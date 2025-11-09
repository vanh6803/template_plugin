package com.example.fluttertemplate

import com.intellij.openapi.project.Project
import com.intellij.openapi.ui.DialogWrapper
import com.intellij.openapi.ui.ValidationInfo
import com.intellij.ui.components.JBCheckBox
import com.intellij.ui.components.JBLabel
import com.intellij.ui.components.JBTextField
import com.intellij.util.ui.FormBuilder
import java.awt.BorderLayout
import java.awt.Dimension
import java.io.BufferedReader
import java.io.File
import java.io.InputStreamReader
import javax.swing.DefaultComboBoxModel
import javax.swing.JComboBox
import javax.swing.JComponent
import javax.swing.JPanel
import com.intellij.openapi.fileChooser.FileChooser
import com.intellij.openapi.fileChooser.FileChooserDescriptorFactory
import com.intellij.openapi.ui.TextFieldWithBrowseButton
import com.intellij.openapi.vfs.VirtualFile

class CreateFlutterProjectDialog(project: Project?) : DialogWrapper(project) {
    private val projectNameField = JBTextField()
    private val packageNameField = JBTextField()
    private val outputDirField = TextFieldWithBrowseButton()
    private val flutterVersionComboBox = JComboBox<String>()
    private val useFvmCheckBox = JBCheckBox("Use FVM (Flutter Version Management)", false)
    
    private val iosCheckBox = JBCheckBox("iOS", true)
    private val androidCheckBox = JBCheckBox("Android", true)
    private val webCheckBox = JBCheckBox("Web", false)
    private val linuxCheckBox = JBCheckBox("Linux", false)
    private val windowsCheckBox = JBCheckBox("Windows", false)
    private val macOSCheckBox = JBCheckBox("macOS", false)
    
    private var availableVersions: List<String> = emptyList()
    
    init {
        title = "Create Flutter Project from Template"
        init()
        
        // Set default values
        val defaultDir = System.getProperty("user.home") + "/Projects"
        outputDirField.text = defaultDir
        
        // Setup browse button for directory selection
        outputDirField.addBrowseFolderListener(
            "Select Output Directory",
            "Chọn thư mục để lưu project mới",
            project,
            FileChooserDescriptorFactory.createSingleFolderDescriptor()
        )
        
        // Setup Flutter version ComboBox
        flutterVersionComboBox.isEditable = true
        flutterVersionComboBox.toolTipText = "Chọn hoặc nhập Flutter version (ví dụ: 3.24.0)"
        
        // Auto-generate package name when project name changes
        projectNameField.document.addDocumentListener(object : javax.swing.event.DocumentListener {
            override fun insertUpdate(e: javax.swing.event.DocumentEvent?) = updatePackageName()
            override fun removeUpdate(e: javax.swing.event.DocumentEvent?) = updatePackageName()
            override fun changedUpdate(e: javax.swing.event.DocumentEvent?) = updatePackageName()
        })
        
        // Check if FVM is available and load versions
        val fvmAvailable = checkFvmAvailable()
        useFvmCheckBox.isEnabled = fvmAvailable
        if (!fvmAvailable) {
            useFvmCheckBox.toolTipText = "FVM chưa được cài đặt. Cài đặt: dart pub global activate fvm"
        }
        
        // Load Flutter versions (start with system version if FVM not available)
        loadFlutterVersions(fvmAvailable && useFvmCheckBox.isSelected)
        
        // Reload versions when FVM checkbox changes
        useFvmCheckBox.addActionListener {
            if (useFvmCheckBox.isSelected) {
                // Reload versions from FVM when FVM is selected
                loadFlutterVersions(true)
            } else {
                // Load system versions when FVM is deselected
                loadFlutterVersions(false)
            }
        }
        
        // ComboBox is always enabled (user can type custom version)
        flutterVersionComboBox.isEnabled = true
    }
    
    private fun checkFvmAvailable(): Boolean {
        return try {
            val process = ProcessBuilder("fvm", "--version").start()
            process.waitFor() == 0
        } catch (e: Exception) {
            false
        }
    }
    
    private fun getCurrentFlutterVersion(): String? {
        return try {
            val process = ProcessBuilder("flutter", "--version").start()
            val reader = BufferedReader(InputStreamReader(process.inputStream))
            val firstLine = reader.readLine()
            reader.close()
            process.waitFor()
            // Extract version from first line: "Flutter 3.24.0 • channel stable..."
            firstLine?.let { line ->
                val match = Regex("Flutter\\s+([0-9]+\\.[0-9]+\\.[0-9]+)").find(line)
                match?.groupValues?.get(1)
            }
        } catch (e: Exception) {
            null
        }
    }
    
