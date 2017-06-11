package com.tuarua.webviewane;

import java.util.ArrayList;

/**
 * Created by Eoin Landy on 26/03/2017.
 */

public class Settings {
    private Boolean javaScriptEnabled = false;
    private Boolean mediaPlaybackRequiresUserGesture = false;
    private String userAgent;
    private Boolean javaScriptCanOpenWindowsAutomatically = true;
    private Boolean blockNetworkImage = false;
    private Boolean allowFileAccess = true;
    private Boolean allowContentAccess = true;
    private Boolean allowUniversalAccessFromFileURLs = true;
    private Boolean allowFileAccessFromFileURLs = true;
    private Boolean geolocationEnabled = false;
    private ArrayList<String> whiteList;

    public Boolean getJavaScriptEnabled() {
        return javaScriptEnabled;
    }

    public void setJavaScriptEnabled(Boolean b) {
        javaScriptEnabled = b;
    }

    public Boolean getMediaPlaybackRequiresUserGesture() {
        return mediaPlaybackRequiresUserGesture;
    }

    public void setMediaPlaybackRequiresUserGesture(Boolean b) {
        mediaPlaybackRequiresUserGesture = b;
    }

    public String getUserAgent() {
        return userAgent;
    }

    public void setUserAgent(String s) {
        userAgent = s;
    }

    public Boolean getJavaScriptCanOpenWindowsAutomatically() {
        return javaScriptCanOpenWindowsAutomatically;
    }

    public void setJavaScriptCanOpenWindowsAutomatically(Boolean b) {
        javaScriptCanOpenWindowsAutomatically = b;
    }

    public Boolean getBlockNetworkImage() {
        return blockNetworkImage;
    }

    public void setBlockNetworkImage(Boolean b) {
        blockNetworkImage = b;
    }

    public void setAllowFileAccess(Boolean b) {
        allowFileAccess = b;
    }

    public Boolean getAllowFileAccess() {
        return allowFileAccess;
    }

    public void setAllowContentAccess(Boolean b) {
        allowContentAccess = b;
    }

    public Boolean getAllowContentAccess() {
        return allowContentAccess;
    }


    public void setAllowUniversalAccessFromFileURLs(Boolean b) {
        allowUniversalAccessFromFileURLs = b;
    }

    public Boolean getAllowUniversalAccessFromFileURLs() {
        return allowUniversalAccessFromFileURLs;
    }


    public void setAllowFileAccessFromFileURLs(Boolean b) {
        allowFileAccessFromFileURLs = b;
    }

    public Boolean getAllowFileAccessFromFileURLs() {
        return allowFileAccessFromFileURLs;
    }

    public Boolean getGeolocationEnabled() {
        return geolocationEnabled;
    }

    public void setGeolocationEnabled(boolean b) {
        geolocationEnabled = b;
    }

    public ArrayList<String> getWhiteList() {return whiteList;}

    public void setWhiteList(ArrayList<String> whiteList) {this.whiteList = whiteList;}

