//
//  CircularProgressView.swift
//  Uber Clone
//
//  Created by S M H  on 25/11/2024.
//
import UIKit

class CircularProgressView: UIView {
    //MARK: - Properties
    
    var progressLayer: CAShapeLayer!
    var trackLayer: CAShapeLayer!
    var pulsatingLayers: CAShapeLayer!
    
    
    //MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureCircleLayers()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - Helper Functions
    
    
    private func configureCircleLayers() {
        pulsatingLayers = circleShapeLayer(strokeColor: .clear, fillColor: .link)
        layer.addSublayer(pulsatingLayers)
        
        trackLayer = circleShapeLayer(strokeColor: .white, fillColor: .clear)
        layer.addSublayer(trackLayer)
        
        progressLayer = circleShapeLayer(strokeColor: .red, fillColor: .clear)
        layer.addSublayer(progressLayer)
        progressLayer.strokeEnd = 1
    }
    
    
    private func circleShapeLayer(strokeColor: UIColor,
                                  fillColor: UIColor) -> CAShapeLayer {
        let layer = CAShapeLayer()
        
        let center = CGPoint(x: 0, y: 32)
        
//        let path = UIBezierPath(arcCenter: .zero, radius: bounds.width / 2, startAngle: 0, endAngle: .pi * 2, clockwise: true)
        
        let path = UIBezierPath(arcCenter: center,
                                radius: self.frame.width / 2,
                                startAngle: -(.pi / 2),
                                endAngle: 1.5 * .pi,
                                clockwise: true)
        
        layer.path = path.cgPath
        layer.strokeColor = strokeColor.cgColor
        layer.fillColor = fillColor.cgColor
        layer.lineWidth = 12
        layer.lineCap = .round
        layer.position = self.center
        
        return layer
    }
    
    // loading animation with bounching
    func animatePulsatingLayer() {
        let animation = CABasicAnimation(keyPath: "transform.scale")
        
        animation.toValue = 1.3
        animation.duration = 0.8
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation.autoreverses = true
        animation.repeatCount = Float.infinity
        
        pulsatingLayers.add(animation, forKey: "pulsing")
    }
    
    // Progress circle countdown with animation
    func setProgressWithAnimation(value: Float,
                                  duration: TimeInterval,
                                  completion: (@escaping() -> Void)) {
        
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 1
        animation.toValue = value
        animation.duration = duration
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        progressLayer.strokeEnd = CGFloat(value)
        progressLayer.add(animation, forKey: "animateProgress")
        
        CATransaction.commit()
    }
    
}
