package net.kdt.pojavlaunch;

import android.app.Activity;
import android.os.Bundle;
import android.os.Process;

import androidx.annotation.Keep;

/**
 * libpojavexec.so's exit hook launches this when the JVM ends, so the launcher
 * can shut the process down cleanly instead of leaving a half-dead JVM behind.
 */
@Keep
public class ExitActivity extends Activity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        finishAffinity();
        Process.killProcess(Process.myPid());
        System.exit(0);
    }
}
