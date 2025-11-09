# Hướng dẫn sử dụng Plugin Flutter Template Creator

## 📦 Cài đặt Plugin

### Bước 1: Build plugin (nếu chưa có file .zip)

```bash
cd plugin
./gradlew buildPlugin
```

File plugin sẽ ở: `build/distributions/FlutterTemplateCreator-1.0.0.zip`

### Bước 2: Cài đặt trong Android Studio/IntelliJ IDEA

1. Mở **Android Studio** hoặc **IntelliJ IDEA**
2. Vào **File** → **Settings** (hoặc **Preferences** trên macOS)
3. Chọn **Plugins** ở menu bên trái
4. Click vào biểu tượng ⚙️ (Settings) ở góc trên cùng
5. Chọn **Install Plugin from Disk...**
6. Chọn file `FlutterTemplateCreator-1.0.0.zip`
7. Click **OK**
8. Restart IDE khi được yêu cầu

### Bước 3: Kiểm tra cài đặt

Sau khi restart, kiểm tra plugin đã được cài đặt:

- Vào **File** → **Settings** → **Plugins**
- Tìm "Flutter Template Creator" - phải có dấu ✓ (enabled)

## 🚀 Sử dụng Plugin

Plugin sẽ xuất hiện ở nhiều nơi để bạn dễ dàng tạo Flutter project:

### Cách 1: Từ Menu (Khi có project mở)

1. Mở Android Studio/IntelliJ IDEA
2. Vào **File** → **New** → **Flutter Project from Template**
3. Dialog sẽ hiện ra để nhập thông tin

### Cách 2: Dùng Keyboard Shortcut

- **Windows/Linux**: `Ctrl + Alt + F`
- **macOS**: `Cmd + Alt + F`

### Cách 3: Từ Welcome Screen (Khi không có project mở)

1. Mở Android Studio
2. Ở **Welcome Screen**, tìm phần **Quick Start**
3. Click **Flutter Project from Template**
4. Dialog sẽ hiện ra

### Cách 4: Từ New Project Wizard (Đang phát triển)

Plugin sẽ tự động xuất hiện trong New Project Wizard khi bạn tạo project mới.

## 📝 Điền thông tin trong Dialog

### 1. Project Name

- **Bắt buộc**: Có
- **Định dạng**: Chữ thường (a-z), số (0-9), dấu gạch dưới (\_)
- **Yêu cầu**: Phải bắt đầu bằng chữ cái
- **Ví dụ hợp lệ**: `myapp`, `my_app`, `app123`
- **Ví dụ không hợp lệ**: `MyApp`, `my-app`, `123app`

### 2. Package Name

- **Bắt buộc**: Không (tự động generate)
- **Định dạng**: Chữ thường, số, dấu chấm (.), dấu gạch dưới (\_)
- **Mặc định**: `com.example.<project_name>` (tự động generate từ project name)
- **Ví dụ**: `com.example.myapp`, `com.company.my_app`

### 3. Output Directory

- **Bắt buộc**: Không
- **Mặc định**: Thư mục hiện tại hoặc `~/Projects`
- **Có thể**: Đường dẫn tuyệt đối hoặc tương đối
- **Ví dụ**:
  - `/Users/vanh/Projects`
  - `./projects`
  - `../flutter_projects`

### 4. Platforms

Chọn các platforms cần thiết:

- ✅ **iOS** (mặc định: enabled)
- ✅ **Android** (mặc định: enabled)
- ⬜ **Web** (mặc định: disabled)
- ⬜ **Linux** (mặc định: disabled)
- ⬜ **Windows** (mặc định: disabled)
- ⬜ **macOS** (mặc định: disabled)

**Lưu ý**: Phải chọn ít nhất một platform

## 📋 Ví dụ sử dụng

### Ví dụ 1: Tạo project cơ bản

1. Mở dialog (Menu hoặc shortcut)
2. Nhập:
   - **Project Name**: `myapp`
   - **Package Name**: (để trống, sẽ tự động = `com.example.myapp`)
   - **Output Directory**: (để trống hoặc chọn thư mục)
   - **Platforms**: ✅ iOS, ✅ Android
3. Click **OK**
4. Đợi script chạy xong
5. Project sẽ được tạo tại: `<output_dir>/myapp`

### Ví dụ 2: Tạo project chỉ cho Web

1. Mở dialog
2. Nhập:
   - **Project Name**: `webapp`
   - **Package Name**: `com.example.webapp`
   - **Output Directory**: `~/Projects`
   - **Platforms**:
     - ⬜ iOS (bỏ chọn)
     - ⬜ Android (bỏ chọn)
     - ✅ Web (chọn)
3. Click **OK**

### Ví dụ 3: Tạo project với nhiều platforms

