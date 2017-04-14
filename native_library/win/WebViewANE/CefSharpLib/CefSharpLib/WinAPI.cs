using System;
using System.Runtime.InteropServices;
using Hwnd = System.IntPtr;
namespace CefSharpLib {
    public static class WinApi {
        public const string User32 = "user32";
        public const string Kernel32 = "kernel32";

        [DllImport(User32, ExactSpelling = true)]
        public static extern bool ShowWindow(Hwnd hwnd, ShowWindowCommands nCmdShow);

        [DllImport(User32, ExactSpelling = true)]
        public static extern bool UpdateWindow(Hwnd hwnd);

        [DllImport(User32, ExactSpelling = true)]
        public static extern bool SetWindowPos(Hwnd hwnd, IntPtr hWndInsertAfter, int x, int y, int cx, int cy,
            WindowPositionFlags flags);

        [DllImport(User32, ExactSpelling = true)]
        public static extern bool RegisterTouchWindow(Hwnd hwnd, TouchWindowFlags flags);
    }

    [Flags]
    public enum ShowWindowCommands {
        SW_FORCEMINIMIZE = 11,
        SW_HIDE = 0,
        SW_MAXIMIZE = 3,
        SW_MINIMIZE = 6,
        SW_RESTORE = 9,
        SW_SHOW = 5,
        SW_SHOWDEFAULT = 10,
        SW_SHOWMAXIMIZED = 3,
        SW_SHOWMINIMIZED = 2,
        SW_SHOWMINNOACTIVE = 7,
        SW_SHOWNA = 8,
        SW_SHOWNOACTIVATE = 4,
        SW_SHOWNORMAL = 1
    }

    [Flags]
    public enum WindowStyles {
        WS_BORDER = 0x00800000,
        WS_CAPTION = 0x00C00000,
        WS_CHILD = 0x40000000,
        WS_CHILDWINDOW = 0x40000000,
        WS_CLIPCHILDREN = 0x02000000,
        WS_CLIPSIBLINGS = 0x04000000,
        WS_DISABLED = 0x08000000,
        WS_DLGFRAME = 0x00400000,
        WS_GROUP = 0x00020000,
        WS_HSCROLL = 0x00100000,
        WS_ICONIC = 0x20000000,
        WS_MAXIMIZE = 0x01000000,
        WS_MAXIMIZEBOX = 0x00010000,
        WS_MINIMIZE = 0x20000000,
        WS_MINIMIZEBOX = 0x00020000,
        WS_OVERLAPPED = 0x00000000,

        WS_OVERLAPPEDWINDOW =
            WS_OVERLAPPED | WS_CAPTION | WS_SYSMENU | WS_THICKFRAME | WS_MINIMIZEBOX | WS_MAXIMIZEBOX,
        WS_POPUP = unchecked((int)0x80000000),
        WS_POPUPWINDOW = WS_POPUP | WS_BORDER | WS_SYSMENU,
        WS_SIZEBOX = 0x00040000,
        WS_SYSMENU = 0x00080000,
        WS_TABSTOP = 0x00010000,
        WS_THICKFRAME = 0x00040000,
        WS_TILED = 0x00000000,
        WS_TILEDWINDOW = WS_OVERLAPPED | WS_CAPTION | WS_SYSMENU | WS_THICKFRAME | WS_MINIMIZEBOX | WS_MAXIMIZEBOX,
        WS_VISIBLE = 0x10000000,
        WS_VSCROLL = 0x00200000
    }

    [Flags]
    public enum WindowPositionFlags {
        SWP_ASYNCWINDOWPOS = 0x4000,
        SWP_DEFERERASE = 0x2000,
        SWP_DRAWFRAME = 0x0020,
        SWP_FRAMECHANGED = 0x0020,
        SWP_HIDEWINDOW = 0x0080,
        SWP_NOACTIVATE = 0x0010,
        SWP_NOCOPYBITS = 0x0100,
        SWP_NOMOVE = 0x0002,
        SWP_NOOWNERZORDER = 0x0200,
        SWP_NOREDRAW = 0x0008,
        SWP_NOREPOSITION = 0x0200,
        SWP_NOSENDCHANGING = 0x0400,
        SWP_NOSIZE = 0x0001,
        SWP_NOZORDER = 0x0004,
        SWP_SHOWWINDOW = 0x0040
    }

    [Flags]
    public enum TouchWindowFlags {
        TWF_FINETOUCH = 0x00000001,
        TWF_WANTPALM = 0x00000002
    }

}