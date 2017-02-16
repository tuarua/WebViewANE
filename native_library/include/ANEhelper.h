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
#pragma once
#ifdef _WIN32
#include "FlashRuntimeExtensions.h"
#else

#include <Adobe AIR/Adobe AIR.h>

#endif

#include <vector>
#include <string>

class ANEHelper {
public:
	FREObject getFREObject(std::string value);
	FREObject getFREObject(const char *value);
	FREObject getFREObject(double value);
	FREObject getFREObject(bool value);
	FREObject getFREObject(int32_t value);
	FREObject getFREObject(int64_t value);
	FREObject getFREObject(uint32_t value);
	FREObject getFREObject(uint8_t value);
	FREObject getProperty(FREObject freObject, std::string propertyName);
	void setProperty(FREObject freObject, std::string name, FREObject value);
	void setProperty(FREObject freObject, std::string name, const char *value);
	void setProperty(FREObject freObject, std::string name, std::string value);
	void setProperty(FREObject freObject, std::string name, double value);
	void setProperty(FREObject freObject, std::string name, bool value);
	void setProperty(FREObject freObject, std::string name, int32_t value);
	void setProperty(FREObject freObject, std::string name, int64_t value);
	void setProperty(FREObject freObject, std::string name, uint32_t value);
	void setProperty(FREObject freObject, std::string name, uint8_t value);
	uint32_t getUInt32(FREObject freObject);
	int32_t getInt32(FREObject freObject);
	std::string getString(FREObject freObject);
	static bool getBool(FREObject freObject);
	double getDouble(FREObject freObject);
	uint32_t getArrayLength(FREObject freObject);
	std::vector<std::string> getStringVector(FREObject freObject, std::string propertyName);
	FREObject createFREObject(std::string className);
	static void dispatchEvent(FREContext ctx, std::string name, std::string value);
	void printObjectType(std::string tag, FREObject freObject);
	void trace(std::string message) const;
	void setFREContext(FREContext ctx);
	FREContext dllContext;
private:
	bool isFREResultOK(FREResult errorCode, std::string errorMessage);
	static std::string friendlyFREResult(FREResult errorCode);
	bool hasThrownException(FREObject thrownException) const;
};
