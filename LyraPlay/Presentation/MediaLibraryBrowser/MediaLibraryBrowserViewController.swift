//
//  MediaLibraryBrowserViewController.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 27.06.22.
//

import Foundation
import UIKit

public final class MediaLibraryBrowserViewController: UIViewController, MediaLibraryBrowserView {
    
    private var tableView = UITableView()
    private var tableDataSource: UITableViewDiffableDataSource<Int, MediaLibraryBrowserCellViewModel>!
    private var viewModel: MediaLibraryBrowserViewModel!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        layout()
        bind(to: viewModel)
        style()
        
        Task {
            await viewModel.load()
        }
    }
    
    public required init?(coder: NSCoder) {
        fatalError("Not implemented")
    }

    public init(viewModel: MediaLibraryBrowserViewModel) {

        super.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
    }
}

// MARK: - Bind ViewModel

extension MediaLibraryBrowserViewController {
    
    private func bind(to viewModel: MediaLibraryBrowserViewModel) {
        
        self.viewModel.isLoading.observe(on: self, queue: .main) { isLoading in }
        self.viewModel.filesDelegate = self
    }
}

// MARK: - SetupViews

extension MediaLibraryBrowserViewController {
    
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
        
        self.tableView.delegate = self
        
        self.tableView.register(
            MediaLibraryBrowserCell.self,
            forCellReuseIdentifier: MediaLibraryBrowserCell.reuseIdentifier
        )

        self.tableDataSource = UITableViewDiffableDataSource(
            tableView: tableView,
            cellProvider: { tableView, indexPath, cellViewModel in

                let cell = tableView.dequeueReusableCell(
                    withIdentifier: MediaLibraryBrowserCell.reuseIdentifier,
                    for: indexPath
                ) as! MediaLibraryBrowserCell
                
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

extension MediaLibraryBrowserViewController {
    
    private func style() {
        
        Styles.apply(navigationItem: navigationItem)
        Styles.apply(contentView: view)
        Styles.apply(tableView: tableView)
    }
}


// MARK: - Layout

extension MediaLibraryBrowserViewController {
    
    private func layout() {
        
        Layout.apply(
            view: view,
            tableView: tableView
        )
    }
}

// MARK: - Table View

extension MediaLibraryBrowserViewController: MediaLibraryBrowserUpdateDelegate {
    
    public func filesDidUpdate(updatedFiles: [MediaLibraryBrowserCellViewModel]) {
        
        var snapshot = NSDiffableDataSourceSnapshot<Int, MediaLibraryBrowserCellViewModel>()
        
        snapshot.appendSections([0])
        snapshot.appendItems(updatedFiles, toSection: 0)

        DispatchQueue.main.async {
            self.tableDataSource.apply(snapshot, animatingDifferences: true)
        }
    }
}

extension MediaLibraryBrowserViewController: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let cellViewModel = tableDataSource.itemIdentifier(for: indexPath) else {
            return
        }
        
        cellViewModel.play()
    }
}
