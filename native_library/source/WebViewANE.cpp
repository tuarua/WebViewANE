#include "WebViewANE.h"
#include "FlashRuntimeExtensions.h"
#include <vector>

std::vector<std::string> funcArray;

#include "stdafx.h"

namespace ManagedCode {
	using namespace System;
	using namespace System::Windows;
	using namespace System::Windows::Interop;
	using namespace System::Windows::Media;
	using namespace System::Collections::Generic;
	using FREObjectSharp = IntPtr;
	using FREContextSharp = IntPtr;
	using FREArgvSharp = array<FREObjectSharp>^;

	ref class ManagedGlobals {
	public:
		static CefSharpLib::MainController^ controller = nullptr;
	};

	array<FREObjectSharp>^ MarshalFREArray(array<FREObject>^ argv, uint32_t argc) {
		array<FREObjectSharp>^ arr = gcnew array<FREObjectSharp>(argc);
		for (uint32_t i = 0; i < argc; i++) {
			arr[i] = FREObjectSharp(argv[i]);
		}
		return arr;
	}

	void MarshalString(String ^ s, std::string& os) {
		using namespace Runtime::InteropServices;
		const char* chars =
			(const char*)(Marshal::StringToHGlobalAnsi(s)).ToPointer();
		os = chars;
		Marshal::FreeHGlobal(FREObjectSharp((void*)chars));
	}


	FREObject CallSharpFunction(String^ name, FREContext context, array<FREObject>^ argv, uint32_t argc) {
		return (FREObject)ManagedGlobals::controller->CallSharpFunction(name, FREContextSharp(context), argc, MarshalFREArray(argv, argc));
	}

	void SetFREContext(FREContext freContext) {
		ManagedGlobals::controller->SetFreContext(FREContextSharp(freContext));
	}

	void InitController() {
		ManagedGlobals::controller = gcnew CefSharpLib::MainController();
	}

	void ShutDown() {
		ManagedGlobals::controller->ShutDown();
	}

	std::vector<std::string> GetFunctions() {
		std::vector<std::string> ret;
		array<String^>^ mArray = ManagedGlobals::controller->GetFunctions();
		int i = 0;
		for (i = 0; i < mArray->Length; ++i) {
			std::string itemStr = "";
			MarshalString(mArray[i], itemStr);
			ret.push_back(itemStr);
		}
		return ret;
	}
	
}

extern "C" {

#define FRE_FUNCTION(fn) FREObject (fn)(FREContext context, void* functionData, uint32_t argc, FREObject argv[])

	array<FREObject>^ getArgvAsArray(FREObject argv[], uint32_t argc) {
		array<FREObject>^ arr = gcnew array<FREObject>(argc);
		for (uint32_t i = 0; i < argc; i++) {
			arr[i] = argv[i];
		}
		return arr;
	}

	FRE_FUNCTION(callSharpFunction) {
		std::string fName = std::string((const char*)functionData);
		return ManagedCode::CallSharpFunction(gcnew System::String(fName.c_str()), context, getArgvAsArray(argv, argc), argc);
	}

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
		
		ManagedCode::InitController();
		ManagedCode::SetFREContext(ctx);
		funcArray = ManagedCode::GetFunctions();
		
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
		ManagedCode::ShutDown();
		contextFinalizer(nullCTX);
		return;
	}
}
