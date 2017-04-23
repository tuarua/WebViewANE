package com.tuarua;

import android.annotation.TargetApi;
import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Color;
import android.os.Build;
import android.text.TextUtils;
import android.util.Log;
import android.view.Gravity;
import android.view.ViewGroup;
import android.webkit.CookieManager;
import android.webkit.GeolocationPermissions;
import android.webkit.JavascriptInterface;
import android.webkit.PermissionRequest;
import android.webkit.ValueCallback;
import android.webkit.WebChromeClient;
import android.webkit.WebResourceError;
import android.webkit.WebResourceRequest;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.RelativeLayout;

import com.adobe.fre.FREASErrorException;
import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREInvalidObjectException;
import com.adobe.fre.FRENoSuchNameException;
import com.adobe.fre.FREObject;
import com.adobe.fre.FRETypeMismatchException;
import com.adobe.fre.FREWrongThreadException;
import com.tuarua.webviewane.Settings;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.HashMap;
import java.util.Map;

import static android.webkit.PermissionRequest.RESOURCE_VIDEO_CAPTURE;

/**
 * Created by Eoin Landy on 21/03/2017.
 */

class WebViewANEContext extends FREContext {

    private String _initialUrl;
    private int _x;
    private int _y;
    private int _width;
    private int _height;
    private int _scaleFactor;

    private int bg_r = 255;
    private int bg_g = 255;
    private int bg_b = 255;
    private int bg_a = 255;

    private WebView webView;
    private RelativeLayout container;
    ViewGroup airView;

    public WebViewANEContext() {
    }

    @Override
    public Map<String, FREFunction> getFunctions() {
        Map<String, FREFunction> functionsToSet = new HashMap<>();
        functionsToSet.put("init", new init());
        functionsToSet.put("isSupported", new isSupported());
        functionsToSet.put("addToStage", new addToStage());
        functionsToSet.put("removeFromStage", new removeFromStage());
        functionsToSet.put("load", new load());
        functionsToSet.put("loadFileURL", new loadFileURL());
        functionsToSet.put("reload", new reload());
        functionsToSet.put("backForwardList", new backForwardList());
        functionsToSet.put("go", new go());
        functionsToSet.put("goBack", new goBack());
        functionsToSet.put("goForward", new goForward());
        functionsToSet.put("stopLoading", new stopLoading());
        functionsToSet.put("reloadFromOrigin", new reloadFromOrigin());
        functionsToSet.put("allowsMagnification", new allowsMagnification());
        functionsToSet.put("getMagnification", new getMagnification());
        functionsToSet.put("setMagnification", new setMagnification());
        functionsToSet.put("loadHTMLString", new loadHTMLString());
        functionsToSet.put("setPositionAndSize", new setPositionAndSize());
        functionsToSet.put("showDevTools", new showDevTools());
        functionsToSet.put("closeDevTools", new closeDevTools());
        functionsToSet.put("onFullScreen", new onFullScreen());
        functionsToSet.put("callJavascriptFunction", new callJavascriptFunction());
        functionsToSet.put("evaluateJavaScript", new evaluateJavaScript());
        functionsToSet.put("setBackgroundColor", new setBackgroundColor());
        functionsToSet.put("shutDown", new shutDown());
        functionsToSet.put("injectScript", new injectScript());
        functionsToSet.put("print", new print());
        functionsToSet.put("focus", new focus());

        return functionsToSet;
    }

    private class isSupported implements FREFunction {
        @Override
        public FREObject call(FREContext freContext, FREObject[] freObjects) {
            try {
                return FREObject.newObject((android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES
                        .LOLLIPOP));
            } catch (FREWrongThreadException e) {
                e.printStackTrace();
            }
            return null;
        }
    }

    @Override
    public void dispose() {

    }


    public class BoundObject {
        @JavascriptInterface
        public void postMessage(String json) {
            if (json != null) {
                dispatchStatusEventAsync(json, AirWebView.JS_CALLBACK_EVENT);
            }
            trace(json);
        }
    }

    public class AirWebView extends RelativeLayout {
        private static final String TRACE = "TRACE";
        public static final String AS_CALLBACK_EVENT = "TRWV.as.CALLBACK";
        public static final String JS_CALLBACK_EVENT = "TRWV.js.CALLBACK";
        private static final String ON_DOWNLOAD_PROGRESS = "WebView.OnDownloadProgress";
        private static final String ON_DOWNLOAD_COMPLETE = "WebView.OnDownloadComplete";
        private static final String ON_DOWNLOAD_CANCEL = "WebView.OnDownloadCancel";
        private static final String ON_PROPERTY_CHANGE = "WebView.OnPropertyChange";
        private static final String ON_FAIL = "WebView.OnFail";


