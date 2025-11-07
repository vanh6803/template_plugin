#!/bin/bash

# Script để tạo Flutter project mới từ template
# Usage: ./create_flutter_template.sh <project_name> [options]
# Example: 
#   ./create_flutter_template.sh myapp
#   ./create_flutter_template.sh myapp --packagename=com.example.abc
#   ./create_flutter_template.sh myapp --output=/path/to/output
#   ./create_flutter_template.sh myapp --ios --android --packagename=com.example.abc
#   ./create_flutter_template.sh myapp --no-ios --no-android --web

set -e

# Màu sắc cho output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Biến đếm step
STEP_COUNTER=0
TOTAL_STEPS=0

# Hàm lấy timestamp
get_timestamp() {
    date '+%H:%M:%S'
}

# Hàm hiển thị thông báo với timestamp
print_info() {
    echo -e "${GREEN}[$(get_timestamp)] [INFO]${NC} $1"
}

print_error() {
    echo -e "${RED}[$(get_timestamp)] [ERROR]${NC} $1" >&2
}

print_warning() {
    echo -e "${YELLOW}[$(get_timestamp)] [WARNING]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[$(get_timestamp)] [✓]${NC} ${BOLD}$1${NC}"
}

print_step() {
    STEP_COUNTER=$((STEP_COUNTER + 1))
    echo -e "${CYAN}[$(get_timestamp)] [STEP $STEP_COUNTER/$TOTAL_STEPS]${NC} ${BOLD}$1${NC}"
}

print_substep() {
    echo -e "${BLUE}  →${NC} $1"
}

print_separator() {
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# Hàm để thay thế text trong file (KHÔNG tạo file backup)
replace_in_file() {
    local file="$1"
    local pattern="$2"
    local replacement="$3"
    
    if [ ! -f "$file" ]; then
        return 1
    fi
    
    # Sử dụng temp file để tránh tạo backup
    local temp_file=$(mktemp)
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed "s|$pattern|$replacement|g" "$file" > "$temp_file"
    else
        sed "s|$pattern|$replacement|g" "$file" > "$temp_file"
    fi
    mv "$temp_file" "$file"
}

# Lấy đường dẫn của script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Xác định thư mục template
# Luôn clone/pull từ GitHub để đảm bảo có template mới nhất
TEMPLATE_LOCAL_DIR="$HOME/Personal/flutter_template"
TEMPLATE_GIT_URL="https://github.com/vanh6803/flutter_template.git"
TEMPLATE_DIR=""

# Bắt đầu script với header
print_separator
echo -e "${BOLD}${CYAN}Flutter Template Creator${NC}"
print_separator

# Kiểm tra Git đã cài đặt chưa
if ! command -v git &> /dev/null; then
    print_error "Git chưa được cài đặt! Vui lòng cài đặt Git trước."
    print_info "  macOS: brew install git"
    print_info "  Linux: sudo apt-get install git"
    exit 1
fi

# Tạo thư mục cha nếu chưa có
mkdir -p "$HOME/Personal"

# Tính toán total steps (ước tính)
TOTAL_STEPS=8

# Kiểm tra và clone/pull template từ GitHub
print_step "Kiểm tra và cập nhật template"
if [ -d "$TEMPLATE_LOCAL_DIR" ] && [ -d "$TEMPLATE_LOCAL_DIR/.git" ]; then
    # Template đã tồn tại và là git repository, pull để cập nhật
    print_substep "Template đã tồn tại, đang cập nhật từ GitHub..."
    PULL_SUCCESS=false
    cd "$TEMPLATE_LOCAL_DIR"
    # Lấy nhánh hiện tại hoặc thử main/master
    CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "main")
    if git pull origin "$CURRENT_BRANCH" 2>/dev/null || git pull origin main 2>/dev/null || git pull origin master 2>/dev/null; then
        PULL_SUCCESS=true
        print_success "Template đã được cập nhật"
    fi
    cd - > /dev/null
    
    # Kiểm tra kết quả pull
    if [ "$PULL_SUCCESS" = true ] && [ -f "$TEMPLATE_LOCAL_DIR/pubspec.yaml" ]; then
        TEMPLATE_DIR="$TEMPLATE_LOCAL_DIR"
        print_substep "Template location: $TEMPLATE_DIR"
    else
        print_warning "Pull thất bại, đang clone lại..."
        rm -rf "$TEMPLATE_LOCAL_DIR"
        print_substep "Đang clone từ: $TEMPLATE_GIT_URL"
        if git clone "$TEMPLATE_GIT_URL" "$TEMPLATE_LOCAL_DIR"; then
            TEMPLATE_DIR="$TEMPLATE_LOCAL_DIR"
            print_success "Đã clone template thành công"
        else
            print_error "Không thể clone template từ GitHub!"
            print_info "Kiểm tra kết nối mạng hoặc clone thủ công:"
            print_info "  git clone $TEMPLATE_GIT_URL $TEMPLATE_LOCAL_DIR"
            exit 1
        fi
    fi
