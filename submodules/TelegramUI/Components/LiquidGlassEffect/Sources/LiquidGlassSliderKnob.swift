import Foundation
import UIKit

public final class LiquidGlassSliderKnob: UIView {
    private let glassView: LiquidGlassView
    private let centerDot: UIView
    
    public var isDark: Bool = false {
        didSet {
            if oldValue != isDark {
                glassView.isDark = isDark
                updateCenterDot()
            }
        }
    }
    
    public var isTracking: Bool = false {
        didSet {
            if oldValue != isTracking {
                updateTrackingState()
            }
        }
    }
    
    public init() {
        self.glassView = LiquidGlassView(blurRadius: 18.0)
        self.centerDot = UIView()
        
        super.init(frame: .zero)
        
        setupKnob()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupKnob() {
        addSubview(glassView)
        
        // Enable chromatic border
        glassView.showsChromaticBorder = true
        glassView.chromaticBorder.borderWidth = 1.5
        
        // Moderate refraction
        glassView.refractionIntensity = 0.4
        
        // Setup center dot
        centerDot.layer.cornerRadius = 2.0
        centerDot.layer.cornerCurve = .continuous
        updateCenterDot()
        glassView.contentView.addSubview(centerDot)
    }
    
    private func updateCenterDot() {
        centerDot.backgroundColor = isDark ? UIColor.white.withAlphaComponent(0.8) : UIColor.black.withAlphaComponent(0.6)
    }
    
    private func updateTrackingState() {
        if isTracking {
            // Scale up and increase refraction when tracking
            GlassSpringAnimator.animateSpring(
                duration: 0.2,
                dampingRatio: 0.6,
                animations: {
                    self.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
                    self.glassView.setRefractionIntensity(0.6, animated: false)
                }
            )
        } else {
            // Return to normal
            GlassSpringAnimator.animateSpring(
                duration: 0.3,
                dampingRatio: 0.7,
                animations: {
                    self.transform = .identity
                    self.glassView.setRefractionIntensity(0.4, animated: false)
                }
            )
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        glassView.frame = bounds
        
        // Vertical pill shape
        glassView.cornerRadius = bounds.width / 2
        
        // Center dot
        let dotSize: CGFloat = 4.0
        centerDot.frame = CGRect(
            x: (bounds.width - dotSize) / 2,
            y: (bounds.height - dotSize) / 2,
            width: dotSize,
            height: dotSize
        )
        centerDot.layer.cornerRadius = dotSize / 2
    }
    
    public override var intrinsicContentSize: CGSize {
        return CGSize(width: 28.0, height: 42.0)
    }
    
    // Animation for value changes
    public func animateValueChange() {
        GlassSpringAnimator.animateWobble(view: self, angle: 0.08, duration: 0.4)
    }
}
