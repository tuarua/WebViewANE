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
NSPointerArray * getFREargs(uint32_t argc, FREObject argv[]) {
    NSPointerArray * pa = [[NSPointerArray alloc] initWithOptions:NSPointerFunctionsOpaqueMemory];
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

FRE_FUNCTION (load) {
    [swft loadWithArgv:getFREargs(argc, argv)];
    return NULL;
}

FRE_FUNCTION (reload) {
    [swft reload];
    return NULL;
}

FRE_FUNCTION (addToStage) {
    [swft addToStage];
    return NULL;
}


void contextInitializer(void *extData, const uint8_t *ctxType, FREContext ctx, uint32_t *numFunctionsToSet, const FRENamedFunction **functionsToSet) {
    static FRENamedFunction extensionFunctions[] = {
        {(const uint8_t *) "init", NULL, &init}
        ,{(const uint8_t *) "addToStage", NULL, &addToStage}
        ,{(const uint8_t *) "load", NULL, &load}
        ,{(const uint8_t *) "reload", NULL, &reload}
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
