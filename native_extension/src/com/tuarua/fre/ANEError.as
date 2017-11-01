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
 */

package com.tuarua.fre {
import flash.system.Capabilities;

[RemoteClass(alias="com.tuarua.fre.ANEError")]
public class ANEError extends Error {
    private var _stackTrace:String;
    private var _source:String;
    private var _type:String;

    private static const errorTypesCSharp:Array = [
        "FreSharp.Exceptions.Ok",
        "FreSharp.Exceptions.NoSuchNameException",
        "FreSharp.Exceptions.FreInvalidObjectException",
        "FreSharp.Exceptions.FreTypeMismatchException",
        "FreSharp.Exceptions.FreActionscriptErrorException",
        "FreSharp.Exceptions.FreInvalidArgumentException",
        "FreSharp.Exceptions.FreReadOnlyException",
        "FreSharp.Exceptions.FreWrongThreadException",
        "FreSharp.Exceptions.FreIllegalStateException",
        "FreSharp.Exceptions.FreInsufficientMemoryException"
    ];

    private static const errorTypesKotlin:Array = [
        "FreKotlin.Exceptions.Ok",
        "FreKotlin.Exceptions.FRENoSuchNameException",
        "FreKotlin.Exceptions.FREInvalidObjectException",
        "FreKotlin.Exceptions.FRETypeMismatchException",
        "FreKotlin.Exceptions.FREASErrorException",
        "FreKotlin.Exceptions.FreInvalidArgumentException",
        "FreKotlin.Exceptions.FREReadOnlyException",
        "FreKotlin.Exceptions.FREWrongThreadException",
        "FreKotlin.Exceptions.FreIllegalStateException",
        "FreKotlin.Exceptions.FreInsufficientMemoryException"
    ];

    private static const errorTypesSwift:Array = [
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

    private function getErrorID(thetype:String):int {
        var val:int;
        if (Capabilities.os.toLowerCase().indexOf("win") == 0) {
            val = errorTypesCSharp.indexOf(thetype);
        }else if (Capabilities.os.toLowerCase().indexOf("linux") == 0){
            val = errorTypesKotlin.indexOf(thetype);
        } else {
            val = errorTypesSwift.indexOf(thetype);
        }
        if (val == -1) val = 10;
        return val;
    }

    //noinspection ReservedWordAsName
    public function get type():String {
        return _type;
    }

    public function get source():String {
        return _source;
    }

}
}