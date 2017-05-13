using System;
using System.Collections.Generic;
using TuaRua.FreSharp;
using FREObject = System.IntPtr;
using FREContext = System.IntPtr;

namespace CefSharpLib {
    public abstract class FreSharpController {
        public Dictionary<string, Func<FREContext, uint, FREObject[], FREObject>> FunctionsDict;
        public static FreContextSharp Context;
        public FREObject CallSharpFunction(string name, ref FREContext ctx, uint argc, FREObject[] argv) {
            return FunctionsDict[name].Invoke(ctx, argc, argv);
        }

        public void SetFreContext(ref FREContext freContext) {
            Context = new FreContextSharp(freContext);
        }

        public void Trace(string value) {
            Context.DispatchEvent("TRACE", value);
        }

    }
}
