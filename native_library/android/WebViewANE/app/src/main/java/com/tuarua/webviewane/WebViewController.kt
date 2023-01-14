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

import android.graphics.*
import android.os.Build
import android.view.KeyEvent
import android.view.View
import android.view.ViewGroup
import android.webkit.CookieManager
import android.webkit.JavascriptInterface
import android.webkit.WebView
import android.widget.FrameLayout
import com.adobe.fre.FREContext
import com.google.gson.Gson
import com.tuarua.frekotlin.FreKotlinController
import com.tuarua.frekotlin.dispatchEvent

class WebViewController(override var context: FREContext?,
                        initialRequest: URLRequest?,
                        viewPort: RectF,
                        private var settings: Settings,
                        private var backgroundColor: Int) : FreKotlinController {

    private val gson = Gson()
    private var _visible = false
    private var _viewPort: RectF = viewPort
    private var _initialRequest = initialRequest
    private var airView: ViewGroup? = null
    private var container: FrameLayout? = null
    private var webView: WebView? = null
    private lateinit var viewClient: ViewClient
    var visible: Boolean
        set(value) {
            this._visible = value
            val frame = container ?: return
            frame.visibility = if (_visible) View.VISIBLE else View.INVISIBLE
        }
        get() = _visible

    var viewPort: RectF
        set(value) {
            this._viewPort = value
            val frame = container ?: return
            frame.layoutParams = FrameLayout.LayoutParams(viewPort.width().toInt(),
                    viewPort.height().toInt())
            frame.x = viewPort.left
            frame.y = viewPort.top
        }
        get() = _viewPort
    lateinit var chromeClient: ChromeClient

    fun add() {
        val newId = View.generateViewId()
        val ctx = this.context ?: return

        airView = ctx.activity.findViewById(android.R.id.content) as ViewGroup
        airView = (airView as ViewGroup).getChildAt(0) as ViewGroup
        container = FrameLayout(ctx.activity)

        val frame = container ?: return
        frame.layoutParams = FrameLayout.LayoutParams(viewPort.width().toInt(),
                viewPort.height().toInt())
        frame.x = viewPort.left
        frame.y = viewPort.top
        frame.id = newId
        (airView as ViewGroup).addView(frame)

        webView = WebView(ctx.activity)
        val wv = webView ?: return
        wv.setOnKeyListener(View.OnKeyListener { _, keyCode, event ->
            if (keyCode == KeyEvent.KEYCODE_BACK) {
                val props = gson.toJson(mapOf("keyCode" to 16777238,
                        "nativeKeyCode" to keyCode,
                        "modifiers" to "",
                        "isSystemKey" to false))
                if (event.action == KeyEvent.ACTION_UP) {
                    dispatchEvent(WebViewEvent.ON_KEY_UP, props)
                } else {
                    dispatchEvent(WebViewEvent.ON_KEY_DOWN, props)
                }
                return@OnKeyListener true
            }
            false
        })
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
        wv.settings.setGeolocationEnabled(settings.geolocationEnabled)
        wv.settings.databaseEnabled = settings.databaseEnabled
        wv.settings.domStorageEnabled = settings.domStorageEnabled
        wv.settings.builtInZoomControls = settings.builtInZoomControls
        wv.settings.displayZoomControls = settings.displayZoomControls

        UrlRequestHeaderManager.persistRequestHeaders = settings.persistRequestHeaders

        chromeClient = ChromeClient(context)
        viewClient = ViewClient(context, settings)
        wv.isHorizontalScrollBarEnabled = false
        wv.webChromeClient = chromeClient
        wv.webViewClient = viewClient
        wv.setBackgroundColor(backgroundColor)

        if (!settings.scrollBarsEnabled) {
            wv.isVerticalScrollBarEnabled = false
            wv.isHorizontalScrollBarEnabled = false
        }

        wv.addJavascriptInterface(BoundObject(), "webViewANE")

        // AppRTC requires third party cookies to work
        val cookieManager = CookieManager.getInstance()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            cookieManager.setAcceptThirdPartyCookies(wv, true)
        }

        val initialRequest = _initialRequest
        val url = initialRequest?.url
        val requestHeaders = initialRequest?.requestHeaders
        if (initialRequest != null && !url.isNullOrEmpty()) {
            when {
                requestHeaders?.isEmpty() == true -> wv.loadUrl(url)
                else -> {
                    UrlRequestHeaderManager.add(initialRequest)
                    wv.loadUrl(url, requestHeaders ?: mutableMapOf())
                }
            }
        }

        frame.addView(wv)

    }

    @Suppress("unused")
    inner class BoundObject {
        @JavascriptInterface
        fun postMessage(json: String?) {
            if (json != null) {
                context?.dispatchEvent(WebViewEvent.JS_CALLBACK_EVENT, json)
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

    fun loadUrl(request: URLRequest) {
        val url = request.url
        when {
            url == null -> return
            request.requestHeaders?.isEmpty() == true -> webView?.loadUrl(url)
            else -> {
                UrlRequestHeaderManager.add(request)
                webView?.loadUrl(url, request.requestHeaders ?: mutableMapOf())
            }
        }
    }

    fun loadFileUrl(url: String) {
        var final = url
        when {
            !final.startsWith("file://", true) -> final = "file://$final"
        }
        webView?.loadUrl(final)
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

    @Suppress("DEPRECATION")
    fun capture(cropTo: RectF): Bitmap? {
        val wv = webView ?: return null
        var x = cropTo.left.toInt()
        var y: Int = cropTo.top.toInt()
        var w: Int = cropTo.width().toInt()
        var h: Int = cropTo.height().toInt()
        if (w == 0 || h == 0) {
            x = 0
            y = 0
            w = wv.width
            h = wv.height
        }
        wv.isDrawingCacheEnabled = true
        val ret = Bitmap.createBitmap(wv.drawingCache, x, y, w, h)
        wv.isDrawingCacheEnabled = false
        return ret
    }

    fun evaluateJavascript(js: String, callback: String?) {
        val wv = webView ?: return
        if (callback is String) {
            wv.evaluateJavascript(js) { result ->
                dispatchEvent(WebViewEvent.AS_CALLBACK_EVENT,
                        gson.toJson(mapOf("callbackName" to callback,
                                "error" to "", "message" to "",
                                "success" to true,
                                "result" to result)))
            }
        } else {
            wv.evaluateJavascript(js, null)
        }
    }

    fun dispose() {
        (airView as ViewGroup).removeView(container)
        container = null
        webView = null

    }

    @Suppress("DEPRECATION")
    fun deleteCookies() {
        val cookieManager = CookieManager.getInstance()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            cookieManager.removeAllCookies(null)
            cookieManager.flush()
        } else {
            cookieManager.removeAllCookie()
        }
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
    val progress: Double
        get() {
            return chromeClient.progress
        }


    @Suppress("PropertyName")
    override val TAG: String
        get() = this::class.java.simpleName


}

