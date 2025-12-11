import Foundation
import UIKit

public final class GlassSpringAnimator {
    private static let config = LiquidGlassConfiguration.shared
    
    // Spring animation with UIViewPropertyAnimator
    public static func animateSpring(
        duration: TimeInterval = 0.5,
        dampingRatio: CGFloat? = nil,
        velocity: CGFloat = 0,
        animations: @escaping () -> Void,
        completion: ((Bool) -> Void)? = nil
    ) {
        let damping = dampingRatio ?? config.springDamping
        
        let animator = UIViewPropertyAnimator(
            duration: duration,
            dampingRatio: damping,
            animations: animations
        )
        
        if let completion = completion {
            animator.addCompletion { position in
                completion(position == .end)
            }
        }
        
        animator.startAnimation()
    }
    
    // Scale animation for tap feedback
    public static func animateTapScale(
        view: UIView,
        scaleDown: CGFloat? = nil,
        scaleBounce: CGFloat? = nil,
        completion: (() -> Void)? = nil
    ) {
        let down = scaleDown ?? config.tapScaleDown
        let bounce = scaleBounce ?? config.tapScaleBounce
        
        // Scale down
        UIView.animate(
            withDuration: 0.1,
            delay: 0,
            options: [.curveEaseOut, .allowUserInteraction],
            animations: {
                view.transform = CGAffineTransform(scaleX: down, y: down)
            },
            completion: { _ in
                // Bounce to slightly larger
                UIView.animate(
                    withDuration: 0.15,
                    delay: 0,
                    options: [.curveEaseInOut, .allowUserInteraction],
                    animations: {
                        view.transform = CGAffineTransform(scaleX: bounce, y: bounce)
                    },
                    completion: { _ in
                        // Return to normal
                        self.animateSpring(
                            duration: 0.3,
                            animations: {
                                view.transform = .identity
                            },
                            completion: { _ in
                                completion?()
                            }
                        )
                    }
                )
            }
        )
    }
    
    // Pulse animation
    public static func animatePulse(
        view: UIView,
        scale: CGFloat = 1.1,
        duration: TimeInterval = 0.6
    ) {
        animateSpring(
            duration: duration / 2,
            animations: {
                view.transform = CGAffineTransform(scaleX: scale, y: scale)
            },
            completion: { _ in
                self.animateSpring(
                    duration: duration / 2,
                    animations: {
                        view.transform = .identity
                    }
                )
            }
        )
    }
    
    // Stretch animation for lens
    public static func animateStretch(
        view: UIView,
        scaleX: CGFloat,
        scaleY: CGFloat,
        duration: TimeInterval = 0.4,
        completion: (() -> Void)? = nil
    ) {
        animateSpring(
            duration: duration,
            animations: {
                view.transform = CGAffineTransform(scaleX: scaleX, y: scaleY)
            },
            completion: { _ in
                completion?()
            }
        )
    }
    
    // Wobble animation
    public static func animateWobble(
        view: UIView,
        angle: CGFloat = 0.05,
        duration: TimeInterval = 0.5
    ) {
        let rotation1 = CGAffineTransform(rotationAngle: angle)
        let rotation2 = CGAffineTransform(rotationAngle: -angle)
        
        UIView.animate(
            withDuration: duration / 4,
            animations: {
                view.transform = rotation1
            },
            completion: { _ in
                UIView.animate(
                    withDuration: duration / 2,
                    animations: {
                        view.transform = rotation2
                    },
                    completion: { _ in
                        self.animateSpring(
                            duration: duration / 4,
                            animations: {
                                view.transform = .identity
                            }
                        )
                    }
                )
            }
        )
    }
}
