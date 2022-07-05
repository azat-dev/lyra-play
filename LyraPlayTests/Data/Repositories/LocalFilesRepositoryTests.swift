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

    private var baseDirectory = FileManager.default.temporaryDirectory.appendingPathComponent("test", isDirectory: true)
    
    func createSUT() -> FilesRepository {
        
        let filesRepository = try! LocalFilesRepository(baseDirectory: baseDirectory)
        detectMemoryLeak(instance: filesRepository)
        return filesRepository
    }
    
    override func tearDown() {
        try? FileManager.default.removeItem(at: baseDirectory)
    }

    func testPutGetFile() async throws {
        
        let filesRepository = createSUT()
        
        let file1 = "file1".data(using: .utf8)!
        let file2 = "file2".data(using: .utf8)!
        let updatedFile1 = "file1-updated".data(using: .utf8)!
        
        let result1 = await filesRepository.putFile(name: "file1.txt", data: file1)
        try AssertResultSucceded(result1)

        let result2 = await filesRepository.putFile(name: "file2.txt", data: file2)
        try AssertResultSucceded(result2)

        let receivedFile1Result = await filesRepository.getFile(name: "file1.txt")
        let receivedFile1 = try AssertResultSucceded(receivedFile1Result)
        
        XCTAssertEqual(receivedFile1, file1)
        
        let receivedFile2Result = await filesRepository.getFile(name: "file2.txt")
        let receivedFile2 = try AssertResultSucceded(receivedFile2Result)

        XCTAssertEqual(receivedFile2, file2)

        let resultUpdateFile = await filesRepository.putFile(name: "file1.txt", data: updatedFile1)
        try AssertResultSucceded(resultUpdateFile)

        let receivedUpdatedFileResult = await filesRepository.getFile(name: "file1.txt")
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
}
