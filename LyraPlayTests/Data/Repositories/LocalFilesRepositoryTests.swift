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

    private var filesRepository: FilesRepository!
    private var baseDirectory: URL!
    
    override func setUp() async throws {
        
        baseDirectory = FileManager.default.temporaryDirectory.appendingPathComponent("test", isDirectory: true)
        filesRepository = try! LocalFilesRepository(baseDirectory: baseDirectory)
    }
    
    override func tearDown() {
        try? FileManager.default.removeItem(at: baseDirectory)
    }

    func testPutGetFile() async {
        
        let file1 = "file1".data(using: .utf8)!
        let file2 = "file2".data(using: .utf8)!
        let updatedFile1 = "file1-updated".data(using: .utf8)!
        
        let result1 = await filesRepository.putFile(name: "file1.txt", data: file1)
        AssertResultSucceded(result1)

        let result2 = await filesRepository.putFile(name: "file2.txt", data: file2)
        AssertResultSucceded(result2)

        let receivedFile1Result = await filesRepository.getFile(name: "file1.txt")
        let receivedFile1 = AssertResultSucceded(receivedFile1Result)
        
        XCTAssertEqual(receivedFile1, file1)
        
        let receivedFile2Result = await filesRepository.getFile(name: "file2.txt")
        let receivedFile2 = AssertResultSucceded(receivedFile2Result)

        XCTAssertEqual(receivedFile2, file2)

        let resultUpdateFile = await filesRepository.putFile(name: "file1.txt", data: updatedFile1)
        AssertResultSucceded(resultUpdateFile)

        let receivedUpdatedFileResult = await filesRepository.getFile(name: "file1.txt")
        let receivedUpdatedFile1 = AssertResultSucceded(receivedUpdatedFileResult)

        XCTAssertEqual(receivedUpdatedFile1, updatedFile1)
    }
    
    func testDeleteFile() async {
        
        let file1 = "file1".data(using: .utf8)!
        let file2 = "file2".data(using: .utf8)!
        
        let result1 = await filesRepository.putFile(name: "file1.txt", data: file1)
        AssertResultSucceded(result1)

        let result2 = await filesRepository.putFile(name: "file2.txt", data: file2)
        AssertResultSucceded(result2)

        let deleteResult = await filesRepository.deleteFile(name: "file1.txt")
        AssertResultSucceded(deleteResult)
        
        let receivedFile1Result = await filesRepository.getFile(name: "file1.txt")
        let receiveFile1Error = AssertResultFailed(receivedFile1Result)
        
        XCTAssertEqual(receiveFile1Error, .fileNotFound)
        
        let receivedFile2Result = await filesRepository.getFile(name: "file2.txt")
        let receivedFile2 = AssertResultSucceded(receivedFile2Result)

        XCTAssertEqual(receivedFile2, file2)
    }

    func testDeleteNotExistingFile() async {

        let deletionResult = await filesRepository.deleteFile(name: "file1.txt")

        let error = AssertResultFailed(deletionResult)
        XCTAssertEqual(error, .fileNotFound)
    }
}
