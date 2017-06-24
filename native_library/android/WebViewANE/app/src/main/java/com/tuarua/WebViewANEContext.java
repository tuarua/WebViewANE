package com.tuarua;

import android.annotation.TargetApi;
import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Color;
import android.graphics.Rect;
import android.os.Build;
import android.text.TextUtils;
import android.util.Log;
import android.util.Xml;
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
import android.webkit.WebResourceResponse;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.RelativeLayout;

import com.adobe.fre.FREASErrorException;
import com.adobe.fre.FREArray;
import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREInvalidObjectException;
import com.adobe.fre.FRENoSuchNameException;
import com.adobe.fre.FREObject;
import com.adobe.fre.FREReadOnlyException;
import com.adobe.fre.FRETypeMismatchException;
import com.adobe.fre.FREWrongThreadException;
import com.tuarua.webviewane.Settings;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.ByteArrayInputStream;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

class WebViewANEContext extends FREContext {

    private String _initialUrl;
    private int _x;
    private int _y;
    private int _width;
    private int _height;
    private double _scaleFactor;
    private int backgroundColor;
    private int backgroundAlpha;
    private WebView webView;
    private RelativeLayout container;
    ViewGroup airView;
    private static final String TRACE = "TRACE";
    private double progress = 0.0;
    private boolean isLoading = false;
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
        functionsToSet.put("zoomIn", new zoomIn());
        functionsToSet.put("zoomOut", new zoomOut());
        functionsToSet.put("loadHTMLString", new loadHTMLString());
        functionsToSet.put("setPositionAndSize", new setPositionAndSize());
        functionsToSet.put("showDevTools", new showDevTools());
        functionsToSet.put("closeDevTools", new closeDevTools());
        functionsToSet.put("onFullScreen", new notImplemented());
        functionsToSet.put("callJavascriptFunction", new callJavascriptFunction());
        functionsToSet.put("evaluateJavaScript", new evaluateJavaScript());
        functionsToSet.put("injectScript", new notImplemented());
        functionsToSet.put("print", new notImplemented());
        functionsToSet.put("focus", new notImplemented());
        functionsToSet.put("capture", new notImplemented());
        functionsToSet.put("addTab", new notImplemented());
        functionsToSet.put("closeTab", new notImplemented());
        functionsToSet.put("setCurrentTab", new notImplemented());
        functionsToSet.put("getCurrentTab", new getCurrentTab());
        functionsToSet.put("getTabDetails", new getTabDetails()); //TODO



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
        public static final String AS_CALLBACK_EVENT = "TRWV.as.CALLBACK";
        public static final String JS_CALLBACK_EVENT = "TRWV.js.CALLBACK";
        private static final String ON_PROPERTY_CHANGE = "WebView.OnPropertyChange";
        private static final String ON_FAIL = "WebView.OnFail";
        private static final String ON_URL_BLOCKED = "WebView.OnUrlBlocked";

