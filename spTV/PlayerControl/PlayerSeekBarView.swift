//
//  PlayerSeekBarView.swift
//  bcTV
//
//  Created by alvin.pratama on 29/09/21.
//

import UIKit

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

    public init() {
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
    }

    @objc internal func panAction(pan: UIPanGestureRecognizer) {
        let velocity = pan.velocity(in: seekerNode)
        guard abs(velocity.x) > abs(velocity.y) else {
            return
        }

        let point = pan.location(in: barNode)
        if point.x >= 0, point.x <= barNode.frame.width {
            // do something
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
