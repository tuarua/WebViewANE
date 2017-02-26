//
// Created by User on 08/12/2016.
// Copyright (c) 2016 Tua Rua Ltd. All rights reserved.
//

import Cocoa
import Foundation

class ANEHelper {
    private var dllContext: FREContext!
    func setFREContext(ctx: FREContext) {
        dllContext = ctx
    }

    private func trace(value: String) {
        FREDispatchStatusEventAsync(self.dllContext, value, "TRACE")
    }

    private func isFREResultOK(errorCode: FREResult, errorMessage: String) -> Bool {
        if FRE_OK == errorCode {
            return true
        }
        let messageToReport: String = "\(errorMessage) \(errorCode)"
        Swift.debugPrint(messageToReport)
        trace(value: messageToReport)
        return false
    }

    private func hasThrownException(thrownException: FREObject?) -> Bool {
        if thrownException == nil {
            return false
        }
        var objectType: FREObjectType? = nil
        if FRE_OK != FREGetObjectType(thrownException, &objectType!) {
            NSLog("Exception was thrown, but failed to obtain information about its type")
            trace(value: "Exception was thrown, but failed to obtain information about it")
            return true
        }

        if FRE_TYPE_OBJECT == objectType {
            var exceptionTextAS: FREObject? = nil
            var newException: FREObject? = nil

            if FRE_OK != FRECallObjectMethod(thrownException, "toString", 0, nil, &exceptionTextAS, &newException) {
                NSLog("Exception was thrown, but failed to obtain information about it");
                trace(value: "Exception was thrown, but failed to obtain information about it")
                return true;
            }
            return true

        }

        return false
    }

    func getFreObject(bool: Bool!) -> FREObject? {
        var ret: FREObject? = nil
        let b: UInt32 = (bool == true) ? 1 : 0

        let status: FREResult = FRENewObjectFromBool(b, &ret)
        _ = isFREResultOK(errorCode: status, errorMessage: "Could not convert Bool to FREObject.")
        return ret
    }

    func getFreObject(string: String!) -> FREObject? {
        var ret: FREObject? = nil
        let status: FREResult = FRENewObjectFromUTF8(UInt32(string.characters.count), string, &ret)
        _ = isFREResultOK(errorCode: status, errorMessage: "Could not convert String to FREObject.")
        return ret
    }

    func getFREObject(double: Double) -> FREObject? {
        var ret: FREObject? = nil
        let status: FREResult = FRENewObjectFromDouble(Double(double), &ret)
        _ = isFREResultOK(errorCode: status, errorMessage: "Could not convert Double to FREObject.")
        return ret
    }

    func getFreObject(int: Int) -> FREObject? {
        var ret: FREObject? = nil
        let status: FREResult = FRENewObjectFromInt32(Int32(int), &ret);
        _ = isFREResultOK(errorCode: status, errorMessage: "Could not convert Int to FREObject.")
        return ret
    }

    func createFREObject(className: String) -> FREObject? {
        var ret: FREObject? = nil
        var thrownException: FREObject? = nil
        let status: FREResult = FRENewObject(className, 0, nil, &ret, &thrownException)
        _ = isFREResultOK(errorCode: status, errorMessage: "Could not create FREObject.")
        if (FRE_OK != status) {
            _ = hasThrownException(thrownException: thrownException!);
        }
        return ret
    }


    func setProperty(freObject: FREObject, name: String, prop: FREObject) {
        var thrownException: FREObject? = nil
        let status: FREResult = FRESetObjectProperty(freObject, name, prop, &thrownException)
        _ = isFREResultOK(errorCode: status, errorMessage: "Could not set property on FREObject.")
        if (FRE_OK != status) {
            _ = hasThrownException(thrownException: thrownException!);
        }

    }

    func getCGPoint(freObject: FREObject?) -> CGPoint {
        var val: CGPoint = CGPoint.init(x: 0, y: 0)

        var thrownException: FREObject? = nil
        var valueX: FREObject? = nil
        var valueY: FREObject? = nil
        var isOK: Bool = true;

        var status: FREResult = FREGetObjectProperty(freObject, UnsafePointer<UInt8>("x"), &valueX, &thrownException)
        _ = isFREResultOK(errorCode: status, errorMessage: "Could not get x on Point FREObject.")
        if (FRE_OK != status) {
            isOK = false
            _ = hasThrownException(thrownException: thrownException!);
        }

        status = FREGetObjectProperty(freObject, UnsafePointer<UInt8>("y"), &valueY, &thrownException)
        _ = isFREResultOK(errorCode: status, errorMessage: "Could not get y on Point FREObject.")
        if (FRE_OK != status) {
            isOK = false
            _ = hasThrownException(thrownException: thrownException!);
        }

        if isOK {
            val = CGPoint.init(x: getInt(freObject: valueX), y: getInt(freObject: valueY))
        }


        return val
    }

