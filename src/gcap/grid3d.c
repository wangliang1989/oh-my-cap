/*******************************************************************
 search for minimum of a 3D array f(ix,iy,iz).
 A true minimum should be less than values of all its 26 neighboring
 points. A flag is set to one if no such minimum is found.
 pt[0-2] is the location (x,y,z) of the minimum. p[3-5] are the 2nd
 differentials. p[6-8] are 2nd cross-differentials.
 In addition to the global minimum, the code also finds *ms<=10 local
 minimums and return their locations in best[].
*******************************************************************/
#include <stdio.h>
#include <math.h>
#include <float.h>
#include <stdlib.h>

float grid3d(float *f, int n[3], float pt[9], int *flag, int *ms, int *best) {
     int i, j, k, m, ix, iy, iz, nxy, nn;
     float f0, eps, g[3][3][3];
     int largerThanNeighbors(float *,int,int,int,int,int n[3]);
     int setNeighbors(float *,int,int,int,int,int n[3],float g[3][3][3]);

     nxy = n[0]*n[1];
     nn = nxy*n[2];
     m = 0;
     for(ix=0;ix<n[0];ix++) {
     for(iy=0;iy<n[1];iy++) {
     for(iz=0;iz<n[2];iz++) {
	i = ix+iy*n[0]+iz*nxy;
	if(f[i]<FLT_MAX&&largerThanNeighbors(f,i,ix,iy,iz,n)==0) {
		for(j=0;j<m;j++) {
		   if (f[i]<f[best[j]]) break;
		}
		m++; if (m>10) m=10;
		for(k=m-1;k>j;k--) best[k]=best[k-1];
		best[k]=i;
	}
     }}}
     if (m==0) {
        fprintf(stderr,"no minimum found\n");
	exit(1);
     }
     *ms=m;
     i=best[0];
     iz = i/nxy; iy = (i-iz*nxy)/n[0]; ix = i-iy*n[0]-iz*nxy;
     *flag = setNeighbors(f,i,ix,iy,iz,n,g);

     f0=f[i];
     pt[3] = g[0][1][1]+g[2][1][1]-2*f0;
     if (pt[3]<FLT_MIN) {fprintf(stderr,"Warning: xx<0\n");pt[3]=FLT_MIN;}
     pt[4] = g[1][0][1]+g[1][2][1]-2*f0;
     if (pt[4]<FLT_MIN) {fprintf(stderr,"Warning: yy<0\n");pt[4]=FLT_MIN;}
     pt[5] = g[1][1][0]+g[1][1][2]-2*f0;
     if (pt[5]<FLT_MIN) {fprintf(stderr,"Warning: zz<0\n");pt[5]=FLT_MIN;}
     pt[6] = 0.25*(g[2][2][1]+g[0][0][1]-g[0][2][1]-g[2][0][1]);
     pt[7] = 0.25*(g[2][1][2]+g[0][1][0]-g[0][1][2]-g[2][1][0]);
     pt[8] = 0.25*(g[1][2][2]+g[1][0][0]-g[1][2][0]-g[1][0][2]);

     eps = 8*pt[3]*pt[4]*pt[5]+2*pt[6]*pt[7]*pt[8]
     	  -2*(pt[4]*pt[7]*pt[7]+pt[5]*pt[6]*pt[6]+pt[3]*pt[8]*pt[8]);
     pt[0] = ( (4*pt[4]*pt[5]-pt[8]*pt[8])*(g[2][1][1]-g[0][1][1])
     	      -(2*pt[5]*pt[6]-pt[7]*pt[8])*(g[1][2][1]-g[1][0][1])
	      -(2*pt[4]*pt[7]-pt[6]*pt[8])*(g[1][1][2]-g[1][1][0]) )/eps;
     pt[1] = (-(2*pt[5]*pt[6]-pt[7]*pt[8])*(g[2][1][1]-g[0][1][1])
     	      +(4*pt[3]*pt[5]-pt[7]*pt[7])*(g[1][2][1]-g[1][0][1])
	      -(2*pt[3]*pt[8]-pt[6]*pt[7])*(g[1][1][2]-g[1][1][0]) )/eps;
     pt[2] = (-(2*pt[4]*pt[7]-pt[6]*pt[8])*(g[2][1][1]-g[0][1][1])
     	      -(2*pt[3]*pt[8]-pt[6]*pt[7])*(g[1][2][1]-g[1][0][1])
	      +(4*pt[3]*pt[4]-pt[6]*pt[6])*(g[1][1][2]-g[1][1][0]) )/eps;
     f0 -= 0.5*(pt[3]*pt[0]*pt[0]
      	       +pt[4]*pt[1]*pt[1]
      	       +pt[5]*pt[2]*pt[2]
      	       +2.*pt[6]*pt[0]*pt[1]
      	       +2.*pt[7]*pt[0]*pt[2]
      	       +2.*pt[8]*pt[1]*pt[2]);
     pt[0]=ix-pt[0];
     pt[1]=iy-pt[1];
     pt[2]=iz-pt[2];
   
     return f0;
}

