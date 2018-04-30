# 反演参数

反演各个参数的意义在朱老师的脚本 `src/gcap/cap.pl` 中有官方的说明。

另外，请读者一定明确设置参数究竟是在做什么。
`src/gcap/cap.pl` 就是 gCAP 的反演脚本。在这个脚本中，各个反演参数已经有一个默认值。
设置反演参数就是去改这些默认值。学习参数设置时首先要注意了解什么情况需要设置参数，修改默认值。

这里对我有充分把握的参数进行说明。自己没有用过的参数，我虽然能或多或少揣摩意思，但也只是英译汉的层次，为了保证正确性，暂时不写，只用原英文说明代替。

## -B

output misfit errors of all solutions for bootstrapping late ($bootstrap).

## -Cf1_pnl/f2_pnl/f1_sw/f2_sw 滤波拐角频率

在反演前，gCAP 会先对观测数据做滤波。

## -Dw1/p1/p2 Pnl 和面波的权重

w1 是 Pnl 的权重。p1 和 p2 是目标函数中 Pnl 和面波的归一化距离的指数。 If p1 or p2 is negative, all traces will be normalized.

## -Fthr

include first-motion data in the search. thr is the threshold ($fm_thr).
The first motion data are specified in $weight.
The polaritiescan be specified using +-1 for P, +-2 for SV, and +-3 for SH afte the station name, e.g. LHSA/+1/-3 means that P is up and SH is CCW.
The Green functions need to have take-off angles stored in the SAC header.

## -Ggreen 格林函数库位置

green 是格林函数库所在的路径。
除非你没有像例子中那样把格林函数就放在 `Glib/` 下，否则 **不要** 设置这个参数。

## -Hdt 采样周期

dt 是采样周期必须和数据预处理的 RESAMPLE 参数和格林函数的 DT 二者相同。一定要设置，除非采样周期恰好是 0.1。

## -Idd[/dm] 搜索步长

dd 是断层面三个参数（strike、dip 和 rake）的搜索步长，dm 是震级的搜索步长。默认值是 10/0.1，如果想用其他步长则需要设置。

If dm<0, the gain of each station will be determined by inversion.

我没有用过负数的情况。

## -Jiso[/diso[/clvd[/dclvd]]] 非双力偶成分设置

只有需要搜索非双力偶成分，才需要设置这个参数。iso 和 clvd 是 ISO 和 CLVD 的反演初始值。diso 和 dclvd 是 ISO 和 CLVD 搜索的步长。
如果需要搜索非双力偶成分，通常设置为 0/0.1/0/0.1。

## -Kvpvs[/mu]

use the vpvs ratio and mu at the source to compute potency tensor parameters ISO and P0. (0/0, off).

## -Ldura 震源持续时间

地震波形是格林函数和震源时间函数（不是震源持续时间）的卷积。
在 gCAP 中，认为震源时间函数是一个等腰梯形。等腰梯形由底边长和梯形上升阶段占据的底边长的比例决定。
震源持续时间就是这里的底边边长。dura 为震源持续时间的长度（单位：秒）。也可以用 sac 文件来指定，我没用过这种方式。

如果不设置这个参数，gCAP会使用 -M 参数中的震级，用经验公式计算。

## -Mmodel_depth/mag 模型、深度、震级

**gCAP 反演程序唯一的必选选项，必须设置**

model 是模型名称。depth 是深度。gCAP 会在格林函数库的路径下去寻找相应模型、相应深度的格林函数文件。
mag 是震级，用预估的矩震级值。

## -Nn

repeat the inversion n times and discard bad traces ($repeat).

## -O 显示设置

没有参数值，只要有了 -O，就不会进行反演，而是把传给二进制程序 `cap` 的各种设置输出到屏幕。

## -P<Yscale[/Xscale[/k]]]> 绘图设置

如果画图没有问题，就不需要设置。Yscale: 第一个 trace 的振幅值（英寸）。Xscale: 每英寸的时间长度。

append k if one wants to keep those waveforms.

## -Qnof

number of freedom per sample ($nof)

## -R<strike1/strike2/dip1/dip2/rake1/rake2> 网格搜索的范围

默认值是 0/360/0/90/-90/90。strike2 建议改为 180，减少计算量。

## -S<s1/s2[/tie]> 最大移动时间

Pnl 和面波的移动最大时间（s1 和 s2），tie=0：SV 和 SH 相互独立移动，tie=0.5：SV 和 SH 的移动时间保持一致

## -T<m1/m2> 时窗长度

Pnl 和面波的时窗长度

## -Udirct

directivity, specify rupture direction on the fault plane (off).

## -V<vp/vl/vr> 视速度

Pnl、Love 和 Rayleigh 的视速度

参见[反演中的时间截取部分](/procedures/inversion/#_5)

## -Wi 反演的物理量

通常 i = 1，默认值是 1。如果是 1，则观测波形的振幅是速度，2 是位移。

## -Xn

output other local minimums whose misfit-min<n*sigma ($mltp).

## -Zstring 权重文件

string 是权重文件的文件名，如果不设置，默认值是 weight.dat。