    func getDouble(freObject: FREObject?) -> Double {
        var val: Double = 0.0
        let status: FREResult = FREGetObjectAsDouble(freObject, &val)
        _ = isFREResultOK(errorCode: status, errorMessage: "Could not convert FREObject to Double.")
        return val
    }
    
    func getCGFloat(freObject: FREObject?) -> CGFloat {
        var val: Double = 0.0
        let status: FREResult = FREGetObjectAsDouble(freObject, &val)
        _ = isFREResultOK(errorCode: status, errorMessage: "Could not convert FREObject to CGFloat.")
        return CGFloat(val)
    }

    func getString(freObject: FREObject?) -> String {
        var strLength: CUnsignedInt? = 0
        var arg: UnsafePointer<UInt8>? = nil

        let status: FREResult = FREGetObjectAsUTF8(freObject, &strLength!, &arg)
        let isOK = self.isFREResultOK(errorCode: status, errorMessage: "Could not convert FREGetObjectAsUTF8.")
        
        if isOK {
            return (NSString(bytes: arg!, length: Int(strLength!),
                    encoding: String.Encoding.utf8.rawValue) as? String)!
        } else {
            return ""
        }

    }


    func getInt(freObject: FREObject?) -> Int {
        var result: CInt? = 0
        let status: FREResult = FREGetObjectAsInt32(freObject, &result!)
        _ = isFREResultOK(errorCode: status, errorMessage: "Could not convert FREObject to Int.")
        return Int(result!)
    }
    
    func getBool(freObject: FREObject?) ->Bool {
        var val: CUnsignedInt? = 0
        FREGetObjectAsBool(freObject, &val!);
        return (val == 1)
    }

    private func getArrayLength(freObject: FREObject) -> Int {
        var valueAs: FREObject? = nil
        FREGetObjectProperty(freObject, UnsafePointer<UInt8>("length"), &valueAs, nil)
        return self.getInt(freObject: valueAs!)
    }


    func getArray(freObject: FREObject?) -> Array<Any?>? {
        var result: [Any?] = []
        if let freObject = freObject {
            let arrayLength: Int = getArrayLength(freObject: freObject)
            for i in 0 ..< arrayLength {
                var objAs: FREObject? = nil
                FREGetArrayElementAt(freObject, UInt32(i), &objAs);
                if objAs != nil {
                    let obj = self.getIdObject(freObject: objAs)
                    result.append(obj)
                }

            }

        }

        return result
    }

    public func printObjectType(freObject: FREObject?) {
        var objectType: FREObjectType = FRE_TYPE_NULL;
        FREGetObjectType(freObject, &objectType);
        switch objectType {
        case FRE_TYPE_ARRAY:
            Swift.debugPrint("printObjectType: FRE_TYPE_ARRAY")
            break
        case FRE_TYPE_VECTOR:
            Swift.debugPrint("printObjectType: FRE_TYPE_VECTOR")
            break
        case FRE_TYPE_STRING:
            Swift.debugPrint("printObjectType: FRE_TYPE_STRING")
            break
        case FRE_TYPE_BOOLEAN:
            Swift.debugPrint("printObjectType: FRE_TYPE_BOOLEAN")
            break
        case FRE_TYPE_OBJECT:
            Swift.debugPrint("printObjectType: FRE_TYPE_OBJECT")
            break
        case FRE_TYPE_NUMBER:
            Swift.debugPrint("printObjectType: FRE_TYPE_NUMBER")
            break
        case FRE_TYPE_NULL:
            Swift.debugPrint("printObjectType: FRE_TYPE_NULL")
            break
        default:
            break
        }
    }

    func getProperty(freObject: FREObject?, propertyName: String) -> FREObject? {
        var valueAS: FREObject? = nil;
        var thrownException: FREObject? = nil
        let status: FREResult = FREGetObjectProperty(freObject, UnsafePointer<UInt8>(propertyName), &valueAS,
                &thrownException)
        _ = isFREResultOK(errorCode: status, errorMessage: "Could not get FREObject property.")
        if (FRE_OK != status) {
            _ = hasThrownException(thrownException: thrownException!);
        }
        return valueAS;
    }
    
