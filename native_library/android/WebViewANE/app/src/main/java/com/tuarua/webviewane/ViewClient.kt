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

import android.graphics.Bitmap
import android.os.Build
import android.util.Log
import android.webkit.*
import com.adobe.fre.FREContext
import com.tuarua.frekotlin.dispatchEvent
import org.json.JSONException
import org.json.JSONObject
import java.io.ByteArrayInputStream

class ViewClient(private var context: FREContext, private var settings: Settings) : WebViewClient() {
    internal var isLoading: Boolean = false
    override fun onReceivedHttpError(view: WebView?, request: WebResourceRequest?, errorResponse: WebResourceResponse?) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.LOLLIPOP) {
            return
        }
        val props = JSONObject()
        try {
            props.put("url", request?.url.toString())
            props.put("tab", 0)
            props.put("errorCode", errorResponse?.statusCode)
            props.put("errorText", errorResponse?.reasonPhrase)
            sendEvent(WebViewEvent.ON_FAIL, props.toString())
        } catch (e: JSONException) {
            Log.e(TAG, e.message)
        }
        super.onReceivedHttpError(view, request, errorResponse)
    }

    private fun isBlackListBlocked(url: String): Boolean {
        val list = settings.blackList ?: return false
        if (list.isEmpty()) {
            return false
        }
        val urlClean = url.toLowerCase()
        var i = 0
        val size = list.size
        while (i < size) {
            val s = list[i].toLowerCase()
            if (urlClean.contains(s)) {
                return true
            }
            i++
        }

        return false
    }

    private fun isWhiteListBlocked(url: String): Boolean {
        val list = settings.whiteList ?: return false
        if (list.isEmpty()) {
            return false
        }
        val urlClean = url.toLowerCase()
        var i = 0
        val size = list.size
        while (i < size) {
            val s = list[i].toLowerCase()
            if (urlClean.contains(s)) {
                return false
            }
            i++
        }
        return true
    }

    override fun shouldInterceptRequest(view: WebView?, request: WebResourceRequest?): WebResourceResponse? {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.LOLLIPOP) {
            return null
        }
        val url = request?.url.toString()
        if (isWhiteListBlocked(url) || isBlackListBlocked(url)) {
            val props = JSONObject()
            try {
                props.put("url", url)
                props.put("tab", 0)
                sendEvent(WebViewEvent.ON_URL_BLOCKED, props.toString())
            } catch (e: JSONException) {
                e.printStackTrace()
            }

            val response = WebResourceResponse("text/plain", "utf-8",
                    ByteArrayInputStream("".toByteArray()))

            response.setStatusCodeAndReasonPhrase(403, "Blocked")
            return response
        } else {
            return null
        }
    }

    override fun onPageStarted(view: WebView?, url: String?, favicon: Bitmap?) {
        super.onPageStarted(view, url, favicon)
        isLoading = true
        var props = JSONObject()
        try {

            props.put("propName", "isLoading")
            props.put("tab", 0)
            props.put("value", isLoading)
            sendEvent(WebViewEvent.ON_PROPERTY_CHANGE, props.toString())
        } catch (e: JSONException) {
            Log.e(TAG, e.message)
        }

        props = JSONObject()
        try {
            props.put("propName", "url")
            props.put("value", url)
            props.put("tab", 0)
            sendEvent(WebViewEvent.ON_PROPERTY_CHANGE, props.toString())
        } catch (e: JSONException) {
            e.printStackTrace()
        }

    }

    override fun onPageFinished(view: WebView?, url: String?) {
        super.onPageFinished(view, url)
        isLoading = false
        var props = JSONObject()
        try {
            props.put("propName", "isLoading")
            props.put("value", isLoading)
            props.put("tab", 0)
            sendEvent(WebViewEvent.ON_PROPERTY_CHANGE, props.toString())
        } catch (e: JSONException) {
            Log.e(TAG, e.message)
        }

        props = JSONObject()
        try {
            props.put("propName", "canGoBack")
            props.put("tab", 0)
            props.put("value", view?.canGoBack())
            sendEvent(WebViewEvent.ON_PROPERTY_CHANGE, props.toString())
        } catch (e: JSONException) {
            Log.e(TAG, e.message)
        }

        props = JSONObject()
        try {
            props.put("propName", "canGoForward")
            props.put("tab", 0)
            props.put("value", view?.canGoForward())
            sendEvent(WebViewEvent.ON_PROPERTY_CHANGE, props.toString())
        } catch (e: JSONException) {
            Log.e(TAG, e.message)
        }

    }

    private fun sendEvent(name: String, value: String) {
        context.dispatchEvent(name, value)
    }

    companion object {
        private var TAG = ChromeClient::class.java.canonicalName
    }
}
