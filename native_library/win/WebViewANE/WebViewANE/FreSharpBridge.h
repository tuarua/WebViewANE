#pragma once
#include "FlashRuntimeExtensions.h"
#include <vector>
#include "FreNamespace.h"

namespace FreSharpBridge {
	using namespace System;
	using namespace Windows;
	using namespace Interop;
	using namespace Windows::Media;
	using namespace Collections::Generic;
	using FREObjectCLR = IntPtr;
	using FREContextCLR = IntPtr;
	using FREArgvSharp = array<FREObjectCLR>^;
	public ref class ManagedGlobals {
	public:
		static FreNamespace::MainController^ controller = nullptr;
	};
	void MarshalString(String ^ s, std::string& os);
	array<FREObjectCLR>^ MarshalFREArray(array<FREObject>^ argv, uint32_t argc);
	std::vector<std::string> GetFunctions();
	FREObject CallSharpFunction(String^ name, FREContext context, array<FREObject>^ argv, uint32_t argc);
	void SetFREContext(FREContext freContext);
	void InitController();
	FreNamespace::MainController^ GetController();
}
extern "C" {
#define FRE_FUNCTION(fn) FREObject (fn)(FREContext context, void* functionData, uint32_t argc, FREObject argv[])

	array<FREObject>^ getArgvAsArray(FREObject argv[], uint32_t argc);
	FRE_FUNCTION(callSharpFunction);

}