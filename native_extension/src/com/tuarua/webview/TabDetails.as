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
[RemoteClass(alias="com.tuarua.webview.TabDetails")]
public class TabDetails {
    /**
     *
     * @return current url of tab
     *
     */
    public var url:String;
    /**
     *
     * @return current page title of tab
     *
     */
    public var title:String;
    /**
     *
     * @return current index of tab
     *
     */
    public var index:int;
    /**
     *
     * @return whether the tab is loading
     *
     */
    public var isLoading:Boolean;
    /**
     *
     * @return whether we can navigate back
     *
     * <p>A Boolean value indicating whether we can navigate back.</p>
     *
     */
    public var canGoBack:Boolean;
    /**
     *
     * @return whether we can navigate forward
     *
     * <p>A Boolean value indicating whether we can navigate forward.</p>
     *
     */
    public var canGoForward:Boolean;
    /**
     *
     * @return estimated progress between 0.0 and 1.0.
     * Available on OSX/iOS only
     *
     */
    public var estimatedProgress:Number;

    public function TabDetails(index:int, url:String, title:String, isLoading:Boolean, canGoBack:Boolean, canGoForward:Boolean, estimatedProgress:Number) {
        this.index = index;
        this.url = url;
        this.title = title;
        this.isLoading = isLoading;
        this.canGoBack = canGoBack;
        this.canGoForward = canGoForward;
        this.estimatedProgress = estimatedProgress;
    }
}
}
