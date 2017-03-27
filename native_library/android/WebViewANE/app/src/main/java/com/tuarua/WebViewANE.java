package com.tuarua;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREExtension;

/**
 * Created by Eoin Landy on 21/03/2017.
 */

public class WebViewANE implements FREExtension {
    public static WebViewANEContext extensionContext;
    @Override
    public void initialize() {

    }

    @Override
    public FREContext createContext(String s) {
        return extensionContext = new WebViewANEContext();
    }

    @Override
    public void dispose() {

    }
}
