# 版本发布

现在，Oh My CAP 在以前的语意话版本的版本号规则的基础上，改为如下原则：

- 主版本号：不兼容的 API 修改，
- 次版本号：软件更新，
- 修订号：文档更新。

## 2.0.0

这一次更新间隔了近五年，修改较多。
这次更新通过如下 PR 合并到 master 分支：

- [更新到 2.0.0](https://github.com/wangliang1989/oh-my-cap/pull/60/files)

其中主要的更新有：

- [波形拟合图改为 gmt6](https://github.com/wangliang1989/oh-my-cap/pull/60/commits/dbf6a477ef3e6ef192337d9d426acd545661bab6)

- [深度反演图改为 gmt6](https://github.com/wangliang1989/oh-my-cap/pull/60/commits/b0a9443fef762618b0fa8feafff72a4a3801d7e9)

- [绘制RMS随深度变化图](https://github.com/wangliang1989/oh-my-cap/pull/60/commits/d850d8a86af3129e53ae7cb809d573b0661c259c)

- [添加外部子函数](https://github.com/wangliang1989/oh-my-cap/pull/60/commits/523d4cd6b9bf36ec9ba57cc600bc3659c41acd95)

- [全面更新文档](https://github.com/wangliang1989/oh-my-cap/pull/60/commits/c5c260033a3dffae0d93391069e56154801f9a82)

## 1.2

- [忽略自定义文件](https://github.com/wangliang1989/oh-my-cap/commit/4aa1b6eae62ad822ad4eb61b76bcc70fecbceada)

考虑到可能需要在工作区内放置一些文件，比如自己写的脚本，而又不想加入 repo 中，可以用 i_ 开头，则会忽略

- [添加检查震源深度和界面深度是否一样的功能](https://github.com/wangliang1989/oh-my-cap/commit/89045125ff0c0544bced74fd4b692c6175708c94)

震源深度不能等于界面深度。添加检查这一点的功能

- [彻底解决 grep 排序不当造成 gmt 绘图脚本确定图幅范围出错的bug](https://github.com/wangliang1989/oh-my-cap/commit/5a02b4e1be70932110f73f893a424407dea9c17b)

Prof. Zhu 的画深度-拟合残差图的 gmt4 脚本不能正确确定图幅范围。
原因在于它要求它所依赖的 junk.out 文件中的各个深度的记录必须是升序，而生成 junk.out 文件的 grep 是按 ASCII 顺序排序而不是数值大小。
之前的做法是小于 10 的深度前面加一个 0，但是这样不符合人类习惯，特别是在深度为小于 1 的小数时让人觉得非常奇怪。
现在改用 Perl 脚本来完成排序的事情，再依次交给 grep，既不会出现错误，又符合人类习惯，彻底解决此 bug。

- [修改获取计算机逻辑核数目的方式](https://github.com/wangliang1989/oh-my-cap/commit/e37902987a327a0defb58ea391e23e468e151bf4)

之前的方式依赖系统特性，只适用于 Linux，为了同时适应 Mac，增加功能：判断系统类别，再针对不同系统得到计算机逻辑核数目

- [给 example/marktime.pl 添加注释](https://github.com/wangliang1989/oh-my-cap/commit/3c584c17a5fa0033ad51aebec3b0fa6c54dd912e)

## 1.1.1

- [修正旋转分量后文件重命名的方式的错误](https://github.com/wangliang1989/oh-my-cap/commit/a03cb773db142e1888f9c040ae2afc5cdde2f85f)

- [perl 5.2.6 以上版本无法找到 config 模块](https://github.com/wangliang1989/oh-my-cap/commit/230aefc8b4e3beb1100ff87a1aa197c5c367a1e0)

## 1.1

- 用配置文件来设置参数
- 并行计算格林函数

## 1.0

- 整合了安装 CAP 所需的软件源码
- 详细的安装指南
- 完整的数据处理流程以及示例
