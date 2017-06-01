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
 * Created by Eoin Landy on 29/04/2017.
 */
package com.tuarua.fre {
[RemoteClass(alias="com.tuarua.fre.ANEError")]
public class ANEError extends Error {
    private var _stackTrace:String;
    private var _source:String;
    private var _type:String;

    private var errorTypes:Array = [
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