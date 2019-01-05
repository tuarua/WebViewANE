using System;
using System.Runtime.InteropServices;

// ReSharper disable IdentifierTypo
namespace WebViewANELib.Touch {
    [StructLayout(LayoutKind.Sequential)]
    internal struct TouchInput {
        public int x;
        public int y;
        public IntPtr hSource;
        public int dwID;
        public TouchEvent dwFlags;
        public int dwMask;
        public int dwTime;
        public IntPtr dwExtraInfo;
        public int cxContact;
        public int cyContact;
    }
}