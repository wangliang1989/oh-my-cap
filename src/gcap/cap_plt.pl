# this subroutine plots waveform fits produced by source inversion srct

sub plot {
  local($mdl, $t1, $t2, $am, $num_com, $sec_per_inch) = @_;
  local($nn,$tt,$plt1,$plt2,$plt3,$plt4,$i,$nam,$com1,$com2,$j,$x,$y,@aa,$rslt,@name,@aztk);
  local $keepBad = 0;
  system "gmtset MEASURE_UNIT inch";
  system "gmtset PAGE_ORIENTATION portrait"; 
  @trace = ("1/255/255/255","3/0/0/0");       # plot data trace
  @name = ("Pz","Pr","Sz"," Sr","Sh");
  
  ($nn,$hight) = (12,10.5);	# 10 rows of traces per 10.5 in.
  
  $sepa = 0.1*$sec_per_inch;
  ($tt, $inc) = (2*$t1 + 3*$t2 + 4*$sepa, 1);
  ($tt, $inc) = ($t1 + $t2 + $sepa, 4) if $num_com == 2;
  $width = 0.1*int(10*$tt/$sec_per_inch+0.5);
  @x0 = ($t1+$sepa, $t1+$sepa, $t2+$sepa, $t2+$sepa, $t2);

  open(FFF,"$mdl.out");
  @rslt = <FFF>;
  close(FFF);
  @meca = split('\s+',shift(@rslt));
  @variance = split('\s+',shift(@rslt));
  @tensor = split('\s+',$rslt[0]);
  @others = grep(/^#/,@rslt);
  @rslt=grep(!/^#/,@rslt);
  
  $outps = "$mdl.ps";
  if ($am>0.) {$am = "$am/-1";} else {$am=-$am;}
  $plt1 = "| pssac -JX$width/$hight -R0/$tt/0/$nn -Y0.2 -Ent-2 -M$am -K >> $outps";
  $plt2 = "| pstext -JX -R -O -K -N >> $outps";
  $plt3 = "| psmeca -JX1/1 -R-1/1/-1/1 -Sa5 -G100 -Y9.5 -X-0.7 -O -K >> $outps";
  $plt3 = "| psmeca -JX1/1 -R-1/1/-1/1 -Sm8 -G100 -Y9.5 -X-0.7 -O -K >> $outps" if $tensor[1] eq "MomentTensor";
  $plt4 = "| psxy -JPa1 -R0/360/0/1 -Sx0.1 -W2/255/0/0 -O >> $outps";
  #$plt1=$plt2=$plt3=$plt4="|cat";		# for testing

  $i = 0; @aztk=();
  foreach (@rslt) {
    @aa = split;
    next if $aa[2] == 0;
    $x = `saclst az user1 f ${mdl}_$aa[0].0`;
    @aa = split(' ', $x);
    if ($aa[2]>90.) {$aa[1] += 180; $aa[2]=180-$aa[2];}
    $aztk[$i] = sprintf("%s %f\n",$aa[1],sqrt(2.)*sin($aa[2]*3.14159/360));
    $i++;
  }

  unlink($outps) if -e $outps;
  while (@rslt) {
    open(PLT, $plt1);
    $i = 0;
    @aaaa = splice(@rslt,0,$nn-2);
    foreach (@aaaa) {
      @aa = split;
      $nam = "${mdl}_$aa[0].";
      $x=0;
      for($j=0;$j<5;$j+=$inc) {
        $com1=8-2*$j; $com2=$com1+1;
	if ($aa[4*$j+2]>0) {
	   printf PLT "%s %f %f 5/0/0/0\n",$nam.$com1,$x,$nn-$i-2;
           printf PLT "%s %f %f 3/255/0/0\n",$nam.$com2,$x,$nn-$i-2;
	} elsif ($keepBad) {
	   printf PLT "%s %f %f 2/0/255/0\n",$nam.$com1,$x,$nn-$i-2;
           printf PLT "%s %f %f 3/255/0/0\n",$nam.$com2,$x,$nn-$i-2;
	}
        $x = $x + $x0[$j];
      }
      $i++;
    }
    close(PLT);
    
    open(PLT, $plt2);
    $y = $nn-2;
    foreach (@aaaa) {
      @aa = split;
      $x = 0;
      printf PLT "%f %f 10 0 0 1 $aa[0]\n",$x-0.8*$sec_per_inch,$y;
      printf PLT "%f %f 10 0 0 1 $aa[1]\n",$x-0.7*$sec_per_inch,$y-0.2;
      for($j=0;$j<5;$j+=$inc) {
	if ($aa[4*$j+2]>0 || $keepBad) {
          printf PLT "%f %f 10 0 0 1 $aa[4*$j+5]\n",$x,$y-0.4;
          printf PLT "%f %f 10 0 0 1 $aa[4*$j+4]\n",$x,$y-0.6;
	}
        $x = $x + $x0[$j];
      }
      $y--;
    }
    $x = 0.5*$sec_per_inch; 
    $y = $nn-0.2;
    printf PLT "$x $y 12 0 0 0 @meca[0,1,2] and Depth $meca[3]\n"; $y-=0.3;
    printf PLT "$x $y 12 0 0 0 @meca[4..22]\n";$y-=0.3;
    printf PLT "$x $y 12 0 0 0 @variance[1..3]\n" if $variance[1] eq "Variance";
    $x = 0.2*$sec_per_inch;
    for($j=0;$j<5;$j+=$inc) {
      printf PLT "%f %f 12 0 0 1 $name[$j]\n",$x,$nn-1.5;
      $x = $x+$x0[$j];
    }
    close(PLT);
    
    open(PLT, $plt3);
    if ($tensor[1] eq "MomentTensor") {
       printf PLT "0 0 0 @tensor[9,4,7,6] %f %f 17\n",-$tensor[8],-$tensor[5];
    } else {
       print PLT "0 0 0 @meca[5,6,7] 1\n";
    }
    #$x = 2;
    #foreach (@others) {
       #split;
       #next if $_[1] eq "Variance" or $_[1] eq "tensor";
       #printf PLT "%f -0.2 0 @_[1,2,3] 0.5 0 0 $_[6]\n",$x; $x+=1.5;
    #}
    close(PLT);
    open(PLT, $plt4);
    foreach (@aztk) {
      print PLT;
    }
    close(PLT);
    
  }
  
}
1;
