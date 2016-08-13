#!/usr/bin/env perl
#
# A user-friendly PERL interface to the CAP source inversion code cap
#
# written by Lupei Zhu, 3/6/1998, Caltech
# 
# revision history
#	6/18/2001	add usage and documentation.
#	11/05/2012	add isotropic and CLVD search (-J).
#	1/13/2013	add option to output potency tensor parameters.
#

# these are the only things one need to change based on the site installation
$home = $ENV{HOME};			# my home directory
require "$home/Src/cap/cap_plt.pl";	# include plot script

#================defaults======================================
$cmd = "cap";
$green = "$home/data/models/Glib";	#green's function location
$repeat = 0;
$bootstrap = 0;
$fm_thr = 0.01;
$dirct='';
$disp=0;
$mltp=0;
$weight="weight.dat";

# plotting
$plot = 0;
$amplify = 0.5;
$sec_per_inch = 40;
$keep = 0;
$rise = 0.5;

# filters and window lengths
($f1_pnl, $f2_pnl, $f1_sw, $f2_sw, $m1, $m2) = (0.02,0.2,0.02,0.1,35,70);

# max. shifts
$max_shft1=1;		# max. shift for Pnl
$max_shft2=5;		# max. shift for surface wave
$tie = 0.5;		# tie between SV and SH

# weights between different portions
$weight_of_pnl=2;		# weight for pnl portions
$power_of_body=1;		# distance scaling power for pnl waves
$power_of_surf=0.5;

# apparent velocities
#($vp, $love, $rayleigh) = (7.8, 3.5, 3.1);
($vp, $love, $rayleigh) = (-1, -1, -1);

# default grid-search ranges
($deg, $dm) = (10, 0.1);
$str1 = 0; $str2 = 360;
$dip1 = 0; $dip2 = 90;
$rak1 = -90; $rak2 = 90;
$iso = $diso = $clvd = $dclvd = 0.;
$vpvs = 0;
$mu = 0;

# number of freedom per sample for estimating uncertainty
$nof = 0.01;
$dt = 0.1;

# rms thresholds for discarding bad traces
@thrshd = (10., 10., 10., 10., 10.);

# command line input, [] means optional, see () for default value
$usage = 
" ===== CAP seismic source tensor inversion using seismic waveforms ====
	Ref: Zhu and Helmberger, 1996, BSSA 86, 1645-1641.
	     Zhu and Ben-Zion, 2013, GJI, submitted.

  Data preparation:
     Put all three-component waveforms station.[r,t,z] of the event in
  a single directory named with the event ID. The data should be velocity
  in cm/s or displacement in cm in the SAC format, with the reference
  time set at the origin time and epicentral distance and azimuth
  set in the SAC header. There should be another file called $weight
  in the same directory, in the following format:
	station_name dist w1 w2 w3 w4 w5 tp ts
  where dist specifies the names of Green functions (dist.grn.?) to be used.
  w1 to w5 are the weights for 5 segments of waveforms: PnlZ, PnlR, Z, R, T.
  tp is first P arrival time if it's set to a positive value. ts is the initial
  time shift for the surface waves, positive means that the data is delayed w.r.t. the model.
  If w2 is set to -1, it indicates that the station is at teleseimic distances and only
  the P (PnlZ) and SH (T) are used. In this case, ts is the S arrival time when it is positive.

  The Greens function library:
     The Greens functions are computed using FK, named as xxx.grn.[0-8] where
  xxx is the distance. All Greens functions from one source depth are placed
  in a single directory named as model_depth. They are in SAC format with
  two time marks set: t1 for the first P arrival and t2 for the first S arrival.
  If first-motion data are to be used in the inversion, the Greens functions
  need to have user1 and user2 set as the P and S take-off angles (in degrees from down).

  Time window determination:
     The inversion breaks the whole record into two windows, the Pnl window
  and the surface wave window. These windows are determined in following way:
    1) If the SAC head has time mark t1, t2 set, the code will use them for
       the Pnl window. The same is true for the surface wave window (using t3 and t4).
    Otherwise,
    2) If positive apparent velocities are given to the code (see -V below), it will use
       them to calculate the time windows:
	  t1 = dist/vp - 0.3*m1, t2 = ts + 0.2*m1
	  t3 = dist/vLove - 0.3*m2, t4 = dist/vRayleigh + 0.7*m2
    Otherwise,
    3) Using the tp, ts in the Green function header
 	  t1 = tp - 0.2*m1,  t2 = t1+m1
	  t3 = ts - 0.3*m2,  t4 = t3+m2
    Here m1, m2 are the maximum lengths for the Pnl and surface waves windows
    (see the -T options below).

  Usage: cap.pl -Mmodel_depth/mag [-B] [-C<f1_pnl/f2_pnl/f1_sw/f2_sw>] [-D<w1/p1/p2>] [-F<thr>] [-Ggreen] [-Hdt] [-Idd[/dm]] [-J[iso[/diso[/clvd[/dclvd]]]]] [-Kvpvs[/mu]] [-L<tau>] [-N<n>] [-O] [-P[<Yscale[/Xscale[/k]]]>] [-Qnof] [-R<strike1/strike2/dip1/dip2/rake1/rake2>] [-S<s1/s2[/tie]>] [-T<m1/m2>] [-V<vp/vl/vr>] [-Udirct] [-Wi] [-Xn] [-Zstring] event_dirs
    -B  output misfit errors of all solutions for bootstrapping late ($bootstrap).
    -C  filters for Pnl and surface waves, specified by the corner
	frequencies of the band-pass filter. ($f1_pnl/$f2_pnl/$f1_sw/$f2_sw).
    -D	weight for Pnl (w1) and distance scaling powers for Pnl (p1) and surface
   	waves (p2). If p1 or p2 is negative, all traces will be normalized. ($weight_of_pnl/$power_of_body/$power_of_surf).
    -F	include first-motion data in the search. thr is the threshold ($fm_thr).
    	The first motion data are specified in $weight. The polarities
	can be specified using +-1 for P, +-2 for SV, and +-3 for SH after
	the station name, e.g. LHSA/+1/-3 means that P is up and SH is CCW.
	The Green functions need to have take-off angles stored in the SAC
	header.
    -G  Green's function library location ($green).
    -H  dt ($dt).
    -I  search interval in strike/dip/rake and mag ($deg/$dm). If dm<0, the gain of each station will be determined by inversion.
    -J  include isotropic and CLVD search using initial values iso/clvd and steps diso/dclvd (0/0/0/0).
    -K	use the vpvs ratio and mu at the source to compute potency tensor parameters ISO and P0. (0/0, off).
    -L  source duration (estimate from mw, can put a sac file name here).
    -M	specify the model, source depth and initial magnitude.
    -N  repeat the inversion n times and discard bad traces ($repeat).
    -O  output CAP input (off).
    -P	generate waveform-fit plot with plotting scale.
    	Yscale: amplitude in inch for the first trace of the page ($amplify).
	Xscale: seconds per inch. ($sec_per_inch).
	append k if one wants to keep those waveforms.
    -Q  number of freedom per sample ($nof)
    -R	grid-search range for strike/dip/rake (0/360/0/90/-90/90).
    -S	max. time shifts in sec for Pnl and surface waves ($max_shft1/$max_shift2) and
	tie between SH shift and SV shift:
	 tie=0 		shift SV and SH independently,
	 tie=0.5 	force the same shift for SH and SV ($tie).
    -T	max. time window lengths for Pnl and surface waves ($m1/$m2).
    -U  directivity, specify rupture direction on the fault plane (off).
    -V	apparent velocities for Pnl, Love, and Rayleigh waves (off).
    -W  use displacement for inversion; 1=> data in velocity; 2=> data in disp ($disp).
    -X  output other local minimums whose misfit-min<n*sigma ($mltp).
    -Z  specify a different weight file name ($weight).