        public AirWebView(Context context, Settings settings) {
            super(context);
            webView = new WebView(context);

            WebSettings webSettings = webView.getSettings();
            webSettings.setJavaScriptEnabled(settings.getJavaScriptEnabled());
            webSettings.setMediaPlaybackRequiresUserGesture(settings.getMediaPlaybackRequiresUserGesture());
            webSettings.setUserAgentString(settings.getUserAgent());
            webSettings.setJavaScriptCanOpenWindowsAutomatically(
                    settings.getJavaScriptCanOpenWindowsAutomatically());
            webSettings.setBlockNetworkImage(settings.getBlockNetworkImage());

            webSettings.setAllowContentAccess(settings.getAllowContentAccess());
            webSettings.setAllowFileAccess(settings.getAllowFileAccess());
            webSettings.setAllowFileAccessFromFileURLs(settings.getAllowFileAccessFromFileURLs());
            webSettings.setAllowUniversalAccessFromFileURLs(settings.getAllowUniversalAccessFromFileURLs());
            webSettings.setGeolocationEnabled(settings.getGeolocationEnabled());

            // AppRTC requires third party cookies to work
            CookieManager cookieManager = CookieManager.getInstance();
            cookieManager.setAcceptThirdPartyCookies(webView, true);

            //webSettings.setBuiltInZoomControls(true);

            webView.setHorizontalScrollBarEnabled(false);
            webView.setWebChromeClient(new WebChromeClient() {

                @Override
                public void onProgressChanged(WebView view, int newProgress) {
                    super.onProgressChanged(view, newProgress);
                    JSONObject jsonObject = new JSONObject();
                    try {
                        double progress = ((double) newProgress) * 0.01;
                        jsonObject.put("propName", "estimatedProgress");
                        jsonObject.put("value", progress);
                        dispatchStatusEventAsync(jsonObject.toString(), ON_PROPERTY_CHANGE);
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }
                }

                @Override
                public void onReceivedTitle(WebView view, String title) {
                    super.onReceivedTitle(view, title);
                    JSONObject jsonObject = new JSONObject();
                    try {
                        jsonObject.put("propName", "title");
                        jsonObject.put("value", title);
                        dispatchStatusEventAsync(jsonObject.toString(), ON_PROPERTY_CHANGE);
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }
                }

                @Override
                public void onPermissionRequest(final PermissionRequest request) {
                    request.grant(request.getResources());
                }

                @Override
                public void onPermissionRequestCanceled(PermissionRequest request) {
                    super.onPermissionRequestCanceled(request);
                    //trace("onPermissionRequestCanceled");
                }

                @Override
                public void onGeolocationPermissionsShowPrompt(String origin, GeolocationPermissions.Callback callback) {
                    //trace("onGeolocationPermissionsShowPrompt");
                    callback.invoke(origin, true, false);

                }

                @Override
                public void onGeolocationPermissionsHidePrompt() {
                    //trace("onGeolocationPermissionsHidePrompt");
                    super.onGeolocationPermissionsHidePrompt();
                }
            });
            webView.setWebViewClient(new WebViewClient() {
                @Override
                public void onReceivedError(WebView view, WebResourceRequest request, WebResourceError error) {
                    super.onReceivedError(view, request, error);
                }

                @Override
                public void onPageStarted(WebView view, String url, Bitmap favicon) {
                    super.onPageStarted(view, url, favicon);
                    JSONObject jsonObject = new JSONObject();
                    try {
                        jsonObject.put("propName", "isLoading");
                        jsonObject.put("value", true);
                        dispatchStatusEventAsync(jsonObject.toString(), ON_PROPERTY_CHANGE);
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }

                    jsonObject = new JSONObject();
                    try {
                        jsonObject.put("propName", "url");
                        jsonObject.put("value", url);
                        dispatchStatusEventAsync(jsonObject.toString(), ON_PROPERTY_CHANGE);
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }
                }

                @Override
                public void onPageFinished(WebView view, String url) {
                    super.onPageFinished(view, url);
                    JSONObject jsonObject = new JSONObject();
                    try {
                        jsonObject.put("propName", "isLoading");
                        jsonObject.put("value", false);
                        dispatchStatusEventAsync(jsonObject.toString(), ON_PROPERTY_CHANGE);
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }

                    jsonObject = new JSONObject();
                    try {
                        jsonObject.put("propName", "canGoBack");
                        jsonObject.put("value", webView.canGoBack());
                        dispatchStatusEventAsync(jsonObject.toString(), ON_PROPERTY_CHANGE);
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }

                    jsonObject = new JSONObject();
                    try {
                        jsonObject.put("propName", "canGoForward");
                        jsonObject.put("value", webView.canGoForward());
                        dispatchStatusEventAsync(jsonObject.toString(), ON_PROPERTY_CHANGE);
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }

                }
            });
            webView.setBackgroundColor((bg_a == 0) ? Color.TRANSPARENT : Color.argb(bg_a, bg_r, bg_g, bg_b));
            webView.addJavascriptInterface(new BoundObject(), "webViewANE");

            if (!TextUtils.isEmpty(_initialUrl)) {
                webView.loadUrl(_initialUrl);
            }

            RelativeLayout.LayoutParams layoutParams = new RelativeLayout.LayoutParams(_width, _height);

            webView.setLayoutParams(layoutParams);

            layoutParams.setMargins(_x, _y, 0, 0);
            super.setGravity(Gravity.TOP | Gravity.LEFT);
            super.addView(webView, layoutParams);

        }

    }


