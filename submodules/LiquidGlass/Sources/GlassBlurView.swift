import Foundation
import UIKit

/// Custom blur view with adjustable radius using CAFilter manipulation
public final class GlassBlurView: UIView {
    
    private let blurView: UIVisualEffectView
    private var currentBlurRadius: CGFloat = 20.0
    
    public var blurRadius: CGFloat {
        get { return currentBlurRadius }
        set { setBlurRadius(newValue, animated: false) }
    }
    
    public var blurStyle: UIBlurEffect.Style {
        didSet {
            updateBlurEffect()
        }
    }
    
    public init(style: UIBlurEffect.Style = .light, blurRadius: CGFloat = 20.0) {
        self.blurStyle = style
        self.currentBlurRadius = blurRadius
        self.blurView = UIVisualEffectView(effect: UIBlurEffect(style: style))
        
        super.init(frame: .zero)
        
        setupView()
        applyCustomBlurRadius()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        blurView.frame = bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(blurView)
        
        clipsToBounds = true
    }
    
    private func updateBlurEffect() {
        blurView.effect = UIBlurEffect(style: blurStyle)
        applyCustomBlurRadius()
    }
    
    public func setBlurRadius(_ radius: CGFloat, animated: Bool) {
        guard LiquidGlassConfiguration.shared.shouldEnableBlur else { return }
        
        currentBlurRadius = radius
        
        if animated {
            UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut], animations: {
                self.applyCustomBlurRadius()
            })
        } else {
            applyCustomBlurRadius()
        }
    }
    
    private func applyCustomBlurRadius() {
        // Try to access the internal blur layer to adjust radius
        guard let sublayer = blurView.layer.sublayers?.first else { return }
        
        // Use CAFilter to adjust blur radius if available
        if let filterClass = NSClassFromString("CAFilter") as AnyObject as? NSObjectProtocol {
            let selector = NSSelectorFromString("filterWithName:")
            
            if filterClass.responds(to: selector) {
                // Create gaussian blur filter
                let filter = filterClass.perform(selector, with: "gaussianBlur")?.takeUnretainedValue() as? NSObject
                
                if let filter = filter {
                    // Set blur radius
                    filter.setValue(currentBlurRadius, forKey: "inputRadius")
                    sublayer.filters = [filter]
                }
            }
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        blurView.frame = bounds
    }
    
    /// Adjusts blur intensity for different contexts
    public enum BlurIntensity {
        case light      // 10.0
        case medium     // 20.0
        case strong     // 30.0
        case extraStrong // 40.0
        
        var radius: CGFloat {
            switch self {
            case .light: return 10.0
            case .medium: return 20.0
            case .strong: return 30.0
            case .extraStrong: return 40.0
            }
        }
    }
    
    public func setIntensity(_ intensity: BlurIntensity, animated: Bool = true) {
        setBlurRadius(intensity.radius, animated: animated)
    }
}
