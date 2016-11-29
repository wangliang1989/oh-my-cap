+++
title = "新手入门"
menu = "main"
hide_authorbox = true
enable_toc = true
weight = 2
+++

本文简要介绍本项目。

## CAP 简介

CAP 方法，即 **C**ut **A**nd **P**aste 方法，是一种将连续地震波形切割成多个波形片段来反演震源机制解的方法。该方法主要由 [朱露培教授](http://www.eas.slu.edu/People/LZhu/home.html) 发展和实现。如果你需要反演的地震在矩震级 3 级以上，7 级以下（大致范围，并不绝对），在 500 公里内至少有 3 个宽频带波形数据（有仪器响应文件），原则上来说，CAP 方法可以满足你。

朱老师发布的 CAP 程序有三个不同的版本：CAP、gCAP 和 gCAP3D。

- CAP 是朱露培教授早期实现的代码，可用于反演双力偶解。该版本仅通过私下交流传播，代码并未在网络上开源；
- gCAP 在 CAP 的基础上增加了反演完整矩张量解的功能。gCAP 于 2013 年在网络上开源。
- gCAP3D 在 gCAP 的基础上增加了使用三维模型下的格林函数进行反演的功能。gCAP3D 于 2016 年在网络上开源。

另外，很多学者发布了自己的 CAP 版本，各有特色。

## 为什么选择 Oh My CAP

Oh My CAP 项目基于 gCAP 建立，对 gCAP 的核心代码只做了微量修改。简单地说，如果你选择 Oh My CAP，你用的就是 gCAP。而在易用性上，本项目远超官方原版本。下面不完全罗列本项目的优势：

1. 理清了程序的依赖关系，最大限度地提供自动安装脚本和安装程序源文件和手把手的安装指南；
2. 手把手的示例演示，和每一个步骤的讲解；
3. 调用 gCAP 的现成 Perl 脚本；
4. 可以清楚查看对原 gCAP 代码做了哪些具体修改（这些修改的记录并非靠人力记录，而是依托 Github 的版本对照功能自动实现），

## 学习指南

首先，你需要安装上程序，所以你应该首先按照网页上『安装』页面的内容进行安装。然后，你需要检查你的安装是否成功，这时，你应该照着『快速开始』里的例子，看能不能自己把例子做出来。然后，你应该仔细学习『流程』的内容，详细掌握每一个步骤。
『代码差异』页面展示的是本项目相对于官方原版程序，做了哪些修改。

## 版权协议和引用问题

本项目中所使用的 fk、pssac 以及 gcap 的源码修改自朱老师的原始代码。这部分代码遵循 GPL 协议，即任何人均可免费获取、使用、修改和再发布代码，但是修改后的版本也必须公开并按 GPL 协议授权。本项目中的其余源码以及网页内容采用更加宽松的 Apache 协议，即在尊重本项目署名权的前提下，可以选择不公开自己的修改。

如果你发表了正式文章，需要有以下引用

1. Zhu, L., and D. V. Helmberger, 1996, Advancements in source estimation techniques using broadband regional seismograms. *BSSA*, 86, 1634-1641. (78)
2. Zhu L, Ben-Zion Y. Parametrization of general seismic potency and moment tensors for source inversion of seismic waveform data[J]. *Geophysical Journal International*, 2013, 194(2): 839-843.

第 1 篇文章是 CAP 方法成型文章（并不是 CAP 的第一篇，但是是方法成型的第一篇），第二篇文章是 CAP 方法从只反演双力偶解发展为完整矩张量解的文章。

## 联系方式

__[王亮](http://wangliang.one)__  成都理工大学

Email： [wangliang.one@foxmail.com]()

CAP 讨论 QQ 群：580712662

欢迎任何人加入到该项目的更新与维护中！
