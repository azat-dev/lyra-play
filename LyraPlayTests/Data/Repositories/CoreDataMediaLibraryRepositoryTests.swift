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
    
    typealias SUT = MediaLibraryRepository
    
    func createSUT(file: StaticString = #filePath, line: UInt = #line) -> SUT {

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
    
    private func anyNewFile(parentId: UUID? = nil, title: String = "Title") -> NewMediaLibraryFileData {
        
        return .init(
            parentId: parentId,
            title: title,
            subtitle: "Subtitle",
            file: "test.mp3",
            duration: 111,
            image: "test.png",
            genre: "genre"
        )
    }
    
    private func anyNewFolder(parentId: UUID? = nil, title: String = "Title") -> NewMediaLibraryFolderData {
        
        return .init(
            parentId: parentId,
            title: title,
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
    
    private func given(sut: SUT, withFolderTitles titles: [String], parentId: UUID? = nil) async throws -> [MediaLibraryFolder] {
        
        var items = [MediaLibraryFolder]()
        
        for title in titles {
            
            let folder = anyNewFolder(parentId: parentId, title: title)
            let resultFolder = await sut.createFolder(data: folder)
            let savedFolder = try AssertResultSucceded(resultFolder)
            
            items.append(savedFolder)
        }
        
        return items
    }
    
    private func given(sut: SUT, folderId: UUID?, withFiles titles: [String]) async throws -> [MediaLibraryFile] {
        
        var items = [MediaLibraryFile]()
        
        for title in titles {
            
            let folder = anyNewFile(parentId: folderId, title: title)
            let resultFile = await sut.createFile(data: folder)
            let savedFile = try AssertResultSucceded(resultFile)
            
            items.append(savedFile)
        }
        
        return items
    }
    
    func test_listItems__empty_list() async throws {
        
        let sut = createSUT()
        
        // Given
        // Empty list
        
        // When
        let result = await sut.listItems(folderId: nil)
        
        // Then
        let files = try AssertResultSucceded(result)
        XCTAssertTrue(files.isEmpty)
    }
    
    func test_listItems__not_empty_list() async throws {
        
        let sut = createSUT()
        
        // Given
        let folders = try await given(sut: sut, withFolderTitles: ["folder1", "folder2"])
        
        let folderId1 = folders[0].id
        let folderId2 = folders[1].id
        
        let files1 = try await given(sut: sut, folderId: folderId1, withFiles: ["file1", "file2"])
        
        // When
        let resultFolder1 = await sut.listItems(folderId: folderId1)
        
        // Then
        let listedFilesInFolder1 = try AssertResultSucceded(resultFolder1)
        AssertEqualReadable(listedFilesInFolder1, files1.map { .file($0) })
        
        // When
        let resultFolder2 = await sut.listItems(folderId: folderId2)
        
        // Then
        let listedFilesInFolder2 = try AssertResultSucceded(resultFolder2)
        XCTAssertTrue(listedFilesInFolder2.isEmpty)
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
    
    func test_deleteFile___empty_list() async throws {
        
        let sut = createSUT()
        
        // Given
        let fileId = UUID()
        
        // When
        let result = await sut.deleteItem(id: fileId)
        
        // Then
        let error = try AssertResultFailed(result)
        
        guard case .fileNotFound = error else {
            XCTFail("Wrong error")
            return
        }
    }
    
    func test_deleteItem__not_empty_list() async throws {
        
        let sut = createSUT()
        
        // Given
        let existingFolders = try await given(sut: sut, withFolderTitles: ["folder0", "folder1"])
        let existingFiles = try await given(sut: sut, folderId: existingFolders[0].id, withFiles: ["file0", "file1"])

        // When
        let result = await sut.deleteItem(id: existingFiles[0].id)
        
        // Then
        try AssertResultSucceded(result)
        
        let listFilesResult = await sut.listItems(folderId: existingFolders[0].id)
        let listedFiles = try AssertResultSucceded(listFilesResult)
        
        AssertEqualReadable(listedFiles.map { $0 }, [.file(existingFiles[1])])
    }
    
    func test_deleteItem__cascade() async throws {
        
        let sut = createSUT()
        
        // Given
        let existingFolders = try await given(sut: sut, withFolderTitles: ["folder0", "folder1"])
        let existingFoldersInFolder0 = try await given(sut: sut, withFolderTitles: ["folder11"], parentId: existingFolders[0].id)
        let existingFilesInFolder0 = try await given(sut: sut, folderId: existingFolders[0].id, withFiles: ["file0"])
        
        // When
        let result = await sut.deleteItem(id: existingFolders[0].id)
        
        // Then
        try AssertResultSucceded(result)
        
        let resultFetchFile = await sut.getItem(id: existingFilesInFolder0[0].id)
        
        guard case .fileNotFound = try AssertResultFailed(resultFetchFile) else {
            XCTFail("Wrong error type \(resultFetchFile)")
            return
        }
        
        let resultFetchFolder = await sut.getItem(id: existingFoldersInFolder0[0].id)
        
        guard case .fileNotFound = try AssertResultFailed(resultFetchFolder) else {
            XCTFail("Wrong error type \(resultFetchFile)")
            return
        }
    }
    
    func test_updateFile__not_existing() async throws {
        
        let sut = createSUT()
        
        // Given
        
        let existingFiles = try await given(sut: sut, folderId: nil, withFiles: ["file1"])
        let _ = await sut.deleteItem(id: existingFiles[0].id)
        
        var updateData = existingFiles[0]
        updateData.file = "File2.mp3"
        
        // When
        let result = await sut.updateFile(data: updateData)

        // Then
        let error = try AssertResultFailed(result)
        
        guard case .fileNotFound = error else {
            
            XCTFail("Wrong error type \(error)")
            return
        }
    }

    func test_updateFile__existing() async throws {
        
        let sut = createSUT()
        
        // Given
        
        let existingFiles = try await given(sut: sut, folderId: nil, withFiles: ["file1", "file2"])

        var updateData = existingFiles[0]
        updateData.file = "File2.mp3"
        updateData.title = "UpdatedTitle"
        updateData.genre = "UpdatedGenre"
        updateData.duration = 222
        updateData.image = "UpdatedImage.png"
        updateData.lastPlayedAt = .now
        updateData.subtitle = "UpdatedSubtitle"
        updateData.playedTime = 333
        
        // When
        let result = await sut.updateFile(data: updateData)

        // Then
        try AssertResultSucceded(result)
        
        let fechResult = await sut.getItem(id: updateData.id)
        let fetchedFile = try AssertResultSucceded(fechResult)
        
        guard case .file(let fetchedFile) = fetchedFile else {
            XCTFail("Wrong type")
            return
        }
        
        updateData.updatedAt = fetchedFile.updatedAt
        AssertEqualReadable(fetchedFile, updateData)
        
        // Then
        let fechResultFile2 = await sut.getItem(id: existingFiles[1].id)
        let fetchedFile2 = try AssertResultSucceded(fechResultFile2)
        
        AssertEqualReadable(fetchedFile2, .file(existingFiles[1]))
    }
    
    func test_updateFolder__not_existing() async throws {
        
        let sut = createSUT()
        
        // Given
        
        let existingFolders = try await given(sut: sut, withFolderTitles: ["folder1"])
        let _ = await sut.deleteItem(id: existingFolders[0].id)

        var updateData = existingFolders[0]
        updateData.title = "UpdatedTitle"
        
        // When
        let result = await sut.updateFolder(data: updateData)

        // Then
        let error = try AssertResultFailed(result)
        
        guard case .fileNotFound = error else {
            
            XCTFail("Wrong error type \(error)")
            return
        }
    }

    func test_updateFolder__existing() async throws {
        
        let sut = createSUT()
        
        // Given
        
        let existingFolders = try await given(sut: sut, withFolderTitles: ["folder1", "folder2"])

        var updateData = existingFolders[0]
        updateData.title = "UpdatedTitle"
        updateData.image = "UpdatedImage.png"
        
        // When
        let result = await sut.updateFolder(data: updateData)

        // Then
        try AssertResultSucceded(result)
        
        let fechResult = await sut.getItem(id: updateData.id)
        let fetchedFolder = try AssertResultSucceded(fechResult)

        guard case .folder(let fetchedFolder) = fetchedFolder else {
            XCTFail("Wrong type")
            return
        }
        
        updateData.updatedAt = fetchedFolder.updatedAt
        AssertEqualReadable(fetchedFolder, updateData)
        
        // Then
        let fechResultFolder2 = await sut.getItem(id: existingFolders[1].id)
        let fetchedFolder2 = try AssertResultSucceded(fechResultFolder2)
        
        AssertEqualReadable(fetchedFolder2, .folder(existingFolders[1]))
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
