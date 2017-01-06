//
// Created by User on 04/12/2016.
// Copyright (c) 2016 Tua Rua Ltd. All rights reserved.
//

#ifndef WEBVIEWANE_WebViewANE_H
#define WEBVIEWANE_WebViewANE_H


#import <Cocoa/Cocoa.h>

#include <Adobe AIR/Adobe AIR.h>

#define EXPORT __attribute__((visibility("default")))
EXPORT
void TRWVExtInizer(void** extData, FREContextInitializer* ctxInitializer, FREContextFinalizer* ctxFinalizer);

EXPORT
void TRWVExtFinizer(void* extData);


#endif //WEBVIEWANE_WebViewANE_H
