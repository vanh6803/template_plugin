# Troubleshooting Build Issues

## Lỗi: "MemoizedProvider overrides final method"

Lỗi này thường xảy ra do xung đột version giữa IntelliJ plugin và Gradle.

### Giải pháp 1: Sử dụng Gradle Wrapper

```bash
cd plugin
./gradlew clean
./gradlew buildPlugin
```

### Giải pháp 2: Downgrade Gradle version

Nếu vẫn lỗi, thử downgrade Gradle trong `gradle/wrapper/gradle-wrapper.properties`:

```properties
distributionUrl=https\://services.gradle.org/distributions/gradle-8.3-bin.zip
```

### Giải pháp 3: Sử dụng version IntelliJ plugin khác

Trong `build.gradle.kts`, thử các version sau:

```kotlin
id("org.jetbrains.intellij") version "1.14.2"  // Version ổn định hơn
// hoặc
id("org.jetbrains.intellij") version "1.13.3"
```

### Giải pháp 4: Clean và rebuild

```bash
cd plugin
rm -rf .gradle build
./gradlew clean buildPlugin
```

### Giải pháp 5: Kiểm tra Java version

Đảm bảo đang sử dụng Java 17:

```bash
java -version  # Phải là Java 17 hoặc cao hơn
```

Nếu không đúng, set JAVA_HOME:

```bash
export JAVA_HOME=/path/to/java17
```

## Lỗi: "Could not resolve dependencies"

### Giải pháp:

```bash
cd plugin
./gradlew --refresh-dependencies buildPlugin
```

## Lỗi: "Plugin descriptor not found"

### Giải pháp:

Kiểm tra file `src/main/resources/META-INF/plugin.xml` có tồn tại và đúng format.

## Build thành công nhưng plugin không hoạt động

1. Kiểm tra IDE version có đúng 2023.1+ không
2. Restart IDE sau khi cài đặt plugin
3. Kiểm tra plugin đã được enable trong Settings → Plugins

## Alternative: Build bằng IntelliJ IDEA

Nếu Gradle command line không hoạt động:

1. Mở project trong IntelliJ IDEA
2. Vào `File` → `Project Structure` → `Project Settings` → `Project`
3. Set SDK: IntelliJ IDEA Plugin SDK
4. Vào `Build` → `Build Project`
5. Vào `Build` → `Prepare Plugin Module 'plugin' For Deployment`

