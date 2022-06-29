//
//  UserDefaultsKeyValueStoreTests.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 29.06.22.
//

import Foundation
import LyraPlay
import XCTest


class UserDefaultsKeyValueStoreTests: XCTestCase {

    private var keyValueStore: KeyValueStore!

    private func deleteAllKeys() async {
        let store1 = UserDefaultsKeyValueStore(storeName: "test1")
        let store2 = UserDefaultsKeyValueStore(storeName: "test2")
        
        await store1.deleteAll()
        await store2.deleteAll()
    }
    
    override func setUp() async throws {
        await deleteAllKeys()
    }
    
    override func tearDown() async throws {
        await deleteAllKeys()
    }
    
    func testPutGet() async {
        
        let keyValueStore1 = UserDefaultsKeyValueStore(storeName: "test1")
        let keyValueStore2 = UserDefaultsKeyValueStore(storeName: "test2")
        
        let testStruct = TestStruct(a: "test", b: 1)
        let testNumber = 1
        let testNumber2 = 2
        let testText = "123"
        
        await keyValueStore1.put(key: "1", value: testStruct)
        await keyValueStore2.put(key: "1", value: testNumber2)
        await keyValueStore1.put(key: "2", value: testNumber)
        await keyValueStore1.put(key: "3", value: testText)
        
        let resultReceivedValue1 = await keyValueStore1.get(key: "1", as: TestStruct.self)
        let receivedValue1 = AssertResultSucceded(resultReceivedValue1)
        XCTAssertNotNil(receivedValue1)
        XCTAssertEqual(receivedValue1, testStruct)
        
        let resultReceivedValue2 = await keyValueStore1.get(key: "2", as: Int.self)
        let receivedValue2 = AssertResultSucceded(resultReceivedValue2)
        XCTAssertEqual(receivedValue2, testNumber)
        
        let resultReceivedValue3 = await keyValueStore1.get(key: "3", as: String.self)
        let receivedValue3 = AssertResultSucceded(resultReceivedValue3)
        XCTAssertEqual(receivedValue3, testText)
        
        let resultReceivedValue22 = await keyValueStore2.get(key: "1", as: Int.self)
        let receivedValue22 = AssertResultSucceded(resultReceivedValue22)
        XCTAssertEqual(receivedValue22, testNumber2)
    }
    
    func testGetNotExisitingKey() async {
     
        let keyValueStore = UserDefaultsKeyValueStore(storeName: "test1")
        
        let resultReceivedValue = await keyValueStore.get(key: "1", as: Int.self)
        let receivedValue = AssertResultSucceded(resultReceivedValue)
        XCTAssertNil(receivedValue)
    }
    
    func testUpdateKey() async {
        
        let keyValueStore1 = UserDefaultsKeyValueStore(storeName: "test1")
        let keyValueStore2 = UserDefaultsKeyValueStore(storeName: "test2")
        
        let testNumber1 = 1
        let testNumber1Updated = 3
        
        let testNumber2 = 2
        
        let testNumber22 = 5
        
        await keyValueStore2.put(key: "1", value: testNumber22)
        await keyValueStore1.put(key: "1", value: testNumber1)
        await keyValueStore1.put(key: "2", value: testNumber2)
        await keyValueStore1.put(key: "1", value: testNumber1Updated)
        

        let resultReceivedValue1 = await keyValueStore1.get(key: "1", as: Int.self)
        let receivedValue1 = AssertResultSucceded(resultReceivedValue1)
        XCTAssertEqual(receivedValue1, testNumber1Updated)
        
        let resultReceivedValue2 = await keyValueStore1.get(key: "2", as: Int.self)
        let receivedValue2 = AssertResultSucceded(resultReceivedValue2)
        XCTAssertEqual(receivedValue2, testNumber2)
        
        let resultReceivedValue22 = await keyValueStore2.get(key: "1", as: Int.self)
        let receivedValue22 = AssertResultSucceded(resultReceivedValue22)
        XCTAssertEqual(receivedValue22, testNumber22)
    }
    
    func testListKeys() async {
        
        let keyValueStore1 = UserDefaultsKeyValueStore(storeName: "test1")
        let keyValueStore2 = UserDefaultsKeyValueStore(storeName: "test2")
        
        let testNumber1 = 1
        let testNumber2 = 2
        
        await keyValueStore1.put(key: "1", value: testNumber1)
        await keyValueStore1.put(key: "2", value: testNumber2)
        
        await keyValueStore1.put(key: "1", value: testNumber1)
        await keyValueStore1.put(key: "2", value: testNumber2)
        
        await keyValueStore2.put(key: "1", value: testNumber1)
     
        let result = await keyValueStore1.listKeys()
        let keys1 = AssertResultSucceded(result)
        
        XCTAssertEqual(keys1.sorted(), ["1", "2"].sorted())
        
        let result2 = await keyValueStore2.listKeys()
        let keys2 = AssertResultSucceded(result2)
        
        XCTAssertEqual(keys2.sorted(), ["1"].sorted())
    }
    
    func testDeleteKey() async {
        
        let keyValueStore1 = UserDefaultsKeyValueStore(storeName: "test1")
        let keyValueStore2 = UserDefaultsKeyValueStore(storeName: "test2")
        
        let testNumber1 = 1
        let testNumber2 = 2
        
        await keyValueStore1.put(key: "1", value: testNumber1)
        await keyValueStore1.put(key: "2", value: testNumber2)
        
        await keyValueStore2.put(key: "1", value: testNumber1)
        
        let resultDelete = await keyValueStore1.delete(key: "1")
        AssertResultSucceded(resultDelete)
        
        let result = await keyValueStore1.listKeys()
        let keys = AssertResultSucceded(result)
        
        XCTAssertEqual(keys, ["2"])
        
        let result2 = await keyValueStore2.listKeys()
        let keys2 = AssertResultSucceded(result2)
        
        XCTAssertEqual(keys2, ["1"])
    }
    
    func testDeleteAll() async {
        
        let keyValueStore1 = UserDefaultsKeyValueStore(storeName: "test1")
        let keyValueStore2 = UserDefaultsKeyValueStore(storeName: "test2")
        
        let testNumber1 = 1
        let testNumber2 = 2
        
        await keyValueStore1.put(key: "1", value: testNumber1)
        await keyValueStore1.put(key: "2", value: testNumber2)
        
        await keyValueStore2.put(key: "1", value: testNumber1)
        
        let resultDelete = await keyValueStore1.deleteAll()
        AssertResultSucceded(resultDelete)
        
        let result = await keyValueStore1.listKeys()
        let keys = AssertResultSucceded(result)
        
        XCTAssertEqual(keys, [])
        
        let result2 = await keyValueStore2.listKeys()
        let keys2 = AssertResultSucceded(result2)
        
        XCTAssertEqual(keys2, ["1"])
    }
}

fileprivate struct TestStruct: Codable, Equatable {

    var a: String
    var b: Int
}
