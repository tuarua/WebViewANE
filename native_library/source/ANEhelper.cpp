/*@copyright The code is licensed under the[MIT
License](http://opensource.org/licenses/MIT):

Copyright © 2015 - 2017 Tua Rua Ltd.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files(the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and / or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions :

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.*/
#include "ANEHelper.h"

FREObject ANEHelper::getFREObject(std::string value) {
	FREObject result;
	auto status = FRENewObjectFromUTF8(uint32_t(value.length()), reinterpret_cast<const uint8_t *>(value.data()), &result);
	isFREResultOK(status, "Could not convert string to FREObject.");
	return result;
}

FREObject ANEHelper::getFREObject(const char *value) {
	FREObject result;
	auto status = FRENewObjectFromUTF8(uint32_t(strlen(value)) + 1, reinterpret_cast<const uint8_t *>(value), &result);
	isFREResultOK(status, "Could not convert char to FREObject.");
	return result;
}

FREObject ANEHelper::getFREObject(double value) {
	FREObject result;
	auto status = FRENewObjectFromDouble(value, &result);
	isFREResultOK(status, "Could not convert double to FREObject.");
	return result;
}

FREObject ANEHelper::getFREObject(bool value) {
	FREObject result;
	auto status = FRENewObjectFromBool(value, &result);
	isFREResultOK(status, "Could not convert bool to FREObject.");
	return result;
}

FREObject ANEHelper::getFREObject(int32_t value) {
	FREObject result;
	auto status = FRENewObjectFromInt32(value, &result);
	isFREResultOK(status, "Could not convert int32_t to FREObject.");
	return result;
}

FREObject ANEHelper::getFREObject(int64_t value) {
	FREObject result;
	auto status = FRENewObjectFromInt32(static_cast<int32_t>(value), &result);
	isFREResultOK(status, "Could not convert int64_t to FREObject.");
	return result;
}

FREObject ANEHelper::getFREObject(uint32_t value) {
	FREObject result;
	auto status = FRENewObjectFromUint32(value, &result);
	isFREResultOK(status, "Could not convert uint32_t to FREObject.");
	return result;
}

FREObject ANEHelper::getFREObject(uint8_t value) {
	FREObject result;
	auto status = FRENewObjectFromUint32(value, &result);
	isFREResultOK(status, "Could not convert uint8_t to FREObject.");
	return result;
}

FREObject ANEHelper::getProperty(FREObject freObject, std::string propertyName) {
	FREObject result = nullptr;
	FREObject thrownException = nullptr;
	auto status = FREGetObjectProperty(freObject, reinterpret_cast<const uint8_t *>(propertyName.data()), &result, &thrownException);
	isFREResultOK(status, "Could not get FREObject property.");
	if (FRE_OK != status)
		hasThrownException(thrownException);
	return result;
}

void ANEHelper::setProperty(FREObject freObject, std::string name, FREObject value) {
	FREObject thrownException = nullptr;
	auto status = FRESetObjectProperty(freObject, reinterpret_cast<const uint8_t *>(name.c_str()), value, &thrownException);
	isFREResultOK(status, "Could not set FREObject property.");
	if (FRE_OK != status)
		hasThrownException(thrownException);
}

void ANEHelper::setProperty(FREObject freObject, std::string name, const char* value) {
	FREObject thrownException = nullptr;
	auto status = FRESetObjectProperty(freObject, reinterpret_cast<const uint8_t *>(name.c_str()), getFREObject(value), nullptr);
	isFREResultOK(status, "Could not set FREObject property.");
	if (FRE_OK != status)
		hasThrownException(thrownException);
}

void ANEHelper::setProperty(FREObject freObject, std::string name, std::string value) {
	FREObject thrownException = nullptr;
	auto status = FRESetObjectProperty(freObject, reinterpret_cast<const uint8_t *>(name.c_str()), getFREObject(value), nullptr);
	isFREResultOK(status, "Could not set FREObject property.");
	if (FRE_OK != status)
		hasThrownException(thrownException);
}

