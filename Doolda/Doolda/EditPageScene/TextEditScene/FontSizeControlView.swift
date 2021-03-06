//
//  FontSizeControlView.swift
//  Doolda
//
//  Created by 김민주 on 2021/11/23.
//

import UIKit

class FontSizeControl: UIControl {
    private (set) var value: CGFloat = 1.0
    
    private let renderer = FontSizeControlRenderer()
    
    private var minimumValue: CGFloat = 0.0
    private var maximumValue: CGFloat = 2.0
    private var previousLocation = CGPoint()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureLayer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.configureLayer()
    }
    
    private func configureLayer() {
        self.renderer.updateBounds(self.bounds)
        
        self.layer.addSublayer(self.renderer.trackLayer)
        self.layer.addSublayer(self.renderer.pointerLayer)
        
    }
    
    func setValue(_ newValue: CGFloat, animated: Bool = false) {
        self.value = min(maximumValue, max(minimumValue, newValue))
    }
    
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        self.previousLocation = touch.location(in: self)
        if self.renderer.trackLayer.frame.contains(self.previousLocation) {
            self.frame.origin = CGPoint(x: 0, y: self.frame.origin.y)
            return true
        } else {
            return false
        }
    }
    
    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let location = touch.location(in: self)
        let deltaLocation = Double(location.y - self.previousLocation.y)
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        let initalPointerX = self.renderer.pointerLayer.position.x
        if deltaLocation < 0 {
            self.renderer.pointerLayer.position = CGPoint(
                x: initalPointerX,
                y: self.previousLocation.y + deltaLocation < 0 ? 0 : self.previousLocation.y + deltaLocation
            )
        } else if deltaLocation >= 0 {
            self.renderer.pointerLayer.position = CGPoint(
                x: initalPointerX,
                y: self.previousLocation.y + deltaLocation > self.renderer.trackLayer.bounds.height
                ? self.renderer.trackLayer.bounds.height : self.previousLocation.y + deltaLocation
            )
        }
        CATransaction.commit()
        
        let valueGap = self.maximumValue - self.minimumValue
        let currentValue =  valueGap - ( self.renderer.pointerLayer.position.y / self.renderer.trackLayer.bounds.height * valueGap )
        self.setValue(currentValue)
        
        return true
    }
    
    private class FontSizeControlRenderer {
        let trackLayer = CAShapeLayer()
        let pointerLayer = CAShapeLayer()
        
        init() {
            self.trackLayer.fillColor = UIColor.clear.cgColor
            self.pointerLayer.fillColor = UIColor.clear.cgColor
        }
        
        func updateBounds(_ bounds: CGRect) {
            self.trackLayer.bounds = bounds
            self.trackLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
            self.updateTrackLayerPath()
            
            self.pointerLayer.bounds = bounds
            self.pointerLayer.bounds.size = CGSize(width: bounds.width, height: bounds.width)
            self.pointerLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
            self.updatePointerLayerPath()
        }
        
        private func updateTrackLayerPath() {
            let bounds = self.trackLayer.bounds
            let path = CGMutablePath()
            path.move(to: CGPoint(x: bounds.minX, y: bounds.minY + bounds.width/8.0))
            path.addLine(to: CGPoint(x:bounds.width/2.0, y: bounds.height - bounds.width/8.0))
            path.addLine(to: CGPoint(x:bounds.width, y: bounds.minY + bounds.width/8.0))
            path.addLine(to: CGPoint(x: bounds.minX, y: bounds.minY + bounds.width/8.0))
            self.trackLayer.path = path
            trackLayer.fillColor = UIColor.white.withAlphaComponent(0.5).cgColor
        }
        
        private func updatePointerLayerPath() {
            let radius: CGFloat = self.pointerLayer.bounds.width / 2.0
            self.pointerLayer.path = UIBezierPath(
                roundedRect: CGRect(x: 0, y: 0, width: 2.0 * radius, height: 2.0 * radius),
                cornerRadius: radius
            ).cgPath
            self.pointerLayer.fillColor = UIColor.white.cgColor
        }
    }
}
