package com.mobilejavalauncher.ui

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.EditText
import android.widget.ProgressBar
import android.widget.TextView
import android.widget.Toast
import androidx.fragment.app.Fragment
import androidx.lifecycle.lifecycleScope
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.google.android.material.tabs.TabLayout
import com.mobilejavalauncher.R
import com.mobilejavalauncher.install.ModrinthClient
import com.mobilejavalauncher.model.ModrinthProject
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

class InstallFragment : Fragment() {
    private lateinit var client: ModrinthClient
    private lateinit var adapter: StoreAdapter
    private lateinit var progress: ProgressBar
    private var category = ModrinthClient.Category.MODS

    override fun onCreateView(i: LayoutInflater, c: ViewGroup?, s: Bundle?) =
        i.inflate(R.layout.fragment_install, c, false)

    override fun onViewCreated(v: View, s: Bundle?) {
        client = ModrinthClient(requireActivity().application as com.mobilejavalauncher.LauncherApp)
        adapter = StoreAdapter()
        progress = v.findViewById(R.id.installProgress)
        val tabs = v.findViewById<TabLayout>(R.id.installTabs)
        val search = v.findViewById<EditText>(R.id.searchInput)
        val recycler = v.findViewById<RecyclerView>(R.id.installList)

        recycler.layoutManager = LinearLayoutManager(context)
        recycler.adapter = adapter

        tabs.addOnTabSelectedListener(object : TabLayout.OnTabSelectedListener {
            override fun onTabSelected(tab: TabLayout.Tab) {
                category = when (tab.position) {
                    0 -> ModrinthClient.Category.MODS
                    1 -> ModrinthClient.Category.SHADERS
                    2 -> ModrinthClient.Category.RESOURCEPACKS
                    else -> ModrinthClient.Category.MODPACKS
                }
                doSearch(search.text.toString())
            }
            override fun onTabUnselected(tab: TabLayout.Tab) {}
            override fun onTabReselected(tab: TabLayout.Tab) {}
        })
        tabs.addTab(tabs.newTab().setText("Mods"))
        tabs.addTab(tabs.newTab().setText("Shaders"))
        tabs.addTab(tabs.newTab().setText("Resource packs"))
        tabs.addTab(tabs.newTab().setText("Modpacks"))

        search.setOnEditorActionListener { _, _, _ ->
            doSearch(search.text.toString()); true
        }
        doSearch("")
    }

    private fun doSearch(query: String) {
        lifecycleScope.launch {
            progress.visibility = View.VISIBLE
            try {
                val results = withContext(Dispatchers.IO) { client.search(category, query) }
                adapter.submit(results)
            } catch (e: Exception) {
                Toast.makeText(context, "Search failed: ${e.message}", Toast.LENGTH_LONG).show()
            } finally {
                progress.visibility = View.GONE
            }
        }
    }

    inner class StoreAdapter : RecyclerView.Adapter<StoreAdapter.Holder>() {
        private val items = mutableListOf<ModrinthProject>()

        fun submit(projects: List<ModrinthProject>) {
            items.clear(); items.addAll(projects); notifyDataSetChanged()
        }

        override fun onCreateViewHolder(parent: ViewGroup, viewType: Int) = Holder(
            layoutInflater.inflate(R.layout.item_store_entry, parent, false)
        )

        override fun getItemCount() = items.size

        override fun onBindViewHolder(h: Holder, pos: Int) {
            val p = items[pos]
            h.title.text = p.title
            h.subtitle.text = "${p.downloads} downloads — ${p.description}"
            h.download.setOnClickListener {
                lifecycleScope.launch {
                    progress.visibility = View.VISIBLE
                    try {
                        val versions = withContext(Dispatchers.IO) { client.versions(p.projectId) }
                        val latest = versions.firstOrNull() ?: error("No versions")
                        withContext(Dispatchers.IO) {
                            client.installVersion(latest, category) { label, d, t ->
                                requireActivity().runOnUiThread {
                                    if (t > 0) progress.progress = (d * 100 / t).toInt()
                                }
                            }
                        }
                        Toast.makeText(context, "Installed ${p.title}", Toast.LENGTH_SHORT).show()
                    } catch (e: Exception) {
                        Toast.makeText(context, "Install failed: ${e.message}", Toast.LENGTH_LONG).show()
                    } finally {
                        progress.visibility = View.GONE
                    }
                }
            }
        }

        inner class Holder(v: View) : RecyclerView.ViewHolder(v) {
            val title: TextView = v.findViewById(R.id.entryTitle)
            val subtitle: TextView = v.findViewById(R.id.entrySubtitle)
            val download: View = v.findViewById(R.id.entryDownload)
        }
    }
}
