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
import flash.filesystem.File;

public class CefSettings {
    /**
     * Set to a value between 1024 and 65535 to enable remote debugging on the specified
     * port. For example, if 8080 is specified the remote debugging URL will be http://localhost:8080.
     * CEF can be remotely debugged from any CEF or Chrome browser window. Also configurable
     * using the "remote-debugging-port" command-line switch.
     */
    public var remoteDebuggingPort:int = 8088;
    /**
     * The location where cache data will be stored on disk. If empty then browsers
     * will be created in "incognito mode" where in-memory caches are used for storage
     * and no data is persisted to disk. HTML5 databases such as localStorage will only
     * persist across sessions if a cache path is specified. Can be overridden for individual
     * CefRequestContext instances via the RequestContextSettings.CachePath value.
     */
    public var cachePath:String = File.applicationStorageDirectory.resolvePath("cache").nativePath;
    /**
     * The log severity. Only messages of this severity level or higher will be logged.
     * Also configurable using the "log-severity" command-line switch with a value of
     * "verbose", "info", "warning", "error", "error-report" or "disable".
     */
    public var logSeverity:int = LogSeverity.DISABLE;
    /**
     * Add custom command line arguments to this collection, they will be added in
     * OnBeforeCommandLineProcessing.
     */
    public var commandLineArgs:Vector.<Object> = new <Object>[];

    /**
     * The location where user data such as spell checking dictionary files will be stored on disk.
     * If empty then the default platform-specific user data directory
     * "Local Settings\Application Data\CEF\User Data"directory under the user profile directory on Windows).
     */
    public var userDataPath:String;

    /**
     * Comma delimited ordered list of language codes without any whitespace that will
     * be used in the "Accept-Language" HTTP header. May be set globally using the CefSettings.AcceptLanguageList
     * value. If both values are empty then "en-US,en" will be used.
     */
    public var acceptLanguageList:String = "en-US,en";

    /**
     * The locale string that will be passed to WebKit. If empty the default locale of "en-US" will be used.
     */
    public var locale:String = "en-US";

    /**
     *  Set command line argument to enable Print Preview
     *  See https://bitbucket.org/chromiumembedded/cef/issues/123/add-support-for-print-preview for details.
     */
    public var enablePrintPreview:Boolean;

    public function CefSettings() {
    }
}
}

