//
//  ViewController.swift
//  InteractiveAnimation
//
//  Created by Toomas Vahter on 23/04/2019.
//  Copyright © 2019 Augmented Code. All rights reserved.
//

import UIKit

final class ViewController: UIViewController {
    private lazy var animatingView: UIView = {
        let view = GradientView(frame: .zero)
        view.gradientLayer.colors = (1...3).map({ "Gradient\($0)" }).map({ UIColor(named: $0)!.cgColor })
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .darkGray
        view.addGestureRecognizer(gestureRecognizer)
        view.addSubview(animatingView)
        NSLayoutConstraint.activate([
            animatingView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 72),
            animatingView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -72),
            animatingView.topAnchor.constraint(equalTo: view.topAnchor, constant: 72),
            animatingView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -72)
            ])
    }
    
    private func makeAnimator() -> UIViewPropertyAnimator {
        let animator = UIViewPropertyAnimator(duration: 2.0, curve: .easeInOut)
        let bounds = view.bounds
        animator.addAnimations { [weak animatingView] in
            guard let animatingView = animatingView else { return }
            animatingView.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 2.0)
            UIView.animateKeyframes(withDuration: 2.0, delay: 0.0, options: .calculationModeCubic, animations: {
                UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.4, animations: {
                    animatingView.center = CGPoint(x: bounds.width * 0.8, y: bounds.height * 0.85)
                })
                UIView.addKeyframe(withRelativeStartTime: 0.4, relativeDuration: 0.6, animations: {
                    animatingView.center = CGPoint(x: bounds.width + animatingView.bounds.height, y: bounds.height * 0.6)
                })
            })
        }
        animator.addCompletion({ [weak self] (_) in
            guard let self = self else { return }
            self.animatingView.transform = CGAffineTransform(rotationAngle: 0.0)
            self.animator = nil
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
        })
        return animator
    }
    
    private var animator: UIViewPropertyAnimator?
    private var dragStartPosition: CGPoint = .zero
    private var fractionCompletedStart: CGFloat = 0
    
    private lazy var gestureRecognizer: UIPanGestureRecognizer = {
        let recognizer = UIPanGestureRecognizer(target: self, action: #selector(updateProgress(_:)))
        recognizer.maximumNumberOfTouches = 1
        return recognizer
    }()
    
    @objc private func updateProgress(_ recognizer: UIPanGestureRecognizer) {
        if animator == nil {
            animator = makeAnimator()
        }
        guard let animator = animator else { return }
        switch recognizer.state {
        case .began:
            animator.pauseAnimation()
            fractionCompletedStart = animator.fractionComplete
            dragStartPosition = recognizer.location(in: view)
        case .changed:
            animator.pauseAnimation()
            let delta = recognizer.location(in: view).x - dragStartPosition.x
            animator.fractionComplete = max(0.0, min(1.0, fractionCompletedStart + delta / 300.0))
        case .ended:
            animator.startAnimation()
        default:
            break
        }
    }
}

final class GradientView: UIView {
    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    var gradientLayer: CAGradientLayer {
        return layer as! CAGradientLayer
    }
}
