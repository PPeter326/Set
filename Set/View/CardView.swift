//
//  CardView.swift
//  PlayCardTest
//
//  Created by Peter Wu on 5/16/18.
//  Copyright © 2018 Zero. All rights reserved.
//

import UIKit

class CardView: UIView {
    
    var numberOfSymbols: Int = 3 { didSet { setNeedsDisplay()}}
    var symbol: Symbol = .diamond
    var color: UIColor = #colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 1)
    var shade: Shade = .solid

    enum Symbol {
        case oval
        case squiggle
        case diamond
    }
    enum Shade {
        case solid
        case striped
        case unfilled
    }
    override func draw(_ rect: CGRect) {
        // Drawing code
        let path = UIBezierPath()
        path.lineWidth = self.frame.size.width / 30
        let color: UIColor = #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1)
            //            createOvalShape(path: path, rect: cardView.frame, color: color)
            let rects = divide(rect: self.bounds, numberOfSymbols: numberOfSymbols)
            for rect in rects {
                if let context = UIGraphicsGetCurrentContext() {
                    context.saveGState()
                                                    createSquiggleShape(path: path, rect: rect, color: color)
//                                        createOvalShape(path: path, rect: rect, color: color)
//                    createDiamondShape(path: path, rect: rect, color: color)
                    path.addClip()
                                createStripedShape(path: path, rect: rect, color: color)
//                    createFilledShape(path: path, color: color)
                    context.restoreGState()
                }
            }
    }
    
    
    func divide(rect: CGRect, numberOfSymbols: Int) -> [CGRect] {
        // determine rectangle ratio of width and height.  If width is wider than height, then divide across horizontally
        let ratio = rect.size.width / rect.size.height
        // determine origin of first rect based on the number of rects
        // If there's only one, then the one and only rect should be in the center (x = rect.midX - width * 1 / 2)
        // if two, then the two should be split in the center (x = rect.midX - width * 2 / 2)
        // If three, then each one should be equally distributed (x = rect.midX - width * 3 / 2)
        var rects = [CGRect]()
        if ratio >= 1.0 { // width > height: horizontal
            let width = rect.size.width / 3.0
            let height = width / 8 * 5
            var rectOrigin = CGPoint(x: rect.midX - width * CGFloat(numberOfSymbols) * 1 / 2, y: rect.midY - height / 2)
            let size = CGSize(width: width, height: height)
            for _  in 1...numberOfSymbols {
                let rect = CGRect(origin: rectOrigin, size: size).insetBy(dx: width / 10, dy: height / 10)
                rects.append(rect)
                rectOrigin.x += width
            }
        } else { // height > width: vertical
            let height = rect.size.height / 3.0
            let width = height / 5 * 8
            let size = CGSize(width: width, height: height)
            var rectOrigin = CGPoint(x: rect.midX - width / 2, y: rect.midY - height * CGFloat(numberOfSymbols) * 1 / 2)
            for _  in 1...numberOfSymbols {
                let rect = CGRect(origin: rectOrigin, size: size).insetBy(dx: width / 10, dy: height / 10)
                rects.append(rect)
                rectOrigin.y += height
            }
        }
        return rects
    }
    func createStripedShape(path: UIBezierPath, rect: CGRect, color: UIColor) {
        path.removeAllPoints()
        for xPosition in stride(from: rect.origin.x, to: rect.maxX, by: rect.size.width / 10) {
            path.move(to: CGPoint(x: xPosition, y: rect.origin.y))
            path.addLine(to: CGPoint(x: xPosition, y: rect.maxY))
        }
        color.setStroke()
        path.stroke()
    }
    func createFilledShape(path: UIBezierPath, color: UIColor) {
        //        path.removeAllPoints()
        color.setFill()
        path.fill()
    }
    
    func createSquiggleShape(path: UIBezierPath, rect: CGRect, color: UIColor) {
        path.removeAllPoints()
        let quadControlPointLength = rect.width / 8
        path.move(to: CGPoint(x: rect.origin.x + quadControlPointLength, y: rect.origin.y + quadControlPointLength * 2))
        path.addCurve(to: CGPoint(x: rect.maxX - quadControlPointLength, y: rect.origin.y + quadControlPointLength * 2), controlPoint1: CGPoint(x: rect.origin.x + rect.width / 3, y: rect.origin.y), controlPoint2: CGPoint(x: rect.maxX - rect.width / 3, y: rect.maxY - rect.height / 6))
        path.addQuadCurve(to: CGPoint(x: rect.maxX - quadControlPointLength, y: rect.maxY - quadControlPointLength), controlPoint: CGPoint(x: rect.maxX, y: rect.midY))
        //        path.move(to: CGPoint(x: rect.maxX - quadControlPointLength, y: rect.maxY - quadControlPointLength))
        path.addCurve(to: CGPoint(x: rect.origin.x + quadControlPointLength, y: rect.maxY - quadControlPointLength), controlPoint1: CGPoint(x: rect.maxX - rect.width / 3, y: rect.maxY), controlPoint2: CGPoint(x: rect.midX - quadControlPointLength, y: rect.origin.y + rect.height / 3))
        path.addQuadCurve(to: CGPoint(x: rect.origin.x + quadControlPointLength, y: rect.origin.y + quadControlPointLength * 2), controlPoint: CGPoint(x: rect.origin.x, y: rect.midY + quadControlPointLength))
        path.lineJoinStyle = .round
        path.close()
        color.setStroke()
        path.stroke()
    }
    func createDiamondShape(path: UIBezierPath, rect: CGRect, color: UIColor) {
        path.removeAllPoints()
        let verticalSafeSpace = rect.size.height / 8
        let horizontalSafeSpace = rect.size.width / 8
        path.move(to: CGPoint(x: rect.midX, y: rect.origin.y + verticalSafeSpace))
        path.addLine(to: CGPoint(x: rect.maxX - horizontalSafeSpace, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY - verticalSafeSpace))
        path.addLine(to: CGPoint(x: rect.minX + horizontalSafeSpace, y: rect.midY))
        path.close()
        color.setStroke()
        path.stroke()
    }
    
    func createOvalShape(path: UIBezierPath, rect: CGRect, color: UIColor) {
        path.removeAllPoints()
        let controlPointLength = rect.width / 8
        path.move(to: CGPoint(x: (rect.origin.x + controlPointLength), y: rect.origin.y + controlPointLength))
        path.addLine(to: CGPoint(x: (rect.maxX - controlPointLength), y: rect.origin.y + controlPointLength))
        path.addQuadCurve(to: CGPoint(x: (rect.maxX - controlPointLength), y: rect.maxY - controlPointLength), controlPoint: CGPoint(x: rect.maxX, y: rect.midY))
        path.addLine(to: CGPoint(x: (rect.origin.x + controlPointLength), y: rect.maxY - controlPointLength))
        path.addQuadCurve(to: CGPoint(x: (rect.origin.x + controlPointLength), y: rect.origin.y + controlPointLength), controlPoint: CGPoint(x: rect.minX, y: rect.midY))
        path.close()
        color.setStroke()
        path.stroke()
    }

}
