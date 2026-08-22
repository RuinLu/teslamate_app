allprojects {
    repositories {
        // 🌟 阿里云镜像
        maven { url = uri("https://maven.aliyun.com/repository/google") }         // 代理 google()
        maven { url = uri("https://maven.aliyun.com/repository/central") }       // 代理 mavenCentral()
        maven { url = uri("https://maven.aliyun.com/repository/public") }        // central+jcenter 合集
        maven { url = uri("https://maven.aliyun.com/repository/gradle-plugin") } // 代理插件门户
        google()       // 国内镜像万一缺货，才兜底走官方（基本用不上）
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
