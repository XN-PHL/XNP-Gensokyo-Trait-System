# XNP GitHub 上传完成后的后续说明

## 当前发布对象

- 仓库：`krystenneunerjh7102-hue/XNP-Gensokyo-Trait-System`
- 分支：`main`
- 定位：源码与失败历史归档
- 基线：`0.5.60.6.11 RC4`
- Steam Workshop ID：`3762431102`

## 仓库中将保存什么

1. `README.md`：仓库用途、边界和许可证状态；
2. `docs/BASELINE_STATUS.md`：该测试基线已知的阻断与历史状态；
3. `src/SOURCE_SNAPSHOT_COMPLETE.md`：全部 `114` 个文本源码文件的可搜索合并快照；
4. `src/SOURCE_FILE_INDEX.md`：源码文件路径及 SHA-256；
5. `history/FAILURE_HISTORY_COMPLETE.md`：全部 `122` 个脱敏历史文件的可搜索合并快照；
6. `archive/XNP_Gensokyo_Trait_System_Source_History_0.5.60.6.11_REPO_READY.zip`：保留原始目录层级的完整仓库就绪包；
7. `MANIFEST_SHA256.txt`：关键上传文件校验。

## 后续开发规则

- 不直接覆盖这次归档；
- 新功能从新分支或新版本目录开始；
- 修改机制前，先搜索 `FAILURE_HISTORY_COMPLETE.md`；
- 搜索旧版本号、函数名、API 名、Lua 错误文本和审计阻断；
- 旧历史只证明“曾经发生过什么”，不能自动证明旧方案现在仍正确；
- 0.5.60.6.11 RC4 是开发基线，不标记为最新正式发布版；
- 当前不创建 GitHub Release，不创建正式版本标签。

## 用户接下来需要做什么

上传成功后只需要打开仓库检查首页是否正常显示 README。  
后续需要继续开发时，把仓库地址交给 Codex，并要求它先阅读：

1. `docs/BASELINE_STATUS.md`
2. `history/FAILURE_HISTORY_COMPLETE.md`
3. `src/SOURCE_FILE_INDEX.md`

仓库地址：

`https://github.com/krystenneunerjh7102-hue/XNP-Gensokyo-Trait-System`
