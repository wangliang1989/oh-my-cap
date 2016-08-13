#include "cap.h"

void    taper(float *aa, int n) {
  int	i, m;
  float	tt, pi1;
  m = rint(0.3*n);
  pi1 = 3.1415926/m;
  for (i=0; i<m; i++) {
    tt = 0.5*(1.-cos(i*pi1));
    aa[i] *= tt;
    aa[n-i-1] *= tt;
  }
}


int discard_bad_data(int nda, DATA *obs, SOLN sol, float sig, float rms_cut[]) {
   int i, j, n;
   float minCC = 50.;
   COMP	*spt;
   n = 0;
   for(i=0;i<nda;i++,obs++) {
     spt = obs->com;
     for(j=0; j<NCP; j++,spt++) {
        if (sol.cfg[i][j]<minCC && sol.error[i][j]/sig > rms_cut[j]) {
	   spt->on_off = 0;
	   n++;
	}
     }
   }
   return(n);
}


void principal_values(float a[]) {
   int i;
   float **b, **v;
   b = matrix(1,3,1,3);
   v = matrix(1,3,1,3);
   for(i=0;i<3;i++) b[i+1][i+1]=a[i];
   b[1][2]=b[2][1]=a[3];b[1][3]=b[3][1]=a[4];b[2][3]=b[3][2]=a[5];
   jacobi(b,3,a,v,&i);
   eigsrt(a,v,3);
   for(i=0;i<3;i++) {a[i] = a[i+1]; if (a[i]<0.0001*a[1]) a[i]=0.0001*a[1];}
   free_convert_matrix(b,1,3,1,3);
   free_matrix(v,1,3,1,3);
}


float *cutTrace(float *trace, int npts, int offset, int n) {
   int m;
   float *cut;
   cut = (float *) calloc(n, sizeof(float));
   if (cut == NULL) return cut;
   m = n+offset;
   if (offset<0) {
      if (m>npts) m = npts;
      if (m>0) memcpy(cut-offset, trace, m*sizeof(float));
   } else {
      if (m>npts) n = npts-offset;
      if (n>0) memcpy(cut, trace+offset, n*sizeof(float));
   }
   taper(cut, n);
   return cut;
}


int check_first_motion(float mt[3][3], FM *fm, int n, float fm_thr) {
  int	i;
  FM	*pt;
  for(pt=fm,i=0;i<n;i++,pt++) {
    if (pt->type*radpmt(mt, pt->alpha, pt->az, abs(pt->type))/abs(pt->type)<fm_thr)
      return -1;
  }
  return 0;

}
