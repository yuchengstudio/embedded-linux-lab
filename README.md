# SAMA5D27 Docker 开发指南

基于 Microchip SAMA5D27（ATSAMA5D27-SOM1-EK1）的嵌入式 Linux 从零开始培训指南。

覆盖从 0 开始的完整流程（Mac + Docker 环境）：

- Docker Desktop 安装与容器构建环境搭建
- AT91Bootstrap / U-Boot / Linux 内核（linux-6.1-mchp）手动编译
- 设备树概念与编译
- Buildroot 根文件系统全量构建
- SD 卡烧录与上板验证
- 实战踩坑 FAQ（CROSS_COMPILE、gnutls 缺失、defconfig 命名、设备树路径等）

## 在线阅读

直接打开 [index.html](index.html) 即可（护眼绿毛玻璃风格，每条命令带一键复制按钮）。

## 环境

| 组件 | 版本 |
|------|------|
| 宿主机 | macOS (Apple Silicon) |
| 构建容器 | Ubuntu 22.04 (Docker) |
| 交叉工具链 | arm-linux-gnueabihf-gcc 11.4.0 |
| 内核分支 | linux4sam linux-6.1-mchp |
