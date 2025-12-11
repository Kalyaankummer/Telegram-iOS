import Foundation
import UIKit

public final class ChromaticBorderView: UIView {
    private let gradientLayer: CAGradientLayer
    private let maskLayer: CAShapeLayer
    
    public var borderWidth: CGFloat = 2.0 {
        didSet {
            if oldValue != borderWidth {
                updateMask()
            }
        }
    }
    
    public var cornerRadius: CGFloat = 0.0 {
        didSet {
            if oldValue != cornerRadius {
                updateMask()
            }
        }
    }
    
    public init() {
        self.gradientLayer = CAGradientLayer()
        self.maskLayer = CAShapeLayer()
        
        super.init(frame: .zero)
        
        setupGradient()
        layer.addSublayer(gradientLayer)
        gradientLayer.mask = maskLayer
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupGradient() {
        // Rainbow prismatic gradient: cyan -> magenta
        let colors: [UIColor] = [
            UIColor(red: 0.0, green: 1.0, blue: 1.0, alpha: 1.0),  // Cyan
            UIColor(red: 0.0, green: 0.5, blue: 1.0, alpha: 1.0),  // Blue
            UIColor(red: 0.5, green: 0.0, blue: 1.0, alpha: 1.0),  // Purple
            UIColor(red: 1.0, green: 0.0, blue: 1.0, alpha: 1.0),  // Magenta
            UIColor(red: 1.0, green: 0.0, blue: 0.5, alpha: 1.0),  // Pink-Magenta
            UIColor(red: 0.0, green: 1.0, blue: 1.0, alpha: 1.0),  // Cyan (loop)
        ]
        
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        
        // Animate gradient rotation
        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [0.0, 0.2, 0.4, 0.6, 0.8, 1.0]
        animation.toValue = [0.2, 0.4, 0.6, 0.8, 1.0, 1.2]
        animation.duration = 3.0
        animation.repeatCount = .infinity
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        gradientLayer.add(animation, forKey: "gradientAnimation")
    }
    
    private func updateMask() {
        let outerPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
        let innerRect = bounds.insetBy(dx: borderWidth, dy: borderWidth)
        let innerPath = UIBezierPath(roundedRect: innerRect, cornerRadius: max(0, cornerRadius - borderWidth))
        
        outerPath.append(innerPath)
        outerPath.usesEvenOddFillRule = true
        
        maskLayer.path = outerPath.cgPath
        maskLayer.fillRule = .evenOdd
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        gradientLayer.frame = bounds
        updateMask()
    }
    
    public func setAnimated(_ animated: Bool) {
        if animated {
            gradientLayer.speed = 1.0
        } else {
            gradientLayer.speed = 0.0
        }
    }
}
