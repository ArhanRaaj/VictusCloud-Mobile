package com.mobilejavalauncher.ui

import android.content.Context
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ArrayAdapter
import android.widget.Button
import android.widget.EditText
import android.widget.Spinner
import android.widget.Toast
import androidx.fragment.app.Fragment
import com.mobilejavalauncher.R

class SettingsFragment : Fragment() {
    override fun onCreateView(i: LayoutInflater, c: ViewGroup?, s: Bundle?) =
        i.inflate(R.layout.fragment_settings, c, false)

    override fun onViewCreated(v: View, s: Bundle?) {
        val prefs = requireContext().getSharedPreferences("mjl_settings", Context.MODE_PRIVATE)
        val mem = v.findViewById<EditText>(R.id.memInput)
        val jvm = v.findViewById<EditText>(R.id.jvmArgsInput)
        val renderer = v.findViewById<Spinner>(R.id.rendererSpinner)

        renderer.adapter = ArrayAdapter(
            requireContext(), android.R.layout.simple_spinner_dropdown_item,
            listOf("opengles2", "opengles3", "opengles3_ltw", "vulkan_zink")
        )

        mem.setText(prefs.getInt("memory_mb", 2048).toString())
        jvm.setText(prefs.getString("jvm_args", "-XX:+UseG1GC"))
        renderer.setSelection(prefs.getInt("renderer_idx", 0))

        v.findViewById<Button>(R.id.themeEditorButton).setOnClickListener {
            startActivity(android.content.Intent(requireContext(), ThemeActivity::class.java))
        }

        val crashText = v.findViewById<android.widget.TextView>(R.id.crashText)
        val lastCrash = com.mobilejavalauncher.CrashLogger.lastCrash(requireContext())
        crashText.text = lastCrash.ifBlank { "No crash recorded" }

        v.findViewById<Button>(R.id.clearCrashButton).setOnClickListener {
            com.mobilejavalauncher.CrashLogger.clear(requireContext())
            crashText.text = "No crash recorded"
        }

        v.findViewById<Button>(R.id.saveSettingsButton).setOnClickListener {
            prefs.edit()
                .putInt("memory_mb", mem.text.toString().toIntOrNull() ?: 2048)
                .putString("jvm_args", jvm.text.toString())
                .putInt("renderer_idx", renderer.selectedItemPosition)
                .apply()
            Toast.makeText(context, "Settings saved", Toast.LENGTH_SHORT).show()
        }
    }
}
