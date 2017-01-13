/**
 * Created by Eoin Landy on 01/12/2016.
 */
package com.tuarua.webview {
import flash.events.Event;

public class WebViewEvent extends Event {
    public static const ON_FAIL:String = "WebView.OnFail";
    public static const ON_JAVASCRIPT_RESULT:String = "WebView.OnJavascriptResult";
    public static const ON_PROPERTY_CHANGE:String = "WebView.OnPropertyChange";
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
