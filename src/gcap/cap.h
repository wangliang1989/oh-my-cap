/***************************************************************
	cap.h		Head file for cap.c
***************************************************************/


#ifndef __CAP_HEAD__
  #define __CAP_HEAD__

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>
#include <float.h>
#include "sac.h"
#include "Complex.h"
#define NRANSI
#include "nr.h"
#include "nrutil.h"
#include "inversion.h"
#include "radiats.h"

/***********************Constants********************************/

#define STN	200		/* up to STN stations */

#define NRC	3		/* 3 components of records */
static char cm[NRC]={'t','r','z'};

#define NCP	5		/* 5 segments, 2*Pnl 2*PSV 1*SH */
static int kd[NCP]={0,1,2,1,2};	/* SH, SVr, SVz, Pnlr, Pnlz */
static int kk[NCP]={0,2,6,2,6};	/* index of 1st Greens' fn for each segment, see below */

#define NRF	4		/* number of fundamental sources: EX, SS, DS, DD. SH only has SS and DS*/
#define NGR	10		/* 8 com. of greens function for DC plus 2 for EX: SHx2, Rx4, Vx4 */
static char grn_com[NGR]={'8','5','b','7','4','1','a','6','3','0'};

#define NFFT	2048		/* for Q operator */

/*********************** Data Structure***************************/

/* focal mechanism (strike, dip, rake) data structure */
typedef struct {
	float	stk;	/* strkie */
	float	dip;	/* dip */
	float	rak;	/* rake */
} MECA;

/* a portion of observed waveform and corresponding 3 components
of Green's functions, cross-correlations, and L2 norms, etc */
typedef struct {
	int	npt;		/* number of points */
	int	on_off;		/* on or off */
	float	*rec;		/* data */
	float	*syn[NRF];	/* Green's functions */
	float	b;		/* beginning time of the data */
/*	float	w; */
	float	rec2;		/* sum rec*rec */
	float	syn2[10];	/* c*sum syn[i]*syn[j], i=0..NRF-1, j=i..0, c=1 if i=j, 2 otherwise */
	float	*crl[NRF];	/* sum rec*syn[i], i=0..NRF-1 */
} COMP;

typedef struct {
	char	stn[10];
	float	*rec[NRC];
	float	*grn[NGR];
	float	az;
	float	dist;
	float	alpha;		/* take-off angle */
	int	tele;		/* 1 if the station is at teleseismic distances*/
	COMP	com[NCP];
} DATA;

typedef struct {
	MECA	meca;
	float	dev[6];			/* uncertainty ellipsis */
	float	err;			/* chi-square of waveform misfits for this solution */
	int	cfg[STN][NCP];		/* correlation for each comp. */
	int	shft[STN][NCP];		/* time shift for each comp. */
	float	error[STN][NCP];	/* chi-square of waveform misfits for each component */
	float   scl[STN][NCP];		/* amplifications to GF for each component */
	int	ms;			/* number of local minimums < 10 */
	int	others[10];		/* top 10 best solutions */
	int	flag;			/* =1 if the best soln is at boundary */
} SOLN;

typedef struct {
	float	par;	// can be mw, iso, or cvld
	float	sigma;	// variance
	float	min, max;	// range
	float	dd;	// search step
} MTPAR;

/* first-motion data */
typedef struct {
	float	az;	/* azimuth */
	float	alpha;	/* take-off angle */
	int	type;	/* 1=P; 2=SV; 3=SH; positive=up; negative=down */
} FM;

/* function declaration */
SOLN	error(int,int,DATA *,int,FM *,float,const int *,float,MTPAR *,GRID,int,int);
void    taper(float *aa, int n);
float	*trap(float, float, float, int *);
float	*cutTrace(float *, int, int, int);
int	discard_bad_data(int,DATA *,SOLN,float,float *);
int	check_first_motion(float mt[3][3], FM *fm, int n, float fm_thr);

#endif
