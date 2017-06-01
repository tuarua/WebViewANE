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
 * Created by Eoin Landy on 24/01/2017.
 */
package com.tuarua.webview {
public class DownloadProgress extends Object {
	/**
	 * Returns the unique identifier for this download.
	 */	
    public var id:uint = 0;
	/**
	 * Returns a simple speed estimate in bytes/s.
	 */	
    public var speed:uint = 0;
	/**
	 * Returns the rough percent complete or -1 if the receive total size is unknown.
	 */	
    public var percent:uint = 0;
	/**
	 * Returns the number of received bytes.
	 */	
    public var bytesLoaded:uint = 0;
	/**
	 * Returns the total number of bytes.
	 */	
    public var bytesTotal:uint = 0;
    /**
     * Returns the URL as it was before any redirects.
     */
    public var url:String;
    public function DownloadProgress() {
    }
}
}


