/**
 * Created by Eoin Landy on 01/12/2016.
 */
package com.tuarua.webview {
import flash.events.Event;

public class WebViewEvent extends Event {
    //public static const WEBVIEW_ERROR:String = "WebView.Error";

    public static const ON_URL_CHANGE:String = "WebView.OnUrlChange";
    public static const ON_FINISH:String = "WebView.OnFinish";
    public static const ON_START:String = "WebView.OnStart";
    public static const ON_FAIL:String = "WebView.OnFail";
    public static const ON_JAVASCRIPT_RESULT:String = "WebView.OnJavascriptResult";
    public static const ON_PROGRESS:String = "WebView.OnProgress";
    public static const ON_PAGE_TITLE:String = "WebView.OnPageTitle"
    public static const ON_BACK_FORWARD_UPDATE: String = "WebView.OnBackForwardUpdate"
    public var params:Object;

    public function WebViewEvent(type:String, params:Object = null, bubbles:Boolean = false, cancelable:Boolean = false) {
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
