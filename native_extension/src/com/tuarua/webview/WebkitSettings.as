/*
 * Copyright Tua Rua Ltd. (c) 2017.
 */

/**
 * Created by User on 21/01/2017.
 */
package com.tuarua.webview {
public class WebkitSettings {
	/**
	 * <p>A Boolean value indicating whether plug-ins are enabled. OSX only.</p>
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
    public function WebkitSettings() {
    }
}
}
