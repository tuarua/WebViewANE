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
import com.tuarua.frekotlin.FreKotlinController
import com.tuarua.frekotlin.sendEvent
import com.tuarua.frekotlin.geom.Rect
import org.json.JSONException
import org.json.JSONObject

class WebViewController(override var context: FREContext?, initialUrl: String?, viewPort: Rect, private var settings: Settings,
                        private var backgroundColor: Int) : FreKotlinController {

    private var _visible: Boolean = false
    private var _viewPort: Rect = viewPort
    private var _initialUrl: String? = initialUrl
    private var airView: ViewGroup? = null
    private var container: FrameLayout? = null
    private var webView: WebView? = null
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
            frame.layoutParams = FrameLayout.LayoutParams(viewPort.width.toInt(), viewPort.height.toInt())
            frame.x = viewPort.x.toFloat()
            frame.y = viewPort.y.toFloat()
        }
        get() = _viewPort

    private lateinit var chromeClient: ChromeClient
    private lateinit var viewClient: ViewClient

    fun add() {
        val newId = View.generateViewId()
        val ctx = this.context ?: return

        airView = ctx.activity.findViewById(android.R.id.content) as ViewGroup
        airView = (airView as ViewGroup).getChildAt(0) as ViewGroup
        container = FrameLayout(ctx.activity)

        val frame = container ?: return
        frame.layoutParams = FrameLayout.LayoutParams(viewPort.width.toInt(), viewPort.height.toInt())
        frame.x = viewPort.x.toFloat()
        frame.y = viewPort.y.toFloat()
        frame.id = newId
        (airView as ViewGroup).addView(frame)

        webView = WebView(ctx.activity.applicationContext)
        val wv = webView ?: return
        wv.setOnKeyListener(View.OnKeyListener { _, keyCode, event ->
            if (keyCode == KeyEvent.KEYCODE_BACK) {
                val props = JSONObject()
                try {
                    props.put("keyCode", 16777238)
                    props.put("nativeKeyCode", keyCode)
                    props.put("modifiers", "")
                    props.put("isSystemKey", false)
                    if (event.action == KeyEvent.ACTION_UP) {
                        sendEvent(Constants.ON_KEY_UP, props.toString())
                    } else {
                        sendEvent(Constants.ON_KEY_DOWN, props.toString())
                    }
                } catch (e: JSONException) {
                    e.printStackTrace()
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

        chromeClient = ChromeClient(ctx)
        viewClient = ViewClient(ctx, settings)
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
                context?.sendEvent(Constants.JS_CALLBACK_EVENT, json)
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

    fun capture(x: Int, y: Int, w: Int, h: Int): Bitmap? {
        val wv = webView ?: return null
        var theX: Int = x
        var theY: Int = y
        var theW: Int = w
        var theH: Int = h

        val bitmap: Bitmap
        if (w > 0 && h > 0) {
            bitmap = Bitmap.createBitmap(w + x, h + y, Bitmap.Config.ARGB_8888)
        } else {
            theX = 0
            theY = 0
            theW = wv.width
            theH = wv.height
            bitmap = Bitmap.createBitmap(theW, theH, Bitmap.Config.ARGB_8888)
        }

        val canvas = Canvas(bitmap)
        wv.draw(canvas)
        return Bitmap.createBitmap(bitmap, theX, theY, theW, theH)
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
                    e.printStackTrace()
                }
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


    @Suppress("PropertyName")
    override val TAG: String
        get() = this::class.java.simpleName


}

