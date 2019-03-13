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
     * A Boolean value indicating whether plug-ins are enabled. OSX only.
     */
    public var plugInsEnabled:Boolean = true;
    /**
     * A Boolean value indicating whether JavaScript is enabled.
     * */
    public var javaScriptEnabled:Boolean = true;
    /**
     * A Boolean value indicating whether JavaScript can open windows without user interaction.
     */
    public var javaScriptCanOpenWindowsAutomatically:Boolean = true;
    /**
     * A Boolean value indicating whether Java is enabled. OSX only.
     */
    public var javaEnabled:Boolean = false;
    /**
     * The minimum font size in points.
     */
    public var minimumFontSize:int = 0;
    /**
     * A Boolean value indicating whether HTML5 videos play inline or use the native full-screen controller.
     */
    public var allowsInlineMediaPlayback:Boolean = false;
    /**
     * A Boolean value indicating whether HTML5 videos can play picture-in-picture.
     */
    public var allowsPictureInPictureMediaPlayback:Boolean = true;
    /**
     * A Boolean value that determines whether a WKWeb​View object should always allow scaling of the webpage.
     */
    public var ignoresViewportScaleLimits:Boolean = false;
    /**
     * A Boolean value indicating whether AirPlay is allowed.
     */
    public var allowsAirPlayForMediaPlayback:Boolean = true;
    /**
     * A Boolean value indicating whether the webview bounces past edge of content and back again.
     */
    public var bounces:Boolean = true;
    /**
     * A Boolean value indicating whether the webview responds to pinch zoom gestures.
     */
    public var useZoomGestures:Boolean = true;
    /**
     *  Add custom preferences via preferences.setValue. This can be used to set private APIs. Use at own risk.
     */
    public var custom:Vector.<Object> = new <Object>[];

    public function WebkitSettings() {
    }
}
}
