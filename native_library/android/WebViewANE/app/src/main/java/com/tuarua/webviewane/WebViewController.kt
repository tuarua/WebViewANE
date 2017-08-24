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

import android.graphics.Rect
import android.os.Build
import android.util.Log
import android.view.View
import android.view.ViewGroup
import android.webkit.CookieManager
import android.webkit.JavascriptInterface
import android.webkit.WebView
import android.widget.FrameLayout
import com.adobe.fre.FREContext
import com.tuarua.frekotlin.sendEvent
import com.tuarua.frekotlin.trace
import org.json.JSONException
import org.json.JSONObject


class WebViewController(private var context: FREContext, initialUrl: String?, viewPort: Rect, settings: Settings,
                        private var backgroundColor: Int) {
    private var _visible: Boolean = false
    private var _viewPort: Rect = viewPort
    private var _initialUrl: String? = initialUrl
    private var airView: ViewGroup? = null
    private var container: FrameLayout? = null

    private var webView: WebView? = null
    private var settings: Settings = settings

    var visible: Boolean
        set(value) {
            this._visible = value
            val frame = container ?: return
            frame.visibility = if (_visible) View.VISIBLE else View.INVISIBLE
        }
        get() = _visible

    var viewPort: Rect
        set(value) {
            this._viewPort = value
            val frame = container ?: return
            frame.layoutParams = FrameLayout.LayoutParams(viewPort.width(), viewPort.height())
            frame.x = viewPort.left.toFloat()
            frame.y = viewPort.top.toFloat()
        }
        get() = _viewPort

    private lateinit var chromeClient: ChromeClient
    private lateinit var viewClient: ViewClient

    fun add() {
        val newId = View.generateViewId()

        airView = context.activity.findViewById(android.R.id.content) as ViewGroup
        airView = (airView as ViewGroup).getChildAt(0) as ViewGroup

        container = FrameLayout(context.activity)

        val frame = container ?: return
        frame.layoutParams = FrameLayout.LayoutParams(viewPort.width(), viewPort.height())
        frame.x = viewPort.left.toFloat()
        frame.y = viewPort.top.toFloat()
        frame.id = newId
        (airView as ViewGroup).addView(frame)

        webView = WebView(context.activity.applicationContext)
        val wv = webView ?: return
        wv.settings.allowContentAccess = settings.allowContentAccess
        wv.settings.setAppCacheEnabled(settings.appCacheEnabled)
        wv.settings.javaScriptEnabled = settings.javaScriptEnabled
        wv.settings.mediaPlaybackRequiresUserGesture = settings.mediaPlaybackRequiresUserGesture
        if (settings.userAgent is String) {
            wv.settings.userAgentString = settings.userAgent
        }
        wv.settings.javaScriptCanOpenWindowsAutomatically = settings.javaScriptCanOpenWindowsAutomatically
        wv.settings.blockNetworkImage = settings.blockNetworkImage
        wv.settings.allowFileAccess = settings.allowFileAccess
        wv.settings.allowContentAccess = settings.allowContentAccess
        wv.settings.allowUniversalAccessFromFileURLs = settings.allowUniversalAccessFromFileURLs
        wv.settings.allowFileAccessFromFileURLs = settings.allowFileAccessFromFileURLs
        wv.settings.setGeolocationEnabled(false)

        chromeClient = ChromeClient(context)
        viewClient = ViewClient(context, settings)
        wv.isHorizontalScrollBarEnabled = false
        wv.setWebChromeClient(chromeClient)
        wv.setWebViewClient(viewClient)
        wv.setBackgroundColor(backgroundColor)

        wv.addJavascriptInterface(BoundObject(), "webViewANE")

        // AppRTC requires third party cookies to work
        val cookieManager = CookieManager.getInstance()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            cookieManager.setAcceptThirdPartyCookies(wv, true)
        }

        if (!_initialUrl.isNullOrEmpty()) {
            wv.loadUrl(_initialUrl)
        }

        frame.addView(wv)

    }

    @Suppress("unused")
    inner class BoundObject {
        @JavascriptInterface
        fun postMessage(json: String?) {
            if (json != null) {
                context.sendEvent(Constants.JS_CALLBACK_EVENT, json)
            }
        }
    }

    fun clearCache() {
        webView?.clearCache(true)
    }

    fun zoomIn() {
        webView?.zoomIn()
    }

    fun zoomOut() {
        webView?.zoomOut()
    }

    fun loadHTMLString(data: String) {
        webView?.loadData(data, "text/html; charset=UTF-8", null)
    }

    fun loadUrl(url: String) {
        webView?.loadUrl(url)
    }

    fun reload() {
        webView?.reload()
    }

    fun goBack() {
        val wv = webView ?: return
        if (wv.canGoBack()) {
            wv.goBack()
        }
    }

    fun goForward() {
        val wv = webView ?: return
        if (wv.canGoForward()) {
            wv.goForward()
        }
    }

    fun go(offset: Int) {
        val wv = webView ?: return
        if (wv.canGoBackOrForward(offset)) {
            wv.goBackOrForward(offset)
        }

    }

    fun stopLoading() {
        webView?.stopLoading()
    }

    fun evaluateJavascript(js: String, callback: String?) {
        val wv = webView ?: return
        if (callback is String) {
            wv.evaluateJavascript(js) { result ->
                val props = JSONObject()
                try {
                    props.put("callbackName", callback)
                    props.put("error", "")
                    props.put("message", "")
                    props.put("success", true)
                    props.put("result", result)
                    sendEvent(Constants.AS_CALLBACK_EVENT, props.toString())
                } catch (e: JSONException) {
                    Log.e(TAG, e.toString())
                    e.printStackTrace()
                }
            }
        } else {
            wv.evaluateJavascript(js, null)
        }

    }

    private fun trace(vararg value: Any?) {
        context.trace(TAG, value)
    }

    private fun sendEvent(name: String, value: String) {
        context.sendEvent(name, value)
    }

    companion object {
        private var TAG = WebViewController::class.java.canonicalName
    }

    val url: String?
        get() {
            return webView?.url
        }
    val title: String?
        get() {
            return webView?.title
        }
    val isLoading: Boolean
        get() {
            return viewClient.isLoading
        }
    val canGoBack: Boolean?
        get() {
            return webView?.canGoBack()
        }
    val canGoForward: Boolean?
        get() {
            return webView?.canGoForward()
        }
    val progress: Double?
        get() {
            return chromeClient.progress
        }

}