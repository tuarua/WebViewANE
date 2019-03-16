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

import android.webkit.GeolocationPermissions
import android.webkit.WebChromeClient
import android.webkit.WebView
import com.adobe.fre.FREContext
import com.google.gson.Gson
import com.tuarua.frekotlin.FreKotlinController

class ChromeClient(override var context: FREContext?): WebChromeClient(), FreKotlinController {
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
    override val TAG: String
        get() = this::class.java.simpleName

}