//
//  LocalAudioFilesRepositoryTests.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 24.06.22.
//

import XCTest
@testable import LyraPlay
import CoreData


extension AudioFileInfo: Equatable {
    
    public static func==(lhs: AudioFileInfo, rhs: AudioFileInfo) -> Bool {
        return lhs.id == rhs.id &&
            lhs.genre == rhs.genre &&
            lhs.artist == rhs.artist &&
            lhs.name == rhs.name &&
            lhs.updatedAt == rhs.updatedAt &&
            lhs.createdAt == rhs.createdAt
    }
}

extension AudioFileInfo: Comparable {
    
    public static func < (lhs: AudioFileInfo, rhs: AudioFileInfo) -> Bool {
        
        if (lhs.id?.uuidString ?? "") < (rhs.id?.uuidString ?? "") ||
            lhs.name < rhs.name {
            return true
        }
        
        return false
    }
}

class CoreDataAudioLibraryRepositoryTests: XCTestCase {
    
    func createSUT(file: StaticString = #filePath, line: UInt = #line) -> AudioLibraryRepository{

        let storeURL = URL(fileURLWithPath: "/dev/null")
        let coreDataStore = try! CoreDataStore(storeURL: storeURL)
        let library = CoreDataAudioLibraryRepository(coreDataStore: coreDataStore)
        
        detectMemoryLeak(instance: library, file: file, line: line)
        return library
    }

    @discardableResult
    private func putAndCheckFile(library: AudioLibraryRepository, fileInfo: AudioFileInfo, data fileData: Data) async throws -> AudioFileInfo?  {
        
        let putResult = await library.putFile(info: fileInfo)

        let savedFileInfo = try AssertResultSucceded(putResult)
        XCTAssertNotNil(savedFileInfo.id)
        
        var expectedFileInfo = fileInfo
        expectedFileInfo.id = savedFileInfo.id
        expectedFileInfo.updatedAt = savedFileInfo.updatedAt
        expectedFileInfo.createdAt = savedFileInfo.createdAt
        
        XCTAssertEqual(savedFileInfo, expectedFileInfo)
        return savedFileInfo
    }
    
    func testCreateNewRecordEmptyList() async throws {
        
        let library = createSUT()
        
        let fileInfo = AudioFileInfo(
            id: nil,
            createdAt: nil,
            updatedAt: nil,
            name: "Name1",
            duration: 10,
            audioFile: "test1.mp3",
            artist: "Artist1",
            genre: "Genre1"
        )
        let fileData = "data".data(using: .utf8)!
        
        let savedFile = try await putAndCheckFile(library: library, fileInfo: fileInfo, data: fileData)
        
        XCTAssertNotNil(savedFile)
        XCTAssertNotNil(savedFile?.createdAt)
        XCTAssertNil(savedFile?.updatedAt)
        
    }
    
    func testCreateNewRecordNotEmptyList() async throws {

        let library = createSUT()
        
        let fileInfo1 = AudioFileInfo(
            id: nil,
            createdAt: nil,
            updatedAt: nil,
            name: "Name1",
            duration: 10,
            audioFile: "test1.mp3",
            artist: "Artist1",
            genre: "Genre1"
        )
        
        let fileData1 = "data1".data(using: .utf8)!
        let savedFile1 = try await putAndCheckFile(library: library,  fileInfo: fileInfo1, data: fileData1)
        
        let fileInfo2 = AudioFileInfo(
            id: nil,
            createdAt: .now,
            updatedAt: nil,
            name: "Name2",
            duration: 10,
            audioFile: "test2.mp3",
            artist: "Artist2",
            genre: "Genre2"
        )
        
        let fileData2 = "data2".data(using: .utf8)!
        let savedFile2 = try await putAndCheckFile(library: library,  fileInfo: fileInfo2, data: fileData2)

        XCTAssertNotEqual(savedFile1?.id, savedFile2?.id)
        XCTAssertNotEqual(savedFile1, savedFile2)
    }
    
    func testUpdateExistingRecord() async throws {
        
        let library = createSUT()
        
        let fileInfo1 = AudioFileInfo(
            id: nil,
            createdAt: nil,
            updatedAt: nil,
            name: "Name1",
            duration: 10,
            audioFile: "test1.mp3",
            artist: "Artist1",
            genre: "Genre1"
        )
        
        let fileData1 = "data1".data(using: .utf8)!
        let savedFile1 = try await putAndCheckFile(library: library,  fileInfo: fileInfo1, data: fileData1)
        
        var fileInfo2 = AudioFileInfo(
            id: savedFile1!.id,
            createdAt: savedFile1!.createdAt,
            updatedAt: savedFile1?.updatedAt,
            name: "Name2",
            duration: 10,
            audioFile: "test2.mp3",
            artist: "Artist2",
            genre: "Genre2"
        )
        
        let fileData2 = "data2".data(using: .utf8)!
        let savedFile2 = try await putAndCheckFile(library: library,  fileInfo: fileInfo2, data: fileData2)

        XCTAssertEqual(savedFile1?.id, savedFile2?.id)
        XCTAssertEqual(savedFile1?.createdAt, savedFile2?.createdAt)
        XCTAssertNotEqual(savedFile2?.updatedAt, fileInfo2.updatedAt)
        
        fileInfo2.updatedAt = savedFile2?.updatedAt
        XCTAssertEqual(savedFile2, fileInfo2)
    }
    
