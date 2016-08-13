/*--------------------------------------------------------------------
 * pssac.c
 *
 * pssac will read sacfiles and plot them
 * PostScript code is written to stdout.
 *
 * author: Lupei Zhu, 1995, Caltech
 *
 * Revision:
 *	2/18/1995	Lupei Zhu	initial coding based on psxy, psseis
 *	3/26/2000	Lupei Zhu	modify to be consistent with 3.3.3
 *	7/10/2001	Lupei Zhu	remove map_clip which caused wrong pen
 *					for plotting boundary
 *	9/10/2002	Lupei Zhu	correct yscale for multiple trace
 *					plot so that the amplitude can be
 *					shown from y-tick
 */

/*#include <stdio.h>
#include <string.h>
#include <fcntl.h>*/
#include "gmt.h"
#include "sac.h"

int main (int argc, char **argv) {
  int 	i,j,ii,n,n_files=0,fno,xy_errors[2],nrdc=-99,colr[3];
  int	plot_n,pn,ierr,ntrace;
  float	*yval, *fpt,x0=0,t0,y0,xx0,yy0;
  double *xx,*yy,*xp,*yp;
  double *xxx,*yyy,*xxp,*yyp,cam,cam0;
  char	line[512],sac_file[100],penpen[20],prf, rdc;
  SACHEAD	h;
  BOOLEAN	error=FALSE,norm=FALSE,multi_segments=FALSE,
     reduce=FALSE,window_cut=FALSE,phase_paint=FALSE,intg=FALSE,
     rmean=FALSE,window_amp=FALSE,scaleAll=FALSE, firstTrace=TRUE,
     positioning = FALSE, vertical_trace = FALSE;
  double	west=0.0,east=0.0,south=0.0,north=0.0,size=1.,cut0,cut1,
     delay=0.,t,reduce_vel,ysc,yscale=1.,alpha=0.,dummy1,dummy2;
  struct GMT_PEN	pen;
  
  xy_errors[0]=xy_errors[1]=0;
  argc = GMT_begin (argc,argv);
  GMT_init_pen (&pen, GMT_PENWIDTH);
  
  /* Check and interpret the command line arguments */
  for (i=1; !error && i < argc; i++) {
    if (argv[i][0] == '-') {
      switch(argv[i][1]) {
      /* Common parameters */
      case 'B': case 'J': case 'K': case 'O':
      case 'R': case 'U': case 'X': case 'x': case 'Y':
      case 'y': case '#': case '\0':
	error += GMT_get_common_args (argv[i],&west,&east,&south,&north);
	break;
	
      /* Supplemental parameters */
      case 'C':		/* cut a window of data for plotting */
	ierr=sscanf(&argv[i][2],"%lf/%lf",&cut0,&cut1);
	window_cut=TRUE;
	if (ierr!=2) {
	   cut0=west;
	   cut1=east;
	}
	break;
      case 'E':		/* profile type */
	reduce=TRUE;
	prf=argv[i][2];
	rdc=argv[i][3];
	if (rdc == 't') {
	   if (&argv[i][4]) sscanf(&argv[i][4],"%d",&nrdc);
	}
	else {
	   sscanf(&argv[i][3],"%lf",&reduce_vel);
	}
	break;
      case 'G':		/* paint positive */
	sscanf(&argv[i][2],"%d/%d/%d/%lf",&colr[0],&colr[1],&colr[2],&cam0);
	phase_paint = TRUE;
	break;
      case 'I':		/* integrate */
        intg = TRUE;
	break;
      case 'M':		/* Multiple traces,-Msize */
	multi_segments=TRUE;
	ierr=sscanf(&argv[i][2],"%lf/%lf",&dummy1,&dummy2);
	size *= dummy1;
	if(ierr == 2) {
	   if (dummy2<0.) {
		scaleAll=TRUE;
	   } else {
	   	norm=TRUE;
	   	alpha += dummy2;
	   }
	}
	break;
      case 'r':		/* remove mean */
	rmean=TRUE;
	break;
      case 'S':		/* shift trace */
	sscanf(&argv[i][2],"%lf",&dummy1);
	delay += dummy1;
	break;
      case 'V':		/* plot traces vertically */
	vertical_trace = TRUE;
	break;
      case 'W':		/* Set line attributes */
	GMT_getpen (&argv[i][2],&pen);
	break;
      default:		/* Options not recognized */
	error=TRUE;
	break;
      }
    }
    else n_files++;
  }
  
  if (argc == 1 || error) {	/* Display usage */
    fprintf (stderr,"Usage: pssac standardGMToptions [SACfiles] [-C[t1/t2]] [-E(k|d|a|n|b)(t[n]|vel)] [-Gr/g/b/c] [-I] [-Msize[/alpha]] [-r] [-Sshift] [-V]\n\n\
    pssac plots SAC traces. If no SAC file names is provided in the command line, it expects (sacfile,[x,[y [pen]]) from stdin.\n\
       -C only plot data between t1 and t2\n\
       -E option determines\n\
         (1) profile type:\n\
	  a: azimuth profile\n\
	  b: back-azimuth profiel\n\
	  d: epicentral distance (in degs.) profile\n\
	  k: epicentral distance (in km.) profile\n\
	  n: traces are numbered from 1 to N in y-axis\n\
         (2) time alignment:\n\
	  tn: align up with time mark tn in SAC head\n\
              default is the reference time. Others are\n\
	      n= -5(b), -3(o), -2(a), 0-9 (t0-t9)\n\
	  vel: use reduced velocity\n\
       -G paint amplitudes larger than c with color r/g/b\n\
       -I integrate the trace before plotting\n\
       -M multiple traces\n\
	  size: each trace will normalized to size (in y-unit)\n\
	  size/alpha: if alpha<0, use same scale for all traces\n\
	      else plot absolute amplitude multiplied by size*r^alpha\n\
	      where r is the distance range in km\n\
       -r remove the mean value in the trace\n\
       -S shift traces by shift seconds\n\
       -V plot traces vertically\n");
    exit(-1);
  }

  GMT_put_history (argc, argv);   /* Update .gmtcommands */
  
  GMT_map_setup (west,east,south,north);
  ps_plotinit (CNULL,gmtdefs.overlay,gmtdefs.page_orientation,
       gmtdefs.x_origin,gmtdefs.y_origin,gmtdefs.global_x_scale,
       gmtdefs.global_y_scale,gmtdefs.n_copies,gmtdefs.dpi,
       GMT_INCH,gmtdefs.paper_width,gmtdefs.page_rgb,
       gmtdefs.encoding.name, GMT_epsinfo (argv[0]));
  GMT_echo_command (argc,argv);
  if (gmtdefs.unix_time) GMT_timestamp (argc, argv);
/*  GMT_map_clip_on (GMT_no_rgb,3);*/
  GMT_setpen (&pen);

  ntrace=0;
  fno=0;
  while( (n_files && ++fno<argc) || (n_files==0 && fgets(line,512,stdin))) {
    /* get sac file name */
    if (n_files) {	/* from command line */
       if (argv[fno][0] == '-') continue;
       else strcpy(sac_file,argv[fno]);
    } else {		/* from standard in */
       i=sscanf(line, "%s %f %f %s",sac_file,&x0,&y0,penpen);
       if (i>2) positioning = TRUE;
       if (i>3) {
          /* set pen attribute */
	  GMT_getpen(penpen,&pen);
          GMT_setpen (&pen);
       }
    }

    /* read in sac files */
    ntrace++;
    if ( (yval = read_sac(sac_file, &h)) == NULL ) {
       continue;
    }
    fpt = (float *) &h;

    /* determine time alignment and y-axis location of the trace from profile type*/
    t=t0=h.b+delay;
    if (h.gcarc<-12340.) h.gcarc=h.dist/111.2;
    if (h.dist <-12340.) h.dist=h.gcarc*111.2;
    if (reduce) {
       switch (prf) {
       case 'd':
          yy0=h.gcarc;
          break;
       case 'k':
	  yy0=h.dist;
          break;
       case 'a':
          yy0=h.az;
          break;
       case 'b':
	  yy0=h.baz;
	  break;
       case 'n':
          yy0=ntrace;
          break;
       default:
          fprintf(stderr,"wrong choise of profile type (d|k|a|n)\n");
          exit(3);
       }
       if (rdc == 't') {
          if (nrdc>-6 && nrdc<10) t-=*(fpt + 10 + nrdc);
       }
       else {
          t-=fabs(h.dist)/reduce_vel;
       }
    }
    if (! positioning ) y0 = yy0;

    xx=( double *) GMT_memory(VNULL,(size_t)h.npts,sizeof(double),"pssac");
    yy=( double *) GMT_memory(VNULL,(size_t)h.npts,sizeof(double),"pssac");
    t += x0;
    for(yy0=0.,n=0,i=0;i<h.npts;i++) {
      if( (window_cut && t>=cut0 && t<=cut1) || ( !window_cut) ){
	xx[n]=t;
	if (intg) {yy[n] = yy0;yy0+=yval[i];} else yy[n]=yval[i];
	n++;
      }
      t += h.delta;
    }
    if(n==0) {
       GMT_free((void *)xx);
       GMT_free((void *)yy);
       continue;
    }

    if(multi_segments){
      h.depmax=-1.e20;h.depmin=1.e20;h.depmen=0.;
      for(i=0;i<n;i++){
         h.depmax=h.depmax > yy[i] ? h.depmax : yy[i];
	 h.depmin=h.depmin < yy[i] ? h.depmin : yy[i];
	 h.depmen += yy[i];
      }
      h.depmen = h.depmen/n;
      if(rmean) for(i=0;i<n;i++) yy[i]-=h.depmen;

      if(norm)	yscale=pow(h.dist,alpha)*size;
      else {
	if (!scaleAll || firstTrace) {
	   yscale=size*fabs((north-south)/(h.depmax-h.depmin)/project_info.pars[1]);
	   firstTrace=FALSE;
	}
      }

      for(i=0;i<n;i++) yy[i]=(double) yy[i]*yscale + y0;
    }

    if (vertical_trace) {
       xp = (double *) GMT_memory(VNULL, (size_t)n, sizeof (double), "pssac");
       memcpy((void *)xp, (void *)yy, n*sizeof(double));
       memcpy((void *)yy, (void *)xx, n*sizeof(double));
       memcpy((void *)xx, (void *)xp, n*sizeof(double));
       GMT_free((void *)xp);
    }

    plot_n=GMT_geo_to_xy_line (xx,yy,n);
    xp=(double *) GMT_memory (VNULL,(size_t)plot_n,sizeof (double),"pssac");
    yp=(double *) GMT_memory (VNULL,(size_t)plot_n,sizeof (double),"pssac");
    memcpy ((void *)xp,(void *)GMT_x_plot,plot_n * sizeof (double));
    memcpy ((void *)yp,(void *)GMT_y_plot,plot_n * sizeof (double));

    if (phase_paint) {
       xxx=(double *) GMT_memory(VNULL,(size_t)(n+2),sizeof (double),"pssac");
       yyy=(double *) GMT_memory(VNULL,(size_t)(n+2),sizeof (double),"pssac");
       cam = y0+cam0*yscale;
       xx0 = xx[0];
       yy0 = yy[0]-1;
       for(i=0; i<n && xx[i]<east; i++) {
	     ii = 0;
             if ( yy[i]>cam && xx[i]>west ) {
   	        yyy[ii] = cam;
		xxx[ii] = xx0+(yyy[ii]-yy0)*(xx[i]-xx0)/(yy[i]-yy0);
		if (xxx[ii]<west || xxx[ii]>xx[i]){
		   xxx[ii] = west;
		   ii++;
		   xxx[ii] = west;
		   yyy[ii] = yy0+(xxx[ii]-xx0)*(yy[i]-yy0)/(xx[i]-xx0);
		}
   	        ii++;
   	        while(i<n && yy[i]>cam && xx[i]<east) {
   	           xxx[ii] = xx[i];
   	           yyy[ii] = yy[i];
   	           ii++;
   	           i++;
   	        }
		if ( i==n || !(xx[i]<east) ) {
		   xx0 = xx[i-1];
		   yy0 = yy[i-1]-1;
		} else {
		   xx0 = xx[i];
		   yy0 = yy[i];
		}
                xxx[ii] = xx[i-1] + (cam-yy[i-1])*(xx0-xx[i-1])/(yy0-yy[i-1]);
   	        yyy[ii] = cam;
   	        ii++;
                if ((pn=GMT_geo_to_xy_line(xxx,yyy,ii)) < 3 ) continue;
                xxp=(double *) GMT_memory (VNULL,(size_t)pn,sizeof (double),"pssac");
                yyp=(double *) GMT_memory (VNULL,(size_t)pn,sizeof (double),"pssac");
                memcpy ((void *)xxp,(void *)GMT_x_plot,pn*sizeof (double));
                memcpy ((void *)yyp,(void *)GMT_y_plot,pn*sizeof (double));
		ps_setpaint(gmtdefs.foreground_rgb);
		ps_setline (pen.width+10);
		ps_line (xxp, yyp, pn, 3, FALSE, FALSE);
		ps_setline (1);
                ps_polygon (xxp,yyp,pn,colr,0);
		GMT_free((void *)xxp);GMT_free((void *)yyp);
             }
	     else {
		xx0 = xx[i];
		yy0 = yy[i];
	     }
       }
       GMT_free((void *)xxx);
       GMT_free((void *)yyy);
       GMT_setpen(&pen);
    }

    ps_line (xp, yp, plot_n, 3, FALSE, FALSE);

    GMT_free((void *)xp);
    GMT_free((void *)yp);
    GMT_free((void *)yval);
    GMT_free((void *)xx);
    GMT_free((void *)yy);
  }
/*  GMT_map_clip_off (); */
  
  if (frame_info.plot) GMT_map_basemap ();
  ps_plotend (gmtdefs.last_page);
  GMT_end (argc,argv);
  return 0;
}