void ANEHelper::setProperty(FREObject freObject, std::string name, double value) {
	FREObject thrownException = nullptr;
	auto status = FRESetObjectProperty(freObject, reinterpret_cast<const uint8_t *>(name.c_str()), getFREObject(value), nullptr);
	isFREResultOK(status, "Could not set FREObject property.");
	if (FRE_OK != status)
		hasThrownException(thrownException);
}

void ANEHelper::setProperty(FREObject freObject, std::string name, bool value) {
	FREObject thrownException = nullptr;
	auto status = FRESetObjectProperty(freObject, reinterpret_cast<const uint8_t *>(name.c_str()), getFREObject(value), nullptr);
	isFREResultOK(status, "Could not set FREObject property.");
	if (FRE_OK != status)
		hasThrownException(thrownException);
}

void ANEHelper::setProperty(FREObject freObject, std::string name, int32_t value) {
	FREObject thrownException = nullptr;
	auto status = FRESetObjectProperty(freObject, reinterpret_cast<const uint8_t *>(name.c_str()), getFREObject(value), nullptr);
	isFREResultOK(status, "Could not set FREObject property.");
	if (FRE_OK != status)
		hasThrownException(thrownException);
}

void ANEHelper::setProperty(FREObject freObject, std::string name, int64_t value) {
	FREObject thrownException = nullptr;
	auto status = FRESetObjectProperty(freObject, reinterpret_cast<const uint8_t *>(name.c_str()), getFREObject(value), nullptr);
	isFREResultOK(status, "Could not set FREObject property.");
	if (FRE_OK != status)
		hasThrownException(thrownException);
}

void ANEHelper::setProperty(FREObject freObject, std::string name, uint32_t value) {
	FREObject thrownException = nullptr;
	auto status = FRESetObjectProperty(freObject, reinterpret_cast<const uint8_t *>(name.c_str()), getFREObject(value), nullptr);
	isFREResultOK(status, "Could not set FREObject property.");
	if (FRE_OK != status)
		hasThrownException(thrownException);
}

void ANEHelper::setProperty(FREObject freObject, std::string name, uint8_t value) {
	FREObject thrownException = nullptr;
	auto status = FRESetObjectProperty(freObject, reinterpret_cast<const uint8_t *>(name.c_str()), getFREObject(value), nullptr);
	isFREResultOK(status, "Could not set FREObject property.");
	if (FRE_OK != status)
		hasThrownException(thrownException);
}

uint32_t ANEHelper::getUInt32(FREObject freObject) {
	uint32_t result = 0;
	auto status = FREGetObjectAsUint32(freObject, &result);
	isFREResultOK(status, "Could not convert FREObject to uint32_t.");
	return result;
}

int32_t ANEHelper::getInt32(FREObject freObject) {
	int32_t result = 0;
	auto status = FREGetObjectAsInt32(freObject, &result);
	isFREResultOK(status, "Could not convert FREObject to int32_t.");
	return result;
}

double ANEHelper::getDouble(FREObject freObject) {
	auto result = 0.0;
	auto status = FREGetObjectAsDouble(freObject, &result);
	isFREResultOK(status, "Could not convert FREObject to double.");
	return result;
}

bool ANEHelper::getBool(FREObject freObject) {
	uint32_t result = 0;
	auto ret = false;
	FREGetObjectAsBool(freObject, &result);
	if (result > 0) ret = true;
	return ret;
}

std::string ANEHelper::getString(FREObject freObject) {
	uint32_t string1Length;
	const uint8_t *val;
	auto status = FREGetObjectAsUTF8(freObject, &string1Length, &val);

	if (isFREResultOK(status, "Could not convert UTF8."))
		return std::string(val, val + string1Length);
	return "";
}

uint32_t ANEHelper::getArrayLength(FREObject freObject) {
	auto arrayLengthAS = getProperty(freObject, "length");
	return getUInt32(arrayLengthAS);
}

std::vector<std::string> ANEHelper::getStringVector(FREObject freObject, std::string propertyName) {
	auto numItems = getArrayLength(freObject);
	std::vector<std::string> ret;
	for (unsigned int k = 0; k < numItems; ++k) {
		FREObject elemAS = nullptr;
		FREGetArrayElementAt(freObject, k, &elemAS);
		std::string elem;
		if (propertyName.empty())
			elem = getString(elemAS);
		else
			elem = getString(getProperty(elemAS, propertyName));
		ret.push_back(elem);
	}

	return ret;
}

