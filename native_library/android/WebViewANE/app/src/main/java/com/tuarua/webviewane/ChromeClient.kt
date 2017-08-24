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

import android.util.Log
import android.webkit.GeolocationPermissions
import android.webkit.PermissionRequest
import android.webkit.WebChromeClient
import android.webkit.WebView
import com.adobe.fre.FREContext
import com.tuarua.frekotlin.sendEvent
import org.json.JSONException
import org.json.JSONObject

class ChromeClient(private var context: FREContext) : WebChromeClient() {
    internal var progress:Double = 0.0
    override fun onProgressChanged(view: WebView?, newProgress: Int) {
        super.onProgressChanged(view, newProgress)
        val props = JSONObject()
        progress = newProgress.toDouble() * 0.01
        try {
            props.put("propName", "estimatedProgress")
            props.put("value", progress)
            props.put("tab", 0)
            sendEvent(Constants.ON_PROPERTY_CHANGE, props.toString())
        } catch (e: JSONException) {
            Log.e(TAG, e.message)
        }
    }

    override fun onReceivedTitle(view: WebView?, title: String?) {
        super.onReceivedTitle(view, title)
        val props = JSONObject()
        try {
            props.put("propName", "title")
            props.put("value", title)
            props.put("tab", 0)
            sendEvent(Constants.ON_PROPERTY_CHANGE, props.toString())
        } catch (e: JSONException) {
            Log.e(TAG, e.message)
        }

    }

    override fun onPermissionRequest(request: PermissionRequest?) {
        super.onPermissionRequest(request)
    }

    override fun onPermissionRequestCanceled(request: PermissionRequest?) {
        super.onPermissionRequestCanceled(request)
    }

    override fun onGeolocationPermissionsShowPrompt(origin: String?, callback: GeolocationPermissions.Callback?) {
        callback?.invoke(origin, true, false)
    }

    override fun onGeolocationPermissionsHidePrompt() {
        super.onGeolocationPermissionsHidePrompt()
    }

    private fun sendEvent(name: String, value: String) {
        context.sendEvent(name, value)
    }

    companion object {
        private var TAG = ChromeClient::class.java.canonicalName
    }

}