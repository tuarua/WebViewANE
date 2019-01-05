using System;
// ReSharper disable IdentifierTypo

namespace WebViewANELib.Touch {
    [Flags]
    internal enum TouchEvent {
        TOUCHEVENTF_MOVE = 0x0001,
        TOUCHEVENTF_DOWN = 0x0002,
        TOUCHEVENTF_UP = 0x0004,
    }
}