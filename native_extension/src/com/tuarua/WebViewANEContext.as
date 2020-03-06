/*
 * Copyright 2017 Tua Rua Ltd.
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 *
 *  Additional Terms
 *  No part, or derivative of this Air Native Extensions's code is permitted
 *  to be sold as the basis of a commercially packaged Air Native Extension which
 *  undertakes the same purpose as this software. That is, a WebView for Windows,
 *  OSX and/or iOS and/or Android.
 *  All Rights Reserved. Tua Rua Ltd.
 */

package com.tuarua {
import com.tuarua.fre.ANEError;
import com.tuarua.webview.ActionscriptCallback;
import com.tuarua.webview.DownloadProgress;
import com.tuarua.webview.JavascriptResult;
import com.tuarua.webview.WebViewEvent;

import flash.display.BitmapData;

import flash.display.Stage;
import flash.display.StageDisplayState;
import flash.events.KeyboardEvent;
import flash.events.StatusEvent;
import flash.external.ExtensionContext;
import flash.utils.Dictionary;

/** @private */
public class WebViewANEContext {
    internal static const NAME:String = "WebViewANE";
    internal static const TRACE:String = "TRACE";
    private static const ON_KEY_UP:String = "WebView.OnKeyUp";
    private static const ON_KEY_DOWN:String = "WebView.OnKeyDown";
    private static const ON_ESC_KEY:String = "WebView.OnEscKey";
    private static const JS_CALLBACK_EVENT:String = "TRWV.js.CALLBACK";
    private static const AS_CALLBACK_EVENT:String = "TRWV.as.CALLBACK";
    private static const ON_CAPTURE_COMPLETE:String = "WebView.OnCaptureComplete";
    private static var _context:ExtensionContext;
    public static var callbacks:Dictionary = new Dictionary();
    private static var argsAsJSON:Object;
    private static var _stage:Stage;
    private static var downloadProgress:DownloadProgress = new DownloadProgress();
    private static var _asCallBacks:Dictionary = new Dictionary(); // as -> js -> as
    private static var _jsCallBacks:Dictionary = new Dictionary(); //js - > as -> js
    private static var _onCaptureComplete:Function;
    public function WebViewANEContext() {
    }

    public static function get context():ExtensionContext {
        if (_context == null) {
            try {
                _context = ExtensionContext.createExtensionContext("com.tuarua." + NAME, null);
                _context.addEventListener(StatusEvent.STATUS, gotEvent);
            } catch (e:Error) {
                throw new Error("ANE " + NAME + " not created properly.  Future calls will fail.");
            }
        }
        return _context;
    }

    public static function createCallback(listener:Function):String {
        var id:String;
        if (listener) {
            id = context.call("createGUID") as String;
            callbacks[id] = listener;
        }
        return id;
    }

    public static function callCallback(callbackId:String, clear:Boolean = true, ... args):void {
        var callback:Function = callbacks[callbackId];
        if (callback == null) return;
        callback.apply(null, args);
        if (clear) {
            delete callbacks[callbackId];
        }
    }

    private static function gotEvent(event:StatusEvent):void {
        var keyName:String;
        switch (event.level) {
            case TRACE:
                trace("[" + NAME + "]", event.code);
                break;
            case ON_KEY_DOWN:
                try {
                    argsAsJSON = JSON.parse(event.code);
                    var systemKeyDown:Boolean = argsAsJSON.isSystemKey;
                    var modifiersDown:String = (argsAsJSON.modifiers as String).toLowerCase();
                    var shiftDown:Boolean = modifiersDown.indexOf("shift") > -1;
                    var controlDown:Boolean = modifiersDown.indexOf("control") > -1;
                    var commandDown:Boolean = modifiersDown.indexOf("command") > -1;
                    var altDown:Boolean = modifiersDown.indexOf("alt") > -1 && !systemKeyDown;
                    WebView.shared().dispatchEvent(new KeyboardEvent(KeyboardEvent.KEY_DOWN, true, false, 0, argsAsJSON.keyCode, 0,
                            controlDown, altDown, shiftDown, controlDown, commandDown));
                } catch (e:Error) {
                    trace(e.getStackTrace());
                    break;
                }
                break;
            case ON_KEY_UP:
                try {
                    argsAsJSON = JSON.parse(event.code);
                    var systemKeyUp:Boolean = argsAsJSON.isSystemKey;
                    var modifiersUp:String = (argsAsJSON.modifiers as String).toLowerCase();
                    var shiftUp:Boolean = modifiersUp.indexOf("shift") > -1;
                    var controlUp:Boolean = modifiersUp.indexOf("control") > -1;
                    var commandUp:Boolean = modifiersUp.indexOf("command") > -1;
                    var altUp:Boolean = modifiersUp.indexOf("alt") > -1 && !systemKeyUp;
                    WebView.shared().dispatchEvent(new KeyboardEvent(KeyboardEvent.KEY_UP, true, false, 0, argsAsJSON.keyCode, 0,
                            controlUp, altUp, shiftUp, controlUp, commandUp));
                } catch (e:Error) {
                    trace(e.message);
                    break;
                }
                break;
            case ON_ESC_KEY:
                _stage.displayState = StageDisplayState.NORMAL;
                break;
            case WebViewEvent.ON_PROPERTY_CHANGE:
                argsAsJSON = JSON.parse(event.code);
                var tab:int = 0;
                if (argsAsJSON.hasOwnProperty("tab")) {
                    tab = argsAsJSON.tab;
                }
                WebView.shared().dispatchEvent(new WebViewEvent(WebViewEvent.ON_PROPERTY_CHANGE, {
                    propertyName: argsAsJSON.propName,
                    value: argsAsJSON.value,
                    tab: tab
                }));
                break;
            case WebViewEvent.ON_FAIL:
                WebView.shared().dispatchEvent(new WebViewEvent(WebViewEvent.ON_FAIL, (event.code.length > 0)
                        ? JSON.parse(event.code) : null));
                break;
            case JS_CALLBACK_EVENT: //js->as->js
                try {
                    argsAsJSON = JSON.parse(event.code);
                    for (var key:Object in _jsCallBacks) {
                        var asCallback:ActionscriptCallback = new ActionscriptCallback();
                        keyName = key as String;
                        if (keyName == argsAsJSON.functionName) {
                            var tmpFunction1:Function = _jsCallBacks[key] as Function;
                            asCallback.functionName = argsAsJSON.functionName;
                            asCallback.callbackName = argsAsJSON.callbackName;
                            asCallback.args = argsAsJSON.args;
                            tmpFunction1.call(null, asCallback);
                            break;
                        }
                    }
                } catch (e:Error) {
                    trace(e.message);
                    break;
                }
                break;
            case AS_CALLBACK_EVENT:
                try {
                    argsAsJSON = JSON.parse(event.code);
                } catch (e:Error) {
                    trace(e.message);
                    break;
                }
                for (var keyAs:Object in _asCallBacks) {
                    keyName = keyAs as String;
                    if (keyName == argsAsJSON.callbackName) {
                        var jsResult:JavascriptResult = new JavascriptResult();
                        jsResult.error = argsAsJSON.error;
                        jsResult.message = argsAsJSON.message;
                        jsResult.success = argsAsJSON.success;
                        jsResult.result = argsAsJSON.result;
                        var tmpFunction2:Function = _asCallBacks[keyAs] as Function;
                        tmpFunction2.call(null, jsResult);
                    }
                }
                break;
            case WebViewEvent.ON_DOWNLOAD_PROGRESS:
                try {
                    argsAsJSON = JSON.parse(event.code);
                    downloadProgress.bytesLoaded = argsAsJSON.bytesLoaded;
                    downloadProgress.bytesTotal = argsAsJSON.bytesTotal;
                    downloadProgress.percent = argsAsJSON.percent;
                    downloadProgress.speed = argsAsJSON.speed;
                    downloadProgress.id = argsAsJSON.id;
                    downloadProgress.url = argsAsJSON.url;
                    WebView.shared().dispatchEvent(new WebViewEvent(WebViewEvent.ON_DOWNLOAD_PROGRESS, downloadProgress));
                } catch (e:Error) {
                    trace(e.message);
                    break;
                }
                break;
            case WebViewEvent.ON_DOWNLOAD_COMPLETE:
                WebView.shared().dispatchEvent(new WebViewEvent(WebViewEvent.ON_DOWNLOAD_COMPLETE, event.code));
                break;
            case WebViewEvent.ON_DOWNLOAD_CANCEL:
                WebView.shared().dispatchEvent(new WebViewEvent(WebViewEvent.ON_DOWNLOAD_CANCEL, event.code));
                break;

            case WebViewEvent.ON_URL_BLOCKED:
                try {
                    argsAsJSON = JSON.parse(event.code);
                } catch (e:Error) {
                    trace(e.message);
                    break;
                }
                WebView.shared().dispatchEvent(new WebViewEvent(WebViewEvent.ON_URL_BLOCKED, argsAsJSON));
                break;
            case WebViewEvent.ON_POPUP_BLOCKED:
                try {
                    argsAsJSON = JSON.parse(event.code);
                } catch (e:Error) {
                    trace(e.message);
                    break;
                }
                WebView.shared().dispatchEvent(new WebViewEvent(WebViewEvent.ON_POPUP_BLOCKED, argsAsJSON));
                break;
            case ON_CAPTURE_COMPLETE:
                _onCaptureComplete.call(null, getCapturedBitmapData());
                break;
            default:
                break;
        }
    }

    public static function dispose():void {
        if (!_context) return;
        trace("[" + NAME + "] Unloading ANE...");
        _context.removeEventListener(StatusEvent.STATUS, gotEvent);
        _context.dispose();
        _context = null;
    }

    private static function getCapturedBitmapData():BitmapData {
        var ret:* = WebViewANEContext.context.call("getCapturedBitmapData");
        if (ret is ANEError) throw ret as ANEError;
        return ret as BitmapData;
    }

    public static function set stage(stage:Stage):void {
        _stage = stage;
    }

    public static function get asCallBacks():Dictionary {
        return _asCallBacks;
    }

    public static function get jsCallBacks():Dictionary {
        return _jsCallBacks;
    }

    public static function set onCaptureComplete(value:Function):void {
        _onCaptureComplete = value;
    }
}
}
