//
//  KeyValueStore.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 29.06.22.
//

import Foundation

// MARK: - Interfaces

public protocol KeyValueStore {
    
    func get<T: Codable>(key: String, as: T.Type) async -> Result<T?, Error>
    
    @discardableResult
    func put<T: Codable>(key: String, value: T) async -> Result<Void, Error>
    
    @discardableResult
    func delete(key: String) async -> Result<Void, Error>
    
    func listKeys() async -> Result<[String], Error>
    
    @discardableResult
    func deleteAll() async -> Result<Void, Error>
}

// MARK: - Implementations

public final class UserDefaultsKeyValueStore: KeyValueStore {
    
    private let storeName: String
    private let userDefaults: UserDefaults
    
    public init(storeName: String) {
        
        self.storeName = storeName
        self.userDefaults = UserDefaults.standard
    }
    
    private func getKeyWithPrefix(key: String) -> String {
        
        let encodedPrefix = storeName.addingPercentEncoding(withAllowedCharacters: .alphanumerics)!
        let encodedKey = key.addingPercentEncoding(withAllowedCharacters: .alphanumerics)!
        
        return "\(encodedPrefix)/\(encodedKey)"
    }
    
    private func getKeyWithoutPrefix(key: String) -> String? {
        
        let splitted = key.components(separatedBy: "/")
        
        guard splitted.count == 2 else {
            return nil
        }
        
        let encodedPrefix = splitted[0]
        
        let decodedPrefix = encodedPrefix.removingPercentEncoding
        
        guard decodedPrefix == storeName else {
            return nil
        }
        
        let encodedKey = splitted[1]
        
        return encodedKey.removingPercentEncoding
    }
    
    public func get<T: Codable>(key: String, as type: T.Type) async -> Result<T?, Error> {
        
        let keyWithPrefix = getKeyWithPrefix(key: key)
        let encodedValue = userDefaults.data(forKey: keyWithPrefix)
        
        guard let encodedValue = encodedValue else {
            return .success(nil)
        }
        
        let decoder = JSONDecoder()
        
        do {

            let decodedValue = try decoder.decode(type, from: encodedValue)
            return .success(decodedValue)
        } catch {
            return .failure(error)
        }
    }
    
    @discardableResult
    public func put<T: Codable>(key: String, value: T) async -> Result<Void, Error> {
        
        let keyWithPrefix = getKeyWithPrefix(key: key)
        let encoder = JSONEncoder()

        do {
            
            let encodedValue = try encoder.encode(value)
            userDefaults.set(encodedValue, forKey: keyWithPrefix)
            return .success(())
            
        } catch {
            return .failure(error)
        }
    }
    
    @discardableResult
    public func delete(key: String) async -> Result<Void, Error> {
        
        let keyWithPrefix = getKeyWithPrefix(key: key)
        userDefaults.removeObject(forKey: keyWithPrefix)
        
        return .success(())
    }
    
    public func listKeys() async -> Result<[String], Error> {
        
        let dictionary = userDefaults.dictionaryRepresentation()

        let keys = dictionary.keys.compactMap { getKeyWithoutPrefix(key: $0) }
        return .success(keys)
    }
    
    @discardableResult
    public func deleteAll() async -> Result<Void, Error> {
        
        let resultKeys = await listKeys()
        
        switch resultKeys {
        
        case .success(let keys):
            for key in keys {
                
                let result = await delete(key: key)
                if case .failure(let error) = result {
                    return .failure(error)
                }
            }
            
            return .success(())
            
        case .failure(let error):
            return .failure(error)
        }
    }
}
