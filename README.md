# metronomelutter

操起吉他熟练地 53231323，然后发现市面上竟然没有一个干净无广告的节拍器？那只能自己写一个了。

基于 Flutter 技术打造的极简全平台（含 Web）节拍器。

## 预览
![preview](./screenshot/preview.png)

## 环境要求
- Flutter 3.x
- Dart 3.x
- Android/iOS/Web 运行环境

## 功能概览
- BPM 圆形滑块调节
- 节拍指示与拍号设置
- 多套主题可选
- 低延迟音频播放
- 录音与回放（含波形展示）
- 本地谱子管理（支持多图上传、预览与首页覆盖）

## 学习笛子页面（规划）
建议新增独立页面（如 `lib/pages/flute_learning_page.dart`），内容分为「基础、练习、复盘」三块：

### 1. 基础区（看得懂）
- 笛子结构与孔位说明
- 口型、呼吸、持笛姿势要点（图文/短视频）
- 常见问题与纠正（漏气、音飘、换指卡顿）

### 2. 练习区（练得动）
- 常用音阶与指法表（按调切换）
- 节拍器联动练习（60/80/100 BPM 等分档）
- 跟练模式：选择谱子后逐页练习（支持缩放、翻页）

### 3. 复盘区（有进步）
- 录音对比（示范 vs 自录）
- 练习日志（日期、BPM、时长、自评分）
- 周进度统计（连续打卡、总时长）

### 第一版建议范围（MVP）
- 指法表 + 音频示例
- 节拍器联动练习
- 谱子练习入口（复用现有多图谱子与录音能力）

## 使用说明
- BPM 调节：滑动圆形滑块或点击后输入数值
- 音效选择：进入「设置 → 音效」切换
- 主题切换：进入「设置 → 主题」选择预设主题
- 拍号设置：点击首页右下拍号按钮设置

## 目录结构
- `lib/pages` 页面
- `lib/component` 组件
- `lib/store` 状态管理（MobX）
- `lib/utils` 工具方法
- `lib/config` 配置与主题

## TODO
- 高 BPM 声音准确性进一步优化
- iOS App Clip
- 学习笛子页面（基础教学 + 练习 + 复盘）

## 运行

flutter pub get

flutter run

flutter build apk && start build\app\outputs\apk\release

## 发布/打包
- Android APK：
  - `flutter build apk`
- Web：
  - `flutter build web`
- iOS：
  - `flutter build ios`

## 修改 mobx 文件时自动生成 .g 文件
flutter packages pub run build_runner watch --delete-conflicting-outputs

## 常见问题

### AnimationController : The named parameter 'vsync' isn't defined

参考：`https://github.com/flutter/flutter/issues/63486`

The "required" 漏了 @ 注解。

执行 `flutter clean` 可解。

## 贡献说明
- 欢迎提交 PR 或 Issue
- 样式/交互优化建议请附截图或描述

## License
- MIT
