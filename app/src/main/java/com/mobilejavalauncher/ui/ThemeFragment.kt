package com.mobilejavalauncher.ui

import android.graphics.Color
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ArrayAdapter
import android.widget.Button
import android.widget.CheckBox
import android.widget.EditText
import android.widget.LinearLayout
import android.widget.SeekBar
import android.widget.Spinner
import android.widget.TextView
import android.widget.Toast
import androidx.fragment.app.Fragment
import com.mobilejavalauncher.R
import com.mobilejavalauncher.theme.LauncherTheme
import com.mobilejavalauncher.theme.ThemeStore

class ThemeFragment : Fragment() {

    private lateinit var store: ThemeStore
    private lateinit var theme: LauncherTheme

    override fun onCreateView(i: LayoutInflater, c: ViewGroup?, s: Bundle?) =
        i.inflate(R.layout.fragment_theme, c, false)

    override fun onViewCreated(v: View, s: Bundle?) {
        store = ThemeStore(requireContext())
        theme = store.load()

        val presetSpinner = v.findViewById<Spinner>(R.id.presetSpinner)
        val accentHex = v.findViewById<EditText>(R.id.accentHex)
        val accentHue = v.findViewById<SeekBar>(R.id.accentHue)
        val backgroundSeek = v.findViewById<SeekBar>(R.id.backgroundSeek)
        val surfaceSeek = v.findViewById<SeekBar>(R.id.surfaceSeek)
        val textSeek = v.findViewById<SeekBar>(R.id.textSeek)
        val cornerSeek = v.findViewById<SeekBar>(R.id.cornerSeek)
        val cornerLabel = v.findViewById<TextView>(R.id.cornerLabel)
        val darkCheck = v.findViewById<CheckBox>(R.id.darkModeCheck)

        presetSpinner.adapter = ArrayAdapter(
            requireContext(), android.R.layout.simple_spinner_dropdown_item,
            ThemeStore.PRESETS.map { it.name }
        )
        presetSpinner.setSelection(ThemeStore.PRESETS.indexOfFirst { it.name == theme.name }
            .coerceAtLeast(0))

        // Range 0..360 maps onto the hue wheel for quick accent picking.
        accentHue.max = 360
        accentHue.progress = hueOf(theme.accent)
        accentHex.setText(store.toHex(theme.accent))
        backgroundSeek.max = 255
        backgroundSeek.progress = Color.red(theme.background)
        surfaceSeek.max = 255
        surfaceSeek.progress = Color.red(theme.surface)
        textSeek.max = 255
        textSeek.progress = Color.red(theme.text)
        cornerSeek.progress = theme.cornerRadius
        cornerLabel.text = "${getString(R.string.theme_corner)}: ${theme.cornerRadius}dp"
        darkCheck.isChecked = theme.darkMode

        presetSpinner.setOnItemSelectedListener(object : android.widget.AdapterView.OnItemSelectedListener {
            override fun onItemSelected(p: android.widget.AdapterView<*>?, view: View?, pos: Int, id: Long) {
                theme = ThemeStore.PRESETS[pos]
                accentHex.setText(store.toHex(theme.accent))
                accentHue.progress = hueOf(theme.accent)
                backgroundSeek.progress = Color.red(theme.background)
                surfaceSeek.progress = Color.red(theme.surface)
                textSeek.progress = Color.red(theme.text)
                cornerSeek.progress = theme.cornerRadius
                darkCheck.isChecked = theme.darkMode
                render(v)
            }
            override fun onNothingSelected(p: android.widget.AdapterView<*>?) {}
        })

        accentHue.setOnSeekBarChangeListener(simple { progress, _ ->
            theme = theme.copy(accent = Color.HSVToColor(floatArrayOf(progress.toFloat(), 0.55f, 0.85f)))
            accentHex.setText(store.toHex(theme.accent))
            render(v)
        })

        backgroundSeek.setOnSeekBarChangeListener(simple { progress, _ ->
            val level = progress.coerceIn(0, 255)
            theme = theme.copy(background = if (theme.darkMode) Color.rgb(level / 8, level / 8, level / 8)
            else Color.rgb(level, level, level))
            render(v)
        })

        surfaceSeek.setOnSeekBarChangeListener(simple { progress, _ ->
            val level = progress.coerceIn(0, 255)
            theme = theme.copy(surface = if (theme.darkMode) Color.rgb(level / 6, level / 6, level / 6)
            else Color.rgb(level, level, level))
            render(v)
        })

        textSeek.setOnSeekBarChangeListener(simple { progress, _ ->
            val level = progress.coerceIn(0, 255)
            theme = theme.copy(text = Color.rgb(level, level, level))
            render(v)
        })

        cornerSeek.setOnSeekBarChangeListener(simple { progress, _ ->
            theme = theme.copy(cornerRadius = progress)
            cornerLabel.text = "${getString(R.string.theme_corner)}: $progress" + "dp"
            render(v)
        })

        darkCheck.setOnCheckedChangeListener { _, checked ->
            theme = theme.copy(darkMode = checked)
            render(v)
        }

        accentHex.setOnFocusChangeListener { _, hasFocus ->
            if (!hasFocus) {
                store.parseHex(accentHex.text.toString())?.let {
                    theme = theme.copy(accent = it)
                    accentHue.progress = hueOf(it)
                    render(v)
                }
            }
        }

        v.findViewById<Button>(R.id.saveThemeButton).setOnClickListener {
            store.save(theme)
            store.applyTo(requireActivity().window.decorView)
            Toast.makeText(context, "Theme saved", Toast.LENGTH_SHORT).show()
        }

        v.findViewById<Button>(R.id.resetThemeButton).setOnClickListener {
            store.reset()
            theme = store.load()
            accentHex.setText(store.toHex(theme.accent))
            accentHue.progress = hueOf(theme.accent)
            render(v)
            Toast.makeText(context, "Theme reset", Toast.LENGTH_SHORT).show()
        }

        render(v)
    }

    /** Repaints the preview card and the editor chrome from the in-memory theme. */
    private fun render(root: View) {
        val card = root.findViewById<LinearLayout>(R.id.previewCard)
        card.background = store.rounded(theme.surface, theme.surface, theme.cornerRadius)
        root.findViewById<TextView>(R.id.previewTitle).setTextColor(theme.text)
        root.findViewById<TextView>(R.id.previewSubtitle).setTextColor(theme.textMuted)
        val button = root.findViewById<Button>(R.id.previewButton)
        button.background = store.rounded(theme.accent, theme.accentSecondary, theme.cornerRadius)
        button.setTextColor(store.contrastOn(theme.accent))
        root.setBackgroundColor(theme.background)
    }

    private fun hueOf(color: Int): Int {
        val hsv = FloatArray(3)
        Color.colorToHSV(color, hsv)
        return hsv[0].toInt().coerceIn(0, 360)
    }

    private fun simple(onChange: (Int, Boolean) -> Unit) = object : SeekBar.OnSeekBarChangeListener {
        override fun onProgressChanged(seekBar: SeekBar?, progress: Int, fromUser: Boolean) =
            onChange(progress, fromUser)
        override fun onStartTrackingTouch(seekBar: SeekBar?) {}
        override fun onStopTrackingTouch(seekBar: SeekBar?) {}
    }
}
