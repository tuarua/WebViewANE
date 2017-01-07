/**
 * Created by User on 08/12/2016.
 */
package com.tuarua {
dynamic public class ANEObject extends Object {
    public var _propNames:Array = new Array();

    public function ANEObject() {
    }

    public function getPropNames():Array {
        for (var i:String in this) {
            _propNames.push(i);
        }
        return _propNames;
    }

    public function addPropName(name:String):void {
        _propNames.push(name);
    }
}
}
