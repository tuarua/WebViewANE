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
import android.webkit.*
import com.adobe.fre.FREContext
import com.google.gson.Gson
import com.tuarua.frekotlin.FreKotlinController
import java.io.ByteArrayInputStream

class ViewClient(override var context: FREContext?, private var settings: Settings) : WebViewClient(), FreKotlinController {
    internal var isLoading = false
    private val gson = Gson()
    override fun onReceivedHttpError(view: WebView?, request: WebResourceRequest?, errorResponse: WebResourceResponse?) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.LOLLIPOP) {
            return
        }
        dispatchEvent(WebViewEvent.ON_FAIL,
                gson.toJson(mapOf("url" to request?.url.toString(),
                        "errorCode" to errorResponse?.statusCode,
                        "errorText" to errorResponse?.reasonPhrase,
                        "tab" to 0)))
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
        return if (isWhiteListBlocked(url) || isBlackListBlocked(url)) {
            dispatchEvent(WebViewEvent.ON_URL_BLOCKED, gson.toJson(mapOf("url" to url, "tab" to 0)))
            val response = WebResourceResponse("text/plain", "utf-8",
                    ByteArrayInputStream("".toByteArray()))

            response.setStatusCodeAndReasonPhrase(403, "Blocked")
            response
        } else {
            null
        }
    }

    override fun onPageStarted(view: WebView?, url: String?, favicon: Bitmap?) {
        super.onPageStarted(view, url, favicon)
        isLoading = true
        dispatchEvent(WebViewEvent.ON_PROPERTY_CHANGE, gson.toJson(mapOf("propName" to "isLoading",
                "tab" to 0, "value" to isLoading)))
        dispatchEvent(WebViewEvent.ON_PROPERTY_CHANGE, gson.toJson(mapOf("propName" to "url",
                "tab" to 0, "value" to url)))
    }

    override fun onPageFinished(view: WebView?, url: String?) {
        super.onPageFinished(view, url)
        isLoading = false
        dispatchEvent(WebViewEvent.ON_PROPERTY_CHANGE, gson.toJson(mapOf("propName" to "isLoading",
                "tab" to 0, "value" to isLoading)))

        dispatchEvent(WebViewEvent.ON_PROPERTY_CHANGE, gson.toJson(mapOf("propName" to "canGoBack",
                "tab" to 0, "value" to view?.canGoBack())))

        dispatchEvent(WebViewEvent.ON_PROPERTY_CHANGE, gson.toJson(mapOf("propName" to "canGoForward",
                "tab" to 0, "value" to view?.canGoForward())))
    }

    override val TAG: String
        get() = this::class.java.simpleName
}
