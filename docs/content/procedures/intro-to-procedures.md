+++
title = "流程介绍"
categories = [
    "pages",
]
enable_toc = true
weight = 1
[menu.main]
parent = "procedures"
+++

gCAP 反演震源机制需要三个步骤：

1. [计算格林函数](http://oh-my-cap.wangliang.one/procedures/gflib/)
2. [数据预处理](http://oh-my-cap.wangliang.one/procedures/preprocess/)
3. [震源机制反演](http://oh-my-cap.wangliang.one/procedures/inversion/)

<!--more-->
## 计算格林函数

格林函数表示 t_0 时刻作用在 r_0 处的单位力矢量在 t 时刻 r 处产生的位移矢量。

地震的波形记录是震源项、格林函数以及仪器响应三者卷积得到的，将记录到的地震波形数据去除仪器响应之后，则可将假定的震源项（震源机制以及震源时间函数）与计算出来的格林函数进行卷积，并将卷积得到的结果与去仪器响应之后的观测波形进行对比。因而正确计算格林函数是关键的一步。

## 数据预处理

数据预处理是对观测到的地震波形数据进行一些处理以符合 gCAP 对数据的要求。

gCAP 要求地震波形数据必须满足如下要求：

1. 必须是SAC格式
2. 三分量波形数据文件名格式为 `station.[rtz]` 且必须放在一个事件目录内
3. 必须去除仪器响应得到位移或速度记录，单位为 cm 或 cm/s
4. SAC头段中 `o`、`az`、`dist` 必须定义

## 反演

gCAP 会截取波形中的Pnl波和面波的波形，并通过遍历所有可能的震源参数以得到与实际波形最像的理论地震图。
