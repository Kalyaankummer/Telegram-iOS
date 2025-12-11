import Foundation
import UIKit

/// Main glass container view combining blur, refraction, chromatic border, and highlights
public final class LiquidGlassView: UIView {
    
    public struct Configuration {
        public var blurRadius: CGFloat
        public var refractionStrength: CGFloat
        public var showChromaticBorder: Bool
        public var chromaticBorderWidth: CGFloat
        public var cornerRadius: CGFloat
        public var shadowOpacity: Float
        public var shadowRadius: CGFloat
        public var showSpecularHighlight: Bool
        
        public static var `default`: Configuration {
            return Configuration(blurRadius: 12.0, refractionStrength: 0.25, showChromaticBorder: true, chromaticBorderWidth: 1.5, cornerRadius: 0, shadowOpacity: 0.15, shadowRadius: 4.0, showSpecularHighlight: true)
        }
        
        public static var button: Configuration {
            return Configuration(blurRadius: 10.0, refractionStrength: 0.15, showChromaticBorder: false, chromaticBorderWidth: 0, cornerRadius: 0, shadowOpacity: 0.1, shadowRadius: 3.0, showSpecularHighlight: true)
        }
        
        public static var switchThumb: Configuration {
            return Configuration(blurRadius: 8.0, refractionStrength: 0.3, showChromaticBorder: true, chromaticBorderWidth: 1.0, cornerRadius: 13.5, shadowOpacity: 0.2, shadowRadius: 3.0, showSpecularHighlight: true)
        }
        
        public static var sliderKnob: Configuration {
            return Configuration(blurRadius: 8.0, refractionStrength: 0.25, showChromaticBorder: false, chromaticBorderWidth: 0, cornerRadius: 11.0, shadowOpacity: 0.15, shadowRadius: 3.0, showSpecularHighlight: true)
        }
        
        public static var tabLens: Configuration {
            return Configuration(blurRadius: 15.0, refractionStrength: 0.3, showChromaticBorder: true, chromaticBorderWidth: 1.5, cornerRadius: 20.0, shadowOpacity: 0.12, shadowRadius: 5.0, showSpecularHighlight: true)
        }
    }
    
    private let blurView: GlassBlurView
    private let refractionLayer: SelfRefractionLayer
    private var chromaticBorder: ChromaticBorderView?
    private let highlightLayer: CAGradientLayer
    private let innerGlowLayer: CAGradientLayer
    private let animator: GlassSpringAnimator
    
    public var configuration: Configuration { didSet { updateConfiguration() } }
    private var isPressed: Bool = false
    private weak var contentSourceView: UIView?
    
    public var onTap: (() -> Void)?
    public var onPressStateChanged: ((Bool) -> Void)?
    
