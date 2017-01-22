/*
 * Copyright Tua Rua Ltd. (c) 2017.
 */

/**
 * Created by Eoin Landy on 14/01/2017.
 */
package com.tuarua.webview {
public class JavascriptResult {
    public var result:*;
    public var message:String;
    public var error:String;
    public var success:Boolean;

    public function JavascriptResult(result:* = null, message:String = null, error:String = null, success:Boolean = false) {
        this.result = result;
        this.message = message;
        this.error = error;
        this.success = success;
    }
}
}
