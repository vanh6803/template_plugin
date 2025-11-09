# Hướng dẫn cài đặt Plugin Flutter Template Creator

## Yêu cầu

- Android Studio/IntelliJ IDEA 2023.1 trở lên
- Flutter SDK đã cài đặt
- Git đã cài đặt

## Cách 1: Build và cài đặt từ source

### Bước 1: Build plugin

```bash
cd plugin
./gradlew buildPlugin
```

File plugin sẽ được tạo tại: `build/distributions/FlutterTemplateCreator-1.0.0.zip`

### Bước 2: Cài đặt trong IDE

1. Mở Android Studio/IntelliJ IDEA
2. Vào `File` → `Settings` (hoặc `Preferences` trên macOS)
3. Chọn `Plugins`
4. Click vào biểu tượng ⚙️ (Settings) → `Install Plugin from Disk...`
5. Chọn file `FlutterTemplateCreator-1.0.0.zip` vừa build
6. Click `OK` và restart IDE

## Cách 2: Development mode

### Chạy plugin trong IDE mới

```bash
cd plugin
./gradlew runIde
```

IDE mới sẽ mở với plugin đã được cài đặt.

## Cách 3: Cài đặt từ Marketplace (nếu có)

1. Mở Android Studio/IntelliJ IDEA
2. Vào `File` → `Settings` → `Plugins`
3. Tìm "Flutter Template Creator"
4. Click `Install`
5. Restart IDE

## Kiểm tra cài đặt

Sau khi cài đặt, bạn sẽ thấy:

1. Menu `File` → `New` → `Create Flutter Project from Template`
2. Hoặc dùng shortcut: `Ctrl+Alt+F` (Windows/Linux) hoặc `Cmd+Alt+F` (macOS)

## Troubleshooting

### Plugin không xuất hiện

- Kiểm tra IDE version có đúng 2023.1+ không
- Restart IDE
- Kiểm tra plugin đã được enable trong Settings → Plugins

### Script không tìm thấy

- Đảm bảo script `create_flutter_template.sh` có trong plugin resources
- Hoặc đặt script ở `~/Personal/template_plugin/create_flutter_template.sh`
- Hoặc thêm script vào PATH

### Lỗi khi build

- Đảm bảo đã cài đặt JDK 17+
- Chạy `./gradlew clean` rồi build lại

