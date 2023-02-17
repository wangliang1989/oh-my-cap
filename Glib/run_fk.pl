#!/usr/bin/env perl
use strict;
use warnings;
use FindBin;
use lib $FindBin::Bin;
require config;

@ARGV >= 1 or die "Usage: perl $0 configname";
my @config = @ARGV;

# 检查文件
my $err = check_fk_file(@config);
die "设置有错误，将导致计算错误，OH MY CAP 中止调用 fk" if $err > 0;

# 判断是否安装了并行模块
my ($MAX_PROCESSES) = check_parl(0);

# 计算格林函数
foreach my $fname (@config) {
    my %pars    = read_config($fname);
    my ($model) = split m/\./, $fname;
    my $flat    = "YES";
    $flat = $pars{"FLAT"} if defined( $pars{"FLAT"} );

    mkdir $model unless ( -d $model );
    open( OUT, "> $model/$model" ) or die;
    print OUT "$pars{'MODEL'}\n";
    close(OUT);
    chdir $model or die;

    fk( $model, $pars{"NT"}, $pars{"DT"}, $pars{"DEPTH"}, $pars{"DIST"}, $flat,
        $MAX_PROCESSES );

    unlink glob "junk.*";
    chdir ".." or die;
}

sub check_fk_file {
    my $err = 0;
    foreach my $fname (@_) {
        my %pars         = read_config($fname);
        my ($model)      = split m/\./, $fname;
        my $nt           = $pars{"NT"};
        my $dt           = $pars{"DT"};
        my @dist         = split m/\s+/, $pars{"DIST"};
        my @source_depth = split m/\s+/, $pars{"DEPTH"};
        my $flat         = "YES";
        $flat = $pars{"FLAT"} if defined( $pars{"FLAT"} );

        print "NT: $nt\nDT: $dt\n";
        print "MODEL:\n$pars{'MODEL'}\n";
        print "FLAT: $flat\n";
        print "DEPTH:\n@source_depth\n";
        print "DIST:\n@dist\n";

        # 震源不能在地层界面上
        my $layer_depth = 0;
        my @layer       = split m/\n/, $pars{'MODEL'};
        foreach (@layer) {
            my $layer       = trim($_);
            my ($thickness) = split m/\s+/, $layer;
            $layer_depth = $layer_depth + $thickness;
            foreach (@source_depth) {
                if ( $_ == $layer_depth ) {
                    print "设置错误：震源在 ${_}km 深度的界面上\n";
                    $err++;
                }
            }
        }

        # FLAT 只能是YES或者NO
        unless ( $flat eq 'YES' or $flat eq 'NO' ) {
            print "设置错误：FLAT 只能是 YES 或者 NO\n";
            $err++;
        }
    }
    return ($err);
}

sub check_parl {
    my $MAX_PROCESSES = 0;
    eval "use Parallel::ForkManager";
    unless ($@) {

        # 计算当前计算机逻辑核核数
        my ($system) = split m/\s+/, `uname`;
        if ( $system eq 'Darwin' ) {
            ($MAX_PROCESSES) = split m/\s+/, `sysctl -n hw.ncpu`;
        }
        elsif ( $system eq 'Linux' ) {
            ($MAX_PROCESSES) = split m/\n/,
              `cat /proc/cpuinfo |grep "processor"|wc -l`;
        }
    }
    return ($MAX_PROCESSES);
}

sub fk {
    my ( $model, $nt, $dt, $DEPTH, $DIST, $flat, $MAX_PROCESSES ) = @_;
    my @source_depth = split m/\s+/, $DEPTH;
    my @dist         = split m/\s+/, $DIST;
    my @cmds;
    foreach my $depth (@source_depth) {
        my $m_parameter = "$model/$depth";
        $m_parameter = "$m_parameter/f" if $flat eq "YES";

        # 计算双力偶
        my $cmd1 = "-M$m_parameter -N$nt/$dt -S2 @dist";

        # 计算爆炸源
        my $cmd2 = "-M$m_parameter -N$nt/$dt -S0 @dist";
        push @cmds, "$cmd1\n$cmd2";
    }
    single_thread(@cmds)                    if $MAX_PROCESSES == 0;
    multithreading( $MAX_PROCESSES, @cmds ) if $MAX_PROCESSES > 0;
}

sub single_thread {
    print "OH MY CAP 没有找到并行模块，将串行调用 fk\n";
    print "建议安装 Parallel::ForkManager\n";
    sleep(5);
    foreach (@_) {
        my ( $cmd1, $cmd2 ) = split m/\n/;
        system "fk.pl $cmd1";
        system "fk.pl $cmd2";
    }
}

sub multithreading {
    use Parallel::ForkManager;
    my $MAX_PROCESSES = shift;
    print "OH MY CAP 已找到并行模块，将并行调用 fk\n";
    sleep(5);
    my $pm = Parallel::ForkManager->new($MAX_PROCESSES);
    foreach (@_) {
        my ( $cmd1, $cmd2 ) = split m/\n/;
        system "fk_parallel.pl $cmd1";
        system "fk_parallel.pl $cmd2";
    }
    $pm->wait_all_children;
}
