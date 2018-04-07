package com.tuarua.utils {
import com.tuarua.WebViewANE;

import flash.system.Capabilities;

public final class os {
    private static const platform:String = Capabilities.version.substr(0, 3);
    public static const isWindows:Boolean = platform == "WIN";
    public static const isOSX:Boolean = platform == "MAC";
    public static const isAndroid:Boolean = platform == "AND";
    public static const isIos:Boolean = platform == "IOS";

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