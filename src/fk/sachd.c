/************************************************************
*	Modify SAC header fields
*	Usage
*		sached header_variable_name value ... f sac_files
*	Lupei Zhu	4/10/2009 SLU	initial codeing.
*	Lupei Zhu	3/28/2010 SLU 	add kztime.
*************************************************************/

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "sac.h"

#define MAXF 40

int main(int argc, char **argv) {
  int		i,j,ls[MAXF],nl,kztime[6];
  float		*pt,*data,value[MAXF];
  char		sac_file[128];
  SACHEAD	hd;

  if(argc<2) {
      fprintf(stderr,"Change some SAC header field values.\nUsage: %s name float_value [kztime year[/jday[/hour[/min[/sec[/msec]]]]]] ... f sac_file ...\n",argv[0]);
      return 0;
  }

  nl=0;argv++;argc--;
  while ( argc && *argv[0] != 'f' ) {
     ls[nl] = sac_head_index(argv[0]);
     if (ls[nl]<0 ||ls[nl]>70) {
	fprintf(stderr, "Error: %s not in sac head or not allowed to change\n",argv[0]);
	return -1;
     }
     argv++; argc--;
     if ( argc<1 ) {
        fprintf(stderr, "Error: expect a value\n");
	return -1;
     }
     if (ls[nl]<70)
        sscanf(argv[0],"%f",&value[nl]);
     else {
        j = sscanf(argv[0],"%d/%d/%d/%d/%d/%d",kztime,kztime+1,kztime+2,kztime+3,kztime+4,kztime+5);
	for(i=j; i<6; i++) kztime[i] = 0;
	if (j==1) kztime[1] = 1;
     }
     nl++; argv++; argc--;
  }

  i = 0;
  pt = (float *) &hd;
  while( (argc>1 && ++i<argc && strcpy(sac_file, argv[i]))
      || (argc<1 && fgets(sac_file,128,stdin)) ) {
      fprintf(stderr,"%s\n",sac_file);
      if ( (data = read_sac(sac_file, &hd)) == NULL ) continue;
      for (j=0;j<nl;j++) {
         if (ls[j]<70) pt[ls[j]] = value[j];
	 else {
	    hd.nzyear = kztime[0];
	    hd.nzjday = kztime[1];
	    hd.nzhour = kztime[2];
	    hd.nzmin  = kztime[3];
	    hd.nzsec  = kztime[4];
	    hd.nzmsec = kztime[5];
         }
      }
      write_sac(sac_file, hd, data);
      free(data);
  }

  return 0;

}
