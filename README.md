# XNP Gensokyo Trait System — Development Source & Failure History

作者：**世界第一小脑 / XN-PHL**  
Steam Workshop ID：`3762431102`

本仓库保存经过整理和审计的开发版本源码、公开发布资料与错误修复历史：

1. `src/XNP_PZ_DistanceRunnerTrait_0.5.60.7.5_RUNTIME_TEST/`：0.5.60.7.5 Build 42 运行测试源码；
2. `workshop/0.5.60.7.5/`：该版本的公开 Workshop 元数据与预览资源；
3. `history/0.5.60.7.5/`：该版本公开化的功能、错误、根因与修复记录；
4. `src/XNP_PZ_DistanceRunnerTrait_0.5.60.6.11_RC4_TESTED_BASELINE/` 与 `history/development-evidence/`：完整保留的 0.5.60.6.11 RC4 开发基线及旧版本历史。

## 当前开发版本

0.5.60.7.5 修正绿色技能的分屏玩家世界坐标投影，加入至少 500 ms/两帧的飞行绘制证明与失败关闭命中，并将轮廓目标查找限制为锁定区域内的局部扫描。用户已确认所需功能存在；这属于用户运行结果记录，不等同于自动化完整运行时证明。

该版本是 `RUNTIME_TEST`，并非稳定版。绿色技能测试无冷却和飞行诊断边框仍默认开启，`STABLE_RELEASE_ALLOWED=false`，许可证状态为 `NOT_SELECTED`。

## 重要边界

- 这是**开发归档与运行测试仓库**，不是稳定发布渠道。
- 0.5.60.7.5 的状态与门禁见 `VERSION_STATUS.md` 和 `docs/0.5.60.7.5/TEST_AND_AUDIT_STATUS.md`。
- 0.5.60.6.11 RC4 基线仍保留原有测试态与发布阻断记录，见 `docs/BASELINE_STATUS.md`。
- 仓库不包含原始控制台日志、截图、存档、私有本机路径、认证信息或第三方源码。0.5.60.7.5 仅包含公开 Workshop 预览与模组运行资产。
- `history/` 的目的不是证明所有旧方案可用，而是记录哪些方案失败、为什么失败、后来如何修正。

## 许可证状态

当前未发布明确开源许可证。除非仓库后续明确增加 LICENSE，否则默认保留全部权利：

- 不允许未经授权重新发布；
- 不允许未经授权商业使用；
- 引用错误历史或技术结论时应注明来源。

## 推荐阅读顺序

1. `VERSION_STATUS.md`
2. `docs/0.5.60.7.5/TEST_AND_AUDIT_STATUS.md`
3. `history/0.5.60.7.5/ERRORS_ROOT_CAUSES_AND_FIXES.md`
4. `history/0.5.60.7.5/KNOWN_TEST_ONLY_FLAGS.md`
5. `docs/BASELINE_STATUS.md`
6. `history/development-evidence/KNOWN_ISSUES_AND_FIXES.md`
