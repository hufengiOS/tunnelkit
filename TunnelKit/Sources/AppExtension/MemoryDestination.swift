//
//  MemoryDestination.swift
//  TunnelKit
//
//  Created by Davide De Rosa on 7/26/17.
//  Copyright (c) 2019 Davide De Rosa. All rights reserved.
//
//  https://github.com/passepartoutvpn
//
//  This file is part of TunnelKit.
//
//  TunnelKit is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  TunnelKit is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with TunnelKit.  If not, see <http://www.gnu.org/licenses/>.
//
//  This file incorporates work covered by the following copyright and
//  permission notice:
//
//      Copyright (c) 2018-Present Private Internet Access
//
//      Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//      The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//      THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

import Foundation
import SwiftyBeaver

class MemoryDestination: BaseDestination, CustomStringConvertible {
    private var buffer: [String] = []
    
    var maxLines: Int?
    
    override init() {
        super.init()
        asynchronously = false
    }
    
    func start(with existing: [String]) {
        execute(synchronously: true) {
            self.buffer = existing
        }
    }
    
    func flush(to url: URL) {
        execute(synchronously: true) {
            let content = self.buffer.joined(separator: "\n")
            try? content.write(to: url, atomically: true, encoding: .utf8)
        }
    }
    
    var description: String {
        return executeSynchronously {
            return self.buffer.joined(separator: "\n")
        }
    }
    
    // MARK: BaseDestination

    // XXX: executed in SwiftyBeaver queue. DO NOT invoke execute* here (sync in sync would crash otherwise)
    override func send(_ level: SwiftyBeaver.Level, msg: String, thread: String, file: String, function: String, line: Int, context: Any?) -> String? {
        guard let message = super.send(level, msg: msg, thread: thread, file: file, function: function, line: line) else {
            return nil
        }
        buffer.append(message)
        if let maxLines = maxLines {
            while buffer.count > maxLines {
                buffer.removeFirst()
            }
        }
        return message
    }
}
