using System;
using System.Collections.Generic;
using FreSharp;
using FREObject = System.IntPtr;
using FREContext = System.IntPtr;

namespace CefSharpLib {
    public abstract class FreSharpController {
        public Dictionary<string, Func<FREContext, uint, FREObject[], FREObject>> FunctionsDict;
        public static readonly FreSharpHelper FreHelper = new FreSharpHelper();

        public FREObject CallSharpFunction(string name, ref FREContext ctx, uint argc, FREObject[] argv) {
            return FunctionsDict[name].Invoke(ctx, argc, argv);
        }
        public void SetFreContext(ref FREContext freContext) {
            FreHelper.SetFreContext(ref freContext);
        }
        public void Trace(string value) {
            FreHelper.DispatchEvent("TRACE", value);
        }
    }
}
