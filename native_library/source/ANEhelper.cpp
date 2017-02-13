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

FREObject ANEHelper::getFREObject(std::string arg) {
	FREObject result;
	FRENewObjectFromUTF8(uint32_t(arg.length()), reinterpret_cast<const uint8_t *>(arg.data()), &result);
	return result;
}

FREObject ANEHelper::getFREObject(const char *arg) {
	FREObject result;
	FRENewObjectFromUTF8(uint32_t(strlen(arg)) + 1, reinterpret_cast<const uint8_t *>(arg), &result);
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

FREObject ANEHelper::getFREObject(int64_t arg) {
	FREObject result;
	FRENewObjectFromInt32(static_cast<int32_t>(arg), &result);
	return result;
}

FREObject ANEHelper::getFREObject(uint32_t arg) {
	FREObject result;
	FRENewObjectFromUint32(arg, &result);
	return result;
}

FREObject ANEHelper::getFREObject(uint8_t arg) {
	FREObject result;
	FRENewObjectFromUint32(arg, &result);
	return result;
}

FREObject ANEHelper::getProperty(FREObject objAS, std::string propertyName) {
	FREObject result = nullptr;
	FREObject thrownException = nullptr;
	FREGetObjectProperty(objAS, reinterpret_cast<const uint8_t *>(propertyName.data()), &result, &thrownException);
	return result;
}

void ANEHelper::setProperty(FREObject objAS, std::string name, FREObject value) {
	FRESetObjectProperty(objAS, reinterpret_cast<const uint8_t *>(name.c_str()), value, nullptr);
}

uint32_t ANEHelper::getUInt32(FREObject uintAS) {
	uint32_t result = 0;
	FREGetObjectAsUint32(uintAS, &result);
	return result;
}

int32_t ANEHelper::getInt32(FREObject intAS) {
	auto result = 0;
	FREGetObjectAsInt32(intAS, &result);
	return result;
}

double ANEHelper::getDouble(FREObject arg) {
	auto result = 0.0;
	FREGetObjectAsDouble(arg, &result);
	return result;
}

bool ANEHelper::getBool(FREObject val) {
	uint32_t result = 0;
	auto ret = false;
	FREGetObjectAsBool(val, &result);
	if (result > 0) ret = true;
	return ret;
}

std::string ANEHelper::getString(FREObject arg) {
	uint32_t string1Length;
	const uint8_t *val;
	FREGetObjectAsUTF8(arg, &string1Length, &val);
	std::string s(val, val + string1Length);
	return s;
}

uint32_t ANEHelper::getArrayLength(FREObject arrayAS) {
	auto arrayLengthAS = getProperty(arrayAS, "length");
	return getUInt32(arrayLengthAS);
}

std::vector<std::string> ANEHelper::getStringVector(FREObject arg, std::string propertyName) {
	auto numItems = getArrayLength(arg);
	std::vector<std::string> ret;
	for (unsigned int k = 0; k < numItems; ++k) {
		FREObject elemAS = nullptr;
		FREGetArrayElementAt(arg, k, &elemAS);
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
	FRENewObject(reinterpret_cast<const uint8_t *>(className.data()), 0, nullptr, &ret, nullptr);
	return ret;
}

void ANEHelper::dispatchEvent(FREContext ctx, std::string name, std::string value) {
	FREDispatchStatusEventAsync(ctx, reinterpret_cast<const uint8_t *>(value.data()), reinterpret_cast<const uint8_t *>(name.data()));
}

