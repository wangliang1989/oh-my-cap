# 代码差异

本项目包含了 fk、pssac 和 gCAP 的源码，并对其进行了微量的修改。

## fk

fk 是 Prof. Lupei Zhu 写的一个计算水平分层介质中理论地震图的程序。

官方版本： [fk3.2.tar](http://www.eas.slu.edu/People/LZhu/downloads/fk3.2.tar)

相对于官方版的改动：

- 删除了自带的示例
- 删除了无用的临时文件
- 修改 Makefile 使得其更通用

详细修改历史见： <https://github.com/wangliang1989/oh-my-cap/commits/master/src/fk>

## pssac

pssac 是 Prof. Lupei Zhu 根据 GMT 的 psxy 命令修改得到，用于绘制 SAC 格式的波形数据的程序。

官方版本： [pssac.tar](http://www.eas.slu.edu/People/LZhu/downloads/pssac.tar) [pssac.c](http://www.eas.slu.edu/People/LZhu/downloads/pssac.c)

相对于官方版的改动：

- 修改 Makefile 使得其更通用

详细修改历史见： <https://github.com/wangliang1989/oh-my-cap/commits/master/src/pssac>

## gcap

Prof. Zhu 的官方版本： [gcap1.0.tar](http://www.eas.slu.edu/People/LZhu/downloads/gcap1.0.tar)

相对于官方版的改动：

- 删除了自带的示例及临时文件
- 修改 `cap_plt.pl` 和 `depth.pl` 使得其不依赖于 GMT 的系统设置
- 修改 `cap.pl` 使得用户不必再自行修改该文件
- 修改 Makefile 使得其更通用

详细修改历史见： <https://github.com/wangliang1989/oh-my-cap/commits/master/src/gcap>
