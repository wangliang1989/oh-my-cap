# 安装

初学者需要阅读本安装文档的每一个字才可能顺利完成安装！
虽然只有一个页面，但是初学者可能需要一个月才能顺利完成，所以请勿心急。

## 确定自己的操作系统

不同操作系统安装 Oh My CAP 的细节是不同的。
你需要确定自己使用的是什么操作系统。
即准确回答问题：自己用的什么操作系统？
如果是 GNU/Linux 系统，是 REHL 系还是 Debian 系？

gCAP 依赖的 SAC 几乎不可能在 Windows 上安装，
所以本软件包只能在 GNU/Linux 或 MacOS 系统上正常运行，
而不能运行在 Windows 上。

GNU/Linux 是指以 Linux 为内核，配备一系列 GNU 应用软件的操作系统。
GNU/Linux 有众多的桌面发行版。
这些桌面发行版主要可以分为两组，即以红帽为基础的 REHL 系和以 Debian 为基础的 Debian 系。
红帽、CentOS、Fedora 等属于 REHL 系，Debian、Ubuntu、Mint 等属于 Debain 系。

MacOS 是苹果公司为其电脑预装的操作系统。
如果你使用的是苹果电脑，你应该就是使用的这款操作系统。

## 安装编译工具

**请勿尝试安装 g77！**
gfortran 已经全面代替 g77 了。
REHL 系（红帽、CentOS、Fedora 等）用户请参照下面的 CentOS 的安装方式。
Debain 系（Debian、Ubuntu、Mint 等）用户请参照下面的 Mint 的安装方式。

### CentOS

```shell
$ sudo yum install gcc gcc-c++ gcc-gfortran
$ sudo yum install compat-gcc-44 compat-gcc-44-c++
$ sudo yum install compat-gcc-44-gfortran compat-libf2c-34
$ sudo yum install make
```

### Mint

```shell
$ sudo apt-get install gcc gfortran
```

### MacOS

MacOS 需要使用 Homebrew 安装依赖。

如果你可以在命令行中访问海外网站，请直接使用官方的安装命令：