elif [ -d "$TEMPLATE_LOCAL_DIR" ]; then
    # Thư mục tồn tại nhưng không phải git repo, xóa và clone lại
    print_warning "Thư mục tồn tại nhưng không phải git repository"
    print_substep "Đang xóa và clone lại..."
    rm -rf "$TEMPLATE_LOCAL_DIR"
    print_substep "Đang clone từ: $TEMPLATE_GIT_URL"
    if git clone "$TEMPLATE_GIT_URL" "$TEMPLATE_LOCAL_DIR"; then
        TEMPLATE_DIR="$TEMPLATE_LOCAL_DIR"
        print_success "Đã clone template thành công"
    else
        print_error "Không thể clone template từ GitHub!"
        print_info "Kiểm tra kết nối mạng hoặc clone thủ công:"
        print_info "  git clone $TEMPLATE_GIT_URL $TEMPLATE_LOCAL_DIR"
        exit 1
    fi
else
    # Chưa có template, clone mới
    print_substep "Template chưa tồn tại, đang clone từ GitHub..."
    print_substep "Repository: $TEMPLATE_GIT_URL"
    if git clone "$TEMPLATE_GIT_URL" "$TEMPLATE_LOCAL_DIR"; then
        TEMPLATE_DIR="$TEMPLATE_LOCAL_DIR"
        print_success "Đã clone template thành công"
    else
        print_error "Không thể clone template từ GitHub!"
        print_info "Kiểm tra kết nối mạng hoặc clone thủ công:"
        print_info "  git clone $TEMPLATE_GIT_URL $TEMPLATE_LOCAL_DIR"
        exit 1
    fi
fi

# Kiểm tra lại template có hợp lệ không
if [ ! -d "$TEMPLATE_DIR" ] || [ ! -f "$TEMPLATE_DIR/pubspec.yaml" ]; then
    print_error "Template không hợp lệ tại: $TEMPLATE_DIR"
    print_error "Thiếu file pubspec.yaml hoặc thư mục không tồn tại"
    exit 1
fi
print_substep "Template location: $TEMPLATE_DIR"

# Hàm hiển thị help
show_help() {
    echo "Usage: $0 <project_name> [options]"
    echo ""
    echo "Options:"
    echo "  --packagename=<package>    Package name (default: com.example.<project_name>)"
    echo "  --output=<path>            Output directory (default: current directory)"
    echo "  --ios                      Include iOS platform (default: true)"
    echo "  --no-ios                   Exclude iOS platform"
    echo "  --android                  Include Android platform (default: true)"
    echo "  --no-android               Exclude Android platform"
    echo "  --web                      Include Web platform (default: false)"
    echo "  --linux                    Include Linux platform (default: false)"
    echo "  --windows                  Include Windows platform (default: false)"
    echo "  --macos                    Include macOS platform (default: false)"
    echo "  --help, -h                 Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 myapp"
    echo "  $0 myapp --packagename=com.example.abc"
    echo "  $0 myapp --output=/path/to/projects"
    echo "  $0 myapp --output=./projects"
    echo "  $0 myapp --ios --android --packagename=com.example.abc"
    echo "  $0 myapp --no-ios --no-android --web"
}

