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

import android.graphics.Color
import android.graphics.Rect
import android.util.Log
import android.webkit.WebView
import com.adobe.fre.FREContext
import com.adobe.fre.FREObject
import com.tuarua.frekotlin.*
import com.tuarua.frekotlin.geom.FreRectangleKotlin
import java.util.ArrayList

typealias FREArgv = ArrayList<FREObject>

@Suppress("unused", "UNUSED_PARAMETER", "UNCHECKED_CAST")
class KotlinController : FreKotlinController {
    private var context: FREContext? = null
    private val TRACE = "TRACE"

    private var isAdded: Boolean = false
    private var scaleFactor: Double = 1.0

    private var webViewController: WebViewController? = null

    fun isSupported(ctx: FREContext, argv: FREArgv): FREObject? {
        return FreObjectKotlin(true).rawValue.guard { return null }
    }

    fun init(ctx: FREContext, argv: FREArgv): FREObject? {
        /*
        initialUrl:String,
        viewPort:Rectangle,
        settings:Settings,
        scaleFactor:Number,
        backgroundColor:uint,
        backgroundAlpha:Number
        */
        argv.takeIf { argv.size > 5 } ?: return ArgCountException().getError(Thread.currentThread().stackTrace)

        try {
            val initialUrl: String? = FreObjectKotlin(argv[0]).value as? String
            val viewPort = FreRectangleKotlin(argv[1]).value
            val sf = FreObjectKotlin(argv[3]).value
            scaleFactor = (sf as? Int)?.toDouble() ?: sf as Double

            val settings = Settings(FreObjectKotlin(argv[2]))
            val backgroundColorFre = FreObjectKotlin(argv[3])
            val fillAlphaFre = FreObjectKotlin(argv[5]).value
            val fillAlpha: Double = (fillAlphaFre as? Int)?.toDouble() ?: fillAlphaFre as Double

            var backgroundColor = Color.TRANSPARENT
            if (fillAlpha > 0) {
                backgroundColor = backgroundColorFre.toColor((255 * fillAlpha).toInt())
            }
            webViewController = WebViewController(ctx, initialUrl, scaleViewPort(viewPort), settings, backgroundColor)

        }catch (e:FreException){
            Log.e(TAG, e.message)
        }
        return null
    }

    fun clearCache(ctx: FREContext, argv: FREArgv): FREObject? {
        webViewController?.clearCache()
        return null
    }

    fun zoomIn(ctx: FREContext, argv: FREArgv): FREObject? {
        webViewController?.zoomIn()
        return null
    }

    fun zoomOut(ctx: FREContext, argv: FREArgv): FREObject? {
        webViewController?.zoomOut()
        return null
    }

    fun setViewPort(ctx: FREContext, argv: FREArgv): FREObject? {
        argv.takeIf { argv.size > 0 } ?: return ArgCountException().getError(Thread.currentThread().stackTrace)
        val viewPortFre = FreRectangleKotlin(argv[0]).value
        webViewController?.viewPort = scaleViewPort(viewPortFre)
        return null
    }

    fun setVisible(ctx: FREContext, argv: FREArgv): FREObject? {
        argv.takeIf { argv.size > 0 } ?: return ArgCountException().getError(Thread.currentThread().stackTrace)
        val visible = FreObjectKotlin(argv[0]).value as Boolean
        if (!isAdded) {
            webViewController?.add()
            isAdded = true
        }
        webViewController?.visible = visible

        return null
    }

    fun loadHTMLString(ctx: FREContext, argv: FREArgv): FREObject? {
        argv.takeIf { argv.size > 0 } ?: return ArgCountException().getError(Thread.currentThread().stackTrace)
        val data: String = FreObjectKotlin(argv[0]).value as String
        webViewController?.loadHTMLString(data)
        return null
    }

    fun load(ctx: FREContext, argv: FREArgv): FREObject? {
        argv.takeIf { argv.size > 0 } ?: return ArgCountException().getError(Thread.currentThread().stackTrace)
        val url: String = FreObjectKotlin(argv[0]).value as String
        webViewController?.loadUrl(url)
        return null
    }

    fun loadFileURL(ctx: FREContext, argv: FREArgv): FREObject? {
        argv.takeIf { argv.size > 0 } ?: return ArgCountException().getError(Thread.currentThread().stackTrace)
        val url: String = FreObjectKotlin(argv[0]).value as String
        webViewController?.loadUrl(url)
        return null
    }

    fun reload(ctx: FREContext, argv: FREArgv): FREObject? {
        webViewController?.reload()
        return null
    }

    fun go(ctx: FREContext, argv: FREArgv): FREObject? {
        argv.takeIf { argv.size > 0 } ?: return ArgCountException().getError(Thread.currentThread().stackTrace)
        val offset = FreObjectKotlin(argv[0]).value as Int
        webViewController?.go(offset)
        return null
    }