    private class init implements FREFunction {
        @Override
        public FREObject call(FREContext freContext, FREObject[] argv) {
            try {
                _initialUrl = argv[0].getAsString();
                _scaleFactor = argv[6].getAsInt();
                _x = Math.round(argv[1].getAsInt() * _scaleFactor);
                _y = Math.round(argv[2].getAsInt() * _scaleFactor);
                _width = Math.round(argv[3].getAsInt() * _scaleFactor);
                _height = Math.round(argv[4].getAsInt() * _scaleFactor);


                FREObject freSettings = argv[5].getProperty("android");


                //TODO settings [5]
                Settings settings = new Settings();
                settings.setJavaScriptEnabled(
                        freSettings.getProperty("javaScriptEnabled").getAsBool());
                settings.setMediaPlaybackRequiresUserGesture(
                        freSettings.getProperty("mediaPlaybackRequiresUserGesture").getAsBool());
                settings.setUserAgent(argv[5].getProperty("userAgent").getAsString());

                settings.setJavaScriptCanOpenWindowsAutomatically(
                        freSettings.getProperty("javaScriptCanOpenWindowsAutomatically").getAsBool());
                settings.setBlockNetworkImage(freSettings.getProperty("blockNetworkImage").getAsBool());

                settings.setAllowContentAccess(freSettings.getProperty("allowContentAccess").getAsBool());
                settings.setAllowFileAccess(freSettings.getProperty("allowFileAccess").getAsBool());
                settings.setAllowFileAccessFromFileURLs(
                        freSettings.getProperty("allowFileAccessFromFileURLs").getAsBool());

                settings.setAllowUniversalAccessFromFileURLs(
                        freSettings.getProperty("allowUniversalAccessFromFileURLs").getAsBool());

                settings.setGeolocationEnabled(freSettings.getProperty("geolocationEnabled").getAsBool());

                airView = (ViewGroup) getActivity().findViewById(android.R.id.content);
                airView = (ViewGroup) airView.getChildAt(0);
                container = new AirWebView(getActivity(), settings);

            } catch (FRETypeMismatchException | FREWrongThreadException | FREInvalidObjectException e) {
                trace(e.toString());
                e.printStackTrace();
            } catch (FREASErrorException | FRENoSuchNameException e) {
                trace(e.toString());
                e.printStackTrace();
            }

            return null;
        }
    }

    private class addToStage implements FREFunction {
        @Override
        public FREObject call(FREContext freContext, FREObject[] freObjects) {
            airView.addView(container);
            return null;
        }
    }

    private class removeFromStage implements FREFunction {
        @Override
        public FREObject call(FREContext freContext, FREObject[] freObjects) {
            // webDialog.dismiss();
            airView.removeView(container);
            return null;
        }
    }

    private class load implements FREFunction {
        @Override
        public FREObject call(FREContext ctx, FREObject[] argv) {
            try {
                String url = argv[0].getAsString();
                webView.loadUrl(url);
            } catch (FRETypeMismatchException | FREWrongThreadException | FREInvalidObjectException e) {
                trace(e.toString());
                e.printStackTrace();
            }
            return null;
        }
    }

