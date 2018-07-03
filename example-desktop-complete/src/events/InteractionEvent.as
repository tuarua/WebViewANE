/*
 * Copyright Tua Rua Ltd. (c) 2017.
 */

package events {
import starling.events.Event;

public class InteractionEvent extends Event {
    public static const ON_NEW_TAB:String = "onNewTab";
    public static const ON_SWITCH_TAB:String = "onSwitchTab";
    public static const ON_CLOSE_TAB:String = "onCloseTab";
    public var params:Object;
    public function InteractionEvent(type:String, _params:Object=null, bubbles:Boolean=false, cancelable:Boolean=false) {
        super(type, bubbles, cancelable);
        this.params = _params;
    }
}
}
