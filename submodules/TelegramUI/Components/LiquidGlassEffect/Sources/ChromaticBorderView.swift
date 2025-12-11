import Foundation
import UIKit

/// A view that creates a rainbow/prismatic border effect for glass elements
/// Uses CAGradientLayer with conic gradient for chromatic aberration look
public final class ChromaticBorderView: UIView {
    
    // MARK: - Properties
    
    /// Width of the chromatic border
    public var borderWidth: CGFloat = 1.5 {
        didSet {
            updateBorder()
        }
    }
    
    /// Whether the border gradient should animate
    public var animateGradient: Bool = true {
        didSet {
            if animateGradient {
                startAnimation()
            } else {
                stopAnimation()
            }
        }
    }
    
    /// Animation duration for one full rotation
    public var animationDuration: TimeInterval = 4.0
    
    /// Opacity of the chromatic border
    public var borderOpacity: CGFloat = 0.8 {
        didSet {
            gradientLayer.opacity = Float(borderOpacity)
        }
    }
    
    private let gradientLayer = CAGradientLayer()
    private let maskLayer = CAShapeLayer()
    private var displayLink: CADisplayLink?
    private var animationStartTime: CFTimeInterval = 0
    
    // Chromatic colors: Cyan -> Blue -> Magenta -> Pink -> Cyan
    private let chromaticColors: [UIColor] = [
        UIColor(red: 0.0, green: 0.83, blue: 1.0, alpha: 1.0),    // Cyan #00D4FF
        UIColor(red: 0.0, green: 0.4, blue: 1.0, alpha: 1.0),     // Blue #0066FF
        UIColor(red: 0.6, green: 0.0, blue: 1.0, alpha: 1.0),     // Purple #9900FF
        UIColor(red: 1.0, green: 0.0, blue: 1.0, alpha: 1.0),     // Magenta #FF00FF
        UIColor(red: 1.0, green: 0.4, blue: 0.6, alpha: 1.0),     // Pink #FF6699
        UIColor(red: 0.0, green: 0.83, blue: 1.0, alpha: 1.0)     // Cyan (repeat for seamless)
    ]
    
