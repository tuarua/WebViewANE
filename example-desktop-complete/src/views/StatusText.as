/*
 * Copyright Tua Rua Ltd. (c) 2018.
 */

package views {
import flash.text.AntiAliasType;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;

public class StatusText extends TextField {
    public function StatusText() {
        super();

        var textFormat:TextFormat = new TextFormat();
        textFormat.font = WebViewANESample.FONT.fontName;
        textFormat.size = 13;
        textFormat.align = TextFormatAlign.LEFT;
        textFormat.kerning = true;
        textFormat.color = 0x454545;

        this.width = 1280;
        this.height = 20;
        this.wordWrap = multiline = false;
        this.selectable = false;
        this.defaultTextFormat = textFormat;
        this.embedFonts = true;
        this.x = 5;
        this.antiAliasType = AntiAliasType.ADVANCED;
        this.sharpness = -100;
        this.text = "";

    }
}
}
