/*
 * Copyright Tua Rua Ltd. (c) 2017.
 */

/**
 * Created by User on 23/06/2017.
 */
package views {
import events.InteractionEvent;

import starling.display.Image;
import starling.display.Quad;
import starling.display.Sprite;
import starling.text.TextField;
import starling.text.TextFormat;
import starling.utils.Align;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;

public class Tab extends Sprite {
    private var bgActive:Quad = new Quad(200, 32, 0xF1F1F1);
    private var bgInactive:Quad = new Quad(200, 32, 0xF1F1F1);
    private var titleTxt:TextField;
    private var _isActive:Boolean = false;
    private var _index:int = 0;
    private var closeTab:Image = new Image(Assets.getAtlas().getTexture("close-tab-btn"));

    public function Tab(index:int) {
        super();
        this._index = index;
        bgInactive.alpha = 0.5;
        bgInactive.visible = false;

        bgInactive.touchable = true;
        bgActive.touchable = false;

        bgInactive.useHandCursor = true;
        bgInactive.addEventListener(TouchEvent.TOUCH, onSwitchTab);
        closeTab.addEventListener(TouchEvent.TOUCH, onCloseTab);

        closeTab.visible = (index > 0);

        addChild(bgInactive);
        addChild(bgActive);


        var tf:TextFormat = new TextFormat();
        tf.setTo("Fira Sans Semi-Bold 13", 11);
        tf.verticalAlign = Align.TOP;
        tf.horizontalAlign = Align.LEFT;
        tf.color = 0x666666;

        titleTxt = new TextField(175, 20, "");
        titleTxt.format = tf;

        titleTxt.batchable = true;
        titleTxt.touchable = false;
        titleTxt.x = 24;
        titleTxt.y = 10;

        closeTab.useHandCursor = true;
        closeTab.x = 3;
        closeTab.y = 7;

        addChild(titleTxt);
        addChild(closeTab);
    }

    private function onSwitchTab(event:TouchEvent):void {
        var touch:Touch = event.getTouch(bgInactive);
        if (touch != null && touch.phase == TouchPhase.ENDED) {
            this.dispatchEvent(new InteractionEvent(InteractionEvent.ON_SWITCH_TAB, {index: _index}, true));
        }
    }

    private function onCloseTab(event:TouchEvent):void {
        var touch:Touch = event.getTouch(closeTab);
        if (touch != null && touch.phase == TouchPhase.ENDED) {
            this.dispatchEvent(new InteractionEvent(InteractionEvent.ON_CLOSE_TAB, {index: _index}, true));
        }
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
