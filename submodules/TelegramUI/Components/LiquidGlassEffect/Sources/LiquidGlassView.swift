import Foundation
import UIKit

public final class LiquidGlassView: UIView {
    private let blurView: GlassBlurView
    private let refractionLayer: SelfRefractionLayer
    public let chromaticBorder: ChromaticBorderView
    private let highlightView: UIView
    private let shadowLayer: CALayer
    public let contentView: UIView
    
    public var cornerRadius: CGFloat = 16.0 {
        didSet {
            if oldValue != cornerRadius {
                updateCornerRadius()
            }
        }
    }
    
    public var isDark: Bool = false {
        didSet {
            if oldValue != isDark {
                blurView.isDark = isDark
                updateShadow()
            }
        }
    }
    
    public var showsChromaticBorder: Bool = true {
        didSet {
            if oldValue != showsChromaticBorder {
                chromaticBorder.isHidden = !showsChromaticBorder
            }
        }
    }
    
    public var refractionIntensity: CGFloat = 0.5 {
        didSet {
            if oldValue != refractionIntensity {
                refractionLayer.setRefractionIntensity(refractionIntensity, animated: false)
            }
        }
    }
    
    public init(blurRadius: CGFloat = 20.0) {
        self.blurView = GlassBlurView(blurRadius: blurRadius)
        self.refractionLayer = SelfRefractionLayer()
        self.chromaticBorder = ChromaticBorderView()
        self.highlightView = UIView()
        self.shadowLayer = CALayer()
        self.contentView = UIView()
        
        super.init(frame: .zero)
        
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        // Add shadow layer first
        layer.insertSublayer(shadowLayer, at: 0)
        updateShadow()
        
        // Add blur view
        addSubview(blurView)
        
        // Add refraction layer
        layer.addSublayer(refractionLayer)
        
        // Add highlight
        highlightView.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        addSubview(highlightView)
        
        // Add chromatic border
        addSubview(chromaticBorder)
        
        // Add content view
        addSubview(contentView)
        
        // Set initial corner radius
        updateCornerRadius()
    }
    
    private func updateCornerRadius() {
        blurView.layer.cornerRadius = cornerRadius
        blurView.layer.cornerCurve = .continuous
        blurView.clipsToBounds = true
        
        refractionLayer.cornerRadius = cornerRadius
        refractionLayer.cornerCurve = .continuous
        refractionLayer.masksToBounds = true
        
        chromaticBorder.cornerRadius = cornerRadius
        
        highlightView.layer.cornerRadius = cornerRadius
        highlightView.layer.cornerCurve = .continuous
        highlightView.clipsToBounds = true
        
        shadowLayer.cornerRadius = cornerRadius
        shadowLayer.cornerCurve = .continuous
        
        contentView.layer.cornerRadius = cornerRadius
        contentView.layer.cornerCurve = .continuous
        contentView.clipsToBounds = true
    }
    
    private func updateShadow() {
        shadowLayer.shadowColor = UIColor.black.cgColor
        shadowLayer.shadowOpacity = isDark ? 0.6 : 0.3
        shadowLayer.shadowOffset = CGSize(width: 0, height: 4)
        shadowLayer.shadowRadius = 12
        shadowLayer.backgroundColor = UIColor.clear.cgColor
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        blurView.frame = bounds
        refractionLayer.frame = bounds
        chromaticBorder.frame = bounds
        contentView.frame = bounds
        
        // Highlight at top
        let highlightHeight: CGFloat = bounds.height * 0.3
        highlightView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: highlightHeight)
        
        // Shadow layer
        shadowLayer.frame = bounds
        shadowLayer.shadowPath = UIBezierPath(
            roundedRect: bounds,
            cornerRadius: cornerRadius
        ).cgPath
    }
    
    // Animation methods
    public func animateTap(completion: (() -> Void)? = nil) {
        GlassSpringAnimator.animateTapScale(view: self, completion: completion)
    }
    
    public func animatePulse() {
        GlassSpringAnimator.animatePulse(view: self)
    }
    
    public func setRefractionIntensity(_ intensity: CGFloat, animated: Bool) {
        self.refractionIntensity = intensity
        refractionLayer.setRefractionIntensity(intensity, animated: animated)
    }
    
    public func setBlurRadius(_ radius: CGFloat, animated: Bool) {
        blurView.setBlurRadius(radius, animated: animated)
    }
}