    public func getNSImage(freObject: FREObject?) -> NSImage {
        let objectBitmapData:FREObject = freObject!;
        var bitmapData:FREBitmapData2 = FREBitmapData2();
        
        FREAcquireBitmapData2( objectBitmapData, &bitmapData );
        
        let width:Int = Int(bitmapData.width);
        let height:Int = Int(bitmapData.height);
        
        
        let releaseProvider: CGDataProviderReleaseDataCallback = { (info: UnsafeMutableRawPointer?,
            data: UnsafeRawPointer, size: Int) -> () in
            // https://developer.apple.com/reference/coregraphics/cgdataproviderreleasedatacallback
            // N.B. 'CGDataProviderRelease' is unavailable: Core Foundation objects are automatically memory managed
            return
        }
        
        let provider:CGDataProvider = CGDataProvider(dataInfo: nil, data: bitmapData.bits32, size: (width * height * 4),
                                                     releaseData:releaseProvider)!
        
        
        let bitsPerComponent = 8;
        let bitsPerPixel = 32;
        let bytesPerRow:Int = 4 * width;
        let colorSpaceRef:CGColorSpace = CGColorSpaceCreateDeviceRGB();
        var bitmapInfo:CGBitmapInfo
        
        if bitmapData.hasAlpha == 1 {
            if  bitmapData.isPremultiplied == 1 {
                bitmapInfo = CGBitmapInfo.init(rawValue: CGBitmapInfo.byteOrder32Little.rawValue |
                    CGImageAlphaInfo.premultipliedFirst.rawValue )
            }else{
                bitmapInfo = CGBitmapInfo.init(rawValue: CGBitmapInfo.byteOrder32Little.rawValue |
                    CGImageAlphaInfo.first.rawValue )
            }
        } else {
            bitmapInfo = CGBitmapInfo.init(rawValue: CGBitmapInfo.byteOrder32Little.rawValue |
                CGImageAlphaInfo.noneSkipLast.rawValue )
        }
        
        let renderingIntent:CGColorRenderingIntent = CGColorRenderingIntent.defaultIntent;
        let imageRef:CGImage = CGImage(width: width, height: height, bitsPerComponent: bitsPerComponent,
                                       bitsPerPixel: bitsPerPixel, bytesPerRow: bytesPerRow, space: colorSpaceRef,
                                       bitmapInfo: bitmapInfo, provider: provider, decode: nil, shouldInterpolate: false,
                                       intent: renderingIntent)!;
        
        let img:NSImage = NSImage(cgImage: imageRef, size: NSSize.init(width: width, height: height))
        return img

    }

    func getIdObject(freObject: FREObject?) -> Any? {
        var objectType: FREObjectType = FRE_TYPE_NULL;
        FREGetObjectType(freObject, &objectType);

        switch objectType {
        case FRE_TYPE_VECTOR, FRE_TYPE_ARRAY:
            return getArray(freObject: freObject)
        case FRE_TYPE_STRING:
            return self.getString(freObject: freObject);
        case FRE_TYPE_BOOLEAN:
            var val: CUnsignedInt? = 0
            FREGetObjectAsBool(freObject, &val!);
            return (val == 1)

        case FRE_TYPE_OBJECT:
            var result: FREObject? = nil
            let status: FREResult = FRECallObjectMethod(freObject, UnsafePointer<UInt8>("getPropNames"), 0, nil,
                    &result, nil)
            if FRE_OK == status {
                let paramNames: Array = getArray(freObject: result!)!
                var dict: Dictionary = Dictionary<String, AnyObject>()
                for item in paramNames {
                    var propVal: FREObject? = nil;
                    propVal = getProperty(freObject: freObject, propertyName: item as! String)
                    if let propVal2 = getIdObject(freObject: propVal) {
                        dict.updateValue(propVal2 as AnyObject, forKey: item as! String)
                    }
                }
                return dict
            } else {
                Swift.debugPrint("Could not convert FREObject to Dictionary.", status)
            }

            return nil;

        case FRE_TYPE_NUMBER:
            return getDouble(freObject: freObject)

        case FRE_TYPE_BITMAPDATA:
            return getNSImage(freObject: freObject);

        case FRE_TYPE_BYTEARRAY:
            return nil;

        case FRE_TYPE_NULL:
            return nil;

        default:
            break;
        }

        return nil

    }


}
