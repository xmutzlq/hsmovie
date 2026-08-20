# 实施计划：iOS Release 构建

## 技术方案

在从 `version2.0@f62e6cf` 创建的 `app-ios-ci` 分支中增加独立 GitHub Actions 工作流。工作流使用 macOS 15、Xcode 26.3 和 Flutter 3.35.7，执行锁定依赖解析及 `flutter build ios --release --no-codesign`。

构建前只在 CI 工作副本中将 iOS deployment target 调整为 13.0，并将 iOS 显示名称设置为“浮光掠影”。这些调整不影响其他平台代码路径。

## 产物设计

编译得到的 `build/ios/iphoneos/Runner.app` 被复制到 `Payload/Runner.app`，再打包为：

```text
hsmovie-1.0.1-ios-unsigned.ipa
```

同一 artifact 还包含：

```text
SHA256SUMS.txt
```

依赖解析日志和 Xcode 构建日志作为独立 artifact 保留 7 天。

## 安全与限制

- 工作流权限仅为 `contents: read`。
- 不使用 Apple 证书、私钥、描述文件或仓库 secrets。
- 未签名 IPA 需要用户自己的合法 Apple 签名材料或兼容侧载方式才能安装到普通真机。
- 不更改移动端业务逻辑，不合并 macOS 专用分支。

## 验证方式

本任务只执行产物所必需的远程构建，不额外运行自动化测试、静态分析、截图或功能验收。CI 会校验 App bundle 存在、显示名称正确，并生成 SHA-256。
