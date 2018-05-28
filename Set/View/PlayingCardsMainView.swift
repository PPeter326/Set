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
    
    lazy var grid = Grid(layout: Grid.Layout.aspectRatio(AspectRatio.cardViewRectangle), frame: self.bounds)
    
    var numberOfCardViews: Int = 0 {
        didSet {
            func makeCells(startingIndex: Int) {
                for index in startingIndex...(numberOfCardViews - 1) {
                    let rect = grid[index]!
                    let newRect = rect.insetBy(dx: rect.width / 10, dy: rect.height / 10)
                    let cardView = CardView(frame: newRect)
                    cardView.backgroundColor = #colorLiteral(red: 0, green: 0.5628422499, blue: 0.3188166618, alpha: 0.7835308305)
                    cardView.layer.borderWidth = rect.width / 100
                    cardView.layer.borderColor = #colorLiteral(red: 0.06274510175, green: 0, blue: 0.1921568662, alpha: 1)
                    self.addSubview(cardView)
                }
            }
            // recalculate grid every time number of cards are set
            grid.cellCount = numberOfCardViews
            let cellCountChanges = numberOfCardViews - oldValue
            if cellCountChanges > 0 { // more cardViews than before
                // make additional cardViews starting at the first index after ending index of old value
                let oldValueEndIndex = oldValue - 1 // if old value had 12 cards, end index = 12 - 1 = 11
                let startingIndex = oldValueEndIndex + 1
                makeCells(startingIndex: startingIndex)
            } else if cellCountChanges < 0 {
                // first remove all subviews
                for cardView in cardViews {
                    cardView.removeFromSuperview()
                }
                // make new cardviews starting from scratch
                makeCells(startingIndex: 0)
            }
            updateCardsFrame()
            setNeedsDisplay()
        }
    }
    
    var cardViews: [CardView] {
        get {
            var temporaryCardViews = [CardView]()
            for subview in self.subviews {
                if let cardView = subview as? CardView {
                    temporaryCardViews.append(cardView)
                }
            }
            return temporaryCardViews
        }
        
    }
    
    var selectedCardViews: [CardView]?
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        setNeedsLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        grid.frame = self.bounds
        updateCardsFrame()
    }
    
    /// Update each cardView's frame with the new CGRect from grid object
    func updateCardsFrame() {
        for (index, cardView) in self.cardViews.enumerated() {
            if let rect = grid[index] {
                let newRect = rect.insetBy(dx: rect.width / 10, dy: rect.height / 10)
                cardView.frame = newRect
            }
        }
    }
    

}


