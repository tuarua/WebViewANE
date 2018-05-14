/*
 * Copyright 2017 Tua Rua Ltd.
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 *
 *  Additional Terms
 *  No part, or derivative of this Air Native Extensions's code is permitted
 *  to be sold as the basis of a commercially packaged Air Native Extension which
 *  undertakes the same purpose as this software. That is, a WebView for Windows,
 *  OSX and/or iOS and/or Android.
 *  All Rights Reserved. Tua Rua Ltd.
 */
package com.tuarua.webview {
public class AndroidSettings {
    /**
     * <p>Sets whether the WebView requires a user gesture to play media.</p>
     */
    public var mediaPlaybackRequiresUserGesture:Boolean = true;
    /**
     * <p>A Boolean value indicating whether JavaScript is enabled.</p>
     */
    public var javaScriptEnabled:Boolean = true;
    /**
     * <p>A Boolean value indicating whether JavaScript can open windows without user interaction.</p>
     */
    public var javaScriptCanOpenWindowsAutomatically:Boolean = true;
    /**
     * <p>A Boolean value indicating whether the WebView should not load image resources from the network.</p>
     */
    public var blockNetworkImage:Boolean = false;
    /**
     * <p>Enables or disables file access within WebView.</p>
     */
    public var allowFileAccess:Boolean = true;
    /**
     * <p>Sets whether JavaScript running in the context of a file scheme URL should be allowed to access
     * content from other file scheme URLs.</p>
     */
    public var allowFileAccessFromFileURLs:Boolean = true;
    /**
     * <p>Sets whether JavaScript running in the context of a file scheme URL should be allowed to access
     * content from other file scheme URLs.</p>
     */
    public var allowUniversalAccessFromFileURLs:Boolean = true;

    /**
     * <p>Enables or disables content URL access within WebView.</p>
     */
    public var allowContentAccess:Boolean = true;


    /**
     * <p>Sets whether Geolocation is enabled.</p>
     */
    public var geolocationEnabled:Boolean = false;

    /**
     * <p>Sets whether the database storage API is enabled.</p>
     */
    public var databaseEnabled:Boolean = true;

    /**
     * <p>Sets whether the DOM storage API is enabled.</p>
     */
    public var domStorageEnabled:Boolean = true;

    /**
     * <p>Sets whether the WebView should display on-screen zoom controls when
     * using the built-in zoom mechanisms.</p>
     */
    public var displayZoomControls: Boolean = false;

    /**
     * <p>Sets whether the WebView should use its built-in zoom mechanisms.</p>
     */
    public var builtInZoomControls: Boolean = true;

    public function AndroidSettings() {
    }
}
}
