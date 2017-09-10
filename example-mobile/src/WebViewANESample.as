package {
import flash.desktop.NativeApplication;
import flash.display.Bitmap;
import flash.display.Loader;
import flash.display.Sprite;
import flash.events.Event;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.system.System;
import flash.utils.ByteArray;

import starling.core.Starling;
import starling.events.Event;
import starling.utils.AssetManager;
import starling.utils.StringUtil;
import starling.utils.SystemUtil;

import utils.ProgressBar;
import utils.ScreenSetup;
[SWF(width="320", height="480", frameRate="60", backgroundColor="#F1F1F1")]
public class WebViewANESample extends Sprite {
    [Embed(source="ttf/fira-sans-embed.ttf", embedAsCFF="false", fontFamily="Fira Sans", fontWeight="SemiBold")]
    private static const firaSansEmbedded:Class;

    private var mStarling:Starling;
    private var logo:Loader;
    private var progressBar:ProgressBar;

    public function WebViewANESample() {
        // The "ScreenSetup" class is part of the "utils" package of this project.
        // It figures out the perfect scale factor and stage size for the given device.
        // The third parameter describes the available asset sets (here, '1x' and '2x').

        var screen:ScreenSetup = new ScreenSetup(stage.fullScreenWidth, stage.fullScreenHeight, [1, 2]);

        Starling.multitouchEnabled = true; // we want to make use of multitouch

        mStarling = new Starling(StarlingRoot, stage, screen.viewPort);
        mStarling.stage.stageWidth = screen.stageWidth;
        mStarling.stage.stageHeight = screen.stageHeight;
        mStarling.skipUnchangedFrames = true;
        mStarling.addEventListener(starling.events.Event.ROOT_CREATED, function ():void {
            loadAssets(screen.assetScale, startGame);
        });

        mStarling.start();
        initLoadingScreen(screen.assetScale);

        if (!SystemUtil.isDesktop) {
            NativeApplication.nativeApplication.addEventListener(
                    flash.events.Event.ACTIVATE, function (e:*):void {
                        mStarling.start();
                    });
            NativeApplication.nativeApplication.addEventListener(
                    flash.events.Event.DEACTIVATE, function (e:*):void {
                        mStarling.stop(true);
                    });
        }
    }

    private function loadAssets(scale:int, onComplete:Function):void {
        // Our assets are loaded and managed by the 'AssetManager'. To use that class,
        // we first have to enqueue pointers to all assets we want it to load.

        var appDir:File = File.applicationDirectory;
        var assets:AssetManager = new AssetManager(scale);

        assets.verbose = false;
        assets.enqueue(
                appDir.resolvePath(StringUtil.format("textures/{0}x", scale))
        );

        // Now, while the AssetManager now contains pointers to all the assets, it actually
        // has not loaded them yet. This happens in the "loadQueue" method; and since this
        // will take a while, we'll update the progress bar accordingly.

        assets.loadQueue(function (ratio:Number):void {
            progressBar.ratio = ratio;
            if (ratio == 1) {
                // now would be a good time for a clean-up
                System.pauseForGCIfCollectionImminent(0);
                System.gc();

                onComplete(assets);
            }
        });
    }

    private function startGame(assets:AssetManager):void {
        var root:StarlingRoot = mStarling.root as StarlingRoot;
        root.start(assets);
        removeLoadingScreen();
    }

    private function initLoadingScreen(scale:int):void {
        var overlay:Sprite = mStarling.nativeOverlay;
        var stageWidth:Number = mStarling.stage.stageWidth;
        var stageHeight:Number = mStarling.stage.stageHeight;

        // On iOS, the "Default.png" image (or one of its variants) is shown while the app
        // starts up. For an absolutely seamless transition, we recreate its contents
        // in the classic display list via the stage color and the logo.
        // Loading the logo from a file and displaying it in the same frame -> that's only
        // possible via the FileStream calls below.

        var bgPath:String = StringUtil.format("textures/{0}x/logo.png", scale);
        var bgFile:File = File.applicationDirectory.resolvePath(bgPath);
        var bytes:ByteArray = new ByteArray();
        var stream:FileStream = new FileStream();
        stream.open(bgFile, FileMode.READ);
        stream.readBytes(bytes, 0, stream.bytesAvailable);
        stream.close();

        logo = new Loader();
        logo.loadBytes(bytes);
        logo.scaleX = 1.0 / scale;
        logo.scaleY = 1.0 / scale;
        overlay.addChild(logo);

        logo.contentLoaderInfo.addEventListener(flash.events.Event.COMPLETE,
                function (e:Object):void {
                    (logo.content as Bitmap).smoothing = true;
                    logo.x = (stageWidth - logo.width) / 2;
                    logo.y = (stageHeight - logo.height) / 2;
                });

        // While the assets are loaded, we will display a progress bar.

        progressBar = new ProgressBar(175, 20);
        progressBar.x = (stageWidth - progressBar.width) / 2;
        progressBar.y = stageHeight * 0.8;
        mStarling.nativeOverlay.addChild(progressBar);
    }

    private function removeLoadingScreen():void {
        if (logo) {
            mStarling.nativeOverlay.removeChild(logo);
            logo = null;
        }

        if (progressBar) {
            mStarling.nativeOverlay.removeChild(progressBar);
            progressBar = null;
        }
    }
}
}