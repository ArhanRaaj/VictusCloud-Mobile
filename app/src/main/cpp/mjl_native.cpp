#include <jni.h>
#include <android/log.h>
#include <string>
#include <vector>

#define LOG_TAG "MJL_Native"
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO, LOG_TAG, __VA_ARGS__)
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__)

// Entry declared in jvm_launcher.cpp — spawns a JVM in-process using a
// prebuilt libjvm.so (Pojav-style OpenJDK mobile port) and invokes mainClass.
extern "C" int mjl_spawn_jvm(
    const char *javaHome,
    const char *mainClass,
    const char *classpath,
    const char *const *jvmArgs, int jvmArgCount,
    const char *const *progArgs, int progArgCount,
    const char *workDir);

extern "C" JNIEXPORT jint JNICALL
Java_com_mobilejavalauncher_game_GameLauncher_launchGame(
        JNIEnv *env, jobject /*thiz*/,
        jstring javaHome, jstring mainClass, jstring classpath,
        jobjectArray jvmArgs, jobjectArray gameArgs,
        jstring workDir) {

    auto toC = [&](jstring s) -> std::string {
        if (!s) return "";
        const char *p = env->GetStringUTFChars(s, nullptr);
        std::string out(p);
        env->ReleaseStringUTFChars(s, p);
        return out;
    };

    std::string javaHomeS = toC(javaHome);
    std::string mainClassS = toC(mainClass);
    std::string classpathS = toC(classpath);
    std::string workDirS = toC(workDir);

    std::vector<std::string> jvmStore;
    int jvmCount = env->GetArrayLength(jvmArgs);
    for (int i = 0; i < jvmCount; i++) {
        jstring s = (jstring) env->GetObjectArrayElement(jvmArgs, i);
        jvmStore.push_back(toC(s));
    }

    std::vector<std::string> progStore;
    int progCount = env->GetArrayLength(gameArgs);
    for (int i = 0; i < progCount; i++) {
        jstring s = (jstring) env->GetObjectArrayElement(gameArgs, i);
        progStore.push_back(toC(s));
    }

    std::vector<const char *> jvmPtrs;
    for (auto &s : jvmStore) jvmPtrs.push_back(s.c_str());
    std::vector<const char *> progPtrs;
    for (auto &s : progStore) progPtrs.push_back(s.c_str());

    LOGI("Spawning JVM: main=%s cp=%s", mainClassS.c_str(), classpathS.c_str());

    return mjl_spawn_jvm(
        javaHomeS.c_str(), mainClassS.c_str(), classpathS.c_str(),
        jvmPtrs.data(), (int) jvmPtrs.size(),
        progPtrs.data(), (int) progPtrs.size(),
        workDirS.c_str());
}