# Parse arguments
PROJECT_NAME=""
PACKAGE_NAME=""
OUTPUT_DIR=""
INCLUDE_IOS=true
INCLUDE_ANDROID=true
INCLUDE_WEB=false
INCLUDE_LINUX=false
INCLUDE_WINDOWS=false
INCLUDE_MACOS=false

# Kiểm tra input
if [ -z "$1" ] || [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
    show_help
    exit 0
fi

PROJECT_NAME="$1"
shift

# Parse options
while [[ $# -gt 0 ]]; do
    case $1 in
        --packagename=*)
            PACKAGE_NAME="${1#*=}"
            shift
            ;;
        --output=*)
            OUTPUT_DIR="${1#*=}"
            shift
            ;;
        --ios)
            INCLUDE_IOS=true
            shift
            ;;
        --no-ios)
            INCLUDE_IOS=false
            shift
            ;;
        --android)
            INCLUDE_ANDROID=true
            shift
            ;;
        --no-android)
            INCLUDE_ANDROID=false
            shift
            ;;
        --web)
            INCLUDE_WEB=true
            shift
            ;;
        --linux)
            INCLUDE_LINUX=true
            shift
            ;;
        --windows)
            INCLUDE_WINDOWS=true
            shift
            ;;
        --macos)
            INCLUDE_MACOS=true
            shift
            ;;
        *)
            print_error "Option không hợp lệ: $1"
            show_help
            exit 1
            ;;
    esac
done

# Validate và hiển thị thông tin project
print_step "Validate project configuration"

# Validate project name (chỉ cho phép chữ thường, số, và dấu gạch dưới)
if [[ ! "$PROJECT_NAME" =~ ^[a-z][a-z0-9_]*$ ]]; then
    print_error "Tên project không hợp lệ!"
    print_error "Chỉ cho phép chữ thường, số và dấu gạch dưới, bắt đầu bằng chữ cái."
    print_info "Ví dụ hợp lệ: myapp, my_app, app123"
    exit 1
fi
print_substep "Project name: $PROJECT_NAME"

# Nếu không có package name, tự động tạo từ project name
if [ -z "$PACKAGE_NAME" ]; then
    # Chuyển đổi project_name thành package_name (thay _ bằng .)
    PACKAGE_NAME="com.example.$(echo $PROJECT_NAME | tr '_' '.')"
    print_substep "Auto-generated package name: $PACKAGE_NAME"
else
    print_substep "Package name: $PACKAGE_NAME"
fi

# Validate package name
if [[ ! "$PACKAGE_NAME" =~ ^[a-z][a-z0-9_.]*$ ]]; then
    print_error "Package name không hợp lệ!"
    print_error "Chỉ cho phép chữ thường, số, dấu chấm và dấu gạch dưới."
    print_info "Ví dụ hợp lệ: com.example.myapp, com.company.my_app"
    exit 1
fi

# Xác định thư mục output
print_step "Xác định output directory"
if [ -z "$OUTPUT_DIR" ]; then
    # Mặc định: sử dụng thư mục hiện tại
    OUTPUT_DIR="$(pwd)"
    print_substep "Using current directory: $OUTPUT_DIR"
else
    # Tạo thư mục output nếu chưa tồn tại
    if [ ! -d "$OUTPUT_DIR" ]; then
        print_substep "Creating output directory: $OUTPUT_DIR"
        if ! mkdir -p "$OUTPUT_DIR"; then
            print_error "Không thể tạo thư mục output: $OUTPUT_DIR"
            print_error "Kiểm tra quyền truy cập hoặc chọn thư mục khác"
            exit 1
        fi
        print_success "Output directory created"
    fi
    
    # Chuyển đổi thành đường dẫn tuyệt đối chuẩn (resolve . và ..)
    OUTPUT_DIR="$(cd "$OUTPUT_DIR" && pwd)"
    print_substep "Resolved output directory: $OUTPUT_DIR"
