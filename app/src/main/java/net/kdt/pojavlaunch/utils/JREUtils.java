package net.kdt.pojavlaunch.utils;

import android.content.Context;
import android.view.Surface;

import androidx.annotation.Keep;

import java.io.File;
import java.util.ArrayList;

/**
 * Shim class for the native helpers exported by libpojavexec.so /
 * libpojavexec_awt.so. The package and method names must match exactly, because
 * the shared libraries resolve them through JNI by name.
 */
@Keep
public class JREUtils {
    private JREUtils() {}

    public static String LD_LIBRARY_PATH;
    public static String jvmLibraryPath;

    /** dlopen a library by absolute path or by name resolved through LD_LIBRARY_PATH. */
    public static native boolean dlopen(String libPath);

    public static native void setLdLibraryPath(String ldLibraryPath);

    public static native int chdir(String path);

    /** Hands the Android Surface to the GLFW stub inside liblwjgl.so. */
    public static native void setupBridgeWindow(Object surface);

    public static native void releaseBridgeWindow();

    public static native void setupBridgeSurfaceAWT(Surface surface);

    /** Installs the linker/exit hooks that keep the JVM from killing the app. */
    public static native void initializeHooks();

    public static native void setupExitMethod(Context context);

    /** Reads the AWT software framebuffer, used by caciocavallo-based AWT. */
    public static native int[] renderAWTScreenFrame();

    /** Resolves a library name against LD_LIBRARY_PATH, mirroring Pojav's helper. */
    public static String findInLdLibPath(String libName) {
        String ldPath = System.getenv("LD_LIBRARY_PATH");
        if (ldPath == null) return libName;
        for (String dir : ldPath.split(":")) {
            if (dir.isEmpty()) continue;
            File candidate = new File(dir, libName);
            if (candidate.exists() && candidate.isFile()) return candidate.getAbsolutePath();
        }
        return libName;
    }

    /** Walks a directory tree collecting every .so file found. */
    public static ArrayList<File> locateLibs(File path) {
        ArrayList<File> found = new ArrayList<>();
        File[] list = path.listFiles();
        if (list == null) return found;
        for (File f : list) {
            if (f.isFile() && f.getName().endsWith(".so")) found.add(f);
            else if (f.isDirectory()) found.addAll(locateLibs(f));
        }
        return found;
    }

    /**
     * Preloads the JRE's own libs plus OpenAL the way PojavLauncher does, so that
     * later lazy loads inside libjvm.so resolve against already-mapped libraries.
     */
    public static void initJavaRuntime(String jreHome, String nativeLibDir, String jreLibDir) {
        dlopen(findInLdLibPath("libjli.so"));
        if (!dlopen("libjvm.so")) {
            // Not on the default search path yet; use the absolute JRE location.
            dlopen(jvmLibraryPath + "/libjvm.so");
        }
        dlopen(findInLdLibPath("libverify.so"));
        dlopen(findInLdLibPath("libjava.so"));
        dlopen(findInLdLibPath("libnet.so"));
        dlopen(findInLdLibPath("libnio.so"));
        dlopen(findInLdLibPath("libawt.so"));
        dlopen(findInLdLibPath("libawt_headless.so"));
        dlopen(findInLdLibPath("libfreetype.so"));
        dlopen(findInLdLibPath("libfontmanager.so"));
        for (File f : locateLibs(new File(jreHome, jreLibDir))) {
            dlopen(f.getAbsolutePath());
        }
        dlopen(nativeLibDir + "/libopenal.so");
    }

    static {
        System.loadLibrary("exithook");
        System.loadLibrary("pojavexec");
        System.loadLibrary("pojavexec_awt");
    }
}
