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
