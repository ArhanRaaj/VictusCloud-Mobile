package net.kdt.pojavlaunch;

import androidx.annotation.Keep;

/**
 * Shim for the log sink that libpojavexec.so binds to via JNI.
 * Symbol surface: Java_net_kdt_pojavlaunch_Logger_{appendToLog,begin,setLogListener}
 */
@Keep
public class Logger {
    public static native void appendToLog(String text);

    public static native void begin(String logFilePath);

    @Keep
    public interface eventLogListener {
        void onEventLogged(String text);
    }

    public static native void setLogListener(eventLogListener logListener);
}
