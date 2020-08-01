---
title: github clone很慢或失败解决方案
date: 2020-08-01 14:48:37
tags: 
- GitHub
categories:
- GitHub
---
最近我在 GitHub clone 项目很慢或者会卡在某个地方以至于 clone 失败，或者clone 失败后会报如下错误：

``` bash
$ ......
$ 接收对象中:  13% (1283/9381), 4.21 MiB | 2.00 KiB/s        
$ error: RPC failed; curl 18 transfer closed with outstanding read data remaining
$ fatal: 远端意外挂断了
$ fatal: 过早的文件结束符（EOF）
$ fatal: index-pack 失败
```

<!-- more -->

### 解决方法一

对 git `http.postBuffer` 属性进行设置
这种方式虽然可以 clone 成功，但是速度还是很慢，速度稳定在10kb/s左右。

``` bash
$ git config --global http.postBuffer 524288000
```

### 解决方法二

使用 SSR 代理,首先打开本地 SSR 客户端 > 高级设置，查看本地 Sockets5 监听端口号，例如我的 Sockets5 监听的端口号为 `1086`

![SSR-setting](https://tva1.sinaimg.cn/large/006tNbRwgy1gadyghg8owj30qe0gqwg3.jpg)

进行如下配置，然后 clone 时使用全局代理模式就可以成功并且速度很快

``` bash
$ git config --global http.https://github.com.proxy socks5://127.0.0.1:1086
$ git config --global https.https://github.com.proxy socks5://127.0.0.1:1086

```

如果不需要上面的配置也可以取消设置

``` bash
$ git config --global --unset http.https://github.com.proxy
$ git config --global --unset https.https://github.com.proxy

```