import Foundation
import UIKit

/// Spring physics animator for glass UI interactions
public final class GlassSpringAnimator {
    
    // MARK: - Spring Parameters
    
    public struct SpringParameters {
        let damping: CGFloat
        let stiffness: CGFloat
        let mass: CGFloat
        let initialVelocity: CGFloat
        
        public init(damping: CGFloat = 15.0, stiffness: CGFloat = 300.0, mass: CGFloat = 1.0, initialVelocity: CGFloat = 0.0) {
            self.damping = damping
            self.stiffness = stiffness
            self.mass = mass
            self.initialVelocity = initialVelocity
        }
        
        // Preset configurations
        public static let gentle = SpringParameters(damping: 20.0, stiffness: 200.0, mass: 1.0)
        public static let bouncy = SpringParameters(damping: 10.0, stiffness: 300.0, mass: 1.0)
        public static let snappy = SpringParameters(damping: 15.0, stiffness: 400.0, mass: 0.8)
        public static let smooth = SpringParameters(damping: 25.0, stiffness: 250.0, mass: 1.0)
    }
    
    // MARK: - Animation Types
    
    /// Tap animation - subtle scale and alpha change
    public static func animateTap(view: UIView, completion: (() -> Void)? = nil) {
        guard LiquidGlassConfiguration.shared.shouldEnableSpringAnimations else {
            completion?()
            return
        }
        
        let scaleDown = CASpringAnimation(keyPath: "transform.scale")
        scaleDown.damping = 15.0
        scaleDown.stiffness = 400.0
        scaleDown.mass = 0.8
        scaleDown.duration = 0.15
        scaleDown.fromValue = 1.0
        scaleDown.toValue = 0.95
        scaleDown.fillMode = .forwards
        scaleDown.isRemovedOnCompletion = false
        
        view.layer.add(scaleDown, forKey: "tapScaleDown")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            let scaleUp = CASpringAnimation(keyPath: "transform.scale")
            scaleUp.damping = 15.0
            scaleUp.stiffness = 400.0
            scaleUp.mass = 0.8
            scaleUp.duration = 0.3
            scaleUp.fromValue = 0.95
            scaleUp.toValue = 1.0
            scaleUp.fillMode = .forwards
            scaleUp.isRemovedOnCompletion = true
            
            view.layer.add(scaleUp, forKey: "tapScaleUp")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                completion?()
            }
        }
    }
    
    /// Bounce animation - playful bounce effect
    public static func animateBounce(view: UIView, intensity: CGFloat = 1.2, completion: (() -> Void)? = nil) {
        guard LiquidGlassConfiguration.shared.shouldEnableSpringAnimations else {
            completion?()
            return
        }
        
        let bounce = CASpringAnimation(keyPath: "transform.scale")
        bounce.damping = 10.0
        bounce.stiffness = 300.0
        bounce.mass = 1.0
        bounce.duration = 0.6
        bounce.fromValue = 1.0
        bounce.toValue = intensity
        bounce.fillMode = .forwards
        bounce.isRemovedOnCompletion = false
        
        view.layer.add(bounce, forKey: "bounce")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let bounceBack = CASpringAnimation(keyPath: "transform.scale")
            bounceBack.damping = 15.0
            bounceBack.stiffness = 300.0
            bounceBack.mass = 1.0
            bounceBack.duration = 0.6
            bounceBack.fromValue = intensity
            bounceBack.toValue = 1.0
            bounceBack.fillMode = .forwards
            bounceBack.isRemovedOnCompletion = true
            
            view.layer.add(bounceBack, forKey: "bounceBack")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                completion?()
            }
        }
    }
    
    /// Stretch animation - elastic stretch and snap back
    public static func animateStretch(view: UIView, from: CGFloat, to: CGFloat, axis: StretchAxis = .horizontal, parameters: SpringParameters = .bouncy, completion: (() -> Void)? = nil) {
        guard LiquidGlassConfiguration.shared.shouldEnableSpringAnimations else {
            completion?()
            return
        }
        
        let keyPath: String
        switch axis {
        case .horizontal:
            keyPath = "transform.scale.x"
        case .vertical:
            keyPath = "transform.scale.y"
        case .both:
            keyPath = "transform.scale"
        }
        
        let stretch = CASpringAnimation(keyPath: keyPath)
        stretch.damping = parameters.damping
        stretch.stiffness = parameters.stiffness
        stretch.mass = parameters.mass
        stretch.initialVelocity = parameters.initialVelocity
        stretch.duration = stretch.settlingDuration
        stretch.fromValue = from
        stretch.toValue = to
        stretch.fillMode = .forwards
        stretch.isRemovedOnCompletion = true
        
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            completion?()
        }
        
        view.layer.add(stretch, forKey: "stretch")
        
        CATransaction.commit()
    }
    
    public enum StretchAxis {
        case horizontal
        case vertical
        case both
    }
    
    /// Toggle animation - smooth state transition
    public static func animateToggle(view: UIView, isOn: Bool, parameters: SpringParameters = .smooth, completion: (() -> Void)? = nil) {
        guard LiquidGlassConfiguration.shared.shouldEnableSpringAnimations else {
            completion?()
            return
        }
        
        let scaleAnimation = CASpringAnimation(keyPath: "transform.scale")
        scaleAnimation.damping = parameters.damping
        scaleAnimation.stiffness = parameters.stiffness
        scaleAnimation.mass = parameters.mass
        scaleAnimation.duration = scaleAnimation.settlingDuration
        scaleAnimation.fromValue = isOn ? 0.9 : 1.0
        scaleAnimation.toValue = isOn ? 1.0 : 0.9
        scaleAnimation.fillMode = .forwards
        scaleAnimation.isRemovedOnCompletion = true
        
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            completion?()
        }
        
        view.layer.add(scaleAnimation, forKey: "toggle")
        
        CATransaction.commit()
    }
    
    /// Generic spring animation for any animatable property
    public static func animate(
        view: UIView,
        keyPath: String,
        from: Any,
        to: Any,
        parameters: SpringParameters = .bouncy,
        completion: (() -> Void)? = nil
    ) {
        guard LiquidGlassConfiguration.shared.shouldEnableSpringAnimations else {
            completion?()
            return
        }
        
        let animation = CASpringAnimation(keyPath: keyPath)
        animation.damping = parameters.damping
        animation.stiffness = parameters.stiffness
        animation.mass = parameters.mass
        animation.initialVelocity = parameters.initialVelocity
        animation.duration = animation.settlingDuration
        animation.fromValue = from
        animation.toValue = to
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = true
        
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            completion?()
        }
        
        view.layer.add(animation, forKey: "customSpring")
        
        CATransaction.commit()
    }
    
    /// UIView-based spring animation wrapper
    public static func springAnimate(
        duration: TimeInterval = 0.6,
        delay: TimeInterval = 0.0,
        damping: CGFloat = 0.7,
        velocity: CGFloat = 0.5,
        animations: @escaping () -> Void,
        completion: ((Bool) -> Void)? = nil
    ) {
        guard LiquidGlassConfiguration.shared.shouldEnableSpringAnimations else {
            animations()
            completion?(true)
            return
        }
        
        UIView.animate(
            withDuration: duration,
            delay: delay,
            usingSpringWithDamping: damping,
            initialSpringVelocity: velocity,
            options: [.curveEaseInOut, .allowUserInteraction],
            animations: animations,
            completion: completion
        )
    }
}
