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
    
    override func setUp() async throws {

        keyValueStore = UserDefaultsKeyValueStore(prefix: "test")
    }

    override func tearDown() async throws {
        
        let keysResult = await keyValueStore.listKeys()
        let keys = AssertResultSucceded(keysResult)
        
        for key in keys {
            await keyValueStore.delete(key: key)
        }
    }
    
    func testPutGet() async {
        
        let testStruct = TestStruct(a: "test", b: 1)
        let testNumber = 1
        let testText = "123"
        
        await keyValueStore.put(key: "1", value: testStruct)
        await keyValueStore.put(key: "2", value: testNumber)
        await keyValueStore.put(key: "3", value: testText)
        
        let resultReceivedValue1 = await keyValueStore.get(key: "1", as: TestStruct.self)
        let receivedValue1 = AssertResultSucceded(resultReceivedValue1)
        XCTAssertNotNil(receivedValue1)
        XCTAssertEqual(receivedValue1, testStruct)
        
        let resultReceivedValue2 = await keyValueStore.get(key: "2", as: Int.self)
        let receivedValue2 = AssertResultSucceded(resultReceivedValue2)
        XCTAssertEqual(receivedValue2, testNumber)
        
        let resultReceivedValue3 = await keyValueStore.get(key: "3", as: String.self)
        let receivedValue3 = AssertResultSucceded(resultReceivedValue3)
        XCTAssertEqual(receivedValue3, testText)
    }
    
    func testGetNotExisitingKey() async {
     
        let resultReceivedValue = await keyValueStore.get(key: "1", as: Int.self)
        let receivedValue = AssertResultSucceded(resultReceivedValue)
        XCTAssertNil(receivedValue)
    }
    
    func testUpdateKey() async {
        
        let testNumber1 = 1
        let testNumber1Updated = 3
        
        let testNumber2 = 2
        
        await keyValueStore.put(key: "1", value: testNumber1)
        await keyValueStore.put(key: "2", value: testNumber2)
        await keyValueStore.put(key: "1", value: testNumber1Updated)

        let resultReceivedValue1 = await keyValueStore.get(key: "1", as: Int.self)
        let receivedValue1 = AssertResultSucceded(resultReceivedValue1)
        XCTAssertEqual(receivedValue1, testNumber1Updated)
        
        let resultReceivedValue2 = await keyValueStore.get(key: "2", as: Int.self)
        let receivedValue2 = AssertResultSucceded(resultReceivedValue2)
        XCTAssertEqual(receivedValue2, testNumber2)
    }
    
    func testListKeys() async {
        
        let testNumber1 = 1
        let testNumber2 = 2
        
        await keyValueStore.put(key: "1", value: testNumber1)
        await keyValueStore.put(key: "2", value: testNumber2)
        
        await keyValueStore.put(key: "1", value: testNumber1)
        await keyValueStore.put(key: "2", value: testNumber2)
     
        let result = await keyValueStore.listKeys()
        let keys = AssertResultSucceded(result)
        
        XCTAssertEqual(keys.sorted(), ["1", "2"].sorted())
    }
    
    func testDeleteKey() async {
        
        let testNumber1 = 1
        let testNumber2 = 2
        
        await keyValueStore.put(key: "1", value: testNumber1)
        await keyValueStore.put(key: "2", value: testNumber2)
        
        let resultDelete = await keyValueStore.delete(key: "1")
        AssertResultSucceded(resultDelete)
        
        let result = await keyValueStore.listKeys()
        let keys = AssertResultSucceded(result)
        
        XCTAssertEqual(keys, ["1"])
    }
}


fileprivate struct TestStruct: Codable, Equatable {

    var a: String
    var b: Int
}
