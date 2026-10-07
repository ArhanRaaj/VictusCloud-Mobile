package com.mobilejavalauncher.ui

import android.graphics.Bitmap
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Button
import android.widget.ImageView
import android.widget.Toast
import androidx.fragment.app.Fragment
import androidx.lifecycle.lifecycleScope
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.mobilejavalauncher.R
import com.mobilejavalauncher.account.AccountStore
import com.mobilejavalauncher.skins.SkinManager
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.io.File

class SkinsFragment : Fragment() {
    private lateinit var skins: SkinManager
    private lateinit var store: AccountStore
    private lateinit var preview: ImageView
    private lateinit var adapter: SkinAdapter
    private var selected: SkinManager.SkinEntry? = null

    override fun onCreateView(i: LayoutInflater, c: ViewGroup?, s: Bundle?) =
        i.inflate(R.layout.fragment_skins, c, false)

    override fun onViewCreated(v: View, s: Bundle?) {
        val app = requireActivity().application as com.mobilejavalauncher.LauncherApp
        skins = SkinManager(requireContext(), app.skinsDir)
        store = AccountStore(requireContext())
        preview = v.findViewById(R.id.skinPreview)
        adapter = SkinAdapter()
        val recycler = v.findViewById<RecyclerView>(R.id.skinList)
        recycler.layoutManager = LinearLayoutManager(context, LinearLayoutManager.HORIZONTAL, false)
        recycler.adapter = adapter
        refresh()

        v.findViewById<Button>(R.id.pickSkinButton).setOnClickListener {
            pickImage.launch("image/*")
        }
        v.findViewById<Button>(R.id.applySkinButton).setOnClickListener {
            val entry = selected ?: return@setOnClickListener
            val acc = store.current() ?: run {
                Toast.makeText(context, "Select an account first", Toast.LENGTH_SHORT).show()
                return@setOnClickListener
            }
            if (!acc.isPremium) {
                Toast.makeText(context, "Offline accounts: skin is used locally in game", Toast.LENGTH_SHORT).show()
                return@setOnClickListener
            }
            lifecycleScope.launch {
                val ok = withContext(Dispatchers.IO) {
                    skins.uploadToMojang(acc, File(app.skinsDir, entry.file), entry.model)
                }
                Toast.makeText(context, if (ok) "Skin uploaded!" else "Upload failed", Toast.LENGTH_SHORT).show()
            }
        }
    }

    private val pickImage = registerForActivityResult(
        androidx.activity.result.contract.ActivityResultContracts.GetContent()
    ) { uri ->
        if (uri == null) return@registerForActivityResult
        runCatching {
            val entry = skins.import(uri, requireContext().contentResolver)
            refresh()
            select(entry)
        }.onFailure {
            Toast.makeText(context, "Invalid skin: ${it.message}", Toast.LENGTH_LONG).show()
        }
    }

    private fun refresh() {
        adapter.submit(skins.list())
    }

    private fun select(entry: SkinManager.SkinEntry) {
        selected = entry
        val app = requireActivity().application as com.mobilejavalauncher.LauncherApp
        val bmp = Bitmap.createBitmap(128, 256, Bitmap.Config.ARGB_8888)
        skins.renderPreview(File(app.skinsDir, entry.file), bmp)
        preview.setImageBitmap(bmp)
    }

    inner class SkinAdapter : RecyclerView.Adapter<SkinAdapter.Holder>() {
        private val items = mutableListOf<SkinManager.SkinEntry>()

        fun submit(s: List<SkinManager.SkinEntry>) {
            items.clear(); items.addAll(s); notifyDataSetChanged()
        }

        override fun onCreateViewHolder(parent: ViewGroup, viewType: Int) = Holder(
            layoutInflater.inflate(R.layout.item_skin, parent, false)
        )

        override fun getItemCount() = items.size

        override fun onBindViewHolder(h: Holder, pos: Int) {
            val entry = items[pos]
            h.name.text = "${entry.name} (${entry.model})"
            val app = requireActivity().application as com.mobilejavalauncher.LauncherApp
            val bmp = Bitmap.createBitmap(64, 128, Bitmap.Config.ARGB_8888)
            skins.renderPreview(File(app.skinsDir, entry.file), bmp)
            h.image.setImageBitmap(bmp)
            h.itemView.setOnClickListener { select(entry) }
            h.itemView.setOnLongClickListener {
                skins.delete(entry); refresh(); true
            }
        }

        inner class Holder(v: View) : RecyclerView.ViewHolder(v) {
            val image: ImageView = v.findViewById(R.id.skinThumb)
            val name: android.widget.TextView = v.findViewById(R.id.skinName)
        }
    }
}
