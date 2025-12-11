import Foundation
import UIKit

public final class LiquidGlassTabLens: UIView {
    private let glassView: LiquidGlassView
    private var isSelected: Bool = false
    
    public var isDark: Bool = false {
        didSet {
            if oldValue != isDark {
                glassView.isDark = isDark
            }
        }
    }
    
    public init() {
        self.glassView = LiquidGlassView(blurRadius: 25.0)
        
        super.init(frame: .zero)
        
        setupLens()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLens() {
        addSubview(glassView)
        
        // Enable chromatic border for lens effect
        glassView.showsChromaticBorder = true
        glassView.chromaticBorder.borderWidth = 2.0
        
        // Strong refraction for lens effect
        glassView.refractionIntensity = 0.7
        
        // Initially hidden
        alpha = 0.0
        transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
    }
    
    public func setSelected(_ selected: Bool, animated: Bool) {
        guard selected != isSelected else { return }
        
        isSelected = selected
        
        if animated {
            if selected {
                animateIn()
            } else {
                animateOut()
            }
        } else {
            alpha = selected ? 1.0 : 0.0
            transform = selected ? .identity : CGAffineTransform(scaleX: 0.8, y: 0.8)
        }
    }
    
    private func animateIn() {
        // Stretch animation on selection
        alpha = 1.0
        
        // Animate with stretch effect
        GlassSpringAnimator.animateStretch(
            view: self,
            scaleX: 1.15,
            scaleY: 0.9,
            duration: 0.15
        ) {
            // Bounce back to normal with spring
            GlassSpringAnimator.animateSpring(
                duration: 0.35,
                dampingRatio: 0.65,
                animations: {
                    self.transform = .identity
                }
            )
        }
        
        // Increase refraction during animation
        glassView.setRefractionIntensity(0.9, animated: true)
        
        // After animation, settle to normal refraction
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.glassView.setRefractionIntensity(0.7, animated: true)
        }
    }
    
    private func animateOut() {
        // Scale down with spring
        GlassSpringAnimator.animateSpring(
            duration: 0.25,
            dampingRatio: 0.8,
            animations: {
                self.alpha = 0.0
                self.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            }
        )
        
        // Reduce refraction
        glassView.setRefractionIntensity(0.4, animated: true)
    }
    
    public func animateToPosition(_ position: CGPoint, animated: Bool) {
        if animated {
            GlassSpringAnimator.animateSpring(
                duration: 0.4,
                dampingRatio: 0.75,
                animations: {
                    self.center = position
                }
            )
        } else {
            center = position
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        glassView.frame = bounds
        
        // Pill shape for tab lens
        glassView.cornerRadius = bounds.height / 2
    }
    
    // Respond to touch
    public func animateTouchDown() {
        GlassSpringAnimator.animateSpring(
            duration: 0.15,
            dampingRatio: 1.0,
            animations: {
                self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            }
        )
    }
    
    public func animateTouchUp() {
        GlassSpringAnimator.animateSpring(
            duration: 0.3,
            dampingRatio: 0.7,
            animations: {
                self.transform = .identity
            }
        )
    }
}
