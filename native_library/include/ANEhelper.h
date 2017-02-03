#pragma once
#ifdef _WIN32
#include "FlashRuntimeExtensions.h"
#else
#include <Adobe AIR/Adobe AIR.h>
#endif
#include <vector>
using namespace std;
class ANEHelper {
public:
	static FREObject getFREObject(string arg);
	static FREObject getFREObject(const char* arg);
	static FREObject getFREObject(double arg);
	static FREObject getFREObject(bool arg);
	static FREObject getFREObject(int32_t arg);
	static FREObject getFREObject(uint32_t arg);
	static FREObject getProperty(FREObject objAS, string propertyName);
	static uint32_t getUInt32(FREObject uintAS);
	static int32_t getInt32(FREObject intAS);
	static string getString(FREObject arg);
	static bool getBool(FREObject val);
	static double getDouble(FREObject arg);
	static uint32_t getArrayLength(FREObject arrayAS);
};
