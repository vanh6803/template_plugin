package com.example.fluttertemplate

import com.intellij.openapi.actionSystem.AnAction
import com.intellij.openapi.actionSystem.AnActionEvent
import com.intellij.openapi.project.Project
import com.intellij.openapi.project.ProjectManager
import com.intellij.openapi.ui.Messages
import com.intellij.openapi.vfs.LocalFileSystem
import com.intellij.openapi.vfs.VirtualFileManager
import com.intellij.platform.PlatformProjectOpenProcessor
import java.io.File
import java.nio.file.Paths

class CreateFlutterProjectAction : AnAction() {
    override fun actionPerformed(e: AnActionEvent) {
        val project = e.project
        val dialog = CreateFlutterProjectDialog(project)
        
        if (dialog.showAndGet()) {
            val config = dialog.getConfiguration()
            createFlutterProject(project, config)
        }
    }

    fun createFlutterProject(project: Project?, config: ProjectConfig) {
        try {
            // Tìm script create_flutter_template.sh
            val scriptPath = findScriptPath()
            if (scriptPath == null || !File(scriptPath).exists()) {
                Messages.showErrorDialog(
                    project,
                    "Không tìm thấy script create_flutter_template.sh\n\n" +
                    "Vui lòng đảm bảo script có trong plugin directory hoặc cấu hình đường dẫn.",
                    "Error"
                )
                return
            }

            // Build command
            val command = buildCommand(scriptPath, config)
            
            // Execute command
            val processBuilder = ProcessBuilder(*command)
            processBuilder.directory(File(config.outputDir))
            processBuilder.redirectErrorStream(true)
            
            val process = processBuilder.start()
            val output = process.inputStream.bufferedReader().readText()
            
            val exitCode = process.waitFor()
            
            if (exitCode == 0) {
                val projectPath = File(config.outputDir, config.projectName)
                val projectPathString = projectPath.absolutePath
                
                // Refresh file system để đảm bảo IDE nhận diện được project mới
                VirtualFileManager.getInstance().refreshWithoutFileWatcher(true)
                
                // Đợi một chút để file system được refresh hoàn toàn
                Thread.sleep(500)
                
                // Hỏi user có muốn mở project không
                val openProject = Messages.showYesNoDialog(
                    project,
                    "Project đã được tạo thành công tại:\n$projectPathString\n\nBạn có muốn mở project này ngay bây giờ?",
                    "Project Created Successfully",
                    Messages.getQuestionIcon()
                )
                
                if (openProject == Messages.YES) {
                    openProjectInIDE(projectPathString)
                } else {
                    Messages.showInfoMessage(
                        project,
                        "Project đã được tạo thành công tại:\n$projectPathString\n\nBạn có thể mở project sau bằng cách: File → Open → $projectPathString",
                        "Success"
                    )
                }
            } else {
                Messages.showErrorDialog(
                    project,
                    "Lỗi khi tạo project:\n$output",
                    "Error"
                )
            }
        } catch (e: Exception) {
            Messages.showErrorDialog(
                project,
                "Lỗi: ${e.message}",
                "Error"
            )
        }
    }

    private fun findScriptPath(): String? {
        // Tìm script trong plugin resources và extract nếu cần
        val tempDir = File(System.getProperty("java.io.tmpdir"), "flutter_template_creator")
        tempDir.mkdirs()
        val extractedScript = File(tempDir, "create_flutter_template.sh")
        
        val pluginResource = javaClass.classLoader.getResource("create_flutter_template.sh")
        if (pluginResource != null) {
            try {
                // Extract script từ jar nếu chưa có hoặc đã cũ
                if (!extractedScript.exists() || 
                    extractedScript.lastModified() < System.currentTimeMillis() - 86400000) { // 24h
                    pluginResource.openStream().use { input ->
                        extractedScript.outputStream().use { output ->
                            input.copyTo(output)
                        }
                    }
                    extractedScript.setExecutable(true)
                }
                if (extractedScript.exists() && extractedScript.canExecute()) {
                    return extractedScript.absolutePath
                }
            } catch (e: Exception) {
                // Fall through to other methods
            }
        }
        
        // Tìm trong user home
        val homeScript = File(System.getProperty("user.home"), 
            "Personal/template_plugin/create_flutter_template.sh")
        if (homeScript.exists()) return homeScript.absolutePath
        
        // Tìm trong PATH
        val pathScript = "create_flutter_template.sh"
        val pathDirs = System.getenv("PATH")?.split(":") ?: emptyList()
        for (dir in pathDirs) {
            val script = File(dir, pathScript)
            if (script.exists() && script.canExecute()) {
                return script.absolutePath
            }
        }
        
        return null
    }

