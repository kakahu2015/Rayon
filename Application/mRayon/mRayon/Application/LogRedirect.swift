//
//  LogRedirect.swift
//  mRayon
//
//  Created by Lakr Aream on 2022/3/14.
//

import SwiftUI

class LogRedirect {
    static let shared = LogRedirect()

    var currentLog = ""
    var accessLock = NSLock()

    var handler: FileHandle?
    var path: URL?

    private init() {
        if let url = FileManager
            .default
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first?
            .appendingPathComponent("wiki.qaq.diag.log")
        {
            path = url
            try? FileManager.default.removeItem(at: url)
            FileManager.default.createFile(atPath: url.path, contents: nil, attributes: nil)
            handler = try? FileHandle(forWritingTo: url)
            checkPipe()
        }
    }

    func checkPipe() {
        return
    }
}
