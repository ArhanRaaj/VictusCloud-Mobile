#include <dlfcn.h>
#include <android/log.h>
#include <string>
#include <vector>

#define LOG_TAG "MJL_JVM"
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO, LOG_TAG, __VA_ARGS__)
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__)

// Minimal definitions matching the JNI Invocation API so we can dlopen a
// prebuilt libjvm.so (OpenJDK mobile port, Pojav-style) without JNI headers
// from that project.
typedef jint (*JNI_CreateJavaVM_t)(void **pvm, void **penv, void *args);

struct JavaVMOption {
    char *optionString;
    void *extraInfo;
};

struct JavaVMInitArgs {
    jint version;
    jint nOptions;
    JavaVMOption *options;
    jboolean ignoreUnrecognized;
};

extern "C" int mjl_spawn_jvm(
    const char *javaHome, const char *mainClass, const char *classpath,
    const char *const *jvmArgs, int jvmArgCount,
    const char *const *progArgs, int progArgCount,
    const char *workDir) {

    void *handle = dlopen("libjvm.so", RTLD_NOW | RTLD_GLOBAL);
    if (!handle) {
        LOGE("libjvm.so not found: %s — drop the OpenJDK mobile port binary into "
             "src/main/cpp/libs/<abi>/ to enable game execution.", dlerror());
        return -1;
    }

    auto createVM = (JNI_CreateJavaVM_t) dlsym(handle, "JNI_CreateJavaVM");
    if (!createVM) {
        LOGE("JNI_CreateJavaVM missing");
        return -2;
    }

    std::vector<std::string> optStore;
    optStore.emplace_back(std::string("-Djava.home=") + javaHome);
    optStore.emplace_back(std::string("-Djava.class.path=") + classpath);
    optStore.emplace_back("-Xcheck:jni");
    for (int i = 0; i < jvmArgCount; i++) optStore.emplace_back(jvmArgs[i]);

    std::vector<JavaVMOption> options;
    for (auto &s : optStore) options.push_back(JavaVMOption{(char *) s.c_str(), nullptr});

    JavaVMInitArgs args{};
    args.version = JNI_VERSION_1_8; // prebuilt JVM decides the exact spec
    args.nOptions = (jint) options.size();
    args.options = options.data();
    args.ignoreUnrecognized = JNI_TRUE;

    void *vm = nullptr;
    void *env = nullptr;
    jint rc = createVM(&vm, &env, &args);
    if (rc != JNI_OK || !env) {
        LOGE("JVM creation failed rc=%d", rc);
        return -3;
    }

    // Cast through the real JNIEnv* and invoke mainClass.main(progArgs)
    JNIEnv *jni = (JNIEnv *) env;
    jclass cls = jni->FindClass(mainClass);
    if (!cls) {
        LOGE("Main class not found: %s", mainClass);
        return -4;
    }
    jmethodID mid = jni->GetStaticMethodID(cls, "main", "([Ljava/lang/String;)V");
    if (!mid) {
        LOGE("main(String[]) not found");
        return -5;
    }
    jclass strCls = jni->FindClass("java/lang/String");
    jobjectArray arr = jni->NewObjectArray(progArgCount, strCls, nullptr);
    for (int i = 0; i < progArgCount; i++) {
        jstring s = jni->NewStringUTF(progArgs[i]);
        jni->SetObjectArrayElement(arr, i, s);
    }
    LOGI("Invoking %s.main with %d args", mainClass, progArgCount);
    jni->CallStaticVoidMethod(cls, mid, arr);

    if (jni->ExceptionCheck()) {
        jni->ExceptionDescribe();
        jni->ExceptionClear();
        return -6;
    }
    return 0;
}
