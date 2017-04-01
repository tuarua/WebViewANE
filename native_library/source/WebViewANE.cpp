#include "WebViewANE.h"
#include <sstream>
#include <iostream>
#include <windows.h>
#include <conio.h>

#include "FlashRuntimeExtensions.h"
#include "ANEHelper.h"
#include <string>

ANEHelper aneHelper = ANEHelper();
using namespace std;
const std::string ANE_NAME = "WebViewANE";

DWORD windowID;
HWND _hwnd;
FREContext dllContext;

int cef_width = 800;
int cef_height = 600;
int cef_x = 0;
int cef_y = 0;

unsigned int cef_bg_r = 255;
unsigned int cef_bg_g = 255;
unsigned int cef_bg_b = 255;

bool cef_enableDownloads;

vector<pair<string, string>> cef_commandLineArgs;
int cef_remoteDebuggingPort;
string cef_cachePath;
int cef_logSeverity;
string cef_userAgent;
string cef_browserSubprocessPath;
string cef_initialUrl;

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

	void MarshalString(String ^ s, string& os) {
		using namespace Runtime::InteropServices;
		const char* chars =
			(const char*)(Marshal::StringToHGlobalAnsi(s)).ToPointer();
		os = chars;
		Marshal::FreeHGlobal(IntPtr((void*)chars));
	}

	void onCefLibMessage(Object ^sender, CefSharpLib::MessageEventArgs ^args) {
		System::String^ type = args->Type;
		System::String^ message = args->Message;
		string typeStr = "";
		MarshalString(type, typeStr);
		string messageStr = "";
		MarshalString(message, messageStr);
		aneHelper.dispatchEvent(dllContext, typeStr, messageStr);
	}

	HWND GetHwnd(HWND parent) {
		HwndSourceParameters parameters;
		parameters.SetPosition(cef_x, cef_y);
		parameters.SetSize(cef_width, cef_height);
		parameters.ParentWindow = IntPtr(parent);
		parameters.WindowName = "Cef Window";
		parameters.WindowStyle = WS_CHILD;
		parameters.AcquireHwndFocusInMenuMode = true;
		HwndSource^ source = gcnew HwndSource(parameters);

		Dictionary<String^, String^>^ cs_cef_commandLineArgs = gcnew Dictionary<String^, String^>();
		for (vector<pair<string, string>>::const_iterator i = cef_commandLineArgs.begin(); i != cef_commandLineArgs.end(); ++i) {
			cs_cef_commandLineArgs->Add(gcnew String(i->first.c_str()), gcnew String(i->second.c_str()));
		}
		
		ManagedGlobals::page = gcnew CefSharpLib::CefPage(gcnew String(cef_initialUrl.c_str()),gcnew String(cef_userAgent.c_str()), cef_logSeverity, cef_logSeverity,
			gcnew String(cef_cachePath.c_str()), cs_cef_commandLineArgs, gcnew String(cef_browserSubprocessPath.c_str()), 
			cef_bg_r, cef_bg_g, cef_bg_b, cef_enableDownloads);

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

	void InjectScript(String^ code, String^ scriptUrl, unsigned int startLine) {
		ManagedGlobals::page->InjectScript(code, scriptUrl, startLine);
	}

	void Print() {
		ManagedGlobals::page->Print();
	}

}