        public AirWebView(Context context, final Settings settings) {
            super(context);
            webView = new WebView(context);

            final WebSettings webSettings = webView.getSettings();
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
                        /*double */progress = ((double) newProgress) * 0.01;
                        jsonObject.put("propName", "estimatedProgress");
                        jsonObject.put("value", progress);
                        jsonObject.put("tab", 0);
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
                        jsonObject.put("tab", 0);
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
                public void onReceivedHttpError(WebView view, WebResourceRequest request, WebResourceResponse errorResponse) {
                    JSONObject jsonObject = new JSONObject();
                    try {
                        jsonObject.put("url", request.getUrl().toString());
                        jsonObject.put("tab", 0);
                        jsonObject.put("errorCode", errorResponse.getStatusCode());
                        jsonObject.put("errorText", errorResponse.getReasonPhrase());
                        dispatchStatusEventAsync(jsonObject.toString(), ON_FAIL);
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }
                    super.onReceivedHttpError(view, request, errorResponse);
                }

                @Override
                public WebResourceResponse shouldInterceptRequest(WebView view, WebResourceRequest request) {
                    ArrayList<String> whiteList = settings.getWhiteList();
                    if (whiteList.isEmpty()) {
                        return null;
                    }
                    for (int i = 0, whiteListSize = whiteList.size(); i < whiteListSize; i++) {
                        String s = whiteList.get(i);
                        if (request.getUrl().toString().contains(s)) {
                            return null;
                        }
                    }

                    JSONObject jsonObject = new JSONObject();
                    try {
                        jsonObject.put("url", request.getUrl().toString());
                        jsonObject.put("tab", 0);
                        dispatchStatusEventAsync(jsonObject.toString(), ON_URL_BLOCKED);
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }

                    WebResourceResponse response = new WebResourceResponse("text/plain", "utf-8",
                            new ByteArrayInputStream("".getBytes()));

                    response.setStatusCodeAndReasonPhrase(403, "Blocked");
                    return response;
                }

                @Override
                public void onPageStarted(WebView view, String url, Bitmap favicon) {
                    super.onPageStarted(view, url, favicon);
                    JSONObject jsonObject = new JSONObject();
                    try {
                        isLoading = true;
                        jsonObject.put("propName", "isLoading");
                        jsonObject.put("value", isLoading);
                        dispatchStatusEventAsync(jsonObject.toString(), ON_PROPERTY_CHANGE);
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }

                    jsonObject = new JSONObject();
                    try {
                        jsonObject.put("propName", "url");
                        jsonObject.put("value", url);
                        jsonObject.put("tab", 0);
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
                        isLoading = false;
                        jsonObject.put("propName", "isLoading");
                        jsonObject.put("value", isLoading);
                        jsonObject.put("tab", 0);
                        dispatchStatusEventAsync(jsonObject.toString(), ON_PROPERTY_CHANGE);
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }

                    jsonObject = new JSONObject();
                    try {
                        jsonObject.put("propName", "canGoBack");
                        jsonObject.put("value", webView.canGoBack());
                        jsonObject.put("tab", 0);
                        dispatchStatusEventAsync(jsonObject.toString(), ON_PROPERTY_CHANGE);
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }

                    jsonObject = new JSONObject();
                    try {
                        jsonObject.put("propName", "canGoForward");
                        jsonObject.put("value", webView.canGoForward());
                        jsonObject.put("tab", 0);
                        dispatchStatusEventAsync(jsonObject.toString(), ON_PROPERTY_CHANGE);
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }

                }
            });

            webView.setBackgroundColor((backgroundAlpha == 0.0) ? Color.TRANSPARENT
                    : Color.argb(backgroundAlpha,
                    Color.red(backgroundColor), Color.green(backgroundColor),
                    Color.blue(backgroundColor)));
            webView.addJavascriptInterface(new BoundObject(), "webViewANE");

            if (!TextUtils.isEmpty(_initialUrl)) {
                webView.loadUrl(_initialUrl);
            }

            RelativeLayout.LayoutParams layoutParams = new RelativeLayout.LayoutParams(_width, _height);
            webView.setLayoutParams(layoutParams);
            layoutParams.setMargins(_x, _y, 0, 0);
            super.setGravity(Gravity.TOP | Gravity.START);
            super.addView(webView, layoutParams);

        }

    }


    private class init implements FREFunction {
        @Override
        public FREObject call(FREContext freContext, FREObject[] argv) {
            try {

                _initialUrl = argv[0].getAsString();
                _scaleFactor = argv[3].getAsDouble();
                _x = (int) Math.round((double) argv[1].getProperty("x").getAsInt() * _scaleFactor);
                _y = (int) Math.round((double) argv[1].getProperty("y").getAsInt() * _scaleFactor);
                _width = (int) Math.round((double) argv[1].getProperty("width").getAsInt() * _scaleFactor);
                _height = (int) Math.round((double) argv[1].getProperty("height").getAsInt() * _scaleFactor);

                backgroundColor = argv[4].getAsInt();
                backgroundAlpha = (int) Math.round(argv[5].getAsDouble() * 255.0);

                FREArray arr = (FREArray) argv[2].getProperty("urlWhiteList");
                FREObject freSettings = argv[2].getProperty("android");

                ArrayList<String> arrayList = new ArrayList<>();
                for (int i = 0, whiteListSize = (int) arr.getLength(); i < whiteListSize; i++) {
                    arrayList.add(arr.getObjectAt(i).getAsString());
                }

                Settings settings = new Settings();
                settings.setWhiteList(arrayList);

                settings.setJavaScriptEnabled(
                        freSettings.getProperty("javaScriptEnabled").getAsBool());
                settings.setMediaPlaybackRequiresUserGesture(
                        freSettings.getProperty("mediaPlaybackRequiresUserGesture").getAsBool());
                settings.setUserAgent(argv[2].getProperty("userAgent").getAsString());

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

            } catch (FRETypeMismatchException | FREWrongThreadException | FREInvalidObjectException | FREASErrorException | FRENoSuchNameException e) {
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

    private class zoomIn implements FREFunction {
        @Override
        public FREObject call(FREContext ctx, FREObject[] argv) {
            webView.zoomIn();
            return null;
        }
    }

    private class zoomOut implements FREFunction {
        @Override
        public FREObject call(FREContext ctx, FREObject[] argv) {
            webView.zoomOut();
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
                int tmp_x = (int) ((double) argv[0].getProperty("x").getAsInt() * _scaleFactor);
                int tmp_y = (int) ((double) argv[0].getProperty("y").getAsInt() * _scaleFactor);
                int tmp_width = (int) ((double) argv[0].getProperty("width").getAsInt() * _scaleFactor);
                int tmp_height = (int) ((double) argv[0].getProperty("height").getAsInt() * _scaleFactor);

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

            } catch (FRETypeMismatchException | FREInvalidObjectException | FREWrongThreadException |
                    FRENoSuchNameException | FREASErrorException e) {
                e.printStackTrace();
            }

            return null;
        }
    }

    private class showDevTools implements FREFunction {
        @Override
        public FREObject call(FREContext ctx, FREObject[] argv) {
            WebView.setWebContentsDebuggingEnabled(true);
            return null;
        }
    }

    private class closeDevTools implements FREFunction {
        @Override
        public FREObject call(FREContext ctx, FREObject[] argv) {
            WebView.setWebContentsDebuggingEnabled(false);
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

    private class notImplemented implements FREFunction {
        @Override
        public FREObject call(FREContext freContext, FREObject[] freObjects) {
            return null;
        }
    }


    private void trace(String msg) {
        //if(logLevel > LogLevel.QUIET){
        Log.i("com.tuarua.WebViewANE", String.valueOf(msg));
        dispatchStatusEventAsync(msg, TRACE);
        // }

    }

    private void trace(int msg) {
        //if(logLevel > LogLevel.QUIET) {
        Log.i("com.tuarua.WebViewANE", String.valueOf(msg));
        dispatchStatusEventAsync(String.valueOf(msg), TRACE);
        // }
    }

    private void trace(boolean msg) {
        // if(logLevel > LogLevel.QUIET) {
        Log.i("com.tuarua.WebViewANE", String.valueOf(msg));
        dispatchStatusEventAsync(String.valueOf(msg), TRACE);
        //  }
    }

    private class getTabDetails implements FREFunction {
        @Override
        public FREObject call(FREContext freContext, FREObject[] freObjects) {

            FREObject result = null;
            try {
                FREArray vecTabs = (FREArray) FREObject.newObject("Vector.<com.tuarua.webview.TabDetails>",
                        null);
                vecTabs.setLength(1);


                //index,
                // tabDetail.Address,
                //tabDetail.Title,
                // tabDetail.IsLoading,
                // tabDetail.CanGoBack,
                // tabDetail.CanGoForward,
                // 1.0

                FREObject[] params = new FREObject[7];
                FREObject index = FREObject.newObject(0);
                FREObject address = FREObject.newObject(webView.getUrl());
                FREObject title = FREObject.newObject(webView.getTitle());
                FREObject isLoadingFre = FREObject.newObject(false);
                FREObject canGoBack = FREObject.newObject(webView.canGoBack());
                FREObject canGoForward = FREObject.newObject(webView.canGoForward());
                FREObject progressFre = FREObject.newObject(progress);


                params[0] = index;
                params[1] = address;
                params[2] = title;
                params[3] = isLoadingFre;
                params[4] = canGoBack;
                params[5] = canGoForward;
                params[6] = progressFre;

                FREObject currentTabFre = FREObject.newObject("com.tuarua.webview.TabDetails", params);
                vecTabs.setObjectAt(0,currentTabFre);

                return vecTabs;

            } catch (FRETypeMismatchException | FREWrongThreadException | FRENoSuchNameException | FREASErrorException | FREInvalidObjectException | FREReadOnlyException e) {
                e.printStackTrace();
            }
            return result;
        }
    }

    private class getCurrentTab implements FREFunction {
        @Override
        public FREObject call(FREContext freContext, FREObject[] freObjects) {
            FREObject result = null;
            try {
                result = FREObject.newObject(0);
            } catch (FREWrongThreadException e) {
                e.printStackTrace();
            }
            return result;
        }
    }
}
