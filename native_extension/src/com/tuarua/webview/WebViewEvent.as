/**
 * Created by Eoin Landy on 01/12/2016.
 */
package com.tuarua.webview {
import flash.events.Event;

public class WebViewEvent extends Event {
    /**
     *
     */
    public static const ON_FAIL:String = "WebView.OnFail";
    /**
     * Dispatched when one of the following is updated url, title, isLoading, canGoBack, canGoForward,
     * estimatedProgress, statusMessage
     */
    public static const ON_PROPERTY_CHANGE:String = "WebView.OnPropertyChange";
    /**
     * <p><strong>Placeholder only.</strong></p>
     */
    public static const ON_CONSOLE_MESSAGE:String = "WebView.OnConsoleMessage";
    /**
     * Dispatched when download progress changes
     * <p><strong>Windows only.</strong></p>
     */
    public static const ON_DOWNLOAD_PROGRESS:String = "WebView.OnDownloadProgress";
    /**
     * Dispatched when download is marked as complete
     * <p><strong>Windows only.</strong></p>
     */
    public static const ON_DOWNLOAD_COMPLETE:String = "WebView.OnDownloadComplete"
    /**
     * Dispatched when download is cancelled
     * <p><strong>Windows only.</strong></p>
     */
    public static const ON_DOWNLOAD_CANCEL:String = "WebView.OnDownloadCancel";
    /**
     * Dispatched when Esc key is pressed. Use this to exit fullscreen.
     * <p><strong>Windows and OSX only.</strong></p>
     */
    public static const ON_ESC_KEY:String = "WebView.OnEscKey";
    /**
     * Dispatched when permission is granted / denied.
     * <p><strong>Windows only.</strong></p>
     */
    public static const ON_PERMISSION_RESULT:String = "WebView.OnPermissionResult";

    /**
     * Dispatched when a url is blocked (due to settings.urlWhiteList).
     * <p><strong>Windows, OSX, iOS only.</strong></p>
     */
    public static const ON_URL_BLOCKED:String = "WebView.OnUrlBlocked";

    public var params:*;


    public function WebViewEvent(type:String, params:* = null, bubbles:Boolean = false, cancelable:Boolean = false) {
        super(type, bubbles, cancelable);
        this.params = params;
    }

    public override function clone():Event {
        return new WebViewEvent(type, this.params, bubbles, cancelable);
    }

    public override function toString():String {
        return formatToString("WebViewEvent", "params", "type", "bubbles", "cancelable");
    }
}


}