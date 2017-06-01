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

/**
 * Created by Eoin Landy on 20/05/2017.
 */
package com.tuarua.fre.display {
import com.tuarua.fre.*;
import com.tuarua.*;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.events.MouseEvent;
import flash.events.StatusEvent;

[RemoteClass(alias="com.tuarua.fre.display.NativeButton")]
public class NativeButton extends NativeDisplayObject {
    private var _upState:Bitmap;
    private var _overState:Bitmap;
    private var _downState:Bitmap;
    public var overStateData:BitmapData;
    public var upStateData:BitmapData;
    public var downStateData:BitmapData;
    private static const AS_CALLBACK_EVENT:String = "TRFRESHARP.as.CALLBACK";
    public var listeners:Vector.<Object> = new <Object>[];

    public function NativeButton(upState:Bitmap, overState:Bitmap, downState:Bitmap=null) {
        _upState = upState;
        _overState = overState;
        _downState = (downState) ? downState : _upState;

        upStateData = _upState.bitmapData;
        overStateData = _overState.bitmapData;
        downStateData = _downState.bitmapData;
        this.type = BUTTON_TYPE;
        ANEContext.ctx.addEventListener(StatusEvent.STATUS, gotNativeEvent);
    }

    public function addEventListener(type:String, listener:Function):void {
        var obj:Object = {type: type, listener: listener};
        listeners.push(obj);
    }


    private function gotNativeEvent(event:StatusEvent):void {
        //trace("native button event", event);

        var argsAsJSON:Object;
        switch (event.level) {
            case AS_CALLBACK_EVENT:
                try {
                    argsAsJSON = JSON.parse(event.code);
                    for each (var listener:Object in listeners) {
                        if (argsAsJSON.id == _id && argsAsJSON.event == listener.type) {
                            var func:Function = listener.listener as Function;
                            func.call(null,new MouseEvent(listener.type));
                        }
                    }

                    //get id and type from JSON
                } catch (e:Error) {
                    trace(e.message);
                    break;
                }
                break;
        }
    }

}
}
