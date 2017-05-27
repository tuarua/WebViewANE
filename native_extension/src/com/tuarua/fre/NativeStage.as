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
