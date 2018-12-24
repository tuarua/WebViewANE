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
        val androidSettings = o["android"]

        appCacheEnabled = Boolean(o["cacheEnabled"]) == true
        if (androidSettings != null) {
            javaScriptEnabled = Boolean(androidSettings["javaScriptEnabled"]) ?: false
            mediaPlaybackRequiresUserGesture = Boolean(androidSettings["mediaPlaybackRequiresUserGesture"]) ?: false
            javaScriptCanOpenWindowsAutomatically = Boolean(androidSettings["javaScriptCanOpenWindowsAutomatically"]) ?: false
            blockNetworkImage = Boolean(androidSettings["blockNetworkImage"]) ?: false
            allowFileAccess = Boolean(androidSettings["allowFileAccess"]) ?: false
            allowContentAccess = Boolean(androidSettings["allowContentAccess"]) ?: false
            allowUniversalAccessFromFileURLs = Boolean(androidSettings["allowUniversalAccessFromFileURLs"]) ?: false
            allowFileAccessFromFileURLs = Boolean(androidSettings["allowFileAccessFromFileURLs"]) ?: false
            geolocationEnabled = Boolean(androidSettings["geolocationEnabled"]) ?: false
            databaseEnabled = Boolean(androidSettings["databaseEnabled"]) ?: false
            domStorageEnabled = Boolean(androidSettings["domStorageEnabled"]) ?: false
            displayZoomControls = Boolean(androidSettings["displayZoomControls"]) ?: false
            builtInZoomControls = Boolean(androidSettings["builtInZoomControls"]) ?: false
        }

        userAgent = String(o["userAgent"])

        val whiteListFre = o["urlWhiteList"]
        if (whiteListFre != null) {
            val whiteListArr = FREArray(whiteListFre)
            whiteList = List(whiteListArr)
        }

        val blackListFre = o["urlBlackList"]
        if (blackListFre != null) {
            val blackListArr = FREArray(blackListFre)
            blackList = List(blackListArr)
        }
    }


}