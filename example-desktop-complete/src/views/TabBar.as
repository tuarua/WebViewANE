/*
 * Copyright Tua Rua Ltd. (c) 2018.
 */

package views {
import com.tuarua.NewTabBtn;

import events.TabEvent;

import flash.display.Shape;
import flash.display.Sprite;
import flash.events.MouseEvent;

public class TabBar extends Sprite {
    private var bg:Shape = new Shape();
    private var newTabBtn:NewTabBtn = new NewTabBtn();
    public var tabs:Vector.<Tab> = new <Tab>[];
    private var tabHolder:Sprite = new Sprite();

    public function TabBar() {
        super();
        bg.graphics.beginFill(0xFFFFFF);
        bg.graphics.drawRect(0, 0, 1920, 32);
        bg.graphics.endFill();

        newTabBtn.addEventListener(MouseEvent.CLICK, onNewTab);
        newTabBtn.x = 202;

        addChild(bg);

        var tab:Tab = new Tab(0);
        tabs.push(tab);
        tabHolder.addChild(tab);

        addChild(tabHolder);
        addChild(newTabBtn);

    }

    private function onNewTab(event:MouseEvent):void {
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
        this.dispatchEvent(new TabEvent(TabEvent.ON_NEW_TAB));
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
        tabHolder.removeChildAt(index);
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
