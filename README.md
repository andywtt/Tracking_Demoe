---
title: MKMapView坐标点的平滑移动-Tracking_Demoe
date: 2017-06-24
tags: OC、MapKit
---
> ###### 前言
> 	网上找了很多资料，也借鉴了许多朋友的代码，才勉强达到基本的效果，还可以再优化。在此非常感谢那些愿意分享的人。感谢这两个demo（[SmoothMovingAnnotation](https://github.com/ZeroJian/SmoothMovingAnnotation)、[iOS_MovingAnnotation_Demo](https://github.com/cysgit/iOS_MovingAnnotation_Demo)）的作者，基本就结合这两个demo才得以实现。所以记录学习下。
> 
#### 目标
使用iOS系统的<mark>MapKit</mark>实现轨迹数据展示，并可以播放轨迹暂停轨迹。

#### 思路
	* 获取轨迹的所有坐标点
	* 标注起点、终点、移动点
	* 自定义移动点，并保存轨迹的所有坐标点
	* 在自定义移动点内写个执行动画，让移动点动起来。

#### 缺点
	* 不流畅
	* 关联的代码量多（Demo是直接从项目中拷贝出来的）

#### 实现的代码部分

[😁😁😁😁请下载demo看](https://github.com/andywtt/Tracking_Demoe)


#### 如果还有更好的方法，请不吝赐教！如有错误请斧正

#### 实现的结果

<iframe height=1130 width=620 src="http://oeto56f8q.bkt.clouddn.com/tracking_demo.gif" frameborder=0 scrolling="no">
