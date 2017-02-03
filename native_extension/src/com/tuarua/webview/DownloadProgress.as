/*
 * Copyright Tua Rua Ltd. (c) 2017.
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


