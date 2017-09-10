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

import com.tuarua.frekotlin.Boolean
import com.tuarua.frekotlin.FreArrayKotlin
import com.tuarua.frekotlin.FreObjectKotlin
import java.util.ArrayList
import com.tuarua.frekotlin.String

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
    var whiteList: ArrayList<String>? = null
    var blackList: ArrayList<String>? = null

    constructor(freObjectKotlin: FreObjectKotlin?) : this() {
        val o = freObjectKotlin ?: return
        val androidSettings: FreObjectKotlin? = o.getProperty("android")

        this.appCacheEnabled = Boolean(o.getProperty("cacheEnabled")) == true
        this.javaScriptEnabled = Boolean(androidSettings?.getProperty("javaScriptEnabled")) == true
        this.mediaPlaybackRequiresUserGesture = Boolean(androidSettings?.getProperty("mediaPlaybackRequiresUserGesture")) == true
        this.javaScriptCanOpenWindowsAutomatically = Boolean(androidSettings?.getProperty("javaScriptCanOpenWindowsAutomatically")) == true
        this.blockNetworkImage = Boolean(androidSettings?.getProperty("blockNetworkImage")) == true
        this.allowFileAccess = Boolean(androidSettings?.getProperty("allowFileAccess")) == true
        this.allowContentAccess = Boolean(androidSettings?.getProperty("allowContentAccess")) == true
        this.allowUniversalAccessFromFileURLs = Boolean(androidSettings?.getProperty("allowUniversalAccessFromFileURLs")) == true
        this.allowFileAccessFromFileURLs = Boolean(androidSettings?.getProperty("allowFileAccessFromFileURLs")) == true
        this.geolocationEnabled = Boolean(androidSettings?.getProperty("geolocationEnabled")) == true
        this.userAgent = String(o.getProperty("userAgent"))

        val whiteListFreK = o.getProperty("urlWhiteList")
        val whiteListFre = whiteListFreK?.rawValue

        if (whiteListFre != null) {
            val aList = FreArrayKotlin(whiteListFre).value
            this.whiteList = ArrayList<String>()
            for (any in aList) {
                this.whiteList?.add(any as String)
            }
        }

        val blackListFreK = o.getProperty("urlBlackList")
        val blackListFre = blackListFreK?.rawValue
        if (blackListFre != null) {
            val aList = FreArrayKotlin(blackListFre).value
            this.blackList = ArrayList<String>()
            for (any in aList) {
                this.blackList?.add(any as String)
            }
        }

    }
}