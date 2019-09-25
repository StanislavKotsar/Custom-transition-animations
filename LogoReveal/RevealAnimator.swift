//
//  RevealAnimator.swift
//  LogoReveal
//
//  Created by Станислав Коцарь on 25/09/2019.
//  Copyright © 2019 Razeware LLC. All rights reserved.
//

import UIKit

class RevealAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    let animationDuration = 2.0
    var operation: UINavigationController.Operation = .push
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return animationDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
    }
    

}
