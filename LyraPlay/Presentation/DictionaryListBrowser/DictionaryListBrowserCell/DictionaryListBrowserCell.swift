//
//  DictionaryListBrowserCell.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 19.08.22.
//

import Foundation
import UIKit

public final class DictionaryListBrowserCell: UITableViewCell {
    
    public static var reuseIdentifier = "DictionaryListBrowserCell"

    private var textGroup = UIStackView()
    private var titleLabel = UILabel()
    private var descritionLabel = UILabel()
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    public required init?(coder: NSCoder) {
        
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        setupViews()
        layout()
        style()
    }
}

// MARK: - Fill from viewModel

extension DictionaryListBrowserCell {

    func fill(with viewModel: DictionaryListBrowserItemViewModel) {
        
        titleLabel.text = viewModel.title
        descritionLabel.text = viewModel.description
    }
}

// MARK: - Setup views

extension DictionaryListBrowserCell {

    private func setupViews() {
        
        textGroup.axis = .vertical
        
        textGroup.addArrangedSubview(titleLabel)
        textGroup.addArrangedSubview(descritionLabel)
        
        contentView.addSubview(textGroup)
    }
}

// MARK: - Style

extension DictionaryListBrowserCell {

    private func style() {

        backgroundView = nil
        backgroundColor = .clear
        
        Styles.apply(contentView: contentView)
        Styles.apply(titleLabel: titleLabel)
        Styles.apply(descriptionLabel: descritionLabel)
    }
}

// MARK: - Layout

extension DictionaryListBrowserCell {
    
    private func layout() {
        
        Layout.apply(
            contentView: contentView,
            textGroup: textGroup,
            titleLabel: titleLabel,
            descriptionLabel: descritionLabel
        )
    }
}

