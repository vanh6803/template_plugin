# Flutter Template Creator Plugin (Android Studio/IntelliJ)

Plugin giúp tạo nhanh Flutter project mới từ template GitHub trực tiếp trong Android Studio/IntelliJ IDEA.

> Tài liệu cho bản script CLI (chạy trong terminal): xem README ở thư mục gốc.
>
> Link nhanh: [Script CLI README](../README.md)

## 🚀 Tính năng

- ✅ Tạo Flutter project từ template GitHub
- ✅ Giao diện trực quan trong IDE
- ✅ Tuỳ chọn platforms (iOS, Android, Web, Linux, Windows, macOS)
- ✅ Tự động validate project name và package name
- ✅ Tự động cập nhật package name theo project name
- ✅ Tự động mở project sau khi tạo trong Android Studio

## 🔧 Yêu cầu

- Android Studio/IntelliJ IDEA 2023.1 trở lên
- Flutter SDK và Git đã cài đặt
- Script `create_flutter_template.sh` khả dụng (đi kèm plugin hoặc có trong PATH)

## 📦 Build plugin (từ source)

```bash
cd plugin
./gradlew buildPlugin
```

Artifact sẽ nằm tại:

- `plugin/build/distributions/<archiveBaseName>-<version>.zip`
  - Ví dụ: `plugin/build/distributions/flutter-template-plugin-1.0.0.zip`

Lưu ý: Tên file có thể thay đổi nếu bạn cấu hình `archiveBaseName`/`archiveVersion` trong task `BuildPlugin`.

## 🧩 Cài đặt plugin vào Android Studio

Có 2 cách cài:

1. Cài từ file ZIP (đã build hoặc tải từ GitHub Releases)

- Mở Android Studio → `Settings` (hoặc `Preferences` trên macOS) → `Plugins`
- Bấm nút `Gear` → `Install Plugin from Disk...`
- Chọn file `.zip` ở mục “build distributions” (hoặc tải về từ GitHub Releases)
- Restart Android Studio để áp dụng

2. Chạy trực tiếp trong IDE (dành cho dev)

```bash
./gradlew runIde
```

Android Studio sandbox sẽ mở kèm plugin để bạn thử nhanh.

## 🎯 Cách dùng

1. Mở Android Studio/IntelliJ IDEA
2. `File` → `New` → `Create Flutter Project from Template`
   - Shortcut: `Ctrl+Alt+F` (Windows/Linux) hoặc `Cmd+Alt+F` (macOS)
3. Nhập:
   - Project Name (chỉ chữ thường, số, gạch dưới)
   - Package Name (tự sinh từ project name, có thể chỉnh)
   - Output Directory
   - Platforms cần bật
4. Nhấn `OK` để tạo project

## 🚢 Phát hành lên GitHub Releases

Sau khi build được file ZIP:

1. Tạo tag phiên bản (ví dụ `v1.0.0`):
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```
2. Tạo Release trên GitHub:
   - Vào tab `Releases` của repository
   - `Draft a new release` → chọn tag vừa push (`v1.0.0`)
   - Điền tiêu đề, ghi chú thay đổi (changelog)
   - Kéo thả file ZIP từ `plugin/build/distributions/*.zip` vào phần Assets
   - `Publish release`
3. Chia sẻ link Releases để người dùng tải file ZIP và cài qua “Install Plugin from Disk…”

Mẹo:

- Đồng bộ version plugin bằng cách đặt `version = "x.y.z"` trong `build.gradle.kts` và dùng `PatchPluginXml` để ghi vào `plugin.xml`. Nhớ đổi version trước khi build/tag.

## 🧱 Cấu trúc dự án (rút gọn)

```
plugin/
├── build.gradle.kts
├── src/
│   └── main/
│       ├── kotlin/
│       │   └── com/example/fluttertemplate/
│       │       ├── CreateFlutterProjectAction.kt
│       │       └── CreateFlutterProjectDialog.kt
│       └── resources/
│           └── META-INF/
│               └── plugin.xml
└── README.md
```

## 🧪 Development nhanh

- Build: `./gradlew buildPlugin`
- Run IDE sandbox: `./gradlew runIde`
- Test: `./gradlew test`

## 📄 License

MIT

---

## 📌 Hướng dẫn version cho người clone dự án

Có 3 thứ thường cần đặt khi build từ source:

- Version của plugin (ghi vào `plugin.xml` và dùng trong tên file)
- Tên file `.zip` đầu ra
- Version/tag khi phát hành lên GitHub

### 1) Đặt version plugin

Sửa trong `plugin/build.gradle.kts`:

```kotlin
group = "com.example"
version = "1.0.0" // Đổi sang version bạn muốn
```

Plugin đã được cấu hình để `PatchPluginXml` đồng bộ version này vào `plugin.xml`. Bạn chỉ cần sửa một chỗ là đủ.

Mẹo nâng cao: cho phép truyền version khi build (không sửa file):

```kotlin
// Đặt ở đầu file build.gradle.kts
val pluginVersion = providers.gradleProperty("pluginVersion").orElse(version.toString())
version = pluginVersion.get()
```

Lúc build:

```bash
./gradlew buildPlugin -PpluginVersion=1.2.3
```

### 2) Đặt tên file zip đầu ra

Bạn có thể tuỳ biến tên file khi build:

```kotlin
// Trong build.gradle.kts, chỉ chạy khi không phải task wrapper
tasks.withType<org.jetbrains.intellij.tasks.BuildPluginTask> {
    archiveBaseName.set("flutter-template-plugin") // tên base
    archiveVersion.set(project.version.toString()) // phần version
}
```

Khi đó artifact sẽ có dạng:

- `plugin/build/distributions/flutter-template-plugin-<version>.zip`

Cũng có thể truyền khi build (không sửa file), nếu thêm:

```kotlin
val archiveBase = providers.gradleProperty("archiveBaseName").orElse("flutter-template-plugin")

tasks.withType<org.jetbrains.intellij.tasks.BuildPluginTask> {
    archiveBaseName.set(archiveBase)
    archiveVersion.set(project.version.toString())
}
```

Build với tham số:

```bash
./gradlew buildPlugin -PpluginVersion=1.2.3 -ParchiveBaseName=my-flutter-plugin
```

### 3) Đặt tag và phát hành GitHub

Giữ đồng bộ giữa version trong `build.gradle.kts` và tag phát hành:

```bash
# Giả sử bạn đã set version = "1.2.3"
git commit -am "chore: bump plugin version to 1.2.3"
git tag v1.2.3
git push origin main --tags
```

Sau đó tạo Release và upload file `.zip` tương ứng như mục “Phát hành lên GitHub Releases”.
