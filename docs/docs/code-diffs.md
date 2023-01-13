# 代码差异

本项目对 fk、pssac 和 gCAP 的源码只进行了微量的修改。这里的详细修改历史是 GitHub 自动跟踪、自动呈现和自动更新的，所以不存在忘记记录的问题。

## fk

fk 是 Prof. Lupei Zhu 写的一个计算水平分层介质中理论地震图的程序。

官方版本： [fk3.2.tar](http://www.eas.slu.edu/People/LZhu/downloads/fk3.2.tar)

相对于官方版的改动：

- 修改个别错误
- 删除了自带的示例
- 删除了无用的临时文件
- 修改 Makefile 使得其更通用
- 修改输出文件的命名规则以适应并行计算

详细修改历史见： <https://github.com/wangliang1989/oh-my-cap/commits/master/src/fk>

## gcap

Prof. Zhu 的官方版本： [gcap1.0.tar](http://www.eas.slu.edu/People/LZhu/downloads/gcap1.0.tar)

相对于官方版的改动：

- 删除了自带的示例及临时文件
- 修改 `cap_plt.pl` 和 `depth.pl` 使得其不依赖于 GMT 的系统设置
- 修改 `cap.pl` 使得用户不必再自行修改该文件
- 修改 Makefile 使得其更通用
- 改用 GMT6 绘图

详细修改历史见： <https://github.com/wangliang1989/oh-my-cap/commits/master/src/gcap>
