import Foundation
import UIKit

public final class LiquidGlassSwitchThumb: UIView {
    private let glassView: LiquidGlassView
    private var isOn: Bool = false
    
    public var isDark: Bool = false {
        didSet {
            if oldValue != isDark {
                glassView.isDark = isDark
            }
        }
    }
    
    public init() {
        self.glassView = LiquidGlassView(blurRadius: 15.0)
        
        super.init(frame: .zero)
        
        setupThumb()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupThumb() {
        addSubview(glassView)
        
        // Enable chromatic border for glass effect
        glassView.showsChromaticBorder = true
        glassView.chromaticBorder.borderWidth = 1.5
        
        // Subtle refraction
        glassView.refractionIntensity = 0.3
    }
    
    public func setOn(_ on: Bool, animated: Bool) {
        self.isOn = on
        
        if animated {
            GlassSpringAnimator.animateSpring(
                duration: 0.3,
                dampingRatio: 0.7,
                animations: {
                    self.updateAppearance()
                }
            )
        } else {
            updateAppearance()
        }
    }
    
    private func updateAppearance() {
        // Increase refraction when on
        glassView.setRefractionIntensity(isOn ? 0.5 : 0.3, animated: false)
        
        // Subtle scale change
        let scale: CGFloat = isOn ? 1.05 : 1.0
        transform = CGAffineTransform(scaleX: scale, y: scale)
    }
    
    public func animateTransition() {
        // Pulse animation during state change
        GlassSpringAnimator.animatePulse(view: glassView, scale: 1.1, duration: 0.4)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        glassView.frame = bounds
        
        // Make it circular
        glassView.cornerRadius = bounds.width / 2
    }
    
    public override var intrinsicContentSize: CGSize {
        if #available(iOS 26.0, *) {
            return CGSize(width: 28.0, height: 28.0)
        } else {
            return CGSize(width: 27.0, height: 27.0)
        }
    }
}
