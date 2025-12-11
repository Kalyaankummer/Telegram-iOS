import Foundation
import UIKit

/// Animated rainbow/prismatic border effect using conic gradient
public final class ChromaticBorderView: UIView {
    
    private let gradientLayer = CAGradientLayer()
    private var rotationAnimation: CABasicAnimation?
    
    public var borderWidth: CGFloat = 2.0 {
        didSet {
            updateBorder()
        }
    }
    
    public var animationDuration: TimeInterval = 3.0 {
        didSet {
            if isAnimating {
                stopAnimation()
                startAnimation()
            }
        }
    }
    
    public var isAnimating: Bool = false
    
    public init() {
        super.init(frame: .zero)
        setup()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        isUserInteractionEnabled = false
        backgroundColor = .clear
        
        // Setup gradient layer with chromatic colors
        gradientLayer.type = .conic
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.0)
        
        // Create rainbow colors for chromatic effect
        let colors: [CGColor] = [
            UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0).cgColor,    // Red
            UIColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 1.0).cgColor,    // Orange
            UIColor(red: 1.0, green: 1.0, blue: 0.0, alpha: 1.0).cgColor,    // Yellow
            UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0).cgColor,    // Green
            UIColor(red: 0.0, green: 0.5, blue: 1.0, alpha: 1.0).cgColor,    // Cyan
            UIColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 1.0).cgColor,    // Blue
            UIColor(red: 0.5, green: 0.0, blue: 1.0, alpha: 1.0).cgColor,    // Purple
            UIColor(red: 1.0, green: 0.0, blue: 0.5, alpha: 1.0).cgColor,    // Magenta
            UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0).cgColor     // Red (loop)
        ]
        
        gradientLayer.colors = colors
        layer.addSublayer(gradientLayer)
        
        // Setup mask for border effect
        updateBorder()
    }
    
    private func updateBorder() {
        // Create a mask that shows only the border
        let maskLayer = CAShapeLayer()
        maskLayer.fillRule = .evenOdd
        
        let outerPath = UIBezierPath(roundedRect: bounds, cornerRadius: bounds.height / 2.0)
        let innerRect = bounds.insetBy(dx: borderWidth, dy: borderWidth)
        let innerPath = UIBezierPath(roundedRect: innerRect, cornerRadius: innerRect.height / 2.0)
        
        outerPath.append(innerPath)
        maskLayer.path = outerPath.cgPath
        
        gradientLayer.mask = maskLayer
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        gradientLayer.frame = bounds
        updateBorder()
    }
    
    // MARK: - Animation
    
    public func startAnimation() {
        guard LiquidGlassConfiguration.shared.shouldEnableChromaticBorder else { return }
        guard !isAnimating else { return }
        
        isAnimating = true
        
        let rotation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.fromValue = 0.0
        rotation.toValue = CGFloat.pi * 2.0
        rotation.duration = animationDuration
        rotation.repeatCount = .infinity
        rotation.timingFunction = CAMediaTimingFunction(name: .linear)
        
        gradientLayer.add(rotation, forKey: "rotation")
        rotationAnimation = rotation
    }
    
    public func stopAnimation() {
        guard isAnimating else { return }
        
        isAnimating = false
        gradientLayer.removeAnimation(forKey: "rotation")
        rotationAnimation = nil
    }
    
    public func pauseAnimation() {
        guard isAnimating else { return }
        
        let pausedTime = gradientLayer.convertTime(CACurrentMediaTime(), from: nil)
        gradientLayer.speed = 0.0
        gradientLayer.timeOffset = pausedTime
    }
    
    public func resumeAnimation() {
        guard isAnimating else { return }
        
        let pausedTime = gradientLayer.timeOffset
        gradientLayer.speed = 1.0
        gradientLayer.timeOffset = 0.0
        gradientLayer.beginTime = 0.0
        let timeSincePause = gradientLayer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
        gradientLayer.beginTime = timeSincePause
    }
    
    // MARK: - Intensity Control
    
    public func setOpacity(_ opacity: CGFloat, animated: Bool = true) {
        if animated {
            UIView.animate(withDuration: 0.3) {
                self.alpha = opacity
            }
        } else {
            self.alpha = opacity
        }
    }
}
