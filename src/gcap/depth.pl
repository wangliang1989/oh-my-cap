#!/usr/bin/env perl
#
# find best depth from CAP output and
# plot the misfit error and source mechanism
# as function of depth for each event
# Usage plt_aa.pl result_file event_dir_names ...
#

$minDep = 0;
$maxDep = 50;

($rsl,@event) = @ARGV;

open(RSL,"$rsl") or die "couldn't open $rsl\n";
@aaa=<RSL>;
close(RSL);

while(@event) {
@aa = splice(@event,0,10);
$i=0;
$xx = "-K -Ba50f5/a20f5WSne";
foreach $eve (@aa){
  $ii=1;
  $best=1;
  $min=1.0e+19;
  foreach (grep(/$eve/,@aaa)) {
    chop;
    $line[$ii]=$_;
    @bb=split;
    ($aa,$dep[$ii])=split('_',$bb[3]);
    $strike[$ii]=$bb[5];
    $dip[$ii]=$bb[6];
    $rake[$ii]=$bb[7];
    $mo[$ii]=$bb[9];
    $rms[$ii]=$bb[11];
    if ($min>$rms[$ii]) {$best=$ii;$min=$rms[$ii]}
    $iso[$ii]=$bb[18];
    $clvd[$ii]=$bb[21];
    $ii++;
  }
  $dof = $bb[12];

  next unless $ii>1;
  if ($ii==2) { $dep[0]=0.; $rms[0]=$rms[1];}
  else {$dep[0]   = 2*$dep[1]-$dep[2];		$rms[0]=$rms[2];}
  $dep[$ii] = 2*$dep[$ii-1]-$dep[$ii-2];	$rms[$ii]=$rms[$ii-2];
  $best++ if $best==1 && $ii>2 && $min==$rms[2];
  $adj=0.; $adj=0.001*$rms[$best] if $rms[$best-1] eq $rms[$best] and $rms[$best+1] eq $rms[$best];
  $d1 = $dep[$best]-$dep[$best-1];
  $d2 = $dep[$best+1]-$dep[$best];
  $sigma = $d1*$d2*($d1+$d2)/($d2*($rms[$best-1]-$rms[$best])+$d1*($rms[$best+1]-$rms[$best])+$adj*($d1+$d2));
  $depth = 0.5*($rms[$best+1]-$rms[$best-1])*$sigma/($d1+$d2);
  $min = $rms[$best] - $depth*$depth/$sigma;
  $sigma = sqrt($sigma*$min/$dof);
  $depth = $dep[$best] - $depth;
  printf STDERR "%s H %5.1f %5.1f\n", $line[$best],$depth,$sigma;

  open(PLT, "| psxy -JX3/1.8 -R$dep[0]/$dep[$ii]/-10/100 $xx");
  for($l=$dep[0];$l<$dep[$ii];$l+=0.2) {
    $aa = ($l-$depth)/$sigma;
    printf PLT "%6.3f %6.3f\n",$l,$aa*$aa;
  }
  close(PLT);
  open(PLT, "| psmeca -JX -R -O -K -Sm2.5");
  for($l=1;$l<$ii;$l++) {
    $aa = `radpttn 1 $strike[$l] $dip[$l] $rake[$l] $iso[$l] $clvd[$l] | head -1`;
    @mt = split(' ', $aa);
    printf PLT "%6.1f %6.1f 0 %s %s %s %s %s $f %f 17 0 0 %s\n",$dep[$l],($rms[$l]-$min)/($min/$dof),@mt[6,1,4,3],-$mt[5],-$mt[2],$mo[$l];
  }
  close(PLT);

  if ($i<$#aa) { open(PLT, "| pstext -JX -R -O -K");}
  else  { open(PLT, "| pstext -JX -R -O");}
  printf PLT "%f 92 10 0 0 1 %s h=%4.1f %4.1f\n",$dep[0]+2,$eve,$depth,$sigma;
  close(PLT);
  $xx = "-O -K -Y2 -Ba50f5/a20f5Wsne";
  $i++;
  if ($i == 5) {
    $xx = "-X3.5 -O -K -Y-8 -Ba50f5/a20f5WSne";
  }

}
}
exit(0);
