/* Copyright 2017 Tua Rua Ltd.
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.*/

#if __APPLE__
#include "TargetConditionals.h"
#if (TARGET_IPHONE_SIMULATOR) || (TARGET_OS_IPHONE)
#import <UIKit/UIKit.h>
#elif TARGET_OS_MAC
#import <Cocoa/Cocoa.h>
#else
#   error "Unknown Apple platform"
#endif

#endif

//! Project version number for FRESwift.
FOUNDATION_EXPORT double FreSwiftVersionNumber;

//! Project version string for FRESwift.
FOUNDATION_EXPORT const unsigned char FreSwiftVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <FRESwift/PublicHeader.h>

#import <FreSwift/FlashRuntimeExtensions.h>
