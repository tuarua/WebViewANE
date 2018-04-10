package com.tuarua.utils {
import com.tuarua.WebViewANE;

import flash.system.Capabilities;

public final class os {
    private static const platform:String = Capabilities.version.substr(0, 3).toLowerCase();
    public static const isWindows:Boolean = platform == "win";
    public static const isOSX:Boolean = platform == "mac";
    public static const isAndroid:Boolean = platform == "and";
    public static const isIos:Boolean = platform == "ios" && Capabilities.os.toLowerCase().indexOf("tvos") == -1;
    public static const isTvos:Boolean = Capabilities.os.toLowerCase().indexOf("tvos") > -1;

    private static var _majorVersion:int;
    private static var _minorVersion:int;
    private static var _buildVersion:int;
    private static var hasCalled:Boolean;

    public static function get majorVersion():int {
        if (hasCalled) return _majorVersion;
        getVersion();
        return _majorVersion;
    }

    public static function get minorVersion():int {
        if (hasCalled) return _minorVersion;
        getVersion();
        return _minorVersion;
    }

    public static function get buildVersion():int {
        if (hasCalled) return _buildVersion;
        getVersion();
        return _buildVersion;
    }

    private static function getVersion():void {
        var arr:Array = WebViewANE.context.call("getOsVersion") as Array;
        _majorVersion = arr[0];
        _minorVersion = arr[1];
        _buildVersion = arr[2];
        hasCalled = true;
    }

}
}