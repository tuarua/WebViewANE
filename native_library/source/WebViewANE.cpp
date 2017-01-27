#include "WebViewANE.h"
#include <sstream>
#include <iostream>
#include <windows.h>
#include <conio.h>

#include "FlashRuntimeExtensions.h"
bool isSupportedInOS = true;
std::string pathSlash = "\\";

#include "../include/ANEhelper.h"
#include <string>

#include <vector>


const std::string ANE_NAME = "WebViewANE";

DWORD windowID;
HWND _hwnd;
HWND _hEdit;
FREContext dllContext;

int cef_width = 800;
int cef_height = 600;
int cef_x = 0;
int cef_y = 0;

unsigned int cef_bg_r = 255;
unsigned int cef_bg_g = 255;
unsigned int cef_bg_b = 255;

std::vector<std::pair<std::string, std::string>> cef_commandLineArgs;
int cef_remoteDebuggingPort;
std::string cef_cachePath;
int cef_logSeverity;
bool cef_bestPerformance;

#include "stdafx.h"
#include "commctrl.h"
#include <Windows.h>

namespace ManagedCode {
	using namespace System;
	using namespace System::Windows;
	using namespace System::Windows::Interop;
	using namespace System::Windows::Media;
	using namespace System::Collections::Generic;

	ref class ManagedGlobals {
	public:
		static CefSharpLib::CefPage^ page = nullptr;
	};

	void MarshalString(String ^ s, std::string& os) {
		using namespace Runtime::InteropServices;
		const char* chars =
			(const char*)(Marshal::StringToHGlobalAnsi(s)).ToPointer();
		os = chars;
		Marshal::FreeHGlobal(IntPtr((void*)chars));
	}

	void onCefLibMessage(Object ^sender, CefSharpLib::MessageEventArgs ^args) {
		System::String^ type = args->Type;
		System::String^ message = args->Message;
		std::string typeStr = "";
		MarshalString(type, typeStr);
		std::string messageStr = "";
		MarshalString(message, messageStr);

		FREDispatchStatusEventAsync(dllContext, (uint8_t*)messageStr.c_str(), (const uint8_t*)typeStr.c_str());
	}

	HWND GetHwnd(HWND parent) {

		HwndSourceParameters parameters;
		parameters.SetPosition(cef_x, cef_y);
		parameters.SetSize(cef_width, cef_height);
		parameters.ParentWindow = IntPtr(parent);
		parameters.WindowName = "Cef Window";
		parameters.WindowStyle = WS_CHILD;
		parameters.AcquireHwndFocusInMenuMode = true;
		//parameters.WindowClassStyle = 0;
		//parameters.ExtendedWindowStyle = 0;
		HwndSource^ source = gcnew HwndSource(parameters);

		Dictionary<String^, String^>^ cs_cef_commandLineArgs = gcnew Dictionary<String^, String^>();
		for (std::vector<std::pair<std::string, std::string>>::const_iterator i = cef_commandLineArgs.begin(); i != cef_commandLineArgs.end(); ++i) {
			cs_cef_commandLineArgs->Add(gcnew String(i->first.c_str()), gcnew String(i->second.c_str()));
		}

		ManagedGlobals::page = gcnew CefSharpLib::CefPage(cef_bestPerformance, cef_logSeverity, cef_logSeverity, 
			gcnew String(cef_cachePath.c_str()), cs_cef_commandLineArgs, cef_bg_r, cef_bg_g, cef_bg_b);
		ManagedGlobals::page->OnMessageSent += gcnew CefSharpLib::CefPage::MessageHandler(onCefLibMessage);

		source->RootVisual = ManagedGlobals::page; //is this wherer the visual is added
		return (HWND)source->Handle.ToPointer();
	}

	void Load(System::String^ url) {
		ManagedGlobals::page->Load(url);
	}

	void LoadHtmlString(System::String^ html, System::String^ url) {
		ManagedGlobals::page->LoadHtmlString(html, url);
	}

	void Reload() {
		ManagedGlobals::page->Reload();
	}

	void ReloadFromOrigin() {
		ManagedGlobals::page->ReloadFromOrigin();
	}

	void GoForward() {
		ManagedGlobals::page->GoForward();
	}

	void GoBack() {
		ManagedGlobals::page->GoBack();
	}

