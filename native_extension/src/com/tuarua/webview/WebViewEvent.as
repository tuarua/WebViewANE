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
 * Created by Eoin Landy on 01/12/2016.
 */
package com.tuarua.webview {
import flash.events.Event;

public class WebViewEvent extends Event {
    /**
     *
     */
    public static const ON_FAIL:String = "WebView.OnFail";
    /**
     * Dispatched when one of the following is updated url, title, isLoading, canGoBack, canGoForward,
     * estimatedProgress, statusMessage
     */
    public static const ON_PROPERTY_CHANGE:String = "WebView.OnPropertyChange";
    /**
     * <p><strong>Placeholder only.</strong></p>
     */
    public static const ON_CONSOLE_MESSAGE:String = "WebView.OnConsoleMessage";
    /**
     * Dispatched when download progress changes
     * <p><strong>Windows only.</strong></p>
     */
    public static const ON_DOWNLOAD_PROGRESS:String = "WebView.OnDownloadProgress";
    /**
     * Dispatched when download is marked as complete
     * <p><strong>Windows only.</strong></p>
     */
    public static const ON_DOWNLOAD_COMPLETE:String = "WebView.OnDownloadComplete"
    /**
     * Dispatched when download is cancelled
     * <p><strong>Windows only.</strong></p>
     */
    public static const ON_DOWNLOAD_CANCEL:String = "WebView.OnDownloadCancel";
    /**
     * Dispatched when Esc key is pressed. Use this to exit fullscreen.
     * <p><strong>Windows and OSX only.</strong></p>
     */
    public static const ON_ESC_KEY:String = "WebView.OnEscKey";
    /**
     * Dispatched when permission is granted / denied.
     * <p><strong>Windows only.</strong></p>
     */
    public static const ON_PERMISSION_RESULT:String = "WebView.OnPermissionResult";

    /**
     * Dispatched when a url is blocked (due to settings.urlWhiteList).
     * <p><strong>Windows, OSX, iOS only.</strong></p>
     */
    public static const ON_URL_BLOCKED:String = "WebView.OnUrlBlocked";

    public var params:*;


    public function WebViewEvent(type:String, params:* = null, bubbles:Boolean = false, cancelable:Boolean = false) {
        super(type, bubbles, cancelable);
        this.params = params;
    }

    public override function clone():Event {
        return new WebViewEvent(type, this.params, bubbles, cancelable);
    }

    public override function toString():String {
        return formatToString("WebViewEvent", "params", "type", "bubbles", "cancelable");
    }
}


}