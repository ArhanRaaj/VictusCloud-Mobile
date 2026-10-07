package net.kdt.pojavlaunch;

import androidx.annotation.Keep;

import dalvik.annotation.optimization.CriticalNative;

/**
 * libpojavexec.so probes for this class during JNI_OnLoad to work out whether
 * the runtime supports {@code @CriticalNative} JNI calls (it accelerates the
 * input bridge). The export it looks for is {@code dvm_testCriticalNative}.
 */
@Keep
public class CriticalNativeTest {
    @CriticalNative
    public static native void testCriticalNative();
}
