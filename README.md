# Flutter Template Creator

Script tự động tạo Flutter project mới từ template GitHub với các tùy chọn tùy chỉnh.

> Tài liệu cho Plugin Android Studio/IntelliJ: xem `plugin/README.md` (Android Studio Plugin).
>
> Link nhanh: [Plugin Android Studio/IntelliJ](plugin/README.md)

## 📋 Mục lục

- [Cài đặt](#cài-đặt)
- [Sử dụng](#sử dụng)
- [Tùy chọn](#tùy-chọn)
- [Ví dụ](#ví-dụ)
- [Troubleshooting](#troubleshooting)

## 🚀 Cài đặt

### 1. Clone hoặc tải script

```bash
# Clone repository hoặc tải script về thư mục bất kỳ
# Ví dụ: ~/tools/flutter_template_creator/
git clone <your-repo> ~/tools/flutter_template_creator
cd ~/tools/flutter_template_creator
```

### 2. Cấp quyền thực thi

```bash
chmod +x create_flutter_template.sh
```

### 3. Thêm alias vào shell (Zsh/Bash)

**Cách 1: Tự động detect đường dẫn (Khuyến nghị)**

Mở file `~/.zshrc` (hoặc `~/.bashrc`) và thêm:

```bash
# Flutter Template Creator - Tự động detect đường dẫn
# Thay đổi đường dẫn dưới đây thành nơi bạn đặt script
FLUTTER_TEMPLATE_DIR="$HOME/tools/flutter_template_creator"
if [ -f "$FLUTTER_TEMPLATE_DIR/create_flutter_template.sh" ]; then
    alias flutter-create-template="$FLUTTER_TEMPLATE_DIR/create_flutter_template.sh"
fi
```

**Cách 2: Đường dẫn trực tiếp**

```bash
# Flutter Template Creator
# Thay đổi đường dẫn theo vị trí thực tế của script
alias flutter-create-template='~/tools/flutter_template_creator/create_flutter_template.sh'
```

**Cách 3: Thêm vào PATH (nếu muốn gọi trực tiếp)**

```bash
# Thêm thư mục chứa script vào PATH
export PATH="$HOME/tools/flutter_template_creator:$PATH"

# Sau đó có thể gọi trực tiếp:
# create_flutter_template.sh myapp
```

**Lưu ý:** Thay đổi đường dẫn `$HOME/tools/flutter_template_creator/` thành đường dẫn thực tế nơi bạn đặt script.

Sau đó reload shell:

```bash
source ~/.zshrc
# hoặc mở terminal mới
```

### 4. Kiểm tra cài đặt

```bash
flutter-create-template --help
```

## 📖 Sử dụng

### Cú pháp cơ bản

```bash
flutter-create-template <project_name> [options]
```

### Tùy chọn

| Option                    | Mô tả                        | Mặc định                     |
| ------------------------- | ---------------------------- | ---------------------------- |
| `--packagename=<package>` | Package name cho Android/iOS | `com.example.<project_name>` |
| `--output=<path>`         | Thư mục output               | Thư mục hiện tại             |
| `--ios`                   | Bao gồm iOS platform         | `true`                       |
| `--no-ios`                | Loại bỏ iOS platform         | -                            |
| `--android`               | Bao gồm Android platform     | `true`                       |
| `--no-android`            | Loại bỏ Android platform     | -                            |
| `--web`                   | Bao gồm Web platform         | `false`                      |
| `--linux`                 | Bao gồm Linux platform       | `false`                      |
| `--windows`               | Bao gồm Windows platform     | `false`                      |
| `--macos`                 | Bao gồm macOS platform       | `false`                      |
| `--help, -h`              | Hiển thị hướng dẫn           | -                            |

## 💡 Ví dụ

### 1. Tạo project cơ bản

```bash
flutter-create-template myapp
```

Tạo project `myapp` với:

- Package name: `com.example.myapp`
- Platforms: iOS, Android
- Output: Thư mục hiện tại

### 2. Tạo project với package name tùy chỉnh

```bash
flutter-create-template myapp --packagename=com.company.myapp
```

### 3. Tạo project chỉ cho Web

```bash
flutter-create-template myapp --no-ios --no-android --web
```

### 4. Tạo project với output directory

```bash
# Đường dẫn tuyệt đối
flutter-create-template myapp --output=/Users/vanh/Projects

# Đường dẫn tương đối
flutter-create-template myapp --output=./projects
```

### 5. Tạo project với nhiều platforms

```bash
flutter-create-template myapp --ios --android --web --linux --windows --macos
```

### 6. Tạo project với đầy đủ options

```bash
flutter-create-template myapp \
  --packagename=com.example.myapp \
  --output=./projects \
  --ios \
  --android \
  --web
```

## 🔧 Template

Script tự động clone/pull template từ:

- **GitHub**: https://github.com/vanh6803/flutter_template.git
- **Local**: `~/Personal/flutter_template`

Template sẽ được tự động cập nhật mỗi lần chạy script để đảm bảo có phiên bản mới nhất.

### Cập nhật template thủ công

```bash
cd ~/Personal/flutter_template
git pull
```

## 📝 Quy tắc đặt tên

### Project name

- Chỉ cho phép: chữ thường (a-z), số (0-9), dấu gạch dưới (\_)
- Phải bắt đầu bằng chữ cái
- Ví dụ hợp lệ: `myapp`, `my_app`, `app123`
- Ví dụ không hợp lệ: `MyApp`, `my-app`, `123app`

### Package name

- Chỉ cho phép: chữ thường (a-z), số (0-9), dấu chấm (.), dấu gạch dưới (\_)
- Phải bắt đầu bằng chữ cái
- Ví dụ hợp lệ: `com.example.myapp`, `com.company.my_app`
- Ví dụ không hợp lệ: `com.Example.MyApp`, `com-example-myapp`

## 🐛 Troubleshooting

### Lỗi: "command not found: flutter-create-template"

**Giải pháp:**

```bash
# Reload shell config
source ~/.zshrc

# Hoặc kiểm tra alias
alias | grep flutter-create-template
```

### Lỗi: "Git chưa được cài đặt"

**Giải pháp:**

```bash
# macOS
brew install git

# Linux
sudo apt-get install git
```

### Lỗi: "Không thể clone template từ GitHub"

**Giải pháp:**

1. Kiểm tra kết nối mạng
2. Clone thủ công:
   ```bash
   git clone https://github.com/vanh6803/flutter_template.git ~/Personal/flutter_template
   ```

### Lỗi: "Thư mục đã tồn tại"

**Giải pháp:**

- Xóa thư mục cũ hoặc chọn tên project khác
- Chọn output directory khác

### Template không cập nhật

**Giải pháp:**

```bash
cd ~/Personal/flutter_template
git pull origin main
# hoặc
git pull origin master
```

## 📂 Cấu trúc sau khi tạo project

```
myapp/
├── lib/
│   └── main.dart
├── test/
├── android/          # (nếu --android)
├── ios/              # (nếu --ios)
├── web/              # (nếu --web)
├── linux/            # (nếu --linux)
├── windows/          # (nếu --windows)
├── macos/            # (nếu --macos)
├── pubspec.yaml
└── README.md
```

## 🎯 Bước tiếp theo sau khi tạo project

```bash
cd myapp
flutter pub get
flutter run
```

## 📚 Thêm thông tin

- Template GitHub: https://github.com/vanh6803/flutter_template
- Flutter Documentation: https://docs.flutter.dev

## 📄 License

MIT
