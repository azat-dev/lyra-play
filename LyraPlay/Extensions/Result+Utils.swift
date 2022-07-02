//
//  Result+Utils.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 02.07.22.
//

import Foundation

extension Result {
    
    var error: Failure? {
        guard case .failure(let error) = self else {
            return nil
        }
        
        return error
    }
}
