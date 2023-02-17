//
//  AudioSessionFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 01.09.2022.
//

public protocol AudioSessionFactory {

    func make() -> AudioSession
}
