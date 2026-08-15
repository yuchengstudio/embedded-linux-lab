# 嵌入式Linux驱动开发读书实验台 - 总览

## 项目组成

### 1. 读书实验台 HTML（核心工作台）
- **文件**: `embedded-linux-book-workspace.html`
- **功能**: 单文件 HTML，浏览器打开即用
- **模块**:
  - 书籍信息卡（书名、作者、ISBN、硬件平台）
  - 今天要处理（自动汇总逾期+今日到期项）
  - 章节进度（13章，状态切换、计划日期、关键概念摘要）
  - 实验日志（30个实验，含关键API、Docker命令、书中代码清单编号）
  - 读书笔记（按章节关联）
  - 数据备份（导出JSON / 导入恢复 / 清空确认）
- **数据存储**: localStorage，版本化（v3），旧版自动提示升级
- **响应式**: PC桌面Tab + 移动端底部Tab

### 2. Docker + QEMU 实验环境
- **目录**: `linux-driver-lab/`
- **Docker镜像**: `linux-driver-lab:latest` (369MB, ARM64)
- **工具链**: gcc 11.4, make 4.3, qemu-system-aarch64 6.2, busybox 1.30
- **脚本**:
  - `start-lab.sh` - 一键启动容器
  - `scripts/build-kernel.sh` - 编译Linux 6.1 LTS内核
  - `scripts/compile-module.sh` - 编译内核模块(.c → .ko)
  - `scripts/make-initramfs.sh` - 打包rootfs
  - `scripts/run-qemu.sh` - 启动QEMU虚拟机
- **示例模块**:
  - `modules/hello/hello.c` - 第3章：Hello World内核模块
  - `modules/chardev/chardev.c` - 第4章：字符设备驱动

### 3. 书籍资料
- **书名**: 嵌入式Linux设备驱动程序开发指南（原书第2版）
- **作者**: Alberto Liberal de los Rios
- **出版社**: 机械工业出版社 2021
- **ISBN**: 9787111684558
- **硬件平台**: NXP i.MX7D / Microchip SAMA5D2 / Broadcom BCM2837
- **结构**: 13章 + 附录，30个实验
- `book-toc.md` - 完整目录
- `book-ch01-build-system.md` - 第1章全文提取

### 4. 实验对照表
- **文件**: `linux-driver-lab/EXPERIMENTS.md`
- **内容**: 全书30个实验的完整对照表
  - 实验编号、名称、关联章节
  - 关键内核API
  - Docker Lab操作命令
  - 书中代码清单编号

## 使用流程

```
读章节 → 在工作台标记进度
   ↓
按书中实验编号 → 在Docker Lab写代码
   ↓
compile-module → make-initramfs → run-qemu
   ↓
QEMU内测试 → 记录结果到工作台
   ↓
遇到问题 → 对话中问我
```

## 进度状态（2026-08-15）

- 第1-2章：已读
- 第3章：进行中
- 实验3-1：已完成
- 实验3-2：进行中（逾期1天）
- 实验3-3至13-4：计划中（日期排到10月26日）
