import Foundation
import UIKit

public final class GlassBlurView: UIView {
    private let blurEffectView: UIVisualEffectView
    private var blurRadius: CGFloat = 20.0
    
    public var isDark: Bool = false {
        didSet {
            if oldValue != isDark {
                updateBlurEffect()
            }
        }
    }
    
    public init(blurRadius: CGFloat = 20.0, isDark: Bool = false) {
        self.blurRadius = blurRadius
        self.isDark = isDark
        
        let blurEffect = UIBlurEffect(style: isDark ? .dark : .light)
        self.blurEffectView = UIVisualEffectView(effect: blurEffect)
        
        super.init(frame: .zero)
        
        addSubview(blurEffectView)
        blurEffectView.frame = bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        setupBlurRadius()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupBlurRadius() {
        guard LiquidGlassConfiguration.shared.supportsCAFilters else { return }
        
        // Use CAFilter private API to adjust blur radius
        if let sublayer = blurEffectView.layer.sublayers?.first {
            if let classValue = NSClassFromString("CAFilter") as AnyObject as? NSObjectProtocol {
                let makeSelector = NSSelectorFromString("filterWithType:")
                if classValue.responds(to: makeSelector) {
                    if let filter = classValue.perform(makeSelector, with: "gaussianBlur")?.takeUnretainedValue() as? NSObject {
                        filter.setValue(blurRadius, forKey: "inputRadius")
                        sublayer.filters = [filter]
                    }
                }
            }
        }
    }
    
    private func updateBlurEffect() {
        let blurEffect = UIBlurEffect(style: isDark ? .dark : .light)
        blurEffectView.effect = blurEffect
        setupBlurRadius()
    }
    
    public func setBlurRadius(_ radius: CGFloat, animated: Bool) {
        self.blurRadius = radius
        
        if animated {
            UIView.animate(withDuration: 0.3) {
                self.setupBlurRadius()
            }
        } else {
            setupBlurRadius()
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        blurEffectView.frame = bounds
    }
}
