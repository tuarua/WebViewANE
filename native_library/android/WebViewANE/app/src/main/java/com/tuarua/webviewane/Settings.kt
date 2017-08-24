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

import com.tuarua.frekotlin.FreArrayKotlin
import com.tuarua.frekotlin.FreObjectKotlin
import java.util.ArrayList

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
        this.appCacheEnabled = o.getProperty("cacheEnabled")?.value as Boolean
        this.javaScriptEnabled = androidSettings?.getProperty("javaScriptEnabled")?.value as Boolean
        this.mediaPlaybackRequiresUserGesture = androidSettings.getProperty("mediaPlaybackRequiresUserGesture")?.value as Boolean
        this.javaScriptCanOpenWindowsAutomatically = androidSettings.getProperty("javaScriptCanOpenWindowsAutomatically")?.value as Boolean
        this.blockNetworkImage = androidSettings.getProperty("blockNetworkImage")?.value as Boolean
        this.allowFileAccess = androidSettings.getProperty("allowFileAccess")?.value as Boolean
        this.allowContentAccess = androidSettings.getProperty("allowContentAccess")?.value as Boolean
        this.allowUniversalAccessFromFileURLs = androidSettings.getProperty("allowUniversalAccessFromFileURLs")?.value as Boolean
        this.allowFileAccessFromFileURLs = androidSettings.getProperty("allowFileAccessFromFileURLs")?.value as Boolean
        this.geolocationEnabled = androidSettings.getProperty("geolocationEnabled")?.value as Boolean
        this.userAgent = o.getProperty("userAgent")?.value as String

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