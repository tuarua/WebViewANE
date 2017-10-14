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

import com.adobe.fre.FREArray
import com.adobe.fre.FREObject
import com.tuarua.frekotlin.*

class Settings() {
    var appCacheEnabled: Boolean = false
    var javaScriptEnabled: Boolean = false
    var mediaPlaybackRequiresUserGesture: Boolean = false
    var userAgent: String? = null
    var javaScriptCanOpenWindowsAutomatically: Boolean = true
    var blockNetworkImage: Boolean = false
    var allowFileAccess: Boolean = true
    var allowContentAccess: Boolean = true
    var allowUniversalAccessFromFileURLs: Boolean = true
    var allowFileAccessFromFileURLs: Boolean = true
    var geolocationEnabled: Boolean = false
    var databaseEnabled: Boolean = false
    var domStorageEnabled: Boolean = false
    var displayZoomControls: Boolean = false
    var builtInZoomControls: Boolean = true
    var whiteList: List<String>? = null
    var blackList: List<String>? = null

    constructor(freObject: FREObject?) : this() {
        val o = freObject ?: return
        val androidSettings: FREObject? = o.getProp("android")

        this.appCacheEnabled = Boolean(o.getProp("cacheEnabled")) == true
        this.javaScriptEnabled = Boolean(androidSettings?.getProp("javaScriptEnabled")) == true
        this.mediaPlaybackRequiresUserGesture = Boolean(androidSettings?.getProp("mediaPlaybackRequiresUserGesture")) == true
        this.javaScriptCanOpenWindowsAutomatically = Boolean(androidSettings?.getProp("javaScriptCanOpenWindowsAutomatically")) == true
        this.blockNetworkImage = Boolean(androidSettings?.getProp("blockNetworkImage")) == true
        this.allowFileAccess = Boolean(androidSettings?.getProp("allowFileAccess")) == true
        this.allowContentAccess = Boolean(androidSettings?.getProp("allowContentAccess")) == true
        this.allowUniversalAccessFromFileURLs = Boolean(androidSettings?.getProp("allowUniversalAccessFromFileURLs")) == true
        this.allowFileAccessFromFileURLs = Boolean(androidSettings?.getProp("allowFileAccessFromFileURLs")) == true
        this.geolocationEnabled = Boolean(androidSettings?.getProp("geolocationEnabled")) == true
        this.databaseEnabled = Boolean(androidSettings?.getProp("databaseEnabled")) == true
        this.domStorageEnabled = Boolean(androidSettings?.getProp("domStorageEnabled")) == true
        this.displayZoomControls = Boolean(androidSettings?.getProp("displayZoomControls")) == true
        this.builtInZoomControls = Boolean(androidSettings?.getProp("builtInZoomControls")) == true

        this.userAgent = String(o.getProp("userAgent"))

        val whiteListFre = o.getProp("urlWhiteList")
        if (whiteListFre != null) {
            val whiteListArr: FREArray? = FREArray(freObject = whiteListFre)
            this.whiteList = List<String>(whiteListArr)
        }

        val blackListFre = o.getProperty("urlBlackList")
        if (blackListFre != null) {
            val blackListArr: FREArray? = FREArray(freObject = blackListFre)
            this.blackList = List<String>(blackListArr)
        }
    }


}