    func testUpdateNotExistingRecordEmptyList() async throws {
        
        let library = createSUT()

        let fileInfo1 = AudioFileInfo(
            id: UUID(),
            createdAt: nil,
            updatedAt: nil,
            name: "Name1",
            duration: 10,
            audioFile: "test.mp3",
            artist: "Artist1",
            genre: "Genre1"
        )
        
        let result = await library.putFile(info: fileInfo1)
        let error = try AssertResultFailed(result)
        
        guard case .fileNotFound = error else {
            XCTFail("Wrong error")
            return
        }
    }

    func testUpdateNotExistingRecordNotEmptyList() async throws {
        
        let library = createSUT()
        
        let fileInfo1 = AudioFileInfo(
            id: nil,
            createdAt: .now,
            updatedAt: nil,
            name: "Name1",
            duration: 10,
            audioFile: "test1.mp3",
            artist: "Artist1",
            genre: "Genre1"
        )
        
        let fileData1 = "data1".data(using: .utf8)!
        try await putAndCheckFile(library: library, fileInfo: fileInfo1, data: fileData1)
        
        let fileInfo2 = AudioFileInfo(
            id: UUID(),
            createdAt: .now,
            updatedAt: nil,
            name: "Name2",
            duration: 10,
            audioFile: "test2.mp3",
            artist: "Artist2",
            genre: "Genre2"
        )
        
        
        let putResult = await library.putFile(info: fileInfo2)
        let putError = try AssertResultFailed(putResult)
    
        guard case .fileNotFound = putError else {
            XCTFail("Wrong error")
            return
        }
    }
    
    func testGetRecordEmptyList() async throws {
        
        let library = createSUT()
        
        let fileId = UUID()
        let result = await library.getInfo(fileId: fileId)
        let error = try AssertResultFailed(result)
        
        guard case .fileNotFound = error else {
            XCTFail("Wrong error")
            return
        }
    }
    
    func testGetRecordNotEmptyList() async throws {
        
        let library = createSUT()
        
        let fileInfo1 = AudioFileInfo(
            id: nil,
            createdAt: .now,
            updatedAt: nil,
            name: "Name1",
            duration: 10,
            audioFile: "test1.mp3",
            artist: "Artist1",
            genre: "Genre1"
        )
        
        let fileData1 = "data1".data(using: .utf8)!
        let savedFile1 = try await putAndCheckFile(library: library,  fileInfo: fileInfo1, data: fileData1)
        
        let fileInfo2 = AudioFileInfo(
            id: nil,
            createdAt: .now,
            updatedAt: nil,
            name: "Name2",
            duration: 10,
            audioFile: "test2.mp3",
            artist: "Artist2",
            genre: "Genre2"
        )
        
        let fileData2 = "data1".data(using: .utf8)!
        try await putAndCheckFile(library: library,  fileInfo: fileInfo2, data: fileData2)
        
        let fileId = savedFile1!.id!
        let result = await library.getInfo(fileId: fileId)
        
        let receivedFileInfo1 = try AssertResultSucceded(result, "File does' not exists")
        XCTAssertEqual(savedFile1, receivedFileInfo1)
    }
    
    func testListFilesEmptyList() async throws {
        
        let library = createSUT()
        let result = await library.listFiles()
        let files = try AssertResultSucceded(result)
        
        XCTAssertTrue(files.isEmpty)
    }
    
    func test_list_files_not_empty_list() async throws {
        
        let library = createSUT()
        
        var fileInfo1 = AudioFileInfo(
            id: nil,
            createdAt: .now,
            updatedAt: nil,
            name: "Name1",
            duration: 10,
            audioFile: "test1.mp3",
            artist: "Artist1",
            genre: "Genre1"
        )
        
        let fileData1 = "data1".data(using: .utf8)!
        let savedFile1 = try await putAndCheckFile(library: library,  fileInfo: fileInfo1, data: fileData1)
        
        var fileInfo2 = AudioFileInfo(
            id: nil,
            createdAt: .now,
            updatedAt: nil,
            name: "Name2",
            duration: 10,
            audioFile: "test2.mp3",
            artist: "Artist2",
            genre: "Genre2"
        )
        
        let fileData2 = "data2".data(using: .utf8)!
        let savedFile2 = try await putAndCheckFile(library: library,  fileInfo: fileInfo2, data: fileData2)
        
        let result = await library.listFiles()
        let files = try AssertResultSucceded(result)
        
        fileInfo1.id = savedFile1?.id
        fileInfo2.id = savedFile2?.id
        
        let expectedFiles = [
            savedFile1!,
            savedFile2!
        ]
        
        XCTAssertEqual(files.sorted(), expectedFiles.sorted())
    }
    
    func test_delete_record_empty_list() async throws {
        
        let library = createSUT()
        
        let fileId = UUID()
        let result = await library.delete(fileId: fileId)
        
        let error = try AssertResultFailed(result)
        guard case .fileNotFound = error else {
            XCTFail("Wrong error")
            return
        }
    }
    
    func test_delete_record_not_empty_list() async throws {
        
        let library = createSUT()
        
        let fileInfo1 = AudioFileInfo(
            id: nil,
            createdAt: .now,
            updatedAt: nil,
            name: "Name1",
            duration: 10,
            audioFile: "test.mp3",
            artist: "Artist1",
            genre: "Genre1"
        )
        
        let fileData1 = "data1".data(using: .utf8)!
        let savedFile1 = try await putAndCheckFile(library: library,  fileInfo: fileInfo1, data: fileData1)
        
        let result = await library.delete(fileId: savedFile1!.id!)
        try AssertResultSucceded(result)
    }    
}
