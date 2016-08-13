/****************************************************************
				cap.c
  Generalized Cut-and-Paste (gCAP) program. The code uses two windows
  (P and S) of 3-component waveforms to determined the moment tensor
    M_ij = M0 * [ sqrt(1-iso*iso)*D_ij  + sqrt(2/3)*iso*I_ij ],
  where I_ij is the unit tensor and D_ij is a deviatoric tensor:
    D_ij = sqrt(1-clvd*clvd)*DC_ij + clvd*CLVD_ij,
  and
    DC_ij   = n_i v_j + n_j v_i,
    CLVD_ij = (2 N_i N_j - v_i v_j - n_i n_j)/sqrt(3),
    (n is the fault normal, v is the slip vector, N=nXv)
    iso = tr(M)/M0/sqrt(6),    -1<= iso <=1,
    clvd = sqrt(3/2)*m2,    -0.5 <= clvd <=0.5,
  where m2 is the intermediate eigenvalue of the normalized deviatoric tensor.

  The solution is given in terms of Mw, strike, dip,
  rake, iso, and clvd. The full moment tensor is also given in the
  output file in the formate of
    M0_in_dyncm Mxx Mxy Mxz Myy Myz Mzz
  where x=North, y=East, z=Down.

  For reference, see
  Zhu and Helmberger, Advancements in source estimation techniques using
      broadband regional seismograms, BSSA, 86, 1634-1641, 1996.
  Zhu and Ben-Zion, Parameterization of general seismic potency and moment
      tensors for source inversion of seismic waveform data, GJI, 2013.

  Requirements:
	Green's function -- has P and S arrival time set (t1 and t2 in SAC header)
  Optional:
	Data		 -- P pick (A in SAC header) --> align with t1
			 -- Pnl window (t1 and t2)
			 -- P-SV, SH window (t3 and t4)

  Modify history:
  June 19, 1998	Lupei Zhu	modified from srct.c
  July  9, 1998 Lupei Zhu	use different velocities for love and rayleigh 
  July 16, 1998 Lupei Zhu	improve m0 estimation using parabola near mimimum
  July 19, 1998 Lupei Zhu	allow inputs for time shifts
  July 26, 1998 Lupei Zhu	taper waveforms (w=0.4)
  Jan. 29, 1998 Lupei Zhu	add option of repeat inversion after discard bad comp.
  Nov.  9, 1999 Lupei Zhu	absorb shft_pnl into constant shift
				use rint() to convert float (t/dt) to int
  Dec   2, 1999 Lupei Zhu	taper waveform before conv() use w=0.3
  Dec  27, 1999 Lupei Zhu	compute windows using apparent Vp, Vs
  June 28, 2000 Lupei Zhu	switch to new greens function format
  Feb  15, 2001 Lupei Zhu	taper waveform after conv.
  June 27, 2001 Lupei Zhu	add fm_thr (firt-motion threshold)
  July 16, 2001 Lupei Zhu	add directivity option
  Jan. 02, 2002 Lupei Zhu	add an input for number of freedom per sec (nof_per_samp)
  Oct. 31, 2002 Lupei Zhu	use abolute time in the output sac files
  July 18, 2003 Lupei Zhu	use Butterworth filters to band-pass data
  July 30, 2003 Lupei Zhu	not absorb shft_pnl into constant shift
  Aug. 18, 2003 Lupei Zhu	normalize L2 of misfit by number of points
  Aug. 21, 2003 Lupei Zhu	tie SH and SV using variable tie (0-0.5)
  Sep. 28, 2003 Lupei Zhu	use P and S take-off angles in hd.user1/user2
  Oct. 12, 2003 Lupei Zhu	output other local minimums whose
				misfit-min is less than mltp*sigma.
  Apr. 06, 2004 Lupei Zhu	allow inputing a SAC source time function src.sac
  Sep. 06, 2004 Lupei Zhu	make cap to run above the event_dir level
  Jan. 28, 2007 Lupei Zhu	use C-wrapped buttworth filtering subroutines.
  Aug. 20, 2007 Lupei Zhu	use SAC's Butterworth filter routines.
  Jan. 28, 2008 Lupei Zhu	include teleseismic P and SH in inversion (by setting W_PnlR<0).
				The time windows of the z component and r/t components can be different
				for both the data and Greens functions.
  Mar. 11, 2010 Lupei Zhu	Correct a bug when computing m0 using interpolation.
				Change to no interpolation of FM untill the correct mw is found to avoid unstable interpolation in some cases.
  Mar. 12, 2010 Lupei Zhu       modified from cap.c by adding ISO.
  June 10, 2010 Lupei Zhu	Correct a bug introduced in Jan. 2008 which deleted
				distance compensation and Pnl weighting of the
				Greens functions.
  Feb. 13, 2012 Lupei Zhu       revise the decomposition of m_ij.
  Mar.  2, 2012 Lupei Zhu       correct a bug in using discard_bad_data().
  Mar. 25, 2012 Lupei Zhu       output misfit errors for bootstrapping.
  Sept 13, 2012 Lupei Zhu       correct a bug in iso interpolation.
  Oct. 29, 2012 Lupei Zhu	add CLVD and consolidate the searches for
				mw, iso, and clvd.
  Nov.  6, 2012 Lupei Zhu	correct a bug in CLVD_ij (in radiats.c).
  Jan. 13, 2013 Lupei Zhu	output potency paramters using vpvs and mu.
  Mar.  4, 2013 Lupei Zhu	change clvd to sqrt(3/2)*m2.

  Known bugs:

****************************************************************/
#include "cap.h"

