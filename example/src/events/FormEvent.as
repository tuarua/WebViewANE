package events {
	import starling.events.Event;
	
	public class FormEvent extends Event {
		public static const ON_DROPDOWN:String = "onDropDown";
		public static const FOCUS_OUT:String = "onFocusOut";
		public static const FOCUS_IN:String = "onFocusIn";
		public static const CHANGE:String = "onChange";
        public static const ENTER:String = "onEnter";
		public var params:Object;
		public function FormEvent(type:String, _params:Object=null, bubbles:Boolean=false, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
			this.params = _params;
		}
	}
}