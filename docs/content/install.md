+++
title = "安装"
menu = "main"
hide_authorbox = true
enable_toc = true
weight = 3
+++

对于初学者。本安装文档的每一个字都需要阅读！因为版权原因，我无法提供全部安装包，有困难请加群 580712662。

以下安装步骤在 CentOS 上验证通过。在其他 Linux 发行版及 Mac 上安装步骤类似。
因为 gCAP 依赖的 SAC 几乎不可能在 Windows 上安装，所以本安装指南不适用于 Windows。

gCAP 依赖 SAC、GMT、fk 和 pssac。

## 安装编译工具

### CentOS 用户

    sudo yum install gcc gcc-c++ gcc-gfortran
    sudo yum install compat-gcc-44 compat-gcc-44-c++ compat-gcc-44-gfortran compat-libf2c-34
    sudo yum install make

其他 Linux 发行版安装方法类似。请勿尝试安装 g77，gfortran 已经全面代替 g77 了。

### MacOS 用户

MacOS 用户推荐使用 [Homebrew](http://brew.sh/index_zh-cn.html) 安装。

    brew install gcc make

## SAC

Oh My CAP 依赖 SAC **v101.6a**。

SAC 是免费而非开源软件。根据授权协议，我不能直接向你提供，你需要自己向 IRIS 申请源码包或者二进制包。申请地址是 <http://ds.iris.edu/ds/nodes/dmc/forms/sac/> 。你要注意，这个审核是人工审核，别和 IRIS 耍花招。

SAC 的安装参考：

- [SAC 在 Linux 上的安装](https://seisman.github.io/SAC_Docs_zh/introduction/linux-install.html)

- [SAC 在 Mac 上的安装](https://seisman.github.io/SAC_Docs_zh/introduction/mac-install.html)

## GMT

gCAP 依赖 GMT4。

GMT4 的安装请参考：

- [GMT 4 在 Linux 上的安装](http://seisman.info/install-gmt4-under-linux.html)
- [GMT 4 在 Mac 上的安装](http://seisman.info/install-gmt4-under-mac.html)

GMT5 用户可以参考 [GMT4 与 GMT5 双版本共存](http://seisman.info/multiple-versions-of-gmt.html) 一文，以保证系统中存在 GMT4 和 GMT5 两个版本且互不影响。

## TauP

本项目中使用 TauP 计算理论到时。TauP 的安装请参考 [TauP 的安装](http://seisman.info/install-taup.html)。

## 下载 Oh My CAP

1. [zip 格式压缩包](https://github.com/wangliang1989/oh-my-cap/archive/v1.1.zip)
2. [tar.gz 格式压缩包](https://github.com/wangliang1989/oh-my-cap/archive/v1.1.tar.gz)

## fk

gcap 需要使用 fk 计算格林函数。

本项目中包含了 fk 源码，进入 `/path/to/oh-my-cap/src/fk` 目录，输入命令进行编译:

    $ make

**若系统中已自行安装 fk，可忽略这一步。**

## pssac

gcap 需要使用 pssac 绘制地震波形。

本项目中包含了 pssac 源码，进入 `/path/to/oh-my-cap/src/pssac` 目录，输入命令进行编译:

    $ make

**若系统中已自行安装 pssac，可忽略这一步。**

## gCAP

在成功执行完以上步骤后，才可以着手编译 gCAP。

gCAP 使用了商业软件 Numerical Recipes（简称 NR）中的一些子函数，
包括 `matrix` 、 `free_matrix` 、 `free_convert_matrix` 、 `jacobi` 和 `eigsrt` 。
由于版权原因，我不能把这几个子函数的源码直接放到这里。
用户应自行购买缺失的源码，并将其放到 `/path/to/oh-my-cap/src/gcap` 下，
再在该目录下进行编译:

    $ make

## 添加环境变量

需要为 fk、pssac 和 gcap 添加环境变量。将以下内容加入配置文件 `~/.bashrc` 中:

    # 注意将 /path/to/oh-my-cap 修改为 oh-my-cap 实际的绝对路径!
    # 若自行安装了 fk 或 pssac，请注释掉相关环境变量配置行
    export OH_MY_CAP=/path/to/oh-my-cap
    export PATH=$OH_MY_CAP/src/fk:${PATH}
    export PATH=$OH_MY_CAP/src/pssac:${PATH}
    export PATH=$OH_MY_CAP/src/gcap:${PATH}

**通常系统的默认 shell 都是 Bash，如果有你自行更换默认 Shell 的情况（如Csh），那么设置的方式可能不同，请自行解决！**

## 安装 Perl 的并行模块

计算格林函数比较耗时，Oh My CAP 已经实现用并行计算格林函数：

    cpanm Parallel::ForkManager

cpanm 是需要事先安装的，安装方法见[Perl 多版本共存之 plenv](http://seisman.info/perl-plenv.html)
