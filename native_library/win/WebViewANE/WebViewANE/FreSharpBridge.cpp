#include "FreSharpBridge.h"
namespace FreSharpBridge {

	void MarshalString(String ^ s, std::string& os) {
		using namespace Runtime::InteropServices;
		const char* chars =
			reinterpret_cast<const char*>(Marshal::StringToHGlobalAnsi(s).ToPointer());
		os = chars;
		// ReSharper disable once CppCStyleCast
		Marshal::FreeHGlobal(FREObjectCLR((void*)chars));
	}

	array<FREObjectCLR>^ MarshalFREArray(array<FREObject>^ argv, uint32_t argc) {
		auto arr = gcnew array<FREObjectCLR>(argc);
		for (uint32_t i = 0; i < argc; i++) {
			arr[i] = FREObjectCLR(argv[i]);
		}
		return arr;
	}

	std::vector<std::string> GetFunctions() {
		std::vector<std::string> ret;
		auto mArray = ManagedGlobals::controller->GetFunctions();
		for (auto i = 0; i < mArray->Length; ++i) {
			std::string itemStr = "";
			MarshalString(mArray[i], itemStr);
			ret.push_back(itemStr);
		}
		return ret;
	}

	FREObject CallSharpFunction(String^ name, FREContext context, array<FREObject>^ argv, uint32_t argc) {
		return static_cast<FREObject>(ManagedGlobals::controller->CallSharpFunction(
			name, FREContextCLR(context), argc, MarshalFREArray(argv, argc)));
	}

	void SetFREContext(FREContext freContext) {
		ManagedGlobals::controller->SetFreContext(FREContextCLR(freContext));
	}

	void InitController() {
		ManagedGlobals::controller = gcnew FreNamespace::MainController();
	}

	FreNamespace::MainController ^ GetController() {
		return ManagedGlobals::controller;
	}

}

extern "C" {

	array<FREObject>^ getArgvAsArray(FREObject argv[], const uint32_t argc) {
		auto arr = gcnew array<FREObject>(argc);
		for (uint32_t i = 0; i < argc; i++) {
			arr[i] = argv[i];
		}
		return arr;
	}

	FRE_FUNCTION(callSharpFunction) {
		auto fName = std::string(static_cast<const char*>(functionData));
		return FreSharpBridge::CallSharpFunction(gcnew System::String(fName.c_str()), context, getArgvAsArray(argv, argc), argc);
	}
}