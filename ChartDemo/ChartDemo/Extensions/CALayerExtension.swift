//
//  CALayerExtension.swift
//  BarChart
//
//  Created by Nguyen Vu Nhat Minh on 21/5/19.
//  Copyright © 2019 Nguyen Vu Nhat Minh. All rights reserved.
//

import UIKit

extension CALayer {
    
    func addLineLayer(
        lineSegment: BarLineSegment,
        color: CGColor?,
        lineWidth: CGFloat,
        isDashed: Bool,
        animated: Bool = true,
        oldSegment: BarLineSegment?
    ) {
        let layer = CAShapeLayer()
        layer.path = UIBezierPath(lineSegment: lineSegment).cgPath
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = color
        layer.lineWidth = lineWidth
        if isDashed {
            layer.lineDashPattern = [4, 4]
        }
        self.addSublayer(layer)
        
        if animated, let segment = oldSegment {
            layer.animate(
                fromValue: UIBezierPath(lineSegment: segment).cgPath,
                toValue: layer.path!,
                keyPath: "path")
        }
    }
    
    func addCurvedLineLayer(
        points: [CGPoint],
        color: CGColor?,
        lineWidth: CGFloat,
        isDashed: Bool = false,
        animated: Bool = true,
        oldPoints: [CGPoint]
    ) {
        let layer = CAShapeLayer()
        layer.path = UIBezierPath(from: points).cgPath
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = color
        layer.lineWidth = lineWidth
        if isDashed {
            layer.lineDashPattern = [4, 4]
        }
        self.addSublayer(layer)
        
        if animated, !oldPoints.isEmpty {
            layer.animate(
                fromValue: UIBezierPath(from: oldPoints).cgPath,
                toValue: layer.path!,
                keyPath: "path")
        }
    }
    
    func addTextLayer(frame: CGRect, color: CGColor?, fontSize: CGFloat, text: String, animated: Bool = true, oldFrame: CGRect?) {
        let textLayer = CATextLayer()
        textLayer.frame = frame
        textLayer.foregroundColor = color
        textLayer.backgroundColor = UIColor.clear.cgColor
        textLayer.alignmentMode = CATextLayerAlignmentMode.center
        textLayer.contentsScale = UIScreen.main.scale
        textLayer.font = CTFontCreateWithName(UIFont.systemFont(ofSize: 0).fontName as CFString, 0, nil)
        textLayer.fontSize = fontSize
        textLayer.string = text
        self.addSublayer(textLayer)
        
        if animated, let oldFrame = oldFrame {
            // "frame" property is not animatable in CALayer, so, I use "position" instead
            // Position is at the center of the frame (if you don't change the anchor point)
            let oldPosition = CGPoint(x: oldFrame.midX, y: oldFrame.midY)
            textLayer.animate(fromValue: oldPosition, toValue: textLayer.position, keyPath: "position")
        }
    }
    
    func addRectangleLayer(
        frame: CGRect,
        name: String?,
        color: CGColor?,
        cornerRadius: CGFloat = 0,
        maskedCorners: CACornerMask = [],
        animated: Bool,
        oldFrame: CGRect?
    ) {
        let layer = CALayer()
        layer.frame = frame
        layer.backgroundColor = color
        layer.cornerRadius = cornerRadius
        layer.maskedCorners = maskedCorners
        layer.name = name
        self.addSublayer(layer)
        
        if animated, let oldFrame = oldFrame {
            layer.animate(fromValue: CGPoint(x: oldFrame.midX, y: oldFrame.midY), toValue: layer.position, keyPath: "position")
            layer.animate(fromValue: CGRect(x: 0, y: 0, width: oldFrame.width, height: oldFrame.height), toValue: layer.bounds, keyPath: "bounds")
        }
    }
    
    func addCircleLayer(
        frame: CGRect,
        name: String?,
        fillColor: CGColor?,
        borderColor: CGColor?,
        borderWidth: CGFloat,
        shadowOpacity: Float,
        shadowRadius: CGFloat,
        shadowOffset: CGSize,
        shadowColor: CGColor?
    ) {
        let layer = CAShapeLayer()
        layer.path = UIBezierPath(ovalIn: frame).cgPath
        layer.fillColor = fillColor
        layer.borderColor = UIColor.red.cgColor
        layer.borderWidth = borderWidth
        layer.name = name
        self.addSublayer(layer)
        
        if shadowOpacity > 0 {
            layer.shadowRadius = shadowRadius
            layer.shadowOpacity = shadowOpacity
            layer.shadowOffset = shadowOffset
            layer.shadowColor = shadowColor
        }
        
        if borderWidth > 0 {
            let borderLayer = CAShapeLayer()
            borderLayer.path = UIBezierPath(ovalIn: frame).cgPath
            borderLayer.lineWidth = borderWidth
            borderLayer.strokeColor = borderColor
            borderLayer.fillColor = UIColor.clear.cgColor
            layer.addSublayer(borderLayer)
        }
    }
    
    func animate(fromValue: Any, toValue: Any, keyPath: String) {
        let anim = CABasicAnimation(keyPath: keyPath)
        anim.fromValue = fromValue
        anim.toValue = toValue
        anim.duration = 0.5
        anim.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        self.add(anim, forKey: keyPath)
    }
}