int main (int argc, char **argv) {
  int 	i,j,k,k1,l,m,nda,npt,plot,kc,nfm,useDisp,dof,tele,indx,gindx;
  int	ns, mltp, nup, up[3], total_n, n_shft, nqP, nqS;
  int	n1,n2,mm[2],n[NCP],max_shft[NCP],npts[NRC];
  int	repeat, bootstrap;
  char	tmp[128],glib[128],dep[32],dst[16],eve[32],*c_pt;
  float	x,x1,x2,y,y1,amp,dt,rad[6],arad[4][3],fm_thr,tie,mtensor[3][3],rec2=0.;
  float	rms_cut[NCP], t0[NCP], tb[NRC], t1, t2, t3, t4, srcDelay;
  float	con_shft[STN], s_shft, shft0[STN][NCP];
  float	tstarP, tstarS, attnP[NFFT], attnS[NFFT];
  float *data[NRC], *green[NGR];
  float	bs_body,bs_surf,bs[NCP],weight,nof_per_samp;
  float	w_pnl[NCP];
  float	distance,dmin=100.,vp,vs1,vs2,depSqr=25,vpvs,mu;
  float	*syn,*f_pt,*f_pt0,*f_pt1;
  GRID	grid;
  MTPAR mt[3];
  COMP	*spt;
  DATA	*obs, *obs0;
  FM	*fm, *fm0;
  SOLN	sol;
  SACHEAD hd[NRC];
  FILE 	*f_out;
  float tau0, riseTime, *src;
  char type[2] = {'B','P'}, proto[2] = {'B','U'};
  double f1_pnl, f2_pnl, f1_sw, f2_sw;
  float pnl_sn[30], pnl_sd[30], sw_sn[30], sw_sd[30];
  long int order=4, nsects;
  void  principal_values(float *);
#ifdef DIRECTIVITY
  int ns_pnl, ns_sw;
  float *src_pnl, *src_sw;
  float tau, faultStr, faultDip, rupDir, rupV, pVel, sVel, temp;
  scanf("%f%f%f%f%f",&pVel,&sVel,&riseTime,&tau0,&rupDir);
  rupDir *= DEG2RAD;
  rupV = 0.8*sVel;
#endif
  
  strcpy(eve,argv[1]);
  strcpy(dep,argv[2]);

  /****** input control parameters *************/
  scanf("%f%f%f%f%d%d%f%f",&x1,&y1,&x,&y,&repeat,&bootstrap,&fm_thr,&tie);
  if (repeat) for(j=0;j<NCP;j++) scanf("%f",rms_cut+4-j);
  scanf("%f%f",&vpvs,&mu);
  scanf("%f%f%f",&vp,&vs1,&vs2);
  scanf("%f%f%f%f",&bs_body,&bs_surf,&x2,&nof_per_samp);
  scanf("%d",&plot);
  scanf("%d%d",&useDisp,&mltp);
  scanf("%s",glib);

  /*** input source functions and filters for pnl and sw ***/
  scanf("%f",&dt);
  if (dt>0.) {
     scanf("%f%f",&tau0,&riseTime);
     if ((src = trap(tau0, riseTime, dt, &ns)) == NULL) {
        fprintf(stderr,"fail to make a trapzoid stf\n");
	return -1;
     }
     srcDelay = 0.;
  } else {
     scanf("%s",tmp); scanf("%f",&riseTime);
     if ((src = read_sac(tmp,hd)) == NULL) {
        fprintf(stderr,"fail to read in source time: %s\n",tmp);
        return -1;
     }
     dt = hd->delta;
     ns = hd->npts;
     srcDelay = -hd->b;
  }
  scanf("%lf%lf%lf%lf",&f1_pnl,&f2_pnl,&f1_sw,&f2_sw);
  if (f1_pnl>0.) design(order, type, proto, 1., 1., f1_pnl, f2_pnl, (double) dt, pnl_sn, pnl_sd, &nsects);
  if (f1_sw>0.)  design(order, type, proto, 1., 1., f1_sw, f2_sw, (double) dt, sw_sn, sw_sd, &nsects);

  /** max. window length, shift, and weight for Pnl portion **/
  mm[0]=rint(x1/dt);
  max_shft[3]=max_shft[4]=2*rint(x/dt);
  w_pnl[3]=w_pnl[4]=x2;
  /** max. window length, shift, and weight for P-SV, SH **/
  mm[1]=rint(y1/dt);
  max_shft[0]=max_shft[1]=max_shft[2]=2*rint(y/dt);
  w_pnl[0]=w_pnl[1]=w_pnl[2]=1.;
  /** and tie of time shifts between SH and P-SV **/

  /** input grid-search range **/
  scanf("%f%f",&(mt[0].par),&(mt[0].dd)); mt[0].min =  1.;  mt[0].max = 10.;
  scanf("%f%f",&(mt[1].par),&(mt[1].dd)); mt[1].min = -1.;  mt[1].max = 1.;
  scanf("%f%f",&(mt[2].par),&(mt[2].dd)); mt[2].min = -0.5; mt[2].max = 0.5;
  for(j=0;j<3;j++) {
    scanf("%f%f%f",&x1,&x2,&grid.step[j]);
    grid.n[j] = rint((x2-x1)/grid.step[j]) + 1;
    grid.x0[j] = x1;
  }
  grid.err = (float *) malloc(grid.n[0]*grid.n[1]*grid.n[2]*sizeof(float));
  if (grid.err == NULL ) {
     fprintf(stderr,"fail to allocate memory for storing misfit errors\n");
     return -1;
  }

#ifdef DIRECTIVITY
  faultStr = grid.x0[0]*DEG2RAD;
  faultDip = grid.x0[1]*DEG2RAD;
#endif

  /** input number of stations **/
  scanf("%d",&nda);
  if (nda > STN) {
     fprintf(stderr,"number of station, %d, exceeds max., some stations are discarded\n",nda);
     nda = STN;
  }
  obs = obs0 = (DATA *) malloc(nda*sizeof(DATA));
  fm = fm0 = (FM *) malloc(3*nda*sizeof(FM));
  if (obs == NULL || fm == NULL) {
     fprintf(stderr,"fail to allocate memory for data\n");
     return -1;
  }
  
  /**** loop over stations *****/
  total_n = 0;
  n_shft = 0;
  nfm = 0;
  for(i=0;i<nda;i++) {

    /***** input station name and weighting factor ******/
    scanf("%s%s",tmp,dst);
    for(nup=0,j=0;j<NCP;j++) {
       scanf("%d",&obs->com[4-j].on_off);
       nup += obs->com[4-j].on_off;
    }
    scanf("%f%f",&x1,&s_shft);
    tele = 0;
    bs[0] = bs[1] = bs[2] = bs_surf;
    bs[3] = bs[4] = bs_body;
    if (obs->com[3].on_off<0) {
       tele = 1;
       tstarS = obs->com[1].on_off;
       tstarP = obs->com[2].on_off;
       obs->com[1].on_off = obs->com[2].on_off = obs->com[3].on_off = 0;
       nup = obs->com[0].on_off + obs->com[4].on_off;
       bs[0] = bs[1] = bs[2] = bs_body;
       j = NFFT;
       if (tstarP>0.) fttq_(&dt, &tstarP, &j, &nqP, attnP);
       if (tstarS>0.) fttq_(&dt, &tstarS, &j, &nqS, attnS);
    }
    if (nup==0) {	/* skip this station */
       nda--; i--;
       continue;
    }

    nup = sscanf(tmp,"%[^/]/%d/%d/%d",obs->stn,&up[0],&up[1],&up[2]);
    if ( fm_thr > 1 ) nup = 1;

    /**************input waveforms************/
    strcat(strcat(strcat(strcpy(tmp,eve),"/"),obs->stn), ".t");
    c_pt = strrchr(tmp,(int) 't');
    for(j=0;j<NRC;j++){
      *c_pt = cm[j];
      if ((data[j] = read_sac(tmp,&hd[j])) == NULL) return -1;
      tb[j] = hd[j].b-hd[j].o;
      npts[j] = hd[j].npts;
    }
    obs->az = hd->az;
    obs->dist = distance = hd->dist;
    obs->tele = tele;
    if (x1<=0.) x1 = hd[2].a;
    x1 -= hd[2].o;
    if (tele && s_shft>0.) s_shft -= hd[0].o;
    t1 = hd[2].t1-hd[2].o;
    t2 = hd[2].t2-hd[2].o;
    t3 = hd[0].t3-hd[0].o;
    t4 = hd[0].t4-hd[0].o;

    /**************compute source time function***********/
#ifdef DIRECTIVITY
    temp = hd->az*DEG2RAD-faultStr;
    temp = rupV*cos(temp)*cos(rupDir)-sin(temp)*sin(rupDir)*cos(faultDip);
    tau = tau0*(1-temp/pVel);
    src_pnl = trap(tau, riseTime, dt, &ns_pnl);
    tau = tau0*(1-temp/sVel);
    src_sw  = trap(tau, riseTime, dt, &ns_sw);
    if (src_pnl == NULL || src_sw == NULL) {
       fprintf(stderr, "failed to make src for pnl or sw\n");
       return -1;
    }
    fprintf(stderr,"station %s %5.1f tauS %5.1f\n",obs->stn,hd->az,tau);
#endif
    
    /************input green's functions***********/
    strcat(strcat(strcat(strcat(strcpy(tmp,glib),dep),"/"),dst),".grn.0");
    c_pt = strrchr(tmp,(int) '0');
    for(j=0;j<NGR;j++) {
      *c_pt = grn_com[j];
      indx = 0; if (j>1) indx = 1; if (j>=kk[2]) indx=2;
      if ((green[j] = read_sac(tmp,&hd[indx])) == NULL) {
	 if (*c_pt<'9') return -1;
	 fprintf(stderr,"Warning: non-DC components are ignored\n");
	 memcpy(&hd[indx], &hd[0], sizeof(SACHEAD));
	 green[j] = (float *)calloc(hd[0].npts,sizeof(float));	/*continue without explosion components*/
	 //for(k=0;k<hd[0].npts;k++)green[j][k]=0.;
      }
      conv(src, ns, green[j], hd[indx].npts);
      if (tele) {
         if (tstarP>0. && j>=kk[2]) conv(attnP, nqP, green[j], hd[indx].npts);
         if (tstarS>0. && j< kk[2]) conv(attnS, nqS, green[j], hd[indx].npts);
      }
    }
    if (!tele) {hd[0].t2 = hd[2].t2; hd[0].user2 = hd[2].user2;}

    /* generate first-motion polarity data */
    if (nup>1 && (hd[2].user1<0. || hd[0].user2<0.)) {
      fprintf(stderr,"No P/S take-off angle in Greens' function %s\n",tmp);
    } else {
      obs->alpha = hd[2].user1;
      for(j=1;j<nup;j++) {
        fm->type = up[j-1];
        fm->az = obs->az;
        if (abs(fm->type)==1)	fm->alpha = hd[2].user1;
	else 			fm->alpha = hd[0].user2;
        nfm++;
        fm++;
      }
    }

    /*** calculate time shift needed to align data and syn approximately ****/
    /* positive shift means synthetic is earlier */
    con_shft[i] = -srcDelay;
    if ( x1 > 0.) {			/* if first-arrival is specified */
       con_shft[i] += x1 - hd[2].t1;	/* use it to align with greens' fn*/
    }
    if (tele && s_shft > x1 ) {
       s_shft -= hd[0].t2+con_shft[i];	/* align teleseismic S */
    }

    /** calculate time windows for Pnl and Surface wave portions **/

    /* for Pnl portion */
    if (t1 < 0 || t2 < 0 ) {	/* no time window in the data trace. use default time window in syn */
      if (!tele && vp>0.)
	 t1 = sqrt(distance*distance+depSqr)/vp;	/* use vp to compute t1 */
      else
	 t1 = hd[2].t1;					/* use tp as t1 */
      t1 = t1 - 0.2*mm[0]*dt + con_shft[i];
      //t2 = hd[0].t2 + 0.2*mm[0]*dt + con_shft[i];	/* ts plus some delay */
      t2 = hd[0].t2 + con_shft[i];	/* ts */
    }

    /* do the same for the s/surface wave portion */
    if (t3 < 0 || t4 < 0 ) {
      if (!tele && vs1>0. && vs2> 0.) {
	 t3 = sqrt(distance*distance+depSqr)/vs1 - 0.3*mm[1]*dt;
	 t4 = sqrt(distance*distance+depSqr)/vs2 + 0.7*mm[1]*dt;
      }
      else {
         t3 = hd[0].t2 - 0.3*mm[1]*dt;
         t4 = t3+mm[1]*dt;
      }
      t3 += con_shft[i] + s_shft;
      t4 += con_shft[i] + s_shft;
    }

    /*calculate the time windows */
    n1 = rint((t2 - t1)/dt);	/*Pnl*/
    n2 = rint((t4 - t3)/dt);	/*PSV/SH*/
    if (n1>mm[0]) n1=mm[0];
    if (n2>mm[1]) n2=mm[1];

    /***window data+Greens, do correlation and L2 norms **/
    t0[0]=t3;			/* love wave */
    t0[1]=t0[2]=t4-n2*dt;	/* rayleigh wave */
    t0[3]=t0[4]=t1;		/* Pnl */
    n[0]=n[1]=n[2]=n2;	n[3]=n[4]=n1;
    shft0[i][0] = shft0[i][1] = shft0[i][2] = s_shft;
    shft0[i][3] = shft0[i][4] = 0.;
    if (obs->com[0].on_off>0) n_shft++;
    if (obs->com[1].on_off>0 || obs->com[2].on_off>0) n_shft++;
    if (obs->com[3].on_off>0 || obs->com[3].on_off>0) n_shft++;
    for(spt=obs->com,kc=2,j=0;j<NCP;j++,spt++,kc=NRF) {
      indx  = kd[j];
      gindx = kk[j];
      if (tele) {
	 if (j==2) {indx=1; gindx=2;}		/* no vertical S, use the radial */
         if (j==3) {indx=2; gindx=kk[2];}	/* no radial P, use the vertical */
      }
      spt->npt = npt = n[j];
      spt->b = t0[j];
      if (spt->on_off) total_n+=npt;
      weight = w_pnl[j]*pow(distance/dmin,bs[j]);
      f_pt = cutTrace(data[indx], npts[indx], rint((t0[j]-tb[indx])/dt), npt);
      if ( f_pt == NULL ) {
         fprintf(stderr, "fail to window the data\n");
	 return -1;
      }
      spt->rec = f_pt;
      if (j<3) {if (f1_sw>0.)  apply(f_pt,(long int) npt,0,sw_sn,sw_sd,nsects);}
      else     {if (f1_pnl>0.) apply(f_pt,(long int) npt,0,pnl_sn,pnl_sd,nsects);}
      if (useDisp==1) cumsum(f_pt, npt, dt); /*use displacement data*/
      for(x2=0.,l=0;l<npt;l++,f_pt++) {
	*f_pt *= weight;
	x2+=(*f_pt)*(*f_pt);
      }
      spt->rec2 = x2;
      rec2 += spt->on_off*x2;
      for(m=0,k=0;k<kc;k++) {
	f_pt = cutTrace(green[gindx+k], hd[indx].npts, rint((t0[j]-con_shft[i]-shft0[i][j]-hd[indx].b)/dt), npt);
	if ( f_pt == NULL ) {
	   fprintf(stderr, "fail to window the Greens functions\n");
	   return -1;
	}
	spt->syn[k] = f_pt;
	if (j<3) {
#ifdef DIRECTIVITY
		conv(src_sw, ns_sw, f_pt, npt);
#endif
		if (f1_sw>0.)  apply(f_pt,(long int) npt,0,sw_sn,sw_sd,nsects);
	} else {
#ifdef DIRECTIVITY
		conv(src_pnl, ns_pnl, f_pt, npt);
#endif
		if (f1_pnl>0.) apply(f_pt,(long int) npt,0,pnl_sn,pnl_sd,nsects);
	}
	if (useDisp) cumsum(f_pt, npt, dt);
	for(l=0;l<npt;l++) f_pt[l] *= weight;
	spt->crl[k] = crscrl(npt,spt->rec,f_pt,max_shft[j]);
	for(x=1.,k1=k;k1>=0;k1--,x=2.) {
	  f_pt0=spt->syn[k];
	  f_pt1=spt->syn[k1];
	  for(x2=0.,l=0;l<npt;l++) x2+=(*f_pt0++)*(*f_pt1++);
	  spt->syn2[m++] = x*x2;
	}
      }
      //fprintf(stderr, "%s %d %e\n",obs->stn, j, spt->rec2);
    }

    obs++;
    for(j=0;j<NRC;j++) free(data[j]);
    for(j=0;j<NGR;j++) free(green[j]);

  }	/*********end of loop over stations ********/

  if (nda < 1) {
    fprintf(stderr,"No station available for inversion\n");
    return -1;
  }

  /************grid-search for full moment tensor***********/
  INVERSION:
  sol = error(3,nda,obs0,nfm,fm0,fm_thr,max_shft,tie,mt,grid,0,bootstrap);

  dof = nof_per_samp*total_n;
  x2 = sol.err/dof;		/* data variance */
  /* repeat grid search if needed */
  if ( repeat && discard_bad_data(nda,obs0,sol,x2,rms_cut) ) {
    repeat--;
    goto INVERSION;
  }

  /**************output the results***********************/
  if (sol.flag) fprintf(stderr,"Warning: flag=%d => the minimum %5.1f/%4.1f/%5.1f is at boundary\n",sol.flag,sol.meca.stk,sol.meca.dip,sol.meca.rak);
  else principal_values(&(sol.dev[0]));
  for(i=0; i<3; i++) rad[i] = sqrt(2*x2/sol.dev[i]);
  if (sol.meca.dip>90.) {
     fprintf(stderr,"Warning: dip corrected by %f\n",sol.meca.dip-90);
     sol.meca.dip = 90.;
  }
  //grid.n[0]=grid.n[1]=grid.n[2]=1;
  //grid.x0[0]=sol.meca.stk; grid.x0[1]=sol.meca.dip; grid.x0[2]=sol.meca.rak;
  //sol = error(nda,obs0,nfm,fm0,max_shft,m0,grid,fm_thr,tie);
  strcat(strcat(strcat(strcpy(tmp,eve),"/"),dep),".out");
  f_out=fopen(tmp,"w");
  fprintf(f_out,"Event %s Model %s FM %3d %2d %3d Mw %4.2f rms %9.3e %5d ERR %3d %3d %3d ISO %3.2f %3.2f CLVD %3.2f %3.2f\n",eve,dep,
	(int) rint(sol.meca.stk), (int) rint(sol.meca.dip), (int) rint(sol.meca.rak),
	mt[0].par, sol.err, dof,
	(int) rint(rad[0]), (int) rint(rad[1]), (int) rint(rad[2]),
        mt[1].par, sqrt(mt[1].sigma*x2),mt[2].par, sqrt(mt[2].sigma*x2));
  fprintf(f_out,"# Variance reduction %4.1f\n",100*(1.-sol.err/rec2));
  amp=pow(10.,1.5*mt[0].par+16.1-20);
  nmtensor(mt[1].par,mt[2].par,sol.meca.stk,sol.meca.dip,sol.meca.rak,mtensor);
  fprintf(f_out,"# MomentTensor = %8.3e %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f\n",amp*1.0e13,mtensor[0][0],mtensor[0][1],mtensor[0][2],mtensor[1][1],mtensor[1][2],mtensor[2][2]);
  if (vpvs>0.) {
     x1 = 1.5*vpvs*vpvs-2.;	// eta = (1+nu)/(1-2*nu) = 3/2*vpvs^2 - 2
     x1 = x1*x1;
     y1 = mt[1].par/sqrt(x1+(1-x1)*mt[1].par*mt[1].par);
     fprintf(f_out,"# PotencyTensor ISO = %5.2f",y1);
     if (mu>0.) fprintf(f_out,"   P0 = %8.3e m3\n",amp*1.0e13/mu/sqrt(1-(1-x1)*y1*y1));
     else fprintf(f_out,"\n");
  }
  for(i=1;i<sol.ms;i++) {
     j = sol.others[i];
     if (grid.err[j]-grid.err[sol.others[0]]<mltp*x2) {
	k = j/(grid.n[0]*grid.n[1]);
	k1 = (j-k*grid.n[0]*grid.n[1])/grid.n[0];
	fprintf(f_out,"# %3d %2d %3d %4.2f %9.3e %3.1f\n",
		(int) rint(grid.x0[0]+(j-k1*grid.n[0]-k*grid.n[0]*grid.n[1])*grid.step[0]),
		(int) rint(grid.x0[1]+k1*grid.step[1]),
		(int) rint(grid.x0[2]+k*grid.step[2]),
		mt[0].par,grid.err[j],(grid.err[j]-grid.err[sol.others[0]])/x2);
     }
  } 
  for(obs=obs0,i=0;i<nda;i++,obs++) {
    fprintf(f_out,"%-9s %5.1f/%-5.2f",obs->stn, obs->dist, con_shft[i]);
    for(j=0;j<NCP;j++) {
      k = NCP - 1 - j;
      sol.shft[i][k]=sol.shft[i][k] - max_shft[k]/2;
      kc = sol.cfg[i][k]; if (kc<0) kc = 0;
      fprintf(f_out," %1d %8.2e %2d %5.2f",obs->com[k].on_off,sol.error[i][k],kc,shft0[i][k]+dt*sol.shft[i][k]);
    }
    fprintf(f_out,"\n");
  }
  fclose(f_out);

  if ( ! plot ) return 0;

  /***** output waveforms for both data and synthetics ****/
  i = mm[1]; if(mm[0]>i) i=mm[0];
  syn = (float *) malloc(i*sizeof(float));
  if (syn == NULL) {
     fprintf(stderr,"fail to allocate memory for output\n");
     return -1;
  }
  for(obs=obs0,i=0;i<nda;i++,obs++){
    mt_radiat(obs->az, mtensor, arad);
    rad[0]=arad[3][0];
    for(k=1;k<4;k++) rad[k]=arad[3-k][0];
    for(k=4;k<6;k++) rad[k]=arad[6-k][2];
    strcat(strcat(strcat(strcat(strcat(strcpy(tmp,eve),"/"),dep), "_"),obs->stn),".0");
    c_pt = strrchr(tmp,(int) '0');
    for(kc=2,f_pt=rad+NRF,spt=obs->com,j=0;j<NCP;j++,spt++,kc=NRF,f_pt=rad) {
      npt=spt->npt;
      hd[0] = sachdr(dt, npt, spt->b);
      hd->dist = obs->dist; hd->az = obs->az; hd->user1 = obs->alpha;
      hd->a = hd->b;
      for(l=0;l<npt;l++) syn[l] = spt->rec[l]/amp;
      write_sac(tmp,hd[0],syn);
      (*c_pt)++;
      for(l=0;l<npt;l++) {
	for(x2=0.,k=0;k<kc;k++) x2 += f_pt[k]*spt->syn[k][l];
	syn[l] = sol.scl[i][j]*x2;
      }
      hd->b -= (shft0[i][j]+con_shft[i]);
      hd->a = hd->b-sol.shft[i][j]*dt;
      write_sac(tmp,hd[0],syn);
      (*c_pt)++;
    }
  }
  return 0;
}


