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
 * Created by User on 26/02/2017.
 */
package com.tuarua.fre {
import flash.utils.describeType;

[RemoteClass(alias="com.tuarua.fre.ANEUtils")]
public class ANEUtils {
    public function ANEUtils() {
    }

    public function getClassProps(clz:*):Vector.<Object> {
        var ret:Vector.<Object> = new <Object>[];
        var xml:XML = describeType(clz);
        for each (var prop:XML in xml.variable) {
            var obj:Object = new Object();
            obj.name = prop.@name.toString();
            obj.type = prop.@type.toString();
            ret.push(obj);
            //trace(obj.name, obj.type);
        }
        return ret;
    }

    public function getClassType(clz:*):String {
        var xml:XML = describeType(clz);
        return xml.@name;
    }

}
}