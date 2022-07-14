//
//  LocalFilesRepositoryTests.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 28.06.22.
//


import Foundation
import LyraPlay
import XCTest


class LocalFilesRepositoryTests: XCTestCase {
    
    func createSUT(baseDirectoryName: String = UUID().uuidString) -> FilesRepository {
        
        let baseDirectory = FileManager.default.temporaryDirectory.appendingPathComponent(baseDirectoryName, isDirectory: true)
        
        let filesRepository = try! LocalFilesRepository(baseDirectory: baseDirectory)
        detectMemoryLeak(instance: filesRepository)
        return filesRepository
    }
    
    override func tearDown() {
        
        let fileURLs = try! FileManager.default.contentsOfDirectory(
            at: FileManager.default.temporaryDirectory,
            includingPropertiesForKeys: nil,
            options: .skipsHiddenFiles
        )
        
        for fileURL in fileURLs {
            try! FileManager.default.removeItem(at: fileURL)
        }
    }
    
    func testPutGetFile() async throws {
        
        let sut1 = createSUT()
        
        let file1 = "file1".data(using: .utf8)!
        let file2 = "file2".data(using: .utf8)!
        let updatedFile1 = "file1-updated".data(using: .utf8)!
        
        let result1 = await sut1.putFile(name: "file1.txt", data: file1)
        try AssertResultSucceded(result1)
        
        let result2 = await sut1.putFile(name: "file2.txt", data: file2)
        try AssertResultSucceded(result2)
        
        let receivedFile1Result = await sut1.getFile(name: "file1.txt")
        let receivedFile1 = try AssertResultSucceded(receivedFile1Result)
        
        XCTAssertEqual(receivedFile1, file1)
        
        let receivedFile2Result = await sut1.getFile(name: "file2.txt")
        let receivedFile2 = try AssertResultSucceded(receivedFile2Result)
        
        XCTAssertEqual(receivedFile2, file2)
        
        let resultUpdateFile = await sut1.putFile(name: "file1.txt", data: updatedFile1)
        try AssertResultSucceded(resultUpdateFile)
        
        let receivedUpdatedFileResult = await sut1.getFile(name: "file1.txt")
        let receivedUpdatedFile1 = try AssertResultSucceded(receivedUpdatedFileResult)
        
        XCTAssertEqual(receivedUpdatedFile1, updatedFile1)
    }
    
    func testDeleteFile() async throws {
        
        let filesRepository = createSUT()
        
        let file1 = "file1".data(using: .utf8)!
        let file2 = "file2".data(using: .utf8)!
        
        let result1 = await filesRepository.putFile(name: "file1.txt", data: file1)
        try AssertResultSucceded(result1)
        
        let result2 = await filesRepository.putFile(name: "file2.txt", data: file2)
        try AssertResultSucceded(result2)
        
        let deleteResult = await filesRepository.deleteFile(name: "file1.txt")
        try AssertResultSucceded(deleteResult)
        
        let receivedFile1Result = await filesRepository.getFile(name: "file1.txt")
        let receiveFile1Error = try AssertResultFailed(receivedFile1Result)
        
        guard case .fileNotFound = receiveFile1Error else {
            XCTFail("Wrong error")
            return
        }
        
        let receivedFile2Result = await filesRepository.getFile(name: "file2.txt")
        let receivedFile2 = try AssertResultSucceded(receivedFile2Result)
        
        XCTAssertEqual(receivedFile2, file2)
    }
    
    func testDeleteNotExistingFile() async throws {
        
        let filesRepository = createSUT()
        
        let deletionResult = await filesRepository.deleteFile(name: "file1.txt")
        
        let error = try AssertResultFailed(deletionResult)
        
        guard case .fileNotFound = error else {
            XCTFail("Wrong error")
            return
        }
    }
    
    func testPutGetSeparationByBaseDirectories() async throws {
        
        let sut1 = createSUT()
        let sut2 = createSUT()
        
        let testFileName = "test.txt"
        
        let testData1 = "test1".data(using: .utf8)!
        let testData2 = "test2".data(using: .utf8)!
        
        let _ = await sut1.putFile(name: testFileName, data: testData1)
        let _ = await sut2.putFile(name: testFileName, data: testData2)
        
        let getResult1 = await sut1.getFile(name: testFileName)
        let data1 = try AssertResultSucceded(getResult1)
        
        XCTAssertEqual(data1, testData1)
        
        let getResult2 = await sut2.getFile(name: testFileName)
        let data2 = try AssertResultSucceded(getResult2)
        
        XCTAssertEqual(data2, testData1)
    }
    
    func testDeleteSeparationByBaseDirectories() async throws {
        
        let sut1 = createSUT()
        let sut2 = createSUT()
        
        let testFileName = "test.txt"
        
        let testData1 = "test1".data(using: .utf8)!
        let testData2 = "test2".data(using: .utf8)!
        
        let _ = await sut1.putFile(name: testFileName, data: testData1)
        let _ = await sut2.putFile(name: testFileName, data: testData2)
        
        let _ = await sut1.deleteFile(name: testFileName)
        
        let getResult1 = await sut1.getFile(name: testFileName)
        let error = try AssertResultFailed(getResult1)
        
        guard case .fileNotFound = error else {
            XCTFail("Wrong error \(error)")
            return
        }
        
        let getResult2 = await sut2.getFile(name: testFileName)
        let data2 = try AssertResultSucceded(getResult2)
        
        XCTAssertEqual(data2, testData1)
    }
}