fi

# Tạo đường dẫn project mới
NEW_PROJECT_DIR="$OUTPUT_DIR/$PROJECT_NAME"

# Kiểm tra nếu thư mục đã tồn tại
if [ -d "$NEW_PROJECT_DIR" ]; then
    print_error "Thư mục đã tồn tại: $NEW_PROJECT_DIR"
    print_info "Vui lòng chọn tên project khác hoặc xóa thư mục cũ"
    exit 1
fi

# Hiển thị summary
print_separator
echo -e "${BOLD}Project Configuration:${NC}"
echo -e "  ${CYAN}Project Name:${NC}     $PROJECT_NAME"
echo -e "  ${CYAN}Package Name:${NC}    $PACKAGE_NAME"
echo -e "  ${CYAN}Output Dir:${NC}      $OUTPUT_DIR"
echo -e "  ${CYAN}Target Path:${NC}     $NEW_PROJECT_DIR"
echo -e "  ${CYAN}Platforms:${NC}       iOS=$INCLUDE_IOS, Android=$INCLUDE_ANDROID, Web=$INCLUDE_WEB"
echo -e "                    Linux=$INCLUDE_LINUX, Windows=$INCLUDE_WINDOWS, macOS=$INCLUDE_MACOS"
print_separator

# Copy toàn bộ template
print_step "Copy template files"
print_substep "Source: $TEMPLATE_DIR"
print_substep "Destination: $NEW_PROJECT_DIR"
# Tạo thư mục đích trước
mkdir -p "$NEW_PROJECT_DIR"

# Copy các file và thư mục Flutter template
# Chỉ copy các file/thư mục Flutter chuẩn, loại trừ script và các project đã tạo
(
    cd "$TEMPLATE_DIR"
    shopt -s dotglob nullglob
    
    # Danh sách các file/thư mục Flutter chuẩn cần copy
    FLUTTER_ITEMS=(
        "lib" "test" "android" "ios" "web" "linux" "windows" "macos"
        "pubspec.yaml" "analysis_options.yaml" "README.md"
        ".metadata" ".gitignore" ".idea" ".vscode"
    )
    
    # Copy từng item Flutter chuẩn
    for item in "${FLUTTER_ITEMS[@]}"; do
        if [ -e "$item" ]; then
            cp -r "$item" "$NEW_PROJECT_DIR/" 2>/dev/null || true
        fi
    done
    
    # Copy các file dot khác (ngoại trừ các file đã biết và đã copy)
    for item in .*; do
        [[ "$item" == "." ]] && continue
        [[ "$item" == ".." ]] && continue
        [[ "$item" == ".git" ]] && continue
        [[ "$item" == ".dart_tool" ]] && continue
        
        # Kiểm tra xem item đã được copy ở trên chưa
        already_copied=0
        for flutter_item in "${FLUTTER_ITEMS[@]}"; do
            if [[ "$item" == "$flutter_item" ]]; then
                already_copied=1
                break
            fi
        done
        [[ $already_copied -eq 1 ]] && continue
        
        if [ -e "$item" ] && [ ! -e "$NEW_PROJECT_DIR/$item" ]; then
            cp -r "$item" "$NEW_PROJECT_DIR/" 2>/dev/null || true
        fi
    done
)
print_success "Template files copied"

# Xóa các file không cần thiết
cd "$NEW_PROJECT_DIR"
print_step "Cleanup unnecessary files"
rm -f create_flutter_template.sh
rm -rf .git
rm -rf build
rm -rf .dart_tool
print_success "Cleaned up build artifacts"

# Xóa các platform không được chọn
print_step "Remove excluded platforms"
if [ "$INCLUDE_IOS" = false ]; then
    print_substep "Removing iOS platform"
    rm -rf ios
fi

if [ "$INCLUDE_ANDROID" = false ]; then
    print_substep "Removing Android platform"
    rm -rf android
fi

if [ "$INCLUDE_WEB" = false ]; then
    print_substep "Removing Web platform"
    rm -rf web
