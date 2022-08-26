//
//  AudioFilesBrowserViewController.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 27.06.22.
//

import Foundation
import UIKit

final class AudioFilesBrowserViewController: UIViewController, AudioFilesBrowserView {
    
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
        
        self.viewModel.isLoading.observe(on: self, queue: .main) { isLoading in }
        self.viewModel.filesDelegate = self
    }
}

// MARK: - SetupViews

extension AudioFilesBrowserViewController {
    
    @objc
    private func didAddItem() {
        
        viewModel.addNewItem()
    }
    
    private func setupTabBar() {
        
        tabBarItem = .init(
            title: "Library",
            image: .init(systemName: "books.vertical"),
            selectedImage: .init(systemName: "books.vertical.fill")
        )
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
        
        setupTabBar()
        setupNavigatioBar()
        
        self.tableView.delegate = self
        
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
        
        self.tableDataSource.defaultRowAnimation = .fade

        self.tableView.dataSource = tableDataSource
        view.addSubview(self.tableView)
    }
}

// MARK: - Style

extension AudioFilesBrowserViewController {
    
    private func style() {
        
        Styles.apply(navigationItem: navigationItem)
        Styles.apply(contentView: view)
        Styles.apply(tableView: tableView)
    }
}


// MARK: - Layout

extension AudioFilesBrowserViewController {
    
    private func layout() {
        
        Layout.apply(
            view: view,
            tableView: tableView
        )
    }
}

// MARK: - Table View

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

extension AudioFilesBrowserViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let cellViewModel = tableDataSource.itemIdentifier(for: indexPath) else {
            return
        }
        
        cellViewModel.play()
    }
}
