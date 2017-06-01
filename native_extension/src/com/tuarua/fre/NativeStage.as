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
 * Created by Eoin Landy on 18/05/2017.
 */
package com.tuarua.fre {
import com.tuarua.*;
import com.tuarua.fre.display.NativeDisplayObject;

import flash.geom.Rectangle;

[RemoteClass(alias="com.tuarua.fre.NativeStage")]
public final class NativeStage {
    private static var _viewPort:Rectangle;
    private static var _visible:Boolean = true;
    public function NativeStage() {
    }

    public static function addChild(nativeDisplayObject:NativeDisplayObject):void {
        if (ANEContext.ctx) {
            try {
                ANEContext.ctx.call("addChildToNativeStage", nativeDisplayObject);
                nativeDisplayObject.isAdded = true;
            } catch (e:Error) {
                trace(e.message);
            }
        }
    }

    public static function init(viewPort:Rectangle, visible:Boolean, transparent:Boolean, backgroundColor:uint = 0):void {
        _viewPort = viewPort;
        _visible = visible;
        if (ANEContext.ctx) {
            try {
                ANEContext.ctx.call("initNativeStage", _viewPort, _visible, transparent, backgroundColor);
            } catch (e:Error) {
                trace(e.message);
            }
        }
    }

    public static function add():void {
        if (ANEContext.ctx) {
            try {
                ANEContext.ctx.call("addNativeStage");
            } catch (e:Error) {
                trace(e.message);
            }
        }
    }

    public static function get viewPort():Rectangle {
        return _viewPort;
    }

    public static function set viewPort(value:Rectangle):void {
        _viewPort = value;
        update("viewPort", value);
    }

    public static function get visible():Boolean {
        return _visible;
    }

    public static function set visible(value:Boolean):void {
        _visible = value;
        update("visible", value);
    }

    private static function update(type:String, value:*):void {
        if (ANEContext.ctx) {
            try {
                ANEContext.ctx.call("updateNativeStage", type, value);
            } catch (e:Error) {
                trace(e.message);
            }
        }
    }

}
}
