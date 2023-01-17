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
    
    // MARK: - Properties
    
    private var observers = Set<AnyCancellable>()
    
    private var tableView = UITableView()
    private var tableDataSource: DataSource<Int, UUID>!
    
    private let viewModel: DictionaryListBrowserViewModel

    // MARK: - Initializers
    
    public init(viewModel: DictionaryListBrowserViewModel) {
        
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    
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
        
        viewModel.items
            .receive(on: RunLoop.main)
            .sink { [weak self] ids in
                
                self?.updateList(ids)
            }.store(in: &observers)
        
        viewModel.changedItems
            .receive(on: RunLoop.main)
            .sink { [weak self] ids in
                
                self?.updateItems(with: ids)
            }.store(in: &observers)
    }
}

// MARK: - Table Events

extension DictionaryListBrowserViewController {
    
    private func updateList(_ items: [UUID]) {
        
        var snapshot = NSDiffableDataSourceSnapshot<Int, UUID>()
        
        snapshot.appendSections([0])
        snapshot.appendItems(items, toSection: 0)

        DispatchQueue.main.async {
            self.tableDataSource.apply(snapshot, animatingDifferences: true)
        }
    }
    
    private func updateItems(with ids: [UUID]) {

        var snapshot = tableDataSource.snapshot()
        snapshot.reconfigureItems(ids)
        
        DispatchQueue.main.async {
            self.tableDataSource.apply(snapshot, animatingDifferences: true)
        }
    }
}

// MARK: - Setup Views

extension DictionaryListBrowserViewController {

    @objc
    private func didAddItem() {
        
        viewModel.addNewItem()
    }
    
    private func setupAddButton() {
        
        let addButton = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(Self.didAddItem)
        )
        
        navigationItem.rightBarButtonItem = addButton
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
    }
    
    private func setupNavigatioBar() {
        
        setupAddButton()
    }

    private func setupViews() {
        
        setupNavigatioBar()
        
        tableView.register(
            DictionaryListBrowserCell.self,
            forCellReuseIdentifier: DictionaryListBrowserCell.reuseIdentifier
        )

        let dataSource = DataSource<Int, UUID>(
            tableView: tableView,
            cellProvider: { [weak self] tableView, indexPath, itemId in

                guard let self = self else {
                    return nil
                }
                
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: DictionaryListBrowserCell.reuseIdentifier,
                    for: indexPath
                ) as! DictionaryListBrowserCell
                
                
                let cellViewModel = self.viewModel.getItem(with: itemId)
                cell.fill(with: cellViewModel)
                
                return cell
            }
        )
        
        dataSource.onDeleteItem = { [weak self] in self?.viewModel.deleteItem($0) }
        
        tableDataSource = dataSource
        tableDataSource.defaultRowAnimation = .fade

        tableView.dataSource = tableDataSource
        view.addSubview(tableView)
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

// MARK: - Helper Classes

fileprivate final class DataSource<SectionIdentifierType, ItemIdentifierType>: UITableViewDiffableDataSource<SectionIdentifierType, ItemIdentifierType>
    where SectionIdentifierType: Hashable, ItemIdentifierType: Hashable {
    
    typealias DeleteItemCallBack = (_ id: ItemIdentifierType) -> Void
    
    // MARK: - Properties
    
    public var onDeleteItem: DeleteItemCallBack?
    
    // MARK: - Methods
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(
        _ tableView: UITableView,
        commit editingStyle: UITableViewCell.EditingStyle,
        forRowAt indexPath: IndexPath
    ) {
        
        if editingStyle == .delete {
    
            if let identifierToDelete = itemIdentifier(for: indexPath) {
                onDeleteItem?(identifierToDelete)
            }
        }
    }
}
