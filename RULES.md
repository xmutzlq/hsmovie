# hsmovie 2.0 Project Rules

## Project Ownership

- `D:\workspace\zlq\hsmovie` is the implementation project. The TV Agent project is read-only reference material.
- Work for version 2.0 stays on the `version2.0` branch unless the user explicitly requests another branch.
- Playback source resolution remains Flutter-owned: CMS candidates keep their existing priority and the hsmovie HTML source remains the fallback.

## Playback

- Local video playback MUST use `media_kit`, `media_kit_video`, and `media_kit_libs_video`.
- FijkPlayer and IJK dependencies, imports, native binaries, and new compatibility code are prohibited after migration.
- The existing player page layout and interactions MUST remain compatible, including source tabs, episodes, seek, speed, fullscreen, lock, auto-next, CMS indicator, DLNA, resume, lifecycle handling, and stall recovery.
- HLS manifests MUST use the ad-filter behavior ported from TV Agent. A filtering or proxy failure MUST fail open to the original remote URL.
- HLS filtering applies only to local playback. DLNA MUST receive the original remote URL, never a loopback URL.

## Specification And Documentation

- Non-trivial work follows Spec Kit: constitution, specification, clarification, plan, tasks, implementation, and validation.
- Formal Markdown artifacts (`RULES.md`, the constitution, and files under `specs/`) MUST have a same-name `.html` counterpart. README and `.specify/templates/` are excluded.
- Markdown is canonical. HTML mirrors MUST contain the same substantive content and MUST NOT introduce independent requirements.
- API or design changes MUST be documented before implementation tasks are marked complete.

## Quality Gates

- Playback parsing/filtering changes require unit tests. Player migration requires controller tests and Android integration validation.
- HLS manifest buffering is capped at 1 MiB. A filter that would remove every media segment MUST return the original manifest.
- Logs MUST identify source, filter outcome, segment counts, and fallback reason without exposing access tokens or complete sensitive URLs.
- Before completion, `flutter analyze`, `flutter test`, and an Android debug build MUST pass, or the exact external blocker MUST be recorded.

## Build Storage

- Flutter commands MUST use `PUB_CACHE=D:\Flutter\flutter_cache`.
- Gradle commands MUST use `GRADLE_USER_HOME=D:\Users\liqin.zeng\.gradle`.
- uv commands MUST use a D-drive `UV_CACHE_DIR`.
- Build-scoped `TEMP` and `TMP` MUST point to a D-drive temporary directory. Do not intentionally create Flutter, Gradle, uv, or build caches on C:.
- Windows builds on machines without administrator rights MUST use the checked-in user-mode build script and D-drive portable toolchain. They MUST NOT require Developer Mode, Visual Studio Installer changes, registry edits, UAC elevation, or system-wide package installation.

## Image Presentation

- Real-ESRGAN and other local image-enhancement executables MUST NOT be packaged or launched. Apex One classifies their generated temporary images as unauthorized file encryption.
- Image widgets MUST preserve the source aspect ratio when stretching or cropping would materially distort the subject.
- On Windows only, when the home API provides a portrait `VodPic` for a wide banner, use a blurred cover background with a contained foreground image. Non-Windows platforms MUST retain their existing banner path and `BoxFit.cover` behavior.
- Apply the same proportion-safe composition to Windows detail headers that receive only portrait artwork. Mobile detail headers may retain their existing cover treatment.
- Prefer a dedicated high-resolution landscape image from the API when one becomes available. Client-side scaling cannot recreate missing source detail.
