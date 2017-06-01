#region License
// Copyright 2017 Tua Rua Ltd.
// 
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
// 
//  http://www.apache.org/licenses/LICENSE-2.0
// 
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
// 
//  Additional Terms
//  No part, or derivative of this Air Native Extensions's code is permitted 
//  to be sold as the basis of a commercially packaged Air Native Extension which 
//  undertakes the same purpose as this software. That is, a WebView for Windows, 
//  OSX and/or iOS and/or Android.
//  All Rights Reserved. Tua Rua Ltd.
#endregion
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