    fun goBack(ctx: FREContext, argv: FREArgv): FREObject? {
        webViewController?.goBack()
        return null
    }

    fun goForward(ctx: FREContext, argv: FREArgv): FREObject? {
        webViewController?.goForward()
        return null
    }

    fun stopLoading(ctx: FREContext, argv: FREArgv): FREObject? {
        webViewController?.stopLoading()
        return null
    }

    fun reloadFromOrigin(ctx: FREContext, argv: FREArgv): FREObject? {
        webViewController?.reload()
        return null
    }

    fun allowsMagnification(ctx: FREContext, argv: FREArgv): FREObject? {
        return FreObjectKotlin(true).rawValue
    }

    fun showDevTools(ctx: FREContext, argv: FREArgv): FREObject? {
        WebView.setWebContentsDebuggingEnabled(true)
        return null
    }

    fun closeDevTools(ctx: FREContext, argv: FREArgv): FREObject? {
        WebView.setWebContentsDebuggingEnabled(false)
        return null
    }

    fun callJavascriptFunction(ctx: FREContext, argv: FREArgv): FREObject? {
        argv.takeIf { argv.size > 1 } ?: return ArgCountException().getError(Thread.currentThread().stackTrace)
        val js: String = FreObjectKotlin(argv[0]).value as String
        val callback: String? = FreObjectKotlin(argv[1]).value as? String
        webViewController?.evaluateJavascript(js, callback)
        return null
    }

    fun evaluateJavaScript(ctx: FREContext, argv: FREArgv): FREObject? {
        argv.takeIf { argv.size > 1 } ?: return ArgCountException().getError(Thread.currentThread().stackTrace)
        val js: String = FreObjectKotlin(argv[0]).value as String
        val callback: String? = FreObjectKotlin(argv[1]).value as? String
        webViewController?.evaluateJavascript(js, callback)
        return null
    }

    fun getCurrentTab(ctx: FREContext, argv: FREArgv): FREObject? {
        return FreObjectKotlin(0).rawValue
    }

    fun getTabDetails(ctx: FREContext, argv: FREArgv): FREObject? {
        val obj: FreObjectKotlin = FreObjectKotlin(name = "Vector.<com.tuarua.webview.TabDetails>").guard { return null }
        val freObject = obj.rawValue ?: return FreException("Can't create TabDetails Vector").getError(Thread
                .currentThread().stackTrace)
        val vecTabs = FreArrayKotlin(freObject)
        vecTabs.rawValue?.length = 1
        val currentTabFre = FreObjectKotlin("com.tuarua.webview.TabDetails", 0,
                webViewController?.url ?: ""
                , webViewController?.title ?: ""
                , webViewController?.isLoading ?: false
                , webViewController?.canGoBack ?: false
                , webViewController?.canGoForward ?: false
                , webViewController?.progress ?: 0.0
        )
        vecTabs.setObjectAt(0, currentTabFre)
        return vecTabs.rawValue
    }

    fun backForwardList(ctx: FREContext, argv: FREArgv): FREObject? = null
    fun setCurrentTab(ctx: FREContext, argv: FREArgv): FREObject? = null
    fun capture(ctx: FREContext, argv: FREArgv): FREObject? = null
    fun addTab(ctx: FREContext, argv: FREArgv): FREObject? = null
    fun closeTab(ctx: FREContext, argv: FREArgv): FREObject? = null
    fun injectScript(ctx: FREContext, argv: FREArgv): FREObject? = null
    fun print(ctx: FREContext, argv: FREArgv): FREObject? = null
    fun focus(ctx: FREContext, argv: FREArgv): FREObject? = null
    fun onFullScreen(ctx: FREContext, argv: FREArgv): FREObject? = null
    fun shutDown(ctx: FREContext, argv: FREArgv): FREObject? = null

    private fun scaleViewPort(rect: Rect): Rect {
        return Rect((rect.left * scaleFactor).toInt(), (rect.top * scaleFactor).toInt(),
                (rect.width() * scaleFactor).toInt(), ((rect.height() + rect.top) * scaleFactor).toInt())
    }

    override fun onStarted() {
        super.onStarted()
    }

    override fun onRestarted() {
        super.onRestarted()
    }

    override fun onResumed() {
        super.onResumed()
    }

    override fun onPaused() {
        super.onPaused()
    }

    override fun onStopped() {
        super.onStopped()
    }

    override fun onDestroyed() {
        super.onDestroyed()
    }

    override fun setFREContext(context: FREContext) {
        this.context = context
    }

    private fun trace(vararg value: Any?) {
        context?.trace(TAG, value)
    }

    private fun sendEvent(name: String, value: String) {
        context?.sendEvent(name, value)
    }

    companion object {
        private var TAG = KotlinController::class.java.canonicalName
    }

}