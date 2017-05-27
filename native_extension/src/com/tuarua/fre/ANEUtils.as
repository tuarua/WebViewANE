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