```shell
$ /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

或者前往 Homebrew 的官网查看安装方法：https://brew.sh/index_zh-cn.html

如果你不能在命令行中访问海外网站，请使用中科大的镜像。
在中科大的镜像使用文档中有全面的安装说明：
https://mirrors.ustc.edu.cn/help/brew.git.html
。
为了让读者直接抓住终点，我把使用中科大的镜像安装Homebrew的方法提炼如下：

首先将以下内容加入环境变量：

```bash
export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.ustc.edu.cn/brew.git"
export HOMEBREW_CORE_GIT_REMOTE="https://mirrors.ustc.edu.cn/homebrew-core.git"
export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.ustc.edu.cn/homebrew-bottles"
```

然后，执行命令：

```shell
$ /bin/bash -c "$(curl -fsSL https://cdn.jsdelivr.net/gh/Homebrew/install@HEAD/install.sh)"
```

安装 gcc、gfortran 和 make：
````shell
$ brew install gcc gfortran make
````

## rdseed

rdseed 用于将 seed 格式的数据转化为 sac 格式。
seed 是一种数据压缩格式。
seed 数据格式目前已经逐渐被 miniseed 格式代替了。
但是 seed 格式在国内依然非常流行。
Oh My CAP 继续使用 seed 格式的数据作为例子。
如果不安装 rdseed，读者也可以使用本项目，但无法运行成功本项目提供的例子。

安装请参见 [rdseed 的安装](http://blog.seisman.info/rdseed-install/)。
具体的安装方法虽然是在 seisman 的博客上，但我都有参与修订，所以是适合你的，下同。

## SAC

建议使用 SAC 的 v102.0 版（较老的 v101.6a 也可）。

根据授权协议，学术界用户可以免费使用 SAC，也可以获得源代码，但不被允许修改源代码和再次分发。
因此，我不能在此处向你提供 SAC。
你需要向 IRIS 证明自己的学术身份来申请源码包或者二进制包。
这里说的学术身份的本质是你拥有一个 edu 邮箱。
申请地址是 <http://ds.iris.edu/ds/nodes/dmc/forms/sac/> 。
你要注意，这个审核是人工审核。

SAC 的安装参考：

- [SAC 在 Linux 上的安装](https://seisman.github.io/SAC_Docs_zh/introduction/linux-install/)

- [SAC 在 Mac 上的安装](https://seisman.github.io/SAC_Docs_zh/introduction/macOS-install/)

已知在 Ubuntu 上如果用二进制包安装，会导致之后的 fk 编译失败，故强烈建议 Linux 用户用源码编译的方式。

## GMT

现在，Oh My CAP 作图只需要安装 gmt6，请在
[gmt 中文社区](https://docs.gmt-china.org/latest/install/)
的文档中查找适合你的操作系统的安装方案。

## TauP

gCAP 使用 TauP 计算理论到时。
TauP 的安装请参考 seisman 的 [TauP 的安装](http://blog.seisman.info/taup-install/)。

## 下载 Oh My CAP

下载本项目的软件包可以使用如下两个格式的压缩包（内容相同）。

- [zip 压缩包](https://github.com/wangliang1989/oh-my-cap/archive/v2.0.0.zip)

- [tar.gz 压缩包](https://github.com/wangliang1989/oh-my-cap/archive/v2.0.0.tar.gz)

在改进了一定程度后，Oh My CAP 会释放一个带版本号的 release，以标记软件的发展。
上面的链接给出的就是 v2.0.0 这个 release 的两种格式的压缩包。
如果你对 git 有基本的了解，你可以阅读这段文字：
自 v2.0.0 以后，Oh My CAP 不再长期设置 dev 分支。平时的修改会直接合并到 master 分支。
在有较多修改后，发布一个新的 release。
软件修改后，我对文档既会应改尽改，又会非必要不修改。
软件和文档的修改分一个或多个 commit，一起合并到 master 分支。
这是为了确保 master 分支的软件和文档始终是匹配的。
如果非常在意结果的复现，你应该使用特定的版本，否则可以直接使用 master 分支。

我希望今后能每年发布一个新的版本。
如果是文档有改动，就前进 0.0.1 个版本号。
如果是软件有改动，就前进 0.1 个版本号。
如果是改变依赖的软件，就前进 1.0.0 个版本号。

## fk

gCAP 使用 fk 计算格林函数。

本项目中包含了 fk 源码，进入 `/path/to/oh-my-cap/src/fk` 目录，输入命令进行编译:

```shell
$ cd /path/to/oh-my-cap/src/fk
$ make
```

## gCAP

在成功执行完以上步骤后，才可以着手编译 gCAP。

在 `/path/to/oh-my-cap/src/gcap` 目录下进行编译:

```shell
$ cd /path/to/oh-my-cap/src/gcap
$ make
```

## 添加环境变量

需要为 fk 和 gcap 添加环境变量。
注意，初学者常在这步出错。

GNU/Linux系统的默认 shell 通常是 Bash，需要将以下内容加入配置文件 `~/.bashrc` 中。
MacOS 的默认 shell 是 zsh，需要将以下内容加入配置文件 `~/.zshrc` 中。
如果你使用的 shell 不是 Bash，也不是和 Bash 兼容的（如 Zsh），
那么你需要按照对应的语法自行修改。

```bash
# 注意将 /path/to/oh-my-cap 修改为 oh-my-cap 实际的绝对路径!
# 若自行安装了 fk，请注释掉相关环境变量配置行
export OH_MY_CAP=/path/to/oh-my-cap
export PATH=$OH_MY_CAP/src/fk:${PATH}
export PATH=$OH_MY_CAP/src/gcap:${PATH}
```

## 安装 Perl 模块

这一步不是必须的。

安装 Perl 模块 Parallel::ForkManager 可以并行计算格林函数。
Linux 和 Mac 均用 cpan 安装，Centos 7 可能没有默认安装 cpan，推荐直接用 yum 来安装：

```shell
$ sudo yum install perl-Parallel-ForkManager # Centos 7 用户
$ cpan # 其他用户使用 cpan
cpan[1]> install Parallel::ForkManager
```
