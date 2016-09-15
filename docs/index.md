# Oh My CAP

# CAP程序简介

CAP 是用地震波形记录反演震源机制解的著名程序，主要由朱露培教授发展和实现。
CAP 有不同的版本：CAP、gCAP 和 gCAP 3D。CAP 大约是在本世纪初研发的，朱露培教授并未在网络上正式开源 CAP 程序。
相较 CAP，gCAP 的主要改进是 gCAP 可以得到矩张量解，前者则是双力偶模型。gCAP 已经正式在网络上开源。
gCAP 3D 相比 gCAP 的区别是可用三维模型计算的格林函数。gCAP 3D已经正式在网络上开源。

# Oh My CAP是什么？

CAP是计算震源机制的一种非常好的方法。很多地震学同行都需要学习、使用和研究它。
然而以下情况阻碍了大家：

1. CAP 的安装真的并不容易。
2. 因为各种原因，大家拿到 CAP 源文件往往不是通过朱露培教授的官网，而是熟人关系。这导致使用的程序很可能彼此不一样，甚至是经过了较大改动的，而且做了哪些改动又不得而知。
3. 从最初的 sac 文件或者 seed 文件开始，怎样正确处理数据到计算格林函数再到最后的反演，需要摸索，而学习者可能连 sac 都是初学。

要迈过了上面的坑，需要学习者自己摸索，或者请人帮助。为了解决这些问题，我们建立了 Oh My CAP 这个开源项目，以提供一个学习和探讨 CAP 的平台。
目前，我们打算在这里向大家提供：

1. 一个更好安装的 CAP 和安装指南(目前，我们使用gCAP，未来希望能加入 gCAP 3D)
2. 如何正确处理数据到最后的如何反演的例子和配套的说明教程
## 参考文献

1. Zhu, L., and D. V. Helmberger, 1996, Advancements in source estimation techniques using broadband regional seismograms. *BSSA*, 86, 1634-1641. (78)
2. Zhu L, Ben-Zion Y. Parametrization of general seismic potency and moment tensors for source inversion of seismic waveform data[J]. *Geophysical Journal International*, 2013, 194(2): 839-843.
