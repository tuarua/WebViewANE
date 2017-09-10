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

#ifndef FreMacros_h
#define FreMacros_h

#if __APPLE__
#include "TargetConditionals.h"
#if (TARGET_IPHONE_SIMULATOR) || (TARGET_OS_IPHONE)
#define IOS
#elif TARGET_OS_MAC
#define OSX
#else
#   error "Unknown Apple platform"
#endif
#endif

#import <Foundation/Foundation.h>
#import <FreSwift/FlashRuntimeExtensions.h>
#ifdef IOS
#import <FreSwift/FreSwift-iOS-Swift.h>
#else
#import <FreSwift/FreSwift-OSX-Swift.h>
#endif
#define NSStringize_helper(x) #x
#define NSStringize(x) @NSStringize_helper(x)
#define FRE_FUNCTION(fn) FREObject (fn)(FREContext context, void* functionData, uint32_t argc, FREObject argv[])
#define MAP_FUNCTION(prefix, fn) { (const uint8_t*)(#fn), (__bridge void *)(NSStringize(fn)), &prefix##_callSwiftFunction }

#define SET_FUNCTIONS *numFunctionsToSet = sizeof( extensionFunctions ) / sizeof( FRENamedFunction ); \
*functionsToSet = extensionFunctions;

#define CONTEXT_INIT(prefix) void (prefix##_contextInitializer)(void *extData, const uint8_t *ctxType, FREContext ctx, uint32_t *numFunctionsToSet, const FRENamedFunction **functionsToSet)

#define CONTEXT_FIN(prefix) void (prefix##_contextFinalizer) (FREContext ctx)

#define EXTENSION_INIT_DECL(prefix) void (prefix##ExtInizer) (void **extData, FREContextInitializer *ctxInitializer, FREContextFinalizer *ctxFinalizer)


#define EXTENSION_INIT(prefix) void (prefix##ExtInizer) (void **extData, FREContextInitializer *ctxInitializer, FREContextFinalizer *ctxFinalizer) { \
*ctxInitializer = &prefix##_contextInitializer; \
*ctxFinalizer = &prefix##_contextFinalizer; \
}

#define EXTENSION_FIN_DECL(prefix) void (prefix##ExtFinizer) (void *extData)
#define EXTENSION_FIN(prefix) void (prefix##ExtFinizer) (void *extData) { \
}

