import Foundation
import UIKit

/// Main glass container combining blur, refraction, chromatic border, and specular highlights
public final class LiquidGlassView: UIView {
    
    // MARK: - Subviews
    
    private let blurView: GlassBlurView
    private let refractionView: SelfRefractionView
    private let chromaticBorder: ChromaticBorderView
    private let specularHighlightView: UIView
    public let contentView: UIView
    
    // MARK: - Configuration
    
    public var cornerRadius: CGFloat = 20.0 {
        didSet {
            updateCornerRadius()
        }
    }
    
    public var blurIntensity: GlassBlurView.BlurIntensity = .medium {
        didSet {
            blurView.setIntensity(blurIntensity)
        }
    }
    
    public var refractionIntensity: CGFloat = 0.5 {
        didSet {
            refractionView.refractionIntensity = refractionIntensity
        }
    }
    
    public var showChromaticBorder: Bool = true {
        didSet {
            updateChromaticBorder()
        }
    }
    
    public var showSpecularHighlights: Bool = true {
        didSet {
            updateSpecularHighlights()
        }
    }
    
    // MARK: - Initialization
    
    public init(style: UIBlurEffect.Style = .light) {
        self.blurView = GlassBlurView(style: style, blurRadius: 20.0)
        self.refractionView = SelfRefractionView()
        self.chromaticBorder = ChromaticBorderView()
        self.specularHighlightView = UIView()
        self.contentView = UIView()
        
        super.init(frame: .zero)
        
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        // Layer order: blur -> refraction -> content -> specular highlights -> chromatic border
        
        // Blur background
        blurView.frame = bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(blurView)
        
        // Refraction layer (on top of blur)
        refractionView.frame = bounds
        refractionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        refractionView.isUserInteractionEnabled = false
        addSubview(refractionView)
        
        // Content container
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.backgroundColor = .clear
        addSubview(contentView)
        
        // Specular highlights
        setupSpecularHighlights()
        specularHighlightView.frame = bounds
        specularHighlightView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        specularHighlightView.isUserInteractionEnabled = false
        addSubview(specularHighlightView)
        
        // Chromatic border (topmost)
        chromaticBorder.frame = bounds
        chromaticBorder.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(chromaticBorder)
        
        // Initial configuration
        updateCornerRadius()
        updateChromaticBorder()
        updateSpecularHighlights()
        
        // Clip to bounds for rounded corners
        clipsToBounds = true
    }
    
    private func setupSpecularHighlights() {
        guard LiquidGlassConfiguration.shared.shouldEnableSpecularHighlights else { return }
        
        // Create a gradient for specular highlight
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor(white: 1.0, alpha: 0.3).cgColor,
            UIColor(white: 1.0, alpha: 0.0).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradientLayer.locations = [0.0, 0.5]
        
        specularHighlightView.layer.addSublayer(gradientLayer)
    }
    
    private func updateCornerRadius() {
        layer.cornerRadius = cornerRadius
        blurView.layer.cornerRadius = cornerRadius
        refractionView.layer.cornerRadius = cornerRadius
        contentView.layer.cornerRadius = cornerRadius
        specularHighlightView.layer.cornerRadius = cornerRadius
        chromaticBorder.layer.cornerRadius = cornerRadius
    }
    
    private func updateChromaticBorder() {
        if showChromaticBorder && LiquidGlassConfiguration.shared.shouldEnableChromaticBorder {
            chromaticBorder.isHidden = false
            chromaticBorder.startAnimation()
        } else {
            chromaticBorder.isHidden = true
            chromaticBorder.stopAnimation()
        }
    }
    
    private func updateSpecularHighlights() {
        specularHighlightView.isHidden = !showSpecularHighlights || !LiquidGlassConfiguration.shared.shouldEnableSpecularHighlights
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        // Update specular highlight gradient frame
        if let gradientLayer = specularHighlightView.layer.sublayers?.first as? CAGradientLayer {
            gradientLayer.frame = specularHighlightView.bounds
        }
    }
    
    // MARK: - Effects Control
    
    /// Enable/disable effects based on performance requirements
    public func setEffectsEnabled(_ enabled: Bool, animated: Bool = true) {
        let alpha: CGFloat = enabled ? 1.0 : 0.0
        
        if animated {
            UIView.animate(withDuration: 0.3) {
                self.refractionView.alpha = alpha
                self.chromaticBorder.alpha = alpha
                self.specularHighlightView.alpha = alpha
            }
        } else {
            self.refractionView.alpha = alpha
            self.chromaticBorder.alpha = alpha
            self.specularHighlightView.alpha = alpha
        }
    }
    
    /// Pause/resume chromatic border animation
    public func pauseChromaticAnimation() {
        chromaticBorder.pauseAnimation()
    }
    
    public func resumeChromaticAnimation() {
        chromaticBorder.resumeAnimation()
    }
    
    // MARK: - Interaction Animations
    
    public func animateTap(completion: (() -> Void)? = nil) {
        GlassSpringAnimator.animateTap(view: self, completion: completion)
    }
    
    public func animateBounce(intensity: CGFloat = 1.1, completion: (() -> Void)? = nil) {
        GlassSpringAnimator.animateBounce(view: self, intensity: intensity, completion: completion)
    }
}
