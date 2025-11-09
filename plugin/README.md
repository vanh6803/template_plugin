# Flutter Template Creator Plugin for Android Studio/IntelliJ

Plugin để tạo Flutter project mới từ template GitHub trực tiếp trong Android Studio/IntelliJ IDEA.

## 🚀 Tính năng

- ✅ Tạo Flutter project từ template GitHub
- ✅ Giao diện trực quan trong IDE
- ✅ Tùy chọn platforms (iOS, Android, Web, Linux, Windows, macOS)
- ✅ Tự động validate project name và package name
- ✅ Tự động cập nhật package name khi nhập project name
- ✅ **Tự động mở project sau khi tạo** trong Android Studio

## 📦 Cài đặt

### Cách 1: Build từ source

```bash
cd plugin
./gradlew buildPlugin
```

File plugin sẽ được tạo tại: `build/distributions/FlutterTemplateCreator-1.0.0.zip`

### Cách 2: Cài đặt trong IDE

1. Mở Android Studio/IntelliJ IDEA
2. Vào `File` → `Settings` → `Plugins`
3. Chọn `Install Plugin from Disk...`
4. Chọn file `.zip` đã build
5. Restart IDE

## 🎯 Sử dụng

1. Mở Android Studio/IntelliJ IDEA
2. Vào `File` → `New` → `Create Flutter Project from Template`
   - Hoặc dùng shortcut: `Ctrl+Alt+F` (Windows/Linux) hoặc `Cmd+Alt+F` (macOS)
3. Điền thông tin:
   - **Project Name**: Tên project (chỉ chữ thường, số, dấu gạch dưới)
   - **Package Name**: Package name (tự động generate từ project name)
   - **Output Directory**: Thư mục chứa project mới
   - **Platforms**: Chọn platforms cần thiết
4. Click `OK` để tạo project

## 🔧 Yêu cầu

- Android Studio/IntelliJ IDEA 2023.1 trở lên
- Flutter SDK đã cài đặt
- Git đã cài đặt
- Script `create_flutter_template.sh` phải có sẵn (trong plugin hoặc PATH)

## 📝 Cấu trúc Plugin

```
plugin/
├── build.gradle.kts          # Build configuration
├── src/
│   └── main/
│       ├── kotlin/
│       │   └── com/example/fluttertemplate/
│       │       ├── CreateFlutterProjectAction.kt    # Main action
│       │       └── CreateFlutterProjectDialog.kt    # UI dialog
│       └── resources/
│           └── META-INF/
│               └── plugin.xml                       # Plugin manifest
└── README.md
```

## 🛠️ Development

### Build plugin

```bash
./gradlew buildPlugin
```

### Run plugin trong IDE

```bash
./gradlew runIde
```

### Test plugin

```bash
./gradlew test
```

## 📄 License

MIT
