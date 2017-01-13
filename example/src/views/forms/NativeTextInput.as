package views.forms {
import events.FormEvent;

import flash.display.Sprite;
import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.KeyboardEvent;
import flash.text.AntiAliasType;
import flash.text.Font;
import flash.text.TextField;
import flash.text.TextFieldType;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import flash.ui.Keyboard;

import starling.core.Starling;

public class NativeTextInput extends Sprite {
    public var input:TextField = new TextField();
    private var firaSansRegularFont:Font = new FiraSansSemiBold();
    private var defaultText:String;
    private var clearOnFocus:Boolean = false;
    private var originalType:String;
    private var textFormat:TextFormat;
    private var _fontSize:uint = 13;
    private var _type:String = TextFieldType.INPUT;
    private var _password:Boolean = false;
    private var _align:String = TextFormatAlign.LEFT;
    private var _maxChars:uint = 0;
    private var _restrict:String = null;
    private var _multiline:Boolean = false;
    private var _height:int = 24;

    public function NativeTextInput(_w:int, _txt:String, _clearOnFocus:Boolean = false, _fontColor:uint = 0x666666) {
        super();
        defaultText = _txt;
        clearOnFocus = _clearOnFocus;
        originalType = _type;

        textFormat = new TextFormat();
        textFormat.font = firaSansRegularFont.fontName;
        textFormat.size = _fontSize;
        textFormat.align = _align;
        textFormat.kerning = true;
        textFormat.color = _fontColor;

        input.width = _w;
        input.height = _height;
        input.multiline = _multiline;
        input.wordWrap = _multiline;
        input.selectable = true;
        input.defaultTextFormat = textFormat;
        input.embedFonts = true;
        input.addEventListener(KeyboardEvent.KEY_DOWN, onKeyUp);
        if (_restrict)
            input.restrict = _restrict;

        input.antiAliasType = AntiAliasType.ADVANCED;
        input.sharpness = -100;
        input.type = _type;

        input.addEventListener(Event.CHANGE, onTextInput);
        input.addEventListener(FocusEvent.FOCUS_IN, onFocusInput);
        input.text = _txt;
        input.y = 0;
        input.visible = false;
        //Starling.current.nativeOverlay.stage.focus = input;
        input.setSelection(0, 1);
        addChild(input);
    }

    private function onKeyUp(event:KeyboardEvent):void {
        if (event.keyCode == Keyboard.ENTER) {
            this.dispatchEvent(new Event(FormEvent.ENTER, true));
        }
    }

    public function enable(value:Boolean, withFade:Boolean = true):void {
        if (withFade) input.alpha = (value) ? 1.0 : 0.25;
        input.selectable = value;
        input.type = (value) ? originalType : TextFieldType.DYNAMIC;
    }

    public function show(value:Boolean):void {
        input.visible = value;
    }

    /*
     protected function onKeyUp(event:KeyboardEvent):void {
     if(event.charCode == 13)
     this.dispatchEvent(new Event("FOCUS_OUT",true));
     }
     */
    protected function onFocusInput(event:FocusEvent):void {
        if (input.text == defaultText && clearOnFocus)
            input.text = "";
    }

    protected function onInputFocusOut(event:FocusEvent):void {
        this.dispatchEvent(new Event("FOCUS_OUT", true));
    }

    protected function onTextInput(event:Event):void {
        this.dispatchEvent(new Event("CHANGE", true));
    }

    public function dispose():void {
        if (Starling.current.nativeOverlay.contains(this))
            Starling.current.nativeOverlay.removeChild(this);
    }

    public function set fontSize(value:uint):void {
        textFormat.size = _fontSize = value;
        input.setTextFormat(textFormat);
    }

    public function set align(value:String):void {
        textFormat.align = _align = value;
        input.setTextFormat(textFormat);
        input.defaultTextFormat = textFormat;
    }

    public function get align():String {
        return _align;
    }

    public function set type(value:String):void {
        originalType = input.type = _type = value;
    }

    public function set maxChars(value:uint):void {
        input.maxChars = _maxChars = value;
    }

    public function set password(value:Boolean):void {
        input.displayAsPassword = _password = value;
    }

    public function set restrict(value:String):void {
        input.restrict = _restrict = value;
    }

    public function set multiline(value:Boolean):void {
        input.wordWrap = input.multiline = _multiline = value;
    }

    public function setHeight(value:int):void {
        input.height = _height = value;
    }


}
}