extern "C" {
	int logLevel = 1;
	
	HWND cefHwnd;

	extern void trace(string msg) {
		string value = "["+ANE_NAME+"] " + msg;
		//if (logLevel > 0)
		aneHelper.dispatchEvent(dllContext, "TRACE", value);
	}

#define FRE_FUNCTION(fn) FREObject (fn)(FREContext context, void* functionData, uint32_t argc, FREObject argv[])

	FRE_FUNCTION(init) {
		cef_initialUrl = aneHelper.getString(argv[0]);
		cef_x = aneHelper.getInt32(argv[1]);
		cef_y = aneHelper.getInt32(argv[2]);
		cef_width = aneHelper.getInt32(argv[3]);
		cef_height = aneHelper.getInt32(argv[4]);

		FREObjectType settingsType;
		FREGetObjectType(argv[5], &settingsType);

		if (FRE_TYPE_NULL != settingsType) {

			FREObject cefSettingsFRE = aneHelper.getProperty(argv[5], "cef");
			cef_remoteDebuggingPort = aneHelper.getInt32(aneHelper.getProperty(cefSettingsFRE, "remoteDebuggingPort"));
			cef_cachePath = aneHelper.getString(aneHelper.getProperty(cefSettingsFRE, "cachePath"));
			cef_logSeverity = aneHelper.getInt32(aneHelper.getProperty(cefSettingsFRE, "logSeverity"));
			cef_browserSubprocessPath = aneHelper.getString(aneHelper.getProperty(cefSettingsFRE, "browserSubprocessPath"));
			cef_enableDownloads = aneHelper.getBool(aneHelper.getProperty(cefSettingsFRE, "enableDownloads"));

			cef_userAgent = aneHelper.getString(aneHelper.getProperty(argv[5], "userAgent"));
			
			FREObject commandLineArgsFRE = aneHelper.getProperty(cefSettingsFRE, "commandLineArgs");
			uint32_t numArgs = aneHelper.getArrayLength(commandLineArgsFRE);

			for (unsigned int j = 0; j < numArgs; ++j) {
				FREObject elemAS = NULL;
				FREGetArrayElementAt(commandLineArgsFRE, j, &elemAS);
				string key = aneHelper.getString(aneHelper.getProperty(elemAS, "key"));
				string val = aneHelper.getString(aneHelper.getProperty(elemAS, "value"));
				cef_commandLineArgs.push_back(make_pair(key, val));
			}
		}
		cefHwnd = ManagedCode::GetHwnd(_hwnd);
		RegisterTouchWindow(cefHwnd, TWF_WANTPALM);
		return NULL;
	}

	FRE_FUNCTION(setPositionAndSize) {
		using namespace std;
		int tmp_x = aneHelper.getInt32(argv[0]);
		int tmp_y = aneHelper.getInt32(argv[1]);
		int tmp_width = aneHelper.getInt32(argv[2]);
		int tmp_height = aneHelper.getInt32(argv[3]);

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
				flg += SWP_NOSIZE;
				
			if (!updateX && !updateY)
				flg += SWP_NOMOVE;

			SetWindowPos(cefHwnd,
				HWND_TOP,
				cef_x,
				cef_y,
				cef_width,
				cef_height,
				flg);
			UpdateWindow(cefHwnd);
		}
		return NULL;
	}

	FRE_FUNCTION(isSupported) {
		using namespace std;
		return aneHelper.getFREObject(true);
	}

	FRE_FUNCTION(load) {
		using namespace std;
		using namespace System;
		string url = aneHelper.getString(argv[0]);
		String^ cs_url = gcnew String(url.c_str());
		ManagedCode::Load(cs_url);
		return NULL;
	}

	FRE_FUNCTION(LoadHtmlString) {
		using namespace std;
		using namespace System;
		string html = aneHelper.getString(argv[0]);
		String^ cs_html = gcnew String(html.c_str());
		string url = aneHelper.getString(argv[1]);
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
		return aneHelper.getFREObject(true);
	}
	
	FRE_FUNCTION(getMagnification) {
		return aneHelper.getFREObject(ManagedCode::GetMagnification());
	}

	FRE_FUNCTION(setMagnification) {
		double value = aneHelper.getDouble(argv[0]);
		ManagedCode::SetMagnification(value);
		return NULL;
	}
	
	FRE_FUNCTION(addToStage) {
		using namespace std;
		ShowWindow(cefHwnd, SW_SHOWDEFAULT);
		UpdateWindow(cefHwnd);
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
		string js = aneHelper.getString(argv[0]);
		FREObjectType callbackType;
		FREGetObjectType(argv[1], &callbackType);

		if (FRE_TYPE_NULL != callbackType) {
			string callback = aneHelper.getString(argv[1]);
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

		string js = aneHelper.getString(argv[0]);
		FREObjectType callbackType;
		FREGetObjectType(argv[1], &callbackType);

		if (FRE_TYPE_NULL != callbackType) {
			string callback = aneHelper.getString(argv[1]);
			ManagedCode::EvaluateJavaScript(gcnew String(js.c_str()), gcnew String(callback.c_str()));
		}
		else {
			ManagedCode::EvaluateJavaScript(gcnew String(js.c_str()));
		}

		return NULL;
	}

	FRE_FUNCTION(setBackgroundColor) {
		cef_bg_r = aneHelper.getUInt32(argv[0]);
		cef_bg_g = aneHelper.getUInt32(argv[1]);
		cef_bg_b = aneHelper.getUInt32(argv[2]);
		return NULL;
	}

	FRE_FUNCTION(shutDown) {
		ManagedCode::ShutDown();
		return NULL;
	}

	FRE_FUNCTION(injectScript) {
		using namespace std;
		using namespace System;
		string code;
		string scriptUrl;
		unsigned int startLine = aneHelper.getUInt32(argv[2]);

		FREObjectType codeType;
		FREGetObjectType(argv[0], &codeType);

		FREObjectType scriptUrlType;
		FREGetObjectType(argv[1], &scriptUrlType);

		if (FRE_TYPE_NULL != codeType) {
			code = aneHelper.getString(argv[0]);
		}
			
		if (FRE_TYPE_NULL != scriptUrlType) {
			scriptUrl = aneHelper.getString(argv[1]);
		}
			
		ManagedCode::InjectScript(gcnew String(code.c_str()), gcnew String(scriptUrl.c_str()), startLine);
		
		return NULL;
	}

	FRE_FUNCTION(print) {
		ManagedCode::Print();
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
		
		DWORD processID = GetCurrentProcessId();
		EnumWindows(EnumProc, processID);

		static FRENamedFunction extensionFunctions[] = {
			{ (const uint8_t*) "init",nullptr, &init }
			,{ (const uint8_t*) "isSupported",nullptr, &isSupported }
			,{ (const uint8_t*) "addToStage",nullptr, &addToStage }
			,{ (const uint8_t*) "load",nullptr, &load }
			,{ (const uint8_t *) "loadFileURL", nullptr, &load }
			,{ (const uint8_t *) "reload", nullptr, &reload }
			,{ (const uint8_t *) "backForwardList", nullptr, &backForwardList }
			,{ (const uint8_t *) "go", nullptr, &go }
			,{ (const uint8_t *) "goBack", nullptr, &goBack }
			,{ (const uint8_t *) "goForward", nullptr, &goForward }
			,{ (const uint8_t *) "stopLoading", nullptr, &stopLoading }
			,{ (const uint8_t *) "reloadFromOrigin", nullptr, &reloadFromOrigin }
			,{ (const uint8_t *) "allowsMagnification", nullptr, &allowsMagnification }
			,{ (const uint8_t *) "getMagnification", nullptr, &getMagnification }
			,{ (const uint8_t *) "setMagnification", nullptr, &setMagnification }
			,{ (const uint8_t *) "loadHTMLString", nullptr, &LoadHtmlString }
			,{ (const uint8_t *) "removeFromStage", nullptr, &removeFromStage }
			,{ (const uint8_t *) "setPositionAndSize", nullptr, &setPositionAndSize }
			,{ (const uint8_t *) "showDevTools", nullptr, &showDevTools }
			,{ (const uint8_t *) "closeDevTools", nullptr, &closeDevTools }
			,{ (const uint8_t *) "onFullScreen", nullptr, &onFullScreen }
			,{ (const uint8_t *) "callJavascriptFunction", nullptr, &callJavascriptFunction }
			,{ (const uint8_t *) "evaluateJavaScript", nullptr, &evaluateJavaScript }
			,{ (const uint8_t *) "setBackgroundColor", nullptr, &setBackgroundColor }
			,{ (const uint8_t *) "shutDown", nullptr, &shutDown }
			,{ (const uint8_t *) "injectScript", nullptr, &injectScript }

			,{ (const uint8_t *) "print", nullptr, &print }
			

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
