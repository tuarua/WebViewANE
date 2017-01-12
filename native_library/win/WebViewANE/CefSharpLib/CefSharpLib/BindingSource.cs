using System;

namespace CefSharpLib
{
    public class BindingSource
    {
        private string _address;

        public BindingSource()
        {
        }


        public String Address
        {
            set
            {
                Console.WriteLine(@"BindingSource set called Old Address: " + _address + @" new address" + value);
                _address = value;
            }
        }

        public String Title
        {
            set { Console.WriteLine(@"BindingSource set called Title" + value); }
        }

        public bool IsLoading
        {
            set { Console.WriteLine(@"BindingSource set called IsLoading" + value); }
        }

        public bool CanGoBack
        {
            set { Console.WriteLine(@"BindingSource set called CanGoBack" + value); }
        }

        public bool CanGoForward
        {
            set { Console.WriteLine(@"BindingSource set called CanGoForward" + value); }
        }

    }
}