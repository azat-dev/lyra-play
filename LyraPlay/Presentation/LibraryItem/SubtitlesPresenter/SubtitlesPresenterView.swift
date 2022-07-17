//
//  SubtitlesPresenterView.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 13.07.22.
//

import Foundation
import UIKit

public final class SubtitlesPresenterView: UIView {
    
    private var tableView: UITableView!
    
    public var viewModel: SubtitlesPresenterViewModel? {
        
        didSet {
            guard let viewModel = viewModel else {
                return
            }

            bind(to: viewModel)
        }
    }
    
    private var prevPosition: SubtitlesPosition?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        
        setupViews()
        layout()
        style()
    }
}

// MARK: - Bind viewModel

extension SubtitlesPresenterView {
    
    private func bind(to viewModel: SubtitlesPresenterViewModel) {

        viewModel.sentences.observe(on: self, queue: .main) { [weak self] sentences in
            self?.tableView.reloadData()
        }
        
        viewModel.currentPosition.observe(on: self, queue: .main) { [weak self] position in
            
            guard let self = self else {
                return
            }
            
            defer { self.prevPosition = position }
            
            guard let sentencePosition = position?.sentence else {
                return
            }
            
            let currentRowIndexPath = IndexPath(item: sentencePosition, section: 0)
            var pathsToReload: [IndexPath] = [
                currentRowIndexPath
            ]
            
            if let prevPosition = self.prevPosition {
                
                let prevPositionPath = IndexPath(item: prevPosition.sentence, section: 0)
                pathsToReload.append(prevPositionPath)
            }
            
            self.tableView.reloadRows(at: pathsToReload, with: .none)
            self.tableView.scrollToRow(
                at: currentRowIndexPath,
                at: .top,
                animated: true
            )
        }
    }
}

// MARK: - Setup Views

extension SubtitlesPresenterView {
    
    private func setupViews() {

        tableView = UITableView(
            frame: frame,
            style: .plain
        )

        tableView.register(
            RowCell.self,
            forCellReuseIdentifier: RowCell.reuseIdentifier
        )

        tableView.dataSource = self
        
        addSubview(tableView)
    }
}

// MARK: - Layout

extension SubtitlesPresenterView {
    
    private func layout() {
        
        Layout.apply(
            view: self,
            tableView: tableView
        )
    }
}

// MARK: - Style

extension SubtitlesPresenterView {
    
    private func style() {
        
        Styles.apply(tableView: tableView)
    }
}

extension SubtitlesPresenterView {
    
    public func getItem(at indexPath: IndexPath) -> RowCellViewModel? {
        
        let sentenceIndex = indexPath.item
        
        guard
            let sentences = viewModel?.sentences.value,
            sentenceIndex < sentences.count
        else {
            fatalError("Inconsistent state")
        }
        
        let sentence = sentences[sentenceIndex]
        
        var isActive = false
        
        if let currentSentenceIndex = viewModel?.currentPosition.value?.sentence {
            
            isActive = currentSentenceIndex == sentenceIndex
        }
        
        let factory = RowCellViewModelFactory()
        return factory.create(
            id: sentenceIndex,
            isActive: isActive,
            text: sentence.text,
            toggleWord: { rowId, range in
                
            },
            activeRange: nil
        )
        
    }
}

// MARK: - Data Source

extension SubtitlesPresenterView: UITableViewDataSource {
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.sentences.value?.count ?? 0
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: RowCell.reuseIdentifier,
            for: indexPath
        )
        
        guard
            let cell = cell as? RowCell,
            let cellViewModel = getItem(at: indexPath)
        else {
            fatalError("Can't dequee a cell")
        }
        
        cell.viewModel = cellViewModel
        return cell
    }
}