    private fun loadFlutterVersions(useFvm: Boolean) {
        val versions = mutableSetOf<String>()
        val currentVersion = getCurrentFlutterVersion()
        
        if (useFvm && checkFvmAvailable()) {
            // Load installed versions from FVM
            try {
                val listProcess = ProcessBuilder("fvm", "list").start()
                val listReader = BufferedReader(InputStreamReader(listProcess.inputStream))
                var line: String?
                while (listReader.readLine().also { line = it } != null) {
                    line?.let { l ->
                        // Parse FVM list output: "3.24.0 (global)"
                        val match = Regex("([0-9]+\\.[0-9]+\\.[0-9]+)").find(l)
                        match?.let { m ->
                            versions.add(m.groupValues[1])
                        }
                    }
                }
                listReader.close()
                listProcess.waitFor()
            } catch (e: Exception) {
                // Ignore errors
            }
            
            // Also check FVM cache directory
            try {
                val fvmCacheDir = File(System.getProperty("user.home"), ".fvm/versions")
                if (fvmCacheDir.exists() && fvmCacheDir.isDirectory) {
                    fvmCacheDir.listFiles()?.forEach { versionDir ->
                        if (versionDir.isDirectory) {
                            val versionName = versionDir.name
                            if (versionName.matches(Regex("^[0-9]+\\.[0-9]+\\.[0-9]+"))) {
                                versions.add(versionName)
                            }
                        }
                    }
                }
            } catch (e: Exception) {
                // Ignore errors
            }
            
            // Load available releases from FVM (optional, can be slow)
            try {
                val releasesProcess = ProcessBuilder("fvm", "releases").start()
                val releasesReader = BufferedReader(InputStreamReader(releasesProcess.inputStream))
                var line: String?
                var count = 0
                // Limit to first 50 releases to avoid slow loading
                while (releasesReader.readLine().also { line = it } != null && count < 50) {
                    line?.let { l ->
                        val match = Regex("^\\s*([0-9]+\\.[0-9]+\\.[0-9]+)").find(l)
                        match?.let { m ->
                            versions.add(m.groupValues[1])
                            count++
                        }
                    }
                }
                releasesReader.close()
                releasesProcess.destroy() // Kill process early if we have enough
            } catch (e: Exception) {
                // Ignore errors - releases command might be slow
            }
        } else {
            // Load system Flutter version
            currentVersion?.let { versions.add(it) }
            
            // Also check system Flutter SDK directory if available
            try {
                val flutterProcess = ProcessBuilder("which", "flutter").start()
                val flutterReader = BufferedReader(InputStreamReader(flutterProcess.inputStream))
                val flutterPath = flutterReader.readLine()
                flutterReader.close()
                flutterProcess.waitFor()
                
                flutterPath?.let { path ->
                    val flutterDir = File(path).parentFile?.parentFile
                    flutterDir?.let { dir ->
                        // Check if there's a version file
                        val versionFile = File(dir, "version")
                        if (versionFile.exists()) {
                            val version = versionFile.readText().trim()
                            if (version.matches(Regex("^[0-9]+\\.[0-9]+\\.[0-9]+"))) {
                                versions.add(version)
                            }
                        }
                    }
                }
            } catch (e: Exception) {
                // Ignore errors
            }
        }
        
        // Convert to sorted list (newest first)
        val sortedVersions = versions.sortedWith(compareByDescending { version ->
            try {
                val parts = version.split(".")
                if (parts.size == 3) {
                    parts[0].toInt() * 1000000 + parts[1].toInt() * 1000 + parts[2].toInt()
                } else {
                    0
                }
            } catch (e: Exception) {
                0
            }
        })
        
        availableVersions = sortedVersions
        
        // Update ComboBox model
        val model = DefaultComboBoxModel<String>()
        if (sortedVersions.isEmpty()) {
            model.addElement("")
        } else {
            sortedVersions.forEach { model.addElement(it) }
        }
        flutterVersionComboBox.model = model
        
        // Set current version as selected if available
        currentVersion?.let {
            if (it in sortedVersions) {
                flutterVersionComboBox.selectedItem = it
            } else if (sortedVersions.isNotEmpty()) {
                flutterVersionComboBox.selectedIndex = 0
            }
        }
    }
    