// grid-search for the full moment tensor
SOLN	error(	int		npar,	// 3=mw; 2=iso; 1=clvd; 0=strike/dip/rake
		int		nda,
		DATA		*obs0,
		int		nfm,
		FM		*fm,
		float		fm_thr,
		const int	*max_shft,
		float		tie,
		MTPAR		*mt,
		GRID		grid,
		int		interp,
		int		bootstrap
	) {
  int	i, j, k, l, m, k1, kc, z0, z1, z2, debug=0;
  int	i_stk, i_dip, i_rak;
  float	amp, rad[6], arad[4][3], x, x1, x2, y, y1, y2, cfg[NCP], s3d[9];
  float	*f_pt0, *f_pt1, *r_pt, *r_pt0, *r_pt1, *z_pt, *z_pt0, *z_pt1, *grd_err;
  float dx, mtensor[3][3], *r_iso, *z_iso;
  DATA	*obs;
  COMP	*spt;
  SOLN	sol, sol1, sol2, best_sol;

  if ( npar ) {	// search for mw, iso, and clvd ================================

  npar--;
  dx = mt[npar].dd;
  mt[npar].sigma = 0.;
  if (bootstrap) {	// do full-grid search for bootstrapping
     if (dx<0.001) {mt[npar].min=mt[npar].max=mt[npar].par; dx=1.;}
     sol.err = FLT_MAX;
     for(mt[npar].par = mt[npar].min; mt[npar].par<=mt[npar].max; mt[npar].par+=dx) {
        sol1 = error(npar,nda,obs0,nfm,fm,fm_thr,max_shft,tie,mt,grid,0,bootstrap);
	if (sol1.err<sol.err) {
	   sol = sol1;
	   x = mt[npar].par;
	}
     }
     mt[npar].par = x;
  } else {		// do line search for efficiency
     i = 1; if (dx>0.001) i = 0;
     sol = error(npar,nda,obs0,nfm,fm,fm_thr,max_shft,tie,mt,grid,i,bootstrap);
     if (dx>0.001) {
        mt[npar].par += dx;
        sol2 = error(npar,nda,obs0,nfm,fm,fm_thr,max_shft,tie,mt,grid,0,bootstrap);
        if (sol2.err > sol.err) {	/* this is the wrong direction, turn around */
           dx = -dx;
           sol1 = sol2; sol2 = sol; sol  = sol1; /*swap sol, sol2 */
           mt[npar].par += dx;
        }
        while(sol2.err < sol.err) {	/* keep going until passing by the mininum */
           sol1 = sol;
           sol = sol2;
           mt[npar].par += dx;
           if (mt[npar].par>mt[npar].max || mt[npar].par<mt[npar].min) sol2.err = sol1.err;
           else sol2 = error(npar,nda,obs0,nfm,fm,fm_thr,max_shft,tie,mt,grid,0,bootstrap);
        }
        mt[npar].sigma = 2*dx*dx/(sol2.err+sol1.err-2*sol.err);
        mt[npar].par -= dx+0.5*dx*(sol2.err-sol1.err)/(sol2.err+sol1.err-2*sol.err);
        sol = error(npar,nda,obs0,nfm,fm,fm_thr,max_shft,tie,mt,grid,1,bootstrap);
     }
  }
  return(sol);

  } else {	// the base case: grid-search for strike, dip, and rake ========

  amp = pow(10.,1.5*mt[0].par+16.1-20);
  best_sol.err = FLT_MAX;
  grd_err = grid.err;
  for(i_rak=0; i_rak<grid.n[2]; i_rak++) {
     sol.meca.rak=grid.x0[2]+i_rak*grid.step[2];
     for(i_dip=0; i_dip<grid.n[1]; i_dip++) {
       sol.meca.dip=grid.x0[1]+i_dip*grid.step[1];
       for(i_stk=0; i_stk<grid.n[0]; i_stk++) {
          sol.meca.stk=grid.x0[0]+i_stk*grid.step[1];
          nmtensor(mt[1].par,mt[2].par,sol.meca.stk,sol.meca.dip,sol.meca.rak,mtensor);
	  if (check_first_motion(mtensor,fm,nfm,fm_thr)<0) {
		*grd_err++ = sol.err = FLT_MAX;
		continue;
	  }
          if (bootstrap) fprintf(stderr,"BOOTSTRAPPING grid %5.2f %5.2f %5.2f %5.1f %5.1f %5.1f\n", mt[0].par, mt[1].par, mt[2].par, sol.meca.stk, sol.meca.dip, sol.meca.rak);
	  for(obs=obs0,sol.err=0.,i=0;i<nda;i++,obs++){
	    mt_radiat(obs->az,mtensor,arad);
	    rad[0]=amp*arad[3][0];
	    for(k=1;k<4;k++) rad[k]=amp*arad[3-k][0];
	    for(k=4;k<6;k++) rad[k]=amp*arad[6-k][2];
	    
	    /*******find the time shift*************/
	    /**SH surface wave**/
	    spt = obs->com;
	    f_pt0 = spt->crl[0];
	    f_pt1 = spt->crl[1];
	    z0 = spt->on_off>0?1:0;
	    /**PSV surface wave**/
	    spt++;
	    r_pt0 = spt->crl[1];
	    r_pt1 = spt->crl[2];
	    r_pt  = spt->crl[3];
	    r_iso = spt->crl[0];
	    z1 = spt->on_off>0?1:0;
	    spt++;
	    z_pt0 = spt->crl[1];
	    z_pt1 = spt->crl[2];
	    z_pt  = spt->crl[3];
	    z_iso = spt->crl[0];
	    z2 = spt->on_off>0?1:0;
	    for(y1=y2=-FLT_MAX,l=0;l<=max_shft[1];l++) {
	      x =rad[4]*(*f_pt0++)+rad[5]*(*f_pt1++);
	      x1=rad[1]*(*r_pt0++)+rad[2]*(*r_pt1++)+rad[3]*(*r_pt++)+rad[0]*(*r_iso++);
	      x2=rad[1]*(*z_pt0++)+rad[2]*(*z_pt1++)+rad[3]*(*z_pt++)+rad[0]*(*z_iso++);
	      y = (1-tie)*z0*x + tie*(z1*x1 + z2*x2);
	      if (y>y2) {y2=y;cfg[0]=x;sol.shft[i][0]=l;}
	      y = tie*z0*x + (1-tie)*(z1*x1 + z2*x2);
	      if (y>y1) {y1=y;cfg[1]=x1;cfg[2]=x2;m=l;}
	    }
	    sol.shft[i][1]=sol.shft[i][2]=m;
	    /**Pnl*/
	    spt++;
	    r_pt0 = spt->crl[1];
	    r_pt1 = spt->crl[2];
	    r_pt  = spt->crl[3];
	    r_iso = spt->crl[0];
	    z1 = spt->on_off>0?1:0;
	    spt++;
	    z_pt0 = spt->crl[1];
	    z_pt1 = spt->crl[2];
	    z_pt  = spt->crl[3];
	    z_iso = spt->crl[0];
	    z2 = spt->on_off>0?1:0;
	    for(y1=-FLT_MAX,l=0;l<=max_shft[3];l++) {
	      x1=rad[1]*(*r_pt0++)+rad[2]*(*r_pt1++)+rad[3]*(*r_pt++)+rad[0]*(*r_iso++);
	      x2=rad[1]*(*z_pt0++)+rad[2]*(*z_pt1++)+rad[3]*(*z_pt++)+rad[0]*(*z_iso++);
	      y = z1*x1 + z2*x2;
	      if (y>y1) {y1=y;cfg[3]=x1;cfg[4]=x2;m=l;}
	    }
	    sol.shft[i][3]=sol.shft[i][4]=m;
	    spt -= NCP - 1;
	    
	    /***error calculation*****/
	    for(kc=2,f_pt1=rad+NRF,j=0;j<NCP;j++,spt++,kc=NRF,f_pt1=rad) {

	      /* compute the L2 norm of syn */
	      for(x2=0.,f_pt0=spt->syn2,k=0;k<kc;k++)
		for(k1=k;k1>=0;k1--)
		  x2+=f_pt1[k]*f_pt1[k1]*(*f_pt0++);

	      y1 = 1.;
	      /* find out the scaling factor for teleseismic distances */
	      if (obs->tele && spt->on_off) {
	         if (cfg[j]>0.) y1 = cfg[j]/x2;
		 else y1 = 0.;
	      }
	      sol.scl[i][j] = y1;

	      x1 = spt->rec2+x2*y1*y1-2.*cfg[j]*y1;
	      sol.error[i][j] = x1;	/*L2 error for this com.*/
	      sol.cfg[i][j] = 100*cfg[j]/sqrt(spt->rec2*x2);
	      sol.err += spt->on_off*x1;
	      //if (bootstrap) fprintf(stderr,"BOOTSTRAPPING %-10s %d %d %9.3e\n", obs->stn, j, spt->on_off, x1);

	    }

	  } /*-------------------------end of all stations*/
	  *grd_err++ = sol.err;		/*error for this solution*/
	  if (bootstrap) fprintf(stderr,"BOOTSTRAPPING chi2 %9.3e\n", sol.err);
	  if (best_sol.err>sol.err) best_sol = sol;

       }
    }
  }
  if (debug) fprintf(stderr, "Mw=%5.2f  iso=%5.2f clvd=%5.2f misfit = %9.3e\n", mt[0].par, mt[1].par, mt[2].par, best_sol.err);
  for(i=0;i<6;i++) best_sol.dev[i]  = 1.;
  if (bootstrap || interp == 0) return(best_sol);
  /* do interpolation */
  best_sol.err = grid3d(grid.err,&(grid.n[0]),s3d,&(best_sol.flag),&(best_sol.ms),best_sol.others);
  if (debug) fprintf(stderr, " interpolation  misfit = %9.3e\n", best_sol.err);
  best_sol.meca.stk = grid.x0[0]+s3d[0]*grid.step[0];
  best_sol.meca.dip = grid.x0[1]+s3d[1]*grid.step[1];
  best_sol.meca.rak = grid.x0[2]+s3d[2]*grid.step[2];
  for(i=0;i<3;i++) best_sol.dev[i]  = s3d[3+i]/(grid.step[i]*grid.step[i]);
  best_sol.dev[3] = s3d[6]/(grid.step[0]*grid.step[1]);
  best_sol.dev[4] = s3d[7]/(grid.step[0]*grid.step[2]);
  best_sol.dev[5] = s3d[8]/(grid.step[1]*grid.step[2]);
  return(best_sol);

  }
}
