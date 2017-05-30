/**
 * Created by Eoin Landy on 18/05/2017.
 */
package com.tuarua.fre.display {
import flash.display.Bitmap;
import flash.display.BitmapData;

[RemoteClass(alias="com.tuarua.fre.display.NativeImage")]
public class NativeImage extends NativeDisplayObject {
    private var _bitmap:Bitmap;
    public var bitmapData:BitmapData;

    public function NativeImage(bitmap:Bitmap) {
        _bitmap = bitmap;
        bitmapData = _bitmap.bitmapData;
        this.type = IMAGE_TYPE;
    }

}
}
