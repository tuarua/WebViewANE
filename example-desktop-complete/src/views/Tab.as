/*
 * Copyright Tua Rua Ltd. (c) 2018.
 */

package views {
import com.tuarua.CloseTabBtn;

import events.TabEvent;

import flash.display.Shape;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.text.AntiAliasType;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;

public class Tab extends Sprite {
    private var bgActive:Shape = new Shape();
    private var bgInactive:Sprite = new Sprite();
    private var titleTxt:TextField = new TextField();
    private var _isActive:Boolean = false;
    private var _index:int = 0;
    private var closeTab:CloseTabBtn = new CloseTabBtn();
    public function Tab(index:int) {
        bgActive.graphics.beginFill(0xF1F1F1);
        bgActive.graphics.drawRect(0,0,200,32);
        bgActive.graphics.endFill();

        bgInactive.graphics.beginFill(0xF1F1F1);
        bgInactive.graphics.drawRect(0,0,200,32);
        bgInactive.graphics.endFill();

        this._index = index;
        bgInactive.alpha = 0.5;
        bgInactive.visible = false;

        bgInactive.addEventListener(MouseEvent.CLICK, onSwitchTab);
        closeTab.addEventListener(MouseEvent.CLICK, onCloseTab);

        closeTab.visible = (index > 0);

        addChild(bgInactive);
        addChild(bgActive);


        var textFormat:TextFormat = new TextFormat();
        textFormat.font = WebViewANESample.FONT.fontName;
        textFormat.size = 11;
        textFormat.align = TextFormatAlign.LEFT;
        textFormat.kerning = true;
        textFormat.color = 0x454545;

        titleTxt.width = 172;
        titleTxt.height = 20;
        titleTxt.wordWrap = titleTxt.multiline = false;
        titleTxt.selectable = false;
        titleTxt.defaultTextFormat = textFormat;
        titleTxt.embedFonts = true;
        titleTxt.antiAliasType = AntiAliasType.ADVANCED;
        titleTxt.text = "";
        titleTxt.mouseEnabled = false;

        titleTxt.x = 24;
        titleTxt.y = 8;

        closeTab.useHandCursor = true;
        closeTab.x = 3;
        closeTab.y = 7;

        addChild(titleTxt);
        addChild(closeTab);

    }

    private function onCloseTab(event:MouseEvent):void {
        this.dispatchEvent(new TabEvent(TabEvent.ON_CLOSE_TAB, {index: _index}, true));
    }

    private function onSwitchTab(event:MouseEvent):void {
        this.dispatchEvent(new TabEvent(TabEvent.ON_SWITCH_TAB, {index: _index}, true));
    }

    public function setTitle(value:String):void {
        titleTxt.text = value;
    }

    public function get isActive():Boolean {
        return _isActive;
    }

    public function set isActive(value:Boolean):void {
        _isActive = value;
        bgInactive.visible = !_isActive;
        bgActive.visible = _isActive;
    }

    public function get index():int {
        return _index;
    }

    public function set index(value:int):void {
        _index = value;

    }

    public function set hasCloseButton(value:Boolean):void {
        closeTab.visible = value;
    }

}
}