fi

if [ "$INCLUDE_LINUX" = false ]; then
    print_substep "Removing Linux platform"
    rm -rf linux
fi

if [ "$INCLUDE_WINDOWS" = false ]; then
    print_substep "Removing Windows platform"
    rm -rf windows
fi

if [ "$INCLUDE_MACOS" = false ]; then
    print_substep "Removing macOS platform"
    rm -rf macos
fi
print_success "Platform cleanup completed"

# Các giá trị cần thay thế
OLD_PACKAGE_NAME="com.example.flutter_template"
OLD_PACKAGE_NAME_CAMEL="com.example.flutterTemplate"
OLD_PROJECT_NAME="flutter_template"
OLD_PROJECT_NAME_DISPLAY="Flutter Template"

# Chuyển đổi package name sang camelCase cho iOS/macOS
# Ví dụ: com.example.my_app -> com.example.myApp
PACKAGE_PREFIX=$(echo "$PACKAGE_NAME" | sed 's/\.[^.]*$//')
PACKAGE_SUFFIX=$(echo "$PACKAGE_NAME" | sed 's/.*\.//')
PACKAGE_SUFFIX_CAMEL=$(echo "$PACKAGE_SUFFIX" | sed 's/_\([a-z]\)/\U\1/g' | sed 's/^\([a-z]\)/\U\1/')
PACKAGE_NAME_CAMEL="$PACKAGE_PREFIX.$PACKAGE_SUFFIX_CAMEL"

# Chuyển đổi project name sang display name (Title Case)
PROJECT_NAME_DISPLAY=$(echo "$PROJECT_NAME" | sed 's/_/ /g' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2));}1')

print_step "Update project configuration files"
print_substep "Replacing package and project names..."

# 1. Thay đổi pubspec.yaml
print_substep "Updating pubspec.yaml"
if replace_in_file "pubspec.yaml" "name: $OLD_PROJECT_NAME" "name: $PROJECT_NAME" && \
   replace_in_file "pubspec.yaml" "description: \"A new Flutter project.\"" "description: \"$PROJECT_NAME_DISPLAY\""; then
    print_success "pubspec.yaml updated"
else
    print_warning "Failed to update pubspec.yaml"
fi

# 2. Thay đổi Android files (nếu có)
if [ "$INCLUDE_ANDROID" = true ] && [ -d "android" ]; then
    print_substep "Updating Android configuration"
    # build.gradle.kts
    replace_in_file "android/app/build.gradle.kts" "namespace = \"$OLD_PACKAGE_NAME\"" "namespace = \"$PACKAGE_NAME\""
    replace_in_file "android/app/build.gradle.kts" "applicationId = \"$OLD_PACKAGE_NAME\"" "applicationId = \"$PACKAGE_NAME\""
    
    # AndroidManifest.xml
    replace_in_file "android/app/src/main/AndroidManifest.xml" "android:label=\"$OLD_PROJECT_NAME\"" "android:label=\"$PROJECT_NAME_DISPLAY\""
    
    # MainActivity.kt - thay đổi package và di chuyển file
    OLD_KOTLIN_DIR="android/app/src/main/kotlin/com/example/flutter_template"
    NEW_KOTLIN_DIR="android/app/src/main/kotlin/$(echo $PACKAGE_NAME | tr '.' '/')"
    
    if [ -d "$OLD_KOTLIN_DIR" ]; then
        mkdir -p "$(dirname "$NEW_KOTLIN_DIR")"
        mv "$OLD_KOTLIN_DIR" "$NEW_KOTLIN_DIR"
        
        # Thay đổi package trong MainActivity.kt
        replace_in_file "$NEW_KOTLIN_DIR/MainActivity.kt" "package $OLD_PACKAGE_NAME" "package $PACKAGE_NAME"
        
        # Xóa các thư mục rỗng
        find android/app/src/main/kotlin -type d -empty -delete 2>/dev/null || true
    fi
    print_success "Android configuration updated"
fi

