/*
 * Copyright Tua Rua Ltd. (c) 2017.
 */

/**
 * Created by Eoin Landy on 10/01/2017.
 */
package com.tuarua.webview {
import com.tuarua.ANEObject;

public class CefSettings extends ANEObject {
/** 
 * <p>Set to a value between 1024 and 65535 to enable remote debugging on the specified
port. For example, if 8080 is specified the remote debugging URL will be http://localhost:8080.
CEF can be remotely debugged from any CEF or Chrome browser window. Also configurable
using the "remote-debugging-port" command-line switch.</p>
 */
    public var remoteDebuggingPort:int = 8088;
/** 
 * <p>The location where cache data will be stored on disk. If empty then browsers
will be created in "incognito mode" where in-memory caches are used for storage
and no data is persisted to disk. HTML5 databases such as localStorage will only
persist across sessions if a cache path is specified. Can be overridden for individual
CefRequestContext instances via the RequestContextSettings.CachePath value.</p>
 */
    public var cachePath:String = "cache";//set to empty
/** 
 * <p>The log severity. Only messages of this severity level or higher will be logged.
Also configurable using the "log-severity" command-line switch with a value of
"verbose", "info", "warning", "error", "error-report" or "disable".</p>
 */
    public var logSeverity:int = 99;//default
/**
 *  <p>Add custom command line argumens to this collection, they will be added in 
OnBeforeCommandLineProcessing.</p>
 */	
    public var commandLineArgs:Vector.<Object> = new <Object>[];
/**
 *  <p>Set command line arguments for best OSR (Offscreen and WPF) Rendering performance
This will disable WebGL, look at the source to determine which flags best suite
your requirements.</p>
 */	
    public var bestPerformance:Boolean = true;

    public function CefSettings() {
    }
}
}