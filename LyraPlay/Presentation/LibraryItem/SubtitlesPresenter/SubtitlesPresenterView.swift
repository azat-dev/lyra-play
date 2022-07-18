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
}

// MARK: - Bind viewModel

extension SubtitlesPresenterView {
    
    private func bind(to viewModel: SubtitlesPresenterViewModel) {

        viewModel.state.observe(on: self, queue: .main) { [weak self] newState in
           
            defer { self?.prevState = newState }
            
            guard let self = self else {
                return
            }
            
            guard
                let prevState = self.prevState,
                let newState = newState,
                prevState.numberOfSentences == newState.numberOfSentences
            else {
                self.tableView.reloadData()
                return
            }
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

// MARK: - Data Source

extension SubtitlesPresenterView: UITableViewDataSource {
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.state.value?.numberOfSentences ?? 0
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
        
        cell.viewModel = viewModel?.getSentenceViewModel(at: indexPath.item)
        return cell
    }
}
