# Hướng dẫn Build Plugin

## Cách 1: Sử dụng Gradle Wrapper (Khuyến nghị)

### Bước 1: Tạo Gradle Wrapper

Nếu chưa có wrapper, tạo bằng cách:

```bash
cd plugin
gradle wrapper --gradle-version 8.3
```

Hoặc nếu đã có IntelliJ IDEA:

1. Mở project trong IntelliJ IDEA
2. Vào `File` → `Settings` → `Build, Execution, Deployment` → `Build Tools` → `Gradle`
3. Chọn `Use Gradle from: 'wrapper' task in build.gradle.kts'`
4. IntelliJ sẽ tự động tạo wrapper

### Bước 2: Build plugin

```bash
./gradlew clean
./gradlew buildPlugin
```

File plugin sẽ ở: `build/distributions/FlutterTemplateCreator-1.0.0.zip`

## Cách 2: Build bằng IntelliJ IDEA

1. Mở project trong IntelliJ IDEA
2. Vào `File` → `Project Structure` → `Project Settings` → `Project`
3. Set SDK: IntelliJ IDEA Plugin SDK (nếu chưa có, tạo mới)
4. Vào `Build` → `Build Project` (Ctrl+F9 / Cmd+F9)
5. Vào `Build` → `Prepare Plugin Module 'plugin' For Deployment`

File plugin sẽ ở: `out/artifacts/plugin/`

## Cách 3: Sử dụng Gradle trực tiếp (nếu đã cài)

```bash
cd plugin
gradle clean buildPlugin
```

## Troubleshooting

### Lỗi: "Unable to load class 'org.gradle.api.publish..."

**Giải pháp:**

1. Clean build:

```bash
./gradlew clean
rm -rf .gradle build
./gradlew buildPlugin
```

2. Hoặc thử version khác trong `build.gradle.kts`:

```kotlin
id("org.jetbrains.intellij") version "1.13.3"
```

3. Hoặc build bằng IntelliJ IDEA (Cách 2 ở trên)

### Lỗi: "Gradle wrapper not found"

**Giải pháp:**

Tạo wrapper:

```bash
gradle wrapper --gradle-version 8.3
```

Hoặc download từ: https://raw.githubusercontent.com/gradle/gradle/master/gradle/wrapper/gradle-wrapper.jar

Đặt vào: `gradle/wrapper/gradle-wrapper.jar`

### Lỗi: Java version không đúng

**Giải pháp:**

```bash
# Kiểm tra Java version
java -version  # Phải là Java 17+

# Set JAVA_HOME nếu cần
export JAVA_HOME=/path/to/java17
```
