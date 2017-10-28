+++
date = 2017-10-28
title = "1.1 版和 1.0 版结果不同的问题"
author = "王亮"
[menu.main]
  parent = "blog"
  weight = 1
+++

1.1 版发布后，有同学给我说，1.1 和 1.0 做例子的结果有微量差异（真的只是非常微量的差异）。不仅如此，1.1 做例子时，还出现了 psmeca 的警告psmeca: Warning:  big isotropic component, case not fully tested!。Oh My CAP 非常在乎可靠性！这篇博客讨论这个问题。
<!--more-->
一切从代码出发，要分析这个问题，以 1.1 版为基础修改代码，让结果和 1.0 一样。经过我的实际测试，只需要做这个网页上展示的修改，即可做出和 1.0 版完全一样的结果：

https://github.com/wangliang1989/oh-my-cap/commit/1b63e43d61c90d3efd2e1eba1926752478ba966e

修改是两部分，一部分是对去仪器响应的频率的改变，一部分是新版本对波形数据新增了 cut 的操作。大家可以自行判断，这两处修改都没有任何错误，也没有很大的差异，但是会对互相关等等的结果造成一些差异，这些都是很正常的。

至于 psmeca 的报警，让我告诉你这是 psmeca 有问题。新版本得到的矩张量解中 DC 的组成比例超过 99%。
