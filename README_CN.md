# XNP 多模式特质联动｜幻想乡玩法系统 V2 测试版

```text
当前通道：V2 测试版
当前版本：2.1.0-test.1
Build Marker：XNP_V2_210_TEST1_IMPROVEMENTS_A
测试版 Workshop ID：3762431102
稳定版：独立发布链，本次没有更新
```

**当前 `SOURCE/` 是测试版，不是稳定版。**

[测试版 Workshop 页面](https://steamcommunity.com/sharedfiles/filedetails/?id=3762431102)

## 四色系统

- 黄色：长途奔袭者移动、耐力与围困应急震开。
- 红色：守护与制造反馈系统。
- 绿色：弹幕和战斗辅助系统。
- 紫色：不死鸟恢复与独立残机继承系统。

## 本测试版新增内容

- 黄色 Alt 围困应急震开：边沿触发、零直接伤害、不重复扫描世界。
- 红色制造反馈：限制在安全范围内的出汗、体温、用力和疲劳变化。
- 紫色修鞋：每次切换最多输出一条结果摘要。
- 开发测试工具：默认关闭，只生成和删除带 XNP 所有权标记的损坏测试物品。
- Sandbox：新增选项统一由权威值驱动，离线审计未发现 raw/effective 漂移。
- Phoenix：100 ms 完整性检查，只在检测到真实泄漏时恢复保护状态，保护期仍为 10 秒。

## 当前证据状态

| 功能 | 状态 | 边界 |
| --- | --- | --- |
| 黄色 Alt 围困应急震开 | PARTIAL | 静态和离线检查通过；Build 42 中能否稳定打断贴脸抓咬仍需实机验证。 |
| 红色制造反馈 | PASS | 静态与离线 Harness 通过。 |
| 紫色修鞋摘要 | PASS | 静态与离线 Harness 通过。 |
| 损坏物品测试工具 | PASS | 静态与离线 Harness 通过，默认关闭。 |
| Sandbox 权威值统一 | PASS | 离线检查 raw/effective 漂移为 0。 |
| Phoenix 泄漏恢复优化 | PASS | 离线回归检查通过。 |
| 本测试包完整实机矩阵 | NOT_TESTED | 尚未记录此精确版本的完整 Build 42 实机结果。 |

Kahlua 语法检查为 130/130 PASS，已记录的离线回归组全部通过。离线 PASS 不等于实机 PASS。

## SOURCE 安装

`SOURCE/` 根目录直接包含 `mod.info`、`poster.png` 和 `42/`。手动安装时，将其内容放入名为 `XNP_PZ_DistanceRunnerTrait` 的本地模组目录；普通测试推荐使用测试版 Workshop。

## 已知限制

- Build 42.20 尚未测试。
- 多人模式尚未完整验证。
- Bandits2 是可选兼容，不是硬依赖。
- 黄色强控制打断仍处于实机待验证状态。

旧 `src/`、`history/` 和 `docs/` 开发归档继续保留，没有被当前测试源码覆盖。

当前没有选择开源许可证。**保留所有权利（All rights reserved）。**
