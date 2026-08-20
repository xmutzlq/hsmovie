# 功能规格：iOS Release 构建

**功能编号**：004

**目标分支**：`app-ios-ci`

**源代码基线**：`version2.0` 的 `f62e6cf`

## 目标

使用 GitHub Actions 的 macOS runner 编译“浮光掠影”iOS Release 应用，并提供可下载、可校验的未签名 IPA。构建过程不得要求将 Apple 证书、私钥或描述文件提交到仓库。

## 用户场景

作为项目维护者，我希望从 Windows 工作站触发远程 iOS 构建，获得一个可供后续重签名或侧载工具处理的 IPA，同时能够查看依赖解析和 Xcode 编译日志。

## 功能需求

1. 构建必须基于 `version2.0` 的已推送源代码，不包含 macOS 专用布局提交。
2. 构建必须使用固定 Flutter 版本 `3.35.7` 和 macOS runner。
3. iOS 最低部署版本必须在构建期间设置为 iOS 13，以满足当前 Flutter 插件要求。
4. 应用显示名称必须为“浮光掠影”。
5. 构建必须使用 Release 模式并禁用代码签名。
6. 产物必须符合 IPA 的 `Payload/Runner.app` 目录结构。
7. CI 必须同时发布 IPA、`SHA256SUMS.txt`、依赖日志和构建日志。
8. CI 不得读取、生成或提交 Apple 签名秘密。
9. 已退休的 Live2D 插件不得进入 iOS 依赖图；头像保持静态显示，不再打开 Live2D 弹窗。
10. 旧 Objective-C Runner 必须包含 Swift 兼容编译单元，以正确链接当前插件所需的 Swift 标准库。

## 验收标准

- GitHub Actions 的 iOS 构建任务成功结束。
- `hsmovie-ios-unsigned` artifact 包含 `hsmovie-1.0.1-ios-unsigned.ipa` 和 `SHA256SUMS.txt`。
- 编译后的 `Info.plist` 中 `CFBundleName` 与 `CFBundleDisplayName` 均为“浮光掠影”。
- 依赖和构建日志无论成功或失败都可下载。

## 范围外事项

- Apple Developer 证书和描述文件管理。
- App Store、TestFlight 或企业分发上传。
- 保证未签名 IPA 可以直接安装到未越狱 iPhone。
- 修改 Android、Windows、Web 或 macOS 的运行时行为。
