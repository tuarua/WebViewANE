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

    public function AndroidSettings() {
    }
}
}
