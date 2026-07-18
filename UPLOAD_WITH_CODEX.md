# Codex：把这个源码与错误历史归档上传到 GitHub

目标仓库：

```text
OWNER=krystenneunerjh7102-hue
REPOSITORY=XNP-Gensokyo-Trait-System
VISIBILITY=public
DEFAULT_BRANCH=main
```

本次只上传当前文件夹内容。不要回到旧的 Workshop 发布方案，不要加入：

- Workshop 上传项目；
- preview/poster；
- 图片、音频、纹理；
- Release 附件；
- 原始 console；
- 本机绝对路径；
- 0.5.60.7.2 文件；
- 未经用户指定的新版本源码。

先检查：

```powershell
git --version
gh --version
gh auth status
```

如未登录：

```powershell
gh auth login --web
```

打开浏览器让用户完成登录。

检查仓库：

```powershell
gh repo view krystenneunerjh7102-hue/XNP-Gensokyo-Trait-System
```

不存在则创建：

```powershell
gh repo create krystenneunerjh7102-hue/XNP-Gensokyo-Trait-System --public --description "Archived XNP Gensokyo Trait System source and failure history"
```

在解压后的仓库根目录执行：

```powershell
git init -b main
git add .
git status
git commit -m "archive: add tested 0.5.60.6.11 source and failure history"
git remote add origin https://github.com/krystenneunerjh7102-hue/XNP-Gensokyo-Trait-System.git
git push -u origin main
```

若仓库已经存在，先读取远端内容，不强推，不覆盖无关历史。

本次不创建 GitHub Release，不打版本发布标签。它是源码与错误历史归档，不是正式发布包。

完成后只返回：

```text
GITHUB_REPOSITORY_URL=
GITHUB_UPLOAD_URL=
COMMIT_SHA=
SOURCE_FILE_COUNT=
HISTORY_FILE_COUNT=
PRIVATE_PATH_LEAK_COUNT=
PUSH_PERFORMED=true|false
PUBLICATION_STATUS=PUBLISHED|BLOCKED
BLOCKER=
```
