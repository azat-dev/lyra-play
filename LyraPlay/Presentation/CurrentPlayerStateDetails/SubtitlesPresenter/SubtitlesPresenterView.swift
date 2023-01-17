//
//  SubtitlesPresenterView.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 13.07.22.
//

import Foundation
import Combine
import UIKit

public final class SubtitlesPresenterView: UIView {
    
    private var viewModelObserver: AnyCancellable?
    private var tableView: UITableView!
    
    public var viewModel: SubtitlesPresenterViewModel? {
        
        didSet {
            guard let viewModel = viewModel else {
                return
            }
            
            bind(to: viewModel)
        }
    }
    
    private var prevState: SubtitlesPresentationState? = nil
    
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
    
    deinit {
        viewModelObserver?.cancel()
    }
}

// MARK: - Bind viewModel

extension SubtitlesPresenterView {
    
    private func bind(to viewModel: SubtitlesPresenterViewModel) {
        
        viewModelObserver = viewModel.state
            .receive(on: RunLoop.main)
            .sink { [weak self] newState in
                
                guard let self = self else {
                    return
                }
                
                if let activeSentenceIndex = newState.activeSentenceIndex {
                    
                    guard self.tableView.numberOfSections > activeSentenceIndex else {
                        return
                    }
                    
                    let indexPath = IndexPath(row: 0, section: activeSentenceIndex)
                    self.tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
                }
            }
    }
}

// MARK: - Setup Views

extension SubtitlesPresenterView: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 25
    }
}

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
        tableView.delegate = self
        tableView.sectionHeaderHeight = 1
        tableView.tableFooterView = nil
        tableView.estimatedSectionFooterHeight = 0
        
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

// MARK: - Data Source

extension SubtitlesPresenterView: UITableViewDataSource {
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        
        return viewModel?.state.value.rows.count ?? 0
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: RowCell.reuseIdentifier,
            for: indexPath
        )
        
        guard
            let cell = cell as? RowCell
        else {
            fatalError("Can't dequee a cell")
        }
        
        guard let rows = viewModel?.state.value.rows else {
            fatalError("Can't find row at: \(indexPath.section)")
        }
        
        cell.viewModel = rows[indexPath.section]
        return cell
    }
}
