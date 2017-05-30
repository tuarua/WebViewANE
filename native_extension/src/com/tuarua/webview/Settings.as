/*
 * Copyright Tua Rua Ltd. (c) 2017.
 */

/**
 * Created by Eoin Landy on 10/01/2017.
 */
package com.tuarua.webview {
import com.tuarua.webview.popup.Popup;

public class Settings extends Object {
	/**
	 * <p>Settings to use for CEF (Windows) version.</p>
	 */	
    public var cef:CefSettings = new CefSettings();
	/**
	 * <p>Settings to use for WKWebView (OSX) version.</p>
	 */	
    public var webkit:WebkitSettings = new WebkitSettings();
    /**
     * <p>Value that will be returned as the User-Agent HTTP header.</p>
     */
    public var userAgent:String = "";
    /**
     * <p>Settings to use for Android version.</p>
     */
    public var android:AndroidSettings = new AndroidSettings();

    public var popup:Popup = new Popup();

    /**
     <p>Vector of urls to allow through, example google.com - This is a simple string match. There is no regex support. WIN, OSX, iOS only.</p>
     */
    public var urlWhiteList:Vector.<String> = new <String>[];

    public function Settings() {
    }
}
}
