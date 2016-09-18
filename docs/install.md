# Oh My CAP 的安装

以下安装步骤在 CentOS 上验证通过。在其他 Linux 发行版及 Mac 上安装步骤类似。
因为 gCAP 依赖的 SAC 几乎不可能在 Windows 上安装，所以本安装指南不适用于 Windows。

gCAP 依赖 SAC、GMT、fk 和 pssac。其次，要完成一系列的编译需要 gcc 和其他辅助的编译工具。
下面的操作请依序完成：

## gcc 和其他辅助的编译工具

### CentOS:

    sudo yum install gcc # C 编译器
    sudo yum install gcc-c++ # C++ 编译器
    sudo yum install gcc-gfortran # Fortran 编译器
    sudo yum install compat-gcc-44 # 兼容 gcc 4.4
    sudo yum install compat-gcc-44-c++ # 兼容 gcc-c++ 4.4
    sudo yum install compat-gcc-44-gfortran # 兼容 gcc-fortran 4.4
    sudo yum install compat-libf2c-34 # g77 3.4.x 兼容库
    sudo yum install make

其他发行版请类似安装。请勿尝试安装 g77。gfortran 已经全面代替 g77 了。

## SAC

获取 SAC 的源码包或者二进制包，需要向 [IRIS](https://www.iris.edu/hq/) 申请。在申请前建议了解[一些申请的注意事项](https://seisman.github.io/SAC_Docs_zh/introduction/request.html)。

申请地址是 <http://ds.iris.edu/ds/nodes/dmc/forms/sac/> 。

本项目要求使用SAC版本号为v101.6a。

在获得源码包或者二进制包后，按照 SAC 参考手册的相关内容进行安装：

[SAC 在 Linux 上的安装](https://seisman.github.io/SAC_Docs_zh/introduction/linux-install.html)

[SAC 在 Mac 上的安装](https://seisman.github.io/SAC_Docs_zh/introduction/mac-install.html)

## GMT

GMT 应该安装 GMT4。GMT4 和 GMT5 是可以共存在电脑上的，所以安装 GMT4 不影响 GMT5 的使用：

[GMT 4 在 Linux 上的安装](https://seisman.info/install-gmt4-under-linux.html)

[GMT 4 在 Mac 上的安装](https://seisman.info/install-gmt4-under-mac.html)

[GMT4 与 GMT5 双版本共存](https://seisman.info/multiple-versions-of-gmt.html)

## fk

fk 的安装文件，我们已经打包好了，你不需要再去其他地方下载，进入 `/path/to/oh-my-cap/src/fk` 目录，输入命令进行编译:

    $ make

## pssac

pssac 的安装文件，我们已经打包好了，你不需要再去其他地方下载，进入 `/path/to/oh-my-cap/src/pssac` 目录，输入命令进行编译:

    $ make

## gCAP

在完成上面的项目后，才可以着手编译 gCAP 。

gCAP 使用了商业软件 Numerical Recipes（简称 NR）中的一些子函数，
包括 `matrix` 、 `free_matrix` 、 `free_convert_matrix` 、 `jacobi` 和 `eigsrt` 。
由于版权原因，这几个子函数的源码并没有包含在本项目中。
用户应自行获取这几个子函数的源文件，并将其放到 `/path/to/oh-my-cap/src/gcap` 下，
再在该目录下进行编译:

    $ make

## 添加环境变量

需要为 fk、pssac 和 gcap 添加环境变量。将以下内容加入环境变量中:

    # 注意将 /path/to/oh-my-cap 修改为 oh-my-cap 实际的绝对路径!
    export OH_MY_CAP=/path/to/oh-my-cap
    export PATH=${PATH}:$OH_MY_CAP/src/fk
    export PATH=${PATH}:$OH_MY_CAP/src/pssac
    export PATH=${PATH}:$OH_MY_CAP/src/gcap
