//
// Created by User on 04/12/2016.
// Copyright (c) 2016 Tua Rua Ltd. All rights reserved.
//
#import <Foundation/Foundation.h>


#include "WebViewANE_oc.h"
#import "WebViewANE-Swift.h"
#include <Adobe AIR/Adobe AIR.h>

WebViewANE *swft;

#define FRE_FUNCTION(fn) FREObject (fn)(FREContext context, void* functionData, uint32_t argc, FREObject argv[])

// convert argv into a pointer array which can be passed to Swift
NSPointerArray *getFREargs(uint32_t argc, FREObject argv[]) {
    NSPointerArray *pa = [[NSPointerArray alloc] initWithOptions:NSPointerFunctionsOpaqueMemory];
    for (int i = 0; i < argc; ++i) {
        FREObject freObject;
        freObject = argv[i];
        [pa addPointer:freObject];
    }
    return pa;
}

FRE_FUNCTION (init) {
    [swft initWebViewWithArgv:getFREargs(argc, argv)];
    return NULL;
}

FRE_FUNCTION (addToStage) {
    [swft addToStage];
    return NULL;
}

FRE_FUNCTION (removeFromStage) {
    [swft removeFromStage];
    return NULL;
}

FRE_FUNCTION (load) {
    [swft loadWithArgv:getFREargs(argc, argv)];
    return NULL;
}

FRE_FUNCTION (loadHTMLString) {
    [swft loadHTMLStringWithArgv:getFREargs(argc, argv)];
    return NULL;
}

FRE_FUNCTION (loadFileURL) {
    [swft loadFileURLWithArgv:getFREargs(argc, argv)];
    return NULL;
}

FRE_FUNCTION (reload) {
    [swft reload];
    return NULL;
}

FRE_FUNCTION (reloadFromOrigin) {
    [swft reloadFromOrigin];
    return NULL;
}

FRE_FUNCTION (stopLoading) {
    [swft stopLoading];
    return NULL;
}

FRE_FUNCTION (goBack) {
    [swft goBack];
    return NULL;
}

FRE_FUNCTION (goForward) {
    [swft goForward];
    return NULL;
}

FRE_FUNCTION (isSupported) {
    return [swft isSupported];
}

FRE_FUNCTION (allowsMagnification) {
    return [swft allowsMagnification];
}

FRE_FUNCTION (getMagnification) {
    return [swft getMagnification];
}

FRE_FUNCTION (setMagnification) {
    [swft setMagnificationWithArgv:getFREargs(argc, argv)];
    return NULL;
}

FRE_FUNCTION (evaluateJavaScript) {
    [swft evaluateJavaScriptWithArgv:getFREargs(argc, argv)];
    return NULL;
}

void contextInitializer(void *extData, const uint8_t *ctxType, FREContext ctx, uint32_t *numFunctionsToSet, const FRENamedFunction **functionsToSet) {
    static FRENamedFunction extensionFunctions[] = {
          {(const uint8_t *) "init", NULL, &init}
        , {(const uint8_t *) "isSupported", NULL, &isSupported}
        , {(const uint8_t *) "addToStage", NULL, &addToStage}
        , {(const uint8_t *) "removeFromStage", NULL, &removeFromStage}
        , {(const uint8_t *) "load", NULL, &load}
        , {(const uint8_t *) "loadHTMLString", NULL, &loadHTMLString}
        , {(const uint8_t *) "load", NULL, &load}
        , {(const uint8_t *) "loadFileURL", NULL, &loadFileURL}
        , {(const uint8_t *) "reload", NULL, &reload}
        , {(const uint8_t *) "reloadFromOrigin", NULL, &reloadFromOrigin}
        , {(const uint8_t *) "stopLoading", NULL, &stopLoading}
        , {(const uint8_t *) "goBack", NULL, &goBack}
        , {(const uint8_t *) "goForward", NULL, &goForward}
        , {(const uint8_t *) "allowsMagnification", NULL, &allowsMagnification}
        , {(const uint8_t *) "getMagnification", NULL, &getMagnification}
        , {(const uint8_t *) "setMagnification", NULL, &setMagnification}
        , {(const uint8_t *) "evaluateJavaScript", NULL, &evaluateJavaScript}

    };

    *numFunctionsToSet = sizeof(extensionFunctions) / sizeof(FRENamedFunction);
    *functionsToSet = extensionFunctions;

    swft = [[WebViewANE alloc] init];
    [swft setFREContextWithCtx:ctx];

}

void contextFinalizer(FREContext ctx) {
    return;
}

void TRWVExtInizer(void **extData, FREContextInitializer *ctxInitializer, FREContextFinalizer *ctxFinalizer) {
    *ctxInitializer = &contextInitializer;
    *ctxFinalizer = &contextFinalizer;
}

void TRWVExtFinizer(void *extData) {
    FREContext nullCTX;
    nullCTX = 0;
    contextFinalizer(nullCTX);
    return;
}
