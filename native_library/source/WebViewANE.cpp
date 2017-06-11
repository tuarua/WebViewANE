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
			,{ (const uint8_t *) "init","init", &callSharpFunction }
			,{ (const uint8_t *) "addToStage", "addToStage", &callSharpFunction }
			,{ (const uint8_t *) "removeFromStage", "removeFromStage", &callSharpFunction }
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