    private fun updatePackageName() {
        val projectName = projectNameField.text.trim()
        if (projectName.isNotEmpty() && packageNameField.text.isEmpty()) {
            val packageName = "com.example.${projectName.replace("_", ".")}"
            packageNameField.text = packageName
        }
    }
    
    override fun createCenterPanel(): JComponent {
        val panel = JPanel(BorderLayout())
        
        val formPanel = FormBuilder.createFormBuilder()
            .addLabeledComponent(JBLabel("Project Name:"), projectNameField, 1, false)
            .addLabeledComponent(JBLabel("Package Name:"), packageNameField, 1, false)
            .addLabeledComponent(JBLabel("Output Directory:"), outputDirField, 1, false)
            .addSeparator()
            .addLabeledComponent(JBLabel("Flutter Version:"), createFlutterVersionPanel(), 1, false)
            .addSeparator()
            .addLabeledComponent(JBLabel("Platforms:"), createPlatformsPanel(), 1, false)
            .addComponentFillVertically(JPanel(), 0)
            .panel
        
        panel.add(formPanel, BorderLayout.CENTER)
        panel.preferredSize = Dimension(500, 400)
        
        return panel
    }
    
    private fun createFlutterVersionPanel(): JPanel {
        val panel = JPanel(BorderLayout())
        val versionPanel = JPanel()
        versionPanel.layout = java.awt.FlowLayout(java.awt.FlowLayout.LEFT)
        flutterVersionComboBox.preferredSize = Dimension(200, flutterVersionComboBox.preferredSize.height)
        versionPanel.add(flutterVersionComboBox)
        versionPanel.add(useFvmCheckBox)
        panel.add(versionPanel, BorderLayout.WEST)
        return panel
    }
    
    private fun createPlatformsPanel(): JPanel {
        val panel = JPanel()
        panel.layout = java.awt.FlowLayout(java.awt.FlowLayout.LEFT)
        panel.add(iosCheckBox)
        panel.add(androidCheckBox)
        panel.add(webCheckBox)
        panel.add(linuxCheckBox)
        panel.add(windowsCheckBox)
        panel.add(macOSCheckBox)
        return panel
    }
    
    override fun doValidate(): ValidationInfo? {
        val projectName = projectNameField.text.trim()
        if (projectName.isEmpty()) {
            return ValidationInfo("Project name không được để trống", projectNameField)
        }
        
        if (!projectName.matches(Regex("^[a-z][a-z0-9_]*$"))) {
            return ValidationInfo(
                "Project name chỉ cho phép chữ thường, số và dấu gạch dưới, bắt đầu bằng chữ cái",
                projectNameField
            )
        }
        
        val packageName = packageNameField.text.trim()
        if (packageName.isNotEmpty() && !packageName.matches(Regex("^[a-z][a-z0-9_.]*$"))) {
            return ValidationInfo(
                "Package name chỉ cho phép chữ thường, số, dấu chấm và dấu gạch dưới",
                packageNameField
            )
        }
        
        val outputDir = outputDirField.text.trim()
        if (outputDir.isNotEmpty()) {
            val dir = java.io.File(outputDir)
            if (!dir.exists() && !dir.mkdirs()) {
                return ValidationInfo("Không thể tạo thư mục output", outputDirField)
            }
        }
        
        if (!iosCheckBox.isSelected && !androidCheckBox.isSelected && 
            !webCheckBox.isSelected && !linuxCheckBox.isSelected && 
            !windowsCheckBox.isSelected && !macOSCheckBox.isSelected) {
            return ValidationInfo("Phải chọn ít nhất một platform")
        }
        
        return null
    }
    
    fun getConfiguration(): ProjectConfig {
        val projectName = projectNameField.text.trim()
        val packageName = packageNameField.text.trim()
        val outputDir = outputDirField.text.trim()
        val flutterVersion = (flutterVersionComboBox.selectedItem as? String)?.trim() ?: ""
        val useFvm = useFvmCheckBox.isSelected
        
        return ProjectConfig(
            projectName = projectName,
            packageName = packageName,
            outputDir = outputDir.ifEmpty { System.getProperty("user.dir") ?: "" },
            flutterVersion = flutterVersion.ifEmpty { null },
            useFvm = useFvm,
            includeIOS = iosCheckBox.isSelected,
            includeAndroid = androidCheckBox.isSelected,
            includeWeb = webCheckBox.isSelected,
            includeLinux = linuxCheckBox.isSelected,
            includeWindows = windowsCheckBox.isSelected,
            includeMacOS = macOSCheckBox.isSelected
        )
    }
}

