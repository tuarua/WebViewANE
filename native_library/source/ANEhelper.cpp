#ifdef _WIN32
#include "FlashRuntimeExtensions.h"
#include <windows.h>
#include <conio.h>
#else
#include <Adobe AIR/Adobe AIR.h>
#include <stdlib.h>
#include <stdio.h>
#endif
#include "../include/ANEhelper.h"
#include <string>
#include <vector>

FREObject getFREObjectProperty(FREObject objAS, const uint8_t * propertyName) {
	FREObject result = NULL;
	FREObject thrownException = NULL;
	FREGetObjectProperty(objAS, propertyName, &result, &thrownException);
	return result;
}

FREObject getFREObjectFromString(std::string arg) {
	FREObject result;
	FRENewObjectFromUTF8((uint32_t)arg.length(), reinterpret_cast<const uint8_t*>(arg.data()), &result);
	return result;
}
FREObject getFREObjectFromString(const char* arg) {
	FREObject result;
	FRENewObjectFromUTF8(uint32_t(strlen(arg)) + 1, (const uint8_t*)arg, &result);
	return result;
}
FREObject getFREObjectFromInt32(int32_t arg) {
	FREObject result;
	FRENewObjectFromInt32(arg, &result);
	return result;
}
FREObject getFREObjectFromUint32(uint32_t arg) {
	FREObject result;
	FRENewObjectFromUint32(arg, &result);
	return result;
}
FREObject getFREObjectFromDouble(double arg) {
	FREObject result;
	FRENewObjectFromDouble(arg, &result);
	return result;
}

FREObject getFREObjectFromBool(bool arg) {
	FREObject result;
	FRENewObjectFromBool(arg, &result);
	return result;
}
uint32_t getUInt32FromFREObject(FREObject uintAS) {
	uint32_t result = 0;
	FREGetObjectAsUint32(uintAS, &result);
	return result;
}

bool getBoolFromFREObject(FREObject val) {
	uint32_t result = 0;
	bool ret = false;
	FREGetObjectAsBool(val, &result);
	if (result > 0) ret = true;
	return ret;
}
double getDoubleFromFREObject(FREObject arg) {
	double result = 0.0;
	FREGetObjectAsDouble(arg, &result);
	return result;
}
int32_t getInt32FromFREObject(FREObject intAS) {
	int32_t result = 0;
	FREGetObjectAsInt32(intAS, &result);
	return result;
}
uint32_t getFREObjectArrayLength(FREObject arrayAS) {
	FREObject arrayLengthAS = getFREObjectProperty(arrayAS, (const uint8_t *) "length");
	return getUInt32FromFREObject(arrayLengthAS);
}
std::string getStringFromFREObject(FREObject arg) {
	uint32_t string1Length;
	const uint8_t *val;
	FREGetObjectAsUTF8(arg, &string1Length, &val);
	std::string s(val, val + string1Length);
	return s;
}
std::vector<std::string> getStringVectorFromFREObject(FREObject arg, const uint8_t * propertyName) {
	uint32_t numItems = getFREObjectArrayLength(arg);
	std::vector<std::string> ret;
	for (unsigned int k = 0; k < numItems; ++k) {
		FREObject elemAS = NULL;
		FREGetArrayElementAt(arg, k, &elemAS);
		std::string elem;
		if(propertyName == NULL)
			elem = getStringFromFREObject(elemAS);
		else
			elem = getStringFromFREObject(getFREObjectProperty(elemAS, propertyName));
		ret.push_back(elem);
	}
	return ret;
}

std::vector<int> getIntVectorFromFREObject(FREObject arg, const uint8_t * propertyName) {
	uint32_t numItems = getFREObjectArrayLength(arg);
	std::vector<int> ret;
	for (unsigned int k = 0; k < numItems; ++k) {
		FREObject elemAS = NULL;
		FREGetArrayElementAt(arg, k, &elemAS);
		int elem;
		if (propertyName == NULL)
			elem = getInt32FromFREObject(elemAS);
		else
			elem = getInt32FromFREObject(getFREObjectProperty(elemAS, propertyName));
		ret.push_back(elem);
	}
	return ret;
}

FREObject getReturnTrue() {
	return getFREObjectFromBool(true);
}