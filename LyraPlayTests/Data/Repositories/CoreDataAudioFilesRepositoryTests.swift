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

class CoreDataAudioFilesRepositoryTests: XCTestCase {
    
    var repository: AudioFilesRepository!
    
    override func setUpWithError() throws {
        let storeBundle = Bundle(for: CoreDataAudioFilesRepositoryTests.self)
        let storeURL = URL(fileURLWithPath: "/dev/null")
        
        let coreDataStore = try! CoreDataStore(storeURL: storeURL)
        repository = CoreDataAudioFilesRepository(coreDataStore: coreDataStore)
    }

    private func putAndCheckFile(fileInfo: AudioFileInfo, data fileData: Data) async -> AudioFileInfo?  {
        
        let putResult = await repository.putFile(info: fileInfo, data: fileData)
        
        if case .failure(let error) = putResult {
            XCTAssertFalse(true, "Can't put the file: \(error)")
            return nil
        }
        
        guard case .success(let savedFileInfo) = putResult else {
            XCTAssertFalse(true, "Can't put the file")
            return nil
        }
        
        XCTAssertNotNil(savedFileInfo.id)
        
        var expectedFileInfo = fileInfo
        expectedFileInfo.id = savedFileInfo.id
        expectedFileInfo.updatedAt = savedFileInfo.updatedAt
        expectedFileInfo.createdAt = savedFileInfo.createdAt
        
        XCTAssertEqual(savedFileInfo, expectedFileInfo)
        return savedFileInfo
    }
    
    func testCreateNewRecordEmptyList() async {
        
        let fileInfo = AudioFileInfo(
            id: nil,
            createdAt: .now,
            updatedAt: nil,
            name: "Name1",
            artist: "Artist1",
            genre: "Genre1"
        )
        let fileData = "data".data(using: .utf8)!
        
        await putAndCheckFile(fileInfo: fileInfo, data: fileData)
    }
    
    func testCreateNewRecordNotEmptyList() async {

        let fileInfo1 = AudioFileInfo(
            id: nil,
            createdAt: .now,
            updatedAt: nil,
            name: "Name1",
            artist: "Artist1",
            genre: "Genre1"
        )
        
        let fileData1 = "data1".data(using: .utf8)!
        let savedFile1 = await putAndCheckFile(fileInfo: fileInfo1, data: fileData1)
        
        let fileInfo2 = AudioFileInfo(
            id: nil,
            createdAt: .now,
            updatedAt: nil,
            name: "Name2",
            artist: "Artist2",
            genre: "Genre2"
        )
        
        let fileData2 = "data2".data(using: .utf8)!
        let savedFile2 = await putAndCheckFile(fileInfo: fileInfo2, data: fileData2)

        XCTAssertNotEqual(savedFile1?.id, savedFile2?.id)
        XCTAssertNotEqual(savedFile1, savedFile2)
    }
    
    func testUpdateExistingRecord() async {
        
        let fileInfo1 = AudioFileInfo(
            id: nil,
            createdAt: .now,
            updatedAt: nil,
            name: "Name1",
            artist: "Artist1",
            genre: "Genre1"
        )
        
        let fileData1 = "data1".data(using: .utf8)!
        let savedFile1 = await putAndCheckFile(fileInfo: fileInfo1, data: fileData1)
        
        var fileInfo2 = AudioFileInfo(
            id: savedFile1!.id,
            createdAt: savedFile1!.createdAt,
            updatedAt: savedFile1?.updatedAt,
            name: "Name2",
            artist: "Artist2",
            genre: "Genre2"
        )
        
        let fileData2 = "data2".data(using: .utf8)!
        let savedFile2 = await putAndCheckFile(fileInfo: fileInfo2, data: fileData2)

        XCTAssertEqual(savedFile1?.id, savedFile2?.id)
        XCTAssertEqual(savedFile1?.createdAt, savedFile2?.createdAt)
        XCTAssertNotEqual(savedFile2?.updatedAt!, fileInfo2.updatedAt!)
        
        fileInfo2.updatedAt = savedFile2?.updatedAt
        XCTAssertEqual(savedFile2, fileInfo2)
    }
    
    func testUpdateNotExistingRecordEmptyList() async {

        let fileInfo1 = AudioFileInfo(
            id: UUID(),
            createdAt: .now,
            updatedAt: nil,
            name: "Name1",
            artist: "Artist1",
            genre: "Genre1"
        )
        
        let fileData1 = "data1".data(using: .utf8)!
        let result = await repository.putFile(info: fileInfo1, data: fileData1)
        
        XCTAssertEqual(result, Result.failure(AudioFilesRepositoryError.fileNotFound))
    }