# 3. Thay đổi iOS files (nếu có)
if [ "$INCLUDE_IOS" = true ] && [ -d "ios" ]; then
    print_substep "Updating iOS configuration"
    # Info.plist
    replace_in_file "ios/Runner/Info.plist" "<string>$OLD_PROJECT_NAME_DISPLAY</string>" "<string>$PROJECT_NAME_DISPLAY</string>"
    replace_in_file "ios/Runner/Info.plist" "<string>$OLD_PROJECT_NAME</string>" "<string>$PROJECT_NAME</string>"
    
    # project.pbxproj
    replace_in_file "ios/Runner.xcodeproj/project.pbxproj" "PRODUCT_BUNDLE_IDENTIFIER = $OLD_PACKAGE_NAME_CAMEL;" "PRODUCT_BUNDLE_IDENTIFIER = $PACKAGE_NAME_CAMEL;"
    replace_in_file "ios/Runner.xcodeproj/project.pbxproj" "PRODUCT_BUNDLE_IDENTIFIER = $OLD_PACKAGE_NAME_CAMEL\.RunnerTests;" "PRODUCT_BUNDLE_IDENTIFIER = $PACKAGE_NAME_CAMEL.RunnerTests;"
    print_success "iOS configuration updated"
fi

# 4. Thay đổi macOS files (nếu có)
if [ "$INCLUDE_MACOS" = true ] && [ -d "macos" ]; then
    print_substep "Updating macOS configuration"
    # AppInfo.xcconfig
    replace_in_file "macos/Runner/Configs/AppInfo.xcconfig" "PRODUCT_NAME = $OLD_PROJECT_NAME" "PRODUCT_NAME = $PROJECT_NAME"
    replace_in_file "macos/Runner/Configs/AppInfo.xcconfig" "PRODUCT_BUNDLE_IDENTIFIER = $OLD_PACKAGE_NAME_CAMEL" "PRODUCT_BUNDLE_IDENTIFIER = $PACKAGE_NAME_CAMEL"
    
    # project.pbxproj
    replace_in_file "macos/Runner.xcodeproj/project.pbxproj" "PRODUCT_BUNDLE_IDENTIFIER = $OLD_PACKAGE_NAME_CAMEL;" "PRODUCT_BUNDLE_IDENTIFIER = $PACKAGE_NAME_CAMEL;" 2>/dev/null || true
    print_success "macOS configuration updated"
fi

# 5. Thay đổi Dart files - import statements
print_substep "Updating Dart import statements"
DART_FILES_COUNT=0
while IFS= read -r -d '' file; do
    if replace_in_file "$file" "package:$OLD_PROJECT_NAME" "package:$PROJECT_NAME"; then
        DART_FILES_COUNT=$((DART_FILES_COUNT + 1))
    fi
done < <(find lib -name "*.dart" -type f -print0 2>/dev/null)
while IFS= read -r -d '' file; do
    if replace_in_file "$file" "package:$OLD_PROJECT_NAME" "package:$PROJECT_NAME"; then
        DART_FILES_COUNT=$((DART_FILES_COUNT + 1))
    fi
done < <(find test -name "*.dart" -type f -print0 2>/dev/null)
if [ $DART_FILES_COUNT -gt 0 ]; then
    print_success "Updated $DART_FILES_COUNT Dart file(s)"
fi

# 6. Xóa pubspec.lock để có thể generate lại
rm -f pubspec.lock
print_substep "Removed pubspec.lock (will be regenerated)"

print_success "All configuration files updated"

# Summary và kết thúc
print_separator
print_success "Project created successfully!"
echo ""
echo -e "${BOLD}${GREEN}Project Location:${NC}"
echo -e "  ${CYAN}$NEW_PROJECT_DIR${NC}"
echo ""
echo -e "${BOLD}${YELLOW}Next Steps:${NC}"
echo -e "  ${BOLD}cd${NC} $NEW_PROJECT_DIR"
echo -e "  ${BOLD}flutter pub get${NC}"
echo -e "  ${BOLD}flutter run${NC}"
echo ""
print_separator
