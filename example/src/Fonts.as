package {
	import flash.utils.Dictionary;
	
	import starling.text.BitmapFont;
	import starling.textures.Texture;

	public class Fonts {
		[Embed(source="../fonts/fira-sans-semi-bold-13.fnt", mimeType="application/octet-stream")]
		private static const FiraRegular13XML:Class;
		private static var fonts:Dictionary = new Dictionary();
		public static function getFont(_name:String):BitmapFont {
			if(fonts["fira-sans-semi-bold-13"] == undefined)
				fonts["fira-sans-semi-bold-13"] = XML(new FiraRegular13XML());
			var fntTexture:Texture = Assets.getAtlas().getTexture(_name);
			return new BitmapFont(fntTexture, fonts[_name] );
		}
		
	}
}