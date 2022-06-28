//
//  AudioFilesBrowserViewController.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 27.06.22.
//

import Foundation
import UIKit

final class AudioFilesBrowserViewController: UIViewController {
    
    private var tableView = UITableView()
    private var tableDataSource: UITableViewDiffableDataSource<Int, AudioFilesBrowserCellViewModel>!
    private var viewModel: AudioFilesBrowserViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        layout()
        bind(to: viewModel)
        style()
        
        Task {
            await viewModel.load()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("Not implemented")
    }

    init(viewModel: AudioFilesBrowserViewModel) {

        super.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
    }
}

// MARK: - Bind ViewModel

extension AudioFilesBrowserViewController {
    
    private func bind(to viewModel: AudioFilesBrowserViewModel) {
        
        self.viewModel.isLoading.observe(on: self) { isLoading in }
        self.viewModel.filesDelegate = self
    }
}

// MARK: - SetupViews

extension AudioFilesBrowserViewController {
    
    @objc
    private func didAddItem() {
        
        viewModel.addNewItem()
    }
    
    private func setupNavigatioBar() {
        
        let addButton = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(Self.didAddItem)
        )
        
        navigationItem.rightBarButtonItem = addButton
    }
    
    private func setupViews() {
        
        setupNavigatioBar()
        
        self.tableView.register(
            AudioFilesBrowserCell.self,
            forCellReuseIdentifier: AudioFilesBrowserCell.reuseIdentifier
        )

        self.tableDataSource = UITableViewDiffableDataSource(
            tableView: tableView,
            cellProvider: { tableView, indexPath, cellViewModel in

                let cell = tableView.dequeueReusableCell(
                    withIdentifier: AudioFilesBrowserCell.reuseIdentifier,
                    for: indexPath
                ) as! AudioFilesBrowserCell
                
                cell.fill(with: cellViewModel)
                return cell
            }
        )

        self.tableView.dataSource = tableDataSource
        view.addSubview(self.tableView)
    }
}

// MARK: - Style

extension AudioFilesBrowserViewController {
    
    private func style() {
        
        self.navigationItem.title = "Library"
        self.navigationItem.largeTitleDisplayMode = .always
    }
}


// MARK: - Layout

extension AudioFilesBrowserViewController {
    
    private func layout() {
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
}

// MARK: - Layout

extension AudioFilesBrowserViewController: AudioFilesBrowserUpdateDelegate {
    
    func filesDidUpdate(updatedFiles: [AudioFilesBrowserCellViewModel]) {
        
        var snapshot = NSDiffableDataSourceSnapshot<Int, AudioFilesBrowserCellViewModel>()
        
        snapshot.appendSections([0])
        snapshot.appendItems(updatedFiles, toSection: 0)

        DispatchQueue.main.async {
            self.tableDataSource.apply(snapshot, animatingDifferences: true)
        }
    }
}
