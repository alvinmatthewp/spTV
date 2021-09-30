//
//  PlayerControlView.swift
//  bcTV
//
//  Created by alvin.pratama on 29/09/21.
//

import UIKit
import ComposableArchitecture
import Combine
import SuperPlayer

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
    
    public var playButtonTapped: Effect<Void, Never> {
        return playButton.publisher(for: UIControl.Event.touchUpInside).map { _ in }.eraseToEffect()
    }
    
    private let store: Store<SuperPlayerControlState, SuperPlayerAction>
    private let viewStore: ViewStore<SuperPlayerControlState, SuperPlayerAction>
    private var disposeBag = Set<AnyCancellable>()

    public init(store: Store<SuperPlayerControlState, SuperPlayerAction>) {
        self.store = store
        viewStore = ViewStore(store)
        seekBar = PlayerSeekBarView(
            store: store.scope(state: { $0 })
        )

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
        
        viewStore.publisher.playIcon
            .sink { [weak self] icon in
                guard let self = self else { return }
                let image = UIImage(systemName: icon == "pip_pause" ? "pause.fill" : "play.fill")
                self.playButton.setImage(image, for: .normal)
                self.setNeedsLayout()
            }
            .store(in: &disposeBag)
        
        viewStore.publisher.actualDuration
            .sink { [weak self] actualDuration in
                guard let self = self else { return }
                if actualDuration.seconds >= 3600 {
                    // 00:00:00 / 00:00:00
                    timeIndicatorWidthConstraint.constant = 118
                } else {
                    // 00:00 / 00:00
                    timeIndicatorWidthConstraint.constant = 80
                }
                self.setNeedsLayout()
            }
            .store(in: &disposeBag)
            
        Publishers.CombineLatest(viewStore.publisher.currentTimeLabel, viewStore.publisher.actualDurationLabel)
            .map { currentTimeLabel, actualDuration in
                NSAttributedString .body3(currentTimeLabel + " / " + actualDuration, color: .white)
            }
            .sink { [weak self] currentTimeLabel in
                guard let self = self else { return }
                self.timeIndicator.attributedText = currentTimeLabel
                self.setNeedsLayout()
            }
            .store(in: &disposeBag)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

