# 数据预处理

数据预处理的学习，你应该在 `example` 路径下进行。
今后你做自己的数据的预处理，你应该也仿照 `example` 路径下的脚本等进行。
 `example` 路径的文件树如下：

```text
example
├── event.conf
├── config.pm
├── process.pl
├── rdseed.pl
├── eventinfo.pl
├── marktime.pl
├── transfer.pl
├── rotate.pl
├── resample.pl
├── weight.pl
├── inversion.pl
├── gmt6depth.pl
├── depth.pl
├── checkconfig.pl
└── 20080418093658
   ├── event.conf
   ├── event.info
   ├── 20080418093658.seed
   ├── [NET]_[STA].r
   ├── [NET]_[STA].t
   ├── [NET]_[STA].z
   ├── weight.dat
   ├── [MODEL]_[DEPTH].out
   ├── [MODEL]_[DEPTH].pdf
   ├── depth_[MODEL].pdf
   └── [MODEL]_depth.pdf
```

## 文件说明

`example` 内的 Perl 脚本就是数据预处理和后面的反演的脚本。
`20080418093658` 是一个示例事件，里面存储这个事件的相关文件：

1.  `20080418093658.seed`:  SEED 格式的事件波形数据，包含了三分量波形数据以及仪器响应。
2.  `event.info`: 事件信息文件，
其中包含了地震事件的基本信息，依次为发震时刻、震中纬度、震中经度、震源深度和震级。
示例事件的 `event.info` 的内容如下：

```text
2008-04-18T09:36:58 38.4584 -87.8398 15.8 5.4
```

3. `event.conf`: 数据处理和反演所用的配置文件。

另外，`example` 内还有一个 `event.conf` 文件。
脚本运行后，会首先读取和脚本在同一路径的配置文件，然后再读取事件路径下的配置文件。
后者中的内容会覆盖前者，后者没有的设置会保留前者的内容。
这样的设计主要是为了兼顾统一设置处理参数和为每个事件有针对性的设置处理参数。

`event.conf` 中数据预处理的参数只有下面两个：

```text
RESAMPLE: 0.2
FREQ: 0.005 0.01 1.0 1.3
```

RESAMPLE 参数是设置重采样的采样间隔。
做重采样的主要目的是保证观测数据和格林函数的采样周期相同。
次要目的是原始采样率很高，一般是 100 Hz，没有必要。
FREQ 是去仪器响应的四个频率。
RESAMPLE 和 FREQ 的设置要注意符合 Nyquist 律。

## 预处理流程

`process.pl` 实际上是对多个脚本的封装，其依次调用如下脚本对数据进行预处理：

1.  `rdseed.pl`：数据解压与重命名
2.  `eventinfo.pl`：将事件信息写入SAC头段
3.  `marktime.pl`：标记初动震相的理论到时
4.  `transfer.pl`：去仪器响应
5.  `rotate.pl`：旋转三分量至 RTZ 方向
6.  `resample.pl`：数据重采样

### 1. rdseed.pl

`rdseed.pl` 依次做以下三件事：

1.  从事件目录下一个或多个 SEED 文件中提取出 SAC 文件和 RESP 文件
2.  如果某台站的数据因故分割成多段数据，则进行合并
3.  将 SAC 文件按照 `NETWORK.STATION.LOCATION.CHANNEL.SAC` 格式重命名

### 2. eventinfo.pl

`eventinfo.pl` 从 `event.info` 文件中读取事件信息，并将其写入到 SAC 头段中。

### 3. marktime.pl

`marktime.pl` 会根据事件信息和台站位置，
计算 Pnl 波理论到时并写入 SAC 文件头段变量 `T0` 中，并对数据进行 cut。

### 4. transfer.pl

`transfer` 依次做以下三件事：

1. 去毛刺、去均值、去线性趋势和波形尖灭
2. 去仪器响应，将原始波形数据转换为速度记录
3. 将单位从默认的 `nm/s` 修改为 `cm/s`

### 5. rotate.pl

`rotate.pl` 将所有台站的三分量转到大圆路径，即 RTZ 方向。

### 6. resample.pl

`resample.pl` 对数据进行重采样。
`resample.pl` 需要重采样的采样周期作为参数，示例中使用的采样周期为 0.2 s。

**注意：所有观测波形和格林函数文件的采样周期必须相同。这一点是程序设计的要求。**
