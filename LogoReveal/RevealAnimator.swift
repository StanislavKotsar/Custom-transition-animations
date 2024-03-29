//
//  RevealAnimator.swift
//  LogoReveal
//
//  Created by Станислав Коцарь on 25/09/2019.
//  Copyright © 2019 Razeware LLC. All rights reserved.
//

import UIKit

class RevealAnimator: UIPercentDrivenInteractiveTransition,
  UIViewControllerAnimatedTransitioning, CAAnimationDelegate {
    
    let animationDuration = 1.2
    var operation: UINavigationController.Operation = .push
    var interactive = false
    private var pausedTime: CFTimeInterval = 0
    weak var storedContext: UIViewControllerContextTransitioning?
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return animationDuration
    }
    
    override func update(_ percentComplete: CGFloat) {
      super.update(percentComplete)
      let animationProgress = TimeInterval(animationDuration) * TimeInterval(percentComplete)
      storedContext?.containerView.layer.timeOffset = pausedTime + animationProgress
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if interactive {
          let transitionLayer = transitionContext.containerView.layer
          pausedTime = transitionLayer.convertTime(CACurrentMediaTime(), from: nil)
          transitionLayer.speed = 0
          transitionLayer.timeOffset = pausedTime
        }
        
        storedContext = transitionContext
        if operation == .push {
                let fromVC = transitionContext.viewController(forKey:
                  .from) as! MasterViewController
                let toVC = transitionContext.viewController(forKey:
                  .to) as! DetailViewController

                transitionContext.containerView.addSubview(toVC.view)
                toVC.view.frame = transitionContext.finalFrame(for: toVC)
                
                let animation = CABasicAnimation(keyPath: "transform")
                animation.fromValue =
                  NSValue(caTransform3D: CATransform3DIdentity)
                animation.toValue =
                  NSValue(caTransform3D:
                  CATransform3DConcat(
                    CATransform3DMakeTranslation(0.0, -10.0, 0.0),
                    CATransform3DMakeScale(150.0, 150.0, 1.0)
                  )
                )
                
                animation.duration = animationDuration
                animation.delegate = self
                animation.fillMode = .forwards
                animation.isRemovedOnCompletion = false
                animation.timingFunction = CAMediaTimingFunction(name:
                  .easeIn)
            
                let maskLayer: CAShapeLayer = RWLogoLayer.logoLayer()
                maskLayer.position = fromVC.logo.position
                toVC.view.layer.mask = maskLayer
                maskLayer.add(animation, forKey: nil)
                fromVC.logo.add(animation, forKey: nil)
                // fade-in animation
                let fadeInAnimation = CABasicAnimation(keyPath: "opacity")
                fadeInAnimation.fromValue = 0
                fadeInAnimation.toValue = 1
                fadeInAnimation.duration = animationDuration
                toVC.view.layer.add(fadeInAnimation, forKey: nil)
        } else {
            guard let fromVC = transitionContext.view(forKey: .from),
                  let toVC = transitionContext.view(forKey: .to) else { return }
            
            transitionContext.containerView.addSubview(fromVC)
            transitionContext.containerView.insertSubview(toVC, belowSubview: fromVC)
            
            UIView.animate(withDuration: animationDuration, animations: {
                fromVC.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                fromVC.layer.opacity = 0
            }) { _ in
                transitionContext.completeTransition(true)
            }
        }
    }
    
    override func cancel() {
      restart(forFinishing: false)
      super.cancel()
    }

    override func finish() {
      restart(forFinishing: true)
      super.finish()
    }

    private func restart(forFinishing: Bool) {
      let transitionLayer = storedContext?.containerView.layer
      transitionLayer?.beginTime = CACurrentMediaTime()
      transitionLayer?.speed = forFinishing ? 1 : -1
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
      if let context = storedContext {
        context.completeTransition(!context.transitionWasCancelled)
        let fromVC = context.viewController(forKey: .from)
          as! MasterViewController
        fromVC.logo.removeAllAnimations()
        let toVC = context.viewController(forKey: .to)
          as! DetailViewController
        toVC.view.layer.mask = nil
        
      }
      storedContext = nil
    }
    
    func handlePan(_ recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in:
          recognizer.view!.superview!)
        var progress: CGFloat = abs(translation.x / 200.0)
        progress = min(max(progress, 0.01), 0.99)
        
        switch recognizer.state {
          case .changed:
            update(progress)
          case .cancelled, .ended:
            if progress < 0.5 {
              cancel()
            } else {
              finish()
            }
            interactive = false
          default:
            break
        }
    }

}
