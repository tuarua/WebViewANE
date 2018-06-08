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
public class WebkitSettings {
    /**
     * <p>A Boolean value indicating whether plug-ins are enabled. OSX only.</p>
     */
    public var plugInsEnabled:Boolean = true;
    /**
     * <p>A Boolean value indicating whether JavaScript is enabled.</p>
     * */
    public var javaScriptEnabled:Boolean = true;
    /**
     * <p>A Boolean value indicating whether JavaScript can open windows without user interaction.</p>
     */
    public var javaScriptCanOpenWindowsAutomatically:Boolean = true;
    /**
     * <p>A Boolean value indicating whether Java is enabled. OSX only.</p>
     */
    public var javaEnabled:Boolean = false;
    /**
     * <p>The minimum font size in points.</p>
     */
    public var minimumFontSize:int = 0;
    /**
     * <p>A Boolean value indicating whether HTML5 videos play inline or use the native full-screen controller.</p>
     */
    public var allowsInlineMediaPlayback:Boolean = false;
    /**
     * <p>A Boolean value indicating whether HTML5 videos can play picture-in-picture.</p>
     */
    public var allowsPictureInPictureMediaPlayback:Boolean = true;
    /**
     * <p>A Boolean value that determines whether a WKWeb​View object should always allow scaling of the webpage.</p>
     */
    public var ignoresViewportScaleLimits:Boolean = false;
    /**
     * <p>A Boolean value indicating whether AirPlay is allowed.</p>
     */
    public var allowsAirPlayForMediaPlayback:Boolean = true;
    /**
     * <p>A Boolean value indicating whether the webview bounces past edge of content and back again.</p>
     */
    public var bounces:Boolean = true;
    /**
     * <p>A Boolean value indicating whether the webview responds to pinch zoom gestures.</p>
     */
    public var useZoomGestures:Boolean = true;
    /**
     *  <p>Add custom preferences via preferences.setValue. This can be used to set private APIs. Use at own risk.</p>
     */
    public var custom:Vector.<Object> = new <Object>[];

    public function WebkitSettings() {
    }
}
}
