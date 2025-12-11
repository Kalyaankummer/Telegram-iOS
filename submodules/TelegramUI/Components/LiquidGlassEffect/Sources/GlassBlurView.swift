import Foundation
import UIKit

/// A custom blur view that provides adjustable blur radius for glass effects
/// Uses UIVisualEffectView with CAFilter manipulation for iOS 13+
public final class GlassBlurView: UIView {
    
    // MARK: - Properties
    
    private var blurEffect: UIBlurEffect
    private var effectView: UIVisualEffectView
    private var blurRadius: CGFloat
    private var tintColor: UIColor?
    private var tintAlpha: CGFloat
    
    private let tintOverlayView: UIView
    
    // MARK: - Initialization
    
    public init(
        blurRadius: CGFloat = 12.0,
        tintColor: UIColor? = nil,
        tintAlpha: CGFloat = 0.1
    ) {
        self.blurRadius = blurRadius
        self.tintColor = tintColor
        self.tintAlpha = tintAlpha
        
        self.blurEffect = UIBlurEffect(style: .light)
        self.effectView = UIVisualEffectView(effect: blurEffect)
        self.tintOverlayView = UIView()
        
        super.init(frame: .zero)
        
        setupViews()
        configureBlur()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupViews() {
        addSubview(effectView)
        effectView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            effectView.topAnchor.constraint(equalTo: topAnchor),
            effectView.leadingAnchor.constraint(equalTo: leadingAnchor),
            effectView.trailingAnchor.constraint(equalTo: trailingAnchor),
            effectView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        tintOverlayView.backgroundColor = tintColor?.withAlphaComponent(tintAlpha) ?? UIColor.white.withAlphaComponent(0.1)
        addSubview(tintOverlayView)
        tintOverlayView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tintOverlayView.topAnchor.constraint(equalTo: topAnchor),
            tintOverlayView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tintOverlayView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tintOverlayView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        hideDefaultTintView()
    }
    
    private func hideDefaultTintView() {
        for subview in effectView.subviews {
            if String(describing: type(of: subview)).contains("VisualEffectSubview") {
                subview.isHidden = true
            }
        }
    }
    
    private func configureBlur() {
        guard let sublayer = effectView.layer.sublayers?.first else { return }
        
        sublayer.backgroundColor = nil
        sublayer.isOpaque = false
        
        if let filters = sublayer.filters {
            for filter in filters {
                guard let filter = filter as? NSObject else { continue }
                let filterName = String(describing: type(of: filter))
                if filterName.contains("gaussianBlur") || String(describing: filter).contains("gaussianBlur") {
                    filter.setValue(blurRadius, forKey: "inputRadius")
                }
            }
            
            let cleanedFilters = filters.filter { filter in
                guard let filter = filter as? NSObject else { return false }
                let name = String(describing: filter)
                return name.contains("gaussianBlur")
            }
            sublayer.filters = cleanedFilters
        }
    }
    
    public func updateBlurRadius(_ radius: CGFloat) {
        self.blurRadius = radius
        configureBlur()
    }
    
    public func updateTintColor(_ color: UIColor?, alpha: CGFloat = 0.1) {
        self.tintColor = color
        self.tintAlpha = alpha
        tintOverlayView.backgroundColor = color?.withAlphaComponent(alpha) ?? UIColor.white.withAlphaComponent(0.1)
    }
    
    public func setDarkMode(_ isDark: Bool) {
        blurEffect = UIBlurEffect(style: isDark ? .dark : .light)
        effectView.effect = blurEffect
        hideDefaultTintView()
        configureBlur()
        
        if tintColor == nil {
            tintOverlayView.backgroundColor = isDark 
                ? UIColor.white.withAlphaComponent(0.05) 
                : UIColor.white.withAlphaComponent(0.1)
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        configureBlur()
    }
    
    public override var backgroundColor: UIColor? {
        didSet {
            super.backgroundColor = .clear
        }
    }
}