    private fun buildCommand(scriptPath: String, config: ProjectConfig): Array<String> {
        val command = mutableListOf("bash", scriptPath, config.projectName)
        
        if (config.packageName.isNotEmpty()) {
            command.add("--packagename=${config.packageName}")
        }
        
        if (config.outputDir.isNotEmpty()) {
            command.add("--output=${config.outputDir}")
        }
        
        if (!config.includeIOS) command.add("--no-ios")
        if (!config.includeAndroid) command.add("--no-android")
        if (config.includeWeb) command.add("--web")
        if (config.includeLinux) command.add("--linux")
        if (config.includeWindows) command.add("--windows")
        if (config.includeMacOS) command.add("--macos")
        
        // Add Flutter version options
        if (config.useFvm) {
            val version = config.flutterVersion
            if (version != null && version.isNotEmpty()) {
                command.add("--fvm=$version")
            } else {
                command.add("--fvm")
            }
        } else {
            val version = config.flutterVersion
            if (version != null && version.isNotEmpty()) {
                command.add("--flutter-version=$version")
            }
        }
        
        return command.toTypedArray()
    }
    
    private fun openProjectInIDE(projectPath: String) {
        try {
            val projectDir = Paths.get(projectPath).toFile()
            if (!projectDir.exists()) {
                Messages.showErrorDialog(
                    null as Project?,
                    "Không tìm thấy project tại: $projectPath",
                    "Error"
                )
                return
            }
            
            // Convert Path to VirtualFile (sử dụng đường dẫn tuyệt đối)
            val normalizedPath = File(projectPath).canonicalPath
            val virtualFile = LocalFileSystem.getInstance().refreshAndFindFileByPath(normalizedPath)
            if (virtualFile == null || !virtualFile.exists()) {
                // Thử lại với đường dẫn gốc nếu canonical path không hoạt động
                val fallbackFile = LocalFileSystem.getInstance().refreshAndFindFileByPath(projectPath)
                if (fallbackFile == null || !fallbackFile.exists()) {
                    Messages.showErrorDialog(
                        null as Project?,
                        "Không thể truy cập project tại: $projectPath\n\nVui lòng mở project thủ công: File → Open → $projectPath",
                        "Error"
                    )
                    return
                }
                // Sử dụng fallback file
                openProjectFile(fallbackFile)
                return
            }
            
            openProjectFile(virtualFile)
        } catch (e: Exception) {
            Messages.showErrorDialog(
                null as Project?,
                "Không thể mở project: ${e.message}\n\nProject đã được tạo tại: $projectPath\nBạn có thể mở thủ công: File → Open → $projectPath",
                "Error Opening Project"
            )
        }
    }
    
    private fun openProjectFile(virtualFile: com.intellij.openapi.vfs.VirtualFile) {
        try {
            // Sử dụng PlatformProjectOpenProcessor để mở project
            val processor = PlatformProjectOpenProcessor()
            
            // Nếu đang có project mở, hỏi có muốn mở trong window mới không
            val currentProject = ProjectManager.getInstance().openProjects.firstOrNull()
            if (currentProject != null) {
                val choice = Messages.showYesNoCancelDialog(
                    currentProject,
                    "Bạn muốn mở project mới như thế nào?\n\n" +
                    "• Yes: Mở trong window mới\n" +
                    "• No: Đóng project hiện tại và mở project mới\n" +
                    "• Cancel: Hủy",
                    "Open Project",
                    "New Window",
                    "Replace",
                    "Cancel",
                    Messages.getQuestionIcon()
                )
                
                when (choice) {
                    Messages.YES -> {
                        // Mở trong window mới
                        processor.doOpenProject(virtualFile, currentProject, true)
                    }
                    Messages.NO -> {
                        // Đóng project hiện tại và mở project mới
                        ProjectManager.getInstance().closeProject(currentProject)
                        processor.doOpenProject(virtualFile, null, false)
                    }
                    Messages.CANCEL -> {
                        // Hủy - không làm gì
                        return
                    }
                }
            } else {
                // Không có project nào đang mở, mở project mới
                processor.doOpenProject(virtualFile, null, false)
            }
        } catch (e: Exception) {
            Messages.showErrorDialog(
                null as Project?,
                "Không thể mở project: ${e.message}",
                "Error Opening Project"
            )
        }
    }
}

data class ProjectConfig(
    val projectName: String,
    val packageName: String,
    val outputDir: String,
    val flutterVersion: String? = null,
    val useFvm: Boolean = false,
    val includeIOS: Boolean = true,
    val includeAndroid: Boolean = true,
    val includeWeb: Boolean = false,
    val includeLinux: Boolean = false,
    val includeWindows: Boolean = false,
    val includeMacOS: Boolean = false
)