1. Mở dialog
2. Nhập:
   - **Project Name**: `multiplatform_app`
   - **Package Name**: `com.company.multiplatform`
   - **Output Directory**: `/Users/vanh/Projects`
   - **Platforms**:
     - ✅ iOS
     - ✅ Android
     - ✅ Web
     - ✅ Linux
     - ✅ Windows
     - ✅ macOS
3. Click **OK**

## ⚙️ Quy trình hoạt động

Khi bạn click **OK**, plugin sẽ:

1. **Validate** thông tin (project name, package name, output directory)
2. **Tìm script** `create_flutter_template.sh`:
   - Từ plugin resources (tự động extract)
   - Hoặc từ `~/Personal/template_plugin/create_flutter_template.sh`
   - Hoặc từ PATH
3. **Clone/Pull template** từ GitHub:
   - Tự động clone từ `https://github.com/vanh6803/flutter_template.git`
   - Hoặc sử dụng template cục bộ tại `~/Personal/flutter_template`
4. **Tạo project** với các thông tin đã nhập
5. **Thay thế** package name và project name trong các file
6. **Xóa** các platforms không được chọn
7. **Hiển thị** thông báo thành công
8. **Tự động mở project** trong Android Studio (tùy chọn)

## 🎯 Sau khi tạo project

### Tự động mở project

Sau khi project được tạo thành công, plugin sẽ hỏi bạn có muốn mở project ngay không:

- **Yes**: Mở project trong Android Studio

  - Nếu đang có project mở, bạn sẽ được hỏi:
    - **New Window**: Mở project mới trong window mới
    - **Replace**: Đóng project hiện tại và mở project mới
    - **Cancel**: Hủy, không mở project
  - Nếu không có project nào đang mở, project mới sẽ được mở trực tiếp

- **No**: Chỉ hiển thị thông báo, không mở project
  - Bạn có thể mở project sau bằng: **File → Open → Chọn thư mục project**

### Chạy project

Sau khi mở project:

1. **Chạy lệnh Flutter** (nếu cần):

   ```bash
   cd <project_directory>
   flutter pub get
   flutter run
   ```

2. **Chạy từ IDE**:
   - Chọn device/emulator
   - Click nút Run hoặc nhấn `Shift+F10` (Windows/Linux) / `Ctrl+R` (macOS)

## ❓ Troubleshooting

### Plugin không xuất hiện trong menu

**Giải pháp:**

1. Kiểm tra plugin đã được enable:
   - File → Settings → Plugins
   - Tìm "Flutter Template Creator" → phải có dấu ✓
2. Restart IDE
3. Kiểm tra shortcut: `Ctrl+Alt+F` / `Cmd+Alt+F`

### Dialog không mở

**Giải pháp:**

1. Kiểm tra log: Help → Show Log in Explorer/Finder
2. Xem có lỗi gì không
3. Thử restart IDE

### Lỗi "Script not found"

**Giải pháp:**

1. Đảm bảo script `create_flutter_template.sh` có trong plugin
2. Hoặc đặt script ở: `~/Personal/template_plugin/create_flutter_template.sh`
3. Hoặc thêm script vào PATH

### Lỗi "Cannot create directory"

**Giải pháp:**

1. Kiểm tra quyền truy cập thư mục output
2. Chọn thư mục khác có quyền ghi
3. Kiểm tra đủ dung lượng ổ cứng

### Project tạo thành công nhưng không mở được

**Giải pháp:**

1. Mở thủ công: File → Open → Chọn thư mục project
2. Kiểm tra Flutter SDK đã cài đặt: `flutter --version`
3. Chạy `flutter pub get` trong terminal

## 🔧 Cấu hình nâng cao

### Thay đổi template repository

Nếu muốn sử dụng template khác, sửa script `create_flutter_template.sh`:

```bash
TEMPLATE_GIT_URL="https://github.com/your-repo/your-template.git"
```

### Thay đổi shortcut

1. File → Settings → Keymap
2. Tìm "Create Flutter Project from Template"
3. Right-click → Add Keyboard Shortcut
4. Chọn shortcut mới

## 📚 Tài liệu thêm

- [README.md](README.md) - Tổng quan về plugin
- [BUILD.md](BUILD.md) - Hướng dẫn build plugin
- [TROUBLESHOOTING.md](TROUBLESHOOTING.md) - Xử lý lỗi

## 💡 Tips

1. **Sử dụng shortcut**: `Ctrl+Alt+F` / `Cmd+Alt+F` để mở nhanh
2. **Auto-generate package name**: Để trống package name để tự động generate
3. **Validate trước khi tạo**: Dialog sẽ validate thông tin trước khi tạo project
4. **Template tự động cập nhật**: Script sẽ tự động pull template mới nhất từ GitHub
