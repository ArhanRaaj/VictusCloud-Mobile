package com.mobilejavalauncher.ui

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Button
import android.widget.EditText
import android.widget.TextView
import android.widget.Toast
import androidx.fragment.app.Fragment
import androidx.lifecycle.lifecycleScope
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.mobilejavalauncher.R
import com.mobilejavalauncher.account.AccountStore
import com.mobilejavalauncher.account.AuthManager
import com.mobilejavalauncher.model.Account
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

class AccountsFragment : Fragment() {
    private lateinit var store: AccountStore
    private lateinit var auth: AuthManager
    private lateinit var list: RecyclerView
    private lateinit var adapter: AccountsAdapter

    override fun onCreateView(i: LayoutInflater, c: ViewGroup?, s: Bundle?) =
        i.inflate(R.layout.fragment_accounts, c, false)

    override fun onViewCreated(v: View, s: Bundle?) {
        store = AccountStore(requireContext())
        auth = AuthManager(store)
        list = v.findViewById(R.id.accountsList)
        adapter = AccountsAdapter()
        list.layoutManager = LinearLayoutManager(context)
        list.adapter = adapter
        refresh()

        v.findViewById<Button>(R.id.addOfflineButton).setOnClickListener {
            val name = v.findViewById<EditText>(R.id.usernameInput).text.toString().trim()
            if (name.isBlank()) {
                Toast.makeText(context, "Enter a username", Toast.LENGTH_SHORT).show()
                return@setOnClickListener
            }
            auth.createOfflineAccount(name)
            refresh()
        }

        v.findViewById<Button>(R.id.addMsButton).setOnClickListener {
            lifecycleScope.launch {
                try {
                    val start = withContext(Dispatchers.IO) { auth.startDeviceFlow() }
                    Toast.makeText(
                        context,
                        "Go to ${start.verificationUri} and enter: ${start.userCode}",
                        Toast.LENGTH_LONG
                    ).show()
                    withContext(Dispatchers.IO) { auth.awaitDeviceFlow(start) {} }
                    refresh()
                } catch (e: Exception) {
                    Toast.makeText(context, "MSA login failed: ${e.message}", Toast.LENGTH_LONG).show()
                }
            }
        }
    }

    private fun refresh() {
        adapter.submit(store.load())
    }

    inner class AccountsAdapter : RecyclerView.Adapter<AccountsAdapter.Holder>() {
        private val items = mutableListOf<Account>()

        fun submit(accounts: List<Account>) {
            items.clear(); items.addAll(accounts); notifyDataSetChanged()
        }

        override fun onCreateViewHolder(parent: ViewGroup, viewType: Int) = Holder(
            layoutInflater.inflate(R.layout.item_account, parent, false)
        )

        override fun getItemCount() = items.size

        override fun onBindViewHolder(h: Holder, pos: Int) {
            val acc = items[pos]
            h.name.text = acc.name
            h.type.text = if (acc.isPremium) "Microsoft (premium)" else "Offline"
            h.delete.setOnClickListener {
                val updated = store.load().filterNot { it.id == acc.id }
                store.save(updated)
                if (store.current()?.id == acc.id) store.setCurrent(null)
                refresh()
            }
            h.itemView.setOnClickListener {
                store.setCurrent(acc.id)
                refresh()
            }
        }

        inner class Holder(v: View) : RecyclerView.ViewHolder(v) {
            val name: TextView = v.findViewById(R.id.accountName)
            val type: TextView = v.findViewById(R.id.accountType)
            val delete: View = v.findViewById(R.id.accountDelete)
        }
    }
}
