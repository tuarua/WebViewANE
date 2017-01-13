/*
 * Copyright Tua Rua Ltd. (c) 2017.
 */

/**
 * Created by Eoin Landy on 10/01/2017.
 */
package com.tuarua.webview {
import com.tuarua.ANEObject;

public class CefSettings extends ANEObject {
    public var remoteDebuggingPort:int = 8088;
    public var cachePath:String = "cache";//set to empty
    public var logSeverity:int = 99;//default
    public var commandLineArgs:Vector.<Object> = new <Object>[];
    /*
    https://github.com/cefsharp/CefSharp/blob/master/CefSharp.Example/CefExample.cs#L37
    * `--disable-gpu --disable-gpu-compositing --enable-begin-frame-scheduling`
    * (you'll loose WebGL support but gain increased FPS and reduced CPU usage).
     */
    public var bestPerformance:Boolean = true;

    public function CefSettings() {
    }
}
}