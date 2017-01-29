/*
 * Copyright Tua Rua Ltd. (c) 2017.
 */

/**
 * Created by User on 21/01/2017.
 */
package com.tuarua.webview {
public class WebkitSettings {
	/**
	 * <p>A Boolean value indicating whether plug-ins are enabled.</p>
	 */	
    public var plugInsEnabled:Boolean = true;
	/**
	 * <p>A Boolean value indicating whether JavaScript is enabled.</p>
	 */	
    public var javaScriptEnabled:Boolean = true;
	/**
	 * <p>A Boolean value indicating whether JavaScript can open windows without user interaction.</p>
	 */	
    public var javaScriptCanOpenWindowsAutomatically:Boolean = true;
	/**
	 * <p>A Boolean value indicating whether Java is enabled.</p>
	 */	
    public var javaEnabled:Boolean = false;
	/**
	 * <p>The minimum font size in points.</p>
	 */	
    public var minimumFontSize:int = 0;
    public function WebkitSettings() {
    }
}
}
