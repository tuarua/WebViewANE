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
using System.Collections.Generic;
using System.Reflection;
using System.Windows;
using System.Windows.Input;
using System.Windows.Media;
using TuaRua.FreSharp.Utils;

namespace WebViewANELib.Touch {
    public class MessageTouchDevice : TouchDevice {
        private static readonly FieldInfo ActualLeft;
        private static readonly FieldInfo ActualTop;
        private static readonly Dictionary<int, MessageTouchDevice> Devices = new Dictionary<int, MessageTouchDevice>();

        static MessageTouchDevice() {
            ActualLeft = typeof(Window).GetField("_actualLeft", BindingFlags.Instance | BindingFlags.NonPublic);
            ActualTop = typeof(Window).GetField("_actualTop", BindingFlags.Instance | BindingFlags.NonPublic);
        }

        public static void RegisterTouchWindow(IntPtr hWnd) {
            TabletHelper.DisableWpfTabletSupport(hWnd);
            TuaRua.FreSharp.Utils.WinApi.RegisterTouchWindow(hWnd, TouchWindowFlags.TWF_WANTPALM);
        }

        public static void WndProc(Window window, int msg, IntPtr wParam, IntPtr lParam, ref bool handled) {
            if (msg != WinApi.WM_TOUCH) return;
            var inputCount = wParam.ToInt32() & 0xffff;
            var inputs = new TouchInput[inputCount];
            if (WinApi.GetTouchInputInfo(lParam, inputCount, inputs, WinApi.TouchInputSize)) {
                for (var i = 0; i < inputCount; i++) {
                    var input = inputs[i];
                    var position = GraphicsHelper.DivideByDpi(new Point(input.x * 0.01, input.y * 0.01));
                    position.Offset(-(double)ActualLeft.GetValue(window), -(double)ActualTop.GetValue(window));
                    if (!Devices.TryGetValue(input.dwID, out var device)) {
                        device = new MessageTouchDevice(input.dwID);
                        Devices.Add(input.dwID, device);
                    }
                    if (!device.IsActive && input.dwFlags.HasFlag(TouchEvent.TOUCHEVENTF_DOWN)) {
                        device.SetActiveSource(PresentationSource.FromVisual(window));
                        device.Position = position;
                        device.Activate();
                        device.ReportDown();
                    }
                    else if (device.IsActive && input.dwFlags.HasFlag(TouchEvent.TOUCHEVENTF_UP)) {
                        device.Position = position;
                        device.ReportUp();
                        device.Deactivate();
                        Devices.Remove(input.dwID);
                    }
                    else if (device.IsActive && input.dwFlags.HasFlag(TouchEvent.TOUCHEVENTF_MOVE) && device.Position != position)  {
                        device.Position = position;
                        device.ReportMove();
                    }
                }
            }

            WinApi.CloseTouchInputHandle(lParam);
            handled = true;
        }

        internal MessageTouchDevice(int id)
            : base(id) { }

        public Point Position { get; set; }

        public override TouchPointCollection GetIntermediateTouchPoints(IInputElement relativeTo) {
            return new TouchPointCollection();
        }

        public override TouchPoint GetTouchPoint(IInputElement relativeTo) {
            var pt = Position;
            if (relativeTo != null) {
                if (ActiveSource != null) {
                    var rootVisual = ActiveSource.RootVisual;
                    var relativeVisual = (Visual)relativeTo;
                    if (rootVisual.IsAncestorOf(relativeVisual)) {
                        pt = rootVisual.TransformToDescendant(relativeVisual).Transform(Position);
                    }  
                }
            }

            var rect = new Rect(pt, new Size(1.0, 1.0));
            return new TouchPoint(this, pt, rect, TouchAction.Move);
        }

        protected override void OnCapture(IInputElement element, CaptureMode captureMode) {
            Mouse.PrimaryDevice.Capture(element, captureMode);
        }
    }

}