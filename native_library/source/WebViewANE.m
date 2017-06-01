// Copyright 2017 Tua Rua Ltd.
// 
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
// 
//  http://www.apache.org/licenses/LICENSE-2.0
// 
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
// 
//  Additional Terms
//  No part, or derivative of this Air Native Extensions's code is permitted 
//  to be sold as the basis of a commercially packaged Air Native Extension which 
//  undertakes the same purpose as this software. That is, a WebView for Windows, 
//  OSX and/or iOS and/or Android.
//  All Rights Reserved. Tua Rua Ltd.

#import "WebViewANE_oc.h"

#ifdef _WIN32
#elif __APPLE__
#include "TargetConditionals.h"
#if (TARGET_IPHONE_SIMULATOR) || (TARGET_OS_IPHONE)

#include "FlashRuntimeExtensions.h"
#import "FlashRuntimeExtensionsBridge.h"
#import "WebViewANE_FW-Swift.h"

FlashRuntimeExtensionsBridge *freBridge; // this runs the native FRE calls and returns to Swift
FRESwiftBridge *swftBridge; // this is the bridge from Swift back to ObjectiveC

#elif TARGET_OS_MAC

#import <Foundation/Foundation.h>
#include "WebViewANE_oc.h"
#import "WebViewANE-Swift.h"
#include <Adobe AIR/Adobe AIR.h>

#else
#   error "Unknown Apple platform"
#endif
#endif

WebViewANE *swft; // our main Swift Controller
NSArray * funcArray;
#define FRE_FUNCTION(fn) FREObject (fn)(FREContext context, void* functionData, uint32_t argc, FREObject argv[])

FRE_FUNCTION(callSwiftFunction) {
    NSString* fName = (__bridge NSString *)(functionData);
    return [swft callSwiftFunctionWithName:fName ctx:context argc:argc argv:argv];
}

void contextInitializer(void *extData, const uint8_t *ctxType, FREContext ctx, uint32_t *numFunctionsToSet,
                        const FRENamedFunction **functionsToSet) {
    
    /******* MAKE SURE TO SET NUM OF FUNCTIONS MANUALLY *****/
    /********************************************************/
    
    const int numFunctions = 29;
    
    /********************************************************/
    /********************************************************/

    
#ifdef _WIN32
#elif __APPLE__
#if (TARGET_IPHONE_SIMULATOR) || (TARGET_OS_IPHONE)
    freBridge = [[FlashRuntimeExtensionsBridge alloc] init];
    swftBridge = [[FRESwiftBridge alloc] init];
    [swftBridge setDelegateWithBridge:freBridge];
    
#elif TARGET_OS_MAC
    
#else
#   error "Unknown Apple platform"
#endif
#endif
    
    swft = [[WebViewANE alloc] init];
    [swft setFREContextWithCtx:ctx];
    
    funcArray = [swft getFunctions];
    static FRENamedFunction extensionFunctions[numFunctions] = {};
    for (int i = 0; i < [funcArray count]; ++i) {
        NSString * nme = [funcArray objectAtIndex:i];
        FRENamedFunction nf = {(const uint8_t *) [nme UTF8String], (__bridge void *)(nme), &callSwiftFunction};
        extensionFunctions[i] = nf;
    }
    
    *numFunctionsToSet = sizeof(extensionFunctions) / sizeof(FRENamedFunction);
    *functionsToSet = extensionFunctions;
    
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