Examples:
> cap.pl -H0.2 -P0.3 -S2/5/0 -T35/70 -F -D2/1/0.5 -C0.05/0.3/0.02/0.1 -W1 -X10 -Mcus_15/5.0 20080418093700
  which finds the best focal mechanism and moment magnitude of tbe 2008/4/18 Southern Illinois earthquake
  20080418093700 using the central US crustal velocity model cus with the earthquake at a depth of 15 km.
  Here we assume that the Greens functions have already been computed and saved in $green/cus/cus_15/.
  The inversion results are saved in cus_15.out with the first line
Event 20080418093700 Model cus_15 FM 115 90  -2 Mw 5.19 rms 1.341e-02   110 ERR   1   3   4
  saying that the fault plane solution is strike 115, dip 90, and rake -2 degrees, with the
  axial lengths of the 1-sigma error ellipsoid of 1, 3, and 4 degrees.
  The rest of the files shows rms, cross-correlation coef., and time shift of individual waveforms.
  The waveform fits are plotted in file cus_15.ps in the event directory.

  To find the best focal depth, repeat the inversion for different focal depths:
> for h in 05 10 15 20 25 30; do ./cap.pl -H0.2 -P0.3 -S2/5/0 -T35/70 -F -D2/1/0.5 -C0.05/0.3/0.02/0.1 -W1 -X10 -Mcus_\$h/5.0 20080418093700; done
  and store all the results in a temporary file:
> grep -h Event 20080418093700/cus_*.out > junk.out
  and then run
> ./depth.pl junk.out 20080418093700 > junk.ps
  The output from the above command
Event 20080418093700 Model cus_15 FM 115 90  -2 Mw 5.19 rms 1.341e-02   110 ERR   1   3   4 H  14.8 0.6
  shows that the best focal depth is 14.8 +/- 0.6 km.

  To include isotropic and CLVD in the inversion, use the -J option to specify the starting iso0, clvd0, and search steps. It requires
  that the Green's function library includes the explosion source components (.a, .b, .c).


";

@ARGV > 1 || die $usage;

$ncom = 5;	# 5 segemnts to plot

