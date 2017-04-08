/*
 * Copyright Tua Rua Ltd. (c) 2017.
 */

/**
 * Created by Eoin Landy on 26/03/2017.
 */
package com.tuarua.webview {
public class AndroidSettings {
    /**
     * <p>Sets whether the WebView requires a user gesture to play media.</p>
     */
    public var mediaPlaybackRequiresUserGesture:Boolean = true;
    /**
     * <p>A Boolean value indicating whether JavaScript is enabled.</p>
     */
    public var javaScriptEnabled:Boolean = true;
    /**
     * <p>A Boolean value indicating whether JavaScript can open windows without user interaction.</p>
     */
    public var javaScriptCanOpenWindowsAutomatically:Boolean = true;
    /**
     * <p>A Boolean value indicating whether the WebView should not load image resources from the network.</p>
     */
    public var blockNetworkImage:Boolean = false;
    /**
     * <p>Enables or disables file access within WebView.</p>
     */
    public var allowFileAccess:Boolean = true;
    /**
     * <p>Sets whether JavaScript running in the context of a file scheme URL should be allowed to access
     * content from other file scheme URLs.</p>
     */
    public var allowFileAccessFromFileURLs:Boolean = true;
    /**
     * <p>Sets whether JavaScript running in the context of a file scheme URL should be allowed to access
     * content from other file scheme URLs.</p>
     */
    public var allowUniversalAccessFromFileURLs:Boolean = true;

    /**
     * <p>Enables or disables content URL access within WebView.</p>
     */
    public var allowContentAccess:Boolean = true;


    /**
     * <p>Sets whether Geolocation is enabled.</p>
     */
    public var geolocationEnabled:Boolean = false;

    public function AndroidSettings() {
    }
}
}
