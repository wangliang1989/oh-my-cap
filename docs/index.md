# Oh My CAP

## CAP 简介

CAP 方法，即 Cut and Paste 方法，是一种用多个地震波形片段反演震源机制解的方法。该方法主要由朱露培教授发展和实现。

CAP 程序有三个不同的版本：CAP、gCAP 和 gCAP3D。

- CAP 是朱露培教授早期实现的代码，该版本仅通过私下交流传播，代码并未在网络上开源；
- gCAP 相对于 CAP 的主要改进是 gCAP 可以得到完整的矩张量解，而 CAP 则只能得到双力偶解。gCAP 于2013年在网络上开源。
- gCAP3D 相比 gCAP 的主要改进在于，gCAP3D 可以使用三维模型下的格林函数。gCAP3D于2016年在网络上开源。

## Oh My CAP是什么

CAP 是计算震源机制的一种非常常用的方法，很多地震学同行都需要学习、使用和研究它。
然而实际使用中会遇到如下一些困难：

1.  无法正确安装 CAP ；
2.  因为各种原因，拿到的 CAP 源文件不是朱露培教授发布的官方版本，而是从其他人手中得到的修改版。这导致使用的程序很可能彼此不一样，甚至是经过了较大改动的，而且做了哪些改动又不得而知，进而导致与他人交流过程出现障碍；
3.  不清楚如何从最原始的 SEED 或 SAC 数据开始，如何一步一步处理数据、计算格林函数并做反演

为了帮助 CAP 初学者解决这些问题，我们基于 gCAP1.0 建立了 Oh My CAP 这个开源项目，总结整理了我们在使用 CAP 中的经验，并提供一个学习、探讨 CAP 的平台。

目前，Oh My CAP 项目具有如下功能：

1.  整合了安装 CAP 所需的软件源码
2.  详细的安装指南
3.  完整的数据处理流程以及示例

## 参考文献

1. Zhu, L., and D. V. Helmberger, 1996, Advancements in source estimation techniques using broadband regional seismograms. *BSSA*, 86, 1634-1641. (78)
2. Zhu L, Ben-Zion Y. Parametrization of general seismic potency and moment tensors for source inversion of seismic waveform data[J]. *Geophysical Journal International*, 2013, 194(2): 839-843.
