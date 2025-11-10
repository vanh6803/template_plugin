plugins {
    id("java")
    id("org.jetbrains.kotlin.jvm") version "1.9.25"
    id("org.jetbrains.intellij") version "1.17.3" apply false
}

group = "com.example"
version = "1.0.0"

repositories {
    mavenCentral()
}

// Chỉ apply/config IntelliJ khi không chạy task 'wrapper'
val isWrapperTask = gradle.startParameter.taskNames.any { it.contains("wrapper", ignoreCase = true) }
if (!isWrapperTask) {
    apply(plugin = "org.jetbrains.intellij")
    // Cấu hình extension bằng kiểu rõ ràng để tránh accessor 'intellij' bị unresolved khi compile script
    extensions.configure<org.jetbrains.intellij.IntelliJPluginExtension>("intellij") {
        version.set("2023.1")
        type.set("IC") // IntelliJ IDEA Community (tương thích với Android Studio)
        plugins.set(listOf("org.jetbrains.plugins.terminal"))
        updateSinceUntilBuild.set(false)
    }
}

// Disable publish tasks để tránh lỗi
tasks.configureEach {
    if (name.contains("publish", ignoreCase = true) || 
        name.contains("sign", ignoreCase = true)) {
        enabled = false
    }
}

java {
    sourceCompatibility = JavaVersion.VERSION_17
    targetCompatibility = JavaVersion.VERSION_17
}

tasks {
    withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile> {
        kotlinOptions {
            jvmTarget = "17"
            freeCompilerArgs = listOf("-Xjvm-default=all")
        }
    }
    // Cố định wrapper luôn dùng Gradle 8.7
    named<Wrapper>("wrapper") {
        gradleVersion = "8.7"
        distributionType = Wrapper.DistributionType.BIN
    }
    if (!isWrapperTask) {
        withType<org.jetbrains.intellij.tasks.PatchPluginXmlTask> {
            sinceBuild.set("231")
            untilBuild.set("") // Không giới hạn version, hỗ trợ tất cả version mới hơn
        }
    }
}

dependencies {
    // Không cần thêm kotlin-stdlib vì IntelliJ Platform đã có sẵn
    // implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk8:1.9.22")
}

