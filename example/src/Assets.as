package {
import flash.display.Bitmap;
import flash.utils.Dictionary;

import starling.textures.Texture;
import starling.textures.TextureAtlas;

public class Assets {

    private static var textures:Dictionary = new Dictionary();
    private static var textureAtlas:TextureAtlas;

    [Embed(source="../sprite-sheet/atlas.png")]
    public static const AtlasTexture:Class;

    [Embed(source="../sprite-sheet/atlas.xml", mimeType="application/octet-stream")]
    public static const AtlasXml:Class;

    public static function getAtlas():TextureAtlas {
        if (textureAtlas == null) {
            var texture:Texture = getTexture("AtlasTexture");
            var xml:XML = XML(new AtlasXml());
            textureAtlas = new TextureAtlas(texture, xml);
        }
        return textureAtlas;
    }

    public static function getTexture(name:String, mm:Boolean = false):Texture {
        if (textures[name] == undefined) {
            var bitmap:Bitmap = new Assets[name]();
            textures[name] = Texture.fromBitmap(bitmap, mm);
        }
        return textures[name];
    }
}
}