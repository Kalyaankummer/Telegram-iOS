import Foundation
import UIKit

/// Spring physics animator for all liquid glass animations
/// Provides consistent bounce, stretch, and tap animations
public final class GlassSpringAnimator {
    
    // MARK: - Spring Configuration
    
    public struct SpringConfig {
        public var damping: CGFloat
        public var stiffness: CGFloat
        public var mass: CGFloat
        public var initialVelocity: CGFloat
        
        public static var `default`: SpringConfig {
            return SpringConfig(
                damping: 0.7,
                stiffness: 300.0,
                mass: 1.0,
                initialVelocity: 0.0
            )
        }
        
        public static var bouncy: SpringConfig {
            return SpringConfig(
                damping: 0.5,
                stiffness: 400.0,
                mass: 0.8,
                initialVelocity: 0.0
            )
        }
        
        public static var gentle: SpringConfig {
            return SpringConfig(
                damping: 0.8,
                stiffness: 200.0,
                mass: 1.2,
                initialVelocity: 0.0
            )
        }
        
        public static var snappy: SpringConfig {
            return SpringConfig(
                damping: 0.6,
                stiffness: 500.0,
                mass: 0.6,
                initialVelocity: 0.0
            )
        }
        
        public var duration: TimeInterval {
            let dampingRatio = damping / (2 * sqrt(stiffness * mass))
            return TimeInterval(2 * .pi / sqrt(stiffness / mass)) * (1 + dampingRatio)
        }
        
        public var dampingRatio: CGFloat {
            return damping / (2 * sqrt(stiffness * mass))
        }
    }
    
    public var defaultConfig: SpringConfig
    private var activeAnimators: [UIViewPropertyAnimator] = []
    
    public init(config: SpringConfig = .default) {
        self.defaultConfig = config
    }
    
    public func animateTapDown(view: UIView, config: SpringConfig? = nil) {
        if LiquidGlassConfiguration.shared.isReduceMotionEnabled {
            view.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            return
        }
        
        let animator = UIViewPropertyAnimator(duration: 0.15, dampingRatio: 0.9) {
            view.transform = CGAffineTransform(scaleX: 0.92, y: 0.92)
        }
        animator.startAnimation()
        activeAnimators.append(animator)
    }
    
    public func animateTapUp(view: UIView, config: SpringConfig? = nil) {
        let cfg = config ?? defaultConfig
        
        if LiquidGlassConfiguration.shared.isReduceMotionEnabled {
            view.transform = .identity
            return
        }
        
        let animator = UIViewPropertyAnimator(duration: cfg.duration, dampingRatio: cfg.dampingRatio) {
            view.transform = .identity
        }
        animator.startAnimation()
        activeAnimators.append(animator)
    }
    
    public func animateTapBounce(view: UIView, completion: (() -> Void)? = nil) {
        if LiquidGlassConfiguration.shared.isReduceMotionEnabled {
            view.transform = .identity
            completion?()
            return
        }
        
        UIView.animate(withDuration: 0.1, delay: 0, options: [.curveEaseIn], animations: {
            view.transform = CGAffineTransform(scaleX: 0.92, y: 0.92)
        }) { _ in
            UIView.animate(withDuration: 0.15, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.8, options: [], animations: {
                view.transform = CGAffineTransform(scaleX: 1.02, y: 1.02)
            }) { _ in
                UIView.animate(withDuration: 0.1, delay: 0, options: [.curveEaseOut], animations: {
                    view.transform = .identity
                }) { _ in
                    completion?()
                }
            }
        }
    }
    
    public func animateSelection(view: UIView, selected: Bool, config: SpringConfig? = nil) {
        let cfg = config ?? SpringConfig.bouncy
        
        if LiquidGlassConfiguration.shared.isReduceMotionEnabled {
            view.transform = selected ? CGAffineTransform(scaleX: 1.05, y: 1.05) : .identity
            return
        }
        
        let scale: CGFloat = selected ? 1.08 : 1.0
        let animator = UIViewPropertyAnimator(duration: cfg.duration, dampingRatio: cfg.dampingRatio) {
            view.transform = CGAffineTransform(scaleX: scale, y: scale)
        }
        animator.startAnimation()
        activeAnimators.append(animator)
    }
    
    public func animateStretch(view: UIView, to frame: CGRect, config: SpringConfig? = nil, completion: (() -> Void)? = nil) {
        let cfg = config ?? defaultConfig
        
        if LiquidGlassConfiguration.shared.isReduceMotionEnabled {
            view.frame = frame
            completion?()
            return
        }
        
        let animator = UIViewPropertyAnimator(duration: cfg.duration, dampingRatio: cfg.dampingRatio) {
            view.frame = frame
        }
        animator.addCompletion { _ in completion?() }
        animator.startAnimation()
        activeAnimators.append(animator)
    }
    
    public func animateToggleWithBounce(view: UIView, to position: CGPoint, config: SpringConfig? = nil, completion: (() -> Void)? = nil) {
        let cfg = config ?? SpringConfig.bouncy
        
        if LiquidGlassConfiguration.shared.isReduceMotionEnabled {
            view.center = position
            completion?()
            return
        }
        
        let animator = UIViewPropertyAnimator(duration: cfg.duration, dampingRatio: cfg.dampingRatio) {
            view.center = position
        }
        
        UIView.animate(withDuration: 0.15, delay: 0, options: [.curveEaseOut], animations: {
            view.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }) { _ in
            UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: [], animations: {
                view.transform = .identity
            })
        }
        
        animator.addCompletion { _ in completion?() }
        animator.startAnimation()
        activeAnimators.append(animator)
    }
    
    public func animateDragStart(view: UIView, scale: CGFloat = 1.1) {
        if LiquidGlassConfiguration.shared.isReduceMotionEnabled {
            view.transform = CGAffineTransform(scaleX: scale, y: scale)
            return
        }
        
        let animator = UIViewPropertyAnimator(duration: 0.2, dampingRatio: 0.7) {
            view.transform = CGAffineTransform(scaleX: scale, y: scale)
        }
        animator.startAnimation()
        activeAnimators.append(animator)
    }
    
    public func animateDragEnd(view: UIView, config: SpringConfig? = nil) {
        let cfg = config ?? SpringConfig.bouncy
        
        if LiquidGlassConfiguration.shared.isReduceMotionEnabled {
            view.transform = .identity
            return
        }
        
        let animator = UIViewPropertyAnimator(duration: cfg.duration, dampingRatio: cfg.dampingRatio) {
            view.transform = .identity
        }
        animator.startAnimation()
        activeAnimators.append(animator)
    }
    
    public func cancelAllAnimations() {
        activeAnimators.forEach { $0.stopAnimation(true) }
        activeAnimators.removeAll()
    }
}