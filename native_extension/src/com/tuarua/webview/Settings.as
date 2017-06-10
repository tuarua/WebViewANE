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

/**
 * Created by Eoin Landy on 10/01/2017.
 */
package com.tuarua.webview {
import com.tuarua.webview.popup.Popup;

public class Settings extends Object {
	/**
	 * <p>Settings to use for CEF (Windows) version.</p>
	 */	
    public var cef:CefSettings = new CefSettings();
	/**
	 * <p>Settings to use for WKWebView (OSX) version.</p>
	 */	
    public var webkit:WebkitSettings = new WebkitSettings();
    /**
     * <p>Value that will be returned as the User-Agent HTTP header.</p>
     */
    public var userAgent:String = "";
    /**
     * <p>Settings to use for Android version.</p>
     */
    public var android:AndroidSettings = new AndroidSettings();

    public var popup:Popup = new Popup();

    /**
     <p>Vector of urls to allow through, example google.com - This uses a simple string match. There is no regex support. WIN, OSX, iOS only.</p>
     */
    public var urlWhiteList:Vector.<String> = new <String>[];

    public function Settings() {
    }
}
}
