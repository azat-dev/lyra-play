//
//  HighlightWordsLayoutManager.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 18.07.22.
//

import Foundation
import UIKit

// MARK: - Implementations

public typealias HighLights = [NSRange: UIColor]

public final class EnhancedLayoutManager: NSLayoutManager {
    
    private var prevHighLights: HighLights? = nil
    
    public var highlights: Observable<HighLights?>? {
        
        didSet {
            bind(to: highlights)
        }
    }
}

extension EnhancedLayoutManager {
    
    private func invalidatePrevHighLights(newItems: HighLights?) {
        
        guard let prevHighLights = prevHighLights else {
            return
        }
        
        for (range, _) in prevHighLights {
            
            guard let newItems = newItems else {
                
                self.invalidateDisplay(forGlyphRange: range)
                return
            }

            let newColor = newItems[range]
            
            if newColor == nil {
                
                self.invalidateDisplay(forGlyphRange: range)
            }
        }
    }
    
    private func invalidateNewHighLights(newItems: HighLights?) {
        
        guard let newItems = newItems else {
            return
        }
        
        for (range, newColor) in newItems {
            
            guard let prevHighLights = prevHighLights else {
                
                self.invalidateDisplay(forGlyphRange: range)
                return
            }

            let prevColor = prevHighLights[range]
            
            if prevColor != newColor {
                
                self.invalidateDisplay(forGlyphRange: range)
            }
        }
    }
    
    private func bind(to highlights: Observable<HighLights?>?) {
        
        highlights?.observe(on: self, queue: .main) { [weak self] highlights in
            
            self?.invalidatePrevHighLights(newItems: highlights)
            self?.invalidateNewHighLights(newItems: highlights)
            self?.prevHighLights = highlights
        }
    }
}


// MARK: - NSLayoutManager

extension EnhancedLayoutManager {
    
    public override func drawBackground(forGlyphRange glyphsToShow: NSRange, at origin: CGPoint) {
        
        let highlights = highlights?.value ?? HighLights()
        
        for (range, color) in highlights {
            
            let wordRange = self.glyphRange(
                forCharacterRange: range,
                actualCharacterRange: nil
            )
            
            enumerateLineFragments(forGlyphRange: wordRange) { rect, usedRect, container, lineRange, stop in
                
                let rect = self.boundingRect(
                    forGlyphRange: NSIntersectionRange(wordRange, lineRange),
                    in: container
                )
                
                let rectWithInsets = rect.offsetBy(dx: origin.x, dy: origin.y)
                    .inset(by: .init(top: 0, left: -3, bottom: 0, right: -3))
                
                self.drawRect(color: color, rect: rectWithInsets)
            }
        }
    }
    
    public func drawRect(color: UIColor, rect: CGRect) {
        
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