    private class loadFileURL implements FREFunction {
        @Override
        public FREObject call(FREContext ctx, FREObject[] argv) {
            try {
                String url = argv[0].getAsString();
                webView.loadUrl(url);
            } catch (FRETypeMismatchException | FREWrongThreadException | FREInvalidObjectException e) {
                trace(e.toString());
                e.printStackTrace();
            }
            return null;
        }
    }

    private class reload implements FREFunction {
        @Override
        public FREObject call(FREContext freContext, FREObject[] freObjects) {
            webView.reload();
            return null;
        }
    }

    private class backForwardList implements FREFunction {
        @Override
        public FREObject call(FREContext freContext, FREObject[] freObjects) {
            return null;
        }
    }

    private class go implements FREFunction {
        @Override
        public FREObject call(FREContext ctx, FREObject[] argv) {
            int offset;
            try {
                offset = argv[0].getAsInt();
                if (webView.canGoBackOrForward(offset))
                    webView.goBackOrForward(offset);
            } catch (FRETypeMismatchException | FREWrongThreadException | FREInvalidObjectException e) {
                e.printStackTrace();
            }
            return null;
        }
    }

    private class goBack implements FREFunction {
        @Override
        public FREObject call(FREContext ctx, FREObject[] argv) {
            if (webView.canGoBack())
                webView.goBack();
            return null;
        }
    }

    private class goForward implements FREFunction {
        @Override
        public FREObject call(FREContext ctx, FREObject[] argv) {
            if (webView.canGoForward())
                webView.goForward();
            return null;
        }
    }

    private class stopLoading implements FREFunction {
        @Override
        public FREObject call(FREContext ctx, FREObject[] argv) {
            webView.stopLoading();
            return null;
        }
    }

    private class reloadFromOrigin implements FREFunction {
        @Override
        public FREObject call(FREContext ctx, FREObject[] argv) {
            webView.reload();
            return null;
        }
    }

    private class allowsMagnification implements FREFunction {
        @Override
        public FREObject call(FREContext ctx, FREObject[] argv) {
            try {
                return FREObject.newObject(true);
            } catch (FREWrongThreadException e) {
                e.printStackTrace();
            }
            return null;
        }
    }

    private class getMagnification implements FREFunction {
        @Override
        public FREObject call(FREContext ctx, FREObject[] argv) {
            return null;
        }
    }

    private class setMagnification implements FREFunction {
        @Override
        public FREObject call(FREContext ctx, FREObject[] argv) {
            try {
                webView.zoomBy((float) argv[0].getAsDouble());
            } catch (FRETypeMismatchException | FREInvalidObjectException | FREWrongThreadException e) {
                e.printStackTrace();
            }
            return null;
        }
    }

    private class loadHTMLString implements FREFunction {
        @Override
        public FREObject call(FREContext ctx, FREObject[] argv) {
            try {
                String data = argv[0].getAsString();
                webView.loadData(data, "text/html; charset=UTF-8", null);
            } catch (FRETypeMismatchException | FREWrongThreadException | FREInvalidObjectException e) {
                e.printStackTrace();
            }
            return null;
        }
    }

    private class setPositionAndSize implements FREFunction {
        @Override
        public FREObject call(FREContext ctx, FREObject[] argv) {

            try {
                int tmp_x = argv[0].getAsInt() * _scaleFactor;
                int tmp_y = argv[1].getAsInt() * _scaleFactor;
                int tmp_width = argv[2].getAsInt() * _scaleFactor;
                int tmp_height = argv[3].getAsInt() * _scaleFactor;

                Boolean updateWidth = false;
                Boolean updateHeight = false;
                Boolean updateX = false;
                Boolean updateY = false;

                if (tmp_width != _width) {
                    _width = tmp_width;
                    updateWidth = true;
                }

                if (tmp_height != _height) {
                    _height = tmp_height;
                    updateHeight = true;
                }

                if (tmp_x != _x) {
                    _x = tmp_x;
                    updateX = true;
                }

                if (tmp_y != _y) {
                    _y = tmp_y;
                    updateY = true;
                }

                if (updateX || updateY || updateWidth || updateHeight) {
                    RelativeLayout.LayoutParams layoutParams = (RelativeLayout.LayoutParams) webView.getLayoutParams();
                    layoutParams.width = _width;
                    layoutParams.height = _height;
                    layoutParams.setMargins(_x, _y, 0, 0);
                    webView.setLayoutParams(layoutParams);
                }

            } catch (FRETypeMismatchException | FREInvalidObjectException | FREWrongThreadException e) {
                e.printStackTrace();
            }

            return null;
        }
    }

