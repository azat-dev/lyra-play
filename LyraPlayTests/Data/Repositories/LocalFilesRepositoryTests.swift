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
    
    override func setUp() async throws {
        
        let directory = URL()
        filesRepository = LocalFilesRepository(directory: directory)
    }
    
    func testPutGetFile() async {
        
        let file1 = "file1".data(using: .utf8)!
        let file2 = "file2".data(using: .utf8)!
        
        let result1 = await filesRepository.put(file: file1)
        let url1 = XCTAssertNoThrow {
            result1.get()
        }
        
        let result2 = await filesRepository.putFile()
        let url2 = XCTAssertNoThrow {
            result1.get()
        }
        
        let receivedFileResult = await filesRepository.getFile(url1)
        
        let receivedFile1 = XCTAssertNoThrow {
            receivedFileResult.get()
        }
        
        XCTAssertEqual(receivedFile1, file1)
    }
    
    func testDeleteFile() async {
        
        let file1 = "file1".data(using: .utf8)!
        let file2 = "file2".data(using: .utf8)!
        
        let result1 = await filesRepository.put(file: file1)
        let url1 = XCTAssertNoThrow {
            result1.get()
        }
        
        let result2 = await filesRepository.putFile()
        let url2 = XCTAssertNoThrow {
            result1.get()
        }
        
        let deletionResult = await filesRepository.deleteFile(url1)
        
        let receivedFile1 = XCTAssertNoThrow {
            deletionResult.get()
        }
    }
}
