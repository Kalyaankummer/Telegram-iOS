import Foundation
import UIKit

/// Tab bar selection lens with stretch animation between tabs
public final class LiquidGlassTabLens: UIView {
    
    // MARK: - Subviews
    
    private let lensGlassView: LiquidGlassView
    private var currentTabIndex: Int = 0
    private var tabFrames: [CGRect] = []
    
    // MARK: - Configuration
    
    public var tabHeight: CGFloat = 44.0 {
        didSet {
            setNeedsLayout()
        }
    }
    
    public var tabSpacing: CGFloat = 8.0 {
        didSet {
            setNeedsLayout()
        }
    }
    
    public var lensInsets: UIEdgeInsets = UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8) {
        didSet {
            setNeedsLayout()
        }
    }
    
    // MARK: - Callbacks
    
    public var onTabSelected: ((Int) -> Void)?
    
    // MARK: - Initialization
    
    public init(style: UIBlurEffect.Style = .light) {
        self.lensGlassView = LiquidGlassView(style: style)
        
        super.init(frame: .zero)
        
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        backgroundColor = .clear
        
        // Lens glass view (will be positioned based on selected tab)
        lensGlassView.cornerRadius = (tabHeight - lensInsets.top - lensInsets.bottom) / 2.0
        lensGlassView.showChromaticBorder = true
        lensGlassView.blurIntensity = .strong
        lensGlassView.refractionIntensity = 0.7
        insertSubview(lensGlassView, at: 0)
        
        // Add shadow to lens for depth
        lensGlassView.layer.shadowColor = UIColor.black.cgColor
        lensGlassView.layer.shadowOffset = CGSize(width: 0, height: 1)
        lensGlassView.layer.shadowRadius = 4
        lensGlassView.layer.shadowOpacity = 0.15
    }
    
    // MARK: - Tab Management
    
    /// Configure tabs with their frames
    public func setTabFrames(_ frames: [CGRect]) {
        tabFrames = frames
        
        // Position lens at current tab
        if currentTabIndex < frames.count {
            updateLensPosition(toTabIndex: currentTabIndex, animated: false)
        }
    }
    
    /// Select a tab with animation
    public func selectTab(at index: Int, animated: Bool = true) {
        guard index >= 0 && index < tabFrames.count else { return }
        guard index != currentTabIndex else { return }
        
        let previousIndex = currentTabIndex
        currentTabIndex = index
        
        updateLensPosition(toTabIndex: index, animated: animated, fromIndex: previousIndex)
        
        onTabSelected?(index)
    }
    
    private func updateLensPosition(toTabIndex index: Int, animated: Bool, fromIndex: Int? = nil) {
        guard index < tabFrames.count else { return }
        
        let targetFrame = lensFrameForTab(at: index)
        
        if animated && LiquidGlassConfiguration.shared.shouldEnableSpringAnimations {
            // Determine if we're moving left or right
            let isMovingRight = (fromIndex ?? 0) < index
            
            // Stretch animation
            if let fromIndex = fromIndex {
                let fromFrame = lensFrameForTab(at: fromIndex)
                let distance = abs(targetFrame.midX - fromFrame.midX)
                let stretchWidth = distance * 1.3 // Stretch beyond target
                
                // First phase: stretch towards target
                let stretchFrame = CGRect(
                    x: min(fromFrame.minX, targetFrame.minX),
                    y: targetFrame.minY,
                    width: stretchWidth,
                    height: targetFrame.height
                )
                
                UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
                    self.lensGlassView.frame = stretchFrame
                }) { _ in
                    // Second phase: snap to target with spring
                    GlassSpringAnimator.springAnimate(
                        duration: 0.4,
                        damping: 0.65,
                        velocity: 0.6,
                        animations: {
                            self.lensGlassView.frame = targetFrame
                        }
                    )
                }
                
                // Animate refraction during stretch
                lensGlassView.refractionIntensity = 0.9
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    UIView.animate(withDuration: 0.4) {
                        self.lensGlassView.refractionIntensity = 0.7
                    }
                }
            } else {
                // Simple spring animation
                GlassSpringAnimator.springAnimate(
                    duration: 0.5,
                    damping: 0.7,
                    velocity: 0.5,
                    animations: {
                        self.lensGlassView.frame = targetFrame
                    }
                )
            }
        } else {
            lensGlassView.frame = targetFrame
        }
    }
    
    private func lensFrameForTab(at index: Int) -> CGRect {
        guard index < tabFrames.count else { return .zero }
        
        let tabFrame = tabFrames[index]
        return CGRect(
            x: tabFrame.minX + lensInsets.left,
            y: tabFrame.minY + lensInsets.top,
            width: tabFrame.width - lensInsets.left - lensInsets.right,
            height: tabFrame.height - lensInsets.top - lensInsets.bottom
        )
    }
    
    // MARK: - Gesture Handling
    
    public func handleTap(at point: CGPoint) {
        // Find which tab was tapped
        for (index, frame) in tabFrames.enumerated() {
            if frame.contains(point) {
                selectTab(at: index, animated: true)
                
                // Add bounce effect
                lensGlassView.animateBounce(intensity: 1.08)
                break
            }
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        // Update lens position if needed
        if currentTabIndex < tabFrames.count {
            let targetFrame = lensFrameForTab(at: currentTabIndex)
            if lensGlassView.frame != targetFrame {
                lensGlassView.frame = targetFrame
            }
        }
    }
    
    // MARK: - Public API
    
    public var selectedIndex: Int {
        return currentTabIndex
    }
    
    public func setLensBlurIntensity(_ intensity: GlassBlurView.BlurIntensity) {
        lensGlassView.blurIntensity = intensity
    }
    
    public func setLensRefractionIntensity(_ intensity: CGFloat) {
        lensGlassView.refractionIntensity = intensity
    }
    
    public func setChromaticBorderEnabled(_ enabled: Bool) {
        lensGlassView.showChromaticBorder = enabled
    }
}

// MARK: - Helper for Tab Bar Integration

public extension LiquidGlassTabLens {
    
    /// Convenience method to create tab frames from tab count and container width
    static func generateTabFrames(tabCount: Int, containerWidth: CGFloat, tabHeight: CGFloat, spacing: CGFloat = 8.0) -> [CGRect] {
        guard tabCount > 0 else { return [] }
        
        let totalSpacing = spacing * CGFloat(tabCount + 1)
        let availableWidth = containerWidth - totalSpacing
        let tabWidth = availableWidth / CGFloat(tabCount)
        
        var frames: [CGRect] = []
        
        for i in 0..<tabCount {
            let x = spacing + CGFloat(i) * (tabWidth + spacing)
            let frame = CGRect(x: x, y: 0, width: tabWidth, height: tabHeight)
            frames.append(frame)
        }
        
        return frames
    }
}
