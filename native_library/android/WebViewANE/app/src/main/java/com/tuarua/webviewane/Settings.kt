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
    var appCacheEnabled = false
    var javaScriptEnabled = false
    var mediaPlaybackRequiresUserGesture = false
    var userAgent: String? = null
    var javaScriptCanOpenWindowsAutomatically = true
    var blockNetworkImage = false
    var allowFileAccess = true
    var allowContentAccess = true
    var allowUniversalAccessFromFileURLs = true
    var allowFileAccessFromFileURLs = true
    var geolocationEnabled = false
    var databaseEnabled = false
    var domStorageEnabled = false
    var displayZoomControls = false
    var builtInZoomControls = true
    var whiteList: List<String>? = null
    var blackList: List<String>? = null

    constructor(freObject: FREObject?) : this() {
        val fre = freObject ?: return
        val androidSettings = fre["android"]

        appCacheEnabled = Boolean(fre["cacheEnabled"]) == true
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

        userAgent = String(fre["userAgent"])

        val whiteListFre = fre["urlWhiteList"]
        if (whiteListFre != null) {
            val whiteListArr = FREArray(whiteListFre)
            whiteList = List(whiteListArr)
        }

        val blackListFre = fre["urlBlackList"]
        if (blackListFre != null) {
            val blackListArr = FREArray(blackListFre)
            blackList = List(blackListArr)
        }
    }


}