    private class showDevTools implements FREFunction {
        @Override
        public FREObject call(FREContext ctx, FREObject[] argv) {
            if (webView != null)
                webView.setWebContentsDebuggingEnabled(true);
            return null;
        }
    }

    private class closeDevTools implements FREFunction {
        @Override
        public FREObject call(FREContext ctx, FREObject[] argv) {
            if (webView != null)
                webView.setWebContentsDebuggingEnabled(false);
            return null;
        }
    }

    private class onFullScreen implements FREFunction {
        @Override
        public FREObject call(FREContext ctx, FREObject[] argv) {
            return null;
        }
    }

    private class callJavascriptFunction implements FREFunction {
        @Override
        public FREObject call(FREContext ctx, FREObject[] argv) {
            try {
                final String js = argv[0].getAsString();
                if (argv[1] != null) {
                    final String callback = argv[1].getAsString();
                    evalJavascript(js, callback);
                } else {
                    evalJavascript(js);
                }

            } catch (FRETypeMismatchException | FREInvalidObjectException | FREWrongThreadException e) {
                e.printStackTrace();
            }
            return null;
        }
    }

    private void evalJavascript(String js, final String callback) {
        webView.evaluateJavascript(js, new ValueCallback<String>() {
            @Override
            public void onReceiveValue(String result) {
                JSONObject jsonObject = new JSONObject();
                try {
                    jsonObject.put("callbackName", callback);
                    jsonObject.put("error", "");
                    jsonObject.put("message", "");
                    jsonObject.put("success", true);
                    jsonObject.put("result", result);

                    dispatchStatusEventAsync(jsonObject.toString(), AirWebView.AS_CALLBACK_EVENT);

                } catch (JSONException e) {
                    trace(e.toString());
                    e.printStackTrace();
                }
            }
        });
    }

    private void evalJavascript(String js) {
        webView.evaluateJavascript(js, null);
    }

    private class evaluateJavaScript implements FREFunction {
        @Override
        public FREObject call(FREContext ctx, final FREObject[] argv) {
            try {
                final String js = argv[0].getAsString();
                if (argv[1] != null) {
                    final String callback = argv[1].getAsString();
                    evalJavascript(js, callback);
                } else {
                    evalJavascript(js);
                }

            } catch (FRETypeMismatchException | FREInvalidObjectException | FREWrongThreadException e) {
                e.printStackTrace();
            }
            return null;
        }
    }

    private class setBackgroundColor implements FREFunction {
        @Override
        public FREObject call(FREContext ctx, FREObject[] argv) {
            try {
                bg_r = argv[0].getAsInt();
                bg_g = argv[1].getAsInt();
                bg_b = argv[2].getAsInt();
                bg_a = (int) (argv[3].getAsDouble() * 255);

                if (webView != null) {
                    webView.setBackgroundColor((bg_a == 0) ? Color.TRANSPARENT : Color.argb(bg_a, bg_r, bg_g, bg_b));
                }

            } catch (FRETypeMismatchException | FREInvalidObjectException | FREWrongThreadException e) {
                trace(e.toString());
                e.printStackTrace();
            }
            return null;
        }
    }

    private class shutDown implements FREFunction {
        @Override
        public FREObject call(FREContext freContext, FREObject[] freObjects) {
            return null;
        }
    }

    private class injectScript implements FREFunction {
        @Override
        public FREObject call(FREContext freContext, FREObject[] freObjects) {
            return null;
        }
    }

    private class print implements FREFunction {
        @Override
        public FREObject call(FREContext freContext, FREObject[] freObjects) {
            return null;
        }
    }

    private class focus implements FREFunction {
        @Override
        public FREObject call(FREContext freContext, FREObject[] freObjects) {
            return null;
        }
    }

    private void trace(String msg) {
        //if(logLevel > LogLevel.QUIET){
        Log.i("com.tuarua.WebViewANE", String.valueOf(msg));
        dispatchStatusEventAsync(msg, "TRACE");
        // }

    }

    private void trace(int msg) {
        //if(logLevel > LogLevel.QUIET) {
        Log.i("com.tuarua.WebViewANE", String.valueOf(msg));
        dispatchStatusEventAsync(String.valueOf(msg), "TRACE");
        // }
    }

    private void trace(boolean msg) {
        // if(logLevel > LogLevel.QUIET) {
        Log.i("com.tuarua.WebViewANE", String.valueOf(msg));
        dispatchStatusEventAsync(String.valueOf(msg), "TRACE");
        //  }
    }


}
