import Foundation
import UIKit

/// Circular glass button for attach, emoji, mic, and other action buttons
public final class LiquidGlassButton: UIView {
    
    private let glassView: LiquidGlassView
    private let iconImageView: UIImageView
    private let highlightOverlay: UIView
    private let animator: GlassSpringAnimator
    
    public var icon: UIImage? {
        didSet { iconImageView.image = icon?.withRenderingMode(.alwaysTemplate) }
    }
    
    public var iconTintColor: UIColor = .white {
        didSet { iconImageView.tintColor = iconTintColor }
    }
    
    public var buttonSize: CGFloat = 32.0 {
        didSet { invalidateIntrinsicContentSize(); setNeedsLayout() }
    }
    
    public var iconSize: CGFloat = 20.0 {
        didSet { setNeedsLayout() }
    }
    
    public var onTap: (() -> Void)?
    
    private var isHighlighted: Bool = false {
        didSet { updateHighlightState() }
    }
    
    public init(icon: UIImage? = nil, size: CGFloat = 32.0) {
        self.buttonSize = size
        self.glassView = LiquidGlassView(configuration: .button)
        self.iconImageView = UIImageView()
        self.highlightOverlay = UIView()
        self.animator = GlassSpringAnimator()
        super.init(frame: .zero)
        self.icon = icon
        setupViews()
        setupGestures()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func setupViews() {
        addSubview(glassView)
        glassView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            glassView.topAnchor.constraint(equalTo: topAnchor),
            glassView.leadingAnchor.constraint(equalTo: leadingAnchor),
            glassView.trailingAnchor.constraint(equalTo: trailingAnchor),
            glassView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        highlightOverlay.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        highlightOverlay.alpha = 0
        highlightOverlay.isUserInteractionEnabled = false
        addSubview(highlightOverlay)
        highlightOverlay.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            highlightOverlay.topAnchor.constraint(equalTo: topAnchor),
            highlightOverlay.leadingAnchor.constraint(equalTo: leadingAnchor),
            highlightOverlay.trailingAnchor.constraint(equalTo: trailingAnchor),
            highlightOverlay.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = iconTintColor
        iconImageView.image = icon?.withRenderingMode(.alwaysTemplate)
        addSubview(iconImageView)
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            iconImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: iconSize),
            iconImageView.heightAnchor.constraint(equalToConstant: iconSize)
        ])
    }
    
    private func setupGestures() {
        let pressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handlePress(_:)))
        pressGesture.minimumPressDuration = 0
        addGestureRecognizer(pressGesture)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        addGestureRecognizer(tapGesture)
    }
    
    public override var intrinsicContentSize: CGSize {
        return CGSize(width: buttonSize, height: buttonSize)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        let cornerRadius = bounds.height / 2
        layer.cornerRadius = cornerRadius
        highlightOverlay.layer.cornerRadius = cornerRadius
    }
    
    @objc private func handlePress(_ gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            isHighlighted = true
            animator.animateTapDown(view: self)
        case .ended:
            isHighlighted = false
            animator.animateTapUp(view: self)
            if bounds.contains(gesture.location(in: self)) { onTap?() }
        case .cancelled:
            isHighlighted = false
            animator.animateTapUp(view: self)
        default: break
        }
    }
    
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        animator.animateTapBounce(view: self) { [weak self] in self?.onTap?() }
        glassView.flashBorder()
    }
    
    private func updateHighlightState() {
        UIView.animate(withDuration: 0.15) { self.highlightOverlay.alpha = self.isHighlighted ? 1.0 : 0.0 }
    }
    
    public func setContentSource(_ view: UIView?) { glassView.setContentSource(view) }
    public func setDarkMode(_ isDark: Bool) {
        glassView.setDarkMode(isDark)
        iconTintColor = isDark ? .white : UIColor(white: 0.2, alpha: 1.0)
    }
    public func pulse() { animator.animateTapBounce(view: self, completion: nil) }
}
