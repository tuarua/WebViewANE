/*
 * Copyright Tua Rua Ltd. (c) 2017.
 */

/**
 * Created by Eoin Landy on 24/01/2017.
 */
package com.tuarua.webview {
public class DownloadProgress extends Object {
	/**
	 * 
	 */	
    public var id:uint = 0;
	/**
	 * 
	 */	
    public var speed:uint = 0;
	/**
	 * 
	 */	
    public var percent:uint = 0;
	/**
	 * 
	 */	
    public var bytesLoaded:uint = 0;
	/**
	 * 
	 */	
    public var bytesTotal:uint = 0;

    public function DownloadProgress() {
    }
}
}