FREObject ANEHelper::createFREObject(std::string className) {
	FREObject ret;
	FREObject thrownException = nullptr;
	auto status = FRENewObject(reinterpret_cast<const uint8_t *>(className.data()), 0, nullptr, &ret, nullptr);
	isFREResultOK(status, "Could not create FREObject.");
	if (FRE_OK != status)
		hasThrownException(thrownException);
	return ret;
}

void ANEHelper::dispatchEvent(FREContext ctx, std::string name, std::string value) {
	FREDispatchStatusEventAsync(ctx, reinterpret_cast<const uint8_t *>(value.data()), reinterpret_cast<const uint8_t *>(name.data()));
}

void ANEHelper::printObjectType(std::string tag, FREObject freObject) {
	auto objectType = FRE_TYPE_NULL;
	FREGetObjectType(freObject, &objectType);

	switch (objectType) {
	case FRE_TYPE_ARRAY:
		trace(tag + " printObjectType: FRE_TYPE_ARRAY");
		break;
	case FRE_TYPE_VECTOR:
		trace(tag + " printObjectType: FRE_TYPE_VECTOR");
		break;
	case FRE_TYPE_STRING:
		trace(tag + " printObjectType: FRE_TYPE_STRING");
		break;
	case FRE_TYPE_BOOLEAN:
		trace(tag + " printObjectType: FRE_TYPE_BOOLEAN");
		break;
	case FRE_TYPE_OBJECT:
		trace(tag + " printObjectType: FRE_TYPE_OBJECT");
		break;
	case FRE_TYPE_NUMBER:
		trace(tag + " printObjectType: FRE_TYPE_NUMBER");
		break;
	case FRE_TYPE_NULL:
		trace(tag + " printObjectType: FRE_TYPE_NULL");
		break;
	default:
		break;
	}
}

void ANEHelper::setFREContext(FREContext ctx) {
	dllContext = ctx;
}

void ANEHelper::trace(std::string message) const {
	dispatchEvent(dllContext, "TRACE", message);
}

bool ANEHelper::isFREResultOK(FREResult errorCode, std::string errorMessage) {
	if (FRE_OK == errorCode) return true;
	auto messageToReport = errorMessage + " " + friendlyFREResult(errorCode);
	trace(messageToReport);
	return false;
}

std::string ANEHelper::friendlyFREResult(FREResult errorCode) {
	switch (errorCode) {
	case FRE_OK:
		return "FRE_OK";
	case FRE_NO_SUCH_NAME:
		return "FRE_NO_SUCH_NAME";
	case FRE_INVALID_OBJECT:
		return "FRE_INVALID_OBJECT";
	case FRE_TYPE_MISMATCH:
		return "FRE_TYPE_MISMATCH";
	case FRE_ACTIONSCRIPT_ERROR:
		return "FRE_ACTIONSCRIPT_ERROR";
	case FRE_INVALID_ARGUMENT:
		return "FRE_INVALID_ARGUMENT";
	case FRE_READ_ONLY:
		return "FRE_READ_ONLY";
	case FRE_WRONG_THREAD:
		return "FRE_WRONG_THREAD";
	case FRE_ILLEGAL_STATE:
		return "FRE_ILLEGAL_STATE";
	case FRE_INSUFFICIENT_MEMORY:
		return "FRE_INSUFFICIENT_MEMORY";
	default:
		return "";
	}
}

bool ANEHelper::hasThrownException(FREObject thrownException) const {
	if (thrownException == nullptr) return false;

	FREObjectType objectType;
	if (FRE_OK != FREGetObjectType(thrownException, &objectType)) {
		trace("Exception was thrown, but failed to obtain information about it");
		return true;
	}

	if (FRE_TYPE_OBJECT == objectType) {
		FREObject exceptionTextAS;
		FREObject newException;
		if (FRE_OK != FRECallObjectMethod(thrownException, reinterpret_cast<const uint8_t *>("toString"), 0, nullptr, &exceptionTextAS, &newException)) {
			trace("Exception was thrown, but failed to obtain information about it");
			return true;
		}
		return true;
	}

	return false;
}

