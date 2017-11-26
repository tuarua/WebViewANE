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

#ifdef _WIN32
#elif __APPLE__

#include "TargetConditionals.h"
#import <Foundation/Foundation.h>
@interface WEBVIEWANE_LIB : NSObject
@end

#if (TARGET_IPHONE_SIMULATOR) || (TARGET_OS_IPHONE)

#elif TARGET_OS_MAC
#ifndef WEBVIEWANE_WebViewANE_H
#define WEBVIEWANE_WebViewANE_H


#import <Cocoa/Cocoa.h>
#include <Adobe AIR/Adobe AIR.h>

#define EXPORT __attribute__((visibility("default")))

EXPORT
EXTENSION_FIN_DECL(TRWV);

EXPORT
EXTENSION_INIT_DECL(TRWV);


#endif //WEBVIEWANE_WebViewANE_H

#else
#   error "Unknown Apple platform"
#endif
#endif
