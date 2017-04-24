using System;
using System.Collections.Generic;
using FreSharp;
using FREObjectSharp = System.IntPtr;
using FREContextSharp = System.IntPtr;

namespace CefSharpLib {
    public abstract class FreSharpController {
        public Dictionary<string, Func<FREContextSharp, uint, FREObjectSharp[], FREObjectSharp>> FunctionsDict;
        public static readonly FreSharpHelper FreHelper = new FreSharpHelper();

        public FREObjectSharp CallSharpFunction(string name, ref FREContextSharp ctx, uint argc, FREObjectSharp[] argv) {
            return FunctionsDict[name].Invoke(ctx, argc, argv);
        }
        public void SetFreContext(ref FREContextSharp freContext) {
            FreHelper.SetFreContext(ref freContext);
        }
        public void Trace(string value) {
            FreHelper.DispatchEvent("TRACE", value);
        }
    }
}
