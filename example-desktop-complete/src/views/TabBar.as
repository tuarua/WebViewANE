/*
 * Copyright Tua Rua Ltd. (c) 2017.
 */
package views {
import events.InteractionEvent;

import starling.display.Image;
import starling.display.Quad;
import starling.display.Sprite;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;

public class TabBar extends Sprite {
    private var bg:Quad = new Quad(1920, 32, 0xFFFFFF);
    private var newTabBtn:Image = new Image(Assets.getAtlas().getTexture("new-tab-btn"));
    public var tabs:Vector.<Tab> = new <Tab>[];
    private var tabHolder:Sprite = new Sprite();

    public function TabBar() {
        bg.touchable = false;
        addChild(bg);

        newTabBtn.useHandCursor = true;
        newTabBtn.addEventListener(TouchEvent.TOUCH, onNewTab);
        newTabBtn.x = 202;


        var tab:Tab = new Tab(0);
        tabs.push(tab);
        tabHolder.addChild(tab);

        addChild(tabHolder);
        addChild(newTabBtn);

    }

    private function onNewTab(event:TouchEvent):void {
        var touch:Touch = event.getTouch(newTabBtn);
        if (touch != null && touch.phase == TouchPhase.ENDED) {
            var tab:Tab = new Tab(tabs.length);
            tabs.push(tab);
            tab.x = ((tabs.length - 1) * 202);
            tabHolder.addChild(tab);
            newTabBtn.x = (tabs.length * 202);
            if (tabs.length > 5) {
                newTabBtn.visible = false;
            }
            for (var i:int = 0, l:int = tabs.length; i < l; ++i) {
                tabs[i].hasCloseButton = (l > 1);
            }
            this.dispatchEvent(new InteractionEvent(InteractionEvent.ON_NEW_TAB));
        }
    }

    public function setTabTitle(tab:int, value:String):void {
        tabs[tab].setTitle(value);
    }

    public function closeTab(index:int):void {
        tabs.removeAt(index);
        newTabBtn.x = (tabs.length * 202);
        for (var i:int = 0, l:int = tabs.length; i < l; ++i) {
            tabs[i].x = (i * 202);
            tabs[i].index = i;
            tabs[i].hasCloseButton = (l > 1);
        }
        tabHolder.removeChildAt(index, true);
        if (tabs.length > 5) {
            newTabBtn.visible = false;
        }
    }

    public function setActiveTab(index:int):void {
        for (var i:int = 0, l:int = tabs.length; i < l; ++i) {
            tabs[i].isActive = (i == index);
        }
    }

}
}
