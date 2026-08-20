# 任务清单：iOS Release 构建

- [x] T001 核对 `version2.0` 远端 HEAD 与现有 iOS 工程。
- [x] T002 从 `version2.0@f62e6cf` 创建独立 `app-ios-ci` 分支。
- [x] T003 增加固定 Flutter/Xcode 版本的 iOS Release 工作流。
- [x] T004 在 CI 中设置 iOS 13 最低版本和“浮光掠影”显示名。
- [x] T005 打包未签名 IPA、SHA-256、依赖日志和构建日志。
- [x] T006 根据首次 CI 错误移除已退休且缺失原生头文件的 Live2D 插件。
- [x] T007 为旧 Objective-C Runner 增加 Swift 插件兼容链接配置。
- [ ] T008 推送构建分支并等待 GitHub Actions 完成。
- [ ] T009 记录最终 artifact、文件大小和 SHA-256。
