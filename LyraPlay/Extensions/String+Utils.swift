//
//  String+Utils.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 01.09.22.
//

import Foundation

extension String {
    
    func substring(with nsrange: NSRange) -> Substring? {
        
        guard let range = Range(nsrange, in: self) else { return nil }
        return self[range]
    }
}
