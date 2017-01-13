/*
 * Copyright Tua Rua Ltd. (c) 2017.
 */

/**
 * Created by User on 07/01/2017.
 */
package com.tuarua.webview {
[RemoteClass(alias="com.tuarua.webview.BackForwardList")]
public class BackForwardList {
    public var backList:Vector.<BackForwardListItem> = new Vector.<BackForwardListItem>();
    public var forwardList:Vector.<BackForwardListItem> = new Vector.<BackForwardListItem>();
    public var currentItem:BackForwardListItem;
    public function BackForwardList() {
    }
}
}
