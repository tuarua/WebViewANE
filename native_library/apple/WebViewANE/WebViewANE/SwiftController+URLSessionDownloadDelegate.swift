// Copyright 2018 Tua Rua Ltd.
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
//  Additional Terms
//  No part, or derivative of this Air Native Extensions's code is permitted
//  to be sold as the basis of a commercially packaged Air Native Extension which
//  undertakes the same purpose as this software. That is, a WebView for Windows,
//  OSX and/or iOS and/or Android.
//  All Rights Reserved. Tua Rua Ltd.

import Foundation
import WebKit
import SwiftyJSON

extension SwiftController: URLSessionTaskDelegate, URLSessionDelegate, URLSessionDownloadDelegate {
    // https://developer.apple.com/documentation/foundation/urlsessiondownloadtask
    // https://www.raywenderlich.com/158106/urlsession-tutorial-getting-started
    public func urlSession(_ session: URLSession,
                           downloadTask: URLSessionDownloadTask,
                           didFinishDownloadingTo location: URL) {
        guard let destinationURL = downloadTaskSaveTos[downloadTask.taskIdentifier] else { return }

        let fileManager = FileManager.default
        try? fileManager.removeItem(at: destinationURL)
        do {
            try fileManager.copyItem(at: location, to: destinationURL)
        } catch {
            self.dispatchEvent(name: WebViewEvent.ON_DOWNLOAD_CANCEL,
                           value: downloadTask.originalRequest?.url?.absoluteString ?? "")
        }
        
        dispatchEvent(name: WebViewEvent.ON_DOWNLOAD_COMPLETE, value: String(describing: downloadTask.taskIdentifier))
        downloadTaskSaveTos[downloadTask.taskIdentifier] = nil
    }
    
    public func urlSession(_ session: URLSession,
                           downloadTask: URLSessionDownloadTask,
                           didWriteData bytesWritten: Int64,
                           totalBytesWritten: Int64,
                           totalBytesExpectedToWrite: Int64) {
        var props = [String: Any]()
        props["id"] = downloadTask.taskIdentifier
        props["url"] = downloadTask.originalRequest?.url?.absoluteString
        props["speed"] = 0
        props["percent"] = (Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)) * 100
        props["bytesLoaded"] = Double(totalBytesWritten)
        props["bytesTotal"] = Double(totalBytesExpectedToWrite)
        dispatchEvent(name: WebViewEvent.ON_DOWNLOAD_PROGRESS, value: JSON(props).description)
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        self.dispatchEvent(name: WebViewEvent.ON_DOWNLOAD_CANCEL,
                       value: task.originalRequest?.url?.absoluteString ?? "")
    }
}