	void StopLoading() {
		ManagedGlobals::page->StopLoading();
	}

	void SetMagnification(System::Double value) {
		ManagedGlobals::page->SetMagnification(value);
	}

	double GetMagnification() {
		return ManagedGlobals::page->GetMagnification();
	}

	void EvaluateJavaScript(System::String^ js) {
		ManagedGlobals::page->EvaluateJavaScript(js);
	}

	void EvaluateJavaScript(System::String^ js, String^ cb) {
		ManagedGlobals::page->EvaluateJavaScript(js, cb);
	}

	void CallJavascriptFunction(String^ js) {
		ManagedGlobals::page->CallJavascriptFunction(js);
	}

	void CallJavascriptFunction(String^ js, String^ cb) {
		ManagedGlobals::page->CallJavascriptFunction(js, cb);
	}

	void ShowDevTools() {
		ManagedGlobals::page->ShowDevTools();
	}

	void CloseDevTools() {
		ManagedGlobals::page->CloseDevTools();
	}

	void ShutDown() {
		ManagedGlobals::page->ShutDown();
	}

}


extern "C" {
	int logLevel = 1;
	
	HWND cefHwnd;

	extern void trace(std::string msg) {
		std::string value = "["+ANE_NAME+"] " + msg;
		//if (logLevel > 0)
			FREDispatchStatusEventAsync(dllContext, (uint8_t*)value.c_str(), (const uint8_t*) "TRACE");
	}

#define FRE_FUNCTION(fn) FREObject (fn)(FREContext context, void* functionData, uint32_t argc, FREObject argv[])

	FRE_FUNCTION(init) {
		using namespace std;
		cef_x = getInt32FromFREObject(argv[0]);
		cef_y = getInt32FromFREObject(argv[1]);
		cef_width = getInt32FromFREObject(argv[2]);
		cef_height = getInt32FromFREObject(argv[3]);

		FREObjectType settingsType;
		FREGetObjectType(argv[4], &settingsType);

		if (FRE_TYPE_NULL != settingsType) {
			FREObject cefSettingsFRE = getFREObjectProperty(argv[4], (const uint8_t*) "cef");
			cef_remoteDebuggingPort = getInt32FromFREObject(getFREObjectProperty(cefSettingsFRE, (const uint8_t*) "remoteDebuggingPort"));
			cef_cachePath = getStringFromFREObject(getFREObjectProperty(cefSettingsFRE, (const uint8_t*) "cachePath"));
			cef_logSeverity = getInt32FromFREObject(getFREObjectProperty(cefSettingsFRE, (const uint8_t*) "logSeverity"));
			cef_bestPerformance = getBoolFromFREObject(getFREObjectProperty(cefSettingsFRE, (const uint8_t*) "bestPerformance"));
			
			FREObject commandLineArgsFRE = getFREObjectProperty(cefSettingsFRE, (const uint8_t*) "commandLineArgs");
			uint32_t numArgs = getFREObjectArrayLength(commandLineArgsFRE);

			for (unsigned int j = 0; j < numArgs; ++j) {
				FREObject elemAS = NULL;
				FREGetArrayElementAt(commandLineArgsFRE, j, &elemAS);
				string key = getStringFromFREObject(getFREObjectProperty(elemAS, (const uint8_t*) "key"));
				string val = getStringFromFREObject(getFREObjectProperty(elemAS, (const uint8_t*) "value"));
				cef_commandLineArgs.push_back(make_pair(key, val));
			}
		}
		cefHwnd = ManagedCode::GetHwnd(_hwnd);
		return NULL;
	}

	FRE_FUNCTION(setPositionAndSize) {
		using namespace std;
		int tmp_x = getInt32FromFREObject(argv[0]);
		int tmp_y = getInt32FromFREObject(argv[1]);
		int tmp_width = getInt32FromFREObject(argv[2]);
		int tmp_height = getInt32FromFREObject(argv[3]);

		bool updateWidth = false;
		bool updateHeight = false;
		bool updateX = false;
		bool updateY = false;

		if (tmp_width != cef_width) {
			cef_width = tmp_width;
			updateWidth = true;
		}

		if (tmp_height != cef_height) {
			cef_height = tmp_height;
			updateHeight = true;
		}

		if (tmp_x != cef_x) {
			cef_x = tmp_x;
			updateX = true;
		}

		if (tmp_y != cef_y) {
			cef_y = tmp_y;
			updateY = true;
		}

		if (updateX || updateY || updateWidth || updateHeight) {
			auto flg = NULL;
			if (!updateWidth && !updateHeight)
				flg = SWP_NOSIZE;
			if (!updateX && !updateY)
				flg = SWP_NOMOVE;

			SetWindowPos(cefHwnd,
				HWND_TOP,
				(updateX) ? cef_x : 0,
				(updateY) ? cef_y : 0,
				(updateWidth) ? cef_width : 0,
				(updateHeight) ? cef_height : 0,
				flg);
			UpdateWindow(cefHwnd);
		}
		return NULL;
	}

	FRE_FUNCTION(isSupported) {
		using namespace std;
		return getFREObjectFromBool(true);
	}

	FRE_FUNCTION(load) {
		using namespace std;
		using namespace System;
		string url = getStringFromFREObject(argv[0]);
		String^ cs_url = gcnew String(url.c_str());
		ManagedCode::Load(cs_url);
		return NULL;
	}

	FRE_FUNCTION(LoadHtmlString) {
		using namespace std;
		using namespace System;
		string html = getStringFromFREObject(argv[0]);
		String^ cs_html = gcnew String(html.c_str());
		string url = getStringFromFREObject(argv[1]);
		String^ cs_url = gcnew String(url.c_str());
		ManagedCode::LoadHtmlString(cs_html, cs_url);
		return NULL;
	}
	
	FRE_FUNCTION(reload) {
		ManagedCode::Reload();
		return NULL;
	}

	FRE_FUNCTION(reloadFromOrigin) {
		ManagedCode::ReloadFromOrigin();
		return NULL;
	}

	FRE_FUNCTION(goBack) {
		ManagedCode::GoBack();
		return NULL;
	}

	FRE_FUNCTION(goForward) {
		ManagedCode::GoForward();
		return NULL;
	}

	FRE_FUNCTION(stopLoading) {
		ManagedCode::StopLoading();
		return NULL;
	}

	FRE_FUNCTION(allowsMagnification) {
		return getFREObjectFromBool(true);
	}
	
	FRE_FUNCTION(getMagnification) {
		return getFREObjectFromDouble(ManagedCode::GetMagnification());
	}

	FRE_FUNCTION(setMagnification) {
		double value = getDoubleFromFREObject(argv[0]);
		ManagedCode::SetMagnification(value);
		return NULL;
	}

	
	

	
	FRE_FUNCTION(addToStage) {
		using namespace std;
		

		ShowWindow(cefHwnd, SW_SHOWDEFAULT);
		UpdateWindow(cefHwnd);

		//do I need this ?
		//System::Windows::Interop::HwndSource^ hws = ManagedCode::HwndSource::FromHwnd(System::IntPtr(cefHwnd)); //seems to run without this ?
		//hws->
		return NULL;
	}

	FRE_FUNCTION(removeFromStage) {
		ShowWindow(cefHwnd, SW_HIDE);
		UpdateWindow(cefHwnd);
		return NULL;
	}

	FRE_FUNCTION(showDevTools) {
		ManagedCode::ShowDevTools();
		return NULL;
	}

	FRE_FUNCTION(closeDevTools) {
		ManagedCode::CloseDevTools();
		return NULL;
	}

	FRE_FUNCTION(onFullScreen) {
		return NULL;
	}

	FRE_FUNCTION(go) {
		return NULL;
	}

	FRE_FUNCTION(backForwardList) {
		return NULL;
	}

	FRE_FUNCTION(callJavascriptFunction) {
		using namespace std;
		using namespace System;
		string js = getStringFromFREObject(argv[0]);
		FREObjectType callbackType;
		FREGetObjectType(argv[1], &callbackType);

		if (FRE_TYPE_NULL != callbackType) {
			string callback = getStringFromFREObject(argv[1]);
			ManagedCode::CallJavascriptFunction(gcnew String(js.c_str()), gcnew String(callback.c_str()));
		}
		else {
			ManagedCode::CallJavascriptFunction(gcnew String(js.c_str()));
		}

		return NULL;
	}

	FRE_FUNCTION(evaluateJavaScript) {
		using namespace std;
		using namespace System;

		string js = getStringFromFREObject(argv[0]);
		FREObjectType callbackType;
		FREGetObjectType(argv[1], &callbackType);

		if (FRE_TYPE_NULL != callbackType) {
			string callback = getStringFromFREObject(argv[1]);
			ManagedCode::EvaluateJavaScript(gcnew String(js.c_str()), gcnew String(callback.c_str()));
		}
		else {
			ManagedCode::EvaluateJavaScript(gcnew String(js.c_str()));
		}

		return NULL;
	}

	FRE_FUNCTION(setBackgroundColor) {
		cef_bg_r = getUInt32FromFREObject(argv[0]);
		cef_bg_g = getUInt32FromFREObject(argv[1]);
		cef_bg_b = getUInt32FromFREObject(argv[2]);
		return NULL;
	}

	FRE_FUNCTION(shutDown) {
		ManagedCode::ShutDown();
		return NULL;
	}

	BOOL CALLBACK EnumProc(HWND hwnd, LPARAM lParam) {
		GetWindowThreadProcessId(hwnd, &windowID);
		if (windowID == lParam) {
			_hwnd = hwnd;
			return false;
		}
		return true;
	}

	[System::STAThreadAttribute]
	BOOL APIENTRY WebViewANEMain(HMODULE hModule,
		DWORD  ul_reason_for_call,
		LPVOID lpReserved
		)
	{
		switch (ul_reason_for_call)
		{
		case DLL_PROCESS_ATTACH:
		case DLL_THREAD_ATTACH:
		case DLL_THREAD_DETACH:
		case DLL_PROCESS_DETACH:
			break;
		}
		return TRUE;
	}

	
	void contextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx, uint32_t* numFunctionsToSet, const FRENamedFunction** functionsToSet) {
		
		DWORD processID = GetCurrentProcessId();
		EnumWindows(EnumProc, processID);

		static FRENamedFunction extensionFunctions[] = {
			{ (const uint8_t*) "init",NULL, &init }
			,{ (const uint8_t*) "isSupported",NULL, &isSupported }
			,{ (const uint8_t*) "addToStage",NULL, &addToStage }
			,{ (const uint8_t*) "load",NULL, &load }
			,{ (const uint8_t *) "loadFileURL", NULL, &load }
			,{ (const uint8_t *) "reload", NULL, &reload }
			,{ (const uint8_t *) "backForwardList", NULL, &backForwardList }
			,{ (const uint8_t *) "go", NULL, &go }
			,{ (const uint8_t *) "goBack", NULL, &goBack }
			,{ (const uint8_t *) "goForward", NULL, &goForward }
			,{ (const uint8_t *) "stopLoading", NULL, &stopLoading }
			,{ (const uint8_t *) "reloadFromOrigin", NULL, &reloadFromOrigin }
			,{ (const uint8_t *) "allowsMagnification", NULL, &allowsMagnification }
			,{ (const uint8_t *) "getMagnification", NULL, &getMagnification }
			,{ (const uint8_t *) "setMagnification", NULL, &setMagnification }
			,{ (const uint8_t *) "loadHTMLString", NULL, &LoadHtmlString }
			,{ (const uint8_t *) "removeFromStage", NULL, &removeFromStage }
			,{ (const uint8_t *) "setPositionAndSize", NULL, &setPositionAndSize }
			,{ (const uint8_t *) "showDevTools", NULL, &showDevTools }
			,{ (const uint8_t *) "closeDevTools", NULL, &closeDevTools }
			,{ (const uint8_t *) "onFullScreen", NULL, &onFullScreen }
			,{ (const uint8_t *) "callJavascriptFunction", NULL, &callJavascriptFunction }
			,{ (const uint8_t *) "evaluateJavaScript", NULL, &evaluateJavaScript }

			,{ (const uint8_t *) "setBackgroundColor", NULL, &setBackgroundColor }
			,{ (const uint8_t *) "shutDown", NULL, &shutDown }

		};

		*numFunctionsToSet = sizeof(extensionFunctions) / sizeof(FRENamedFunction);
		*functionsToSet = extensionFunctions;
		dllContext = ctx;
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
		cefHwnd = NULL;
		contextFinalizer(nullCTX);
		return;
	}
}
