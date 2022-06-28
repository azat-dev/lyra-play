//
//  AudioFilesBrowserCell.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 27.06.22.
//

import Foundation
import UIKit

public final class AudioFilesBrowserCell: UITableViewCell {
    
    public static var reuseIdentifier = "AudioFilesBrowserCell"

    private var titleLabel = UILabel()
    private var descritionLabel = UILabel()
    private var coverImageView = UIImageView()
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        layout()
    }
    
    public required init?(coder: NSCoder) {
        
        super.init(coder: coder)
        setupViews()
        layout()
    }
}

// MARK: - Fill from viewModel

extension AudioFilesBrowserCell {

    func fill(with viewModel: AudioFilesBrowserCellViewModel) {
        
        titleLabel.text = viewModel.title
        descritionLabel.text = viewModel.description
    }
}

// MARK: - Setup

extension AudioFilesBrowserCell {

    private func setupViews() {
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(descritionLabel)
        contentView.addSubview(coverImageView)
    }
}

// MARK: - Layout

extension AudioFilesBrowserCell {

    private func layout() {
        
        let imageSize: CGFloat = 30
        
        coverImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        descritionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            coverImageView.heightAnchor.constraint(equalToConstant: imageSize),
            coverImageView.widthAnchor.constraint(equalToConstant: imageSize),
            
            coverImageView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            coverImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            titleLabel.leftAnchor.constraint(equalTo: coverImageView.rightAnchor, constant: 10),
            titleLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -10),
            
            descritionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            descritionLabel.topAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            descritionLabel.leftAnchor.constraint(equalTo: coverImageView.rightAnchor, constant: 10),
            descritionLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -10),
        ])
    }
}
