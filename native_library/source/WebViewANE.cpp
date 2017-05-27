#include "WebViewANE.h"
#include "FlashRuntimeExtensions.h"
#include "stdafx.h"
#include "FreSharpBridge.h"

extern "C" {

	[System::STAThreadAttribute]
	BOOL APIENTRY WebViewANEMain(HMODULE hModule, DWORD  ul_reason_for_call, LPVOID lpReserved) {
		switch (ul_reason_for_call) {
		case DLL_PROCESS_ATTACH:
		case DLL_THREAD_ATTACH:
		case DLL_THREAD_DETACH:
		case DLL_PROCESS_DETACH:
			break;
		}
		return true;
	}

	void contextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx, uint32_t* numFunctionsToSet, const FRENamedFunction** functionsToSet) {
		
		FreSharpBridge::InitController();
		FreSharpBridge::SetFREContext(ctx);
		FreSharpBridge::GetFunctions();
		

		//TODO how to pass functionData without losing the string reference

		static FRENamedFunction extensionFunctions[] = {
			{ (const uint8_t *) "isSupported","isSupported", &callSharpFunction }
			,{ (const uint8_t *) "setBackgroundColor", "setBackgroundColor", &callSharpFunction }
			,{ (const uint8_t *) "init","init", &callSharpFunction }
			,{ (const uint8_t *) "addToStage", "addToStage", &callSharpFunction }
			,{ (const uint8_t *) "removeFromStage", "removeFromStage", &callSharpFunction }
			,{ (const uint8_t *) "shutDown", "shutDown", &callSharpFunction }
			,{ (const uint8_t *) "injectScript", "injectScript", &callSharpFunction }
			,{ (const uint8_t *) "load","load", &callSharpFunction }
			,{ (const uint8_t *) "loadFileURL", "loadFileURL", &callSharpFunction }
			,{ (const uint8_t *) "reload", "reload", &callSharpFunction }
			,{ (const uint8_t *) "reloadFromOrigin", "reloadFromOrigin", &callSharpFunction }
			,{ (const uint8_t *) "go", "go", &callSharpFunction }
			,{ (const uint8_t *) "goBack", "goBack", &callSharpFunction }
			,{ (const uint8_t *) "goForward", "goForward", &callSharpFunction }
			,{ (const uint8_t *) "stopLoading", "stopLoading", &callSharpFunction }
			,{ (const uint8_t *) "backForwardList", "backForwardList", &callSharpFunction }
			,{ (const uint8_t *) "allowsMagnification", "allowsMagnification", &callSharpFunction }
			,{ (const uint8_t *) "getMagnification", "getMagnification", &callSharpFunction }
			,{ (const uint8_t *) "setMagnification", "setMagnification", &callSharpFunction }
			,{ (const uint8_t *) "focus", "focus", &callSharpFunction }
			,{ (const uint8_t *) "loadHTMLString", "loadHTMLString", &callSharpFunction }
			,{ (const uint8_t *) "setPositionAndSize", "setPositionAndSize", &callSharpFunction }
			,{ (const uint8_t *) "showDevTools", "showDevTools", &callSharpFunction }
			,{ (const uint8_t *) "closeDevTools", "closeDevTools", &callSharpFunction }
			,{ (const uint8_t *) "onFullScreen", "onFullScreen", &callSharpFunction }
			,{ (const uint8_t *) "callJavascriptFunction", "callJavascriptFunction", &callSharpFunction }
			,{ (const uint8_t *) "evaluateJavaScript", "evaluateJavaScript", &callSharpFunction }
			,{ (const uint8_t *) "print", "print", &callSharpFunction }
			,{ (const uint8_t *) "capture", "capture", &callSharpFunction }
			
		};

		*numFunctionsToSet = sizeof(extensionFunctions) / sizeof(FRENamedFunction);
		*functionsToSet = extensionFunctions;
		
	}

	void contextFinalizer(FREContext ctx) {
		return;
	}

	void TRWVExtInizer(void** extData, FREContextInitializer* ctxInitializer, FREContextFinalizer* ctxFinalizer) {
		*ctxInitializer = &contextInitializer;
		*ctxFinalizer = &contextFinalizer;
	}

	void TRWVExtFinizer(void* extData) {
		FREContext nullCTX;
		nullCTX = 0;
		FreSharpBridge::GetController()->ShutDown();
		contextFinalizer(nullCTX);
		return;
	}
}
