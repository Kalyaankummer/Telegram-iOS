import Foundation
import UIKit

/// Tab bar selection lens with stretch animation between tabs
public final class LiquidGlassTabLens: UIView {
    
    private let glassView: LiquidGlassView
    private let animator: GlassSpringAnimator
    
    public var lensHeight: CGFloat = 40 {
        didSet { invalidateIntrinsicContentSize(); setNeedsLayout() }
    }
    
    public var lensCornerRadius: CGFloat = 20 {
        didSet { setNeedsLayout() }
    }
    
    private var currentTabIndex: Int = 0
    private var tabFrames: [CGRect] = []
    
    public init() {
        self.glassView = LiquidGlassView(configuration: .tabLens)
        self.animator = GlassSpringAnimator(config: .bouncy)
        super.init(frame: .zero)
        setupViews()
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
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 5
        layer.shadowOpacity = 0.12
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = lensCornerRadius
    }
    
    public func setTabFrames(_ frames: [CGRect]) {
        self.tabFrames = frames
        if !frames.isEmpty && currentTabIndex < frames.count {
            updateLensFrame(for: currentTabIndex, animated: false)
        }
    }
    
    public func moveToTab(_ index: Int, animated: Bool = true) {
        guard index >= 0 && index < tabFrames.count else { return }
        let previousIndex = currentTabIndex
        currentTabIndex = index
        if animated && previousIndex != index {
            animateStretchTransition(from: previousIndex, to: index)
        } else {
            updateLensFrame(for: index, animated: false)
        }
    }
    
    private func updateLensFrame(for index: Int, animated: Bool) {
        guard index < tabFrames.count else { return }
        let tabFrame = tabFrames[index]
        let padding: CGFloat = 8
        let lensFrame = CGRect(
            x: tabFrame.midX - (tabFrame.width + padding) / 2,
            y: tabFrame.midY - lensHeight / 2,
            width: tabFrame.width + padding,
            height: lensHeight
        )
        if animated {
            animator.animateStretch(view: self, to: lensFrame)
        } else {
            frame = lensFrame
        }
    }
    
    private func animateStretchTransition(from fromIndex: Int, to toIndex: Int) {
        guard fromIndex < tabFrames.count && toIndex < tabFrames.count else { return }
        let fromFrame = tabFrames[fromIndex]
        let toFrame = tabFrames[toIndex]
        let padding: CGFloat = 8
        
        let stretchedMinX = min(fromFrame.minX, toFrame.minX) - padding / 2
        let stretchedMaxX = max(fromFrame.maxX, toFrame.maxX) + padding / 2
        let stretchedFrame = CGRect(
            x: stretchedMinX,
            y: fromFrame.midY - lensHeight / 2,
            width: stretchedMaxX - stretchedMinX,
            height: lensHeight
        )
        
        let finalFrame = CGRect(
            x: toFrame.midX - (toFrame.width + padding) / 2,
            y: toFrame.midY - lensHeight / 2,
            width: toFrame.width + padding,
            height: lensHeight
        )
        
        UIView.animate(withDuration: 0.15, delay: 0, options: [.curveEaseOut], animations: {
            self.frame = stretchedFrame
        }) { _ in
            UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [], animations: {
                self.frame = finalFrame
            }) { _ in
                self.glassView.flashBorder()
            }
        }
    }
    
    public func updatePositionDuringDrag(progress: CGFloat, from fromIndex: Int, to toIndex: Int) {
        guard fromIndex < tabFrames.count && toIndex < tabFrames.count else { return }
        let fromFrame = tabFrames[fromIndex]
        let toFrame = tabFrames[toIndex]
        let padding: CGFloat = 8
        let clampedProgress = max(0, min(1, progress))
        let currentX = fromFrame.midX + (toFrame.midX - fromFrame.midX) * clampedProgress
        let currentWidth = fromFrame.width + (toFrame.width - fromFrame.width) * clampedProgress
        let stretchFactor: CGFloat = 1.0 + 0.2 * sin(clampedProgress * .pi)
        let stretchedWidth = (currentWidth + padding) * stretchFactor
        frame = CGRect(
            x: currentX - stretchedWidth / 2,
            y: fromFrame.midY - lensHeight / 2,
            width: stretchedWidth,
            height: lensHeight
        )
    }
    
    public func finishDrag(velocity: CGFloat) {
        let nearestIndex = findNearestTabIndex()
        moveToTab(nearestIndex, animated: true)
    }
    
    private func findNearestTabIndex() -> Int {
        let currentCenter = frame.midX
        var nearestIndex = 0
        var nearestDistance = CGFloat.greatestFiniteMagnitude
        for (index, tabFrame) in tabFrames.enumerated() {
            let distance = abs(tabFrame.midX - currentCenter)
            if distance < nearestDistance {
                nearestDistance = distance
                nearestIndex = index
            }
        }
        return nearestIndex
    }
    
    public func setContentSource(_ view: UIView?) { glassView.setContentSource(view) }
    public func setDarkMode(_ isDark: Bool) { glassView.setDarkMode(isDark) }
    public func updateRefraction() { glassView.updateRefraction() }
    public func setPerformanceMode(_ enabled: Bool) { glassView.setPerformanceMode(enabled) }
}