#include "ANEHelper.h"
FREObject ANEHelper::getFREObject(string arg) {
	FREObject result;
	FRENewObjectFromUTF8(uint32_t(arg.length()), reinterpret_cast<const uint8_t*>(arg.data()), &result);
	return result;
}

FREObject ANEHelper::getFREObject(const char* arg) {
	FREObject result;
	FRENewObjectFromUTF8(uint32_t(strlen(arg)) + 1, reinterpret_cast<const uint8_t*>(arg), &result);
	return result;
}

FREObject ANEHelper::getFREObject(double arg) {
	FREObject result;
	FRENewObjectFromDouble(arg, &result);
	return result;
}

FREObject ANEHelper::getFREObject(bool arg) {
	FREObject result;
	FRENewObjectFromBool(arg, &result);
	return result;
}

FREObject ANEHelper::getFREObject(int32_t arg) {
	FREObject result;
	FRENewObjectFromInt32(arg, &result);
	return result;
}

FREObject ANEHelper::getFREObject(uint32_t arg) {
	FREObject result;
	FRENewObjectFromUint32(arg, &result);
	return result;
}

FREObject ANEHelper::getProperty(FREObject objAS, string propertyName) {
	FREObject result = nullptr;
	FREObject thrownException = nullptr;
	FREGetObjectProperty(objAS, reinterpret_cast<const uint8_t*>(propertyName.data()), &result, &thrownException);
	return result;
}

uint32_t ANEHelper::getUInt32(FREObject uintAS) {
	uint32_t result = 0;
	FREGetObjectAsUint32(uintAS, &result);
	return result;
}

int32_t ANEHelper::getInt32(FREObject intAS) {
	int32_t result = 0;
	FREGetObjectAsInt32(intAS, &result);
	return result;
}

double ANEHelper::getDouble(FREObject arg) {
	double result = 0.0;
	FREGetObjectAsDouble(arg, &result);
	return result;
}

bool ANEHelper::getBool(FREObject val) {
	uint32_t result = 0;
	bool ret = false;
	FREGetObjectAsBool(val, &result);
	if (result > 0) ret = true;
	return ret;
}

string ANEHelper::getString(FREObject arg) {
	uint32_t string1Length;
	const uint8_t *val;
	FREGetObjectAsUTF8(arg, &string1Length, &val);
	string s(val, val + string1Length);
	return s;
}

uint32_t ANEHelper::getArrayLength(FREObject arrayAS) {
	FREObject arrayLengthAS = getProperty(arrayAS, "length");
	return getUInt32(arrayLengthAS);
}