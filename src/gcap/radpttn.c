/* output P/SV/SH radiation patterns from a moment-tensor */
#include <stdio.h> 
#include "radiats.h"

int main (int argc, char **argv) {
      int	type, az, alpha;
      float	stk,dip,rak,iso=0.,clvd=0.,mt[3][3];
      if (argc < 5) {
         fprintf(stderr,"Usage %s 1(P)|2(SV)|3(SH) strike dip rake [iso [clvd]]\n\
		Output: azimuth take-off-angle strength\n",argv[0]);
	 return -1;
      }
      sscanf(argv[1],"%d",&type);
      sscanf(argv[2],"%f",&stk);
      sscanf(argv[3],"%f",&dip);
      sscanf(argv[4],"%f",&rak);
      if (argc>5) sscanf(argv[5],"%f",&iso);
      if (argc>6) sscanf(argv[6],"%f",&clvd);
      nmtensor(iso,clvd,stk,dip,rak,mt);
      printf("MT %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f\n",mt[0][0],mt[0][1],mt[0][2],mt[1][1],mt[1][2],mt[2][2]);
      for(az=0;az<360;az+=5) {
      for(alpha=0;alpha<90;alpha+=2) {
         printf("%3d %2d %f\n",az,alpha,radpmt(mt,alpha,az,type));
      }}
      return 0;
}
