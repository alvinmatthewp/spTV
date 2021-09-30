//
//  PlayerControlView.swift
//  bcTV
//
//  Created by alvin.pratama on 29/09/21.
//

import UIKit

public final class PlayerControlView: UIView {
    internal static let height: CGFloat = 32

    private let playButton: UIButton = {
        let node = UIButton()
        node.setImage(UIImage(systemName: "play.fill"), for: .normal)
        node.tintColor = .white
        return node
    }()

    private let seekBar: PlayerSeekBarView

    private let timeIndicator = UILabel()

    public init() {
        seekBar = PlayerSeekBarView()

        super.init(frame: .zero)
        
        addSubview(playButton)
        addSubview(seekBar)
        addSubview(timeIndicator)
        
        playButton.translatesAutoresizingMaskIntoConstraints = false
        seekBar.translatesAutoresizingMaskIntoConstraints = false
        timeIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        let timeIndicatorWidthConstraint = timeIndicator.widthAnchor.constraint(equalToConstant: 80)
        
        NSLayoutConstraint.activate([
            playButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            playButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            playButton.widthAnchor.constraint(equalToConstant: PlayerControlView.height / 2),
            
            seekBar.leadingAnchor.constraint(equalTo: playButton.trailingAnchor, constant: 12),
            seekBar.trailingAnchor.constraint(equalTo: timeIndicator.leadingAnchor, constant: -12),
            seekBar.heightAnchor.constraint(equalToConstant: PlayerControlView.height),
            seekBar.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            timeIndicator.trailingAnchor.constraint(equalTo: trailingAnchor),
            timeIndicator.centerYAnchor.constraint(equalTo: centerYAnchor),
            timeIndicatorWidthConstraint,
        ])
        
        timeIndicator.attributedText = .body3("00:00 / 00:00", color: .white)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

