//
//  HighlightWordsLayoutManager.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 18.07.22.
//

import Foundation
import UIKit

public struct HightLight {
    
    public var id: String
    public var range: NSRange
    public var color: UIColor
    
    public init(id: String, range: NSRange, color: UIColor) {
        
        self.id = id
        self.range = range
        self.color = color
    }
    
}

public final class HighlightWordsLayoutManager: NSLayoutManager {
    
    private var highlights = [HightLight]()
    
    public func putHighlight(highlight: HightLight) {
        
        let index = highlights.firstIndex { $0.id == highlight.id }
        
        if let index = index {
            
            let prevItem = highlights[index]
            let prevRange = prevItem.range
            
            highlights[index] = highlight
            
            if prevItem.range == highlight.range && prevItem.color == highlight.color {
                return
            }
            
            invalidateDisplay(forCharacterRange: prevRange)
            return
        }
        
        highlights.append(highlight)
        invalidateDisplay(forCharacterRange: highlight.range)
    }
    
    public func removeHighlight(id: String) {
        
        let index = highlights.firstIndex { $0.id == id }
        
        guard
            let index = index
        else {
            return
        }
        
        let item = highlights[index]
        highlights.remove(at: index)
        invalidateDisplay(forCharacterRange: item.range)
    }
    
    public override func drawBackground(forGlyphRange glyphsToShow: NSRange, at origin: CGPoint) {
        
        for highlight in highlights {
            
            let wordRange = self.glyphRange(
                forCharacterRange: highlight.range,
                actualCharacterRange: nil
            )
            
            enumerateLineFragments(forGlyphRange: wordRange) { rect, usedRect, container, lineRange, stop in
                
                let rect = self.boundingRect(
                    forGlyphRange: NSIntersectionRange(wordRange, lineRange),
                    in: container
                )
                
                let rectWithInsets = rect.offsetBy(dx: origin.x, dy: origin.y)
                    .inset(by: .init(top: 0, left: -2, bottom: 0, right: -2))
                
                self.drawRect(color: highlight.color, rect: rectWithInsets)
            }
        }
    }
    
    private func drawRect(color: UIColor, rect: CGRect) {
        
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        
        color.setFill()
        
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: .allCorners,
            cornerRadii: .init(width: 5, height: 5)
        )
        
        context.addPath(path.cgPath)
        context.drawPath(using: .fill)
    }
}
