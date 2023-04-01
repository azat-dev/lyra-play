//
//  WordCell.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 13.07.22.
//

import Foundation
import UIKit
import Combine

final class RowCell: UICollectionViewCell, NSLayoutManagerDelegate {
    
    public static let reuseIdentifier = "RowCell"
    
    private var textView: UITextView!
    
    private var textLayoutManager = EnhancedLayoutManager()
    
    private var highlights: Observable<HighLights?> = Observable(nil)
    
    private var observers = Set<AnyCancellable>()
    
    public var viewModel: SubtitlesPresenterRowViewModel? {
        
        didSet {
            bind(to: viewModel)
        }
    }
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        viewModel = nil
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
    
    func setupEmpty() {
        
        textLayoutManager.highlights?.value = nil
        textView.text = "..."
    }
    
    func setupSentence(data: SubtitlesPresenterRowSentenceViewModel) {
        
        textView.text = data.text
        textView.accessibilityIdentifier = data.text
    }
    
    func bind(to viewModel: SubtitlesPresenterRowViewModel?) {
        
        observers.removeAll()
        
        guard let viewModel = viewModel else {
            return
        }
        
        switch viewModel.data {
            
        case .empty:
            setupEmpty()
            
        case .sentence(let sentenceData):
            setupSentence(data: sentenceData)
            
            sentenceData.dictionaryWords
                .receive(on: DispatchQueue.main)
                .sink { [weak self] ranges in
                    
                    guard let self = self else {
                        return
                    }
                    
                    var colorRanges = [NSRange: UIColor]()
                    
                    for range in ranges ?? [] {
                        
                        colorRanges[range] = UIColor.purple
                    }
                    
                    self.textLayoutManager.highlights?.value = colorRanges
                    
                }.store(in: &observers)
        }
        
        viewModel.isActive
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isActive in
            
                self?.updateActive(isActive)
            }.store(in: &observers)
        
    }
}

// MARK: - Setup Views

extension RowCell {
    
    private func didTapOutside() {
        
        guard
            let viewModel = viewModel,
            case .sentence(let sentenceData) = viewModel.data
        else {
            return
        }
        
        sentenceData.toggleWord(viewModel.id, nil)
    }
    
    private func didTap(range: UITextRange) {
        
        guard
            let viewModel = viewModel,
            case .sentence(let sentenceData) = viewModel.data
        else {
            return
        }
        
        let nsRange = range.toNSRange(textView: textView)
        
        guard let range = Range(nsRange, in: sentenceData.text) else {
            return
        }
        
        sentenceData.toggleWord(viewModel.id, range)
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
        
        let textStorage = NSTextStorage()
        let textContainer = NSTextContainer(size: contentView.bounds.size)
        
        textLayoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(textLayoutManager)
        
        textLayoutManager.highlights = highlights
        textLayoutManager.delegate = self
        
        textView = UITextView(frame: .zero, textContainer: textContainer)
        textView.attributedText = textStorage
        contentView.addSubview(textView)
        
        textView.addGestureRecognizer(tapGestureRecognizer)
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
