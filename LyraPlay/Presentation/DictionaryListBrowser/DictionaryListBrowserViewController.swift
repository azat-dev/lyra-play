//
//  DictionaryListBrowserViewController.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 19.08.22.
//

import Foundation
import Combine
import UIKit

public final class DictionaryListBrowserViewController: UIViewController, DictionaryListBrowserView {
    
    private var observers = Set<AnyCancellable>()
    
    private var tableView = UITableView()
    private var tableDataSource: UITableViewDiffableDataSource<Int, DictionaryListBrowserItemViewModel>!
    
    private let viewModel: DictionaryListBrowserViewModel
    
    public init(viewModel: DictionaryListBrowserViewModel) {
        
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        
        Task {
            await viewModel.load()
        }
    }
    
    private func setup() {
        
        setupViews()
        style()
        layout()
        bind(to: viewModel)
    }
    
    deinit {
        observers.removeAll()
    }
}

// MARK: - Bind viewModel

extension DictionaryListBrowserViewController {
    
    private func bind(to viewModel: DictionaryListBrowserViewModel) {
        
        viewModel.isLoading.receive(on: RunLoop.main).sink { isLoading in
            
        }.store(in: &observers)
        
        viewModel.listChanged.receive(on: RunLoop.main).sink { event in
            
            self.listChanged(event: event)
        }.store(in: &observers)
    }
}

// MARK: - Table Events

extension DictionaryListBrowserViewController {
    
    private func listLoaded(items: [DictionaryListBrowserItemViewModel]) {
        
        var snapshot = NSDiffableDataSourceSnapshot<Int, DictionaryListBrowserItemViewModel>()
        
        snapshot.appendSections([0])
        snapshot.appendItems(items, toSection: 0)

        DispatchQueue.main.async {
            self.tableDataSource.apply(snapshot, animatingDifferences: true)
        }
    }
    
    private func listChanged(event: DictionaryListBrowserChangeEvent) {
        
        switch event {
        case .loaded(let items):
            listLoaded(items: items)
        }
    }
}

// MARK: - Setup Views

extension DictionaryListBrowserViewController {

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
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
    }

    private func setupViews() {
        
        setupNavigatioBar()
        
        self.tableView.register(
            DictionaryListBrowserCell.self,
            forCellReuseIdentifier: DictionaryListBrowserCell.reuseIdentifier
        )

        self.tableDataSource = UITableViewDiffableDataSource(
            tableView: tableView,
            cellProvider: { tableView, indexPath, cellViewModel in

                let cell = tableView.dequeueReusableCell(
                    withIdentifier: DictionaryListBrowserCell.reuseIdentifier,
                    for: indexPath
                ) as! DictionaryListBrowserCell
                
                cell.fill(with: cellViewModel)
                return cell
            }
        )
        
        self.tableDataSource.defaultRowAnimation = .fade

        self.tableView.dataSource = tableDataSource
        view.addSubview(self.tableView)
    }
}

// MARK: - Layout
extension DictionaryListBrowserViewController {
    
    private func layout() {
        
        Layout.apply(
            view: view,
            tableView: tableView
        )
    }
}

// MARK: - Styles

extension DictionaryListBrowserViewController {
    
    private func style() {
        
        Styles.apply(navigationItem: navigationItem)
        Styles.apply(contentView: view)
        Styles.apply(tableView: tableView)
    }
}