    /*
    @Override
    public void setSupportZoom(boolean b) {

    }

    @Override
    public boolean supportZoom() {
        return false;
    }



    @Override
    public void setBuiltInZoomControls(boolean b) {

    }

    @Override
    public boolean getBuiltInZoomControls() {
        return false;
    }

    @Override
    public void setDisplayZoomControls(boolean b) {

    }

    @Override
    public boolean getDisplayZoomControls() {
        return false;
    }





    @Override
    public void setLoadWithOverviewMode(boolean b) {

    }

    @Override
    public boolean getLoadWithOverviewMode() {
        return false;
    }

    @Override
    public void setEnableSmoothTransition(boolean b) {

    }

    @Override
    public boolean enableSmoothTransition() {
        return false;
    }

    @Override
    public void setSaveFormData(boolean b) {

    }

    @Override
    public boolean getSaveFormData() {
        return false;
    }

    @Override
    public void setSavePassword(boolean b) {

    }

    @Override
    public boolean getSavePassword() {
        return false;
    }

    @Override
    public void setTextZoom(int i) {

    }

    @Override
    public int getTextZoom() {
        return 0;
    }

    @Override
    public void setDefaultZoom(ZoomDensity zoomDensity) {

    }

    @Override
    public ZoomDensity getDefaultZoom() {
        return null;
    }

    @Override
    public void setLightTouchEnabled(boolean b) {

    }

    @Override
    public boolean getLightTouchEnabled() {
        return false;
    }

    @Override
    public void setUseWideViewPort(boolean b) {

    }

    @Override
    public boolean getUseWideViewPort() {
        return false;
    }

    @Override
    public void setSupportMultipleWindows(boolean b) {

    }

    @Override
    public boolean supportMultipleWindows() {
        return false;
    }

    @Override
    public void setLayoutAlgorithm(LayoutAlgorithm layoutAlgorithm) {

    }

    @Override
    public LayoutAlgorithm getLayoutAlgorithm() {
        return null;
    }

    @Override
    public void setStandardFontFamily(String s) {

    }

    @Override
    public String getStandardFontFamily() {
        return null;
    }

    @Override
    public void setFixedFontFamily(String s) {

    }

    @Override
    public String getFixedFontFamily() {
        return null;
    }

    @Override
    public void setSansSerifFontFamily(String s) {

    }

    @Override
    public String getSansSerifFontFamily() {
        return null;
    }

    @Override
    public void setSerifFontFamily(String s) {

    }

    @Override
    public String getSerifFontFamily() {
        return null;
    }

    @Override
    public void setCursiveFontFamily(String s) {

    }

    @Override
    public String getCursiveFontFamily() {
        return null;
    }

    @Override
    public void setFantasyFontFamily(String s) {

    }

    @Override
    public String getFantasyFontFamily() {
        return null;
    }

    @Override
    public void setMinimumFontSize(int i) {

    }

    @Override
    public int getMinimumFontSize() {
        return 0;
    }

    @Override
    public void setMinimumLogicalFontSize(int i) {

    }

    @Override
    public int getMinimumLogicalFontSize() {
        return 0;
    }

    @Override
    public void setDefaultFontSize(int i) {

    }

    @Override
    public int getDefaultFontSize() {
        return 0;
    }

    @Override
    public void setDefaultFixedFontSize(int i) {

    }

    @Override
    public int getDefaultFixedFontSize() {
        return 0;
    }

    @Override
    public void setLoadsImagesAutomatically(boolean b) {

    }

    @Override
    public boolean getLoadsImagesAutomatically() {
        return false;
    }



    @Override
    public void setBlockNetworkLoads(boolean b) {

    }

    @Override
    public boolean getBlockNetworkLoads() {
        return false;
    }







    @Override
    public void setPluginState(PluginState pluginState) {

    }

    @Override
    public void setDatabasePath(String s) {

    }

    @Override
    public void setGeolocationDatabasePath(String s) {

    }

    @Override
    public void setAppCacheEnabled(boolean b) {

    }

    @Override
    public void setAppCachePath(String s) {

    }

    @Override
    public void setAppCacheMaxSize(long l) {

    }

    @Override
    public void setDatabaseEnabled(boolean b) {

    }

    @Override
    public void setDomStorageEnabled(boolean b) {

    }

    @Override
    public boolean getDomStorageEnabled() {
        return false;
    }

    @Override
    public String getDatabasePath() {
        return null;
    }

    @Override
    public boolean getDatabaseEnabled() {
        return false;
    }





    @Override
    public PluginState getPluginState() {
        return null;
    }


    @Override
    public void setDefaultTextEncodingName(String s) {

    }

    @Override
    public String getDefaultTextEncodingName() {
        return null;
    }


    @Override
    public void setNeedInitialFocus(boolean b) {

    }

    @Override
    public void setRenderPriority(RenderPriority renderPriority) {

    }

    @Override
    public void setCacheMode(int i) {

    }

    @Override
    public int getCacheMode() {
        return WebSettings.LOAD_DEFAULT;
    }

    @Override
    public void setMixedContentMode(int i) {

    }

    @Override
    public int getMixedContentMode() {
        return 0;
    }

    @Override
    public void setOffscreenPreRaster(boolean b) {

    }

    @Override
    public boolean getOffscreenPreRaster() {
        return false;
    }

    @RequiresApi(api = Build.VERSION_CODES.N)
    @Override
    public void setDisabledActionModeMenuItems(int i) {

    }

    @Override
    public int getDisabledActionModeMenuItems() {
        return 0;
    }
    */
}
