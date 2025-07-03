package com.ferry.emone.emone

import android.content.Intent
import android.nfc.NfcAdapter
import android.nfc.Tag
import android.nfc.tech.MifareClassic
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.ferry.emone/emoney"
    private var latestTag: Tag? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "readTapCashBlock") {
                val tag = latestTag // gunakan yang diperbarui dari onNewIntent
                if (tag != null) {
                    val mfc = MifareClassic.get(tag)
                    try {
                        mfc.connect()
                        val sectorIndex = 1
                        val blockIndex = 4
                        val auth = mfc.authenticateSectorWithKeyA(sectorIndex, MifareClassic.KEY_DEFAULT)
                        if (auth) {
                            val data = mfc.readBlock(blockIndex)
                            result.success(data.toList())
                        } else {
                            result.error("AUTH_FAILED", "Autentikasi gagal", null)
                        }
                    } catch (e: Exception) {
                        result.error("ERROR", e.message, null)
                    } finally {
                        if (mfc.isConnected) mfc.close()
                    }
                } else {
                    result.error("NO_TAG", "Tag tidak ditemukan (null)", null)
                }
            }
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        latestTag = intent.getParcelableExtra(NfcAdapter.EXTRA_TAG)
    }
}
