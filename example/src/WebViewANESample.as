package {
import flash.desktop.NativeApplication;
import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.events.FullScreenEvent;
import flash.geom.Rectangle;
import flash.system.Capabilities;

import starling.core.Starling;
import starling.events.Event;
import starling.events.ResizeEvent;


[SWF(width="1280", height="800", frameRate="60", backgroundColor="#F1F1F1")]
public class WebViewANESample extends Sprite {
    public var mStarling:Starling;
    public static var target:WebViewANESample;
    private static var _app:StarlingRoot;

    public function WebViewANESample() {

        super();
        WebViewANESample.target = this;
        stage.align = StageAlign.TOP_LEFT;
        stage.scaleMode = StageScaleMode.NO_SCALE;
        
        Starling.multitouchEnabled = false;
        var viewPort:Rectangle = new Rectangle(0, 0, stage.stageWidth, stage.stageHeight);


        mStarling = new Starling(StarlingRoot, stage, viewPort, null, "auto", "auto");
        mStarling.addEventListener(starling.events.Event.ROOT_CREATED,
                function onRootCreated(event:Object, app:StarlingRoot):void {
                    _app = app;
                    mStarling.removeEventListener(starling.events.Event.ROOT_CREATED, onRootCreated);
                    _app.start();
                    mStarling.start();
                    stage.addEventListener(ResizeEvent.RESIZE, onResize);
                });

        mStarling.stage.stageWidth = stage.stageWidth;  // <- same size on all devices!
        mStarling.stage.stageHeight = stage.stageHeight;
        mStarling.simulateMultitouch = false;
        mStarling.showStatsAt("right", "bottom");
        mStarling.enableErrorChecking = false;
        mStarling.antiAliasing = 16;
        mStarling.skipUnchangedFrames = true;


        NativeApplication.nativeApplication.executeInBackground = true;

    }



    private function onResize(e:flash.events.Event):void {
        mStarling.stage.stageWidth = this.stage.stageWidth;
        mStarling.stage.stageHeight = this.stage.stageHeight;

        var viewPort:Rectangle = mStarling.viewPort;
        viewPort.width = this.stage.stageWidth;
        viewPort.height = this.stage.stageHeight;
        try {
            mStarling.viewPort = viewPort;
        }
        catch(error:Error) {}


        _app.appWidth = viewPort.width;
        _app.appHeight = viewPort.height;
        _app.updateWebViewOnResize();

        // if(CONFIG::STARLING_DEBUG && BuildMode.isDebugBuild()) {
        mStarling.showStatsAt("right","bottom");
        mStarling.showStats = true;
        //}

    }

}
}