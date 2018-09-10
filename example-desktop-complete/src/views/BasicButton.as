/*
 * Copyright Tua Rua Ltd. (c) 2018.
 */

package views {
import flash.display.Shape;
import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.text.AntiAliasType;
import flash.text.TextField;
import flash.text.TextFormat;

public class BasicButton extends SimpleButton {
    public function BasicButton(text:String, w:int = 192) {
        var container:Sprite = new Sprite();
        var bg:Shape = new Shape();
        bg.graphics.beginFill(0x777777);
        bg.graphics.drawRect(0, 0, w, 36);
        bg.graphics.endFill();

        var lbl:TextField = new TextField();
        lbl.selectable = false;
        lbl.width = w;
        lbl.y = 7;

        lbl.wordWrap = lbl.multiline = false;
        lbl.selectable = false;
        lbl.embedFonts = true;
        lbl.antiAliasType = AntiAliasType.ADVANCED;
        lbl.sharpness = -100;

        var tf:TextFormat = new TextFormat(WebViewANESample.FONT.fontName, 13, 0xFFFFFF);
        tf.align = "center";
        tf.bold = false;
        lbl.defaultTextFormat = tf;
        lbl.text = text;

        container.addChild(bg);
        container.addChild(lbl);
        container.cacheAsBitmap = true;
        this.upState = container;
        this.downState = container;
        this.overState = container;
        this.hitTestState = container;
        this.useHandCursor = false;
    }
}
}
