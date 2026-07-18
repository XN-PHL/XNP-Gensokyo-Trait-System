# XNP Gensokyo Trait System — Source & Failure History Archive

作者：**世界第一小脑 / XN-PHL**  
Steam Workshop ID：`3762431102`

本仓库只保存两类内容：

1. `src/`：曾经实机使用过的 **0.5.60.6.11 RC4 开发基线源码**；
2. `history/`：经过脱敏的错误、根因、审计和修复演化记录，用于避免后续开发重复踩坑。

## 重要边界

- 这是**开发归档仓库**，不是最新正式发布包，也不是可直接订阅安装的 Workshop 项目。
- 二次静态复核发现该基线仍保留测试态与发布阻断，详见 `docs/BASELINE_STATUS.md`。
- 仓库故意不包含海报、预览图、截图、音频、纹理、Workshop 上传项目、原始控制台日志和私有本机路径。
- `src/` 只保留 Lua、配置、翻译和脚本等文本源码。
- `history/` 的目的不是证明所有旧方案可用，而是记录哪些方案失败、为什么失败、后来如何修正。

## 许可证状态

当前未发布明确开源许可证。除非仓库后续明确增加 LICENSE，否则默认保留全部权利：

- 不允许未经授权重新发布；
- 不允许未经授权商业使用；
- 引用错误历史或技术结论时应注明来源。

## 推荐阅读顺序

1. `docs/BASELINE_STATUS.md`
2. `history/development-evidence/KNOWN_ISSUES_AND_FIXES.md`
3. `history/development-evidence/02_ALL_ERRORS_AND_ROOT_CAUSES.md`
4. `history/development-evidence/01_COMPLETE_VERSION_TIMELINE.md`
5. `history/development-evidence/versions/`
