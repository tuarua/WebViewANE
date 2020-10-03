/*
 * Copyright Tua Rua Ltd. (c) 2018.
 */

package views {
import flash.display.Sprite;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.text.AntiAliasType;
import flash.text.TextField;
import flash.text.TextFieldType;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import flash.ui.Keyboard;

public class Input extends Sprite {
    private static const w:int = 802;
    public static const ENTER:String = "OnEnter";

    public var input:TextField = new TextField();

    public function Input() {
        super();
        this.graphics.beginFill(0xAAAAAA);
        this.graphics.drawRect(0, 0, w, 24);
        this.graphics.endFill();

        this.graphics.beginFill(0xFFFFFF);
        this.graphics.drawRect(2, 2, w-4, 20);
        this.graphics.endFill();

        var textFormat:TextFormat = new TextFormat();
        textFormat.font = Main.FONT.fontName;
        textFormat.size = 13;
        textFormat.align = TextFormatAlign.LEFT;
        textFormat.kerning = true;
        textFormat.color = 0x454545;

        input.width = w - 10;
        input.height = 24;
        input.wordWrap = input.multiline = false;
        input.selectable = true;
        input.defaultTextFormat = textFormat;
        input.embedFonts = true;
        input.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
        input.x = 5;
        input.antiAliasType = AntiAliasType.ADVANCED;
        input.sharpness = -100;
        input.type = TextFieldType.INPUT;

        input.text = "";
        input.y = 0;
        input.setSelection(0, 1);
        addChild(input);

    }

    private function onKeyUp(event:KeyboardEvent):void {
        if (event.keyCode == Keyboard.ENTER) {
            this.dispatchEvent(new Event(ENTER, true));
        }
    }

    public function get text():String {
        return input.text;
    }

    public function set text(value:String):void {
        input.text = value;
    }

}
}
