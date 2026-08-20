# 快速使用：iOS Release 构建

## 自动触发

推送影响 iOS 构建的文件到 `app-ios-ci` 分支后，GitHub Actions 会运行 `Build iOS` 工作流。

## 手动触发

在 GitHub 仓库的 Actions 页面选择 `Build iOS`，然后选择 `app-ios-ci` 分支运行。

## 下载产物

构建成功后下载 `hsmovie-ios-unsigned` artifact，其中包含：

```text
hsmovie-1.0.1-ios-unsigned.ipa
SHA256SUMS.txt
```

## 校验文件

在 PowerShell 中执行：

```powershell
Get-FileHash .\hsmovie-1.0.1-ios-unsigned.ipa -Algorithm SHA256
```

输出应与 `SHA256SUMS.txt` 一致。

## 安装限制

该 IPA 未进行 Apple 代码签名，不能保证直接安装到普通 iPhone。真机安装需要使用属于用户自己的合法证书和描述文件重新签名，或通过用户自行选择的兼容侧载方式处理。

## 已验证构建

| 项目 | 值 |
| --- | --- |
| GitHub Actions 运行 | `32335806222`（Build iOS #3） |
| 构建结果 | 成功 |
| 源提交 | `638c730098b1cc985c95085a5572cb9ec0e531e5` |
| 产物名称 | `hsmovie-ios-unsigned` |
| Artifact ID | `9394666836` |
| Artifact ZIP 大小 | `18,107,108` bytes |
| Artifact ZIP SHA-256 | `a9dd5f6cf22d1d4d4540d8f3283ba9895886deab0a1f0001766be8f14094f1df` |
| 到期时间 | `2026-08-27 13:33`（Asia/Shanghai） |

上述 SHA-256 是 GitHub artifact ZIP 的摘要。IPA 自身的 SHA-256 位于 artifact 内的 `SHA256SUMS.txt`。
