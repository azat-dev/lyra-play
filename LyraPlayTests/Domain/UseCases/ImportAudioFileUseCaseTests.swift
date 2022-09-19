//
//  ImportAudioFileUseCaseTests.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 24.06.22.
//

import Foundation

import XCTest
@testable import LyraPlay
import Mockingbird

class ImportAudioFileUseCaseTests: XCTestCase {

    typealias SUT = (
        useCase: ImportAudioFileUseCase,
        mediaLibraryRepository: MediaLibraryRepositoryMock,
        imagesRepository: FilesRepositoryMock,
        audioFilesRepository: FilesRepositoryMock,
        tagsParser: TagsParserMock,
        fileNameGenerator: ImportAudioFileUseCaseFileNameGenerator
    )
    
    func createSUT() async -> SUT {

        let tagsParser = mock(TagsParser.self)
        let mediaLibraryRepository = mock(MediaLibraryRepository.self)
        let imagesRepository = mock(FilesRepository.self)
        let audioFilesRepository = mock(FilesRepository.self)
        let fileNameGenerator = mock(ImportAudioFileUseCaseFileNameGenerator.self)
        
        given(await mediaLibraryRepository.createFile(data: any()))
            .willReturn(.failure(.internalError(nil)))
        
        given(await imagesRepository.putFile(name: any(), data: any()))
            .willReturn(.success(()))

        given(await audioFilesRepository.putFile(name: any(), data: any()))
            .willReturn(.success(()))

        given(fileNameGenerator.generate(originalName: any()))
            .will { name in
                return name
            }
        
        let useCase = ImportAudioFileUseCaseImpl(
            mediaLibraryRepository: mediaLibraryRepository,
            audioFilesRepository: audioFilesRepository,
            imagesRepository: imagesRepository,
            tagsParser: tagsParser,
            fileNameGenerator: fileNameGenerator
        )
        
        detectMemoryLeak(instance: useCase)
        
        return (
            useCase,
            mediaLibraryRepository,
            imagesRepository,
            audioFilesRepository,
            tagsParser,
            fileNameGenerator
        )
    }
    
    func test_import(tags: AudioFileTags) async throws {

        // Given
        let sut = await createSUT()
        
        let testFile = "test1.mp3"
        let testFileData = "test1".data(using: .utf8)!
        
        let title = tags.title ?? testFile
        let parentFolderId = UUID()

        given(await sut.tagsParser.parse(url: any()))
            .willReturn(.success(tags))
        
        given(sut.audioFilesRepository.getFileUrl(name: any()))
            .willReturn(.init(fileURLWithPath: testFile))
        
        let newFileData = NewMediaLibraryFileData(
            parentId: parentFolderId,
            title: title,
            subtitle: tags.artist,
            file: testFile,
            duration: tags.duration,
            image: tags.coverImage == nil ? nil : "\(title).\(tags.coverImage!.fileExtension)",
            genre: tags.genre
        )
        
        given(await sut.mediaLibraryRepository.createFile(data: any()))
            .willReturn(
                .success(
                    .init(
                        id: UUID(),
                        parentId: parentFolderId,
                        createdAt: .now,
                        updatedAt: nil,
                        title: newFileData.title,
                        subtitle: newFileData.subtitle,
                        file: newFileData.file,
                        duration: newFileData.duration,
                        image: newFileData.image,
                        genre: newFileData.genre
                    )
                )
            )

        // When
        let result = await sut.useCase.importFile(
            targetFolderId: parentFolderId,
            originalFileName: testFile,
            fileData: testFileData
        )

        // Then
        try AssertResultSucceded(result, "Can't import a file: \(testFile)")

        
        if tags.coverImage != nil{
            verify(await sut.imagesRepository.putFile(name: any(), data: any()))
                .wasCalled(1)
        } else {
            verify(await sut.imagesRepository.putFile(name: any(), data: any()))
                .wasNeverCalled()
        }
        
        verify(await sut.mediaLibraryRepository.createFile(data: newFileData))
            .wasCalled(1)
        
        verify(await sut.audioFilesRepository.putFile(name: any(), data: any()))
            .wasCalled(1)
    }
    
    func test_import_without_id3_tags() async throws {
        
        try  await test_import(tags: .init(duration: 10))
    }
    
    func test_import_with_id3_tags() async throws {

        // Given
        let testTags = AudioFileTags(
            title: "tagsTile",
            genre: "tagsGenre",
            coverImage: .init(data: "test".data(using: .utf8)!, fileExtension: "png"),
            artist: "tagsArtist",
            duration: 10,
            lyrics: nil
        )
        
        try await test_import(tags: testTags)
    }
}
