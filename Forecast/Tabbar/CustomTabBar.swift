//
//  CustomTabBar.swift
//  Forecast
//
//  Created by Ahmed on 22/07/2023.
//

import UIKit

@IBDesignable
class CustomTabBar: UITabBar {

    private var shapeLayer: CALayer?

    private func addShape() {
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = createPath()
        shapeLayer.strokeColor = UIColor.lightGray.cgColor
        shapeLayer.fillColor = UIColor(named: "customPink")?.cgColor
        shapeLayer.lineWidth = 1.0

        if let oldShapeLayer = self.shapeLayer {
            self.layer.replaceSublayer(oldShapeLayer, with: shapeLayer)
        } else {
            self.layer.insertSublayer(shapeLayer, at: 0)
        }

        self.shapeLayer = shapeLayer
        self.tintColor = .black
        self.unselectedItemTintColor = .black.withAlphaComponent(0.5)
    }

    override func draw(_ rect: CGRect) {
        self.addShape()
        
    }

    func createPath() -> CGPath {

        let height: CGFloat = 40.0
        let path = UIBezierPath()
        let centerWidth = self.frame.width / 2

        path.move(to: CGPoint(x: 80, y: 0)) // start top left
        path.addLine(to: CGPoint(x: (centerWidth - height * 2), y: 0)) // the beginning of the trough

        // first curve down
        path.addCurve(to: CGPoint(x: centerWidth, y: height),
                      controlPoint1: CGPoint(x: (centerWidth - 30), y: 0), controlPoint2: CGPoint(x: centerWidth - 35, y: height))
        // second curve up
        path.addCurve(to: CGPoint(x: (centerWidth + height * 2), y: 0),
                      controlPoint1: CGPoint(x: centerWidth + 35, y: height), controlPoint2: CGPoint(x: (centerWidth + 30), y: 0))

        // complete the rect
        path.addLine(to: CGPoint(x: self.frame.width - 80, y: 0))
        path.addCurve(to: CGPoint(x: self.frame.width - 150, y: self.frame.height - 20),
                      controlPoint1: CGPoint(x: self.frame.width - 75, y: self.frame.height - 18), controlPoint2: CGPoint(x: self.frame.width - 75, y: self.frame.height - 18))
        path.addLine(to: CGPoint(x: 170, y: self.frame.height - 20))
        path.addCurve(to: CGPoint(x: 80, y: 0),
                      controlPoint1: CGPoint(x: 75, y: self.frame.height - 18), controlPoint2: CGPoint(x: 75, y: self.frame.height - 18))
        path.close()
        
        self.itemPositioning = .centered

        return path.cgPath
    }
}
