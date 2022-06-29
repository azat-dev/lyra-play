//
//  KeyValueStore.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 29.06.22.
//

import Foundation

public protocol KeyValueStore {
    
    func get<T: Codable>(key: String, as: T.Type) async -> Result<T?, Error>
    
    func put<T: Codable>(key: String, value: T) async -> Result<Void, Error>
    
    func delete(key: String) async -> Result<Void, Error>
    
    func listKeys() async -> Result<[String], Error>
}
