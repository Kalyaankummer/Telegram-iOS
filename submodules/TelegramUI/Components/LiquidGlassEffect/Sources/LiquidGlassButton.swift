import Foundation
import UIKit

public final class LiquidGlassButton: UIControl {
    private let glassView: LiquidGlassView
    private let iconImageView: UIImageView
    private let titleLabel: UILabel
    
    public var icon: UIImage? {
        didSet {
            iconImageView.image = icon
            setNeedsLayout()
        }
    }
    
    public var title: String? {
        didSet {
            titleLabel.text = title
            setNeedsLayout()
        }
    }
    
    public var isDark: Bool = false {
        didSet {
            if oldValue != isDark {
                glassView.isDark = isDark
                updateColors()
            }
        }
    }
    
    public init(style: ButtonStyle = .circular) {
        self.glassView = LiquidGlassView(blurRadius: 20.0)
        self.iconImageView = UIImageView()
        self.titleLabel = UILabel()
        
        super.init(frame: .zero)
        
        setupButton()
        
        switch style {
        case .circular:
            glassView.cornerRadius = 28.0  // Will be adjusted in layoutSubviews
        case .rounded:
            glassView.cornerRadius = 16.0
        case .pill:
            glassView.cornerRadius = 22.0  // Will be adjusted in layoutSubviews
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupButton() {
        addSubview(glassView)
        
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = .white
        glassView.contentView.addSubview(iconImageView)
        
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.textAlignment = .center
        glassView.contentView.addSubview(titleLabel)
        
        updateColors()
        
        addTarget(self, action: #selector(touchDown), for: .touchDown)
        addTarget(self, action: #selector(touchUp), for: [.touchUpInside, .touchUpOutside, .touchCancel])
    }
    
    private func updateColors() {
        titleLabel.textColor = isDark ? .white : .black
        iconImageView.tintColor = isDark ? .white : .black
    }
    
    @objc private func touchDown() {
        GlassSpringAnimator.animateTapScale(
            view: glassView,
            scaleDown: 0.92,
            scaleBounce: nil
        )
    }
    
    @objc private func touchUp() {
        GlassSpringAnimator.animateSpring(
            duration: 0.3,
            animations: {
                self.glassView.transform = .identity
            }
        )
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        glassView.frame = bounds
        
        // Adjust corner radius for circular style
        if bounds.width == bounds.height {
            glassView.cornerRadius = bounds.width / 2
        }
        
        let contentSize = glassView.contentView.bounds.size
        
        if let _ = icon, let _ = title {
            // Both icon and title
            let iconSize: CGFloat = 24
            let spacing: CGFloat = 8
            
            let totalHeight = iconSize + spacing + titleLabel.font.lineHeight
            var y = (contentSize.height - totalHeight) / 2
            
            iconImageView.frame = CGRect(
                x: (contentSize.width - iconSize) / 2,
                y: y,
                width: iconSize,
                height: iconSize
            )
            
            y += iconSize + spacing
            
            titleLabel.sizeToFit()
            titleLabel.frame = CGRect(
                x: (contentSize.width - titleLabel.bounds.width) / 2,
                y: y,
                width: titleLabel.bounds.width,
                height: titleLabel.font.lineHeight
            )
        } else if let _ = icon {
            // Icon only
            let iconSize: CGFloat = min(contentSize.width * 0.5, contentSize.height * 0.5)
            iconImageView.frame = CGRect(
                x: (contentSize.width - iconSize) / 2,
                y: (contentSize.height - iconSize) / 2,
                width: iconSize,
                height: iconSize
            )
            titleLabel.frame = .zero
        } else if let _ = title {
            // Title only
            titleLabel.sizeToFit()
            titleLabel.frame = CGRect(
                x: (contentSize.width - titleLabel.bounds.width) / 2,
                y: (contentSize.height - titleLabel.font.lineHeight) / 2,
                width: titleLabel.bounds.width,
                height: titleLabel.font.lineHeight
            )
            iconImageView.frame = .zero
        }
    }
    
    public override var intrinsicContentSize: CGSize {
        if let _ = title {
            titleLabel.sizeToFit()
            let width = titleLabel.bounds.width + 32
            let height: CGFloat = 44
            return CGSize(width: width, height: height)
        }
        return CGSize(width: 56, height: 56)
    }
    
    public enum ButtonStyle {
        case circular
        case rounded
        case pill
    }
}
