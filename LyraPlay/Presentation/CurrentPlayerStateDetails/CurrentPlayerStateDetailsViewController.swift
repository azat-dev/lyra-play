//
//  CurrentPlayerStateDetailsViewController.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 30.09.22.
//

import Foundation
import Combine
import UIKit

public final class CurrentPlayerStateDetailsViewController: UIViewController, CurrentPlayerStateDetailsView {
    
    // MARK: - Properties
    
    private let viewModel: CurrentPlayerStateDetailsViewModel
    
    private var observers = Set<AnyCancellable>()
    
    // MARK: - Initializers
    
    public init(viewModel: CurrentPlayerStateDetailsViewModel) {
        
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        observers.removeAll()
    }
    
    // MARK: - Methods
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    private func setup() {
        
        setupViews()
        style()
        layout()
        bind(to: viewModel)
    }
}

// MARK: - Bind viewModel

extension CurrentPlayerStateDetailsViewController {
    
    private func updateActiveState(_ data: CurrentPlayerStateDetailsViewModelPresentation) {
        
        
    }
    
    private func updateState(_ newState: CurrentPlayerStateDetailsViewModelState) {

        switch newState {
        
        case .loading:
            break
            
        case .notActive:
            break
        
        case .active(let data):
            updateActiveState(data)
        }
    }
    
    private func bind(to viewModel: CurrentPlayerStateDetailsViewModel) {
        
        viewModel.state
            .receive(on: RunLoop.main)
            .sink {  [weak self] state in self?.updateState(state) }
            .store(in: &observers)
    }
}

// MARK: - Setup Views

extension CurrentPlayerStateDetailsViewController {
    
    private func setupViews() {
    }
}

// MARK: - Layout
extension CurrentPlayerStateDetailsViewController {
    
    private func layout() {
        
        Layout.apply(
            view: view
        )
    }
}

// MARK: - Styles

extension CurrentPlayerStateDetailsViewController {
    
    private func style() {
        
        Styles.apply(contentView: view)
    }
}

