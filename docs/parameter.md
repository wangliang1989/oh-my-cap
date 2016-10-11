# 反演参数

## 参数使用

    cap.pl -Mmodel_depth/mag [-B] [-C<f1_pnl/f2_pnl/f1_sw/f2_sw>] [-D<w1/p1/p2>] [-F<thr>] [-Ggreen] [-Hdt] [-Idd[/dm]] [-J[iso[/diso[/clvd[/dclvd]]]]] [-Kvpvs[/mu]] [-L<tau>] [-N<n>] [-O] [-P[<Yscale[/Xscale[/k]]]>] [-Qnof] [-R<strike1/strike2/dip1/dip2/rake1/rake2>] [-S<s1/s2[/tie]>] [-T<m1/m2>] [-V<vp/vl/vr>] [-Udirct] [-Wi] [-Xn] [-Zstring] event_dirs

event_dirs 是事件的路径。[]内为可选参数，/是输入参数的分隔符，< >在实际使用中不要键入，这里是为了表明其含义。

## 参数含义

### -C

针对 Pnl 和面波的带通滤波器，由其拐角频限定，默认值是 0.02/0.2/0.02/0.1。

### -Ggreen

格林函数库的位置，如果格林函数库不在 `Glib/` 下，才需要用此参数特别指定。

### -Hdt

dt 的值。再次强调 dt 必须和 SAC 文件的头段 delta、计算格林函数的参数 dt 保持相等。如果这三者不相等，那么计算结果是错误的。这一点是程序设计的要求。

### -Idd

搜索步长，默认值是 10/0.1，表示 strike、dip、rake 按 10 度为步长来搜索，震级为0.1来搜索。

### -Mmodel_depth/mag

指定格林函数，-Mhk_15/5.0表示 hk 模型、深度15公里 和 初始震级 5.0。

### -P[<Yscale[/Xscale[/k]]

绘图参数,Yscale: 第一道的振幅长度，单位 inch。Xscale: 每 inch 的事件长度 append k if one wants to keep those

### -R<strike1/strike2/dip1/dip2/rake1/rake2>

网格搜索的范围，按照 strike/dip/rake，默认值是 0/360/0/90/-90/90

### -S<s1/s2[/tie]>

Pnl 和面波的最大时间偏移，SH 偏移与 SV 偏移之间的联系(tie)。tie = 0，表示 SV 和 SH 偏移相互独立。tie = 0.5，表示强制令 SH 和 SV 偏移相同，默认值是 0.5。
如 -S5/10/0 表示 Pnl波最多可以偏移 5 秒，面波可以偏移 10 秒，SV 和 SH 的偏移相互独立。

### -T<m1/m2>

Pnl 和面波的最大时窗长度，如果确定时窗是用的方法 3 ，则此参数非常重要。

### -V<vp/vl/vr>

Pnl、Love 和 Rayleigh 波的视速度，缺省值为 off，如果确定时窗是用方法 2，则此参数非常重要。

### -Wi

1 表示用的是速度，2 表示用的是位移。

### -Zstring
指定不同的权重文件名，默认值是 weight.dat
