#include <math.h>
#include <stdlib.h>

/* unit sum trapzoid from convolution of two boxes (durations t1 and t2) */
float *trap(float t1, float t2, float dt, int *n) {
    int i, n1, n2;
    float slope, *s;
    n1 = rint(t1/dt); if (n1<1) n1 = 1;
    n2 = rint(t2/dt); if (n2<1) n2 = 1;
    if (n1 > n2) {
	i = n1;
	n1 = n2;
	n2 = i;
    }
    *n = n1+n2;
    s = (float *) malloc((*n)*sizeof(float));
    if ( s == NULL ) return s;
    slope = 1./(n1*n2);
    s[0] = 0;
    for(i=1;i<=n1;i++) s[*n-i] = s[i]=s[i-1] + slope;
    for(;i<n2;i++) s[i]=s[i-1];
/*
    fprintf(stderr,"%d %d \n",n1,n2);
    slope = 0;for(i=0;i<*n;i++) {slope+=s[i];fprintf(stderr,"%d %f %f\n",i,s[i],slope);}
*/
    return s;
}
