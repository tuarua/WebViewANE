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

namespace WebViewANELib.Touch {
    internal class GraphicsHelper {
        public static double DpiX { get; }
        public static double DpiY { get; }

        public static Point DivideByDpi(Point point) {
            return new Point(point.X * 96.0 / DpiX, point.Y * 96.0 / DpiY);
        }

        static GraphicsHelper() {
            using (var graphics = System.Drawing.Graphics.FromHwnd(IntPtr.Zero)) {
                DpiX = graphics.DpiX;
                DpiY = graphics.DpiY;
            }
        }
    }
}