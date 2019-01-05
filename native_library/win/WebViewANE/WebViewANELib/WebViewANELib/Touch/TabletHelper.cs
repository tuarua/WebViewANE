using System;
using System.Reflection;
using System.Windows.Input;
namespace WebViewANELib.Touch {
    public static class TabletHelper {
        public static bool HasRemovedDevices { get; private set; }

        private static readonly object StylusLogic;
        private static readonly Type StylusLogicType;
        private static readonly FieldInfo CountField452;

        static TabletHelper()  {
            var inputManagerType = typeof(InputManager);
            StylusLogic = inputManagerType.InvokeMember("StylusLogic", BindingFlags.GetProperty | BindingFlags.Instance | BindingFlags.NonPublic,
                null, InputManager.Current, null);

            if (StylusLogic == null) return;
            StylusLogicType = StylusLogic.GetType();
            CountField452 = StylusLogicType.GetField("_lastSeenDeviceCount", BindingFlags.Instance | BindingFlags.NonPublic);
        }

        public static void DisableWpfTabletSupport(IntPtr hWnd) {
            while (Tablet.TabletDevices.Count > 0) {
                // Only in .Net Framework 4.5.2 - see https://connect.microsoft.com/VisualStudio/Feedback/Details/1016534
                if (CountField452 != null) {
                    CountField452.SetValue(StylusLogic, 1 + (int)CountField452.GetValue(StylusLogic));
                }
                var index = Tablet.TabletDevices.Count - 1;

                StylusLogicType.InvokeMember("OnTabletRemoved", BindingFlags.InvokeMethod | BindingFlags.Instance | BindingFlags.NonPublic,
                    null, StylusLogic, new object[] { (uint)index });

                HasRemovedDevices = true;
            }
        }
    }

}