#pragma once
#ifndef MAP_FUNCTION
#define MAP_FUNCTION(fn) { (const uint8_t*)(#fn), (#fn), &callSharpFunction }
#endif
#ifndef EXTENSION_INIT_DECL
#define EXTENSION_INIT_DECL(prefix) void (prefix##ExtInizer) (void **extData, FREContextInitializer *ctxInitializer, FREContextFinalizer *ctxFinalizer)
#endif

#ifndef EXTENSION_FIN_DECL
#define EXTENSION_FIN_DECL(prefix) void (prefix##ExtFinizer) (void *extData)
#endif

#ifndef EXTENSION_FIN
#define EXTENSION_FIN(prefix) void (prefix##ExtFinizer) (void *extData) { \
FREContext nullCTX = 0; \
prefix##_contextFinalizer(nullCTX); \
}
#endif

#ifndef CONTEXT_FIN
#define CONTEXT_FIN(prefix) void (prefix##_contextFinalizer) (FREContext ctx)
#endif

#ifndef EXTENSION_INIT	
#define EXTENSION_INIT(prefix) void (prefix##ExtInizer) (void **extData, FREContextInitializer *ctxInitializer, FREContextFinalizer *ctxFinalizer) { \
*ctxInitializer = &prefix##_contextInitializer; \
*ctxFinalizer = &prefix##_contextFinalizer; \
}
#endif

#ifndef SET_FUNCTIONS
#define SET_FUNCTIONS *numFunctionsToSet = sizeof( extensionFunctions ) / sizeof( FRENamedFunction ); \
*functionsToSet = extensionFunctions;
#endif

#ifndef FREBRIDGE_INIT
#define FREBRIDGE_INIT FreSharpBridge::InitController(); \
FreSharpBridge::SetFREContext(ctx); \
FreSharpBridge::GetFunctions();
#endif // !FREBRIDGE_INIT

#ifndef CONTEXT_INIT
#define CONTEXT_INIT(prefix) void (prefix##_contextInitializer)(void *extData, const uint8_t *ctxType, FREContext ctx, uint32_t *numFunctionsToSet, const FRENamedFunction **functionsToSet)
#endif