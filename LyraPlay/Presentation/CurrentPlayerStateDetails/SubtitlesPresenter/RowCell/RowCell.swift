//
//  WordCell.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 13.07.22.
//

import Foundation
import UIKit

final class RowCell: UICollectionViewCell, NSLayoutManagerDelegate {
    
    public static let reuseIdentifier = "RowCell"
    
    private var textView: UITextView!
    private var textLayoutManager = EnhancedLayoutManager()
    private var highlights: Observable<HighLights?> = Observable(nil)
    
    public var viewModel: SentenceViewModel! {

        didSet {
            
            if let oldModel = oldValue {
                disconnect(viewModel: oldModel)
            }
            
            bind(to: viewModel)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        
        setupViews()
        layout()
        style()
    }
}

// MARK: - Bind to ViewModel

extension RowCell {
    
    private func updateActive(_ isActive: Bool) {
        
        if isActive {
            Styles.apply(activeTextView: self.textView)
        } else {
            Styles.apply(textView: self.textView)
        }
    }

    func disconnect(viewModel: SentenceViewModel) {
        
        viewModel.isActive.remove(observer: self)
        viewModel.selectedWordRange.remove(observer: self)
    }
    
    func bind(to viewModel: SentenceViewModel) {
        
        textView.text = viewModel.text
        
        viewModel.isActive.observe(on: self, queue: .main) { [weak self] isActive in
            self?.updateActive(isActive)
        }
        
        viewModel.selectedWordRange.observe(on: self, queue: .main) { [weak self] activeRange in
            
            guard let self = self else {
                return
            }
            
            guard let activeRange = activeRange else {
                self.highlights.value = nil
                return
            }
            
            let nsRange = NSRange(activeRange, in: viewModel.text)
            self.highlights.value = [nsRange: UIColor.red]
        }
    }
}

// MARK: - Setup Views

extension RowCell {
    
    private func didTapOutside() {

        guard let viewModel = viewModel else {
            return
        }
        
        viewModel.toggleWord(viewModel.id, nil)
    }
    
    private func didTap(range: UITextRange) {

        guard let viewModel = viewModel else {
            return
        }
        
        let nsRange = range.toNSRange(textView: textView)
        guard let range = Range(nsRange, in: viewModel.text) else {
            return
        }
        
        viewModel.toggleWord(viewModel.id, range)
    }

    @objc
    private func didTap(gesture: UITapGestureRecognizer) {
        
        let point = gesture.location(in: textView)
        var isPlacedInLine = false
        
        textView.layoutManager.enumerateLineFragments(forGlyphRange: textView.textRange) {
            [weak self] (rect, usedRect, textContainer, glyphRange, stop) in
            
            guard let self = self else {
                return
            }

            let textContainerInset = self.textView.textContainerInset
            
            let usedRectWithInsets = usedRect.offsetBy(
                dx: textContainerInset.left,
                dy: textContainerInset.top
            ).inset(
                by: .init(
                    top: 0,
                    left: 0,
                    bottom: -2,
                    right: 0
                )
            )
            
            let placedInLine = usedRectWithInsets.contains(point)
            guard placedInLine else {
                return
            }

            let tapRange = self.textView.characterRange(at: point)
            guard let tapRange = tapRange else {
                return
            }
            
            stop.pointee = true
            isPlacedInLine = true
            self.didTap(range: tapRange)
        }
        
        if !isPlacedInLine {
            didTapOutside()
        }
    }
    
    private func setupViews() {

        let tapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(didTap(gesture:))
        )
        
//        let textStorage = NSTextStorage()
//        let textContainer = NSTextContainer(size: .zero)
        
//        textLayoutManager.highlights = highlights
//        textStorage.addLayoutManager(self.textLayoutManager)
//
//        textLayoutManager.addTextContainer(textContainer)
//        textLayoutManager.delegate = self
        
        textView = UITextView()
        textView.addGestureRecognizer(tapGestureRecognizer)
        
        contentView.addSubview(textView)
    }
}

// MARK: - Layout

extension RowCell {
    
    private func layout() {

        textView.constraintTo(view: contentView, margins: .init(top: 0, left: 20, bottom: 0, right: 20))
    }
}

// MARK: - Style

extension RowCell {
    
    private func style() {
        
        backgroundColor = .clear
        backgroundView = nil
        selectedBackgroundView = nil
        
        Styles.apply(contentView: contentView)
    }
}
