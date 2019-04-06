package {
import com.tuarua.FreSwift;
import com.tuarua.WebViewANE;
import com.tuarua.webview.Settings;

import flash.display.Sprite;
import flash.events.Event;
import flash.geom.Rectangle;
import flash.net.URLRequest;

[SWF(width="1024", height="768", frameRate="60", backgroundColor="#F1F1F1")]
public class WebViewExampleAS3 extends Sprite {
    private var freSwiftANE:FreSwift = new FreSwift();//must create before all others
    private var webview:WebViewANE = new WebViewANE();
    private var hasActivated:Boolean;

    public function WebViewExampleAS3() {
        this.addEventListener(Event.ACTIVATE, onActivated);
    }

    protected function onActivated(event:Event):void {
        if (hasActivated) return;
        hasActivated = true;
        var viewport:Rectangle = new Rectangle(0, 0, 1024, 768);
        var settings:Settings = new Settings();
        webview.init(stage, viewport, new URLRequest("https://html5test.com"), settings, 1, 0xFFF1F1F1);
        webview.visible = true;
    }
}
}