/*@copyright The code is licensed under the[MIT
 License](http://opensource.org/licenses/MIT):
 
 Copyright © 2017 -  Tua Rua Ltd.
 
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

import Foundation

var context: FREContext!

func trace(_ value: Any...) {
    var traceStr: String = ""
    for i in 0 ..< value.count {
        traceStr = traceStr + "\(value[i])" + " "
    }
    do {
        try context.dispatchStatusEventAsync(code: traceStr, level: "TRACE")
    } catch {
    }
}

fileprivate enum FREObjectType2: UInt32 {
    case FRE_TYPE_OBJECT = 0
    case FRE_TYPE_NUMBER = 1
    case FRE_TYPE_STRING = 2
    case FRE_TYPE_BYTEARRAY = 3
    case FRE_TYPE_ARRAY = 4
    case FRE_TYPE_VECTOR = 5
    case FRE_TYPE_BITMAPDATA = 6
    case FRE_TYPE_BOOLEAN = 7
    case FRE_TYPE_NULL = 8
    case FRE_TYPE_INT = 9
    case FRE_TYPE_CUSTOM = 10
}

struct FREError: Error {
    
    enum Code {
        case ok
        case noSuchName
        case invalidObject
        case typeMismatch
        case actionscriptError
        case invalidArgument
        case readOnly
        case wrongThread
        case illegalState
        case insufficientMemory
    }
    
    func printStackTrace(_ oFile: String, _ oLine: Int, _ oColumn: Int) {
        trace("_______________")
        trace("*****ERROR*****")
        trace("message:", message)
        trace("code:", code)
        trace("exception:", exception)
        trace("at: [\(file):\(line):\(column)]")
        trace("originator: [\(oFile):\(oLine):\(oColumn)]")
        trace("***************")
    }
    
    let exception: String
    let message: String
    let code: Code
    let line: Int
    let column: Int
    let file: String
}


fileprivate func getActionscriptClassType(object: FREObject) -> FREObjectType2 {
    if let aneUtils: FREObject? = try? FREObject.newObject(className: "com.tuarua.ANEUtils", args: nil) {
        let params: NSPointerArray = NSPointerArray(options: .opaqueMemory)
        params.addPointer(object)
        if let classType: FREObject? = try? aneUtils?.callMethod(methodName: "getClassType", args: params) {
            let type: String? = try! classType?.getAsString().lowercased()
            if type == "int" {
                return FREObjectType2.FRE_TYPE_INT
            } else if type == "string" {
                return FREObjectType2.FRE_TYPE_STRING
            } else if type == "number" {
                return FREObjectType2.FRE_TYPE_NUMBER
            } else if type == "boolean" {
                return FREObjectType2.FRE_TYPE_BOOLEAN
            } else {
                return FREObjectType2.FRE_TYPE_CUSTOM
            }
        }
    }
    
    return FREObjectType2.FRE_TYPE_NULL
}

extension FREContext {
    
    func dispatchStatusEventAsync(code: String, level: String) throws {
        #if os(iOS)
            let status: FREResult = FRESwiftBridge.bridge.FREDispatchStatusEventAsync(ctx: self, code: code, level: level)
        #else
            let status: FREResult = FREDispatchStatusEventAsync(self, code, level)
        #endif
        guard FRE_OK == status else {
            throw FREError(exception: "", message: "cannot dispatch event \(code):\(level)",
                code: FREObject.getErrorCode(status), line: #line, column: #column, file: #file)
        }
    }
    
    func getActionScriptData() throws -> FREObject? {
        var ret: FREObject?
        #if os(iOS)
            let status: FREResult = FRESwiftBridge.bridge.FREGetContextActionScriptData(ctx: self, actionScriptData: &ret)
        #else
            let status: FREResult = FREGetContextActionScriptData(self, &ret)
        #endif
        guard FRE_OK == status else {
            throw FREError(exception: "", message: "cannot get actionscript data", code: FREObject.getErrorCode(status),
                           line: #line, column: #column, file: #file)
        }
        return ret
    }
    
    
    func setActionScriptData(object: FREObject) throws {
        #if os(iOS)
            let status: FREResult = FRESwiftBridge.bridge.FRESetContextActionScriptData(ctx: self, actionScriptData: object)
        #else
            let status: FREResult = FRESetContextActionScriptData(self, object)
        #endif
        guard FRE_OK == status else {
            throw FREError(exception: "", message: "cannot set actionscript data", code: FREObject.getErrorCode(status),
                           line: #line, column: #column, file: #file)
        }
        
    }
}


extension FREObject {
    
    func release() {
        #if os(iOS)
            if FRE_TYPE_BITMAPDATA == self.getType() {
                _ = FRESwiftBridge.bridge.FREReleaseBitmapData(object: self)
            } else if FRE_TYPE_BYTEARRAY == self.getType() {
                _ = FRESwiftBridge.bridge.FREReleaseByteArray(object: self)
            }
        #else
            if FRE_TYPE_BITMAPDATA == self.getType() {
                FREReleaseBitmapData(self)
            } else if FRE_TYPE_BYTEARRAY == self.getType() {
                FREReleaseByteArray(self)
            }
        #endif
    }
    
    func acquire(descriptorToSet: inout FREBitmapData2) throws {
        #if os(iOS)
            let status: FREResult = FRESwiftBridge.bridge.FREAcquireBitmapData2(object: self, descriptorToSet: &descriptorToSet)
        #else
            let status: FREResult = FREAcquireBitmapData2(self, &descriptorToSet)
        #endif
        guard FRE_OK == status else {
            throw FREError(exception: "", message: "cannot acquire BitmapData", code: FREObject.getErrorCode(status),
                           line: #line, column: #column, file: #file)
        }
    }
    
    func acquire(byteArrayToSet: inout FREByteArray) throws {
        #if os(iOS)
            let status: FREResult = FRESwiftBridge.bridge.FREAcquireByteArray(object: self, byteArrayToSet: &byteArrayToSet)
        #else
            let status: FREResult = FREAcquireByteArray(self, &byteArrayToSet)
        #endif
        guard FRE_OK == status else {
            throw FREError(exception: "", message: "cannot acquire ByteArray", code: FREObject.getErrorCode(status),
                           line: #line, column: #column, file: #file)
        }
    }
    
    func getAsInt() throws -> Int {
        return try _getAsInt(self)
    }
    
    func getAsUInt() throws -> UInt {
        return try _getAsUInt(self)
    }
    
    func getAsDouble() throws -> Double {
        return try _getAsDouble(self)
    }
    
    func getAsCGFloat() throws -> CGFloat {
        return try CGFloat(_getAsDouble(self))
    }
    
    
    func getAsCGPoint() throws -> CGPoint {
        var ret: CGPoint = CGPoint.init(x: 0, y: 0)
        if let xFRE: FREObject = try self.getProperty(name: "x"), let yFRE: FREObject = try self.getProperty(name: "y") {
            let x = try xFRE.getAsInt()
            let y = try yFRE.getAsInt()
            ret = CGPoint.init(x: x, y: y)
        }
        return ret
    }
    
    func getAsString() throws -> String {
        return try _getAsString(self)
    }
    
    func getAsBool() throws -> Bool {
        return try _getAsBool(self)
    }
    
    func getType() -> FREObjectType {
        var objectType: FREObjectType = FRE_TYPE_NULL
        #if os(iOS)
            _ = FRESwiftBridge.bridge.FREGetObjectType(object: self, objectType: &objectType)
        #else
            FREGetObjectType(self, &objectType)
        #endif
        return objectType
    }
    
    func getTypeAsString() -> String {
        let objectType: FREObjectType = self.getType()
        switch objectType {
        case FRE_TYPE_ARRAY:
            return "FRE_TYPE_ARRAY"
        case FRE_TYPE_VECTOR:
            return "FRE_TYPE_VECTOR"
        case FRE_TYPE_STRING:
            return "FRE_TYPE_STRING"
        case FRE_TYPE_BOOLEAN:
            return "FRE_TYPE_BOOLEAN"
        case FRE_TYPE_OBJECT:
            return "FRE_TYPE_OBJECT"
        case FRE_TYPE_NUMBER:
            switch getActionscriptClassType(object: self) {
            case FREObjectType2.FRE_TYPE_NUMBER:
                return "FRE_TYPE_NUMBER"
            case FREObjectType2.FRE_TYPE_INT:
                return "FRE_TYPE_INT"
            case FREObjectType2.FRE_TYPE_BOOLEAN:
                return "FRE_TYPE_BOOLEAN"
            default:
                return "FRE_TYPE_NUMBER"
            }
        case FRE_TYPE_NULL:
            return "FRE_TYPE_NULL"
        case FRE_TYPE_BITMAPDATA:
            return "FRE_TYPE_BITMAPDATA"
        case FRE_TYPE_BYTEARRAY:
            return "FRE_TYPE_BYTEARRAY"
        default:
            return "UNKNOWN"
        }
        
    }
    
    func getAsId() throws -> Any? {
        let objectType: FREObjectType = self.getType()
        
        switch objectType {
        case FRE_TYPE_VECTOR, FRE_TYPE_ARRAY:
            return try self.getAsArray()
        case FRE_TYPE_STRING:
            return try self.getAsString()
        case FRE_TYPE_BOOLEAN:
            return try self.getAsBool()
        case FRE_TYPE_OBJECT:
            return try self.getAsDictionary()
        case FRE_TYPE_NUMBER:
            switch getActionscriptClassType(object: self) {
            case FREObjectType2.FRE_TYPE_NUMBER:
                return try self.getAsDouble()
            case FREObjectType2.FRE_TYPE_INT:
                return try self.getAsInt()
            case FREObjectType2.FRE_TYPE_BOOLEAN:
                return try self.getAsBool()
            default:
                return try self.getAsDouble()
            }
        case FRE_TYPE_BITMAPDATA:
            return try self.getAsImage()
        case FRE_TYPE_BYTEARRAY:
            return try self.getAsData()
        case FRE_TYPE_NULL:
            return nil
        default:
            break
        }
        return nil
    }
    
    func getAsImage() throws -> CGImage? {
        var bitmapData: FREBitmapData = FREBitmapData.init()
        try self.acquire(descriptorToSet: &bitmapData)
        
        let width: Int = Int(bitmapData.width);
        let height: Int = Int(bitmapData.height);
        let releaseProvider: CGDataProviderReleaseDataCallback = { (info: UnsafeMutableRawPointer?,
            data: UnsafeRawPointer, size: Int) -> () in
            // https://developer.apple.com/reference/coregraphics/cgdataproviderreleasedatacallback
            // N.B. 'CGDataProviderRelease' is unavailable: Core Foundation objects are automatically memory managed
            return
        }
        let provider: CGDataProvider = CGDataProvider(dataInfo: nil, data: bitmapData.getBits(), size: (width * height * 4),
                                                      releaseData: releaseProvider)!
        
        let bitsPerComponent = 8;
        let bitsPerPixel = 32;
        let bytesPerRow: Int = 4 * width;
        let colorSpaceRef: CGColorSpace = CGColorSpaceCreateDeviceRGB();
        var bitmapInfo: CGBitmapInfo
        
        if bitmapData.hasAlpha() {
            if bitmapData.isPremultiplied() {
                bitmapInfo = CGBitmapInfo.init(rawValue: CGBitmapInfo.byteOrder32Little.rawValue |
                    CGImageAlphaInfo.premultipliedFirst.rawValue)
                
            } else {
                bitmapInfo = CGBitmapInfo.init(rawValue: CGBitmapInfo.byteOrder32Little.rawValue |
                    CGImageAlphaInfo.first.rawValue)
            }
        } else {
            bitmapInfo = CGBitmapInfo.init(rawValue: CGBitmapInfo.byteOrder32Little.rawValue |
                CGImageAlphaInfo.noneSkipFirst.rawValue)
        }
        
        let renderingIntent: CGColorRenderingIntent = CGColorRenderingIntent.defaultIntent;
        let imageRef: CGImage = CGImage(width: width, height: height, bitsPerComponent: bitsPerComponent,
                                        bitsPerPixel: bitsPerPixel, bytesPerRow: bytesPerRow, space: colorSpaceRef,
                                        bitmapInfo: bitmapInfo, provider: provider, decode: nil, shouldInterpolate: false,
                                        intent: renderingIntent)!;
        
        return imageRef
        
    }
    
    func getAsData() throws -> NSData {
        var ret: FREByteArray = FREByteArray.newByteArray()
        try self.acquire(byteArrayToSet: &ret)
        return NSData.init(bytes: ret.getBytes(), length: Int(ret.getLength()))
    }
    
    func getAsDictionary() throws -> Dictionary<String, AnyObject> {
        var ret: Dictionary = Dictionary<String, AnyObject>()
        if let aneUtils: FREObject? = try? FREObject.newObject(className: "com.tuarua.ANEUtils", args: nil) {
            let paramsArray: NSPointerArray = NSPointerArray(options: .opaqueMemory)
            paramsArray.addPointer(self)
            
            let classProps: FREObject? = try aneUtils?.callMethod(methodName: "getClassProps", args: paramsArray)
            
            if let arrayLength: UInt = try classProps?.getLength() {
                for i in 0 ..< arrayLength {
                    if let elem: FREObject = try classProps?.getObjectAt(index: i) {
                        if let propNameAs: FREObject = try elem.getProperty(name: "name") {
                            let propName: String = try propNameAs.getAsString()
                            //let propTypeAs = try self.getProperty(name: "type")
                            if let propVal = try self.getProperty(name: propName) {
                                if let propvalId = try propVal.getAsId() {
                                    ret.updateValue(propvalId as AnyObject, forKey: propName)
                                }
                            }
                            
                        }
                    }
                }
            }
            
        }
        return ret
    }
    
    fileprivate static func getActionscriptException(_ thrownException: FREObject?) -> String {
        if let thrownException = thrownException {
            if FRE_TYPE_OBJECT == thrownException.getType() {
                do {
                    if let exceptionTextAS: FREObject = try thrownException.callMethod(methodName: "toString", args: nil) {
                        let ret: String = try exceptionTextAS.getAsString()
                        return ret
                    }
                } catch {
                }
            }
        }
        return ""
    }
    
    fileprivate static func getErrorCode(_ result: FREResult) -> FREError.Code {
        switch result {
        case FRE_NO_SUCH_NAME:
            return .noSuchName
        case FRE_INVALID_OBJECT:
            return .invalidObject
        case FRE_TYPE_MISMATCH:
            return .typeMismatch
        case FRE_ACTIONSCRIPT_ERROR:
            return .actionscriptError
        case FRE_INVALID_ARGUMENT:
            return .invalidArgument
        case FRE_READ_ONLY:
            return .readOnly
        case FRE_WRONG_THREAD:
            return .wrongThread
        case FRE_ILLEGAL_STATE:
            return .illegalState
        case FRE_INSUFFICIENT_MEMORY:
            return .insufficientMemory
        default:
            return .ok
        }
    }
    
    func getProperty(name: String) throws -> FREObject? {
        var ret: FREObject?
        var thrownException: FREObject?
        
        #if os(iOS)
            let status: FREResult = FRESwiftBridge.bridge.FREGetObjectProperty(object: self,
                                                                               propertyName: name,
                                                                               propertyValue: &ret,
                                                                               thrownException: &thrownException)
        #else
            let status: FREResult = FREGetObjectProperty(self, name, &ret, &thrownException)
        #endif
        
        guard FRE_OK == status else {
            throw FREError(exception: FREObject.getActionscriptException(thrownException),
                           message: "cannot get property \"\(name)\"", code: FREObject.getErrorCode(status),
                           line: #line, column: #column, file: #file)
        }
        return ret
    }
    
    func setProperty(name: String, prop: FREObject?) throws {
        var thrownException: FREObject?
        #if os(iOS)
            let status: FREResult = FRESwiftBridge.bridge.FRESetObjectProperty(object: self,
                                                                               propertyName: name,
                                                                               propertyValue: prop,
                                                                               thrownException: &thrownException)
        #else
            let status: FREResult = FRESetObjectProperty(self, name, prop, &thrownException)
        #endif
        guard FRE_OK == status else {
            throw FREError(exception: FREObject.getActionscriptException(thrownException),
                           message: "cannot set property \"\(name)\"", code: FREObject.getErrorCode(status),
                           line: #line, column: #column, file: #file)
        }
    }
    
    
    static func toArray(args: Any...) throws -> NSPointerArray {
        let argsArray: NSPointerArray = NSPointerArray(options: .opaqueMemory)
        for i in 0 ..< args.count {
            let arg: FREObject? = try self._newObject(any: args[i]) //TODO don't add nil ?
            argsArray.addPointer(arg)
        }
        return argsArray
    }
    
    
    func callMethod(methodName: String, args: NSPointerArray?) throws -> FREObject? {
        var ret: FREObject?
        var thrownException: FREObject?
        var numArgs: UInt32 = 0
        if args != nil {
            numArgs = UInt32((args?.count)!)
        }
        #if os(iOS)
            let status: FREResult = FRESwiftBridge.bridge.FRECallObjectMethod(object: self, methodName: methodName,
                                                                              argc: numArgs, argv: args,
                                                                              result: &ret, thrownException: &thrownException)
        #else
            let status: FREResult = FRECallObjectMethod(self, methodName, numArgs, arrayToFREArray(args), &ret, &thrownException)
        #endif
        guard FRE_OK == status else {
            throw FREError(exception: FREObject.getActionscriptException(thrownException),
                           message: "cannot call method \"\(methodName)\"", code: FREObject.getErrorCode(status),
                           line: #line, column: #column, file: #file)
        }
        
        
        return ret
    }
    
    
    static func newObject(string: String) throws -> FREObject? {
        return try self._newObject(string)
    }
    
    static func newObject(double: Double) throws -> FREObject? {
        return try self._newObject(double)
    }
    
    static func newObject(int: Int) throws -> FREObject? {
        return try self._newObject(int)
    }
    
    static func newObject(uint: UInt) throws -> FREObject? {
        return try self._newObject(uint)
    }
    
    static func newObject(bool: Bool) throws -> FREObject? {
        return try self._newObject(bool)
    }
    
    static func newObject(any: Any) throws -> FREObject? {
        return try self._newObject(any: any)
    }
    
    static func newObject(className: String, args: NSPointerArray?) throws -> FREObject? {
        return try self._newObject(className, args)
    }
    
    fileprivate static func arrayToFREArray(_ array: NSPointerArray?) -> UnsafeMutablePointer<FREObject?>? {
        if let array = array {
            let ret = UnsafeMutablePointer<FREObject?>.allocate(capacity: array.count)
            for i in 0 ..< array.count {
                ret[i] = array.pointer(at: i)
            }
            return ret
        }
        return nil
    }
    
    fileprivate func arrayToFREArray(_ array: NSPointerArray?) -> UnsafeMutablePointer<FREObject?>? {
        if let array = array {
            let ret = UnsafeMutablePointer<FREObject?>.allocate(capacity: array.count)
            for i in 0 ..< array.count {
                ret[i] = array.pointer(at: i)
            }
            return ret
        }
        return nil
    }
    
    fileprivate static func _newObject(_ className: String, _ args: NSPointerArray?) throws -> FREObject? {
        var ret: FREObject?
        var thrownException: FREObject?
        var numArgs: UInt32 = 0
        if args != nil {
            numArgs = UInt32((args?.count)!)
        }
        #if os(iOS)
            let status: FREResult = FRESwiftBridge.bridge.FRENewObject(className: className, argc: numArgs, argv: args,
                                                                       object: &ret, thrownException: &thrownException)
        #else
            let status: FREResult = FRENewObject(className, numArgs, arrayToFREArray(args), &ret, &thrownException)
        #endif
        guard FRE_OK == status else {
            throw FREError(exception: FREObject.getActionscriptException(thrownException),
                           message: "cannot create new  object \(className)", code: getErrorCode(status),
                           line: #line, column: #column, file: #file)
        }
        return ret
    }
    
    fileprivate static func _newObject(any: Any) throws -> FREObject? {
        if any is FREObject {
            return (any as! FREObject)
        } else if any is String {
            return try self._newObject(any as! String)
        } else if any is Int {
            return try self._newObject(any as! Int)
        } else if any is Int32 {
            return try self._newObject(any as! Int)
        } else if any is UInt {
            return try self._newObject(any as! UInt)
        } else if any is UInt32 {
            return try self._newObject(any as! UInt)
        } else if any is Double {
            return try self._newObject(any as! Double)
        } else if any is Bool {
            return try self._newObject(any as! Bool)
        } //TODO add Dict and others
        return nil
        
    }
    
    fileprivate static func _newObject(_ string: String) throws -> FREObject? {
        var ret: FREObject?
        #if os(iOS)
            let status: FREResult = FRESwiftBridge.bridge.FRENewObjectFromUTF8(length: UInt32(string.utf8.count),
                                                                               value: string, object: &ret)
        #else
            let status: FREResult = FRENewObjectFromUTF8(UInt32(string.utf8.count), string, &ret)
        #endif
        guard FRE_OK == status else {
            throw FREError(exception: "", message: "cannot create new  object ", code: getErrorCode(status),
                           line: #line, column: #column, file: #file)
        }
        return ret
    }
    
    fileprivate static func _newObject(_ double: Double) throws -> FREObject? {
        var ret: FREObject?
        #if os(iOS)
            let status: FREResult = FRESwiftBridge.bridge.FRENewObjectFromDouble(value: double, object: &ret)
        #else
            let status: FREResult = FRENewObjectFromDouble(double, &ret)
        #endif
        guard FRE_OK == status else {
            throw FREError(exception: "", message: "cannot create new  object ", code: getErrorCode(status),
                           line: #line, column: #column, file: #file)
        }
        return ret
    }
    
    fileprivate static func _newObject(_ int: Int) throws -> FREObject? {
        var ret: FREObject?
        #if os(iOS)
            let status: FREResult = FRESwiftBridge.bridge.FRENewObjectFromInt32(value: Int32(int), object: &ret)
        #else
            let status: FREResult = FRENewObjectFromInt32(Int32(int), &ret)
        #endif
        guard FRE_OK == status else {
            throw FREError(exception: "", message: "cannot create new  object ", code: getErrorCode(status),
                           line: #line, column: #column, file: #file)
        }
        return ret
    }
    
    fileprivate static func _newObject(_ uint: UInt) throws -> FREObject? {
        var ret: FREObject?
        #if os(iOS)
            let status: FREResult = FRESwiftBridge.bridge.FRENewObjectFromUint32(value: UInt32(uint), object: &ret)
        #else
            let status: FREResult = FRENewObjectFromUint32(UInt32(uint), &ret)
        #endif
        guard FRE_OK == status else {
            throw FREError(exception: "", message: "cannot create new  object ", code: getErrorCode(status),
                           line: #line, column: #column, file: #file)
        }
        return ret
    }
    
    fileprivate static func _newObject(_ bool: Bool) throws -> FREObject? {
        var ret: FREObject?
        #if os(iOS)
            let status: FREResult = FRESwiftBridge.bridge.FRENewObjectFromBool(value: bool, object: &ret)
        #else
            let b: UInt32 = (bool == true) ? 1 : 0
            let status: FREResult = FRENewObjectFromBool(b, &ret)
        #endif
        guard FRE_OK == status else {
            throw FREError(exception: "", message: "cannot create new  object ", code: getErrorCode(status),
                           line: #line, column: #column, file: #file)
        }
        return ret
    }
    
    
    fileprivate func _getAsString(_ object: FREObject) throws -> String {
        var ret: String = ""
        var len: UInt32 = 0
        var valuePtr: UnsafePointer<UInt8>?
        #if os(iOS)
            let status: FREResult = FRESwiftBridge.bridge.FREGetObjectAsUTF8(object: object, length: &len, value: &valuePtr)
        #else
            let status: FREResult = FREGetObjectAsUTF8(object, &len, &valuePtr)
        #endif
        if FRE_OK == status {
            ret = (NSString(bytes: valuePtr!, length: Int(len), encoding: String.Encoding.utf8.rawValue) as? String)!
        } else {
            throw FREError(exception: "", message: "cannot get FREObject as String", code: FREObject.getErrorCode(status),
                           line: #line, column: #column, file: #file)
        }
        return ret
        
    }
    
    fileprivate func _getAsInt(_ object: FREObject) throws -> Int {
        var ret: Int32 = 0
        #if os(iOS)
            let status: FREResult = FRESwiftBridge.bridge.FREGetObjectAsInt32(object: object, value: &ret)
        #else
            let status: FREResult = FREGetObjectAsInt32(object, &ret)
        #endif
        guard FRE_OK == status else {
            throw FREError(exception: "", message: "cannot get FREObject as Int", code: FREObject.getErrorCode(status),
                           line: #line, column: #column, file: #file)
        }
        return Int(ret)
    }
    
    fileprivate func _getAsUInt(_ object: FREObject) throws -> UInt {
        var ret: UInt32 = 0
        #if os(iOS)
            let status: FREResult = FRESwiftBridge.bridge.FREGetObjectAsUint32(object: object, value: &ret)
        #else
            let status: FREResult = FREGetObjectAsUint32(object, &ret)
        #endif
        guard FRE_OK == status else {
            throw FREError(exception: "", message: "cannot get FREObject as UInt", code: FREObject.getErrorCode(status),
                           line: #line, column: #column, file: #file)
        }
        return UInt(ret)
    }
    
    fileprivate func _getAsDouble(_ object: FREObject) throws -> Double {
        var ret: Double = 0.0
        #if os(iOS)
            let status: FREResult = FRESwiftBridge.bridge.FREGetObjectAsDouble(object: object, value: &ret)
        #else
            let status: FREResult = FREGetObjectAsDouble(object, &ret)
        #endif
        guard FRE_OK == status else {
            throw FREError(exception: "", message: "cannot get FREObject as Double", code: FREObject.getErrorCode(status),
                           line: #line, column: #column, file: #file)
        }
        return ret
    }
    
    fileprivate func _getAsBool(_ object: FREObject) throws -> Bool {
        var ret: Bool = false
        var val: UInt32 = 0
        #if os(iOS)
            let status: FREResult = FRESwiftBridge.bridge.FREGetObjectAsBool(object: object, value: &val)
        #else
            let status: FREResult = FREGetObjectAsBool(object, &val)
        #endif
        guard FRE_OK == status else {
            throw FREError(exception: "", message: "cannot get FREObject as Bool", code: FREObject.getErrorCode(status),
                           line: #line, column: #column, file: #file)
        }
        ret = val == 1 ? true : false
        return ret
    }
    
}

//TODO may be able to improve in Swift 3.1
///http://stackoverflow.com/questions/37977817/extension-for-generic-type-unsafemutablepointeruint8/37978021#37978021

public typealias FREArray = UnsafeMutableRawPointer

extension FREArray {
    func getAsArray() throws -> Array<Any?> {
        return try _getAsArray(self)
    }
    
    fileprivate func _getAsArray(_ object: FREObject) throws -> Array<Any?> {
        var ret: [Any?] = []
        let arrayLength: UInt = try object.getLength()
        for i in 0 ..< arrayLength {
            if let elem: FREObject = try getObjectAt(index: i) {
                if let obj = try elem.getAsId() {
                    ret.append(obj)
                }
            }
        }
        return ret
        
    }
    
    func getObjectAt(index: UInt) throws -> FREObject? {
        var object: FREObject?
        #if os(iOS)
            let status: FREResult = FRESwiftBridge.bridge.FREGetArrayElementA(arrayOrVector: self, index: UInt32(index),
                                                                              value: &object)
        #else
            let status: FREResult = FREGetArrayElementAt(self, UInt32(index), &object)
        #endif
        guard FRE_OK == status else {
            
            throw FREError(exception: "", message: "cannot get object at \(index) ", code: FREObject.getErrorCode(status),
                           line: #line, column: #column, file: #file)
        }
        return object
    }
    
    func setObjectAt(index: UInt, object: FREObject) throws {
        #if os(iOS)
            let status: FREResult = FRESwiftBridge.bridge.FRESetArrayElementA(arrayOrVector: self, index: UInt32(index),
                                                                              value: object)
        #else
            let status: FREResult = FRESetArrayElementAt(self, UInt32(index), object)
        #endif
        guard FRE_OK == status else {
            throw FREError(exception: "", message: "cannot set object at \(index) ", code: FREObject.getErrorCode(status),
                           line: #line, column: #column, file: #file)
        }
    }
    
    func getLength() throws -> UInt {
        var ret: UInt32 = 0
        #if os(iOS)
            let status: FREResult = FRESwiftBridge.bridge.FREGetArrayLength(arrayOrVector: self, length: &ret)
        #else
            let status: FREResult = FREGetArrayLength(self, &ret)
        #endif
        guard FRE_OK == status else {
            throw FREError(exception: "", message: "cannot get length of array", code: FREObject.getErrorCode(status),
                           line: #line, column: #column, file: #file)
        }
        return UInt(ret)
    }
    
}

extension FREByteArray {
    static func newByteArray() -> FREByteArray {
        return self.init()
    }
    
    static func newByteArray(length: UInt32, bytes: UnsafeMutablePointer<UInt8>!) -> FREByteArray {
        return self.init(length: length, bytes: bytes)
    }
    
    func getLength() -> UInt {
        return UInt(self.length)
    }
    
    func getBytes() -> UnsafeMutablePointer<UInt8>! {
        return self.bytes;
    }
    
}

public typealias FREBitmapData = FREBitmapData2

extension FREBitmapData {
    func getWidth() -> UInt {
        return UInt(self.width)
    }
    
    func getHeight() -> UInt {
        return UInt(self.height)
    }
    
    func hasAlpha() -> Bool {
        return (self.hasAlpha == 1)
    }
    
    func isPremultiplied() -> Bool {
        return (self.isPremultiplied == 1)
    }
    
    func isInvertedY() -> Bool {
        return (self.isInvertedY == 1)
    }
    
    func getLineStride32() -> UInt {
        return UInt(self.lineStride32)
    }
    
    func getBits() -> UnsafeMutablePointer<UInt32>! {
        return self.bits32
    }
    
    func invalidateRect(object: FREObject, x: UInt, y: UInt, width: UInt, height: UInt) throws {
        #if os(iOS)
            let status: FREResult = FRESwiftBridge.bridge.FREInvalidateBitmapDataRect(object: object, x: UInt32(x),
                                                                                      y: UInt32(y), width: UInt32(width), height: UInt32(height))
        #else
            let status: FREResult = FREInvalidateBitmapDataRect(object, UInt32(x), UInt32(y), UInt32(width), UInt32(height))
        #endif
        
        guard FRE_OK == status else {
            throw FREError(exception: "", message: "cannot invalidateRect", code: FREObject.getErrorCode(status),
                           line: #line, column: #column, file: #file)
        }
    }
    
    static func newBitmapData() -> FREBitmapData {
        return self.init()
        
    }
    
    static func newBitmapData(width: UInt32, height: UInt32, hasAlpha: UInt32,
                              isPremultiplied: UInt32, lineStride32: UInt32, isInvertedY: UInt32,
                              bits32: UnsafeMutablePointer<UInt32>!) -> FREBitmapData {
        return self.init(width: width, height: height, hasAlpha: hasAlpha, isPremultiplied: isPremultiplied,
                         lineStride32: lineStride32, isInvertedY: isInvertedY, bits32: bits32)
    }
    
}

