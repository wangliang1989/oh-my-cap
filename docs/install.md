# Oh My CAP 的安装

以下安装步骤在 CentOS 上验证通过。在其他 Linux 发行版及 Mac 上安装步骤类似。
因为 gCAP 依赖的 SAC 几乎不可能在 Windows 上安装，所以本安装指南不适用于 Windows。

gCAP 依赖 SAC、GMT、fk 和 pssac。

## 下载

### 方法1

直接下载： https://codeload.github.com/wangliang1989/oh-my-cap/zip/master

### 方法2

使用 git 下载最新版本：

    git clone https://github.com/wangliang1989/oh-my-cap.git

## 安装编译相关工具

### CentOS 用户

    sudo yum install gcc gcc-c++ gcc-gfortran
    sudo yum install compat-gcc-44 compat-gcc-44-c++ compat-gcc-44-gfortran compat-libf2c-34
    sudo yum install make

其他 Linux 发行版安装方法类似。请勿尝试安装 g77，gfortran 已经全面代替 g77 了。

### MacOS 用户

MacOS 用户推荐使用 [Homebrew](http://brew.sh/index_zh-cn.html) 安装。

    brew install gcc make

## SAC

本项目依赖于 SAC **v101.6a**。

SAC 是非开源软件，需要向 IRIS 申请源码包或者二进制包。申请地址是 <http://ds.iris.edu/ds/nodes/dmc/forms/sac/> 。

SAC 的安装参考：

- [SAC 在 Linux 上的安装](https://seisman.github.io/SAC_Docs_zh/introduction/linux-install.html)

- [SAC 在 Mac 上的安装](https://seisman.github.io/SAC_Docs_zh/introduction/mac-install.html)

## GMT

本项目依赖于 GMT 4，不支持 GMT 5。

GMT4 的安装请参考：

- [GMT 4 在 Linux 上的安装](https://seisman.info/install-gmt4-under-linux.html)
- [GMT 4 在 Mac 上的安装](https://seisman.info/install-gmt4-under-mac.html)

GMT 5用户可以可以参考 [GMT4 与 GMT5 双版本共存](https://seisman.info/multiple-versions-of-gmt.html) 一文，以保证系统中存在GMT4和GMT5两个版本且不互相影响。

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
由于版权原因，本项目并不包含这几个子函数的源码。
用户应自行获取缺失源码，并将其放到 `/path/to/oh-my-cap/src/gcap` 下，
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

**不同发行版下配置文件可能不同，请自行解决！**
