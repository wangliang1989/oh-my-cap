# 安装

初学者需要阅读本安装文档的每一个字！

因为版权原因，我无法在此提供 SAC 和 NR，SAC 需要向 IRIS 申请，而 NR 需要购买。
gCAP 依赖 SAC、GMT、fk 和 pssac，本项目还要求安装 Taup。另外，绝大多数情况，原始地震数据是 seed 格式，所以往往需要 rdseed。

## 平台问题
gCAP 可以运行在 GNU/Linux 和 MacOS 上。因为 gCAP 依赖的 SAC 几乎不可能在 Windows 上安装，所以请勿尝试 Windows！
98% 的可能性你会在 GNU/Linux 上用 gCAP。
GNU/Linux 有众多的桌面发行版，这些桌面发行版主要可以分为两组，即以红帽为基础的 REHL 系和以 Debian 为基础的 Debian 系。
红帽、CentOS、Fedora 等属于 REHL 系，Debian、Ubuntu、Mint 属于 Debain 系。
如果你是第一次听说 Linux 这些东西，还没装系统，请选择 CentOS。
以下安装步骤在 CentOS 、Mint 和 Mac 上验证通过。在其他 Linux 发行版骤类似。

## 安装编译工具

**请勿尝试安装 g77！**
gfortran 已经全面代替 g77 了。
REHL 系（红帽、CentOS、Fedora 等）用户请参照 CentOS 的安装方式。
Debain 系（Debian、Ubuntu、Mint 等）用户请参照 Mint 的安装方式。

### CentOS

````
$ sudo yum install gcc gcc-c++ gcc-gfortran
$ sudo yum install compat-gcc-44 compat-gcc-44-c++ compat-gcc-44-gfortran compat-libf2c-34
$ sudo yum install make
````

### Mint

````
$ sudo apt-get install gcc gfortran
````

### MacOS

MacOS 用户推荐使用 [Homebrew](http://brew.sh/index_zh-cn.html) 安装。

````
$ brew install gcc make
````

## rdseed

rdseed 用于转换地震数据，是非常常用的软件。如果你不安装 rdseed，你也可以使用本项目，但无法运行成功本项目提供的例子。
安装请参见 [rdseed 的安装](http://blog.seisman.info/rdseed-install/)。
具体的安装方法虽然是在 seisman 的博客上，但我都有参与修订，所以是适合你的，下同。

## SAC

建议使用 SAC 的 **v101.6a** 版。

SAC 是非开源软件，但对学术界用户开放源代码和免费使用。根据授权协议，我不能直接向你提供，你需要自己向 IRIS 证明你的学术身份来申请源码包或者二进制包。
申请地址是 <http://ds.iris.edu/ds/nodes/dmc/forms/sac/> 。你要注意，这个审核是人工审核。

SAC 的安装参考：

- [SAC 在 Linux 上的安装](https://seisman.github.io/SAC_Docs_zh/introduction/linux-install/)

- [SAC 在 Mac 上的安装](https://seisman.github.io/SAC_Docs_zh/introduction/macOS-install/)

已知在 Ubuntu 上如果用二进制包安装，会导致之后的 fk 等编译失败，故强烈建议 Linux 用户用源码编译的方式。

## GMT

gCAP 依赖 GMT4。

Linux 用户：

- [GMT 4 在 Linux 上的安装](http://blog.seisman.info/install-gmt4-under-linux/)
- [GMT4 与 GMT5 双版本共存](http://blog.seisman.info/multiple-versions-of-gmt/)

Mac 用户：

- [macOS 下安装 GMT](http://docs.gmt-china.org/install/macOS/)

## TauP

本项目中使用 TauP 计算理论到时。TauP 的安装请参考 [TauP 的安装](http://blog.seisman.info/taup-install/)。

## 下载 Oh My CAP

1. [zip 格式压缩包](https://github.com/wangliang1989/oh-my-cap/archive/v1.1.1.zip)
2. [tar.gz 格式压缩包](https://github.com/wangliang1989/oh-my-cap/archive/v1.1.1.tar.gz)

## fk

gcap 使用 fk 计算格林函数。

本项目中包含了 fk 源码，进入 `/path/to/oh-my-cap/src/fk` 目录，输入命令进行编译:

````
$ make
````

## pssac

gcap 需要使用 pssac 绘制地震波形。

本项目中包含了 pssac 源码，进入 `/path/to/oh-my-cap/src/pssac` 目录，输入命令进行编译:

````
$ make
````

## gCAP

在成功执行完以上步骤后，才可以着手编译 gCAP。

gCAP 使用了商业软件 Numerical Recipes（简称 NR）中的一些子函数，
包括 `matrix` 、 `free_matrix` 、 `free_convert_matrix` 、 `jacobi` 和 `eigsrt` 。
由于版权原因，我不能把这几个子函数的源码直接放到这里。
用户应自行购买缺失的源码，并将其放到 `/path/to/oh-my-cap/src/gcap` 下，
再在该目录下进行编译:

````
$ make
````

## 添加环境变量

需要为 fk、pssac 和 gcap 添加环境变量。将以下内容加入配置文件 `~/.bashrc` 中:

````
# 注意将 /path/to/oh-my-cap 修改为 oh-my-cap 实际的绝对路径!
# 若自行安装了 fk 或 pssac，请注释掉相关环境变量配置行
export OH_MY_CAP=/path/to/oh-my-cap
export PATH=$OH_MY_CAP/src/fk:${PATH}
export PATH=$OH_MY_CAP/src/pssac:${PATH}
export PATH=$OH_MY_CAP/src/gcap:${PATH}
````

**通常系统的默认 shell 都是 Bash，如果有你自行更换默认 Shell 的情况（如Csh），那么设置的方式可能不同，请自行解决！**

## 安装 Perl 模块

需要安装 Perl 模块 Parallel::ForkManager。
所有操作系统均可以用 cpan安装，Centos 7 可能没有默认安装 cpan，推荐直接用 yum 来安装：

````
$ sudo yum install perl-Parallel-ForkManager # Centos 7 用户
$ cpan # 其他用户使用 cpan
cpan[1]> install Parallel::ForkManager
````