#input options
foreach (grep(/^-/,@ARGV)) {
   $opt = substr($_,1,1);
   @value = split(/\//,substr($_,2));
   if ($opt eq "B") {
     $bootstrap = 1;
   } elsif ($opt eq "C") {
     ($f1_pnl, $f2_pnl, $f1_sw, $f2_sw) = @value;
   } elsif ($opt eq "D") {
     ($weight_of_pnl,$power_of_body,$power_of_surf)=@value;
   } elsif ($opt eq "F") {
     $fm_thr = $value[0] if $#value >= 0;
   } elsif ($opt eq "G") {
     $green = substr($_,2);
   } elsif ($opt eq "H") {
     $dt = $value[0];
   } elsif ($opt eq "I") {
     $deg = $value[0];
     $dm = $value[1] if $#value > 0;
   } elsif ($opt eq "J") {
     $iso   = $value[0] if $value[0];
     $diso  = $value[1] if $value[1];
     $clvd  = $value[2] if $value[2];
     $dclvd = $value[3] if $value[3];
   } elsif ($opt eq "K") {
     $vpvs = $value[0] if $value[0];
     $mu   = $value[1] if $value[1];
   } elsif ($opt eq "L") {
     $dura = join('/',@value);
   } elsif ($opt eq "M") {
     ($md_dep,$mg) = @value;
   } elsif ($opt eq "N") {
     $repeat = $value[0];
   } elsif ($opt eq "O") {
     $cmd = "cat";
   } elsif ($opt eq "P") {
     $plot = 1;
     $amplify = $value[0] if $#value >= 0;
     $sec_per_inch = $value[1] if $#value > 0;
     $keep = 1 if $#value > 1;
   } elsif ($opt eq "Q") {
     $nof = $value[0];
   } elsif ($opt eq "R") {
     ($str1,$str2,$dip1,$dip2,$rak1,$rak2) = @value;
   } elsif ($opt eq "S") {
     ($max_shft1, $max_shft2) = @value;
     $tie = $value[2] if $#value > 1;
   } elsif ($opt eq "T") {
     ($m1, $m2) = @value;
   } elsif ($opt eq "U") {
     ($rupDir) = @value;
     $pVel = 6.4;
     $sVel = 3.6;
     $rise = 0.4;
     $dirct = "_dir";
   } elsif ($opt eq "V") {
     ($vp, $love, $rayleigh) = @value;
   } elsif ($opt eq "W") {
     $disp = $value[0];
   } elsif ($opt eq "X") {
     $mltp = $value[0];
   } elsif ($opt eq "Z") {
     $weight = $value[0];
   } else {
     printf STDERR $usage;
     exit(0);
   }
}
@event = grep(!/^-/,@ARGV);

unless ($dura) {
  $dura = int(10**(($mg-5)/2)+0.5);
  $dura = 1 if $dura < 1;
  $dura = 9 if $dura > 9;
}

if ( -r $dura ) {	# use a sac file for source time function   
  $dt = 0;
  $riseTime = 1;
} else {
  $riseTime = $rise*$dura;
}

($model, $depth) = split('_', $md_dep);
unless ($depth) {
  $model = ".";
  $depth = 1;
}

foreach $eve (@event) {

  next unless -d $eve;
  print STDERR "$eve $depth $dura\n";

  open(WEI, "$eve/$weight") || next;
  @wwf=<WEI>;
  close(WEI);
  $ncom = 2 if $wwf[0] =~ / -1 /;

  $cmd = "cap$dirct $eve $md_dep" unless $cmd eq "cat";

  open(SRC, "| $cmd") || die "can not run $cmd\n";
  print SRC "$pVel $sVel $riseTime $dura $rupDir\n",$riseTime if $dirct eq "_dir";
  print SRC "$m1 $m2 $max_shft1 $max_shft2 $repeat $bootstrap $fm_thr $tie\n";
  print SRC "@thrshd\n" if $repeat;
  print SRC "$vpvs $mu\n";
  print SRC "$vp $love $rayleigh\n";
  print SRC "$power_of_body $power_of_surf $weight_of_pnl $nof\n";
  print SRC "$plot\n";
  print SRC "$disp $mltp\n";
  print SRC "$green/$model/\n";
  print SRC "$dt $dura $riseTime\n";
  print SRC "$f1_pnl $f2_pnl $f1_sw $f2_sw\n";
  print SRC "$mg $dm\n";
  print SRC "$iso $diso\n";
  print SRC "$clvd $dclvd\n";
  print SRC "$str1 $str2 $deg\n";
  print SRC "$dip1 $dip2 $deg\n";
  print SRC "$rak1 $rak2 $deg\n";
  printf SRC "%d\n",$#wwf + 1;
  print SRC @wwf;
  close(SRC);
  print STDERR "inversion done\n";

  plot:
  if ( $plot > 0 && ($? >> 8) == 0 ) {
     chdir($eve);
     &plot($md_dep, $m1, $m2, $amplify, $ncom, $sec_per_inch);
     unlink(<${md_dep}_*.?>) unless $keep;
     chdir("../");
  }

}
exit(0);
