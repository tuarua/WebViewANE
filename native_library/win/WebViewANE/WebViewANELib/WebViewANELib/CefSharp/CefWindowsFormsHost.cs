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
//  All Rights Reserved. Tua Rua Ltd.
#endregion

using System;
using System.Windows;
using System.Windows.Forms.Integration;
using WebViewANELib.Touch;

// ReSharper disable IdentifierTypo

namespace WebViewANELib.CefSharp {
    public class CefWindowsFormsHost : WindowsFormsHost {
        static CefWindowsFormsHost() {
            DefaultStyleKeyProperty.OverrideMetadata(typeof(CefWindowsFormsHost), new FrameworkPropertyMetadata(typeof(CefWindowsFormsHost)));
        }

        protected override IntPtr WndProc(IntPtr hwnd, int msg, IntPtr wParam, IntPtr lParam, ref bool handled) {
            MessageTouchDevice.WndProc(Window.GetWindow(this), msg, wParam, lParam, ref handled);
            return base.WndProc(hwnd, msg, wParam, lParam, ref handled);
        }
    }
}