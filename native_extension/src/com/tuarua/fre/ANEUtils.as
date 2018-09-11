/*
 * Copyright 2018 Tua Rua Ltd.
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
import flash.utils.describeType;
import flash.utils.getDefinitionByName;
import flash.utils.getQualifiedClassName;

/** @private */
public class ANEUtils {
    public function ANEUtils() {
    }

    public static function getClass(obj:Object):Class {
        return Class(getDefinitionByName(getQualifiedClassName(obj)));
    }

    public function getClass(obj:Object):Class {
        return Class(getDefinitionByName(getQualifiedClassName(obj)));
    }

    public static function getClassProps(clz:*):Vector.<Object> {
        var ret:Vector.<Object> = new <Object>[];
        var isObject:Boolean = false;
        for (var id:String in clz) {
            var objc:Object = {};
            objc.name = id;
            if (clz.hasOwnProperty(id)) {
                objc.type = getClassType(clz[id]);
                objc.cls = objc.type == "*" ? null : getClass(Class(getDefinitionByName(objc.type)));
                ret.push(objc);
                isObject = true;
            }
        }
        if (isObject) {
            return ret;
        }
        var xml:XML = describeType(clz);
        if (xml.variable && xml.variable.length() > 0) {
            for each (var prop:XML in xml.variable) {
                var obj:Object = {};
                obj.name = prop.@name.toString();
                obj.type = prop.@type.toString();
                obj.cls = obj.type == "*" ? null : getClass(Class(getDefinitionByName(obj.type)));
                ret.push(obj);
            }
        } else if (xml.factory && xml.factory.variable && xml.factory.variable.length() > 0) {
            for each (var propb:XML in xml.factory.variable) {
                var objb:Object = {};
                objb.name = propb.@name.toString();
                objb.type = propb.@type.toString();
                objb.cls = objb.type == "*" ? null : getClass(Class(getDefinitionByName(objb.type)));
                ret.push(objb);
            }
        }
        return ret;
    }

    public function getClassProps(clz:*):Vector.<Object> {
        var ret:Vector.<Object> = new <Object>[];
        var isObject:Boolean = false;
        for (var id:String in clz) {
            var objc:Object = {};
            objc.name = id;
            if (clz.hasOwnProperty(id)) {
                objc.type = getClassType(clz[id]);
                objc.cls = objc.type == "*" ? null : getClass(Class(getDefinitionByName(objc.type)));
                ret.push(objc);
                isObject = true;
            }
        }
        if (isObject) {
            return ret;
        }
        var xml:XML = describeType(clz);
        if (xml.variable && xml.variable.length() > 0) {
            for each (var prop:XML in xml.variable) {
                var obj:Object = {};
                obj.name = prop.@name.toString();
                obj.type = prop.@type.toString();
                obj.cls = obj.type == "*" ? null : getClass(Class(getDefinitionByName(obj.type)));
                ret.push(obj);
            }
        } else if (xml.factory && xml.factory.variable && xml.factory.variable.length() > 0) {
            for each (var propb:XML in xml.factory.variable) {
                var objb:Object = {};
                objb.name = propb.@name.toString();
                objb.type = propb.@type.toString();
                objb.cls = objb.type == "*" ? null : getClass(Class(getDefinitionByName(objb.type)));
                ret.push(objb);
            }
        }
        return ret;
    }

    private static function getPropClass(name:String, cls:Class):Class {
        var clsProps:Vector.<Object> = getClassProps(cls);
        for each (var clsa:Object in clsProps) {
            if (clsa.name == name) {
                return clsa.cls;
            }
        }
        return null;
    }

    public static function map(from:Object, to:Class):Object {
        var classInstance:Object;
        classInstance = new to();
        for (var id:String in from) {
            var name:String = id;
            var propCls:Class;
            if (from[name] is String) {
                propCls = String;
            } else if (from[name] is Boolean) {
                propCls = Boolean;
            } else if (from[name] is int) {
                propCls = int;
            } else if (from[name] is Number) {
                propCls = Number;
            } else {
                propCls = getPropClass(name, to);
            }

            switch (propCls) {
                case String:
                case int:
                case Number:
                case Boolean:
                case Array:
                case Vector.<String>:
                case Vector.<int>:
                case Vector.<Number>:
                case Vector.<Boolean>:
                    classInstance[name] = from[name];
                    break;
                case Date:
                    classInstance[name] = new Date(Date.parse(from[name]));
                    break;
                default: //Object or Class
                    classInstance[name] = (propCls == null) ? from[name] : map(from[name], getPropClass(name, to));
                    break;
            }

        }
        return classInstance;
    }

    public static function getClassType(clz:*):String {
        return getQualifiedClassName(clz);
    }

    public function getClassType(clz:*):String {
        return getQualifiedClassName(clz);
    }

}
}