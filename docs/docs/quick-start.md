# 快速开始

Oh My CAP 中自带了一个示例事件，你可以按照如下步骤依次执行命令得到该事件的震源机制解，
以验证所有程序都正确安装并对整个流程有初步的认识。
Linux 和 Mac 得到的结果有非常微小的差异，原因在于 fk 生成的格林函数有差别。
这一点你可以忽略。
流程大约是三步：计算格林函数、数据预处理和反演。之后还有查询结果。

## 计算格林函数

```shell
# 进入 Glib 目录，生成格林函数
$ cd Glib
$ perl run_fk.pl model.fk
```

## 数据预处理

```shell
# 进入 example 目录
$ cd ../example/
# 对示例数据进行预处理
$ perl process.pl 20080418093658
```
警告 `WARNING potential for aliasing. new delta: 0.200000 data delta: 0.025000`
是 SAC 输出的，意思是降采样的过程可能导致波形失真。
Oh My CAP 的脚本是考虑了这个问题的，所以这个警告应忽略。

## 反演

```shell
# 生成权重文件
$ perl weight.pl 20080418093658
# 反演并查看反演结果
$ perl inversion.pl 20080418093658
# 路径 20080418093658 下面的 model_*.pdf 为各个深度的结果和波形拟合图
```

下图是震源深度固定为 15 km 时的震源机制反演结果（即 `20080418093658/model_15.pdf`）：

![15 km的反演结果](/img/model_15.png)

## 绘制并查看深度反演结果

zhu 在 gCAP 中提供了一个脚本，
可以估计震源深度，
且利用 gmt4 绘制震源深度与相对误差的关系图。
我提供的 `gmt6depth.pl` 会复现 zhu 的这个脚本的结果，并且用 gmt6 完成绘图：

```shell
$ perl gmt6depth.pl 20080418093658
Event 20080418093658 Model model_15 FM 295 90   2 Mw 5.20 rms 1.880e-02   121 ERR   1   7   4 ISO 0.00 0.00 CLVD 0.00 0.00
 H  14.8   0.7
```

程序运行后，生成的图片文件是 `20080418093658/model_depth.pdf`，如下图：

![震源深度与相对误差的关系](/img/model_depth.png)

`depth.pl` 这个脚本会输出震源深度和绝对误差的关系图。
这个图也是你在很多 CAP 的论文中看到的图：

```shell
$ perl depth.pl 20080418093658
```

图片的文件是 `20080418093658/depth_model.pdf`，如下图：

![震源深度与绝对误差的关系](/img/depth_model.png)
