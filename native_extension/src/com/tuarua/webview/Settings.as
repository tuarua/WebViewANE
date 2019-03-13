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
import com.tuarua.webview.popup.Popup;

public class Settings {
    /**
     * Sets whether a context menu will appear on right click. OSX and Windows only.
     */
    public var contextMenu:ContextMenu = new ContextMenu();
    /**
     * Sets whether downloads will be handled by the WebView. OSX and Windows only.
     */
    public var enableDownloads:Boolean = true;
    /**
     * The path to automatically save downloads to. No user dialog is shown. OSX and Windows only.
     */
    public var downloadPath:String;
    /**
     * Settings to use for CEF (Windows) version.
     */
    public var cef:CefSettings = new CefSettings();
    /**
     * Settings to use for WKWebView (OSX / iOS) version.
     */
    public var webkit:WebkitSettings = new WebkitSettings();
    /**
     * Value that will be returned as the User-Agent HTTP header.
     */
    public var userAgent:String = "";
    /**
     * Settings to use for Android version.
     */
    public var android:AndroidSettings = new AndroidSettings();

    public var popup:Popup = new Popup();
    /**
     * Vector of urls to allow through, example google.com - This uses a simple string match. There is no regex support.
     */
    public var urlWhiteList:Vector.<String> = new <String>[];
    /**
     * Vector of urls to block example .pdf,.zip - This uses a simple string match. There is no regex support.
     */
    public var urlBlackList:Vector.<String> = new <String>[];
    /**
     * Enables browser cache.
     */
    public var cacheEnabled:Boolean = true;
    /**
     * The web engine to use.</p>
     */
    public var engine:int = WebEngine.DEFAULT;
    /**
     @param useHiDPI set true if using <requestedDisplayResolution>high</requestedDisplayResolution> in your
     app xml - Windows only.
     */
    public var useHiDPI:Boolean = true;
    /**
     * Sets the container Window (HWND) of the webview to be transparent.
     * <p><b>Important!<b> some video cards don't support this and may cause view to be invisible - Windows 8.1+ only.</p>
     */
    public var useTransparentBackground:Boolean = false;
    /**
     * Sets the container Window (HWND) of the webview to be transparent.
     * <p><b>Important!<b> some video cards don't support this and may cause view to be invisible - Windows 8.1+ only.</p>
     */
    public var persistRequestHeaders:Boolean = false;

    public function Settings() {
    }
}
}
