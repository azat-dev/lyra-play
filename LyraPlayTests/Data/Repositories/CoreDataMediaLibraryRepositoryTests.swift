//
//  LocalAudioFilesRepositoryTests.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 24.06.22.
//

import XCTest
@testable import LyraPlay
import CoreData

class CoreDataMediaLibraryRepositoryTests: XCTestCase {
    
    func createSUT(file: StaticString = #filePath, line: UInt = #line) -> MediaLibraryRepository{

        let storeURL = URL(fileURLWithPath: "/dev/null")
        let coreDataStore = try! CoreDataStore(storeURL: storeURL)
        let library = CoreDataMediaLibraryRepository(coreDataStore: coreDataStore)
        
        detectMemoryLeak(instance: library, file: file, line: line)
        return library
    }

    @discardableResult
    private func putAndCheckFile(library: MediaLibraryRepository, fileInfo: MediaLibraryAudioFile, data fileData: Data) async throws -> MediaLibraryAudioFile?  {
        
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
        
        let sut = createSUT()
        
        let fileInfo = MediaLibraryAudioFile(
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
        
        let savedFile = try await putAndCheckFile(library: sut, fileInfo: fileInfo, data: fileData)
        
        XCTAssertNotNil(savedFile)
        XCTAssertNotNil(savedFile?.createdAt)
        XCTAssertNil(savedFile?.updatedAt)
        
    }
    
    private func anyNewFile(parentId: UUID? = nil) -> NewMediaLibraryFileData {
        
        return .init(
            parentId: parentId,
            title: "Title",
            subtitle: "Subtitle",
            file: "test.mp3",
            duration: 111,
            image: "test.png",
            genre: "genre"
        )
    }
    
    private func anyNewFolder(parentId: UUID? = nil) -> NewMediaLibraryFolderData {
        
        return .init(
            parentId: parentId,
            title: "Title",
            image: "test.png"
        )
    }
    
    func test_create_file__empty_list() async throws {
        
        let sut = createSUT()
        
        // Given
        
        let newFile = anyNewFile()
        
        // When
        let result = await sut.createFile(data: newFile)
        
        // Then
        let savedFile = try AssertResultSucceded(result)
        
        // Then
        let fetchResult = await sut.getItem(id: savedFile.id)
        let receivedItem = try AssertResultSucceded(fetchResult)
        
        AssertEqualReadable(.file(savedFile), receivedItem)
        
        guard case .file(let fetchedFile) = receivedItem else {
            XCTFail("Wrong library item type \(receivedItem)")
            return
        }
        
        XCTAssertEqual(fetchedFile.title, newFile.title)
        XCTAssertEqual(fetchedFile.subtitle, newFile.subtitle)
        XCTAssertEqual(fetchedFile.file, newFile.file)
        XCTAssertEqual(fetchedFile.duration, newFile.duration)
        XCTAssertEqual(fetchedFile.image, newFile.image)
        XCTAssertEqual(fetchedFile.duration, newFile.duration)
    }
    
    func test_create_file__with_existing_title() async throws {
        
        let sut = createSUT()
        
        // Given
        let newFile = anyNewFile()
        
        // When
        let _ = await sut.createFile(data: newFile)
        let result = await sut.createFile(data: newFile)
        
        // Then
        let error = try AssertResultFailed(result)
        
        guard case .nameMustBeUnique = error else {
            
            XCTFail("Wrong error type \(error)")
            return
        }
    }
    
    func test_create_file__with_not_existing_parent() async throws {
        
        let sut = createSUT()
        
        // Given
        let newFile = anyNewFile(parentId: UUID())
        
        // When
        let result = await sut.createFile(data: newFile)
        
        // Then
        let error = try AssertResultFailed(result)
        
        guard case .parentNotFound = error else {
            
            XCTFail("Wrong error type \(error)")
            return
        }
    }
    
    func test_create_folder__empty_list() async throws {
        
        let sut = createSUT()
        
        // Given
        
        let newFolder = anyNewFolder()
        
        // When
        let result = await sut.createFolder(data: newFolder)
        
        // Then
        let savedFolder = try AssertResultSucceded(result)
        
        // Then
        let fetchResult = await sut.getItem(id: savedFolder.id)
        let receivedItem = try AssertResultSucceded(fetchResult)
        
        AssertEqualReadable(.folder(savedFolder), receivedItem)
        
        guard case .folder(let fetchedFolder) = receivedItem else {
            XCTFail("Wrong library item type \(receivedItem)")
            return
        }
        
        XCTAssertEqual(fetchedFolder.title, newFolder.title)
    }
    
    func test_create_folder__with_existing_title() async throws {
        
        let sut = createSUT()
        
        // Given
        let newFolder = anyNewFolder()
        
        // When
        let _ = await sut.createFolder(data: newFolder)
        let result = await sut.createFolder(data: newFolder)
        
        // Then
        let error = try AssertResultFailed(result)
        
        guard case .nameMustBeUnique = error else {
            
            XCTFail("Wrong error type \(error)")
            return
        }
    }
    
    func test_create_folder__with_not_existing_parent() async throws {
        
        let sut = createSUT()
        
        // Given
        let newFolder = anyNewFolder(parentId: UUID())
        
        // When
        let result = await sut.createFolder(data: newFolder)
        
        // Then
        let error = try AssertResultFailed(result)
        
        guard case .parentNotFound = error else {
            
            XCTFail("Wrong error type \(error)")
            return
        }
    }
    
    func testCreateNewRecordNotEmptyList() async throws {

        let sut = createSUT()
        
        let fileInfo1 = MediaLibraryAudioFile(
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
        let savedFile1 = try await putAndCheckFile(library: sut,  fileInfo: fileInfo1, data: fileData1)
        
        let fileInfo2 = MediaLibraryAudioFile(
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
        let savedFile2 = try await putAndCheckFile(library: sut,  fileInfo: fileInfo2, data: fileData2)

        XCTAssertNotEqual(savedFile1?.id, savedFile2?.id)
        XCTAssertNotEqual(savedFile1, savedFile2)
    }
    
    func testUpdateExistingRecord() async throws {
        
        let sut = createSUT()
        
        let fileInfo1 = MediaLibraryAudioFile(
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
        let savedFile1 = try await putAndCheckFile(library: sut,  fileInfo: fileInfo1, data: fileData1)
        
        var fileInfo2 = MediaLibraryAudioFile(
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
        let savedFile2 = try await putAndCheckFile(library: sut,  fileInfo: fileInfo2, data: fileData2)

        XCTAssertEqual(savedFile1?.id, savedFile2?.id)
        XCTAssertEqual(savedFile1?.createdAt, savedFile2?.createdAt)
        XCTAssertNotEqual(savedFile2?.updatedAt, fileInfo2.updatedAt)
        
        fileInfo2.updatedAt = savedFile2?.updatedAt
        XCTAssertEqual(savedFile2, fileInfo2)
    }
    
    func testUpdateNotExistingRecordEmptyList() async throws {
        
        let sut = createSUT()

        let fileInfo1 = MediaLibraryAudioFile(
            id: UUID(),
            createdAt: nil,
            updatedAt: nil,
            name: "Name1",
            duration: 10,
            audioFile: "test.mp3",
            artist: "Artist1",
            genre: "Genre1"
        )
        
        let result = await sut.putFile(info: fileInfo1)
        let error = try AssertResultFailed(result)
        
        guard case .fileNotFound = error else {
            XCTFail("Wrong error")
            return
        }
    }

    func testUpdateNotExistingRecordNotEmptyList() async throws {
        
        let sut = createSUT()
        
        let fileInfo1 = MediaLibraryAudioFile(
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
        try await putAndCheckFile(library: sut, fileInfo: fileInfo1, data: fileData1)
        
        let fileInfo2 = MediaLibraryAudioFile(
            id: UUID(),
            createdAt: .now,
            updatedAt: nil,
            name: "Name2",
            duration: 10,
            audioFile: "test2.mp3",
            artist: "Artist2",
            genre: "Genre2"
        )
        
        
        let putResult = await sut.putFile(info: fileInfo2)
        let putError = try AssertResultFailed(putResult)
    
        guard case .fileNotFound = putError else {
            XCTFail("Wrong error")
            return
        }
    }
    
    func testGetRecordEmptyList() async throws {
        
        let sut = createSUT()
        
        let fileId = UUID()
        let result = await sut.getInfo(fileId: fileId)
        let error = try AssertResultFailed(result)
        
        guard case .fileNotFound = error else {
            XCTFail("Wrong error")
            return
        }
    }
    
    func test_get_item__empty_list() async throws {
        
        let sut = createSUT()
        
        // Given
        let itemId = UUID()
        
        // When
        let result = await sut.getItem(id: itemId)
        
        // Then
        let error = try AssertResultFailed(result)
        
        guard case .fileNotFound = error else {
            XCTFail("Wrong error")
            return
        }
    }
    
    func testGetRecordNotEmptyList() async throws {
        
        let sut = createSUT()
        
        let fileInfo1 = MediaLibraryAudioFile(
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
        let savedFile1 = try await putAndCheckFile(library: sut, fileInfo: fileInfo1, data: fileData1)
        
        let fileInfo2 = MediaLibraryAudioFile(
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
        try await putAndCheckFile(library: sut, fileInfo: fileInfo2, data: fileData2)
        
        let fileId = savedFile1!.id!
        let result = await sut.getInfo(fileId: fileId)
        
        let receivedFileInfo1 = try AssertResultSucceded(result, "File does' not exists")
        XCTAssertEqual(savedFile1, receivedFileInfo1)
    }
    
    func testListFilesEmptyList() async throws {
        
        let sut = createSUT()
        let result = await sut.listFiles()
        let files = try AssertResultSucceded(result)
        
        XCTAssertTrue(files.isEmpty)
    }
    
    func test_list_files_not_empty_list() async throws {
        
        let sut = createSUT()
        
        var fileInfo1 = MediaLibraryAudioFile(
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
        let savedFile1 = try await putAndCheckFile(library: sut, fileInfo: fileInfo1, data: fileData1)
        
        var fileInfo2 = MediaLibraryAudioFile(
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
        let savedFile2 = try await putAndCheckFile(library: sut, fileInfo: fileInfo2, data: fileData2)
        
        let result = await sut.listFiles()
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
        
        let sut = createSUT()
        
        let fileId = UUID()
        let result = await sut.delete(fileId: fileId)
        
        let error = try AssertResultFailed(result)
        guard case .fileNotFound = error else {
            XCTFail("Wrong error")
            return
        }
    }
    
    func test_delete_record_not_empty_list() async throws {
        
        let sut = createSUT()
        
        let fileInfo1 = MediaLibraryAudioFile(
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
        let savedFile1 = try await putAndCheckFile(library: sut, fileInfo: fileInfo1, data: fileData1)
        
        let result = await sut.delete(fileId: savedFile1!.id!)
        try AssertResultSucceded(result)
    }    
}

// MARK: - Helpers


extension MediaLibraryAudioFile: Equatable {
    
    public static func==(lhs: MediaLibraryAudioFile, rhs: MediaLibraryAudioFile) -> Bool {
        return lhs.id == rhs.id &&
            lhs.genre == rhs.genre &&
            lhs.artist == rhs.artist &&
            lhs.name == rhs.name &&
            lhs.updatedAt == rhs.updatedAt &&
            lhs.createdAt == rhs.createdAt
    }
}

extension MediaLibraryAudioFile: Comparable {
    
    public static func < (lhs: MediaLibraryAudioFile, rhs: MediaLibraryAudioFile) -> Bool {
        
        if (lhs.id?.uuidString ?? "") < (rhs.id?.uuidString ?? "") ||
            lhs.name < rhs.name {
            return true
        }
        
        return false
    }
}