    public init(configuration: Configuration = .default) {
        self.configuration = configuration
        self.blurView = GlassBlurView(blurRadius: configuration.blurRadius)
        self.refractionLayer = SelfRefractionLayer()
        self.highlightLayer = CAGradientLayer()
        self.innerGlowLayer = CAGradientLayer()
        self.animator = GlassSpringAnimator()
        super.init(frame: .zero)
        setupLayers()
        setupGestures()
        updateConfiguration()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func setupLayers() {
        addSubview(blurView)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            blurView.topAnchor.constraint(equalTo: topAnchor),
            blurView.leadingAnchor.constraint(equalTo: leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: trailingAnchor),
            blurView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        refractionLayer.isRefractionEnabled = LiquidGlassConfiguration.shared.enableRefraction
        layer.addSublayer(refractionLayer)
        
        innerGlowLayer.type = .radial
        innerGlowLayer.colors = [UIColor.white.withAlphaComponent(0.15).cgColor, UIColor.white.withAlphaComponent(0.05).cgColor, UIColor.clear.cgColor]
        innerGlowLayer.locations = [0.0, 0.5, 1.0]
        innerGlowLayer.startPoint = CGPoint(x: 0.3, y: 0.3)
        innerGlowLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        layer.addSublayer(innerGlowLayer)
        
        highlightLayer.colors = [UIColor.white.withAlphaComponent(0.4).cgColor, UIColor.white.withAlphaComponent(0.1).cgColor, UIColor.clear.cgColor]
        highlightLayer.locations = [0.0, 0.3, 1.0]
        highlightLayer.startPoint = CGPoint(x: 0, y: 0)
        highlightLayer.endPoint = CGPoint(x: 1, y: 1)
        layer.addSublayer(highlightLayer)
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        clipsToBounds = false
    }
    
    private func setupChromaticBorder() {
        chromaticBorder?.removeFromSuperview()
        chromaticBorder = nil
        if configuration.showChromaticBorder && LiquidGlassConfiguration.shared.enableChromaticBorder {
            let border = ChromaticBorderView()
            border.borderWidth = configuration.chromaticBorderWidth
            border.isUserInteractionEnabled = false
            addSubview(border)
            border.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                border.topAnchor.constraint(equalTo: topAnchor),
                border.leadingAnchor.constraint(equalTo: leadingAnchor),
                border.trailingAnchor.constraint(equalTo: trailingAnchor),
                border.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
            chromaticBorder = border
        }
    }
    
    private func setupGestures() {
        let pressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handlePress(_:)))
        pressGesture.minimumPressDuration = 0
        pressGesture.cancelsTouchesInView = false
        addGestureRecognizer(pressGesture)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        addGestureRecognizer(tapGesture)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        let cornerRadius = configuration.cornerRadius > 0 ? configuration.cornerRadius : bounds.height / 2
        refractionLayer.frame = bounds
        highlightLayer.frame = bounds
        innerGlowLayer.frame = bounds
        layer.cornerRadius = cornerRadius
        blurView.layer.cornerRadius = cornerRadius
        blurView.clipsToBounds = true
        highlightLayer.cornerRadius = cornerRadius
        innerGlowLayer.cornerRadius = cornerRadius
        chromaticBorder?.setCornerRadius(cornerRadius)
        updateRefraction()
    }
    
    private func updateConfiguration() {
        blurView.updateBlurRadius(configuration.blurRadius)
        refractionLayer.refractionStrength = configuration.refractionStrength
        refractionLayer.isRefractionEnabled = LiquidGlassConfiguration.shared.enableRefraction
        layer.shadowOpacity = configuration.shadowOpacity
        layer.shadowRadius = configuration.shadowRadius
        highlightLayer.isHidden = !configuration.showSpecularHighlight
        innerGlowLayer.isHidden = !configuration.showSpecularHighlight
        setupChromaticBorder()
        setNeedsLayout()
    }
    
    @objc private func handlePress(_ gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            isPressed = true
            animator.animateTapDown(view: self)
            onPressStateChanged?(true)
        case .ended, .cancelled:
            isPressed = false
            animator.animateTapUp(view: self)
            onPressStateChanged?(false)
        default: break
        }
    }
    
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        animator.animateTapBounce(view: self) { [weak self] in self?.onTap?() }
        chromaticBorder?.flash()
    }
    
    public func setContentSource(_ view: UIView?) {
        contentSourceView = view
        updateRefraction()
    }
    
    public func updateRefraction() {
        guard LiquidGlassConfiguration.shared.enableRefraction else { return }
        refractionLayer.captureContent(from: contentSourceView)
    }
    
    public func animateSelection(selected: Bool) {
        animator.animateSelection(view: self, selected: selected)
        chromaticBorder?.pulse()
    }
    
    public func animateStretch(to frame: CGRect, completion: (() -> Void)? = nil) {
        animator.animateStretch(view: self, to: frame, completion: completion)
    }
    
    public func setDarkMode(_ isDark: Bool) {
        blurView.setDarkMode(isDark)
    }
    
    public func setPerformanceMode(_ enabled: Bool) {
        refractionLayer.setPerformanceMode(enabled)
    }
    
    public func flashBorder() {
        chromaticBorder?.flash()
    }
}
