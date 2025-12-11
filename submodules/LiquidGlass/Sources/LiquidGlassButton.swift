import Foundation
import UIKit

/// Circular glass button for attach, emoji, mic, and other action buttons
public final class LiquidGlassButton: UIControl {
    
    // MARK: - Subviews
    
    private let glassView: LiquidGlassView
    private let iconImageView: UIImageView
    private let titleLabel: UILabel
    
    // MARK: - Configuration
    
    public var icon: UIImage? {
        didSet {
            iconImageView.image = icon
        }
    }
    
    public var title: String? {
        didSet {
            titleLabel.text = title
            titleLabel.isHidden = title == nil
        }
    }
    
    public var iconTintColor: UIColor = .white {
        didSet {
            iconImageView.tintColor = iconTintColor
        }
    }
    
    public var buttonSize: ButtonSize = .medium {
        didSet {
            invalidateIntrinsicContentSize()
            setNeedsLayout()
        }
    }
    
    public enum ButtonSize {
        case small      // 44x44
        case medium     // 56x56
        case large      // 72x72
        
        var diameter: CGFloat {
            switch self {
            case .small: return 44.0
            case .medium: return 56.0
            case .large: return 72.0
            }
        }
        
        var iconSize: CGFloat {
            switch self {
            case .small: return 20.0
            case .medium: return 24.0
            case .large: return 32.0
            }
        }
    }
    
    // MARK: - Initialization
    
    public init(icon: UIImage? = nil, title: String? = nil, style: UIBlurEffect.Style = .light) {
        self.glassView = LiquidGlassView(style: style)
        self.iconImageView = UIImageView()
        self.titleLabel = UILabel()
        
        super.init(frame: .zero)
        
        self.icon = icon
        self.title = title
        
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        // Glass background
        addSubview(glassView)
        
        // Icon
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = iconTintColor
        iconImageView.image = icon
        glassView.contentView.addSubview(iconImageView)
        
        // Title label
        titleLabel.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.text = title
        titleLabel.isHidden = title == nil
        addSubview(titleLabel)
        
        // Setup touch handlers
        addTarget(self, action: #selector(touchDown), for: .touchDown)
        addTarget(self, action: #selector(touchUp), for: [.touchUpInside, .touchUpOutside, .touchCancel])
    }
    
    @objc private func touchDown() {
        glassView.animateTap()
    }
    
    @objc private func touchUp() {
        // Animation is handled in touchDown
    }
    
    public override var intrinsicContentSize: CGSize {
        let diameter = buttonSize.diameter
        let titleHeight: CGFloat = title != nil ? 20.0 : 0.0
        let spacing: CGFloat = title != nil ? 4.0 : 0.0
        return CGSize(width: diameter, height: diameter + spacing + titleHeight)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        let diameter = buttonSize.diameter
        let iconSize = buttonSize.iconSize
        
        // Position glass view (circular)
        glassView.frame = CGRect(
            x: (bounds.width - diameter) / 2.0,
            y: 0,
            width: diameter,
            height: diameter
        )
        glassView.cornerRadius = diameter / 2.0
        
        // Position icon (centered in glass view)
        iconImageView.frame = CGRect(
            x: (diameter - iconSize) / 2.0,
            y: (diameter - iconSize) / 2.0,
            width: iconSize,
            height: iconSize
        )
        
        // Position title label (below glass view)
        if !titleLabel.isHidden {
            let labelHeight: CGFloat = 20.0
            titleLabel.frame = CGRect(
                x: 0,
                y: diameter + 4.0,
                width: bounds.width,
                height: labelHeight
            )
        }
    }
    
    // MARK: - State
    
    public override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.1) {
                self.glassView.alpha = self.isHighlighted ? 0.8 : 1.0
            }
        }
    }
    
    public override var isEnabled: Bool {
        didSet {
            UIView.animate(withDuration: 0.2) {
                self.alpha = self.isEnabled ? 1.0 : 0.5
            }
        }
    }
    
    // MARK: - Customization
    
    public func setBlurIntensity(_ intensity: GlassBlurView.BlurIntensity) {
        glassView.blurIntensity = intensity
    }
    
    public func setRefractionIntensity(_ intensity: CGFloat) {
        glassView.refractionIntensity = intensity
    }
    
    public func setChromaticBorderEnabled(_ enabled: Bool) {
        glassView.showChromaticBorder = enabled
    }
    
    public func setSpecularHighlightsEnabled(_ enabled: Bool) {
        glassView.showSpecularHighlights = enabled
    }
    
    // MARK: - Animation Helpers
    
    public func bounce() {
        glassView.animateBounce(intensity: 1.15)
    }
}
