+++
title = "快速开始"
menu = "main"
hide_authorbox = true
weight = 4
+++

Oh My CAP 中自带了一个示例事件，你可以按照如下步骤依次执行命令得到该事件的震源机制解，以验证所有程序都正确安装并对整个流程有初步的认识。

```
# 进入 Glib 目录，生成格林函数
$ cd Glib
$ perl run_fk.pl model.fk

# 进入 example 目录
$ cd ../example/

# 对示例数据进行预处理
$ perl process.pl 20080418093658
# 警告 `WARNING potential for aliasing. new delta: 0.200000 data delta: 0.025000` 可忽略

# 生成权重文件
$ perl weight.pl 20080418093658

# 反演并查看反演结果
$ perl inversion.pl 20080418093658
# 路径 20080418093658 下面的 model_*.pdf为各个深度的结果和波形拟合图

# 绘制并查看深度反演结果
$ perl get_depth.pl 20080418093658
$ gs 20080418093658/depth.ps
```
下图展示了震源深度固定为 15 km 时的震源机制反演结果（即 `20080418093658/model_15.pdf`）：
![15 km的反演结果](/images/model_15.png)

下图展示了不同震源深度的反演结果（即 `20080418093658/depth.pdf`）：
![深度反演结果](/images/model_depth.png)
