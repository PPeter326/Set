//
//  PlayingCardsMainView.swift
//  Set
//
//  Created by Peter Wu on 5/17/18.
//  Copyright © 2018 Zero. All rights reserved.
//

import UIKit

class PlayingCardsMainView: UIView {
    private struct AspectRatio {
        static let cardViewRectangle: CGFloat = 5.0 / 8.0
    }
    private lazy var grid = Grid(layout: Grid.Layout.aspectRatio(AspectRatio.cardViewRectangle), frame: self.bounds)
    
    @IBInspectable var numberOfCards: Int = 12 {
        didSet {
            grid.cellCount = numberOfCards
            makeCardViews()
            setNeedsDisplay(); setNeedsLayout()
        }
    }
    override func draw(_ rect: CGRect) {
//        self.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    }
    
    func makeCardViews() {
        grid.cellCount = numberOfCards
        
        for count in 0...numberOfCards {
            if let rect = grid[count] {
                let newRect = rect.insetBy(dx: rect.width / 10, dy: rect.height / 10)
                let cardView = CardView(frame: newRect)
                cardView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                cardView.layer.borderWidth = rect.width / 100
                cardView.layer.borderColor = #colorLiteral(red: 0.06274510175, green: 0, blue: 0.1921568662, alpha: 1)
                self.addSubview(cardView)
            } else {
                print("no cards")
            }
        }
    }

}
