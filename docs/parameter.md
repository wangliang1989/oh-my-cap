# 反演参数

cap.pl -Mmodel_depth/mag [-B] [-C<f1_pnl/f2_pnl/f1_sw/f2_sw>] [-D<w1/p1/p2>] [-F<thr>] [-Ggreen] [-Hdt] [-Idd[/dm]] [-J[iso[/diso[/clvd[/dclvd]]]]] [-Kvpvs[/mu]] [-L<tau>] [-N<n>] [-O] [-P[<Yscale[/Xscale[/k]]]>] [-Qnof] [-R<strike1/strike2/dip1/dip2/rake1/rake2>] [-S<s1/s2[/tie]>] [-T<m1/m2>] [-V<vp/vl/vr>] [-Udirct] [-Wi] [-Xn] [-Zstring] event_dirs

    -B  output misfit errors of all solutions for bootstrapping late ($bootstrap).
    -C  针对 Pnl 和面波的带通滤波器，由其拐角频限定，默认值是 0.02/0.2/0.02/0.1
    -D  weight for Pnl (w1) and distance scaling powers for Pnl (p1) and surface
        waves (p2). If p1 or p2 is negative, all traces will be normalized. ($weight_of_pnl/$power_of_body/$power_of_surf).
    -F  include first-motion data in the search. thr is the threshold ($fm_thr).
        The first motion data are specified in $weight. The polarities
        can be specified using +-1 for P, +-2 for SV, and +-3 for SH after
        the station name, e.g. LHSA/+1/-3 means that P is up and SH is CCW.
        The Green functions need to have take-off angles stored in the SAC
        header.
    -G  格林函数库的位置，如果格林函数库不在 `Glib/` 下，才需要特别指定
    -H  dt，和数据的采样周期相同
    -I  搜索步长，默认值是 10/0.1，表示 strike、dip、rake 按 10 度为步长来搜索，震级为0.1来搜索。
    -J  include isotropic and CLVD search using initial values iso/clvd and steps diso/dclvd (0/0/0/0).
    -K  use the vpvs ratio and mu at the source to compute potency tensor parameters ISO and P0. (0/0, off).
    -L  震源持续时间，输入值为时间，由震级估计，这里可以放置一个 SAC 文件名让程序自己读入
    -M  指定格林函数，-Mhk_15/5.0表示 hk 模型、深度15公里 和 初始震级 5.0
    -N  重复反演 n 次，并且丢弃损坏的道次，默认值是 0
    -O  将 CAP 的输入信息也一并输出出来，默认值是 off，不输出
    -P  绘图参数
        Yscale: 第一道的振幅长度，单位 inch
        Xscale: 每 inch 的事件长度
        append k if one wants to keep those waveforms
    -Q  number of freedom per sample ($nof)
    -R  网格搜索的范围，按照 strike/dip/rake，默认值是 0/360/0/90/-90/90
    -S  Pnl 和面波的最大时间偏移，SH 偏移与 SV 偏移之间的联系(tie)。tie = 0，表示 SV 和 SH 偏移相互独立。tie = 0.5，表示强制令 SH 和 SV 偏移相同，默认值是 0.5。如 -S5/10/0 表示 Pnl波最多可以偏移 5 秒，面波可以偏移 10 秒，SV 和 SH 的偏移相互独立
    -T  Pnl 和面波的最大时窗长度，如果确定时窗是用的方法 3 ，则此参数非常重要
    -U  方向性，指定断层面上的破裂方向，缺省值为 off，亦即不考虑破裂方向
    -V  Pnl、Love 和 Rayleigh 波的视速度，缺省值为 off
    -W  1 表示用的是速度，2 表示用的是位移。
    -X  output other local minimums whose misfit-min<n*sigma ($mltp).
    -Z  指定不同的权重文件名，默认值是 weight.dat