//
//  FileIO.swift
//  Task Tracker
//
//  Created by Abraham Narvaez on 12/13/20.
//  Copyright © 2020 MongoDB, Inc. All rights reserved.
//

import Foundation

struct FileIO {
    static let realmFileURL = ""
    static let documentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let archiveURL = documentsDirectory.appendingPathComponent("userData")
    
//    func read(fileNamed: String) throws -> Data {
//       guard let url = makeURL(forFileNamed: fileNamed) else {
//           throw Error.invalidDirectory
//       }
//       guard fileManager.fileExists(atPath: url.absoluteString) else {
//           throw Error.fileNotExists
//       }
//       do {
//           return try Data(contentsOf: url)
//       } catch {
//           debugPrint(error)
//           throw Error.readingFailed
//       }
//   }
}
