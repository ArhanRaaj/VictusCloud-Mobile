package com.mobilejavalauncher.ui

import android.app.Activity
import android.os.Bundle

/** Receives mjl://auth redirects if a browser-based MSA flow is used. */
class MsAuthActivity : Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // The device-code flow is primary; this handles optional redirect flows.
        finish()
    }
}
