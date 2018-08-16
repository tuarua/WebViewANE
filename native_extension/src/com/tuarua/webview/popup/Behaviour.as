/*
 * Copyright 2017 Tua Rua Ltd.
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 *
 *  Additional Terms
 *  No part, or derivative of this Air Native Extensions's code is permitted
 *  to be sold as the basis of a commercially packaged Air Native Extension which
 *  undertakes the same purpose as this software. That is, a WebView for Windows,
 *  OSX and/or iOS and/or Android.
 *  All Rights Reserved. Tua Rua Ltd.
 */
package com.tuarua.webview.popup {
public final class Behaviour {
    public static const BLOCK:uint = 0;
    /** On OSX any spawned windows will replace any previous*/
    public static const NEW_WINDOW:uint = 1;
    public static const SAME_WINDOW:uint = 2;
    /** On Windows. Any spawned windows opened will replace any previous. On OSX this is NEW_WINDOW's default behaviour*/
    public static const REPLACE:uint = 3;
}
}
