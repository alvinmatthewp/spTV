//
//  PlayerSeekBarView.swift
//  bcTV
//
//  Created by alvin.pratama on 29/09/21.
//

import UIKit
import Combine
import ComposableArchitecture
import SuperPlayer

internal final class PlayerSeekBarView: UIView {

    private static var timelineHeight: CGFloat {
        PlayerControlView.height / 8
    }

    private static var seekerRadius: CGFloat {
        PlayerControlView.height / 4
    }

    private static let cornerRadius: CGFloat = 4

    private let barNode: UIView = {
        let node = UIView()
        node.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        return node
    }()

    private let seekerNode: UIButton = {
        let node = UIButton()
        node.backgroundColor = .white
        return node
    }()

    private let loadedTimeNode: UIView = {
        let node = UIView()
        node.backgroundColor = .white
        node.layer.cornerRadius = PlayerSeekBarView.cornerRadius
        return node
    }()
    
    private let store: Store<SuperPlayerControlState, SuperPlayerAction>
    private let viewStore: ViewStore<SuperPlayerControlState, SuperPlayerAction>
    private var disposeBag = Set<AnyCancellable>()
    
    var barNodeDidLayout: Bool = false
    
    public init(store: Store<SuperPlayerControlState, SuperPlayerAction>) {
        self.store = store
        self.viewStore = ViewStore(store)

        super.init(frame: .zero)
        
        seekerNode.layer.cornerRadius = PlayerSeekBarView.seekerRadius
        barNode.layer.cornerRadius = PlayerSeekBarView.cornerRadius
        
        addSubview(barNode)
        addSubview(loadedTimeNode)
        addSubview(seekerNode)
        
        barNode.translatesAutoresizingMaskIntoConstraints = false
        seekerNode.translatesAutoresizingMaskIntoConstraints = false
        loadedTimeNode.translatesAutoresizingMaskIntoConstraints = false
        
        let loadedTimeNodeWidthConstraint = loadedTimeNode.widthAnchor.constraint(equalToConstant: 0)
        let seekerPositionConstraint = seekerNode.leadingAnchor.constraint(equalTo: leadingAnchor, constant: PlayerSeekBarView.seekerRadius)
        
        NSLayoutConstraint.activate([
            barNode.leadingAnchor.constraint(equalTo: leadingAnchor, constant: PlayerSeekBarView.seekerRadius),
            barNode.trailingAnchor.constraint(equalTo: trailingAnchor, constant: PlayerSeekBarView.seekerRadius),
            barNode.centerYAnchor.constraint(equalTo: centerYAnchor),
            barNode.heightAnchor.constraint(equalToConstant: PlayerSeekBarView.timelineHeight),
            
            loadedTimeNode.centerYAnchor.constraint(equalTo: centerYAnchor),
            loadedTimeNode.heightAnchor.constraint(equalToConstant: PlayerSeekBarView.timelineHeight),
            loadedTimeNodeWidthConstraint,
            
            seekerNode.centerYAnchor.constraint(equalTo: barNode.centerYAnchor),
            seekerNode.heightAnchor.constraint(equalToConstant: PlayerControlView.height / 2),
            seekerNode.widthAnchor.constraint(equalToConstant: PlayerControlView.height / 2),
            seekerPositionConstraint,
        ])
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panAction(pan:)))
        pan.cancelsTouchesInView = true
        seekerNode.isUserInteractionEnabled = true
        seekerNode.addGestureRecognizer(pan)
        
        viewStore.publisher.loadedTimes
            .sink { [weak self] loadedTimes in
                guard let self = self, let lastLoadedTime = loadedTimes.last else { return }
                loadedTimeNodeWidthConstraint.constant = lastLoadedTime.barOffset + lastLoadedTime.barWidth
                self.setNeedsLayout()
            }
            .store(in: &disposeBag)

        viewStore.publisher.seekerPosition
            .sink { [weak self] seekerPosition in
                seekerPositionConstraint.constant = seekerPosition
                self?.setNeedsLayout()
            }
            .store(in: &disposeBag)
        
        seekerNode.publisher(for: UIControl.Event.touchDown)
            .sink { [viewStore] _ in
                // before we start seeking time, we need to pause the player first
                // common UX used in almost streaming platforms (Youtube, Netflix, Hotstar, etc.)
                viewStore.send(.player(.callMethod(.pause)))
            }
            .store(in: &disposeBag)
        
        seekerNode.publisher(for: UIControl.Event.touchUpInside)
            .sink { [viewStore] _ in
                viewStore.send(.player(.callMethod(.play)))
            }
            .store(in: &disposeBag)
    }
    
    override internal func layoutSubviews() {
        super.layoutSubviews()
        
        if !barNodeDidLayout && barNode.frame != .zero {
            barNodeDidLayout = true
            viewStore.send(.seekBarWidth(barNode.frame.width))
        }
    }

    @objc internal func panAction(pan: UIPanGestureRecognizer) {
        let velocity = pan.velocity(in: seekerNode)
        guard abs(velocity.x) > abs(velocity.y) else {
            return
        }

        let point = pan.location(in: barNode)
        if point.x >= 0, point.x <= barNode.frame.width {
            viewStore.send(.slidingSeeker(to: point.x))
        }
        
        if pan.state == .ended {
            viewStore.send(.doneSeeking)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
