/*
 * Copyright Tua Rua Ltd. (c) 2017.
 */

/**
 * Created by Eoin Landy on 21/01/2017.
 */
package com.tuarua.webview {
	
public class ActionscriptCallback {
	/**
	 * 
	 */	
    public var args:*;
	/**
	 * 
	 */	
    public var functionName:String;
	/**
	 * 
	 */	
    public var callbackName:String;

    public function ActionscriptCallback(args:* = null, functionName:String = null, callbackName:String = null) {
        this.args = args;
        this.functionName = functionName;
        this.callbackName = callbackName;
    }
}
}
