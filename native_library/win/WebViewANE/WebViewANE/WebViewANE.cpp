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

#include "FreSharpMacros.h"
#include "WebViewANE.h"
#include "FreSharpBridge.h"
#include "stdafx.h"
extern "C" {

	[System::STAThreadAttribute]
	BOOL APIENTRY WebViewANEMain(HMODULE hModule, DWORD  ul_reason_for_call, LPVOID lpReserved) {
		switch (ul_reason_for_call) {
		case DLL_PROCESS_ATTACH:
		case DLL_THREAD_ATTACH:
		case DLL_THREAD_DETACH:
		case DLL_PROCESS_DETACH:
			break;
		default: ;
		}
		return true;
	}


	CONTEXT_INIT(TRWV) {
		
		FreSharpBridge::InitController();
		FreSharpBridge::SetFREContext(ctx);
		FreSharpBridge::GetFunctions();
		
		static FRENamedFunction extensionFunctions[] = {
			 MAP_FUNCTION(init)
			,MAP_FUNCTION(setVisible)
			,MAP_FUNCTION(injectScript)
			,MAP_FUNCTION(load)
			,MAP_FUNCTION(loadFileURL)
			,MAP_FUNCTION(reload)
			,MAP_FUNCTION(reloadFromOrigin)
			,MAP_FUNCTION(go)
			,MAP_FUNCTION(goBack)
			,MAP_FUNCTION(goForward)
			,MAP_FUNCTION(stopLoading)
			,MAP_FUNCTION(backForwardList)
			,MAP_FUNCTION(allowsMagnification)
			,MAP_FUNCTION(zoomIn)
			,MAP_FUNCTION(zoomOut)
			,MAP_FUNCTION(focus)
			,MAP_FUNCTION(loadHTMLString)
			,MAP_FUNCTION(setViewPort)
			,MAP_FUNCTION(showDevTools)
			,MAP_FUNCTION(closeDevTools)
			,MAP_FUNCTION(onFullScreen)
			,MAP_FUNCTION(callJavascriptFunction)
			,MAP_FUNCTION(evaluateJavaScript)
			,MAP_FUNCTION(print)
			,MAP_FUNCTION(printToPdf)
			,MAP_FUNCTION(capture)
			,MAP_FUNCTION(getCapturedBitmapData)
			,MAP_FUNCTION(addTab)
			,MAP_FUNCTION(closeTab)
			,MAP_FUNCTION(setCurrentTab)
			,MAP_FUNCTION(getCurrentTab)
			,MAP_FUNCTION(getTabDetails)
			,MAP_FUNCTION(shutDown)
			,MAP_FUNCTION(clearCache)
			,MAP_FUNCTION(addEventListener)
			,MAP_FUNCTION(removeEventListener)
			,MAP_FUNCTION(getOsVersion)
			,MAP_FUNCTION(deleteCookies)
		};

		SET_FUNCTIONS
	}

	CONTEXT_FIN(TRWV) {
		FreSharpBridge::GetController()->OnFinalize();
	}

	EXTENSION_INIT(TRWV)
		 
	EXTENSION_FIN(TRWV)

}