    // MARK: - Initialization
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayers()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayers()
    }
    
    deinit {
        stopAnimation()
    }
    
    // MARK: - Setup
    
    private func setupLayers() {
        backgroundColor = .clear
        isUserInteractionEnabled = false
        
        // Setup gradient layer
        gradientLayer.type = .conic
        gradientLayer.colors = chromaticColors.map { $0.cgColor }
        gradientLayer.locations = [0.0, 0.2, 0.4, 0.6, 0.8, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.opacity = Float(borderOpacity)
        
        layer.addSublayer(gradientLayer)
        
        // Setup mask layer for border effect
        maskLayer.fillColor = UIColor.clear.cgColor
        maskLayer.strokeColor = UIColor.white.cgColor
        maskLayer.lineWidth = borderWidth
        
        gradientLayer.mask = maskLayer
        
        if animateGradient && !LiquidGlassConfiguration.shared.isReduceMotionEnabled {
            startAnimation()
        }
    }
    
    // MARK: - Layout
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        updateBorder()
    }
    
    private func updateBorder() {
        gradientLayer.frame = bounds
        
        // Create rounded rect path for border
        let inset = borderWidth / 2
        let borderRect = bounds.insetBy(dx: inset, dy: inset)
        let cornerRadius = max(0, layer.cornerRadius - inset)
        
        let path = UIBezierPath(roundedRect: borderRect, cornerRadius: cornerRadius)
        maskLayer.path = path.cgPath
        maskLayer.lineWidth = borderWidth
    }
    
    // MARK: - Corner Radius
    
    public override var layer: CALayer {
        let layer = super.layer
        return layer
    }
    
    public func setCornerRadius(_ radius: CGFloat) {
        layer.cornerRadius = radius
        updateBorder()
    }
    
    // MARK: - Animation
    
    private func startAnimation() {
        guard displayLink == nil else { return }
        
        animationStartTime = CACurrentMediaTime()
        displayLink = CADisplayLink(target: self, selector: #selector(updateAnimation))
        displayLink?.preferredFramesPerSecond = 30 // Limit to 30fps for performance
        displayLink?.add(to: .main, forMode: .common)
    }
    
    private func stopAnimation() {
        displayLink?.invalidate()
        displayLink = nil
    }
    
    @objc private func updateAnimation() {
        let elapsed = CACurrentMediaTime() - animationStartTime
        let progress = CGFloat(elapsed.truncatingRemainder(dividingBy: animationDuration)) / CGFloat(animationDuration)
        
        // Rotate the gradient
        let angle = progress * 2 * .pi
        let endPoint = CGPoint(
            x: 0.5 + 0.5 * sin(angle),
            y: 0.5 - 0.5 * cos(angle)
        )
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        gradientLayer.endPoint = endPoint
        CATransaction.commit()
    }
    
    // MARK: - Public Methods
    
    /// Update the chromatic colors
    public func setColors(_ colors: [UIColor]) {
        gradientLayer.colors = colors.map { $0.cgColor }
    }
    
    /// Flash the border (for highlight effect)
    public func flash(duration: TimeInterval = 0.3) {
        let originalOpacity = gradientLayer.opacity
        
        let animation = CAKeyframeAnimation(keyPath: "opacity")
        animation.values = [originalOpacity, 1.0, originalOpacity]
        animation.keyTimes = [0, 0.5, 1.0]
        animation.duration = duration
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        gradientLayer.add(animation, forKey: "flashAnimation")
    }
    
    /// Pulse animation for selection
    public func pulse(scale: CGFloat = 1.1, duration: TimeInterval = 0.2) {
        let scaleAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        scaleAnimation.values = [1.0, scale, 1.0]
        scaleAnimation.keyTimes = [0, 0.5, 1.0]
        scaleAnimation.duration = duration
        scaleAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        layer.add(scaleAnimation, forKey: "pulseAnimation")
    }
    
    /// Set visibility with animation
    public func setVisible(_ visible: Bool, animated: Bool = true) {
        if animated {
            UIView.animate(withDuration: 0.2) {
                self.alpha = visible ? 1.0 : 0.0
            }
        } else {
            alpha = visible ? 1.0 : 0.0
        }
    }
}

// MARK: - Static Chromatic Border (No Animation)

/// A simpler chromatic border without animation for better performance
public final class StaticChromaticBorderLayer: CAGradientLayer {
    
    public override init() {
        super.init()
        setupGradient()
    }
    
    public override init(layer: Any) {
        super.init(layer: layer)
        if let chromaticLayer = layer as? StaticChromaticBorderLayer {
            self.colors = chromaticLayer.colors
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGradient()
    }
    
    private func setupGradient() {
        type = .conic
        colors = [
            UIColor(red: 0.0, green: 0.83, blue: 1.0, alpha: 1.0).cgColor,
            UIColor(red: 0.0, green: 0.4, blue: 1.0, alpha: 1.0).cgColor,
            UIColor(red: 1.0, green: 0.0, blue: 1.0, alpha: 1.0).cgColor,
            UIColor(red: 1.0, green: 0.4, blue: 0.6, alpha: 1.0).cgColor,
            UIColor(red: 0.0, green: 0.83, blue: 1.0, alpha: 1.0).cgColor
        ]
        locations = [0.0, 0.25, 0.5, 0.75, 1.0]
        startPoint = CGPoint(x: 0.5, y: 0.5)
        endPoint = CGPoint(x: 0.5, y: 0)
    }
    
    public func applyAsBorder(to layer: CALayer, width: CGFloat, cornerRadius: CGFloat) {
        frame = layer.bounds
        
        let maskLayer = CAShapeLayer()
        let inset = width / 2
        let borderRect = bounds.insetBy(dx: inset, dy: inset)
        let path = UIBezierPath(roundedRect: borderRect, cornerRadius: max(0, cornerRadius - inset))
        
        maskLayer.path = path.cgPath
        maskLayer.fillColor = UIColor.clear.cgColor
        maskLayer.strokeColor = UIColor.white.cgColor
        maskLayer.lineWidth = width
        
        mask = maskLayer
    }
}
