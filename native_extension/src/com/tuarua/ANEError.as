/**
 * Created by Eoin Landy on 29/04/2017.
 */
package com.tuarua {
[RemoteClass(alias="com.tuarua.ANEError")]
public class ANEError extends Error {
    private var _stackTrace:String;
    private var _source:String;
    private var _type:String;

    private var errorTypes:Array = [
        "ok",
        "noSuchName",
        "invalidObject",
        "typeMismatch",
        "actionscriptError",
        "invalidArgument",
        "readOnly",
        "wrongThread",
        "illegalState",
        "insufficientMemory"
    ];

    public function ANEError(message:String, errorID:int, type:String, source:String, stackTrace:String) {
        _stackTrace = stackTrace;
        _source = source;
        _type = type;
        super(message, getErrorID(_type));
    }

    override public function get errorID():int {
        return super.errorID;
    }

    override public function getStackTrace():String {
        return _stackTrace;
    }

    private function getErrorID(type:String):int {
        var val:int = errorTypes.indexOf(type);
        if(val == -1) val = 10;
        return val;
    }

    public function get type():String {
        return _type;
    }

    public function get source():String {
        return _source;
    }
}
}