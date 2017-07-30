#include "FreSharpBridge.h"
namespace FreSharpBridge {

	void MarshalString(String ^ s, std::string& os) {
		using namespace Runtime::InteropServices;
		const char* chars =
			(const char*)(Marshal::StringToHGlobalAnsi(s)).ToPointer();
		os = chars;
		Marshal::FreeHGlobal(FREObjectCLR((void*)chars));
	}

	array<FREObjectCLR>^ MarshalFREArray(array<FREObject>^ argv, uint32_t argc) {
		array<FREObjectCLR>^ arr = gcnew array<FREObjectCLR>(argc);
		for (uint32_t i = 0; i < argc; i++) {
			arr[i] = FREObjectCLR(argv[i]);
		}
		return arr;
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

	FREObject CallSharpFunction(String^ name, FREContext context, array<FREObject>^ argv, uint32_t argc) {
		return (FREObject)ManagedGlobals::controller->CallSharpFunction(name, FREContextCLR(context), argc, MarshalFREArray(argv, argc));
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

	array<FREObject>^ getArgvAsArray(FREObject argv[], uint32_t argc) {
		array<FREObject>^ arr = gcnew array<FREObject>(argc);
		for (uint32_t i = 0; i < argc; i++) {
			arr[i] = argv[i];
		}
		return arr;
	}

	FRE_FUNCTION(callSharpFunction) {
		std::string fName = std::string((const char*)functionData);
		return FreSharpBridge::CallSharpFunction(gcnew System::String(fName.c_str()), context, getArgvAsArray(argv, argc), argc);
	}
}