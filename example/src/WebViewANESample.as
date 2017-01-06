package {
import flash.desktop.NativeApplication;
import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.geom.Rectangle;

import starling.core.Starling;
import starling.events.Event;


[SWF(width="1280", height="800", frameRate="60", backgroundColor="#F1F1F1")]
public class WebViewANESample extends Sprite {
    public var mStarling:Starling;

    public function WebViewANESample() {

        super();

        stage.align = StageAlign.TOP_LEFT;
        stage.scaleMode = StageScaleMode.NO_SCALE;
        Starling.multitouchEnabled = false;
        var viewPort:Rectangle = new Rectangle(0, 0, stage.stageWidth, stage.stageHeight);


        mStarling = new Starling(StarlingRoot, stage, viewPort, null, "auto", "auto");
        mStarling.addEventListener(starling.events.Event.ROOT_CREATED,
                function onRootCreated(event:Object, app:StarlingRoot):void {
                    mStarling.removeEventListener(starling.events.Event.ROOT_CREATED, onRootCreated);
                    app.start();
                    mStarling.start();
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

}
}