/* return 1 if f[i0] is larger than the value of any of its 26 neighbor */
int largerThanNeighbors(float *f,int i0,int ix0,int iy0,int iz0,int n[3]) {
    int i,ix,iy,iz,nxy,nn;
    nxy = n[0]*n[1];
    nn = nxy*n[2];
    for(ix=ix0-1;ix<=ix0+1;ix++)
    for(iy=iy0-1;iy<=iy0+1;iy++)
    for(iz=iz0-1;iz<=iz0+1;iz++) {
       i = ix+iy*n[0]+iz*nxy;
       if (i==i0||ix<0||ix>n[0]-1||iy<0||iy>n[1]-1||iz<0||iz>n[2]-1||f[i]==FLT_MAX) continue;
       if (f[i]<f[i0]) return 1;
    }
    return 0;
}

/* duplicate points of f[] to make 26 neighbors g around the point i0
   return 0 if all duplicate points are from f; otherwise return 1
   to indicate the point is one edge */
int setNeighbors(float *f,int i0, int ix0, int iy0, int iz0, int n[3], float g[3][3][3]) {
    int flag, i1, i2, ix, iy, iz, nxy, nn;

    flag = 54;
    nxy = n[0]*n[1]; nn=nxy*n[2];

    for(ix=0;ix<3;ix++)
    for(iy=0;iy<3;iy++)
    for(iz=0;iz<3;iz++)
       g[ix][iy][iz] = f[i0]+0.1*fabs(f[i0]);


    for(iy=0;iy<3;iy++)
    for(iz=0;iz<3;iz++) {
	if (iy0+iy-1<0||iy0+iy-1>=n[1]||iz0+iz-1<0||iz0+iz-1>=n[2]) continue;
	ix = (iy-1)*n[0]+(iz-1)*nxy;
	i1 = i0-1+ix;
	i2 = i0+1+ix;
        if (ix0>0&&f[i1]<FLT_MAX) {
	   g[0][iy][iz] = f[i1];
	   flag--;
	} else if (ix0<n[0]-1&&f[i2]<FLT_MAX) {
	   g[0][iy][iz] = f[i2];
	}
        if (ix0<n[0]-1&&f[i2]<FLT_MAX) {
	   g[2][iy][iz] = f[i2];
	   flag--;
	} else if (ix0>0&&f[i1]<FLT_MAX) {
	   g[2][iy][iz] = f[i1];
	}
    }

    for(ix=0;ix<3;ix++)
    for(iz=0;iz<3;iz++) {
	if (ix0+ix-1<0||ix0+ix-1>=n[0]||iz0+iz-1<0||iz0+iz-1>=n[2]) continue;
	iy = (ix-1)+(iz-1)*nxy;
	i1 = i0-n[0]+iy;
	i2 = i0+n[0]+iy;
        if (iy0>0&&f[i1]<FLT_MAX) {
	   g[ix][0][iz] = f[i1];
	   flag--;
	} else if (iy0<n[1]-1&&f[i2]<FLT_MAX) {
	   g[ix][0][iz] = f[i2];
	}
        if (iy0<n[1]-1&&f[i2]<FLT_MAX) {
	   g[ix][2][iz] = f[i2];
	   flag--;
	} else if (iy0>0&&f[i1]<FLT_MAX) {
	   g[ix][2][iz] = f[i1];
	}
    }

    for(ix=0;ix<3;ix++)
    for(iy=0;iy<3;iy++) {
	if (ix0+ix-1<0||ix0+ix-1>=n[0]||iy0+iy-1<0||iy0+iy-1>=n[1]) continue;
	iz = (ix-1)+(iy-1)*n[0];
	i1 = i0-nxy+iz;
	i2 = i0+nxy+iz;
        if (iz0>0&&f[i1]<FLT_MAX) {
	   g[ix][iy][0] = f[i1];
	   flag--;
	} else if (iz0<n[2]-1&&f[i2]<FLT_MAX) {
	   g[ix][iy][0] = f[i2];
	}
        if (iz0<n[2]-1&&f[i2]<FLT_MAX) {
	   g[ix][iy][2] = f[i2];
	   flag--;
	} else if (iz0>0&&f[i1]<FLT_MAX) {
	   g[ix][iy][2] = f[i1];
	}
    }

    return flag;
}
