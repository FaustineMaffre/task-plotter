//
//  Storage.swift
//  task-plotter
//
//  Created by Faustine Maffre on 14/12/2020.
//

import Foundation

class Storage {
    static let encoder: JSONEncoder = JSONEncoder()
    static let decoder: JSONDecoder = JSONDecoder()
    
    static let dataFileUrl: URL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath).appendingPathComponent("data.txt", isDirectory: false)
    
    static func store<T: Encodable>(_ object: T) {
        // encode data
        if let encoded = try? Self.encoder.encode(object) {
            
            // create new file with data
            FileManager.default.createFile(atPath: Self.dataFileUrl.path, contents: encoded, attributes: nil)
            
            print("📁 \(T.self) object stored to \(Self.dataFileUrl) 📁") // INFOlog
        } else {
            print("⚠️ Error during encoding ⚠️") // INFOlog
        }
    }
    
    static func retrieve<T: Decodable>(as type: T.Type) -> T? {
        // get encoded data from file, then decode data and return it
        if let encoded = FileManager.default.contents(atPath: Self.dataFileUrl.path),
           let res = try? Self.decoder.decode(type, from: encoded) {
            
            print("📁 \(T.self) object retrieved from \(Self.dataFileUrl) 📁") // INFOlog
            
            return res
        } else {
            print("⚠️ Error during decoding ⚠️") // INFOlog
            
            return nil
        }
    }
}
