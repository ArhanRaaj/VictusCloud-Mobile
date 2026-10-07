package com.mobilejavalauncher.ui

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ArrayAdapter
import android.widget.Button
import android.widget.ProgressBar
import android.widget.Spinner
import android.widget.TextView
import android.widget.Toast
import androidx.fragment.app.Fragment
import androidx.lifecycle.lifecycleScope
import com.mobilejavalauncher.LauncherApp
import com.mobilejavalauncher.MainActivity
import com.mobilejavalauncher.R
import com.mobilejavalauncher.account.AccountStore
import com.mobilejavalauncher.install.VersionInstaller
import com.mobilejavalauncher.model.LaunchProfile
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.io.File

class HomeFragment : Fragment() {
    private lateinit var installer: VersionInstaller
    private lateinit var accounts: AccountStore

    override fun onCreateView(i: LayoutInflater, c: ViewGroup?, s: Bundle?) =
        i.inflate(R.layout.fragment_home, c, false)

    override fun onViewCreated(v: View, s: Bundle?) {
        val app = requireActivity().application as LauncherApp
        installer = VersionInstaller(app)
        accounts = AccountStore(requireContext())

        val spinner = v.findViewById<Spinner>(R.id.versionSpinner)
        val play = v.findViewById<Button>(R.id.playButton)
        val progress = v.findViewById<ProgressBar>(R.id.progress)
        val status = v.findViewById<TextView>(R.id.statusText)
        val apkBtn = v.findViewById<Button>(R.id.installApkButton)

        v.findViewById<TextView>(R.id.currentAccount).text =
            "Account: ${accounts.current()?.name ?: "none"}"

        lifecycleScope.launch {
            status.text = "Loading version manifest…"
            runCatching {
                val manifest = withContext(Dispatchers.IO) { installer.fetchManifest() }
                val releases = manifest.versions.filter { it.type == "release" }.map { it.id }
                spinner.adapter = ArrayAdapter(requireContext(), android.R.layout.simple_spinner_dropdown_item, releases)
                status.text = "Ready. Latest: ${manifest.latest.release}"
            }.onFailure { status.text = "Manifest error: ${it.message}" }
        }

        play.setOnClickListener {
            val version = spinner.selectedItem as? String ?: return@setOnClickListener
            val account = accounts.current() ?: run {
                Toast.makeText(context, "Add an account first", Toast.LENGTH_SHORT).show()
                return@setOnClickListener
            }
            lifecycleScope.launch {
                play.isEnabled = false
                progress.visibility = View.VISIBLE
                try {
                    val versionJson = withContext(Dispatchers.IO) {
                        installer.install(version) { label, d, t ->
                            requireActivity().runOnUiThread {
                                status.text = "Downloading $label"
                                if (t > 0) progress.progress = (d * 100 / t).toInt()
                            }
                        }
                        File(app.versionsDir, "$version/$version.json")
                    }
                    startActivity(
                        Intent(requireContext(), com.mobilejavalauncher.GameActivity::class.java)
                            .putExtra(com.mobilejavalauncher.GameActivity.EXTRA_VERSION, version)
                    )
                } catch (e: Exception) {
                    status.text = "Error: ${e.message}"
                } finally {
                    progress.visibility = View.GONE
                    play.isEnabled = true
                }
            }
        }

        apkBtn.setOnClickListener { pickApk.launch("*/*") }
    }

    private val pickApk = registerForActivityResult(
        androidx.activity.result.contract.ActivityResultContracts.GetContent()
    ) { uri: Uri? ->
        if (uri == null) return@registerForActivityResult
        runCatching {
            val intent = Intent(Intent.ACTION_INSTALL_PACKAGE).apply {
                setDataAndType(uri, "application/vnd.android.package-archive")
                addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            }
            startActivity(intent)
        }.onFailure {
            // Fallback: copy then stream-install via FileProvider
            val dst = File(requireContext().cacheDir, "incoming.apk")
            requireContext().contentResolver.openInputStream(uri)!!.use { inp ->
                dst.outputStream().use { inp.copyTo(it) }
            }
            val shared = androidx.core.content.FileProvider.getUriForFile(
                requireContext(), "${requireContext().packageName}.fileprovider", dst
            )
            val intent = Intent(Intent.ACTION_INSTALL_PACKAGE).apply {
                setDataAndType(shared, "application/vnd.android.package-archive")
                addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            }
            startActivity(intent)
        }
    }
}