#ifdef IOS
#define SWIFT_DECL(prefix) prefix##_FlashRuntimeExtensionsBridge * prefix##_freBridge; \
SwiftController * prefix##_swft;  \
FreSwiftBridge * prefix##_swftBridge;  \
NSArray * prefix##_funcArray; \
FREObject (prefix##_callSwiftFunction) (FREContext context, void* functionData, uint32_t argc, FREObject argv[]) {\
NSString* name = (__bridge NSString *)(functionData); \
NSString* fName = [NSString stringWithFormat:@"%@%@", NSStringize(prefix)"_", name]; \
return [prefix##_swft callSwiftFunctionWithName:fName ctx:context argc:argc argv:argv]; \
}
#define SWIFT_INITS(prefix) prefix##_swft = [[SwiftController alloc] init]; \
[prefix##_swft setFREContextWithCtx:ctx]; \
prefix##_freBridge = [[prefix##_FlashRuntimeExtensionsBridge alloc] init]; \
prefix##_swftBridge = [[FreSwiftBridge alloc] init]; \
[prefix##_swftBridge setDelegateWithBridge:prefix##_freBridge]; \
prefix##_funcArray = [prefix##_swft getFunctionsWithPrefix:NSStringize(prefix)"_"];
#else
#define SWIFT_DECL(prefix) SwiftController * prefix##_swft; \
NSArray * prefix##_funcArray; \
FREObject (prefix##_callSwiftFunction) (FREContext context, void* functionData, uint32_t argc, FREObject argv[]) {\
NSString* name = (__bridge NSString *)(functionData); \
NSString* fName = [NSString stringWithFormat:@"%@%@", NSStringize(prefix)"_", name]; \
return [prefix##_swft callSwiftFunctionWithName:fName ctx:context argc:argc argv:argv]; \
}
#define SWIFT_INITS(prefix) prefix##_swft = [[SwiftController alloc] init]; \
[prefix##_swft setFREContextWithCtx:ctx]; \
prefix##_funcArray = [prefix##_swft getFunctionsWithPrefix:NSStringize(prefix)"_"];
#endif



#ifdef IOS
#define FRE_OBJC_BRIDGE_FUNCS \
- (FREResult)FREAcquireBitmapData2WithObject:(FREObject _Nonnull)object descriptorToSet:(FREBitmapData2 * _Nonnull)descriptorToSet { \
return FREAcquireBitmapData2(object, descriptorToSet); \
} \
- (FREResult)FREAcquireByteArrayWithObject:(FREObject _Nonnull)object byteArrayToSet:(FREByteArray * _Nonnull)byteArrayToSet { \
return FREAcquireByteArray(object, byteArrayToSet); \
} \
- (FREResult)FRECallObjectMethodWithObject:(FREObject _Nonnull)object methodName:(NSString * _Nonnull)methodName argc:(uint32_t)argc argv:(NSPointerArray * _Nullable)argv result:(FREObject _Nullable)result thrownException:(FREObject _Nullable)thrownException { \
if (argc > 0) { \
FREObject _argv[argc]; \
for (int i = 0; i < argc; ++i) { \
_argv[i] = [argv pointerAtIndex:i]; \
} \
return FRECallObjectMethod(object, (const uint8_t *) [methodName UTF8String], argc, _argv, result, thrownException); \
} \
return FRECallObjectMethod(object, (const uint8_t *) [methodName UTF8String], argc, NULL, result, thrownException); \
} \
- (FREResult)FREDispatchStatusEventAsyncWithCtx:(FREContext _Nonnull)ctx code:(NSString * _Nonnull)code level:(NSString * _Nonnull)level { \
return FREDispatchStatusEventAsync(ctx, (const uint8_t *) [code UTF8String], (const uint8_t *) [level UTF8String]); \
} \
- (FREResult)FREGetArrayElementAWithArrayOrVector:(FREObject _Nonnull)arrayOrVector index:(uint32_t)index value:(FREObject _Nullable)value { \
return FREGetArrayElementAt(arrayOrVector, index, value); \
} \
- (FREResult)FREGetArrayLengthWithArrayOrVector:(FREObject _Nonnull)arrayOrVector length:(uint32_t * _Nonnull)length { \
return FREGetArrayLength(arrayOrVector, length); \
} \
- (FREResult)FREGetContextActionScriptDataWithCtx:(FREContext _Nonnull)ctx actionScriptData:(FREObject _Nonnull)actionScriptData { \
return FREGetContextActionScriptData(ctx, actionScriptData); \
} \
- (FREResult)FREGetContextNativeDataWithCtx:(FREContext _Nonnull)ctx nativeData:(const void * _Nonnull * _Nonnull)nativeData { \
return FREGetContextNativeData(ctx, (void**)nativeData); \
} \
- (FREResult)FREGetObjectAsBoolWithObject:(FREObject _Nonnull)object value:(uint32_t * _Nonnull)value { \
return FREGetObjectAsBool(object, value); \
} \
- (FREResult)FREGetObjectAsDoubleWithObject:(FREObject _Nonnull)object value:(double * _Nonnull)value { \
return FREGetObjectAsDouble(object, value); \
} \
- (FREResult)FREGetObjectAsInt32WithObject:(FREObject _Nonnull)object value:(int32_t * _Nonnull)value { \
return FREGetObjectAsInt32(object, value); \
} \
- (FREResult)FREGetObjectAsUTF8WithObject:(FREObject _Nonnull)object length:(uint32_t * _Nonnull)length value:(const uint8_t *const  _Nullable * _Nullable)value { \
return FREGetObjectAsUTF8(object, length, (const uint8_t**)value); \
} \
- (FREResult)FREGetObjectAsUint32WithObject:(FREObject _Nonnull)object value:(uint32_t * _Nonnull)value { \
return FREGetObjectAsUint32(object, value); \
} \
- (FREResult)FREGetObjectPropertyWithObject:(FREObject _Nonnull)object propertyName:(NSString * _Nonnull)propertyName propertyValue:(FREObject _Nullable)propertyValue thrownException:(FREObject _Nullable)thrownException { \
return FREGetObjectProperty(object, (const uint8_t *) [propertyName UTF8String], propertyValue, &thrownException); \
} \
- (FREResult)FREGetObjectTypeWithObject:(FREObject _Nullable)object objectType:(FREObjectType * _Nonnull)objectType { \
return FREGetObjectType(object, objectType); \
} \
- (FREResult)FREInvalidateBitmapDataRectWithObject:(FREObject _Nonnull)object x:(uint32_t)x y:(uint32_t)y width:(uint32_t)width height:(uint32_t)height { \
return FREInvalidateBitmapDataRect(object, x, y, width, height); \
} \
- (FREResult)FRENewObjectFromBoolWithValue:(BOOL)value object:(FREObject _Nullable)object { \
return FRENewObjectFromBool(value ? 1 : 0, object); \
} \
- (FREResult)FRENewObjectFromDoubleWithValue:(double)value object:(FREObject _Nullable)object { \
return FRENewObjectFromDouble(value, object); \
} \
- (FREResult)FRENewObjectFromInt32WithValue:(int32_t)value object:(FREObject _Nullable)object { \
return FRENewObjectFromInt32(value, object); \
} \
- (FREResult)FRENewObjectFromUTF8WithLength:(uint32_t)length value:(NSString * _Nonnull)value object:(FREObject _Nullable)object { \
return FRENewObjectFromUTF8(length, (const uint8_t *) [value UTF8String], object); \
} \
- (FREResult)FRENewObjectFromUint32WithValue:(uint32_t)value object:(FREObject _Nullable)object { \
return FRENewObjectFromUint32(value, object); \
} \
- (FREResult)FRENewObjectWithClassName:(NSString * _Nonnull)className argc:(uint32_t)argc argv:(NSPointerArray * _Nullable)argv object:(FREObject _Nullable)object thrownException:(FREObject _Nullable)thrownException { \
if (argc > 0) { \
FREObject _argv[argc]; \
for (int i = 0; i < argc; ++i) { \
_argv[i] = [argv pointerAtIndex:i]; \
} \
return FRENewObject((const uint8_t *) [className UTF8String], argc, _argv, object, &thrownException); \
} \
return FRENewObject((const uint8_t *) [className UTF8String], argc, NULL, object, &thrownException); \
} \
- (FREResult)FREReleaseBitmapDataWithObject:(FREObject _Nonnull)object { \
return FREReleaseBitmapData(object); \
} \
- (FREResult)FREReleaseByteArrayWithObject:(FREObject _Nonnull)object { \
return FREReleaseByteArray(object); \
} \
- (FREResult)FRESetArrayElementAWithArrayOrVector:(FREObject _Nonnull)arrayOrVector index:(uint32_t)index value:(FREObject _Nullable)value { \
return FRESetArrayElementAt(arrayOrVector, index, value); \
} \
- (FREResult)FRESetArrayLengthWithArrayOrVector:(FREObject _Nonnull)arrayOrVector length:(uint32_t)length { \
return FRESetArrayLength(arrayOrVector, length); \
} \
- (FREResult)FRESetContextActionScriptDataWithCtx:(FREContext _Nonnull)ctx actionScriptData:(FREObject _Nonnull)actionScriptData { \
return FRESetContextActionScriptData(ctx, actionScriptData); \
} \
- (FREResult)FRESetContextNativeDataWithCtx:(FREContext _Nonnull)ctx nativeData:(const void * _Nonnull)nativeData { \
return FRESetContextNativeData(ctx, (void*)nativeData); \
} \
- (FREResult)FRESetObjectPropertyWithObject:(FREObject _Nonnull)object propertyName:(NSString * _Nonnull)propertyName propertyValue:(FREObject _Nullable)propertyValue thrownException:(FREObject _Nullable)thrownException { \
return FRESetObjectProperty(object, (const uint8_t *) [propertyName UTF8String], propertyValue, &thrownException); \
};
#endif
#endif /* FreMacros_h */
