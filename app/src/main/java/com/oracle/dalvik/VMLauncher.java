package com.oracle.dalvik;

import androidx.annotation.Keep;

/**
 * Shim for PojavLauncher's in-process JVM spawner.
 * libpojavexec.so exports Java_com_oracle_dalvik_VMLauncher_launchJVM and creates
 * the JVM inside the current process, then calls main() with {@code args}.
 */
@Keep
public class VMLauncher {
    /** @param args argv, where args[0] is the program name ("java"). */
    public static native int launchJVM(String[] args);
}