    func testUpdateNotExistingRecordNotEmptyList() async {
        
        let fileInfo1 = AudioFileInfo(
            id: nil,
            createdAt: .now,
            updatedAt: nil,
            name: "Name1",
            artist: "Artist1",
            genre: "Genre1"
        )
        
        let fileData1 = "data1".data(using: .utf8)!
        let savedFile1 = await putAndCheckFile(fileInfo: fileInfo1, data: fileData1)
        
        let fileInfo2 = AudioFileInfo(
            id: UUID(),
            createdAt: .now,
            updatedAt: nil,
            name: "Name2",
            artist: "Artist2",
            genre: "Genre2"
        )
        
        let fileData2 = "data2".data(using: .utf8)!
        
        let putResult = await repository.putFile(info: fileInfo2, data: fileData2)
        
        guard case .failure(let error) = putResult else {
            XCTAssertFalse(true, "Put must fail")
            return
        }
        
        
        XCTAssertEqual(error, .fileNotFound)
    }
    
    func testGetRecordEmptyList() async {
        
        let fileId = UUID()
        let result = await repository.getInfo(fileId: fileId)
        
        guard case .failure(let error) = result else {
            XCTAssertFalse(true, "File exists")
            return
        }
        
        XCTAssertEqual(error, .fileNotFound)
    }
    
    func testGetRecordNotEmptyList() async {
        
        let fileInfo1 = AudioFileInfo(
            id: nil,
            createdAt: .now,
            updatedAt: nil,
            name: "Name1",
            artist: "Artist1",
            genre: "Genre1"
        )
        
        let fileData1 = "data1".data(using: .utf8)!
        let savedFile1 = await putAndCheckFile(fileInfo: fileInfo1, data: fileData1)
        
        let fileInfo2 = AudioFileInfo(
            id: nil,
            createdAt: .now,
            updatedAt: nil,
            name: "Name2",
            artist: "Artist2",
            genre: "Genre2"
        )
        
        let fileData2 = "data1".data(using: .utf8)!
        let savedFile2 = await putAndCheckFile(fileInfo: fileInfo2, data: fileData2)
        
        let fileId = savedFile1!.id!
        let result = await repository.getInfo(fileId: fileId)
        
        guard case .success(let receivedFileInfo1) = result else {
            XCTAssertFalse(true, "File does not exist")
            return
        }
        
        XCTAssertEqual(savedFile1, receivedFileInfo1)
    }
    
    func testListFilesEmptyList() async {
        
        let result = await repository.listFiles()
        
        guard case .success(let files) = result else {
            XCTAssertFalse(true, "List files error")
            return
        }
        
        XCTAssertTrue(files.isEmpty)
    }
    
    func test_list_files_not_empty_list() async {
        
        var fileInfo1 = AudioFileInfo(
            id: nil,
            createdAt: .now,
            updatedAt: nil,
            name: "Name1",
            artist: "Artist1",
            genre: "Genre1"
        )
        
        let fileData1 = "data1".data(using: .utf8)!
        let savedFile1 = await putAndCheckFile(fileInfo: fileInfo1, data: fileData1)
        
        var fileInfo2 = AudioFileInfo(
            id: nil,
            createdAt: .now,
            updatedAt: nil,
            name: "Name2",
            artist: "Artist2",
            genre: "Genre2"
        )
        
        let fileData2 = "data2".data(using: .utf8)!
        let savedFile2 = await putAndCheckFile(fileInfo: fileInfo2, data: fileData2)
        
        let result = await repository.listFiles()
        
        guard case .success(let files) = result else {
            XCTAssertFalse(true, "List files error")
            return
        }
        
        fileInfo1.id = savedFile1?.id
        fileInfo2.id = savedFile2?.id
        
        var expectedFiles = [
            savedFile1!,
            savedFile2!
        ]
        
        XCTAssertEqual(files.sorted(), expectedFiles.sorted())
    }
    
    func test_delete_record_empty_list() async {
        
        let fileId = UUID()
        let result = await repository.delete(fileId: fileId)
        
        guard case .failure(let error) = result else {
            XCTAssertFalse(true, "File exists")
            return
        }
        
        XCTAssertEqual(error, .fileNotFound)
    }
    
    func test_delete_record_not_empty_list() async {
        
        let fileInfo1 = AudioFileInfo(
            id: nil,
            createdAt: .now,
            updatedAt: nil,
            name: "Name1",
            artist: "Artist1",
            genre: "Genre1"
        )
        
        let fileData1 = "data1".data(using: .utf8)!
        let savedFile1 = await putAndCheckFile(fileInfo: fileInfo1, data: fileData1)
        
        let result = await repository.delete(fileId: savedFile1!.id!)
        
        guard case .success(_) = result else {
            XCTAssertFalse(true, "File does not exist")
            return
        }
    }    
}
