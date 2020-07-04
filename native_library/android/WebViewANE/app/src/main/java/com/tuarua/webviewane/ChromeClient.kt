/*
 * Copyright 2017 Tua Rua Ltd.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * Additional Terms
 * No part, or derivative of this Air Native Extensions's code is permitted
 * to be sold as the basis of a commercially packaged Air Native Extension which
 * undertakes the same purpose as this software. That is, a WebView for Windows,
 * OSX and/or iOS and/or Android.
 * All Rights Reserved. Tua Rua Ltd.
 */

package com.tuarua.webviewane

import android.annotation.TargetApi
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.webkit.GeolocationPermissions
import android.webkit.ValueCallback
import android.webkit.WebChromeClient
import android.webkit.WebView
import com.adobe.fre.FREContext
import com.google.gson.Gson
import com.tuarua.frekotlin.FreKotlinController

class ChromeClient(override var context: FREContext?) : WebChromeClient(), FreKotlinController {
    var filePathCallback: ValueCallback<Array<Uri>>? = null

    internal var progress = 0.0
    private val gson = Gson()
    override fun onProgressChanged(view: WebView?, newProgress: Int) {
        super.onProgressChanged(view, newProgress)
        progress = newProgress.toDouble() * 0.01
        dispatchEvent(WebViewEvent.ON_PROPERTY_CHANGE,
                gson.toJson(mapOf("propName" to "estimatedProgress",
                        "value" to progress,
                        "tab" to 0)))
    }

    override fun onReceivedTitle(view: WebView?, title: String?) {
        super.onReceivedTitle(view, title)
        dispatchEvent(WebViewEvent.ON_PROPERTY_CHANGE,
                gson.toJson(mapOf("propName" to "title",
                        "value" to title,
                        "tab" to 0)))
    }

    override fun onGeolocationPermissionsShowPrompt(origin: String?,
                                                    callback: GeolocationPermissions.Callback?) {
        callback?.invoke(origin, true, false)
    }

    @TargetApi(Build.VERSION_CODES.LOLLIPOP)
    override fun onShowFileChooser(webView: WebView?, filePathCallback: ValueCallback<Array<Uri>>?,
                                   fileChooserParams: FileChooserParams?): Boolean {

        this.filePathCallback?.onReceiveValue(arrayOf())
        this.filePathCallback = null

        val intent = Intent()
        intent.addCategory(Intent.CATEGORY_OPENABLE)
        intent.addCategory(Intent.CATEGORY_DEFAULT)
        intent.action = Intent.ACTION_GET_CONTENT
        intent.type = "*/*"
        intent.putExtra(Intent.EXTRA_ALLOW_MULTIPLE, true)
        if (fileChooserParams?.acceptTypes != null) {
            intent.putExtra(Intent.EXTRA_MIME_TYPES, fileChooserParams.acceptTypes)
        }

        if (filePathCallback != null && fileChooserParams != null) {
            this.filePathCallback = filePathCallback
        }

        val title = fileChooserParams?.title ?: "Choose a file"

        context?.activity?.startActivityForResult(Intent.createChooser(intent, title), REQUEST_FILE)
        return true
    }

    companion object {
        const val REQUEST_FILE = 80
    }

    override val TAG: String
        get() = this::class.java.simpleName

}