//
//  ViewController.swift
//  Set
//
//  Created by Peter Wu on 4/17/18.
//  Copyright © 2018 Zero. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    // MARK: - UI Elements -
    
    
    @IBOutlet weak var playingCardsMainView: PlayingCardsMainView! {
        didSet {
            // make new cardviews
            makeCardViews()
            // add swipe and rotate gestures to deal and shuffle, respectively
            let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(swipeDownToDeal(_:)))
            swipeDown.direction = .down
            playingCardsMainView.addGestureRecognizer(swipeDown)
            let rotate = UIRotationGestureRecognizer(target: self, action: #selector(rotateToShuffle(_:)))
            playingCardsMainView.addGestureRecognizer(rotate)
        }
    }
    
    @IBOutlet weak var scoreLabel: UILabel! {
        didSet {
            scoreLabel.attributedText = updateAttributedString("SCORE: 0")
        }
    }

    var score: Int = 0 {
        didSet {
            let scoreString = "SCORE: \(score)"
            scoreLabel.attributedText = updateAttributedString(scoreString)
            
        }
    }
    @IBOutlet weak var dealCardButton: UIButton! {
        didSet {
            dealCardButton.layer.cornerRadius = 8.0
        }
    }
    
    
    var selectedCardViews = [CardView]() {
        didSet {
            assert(selectedCardViews.count < 4, "invalid number of selected card views")
            // reset cardviews style on prior selected cards
            for cardView in oldValue {
                cardView.layer.borderWidth = cardView.frame.width / 100
                cardView.layer.borderColor = #colorLiteral(red: 0.06274510175, green: 0, blue: 0.1921568662, alpha: 1)
            }
            // show border on new selected cards
            for cardView in selectedCardViews {
                cardView.layer.borderWidth = cardView.frame.width / 15
                cardView.layer.borderColor = #colorLiteral(red: 0, green: 0.9914394021, blue: 1, alpha: 1).cgColor
            }
            if let matched = set.matched {
                if matched {
                    selectedCardViews = selectedCardViews.map { (cardView) -> CardView in
                        cardView.layer.borderWidth = cardView.frame.width / 15
                        cardView.layer.borderColor =  UIColor.green.cgColor
                        return cardView
                    }
                } else {
                    selectedCardViews = selectedCardViews.map { (cardView) -> CardView in
                        cardView.layer.borderWidth = cardView.frame.width / 15
                        cardView.layer.borderColor =  UIColor.red.cgColor
                        return cardView
                    }
                }
            }
        }
    }
    
    // MARK: - Game Properties -
    private var set = Set()
    
    // MARK: Card Attributes
    private let colorDictionary: [Card.Color: UIColor] = [
        .color1: #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1),
        .color2: #colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 1),
        .color3: #colorLiteral(red: 0, green: 0.9768045545, blue: 0, alpha: 1)
    ]
    
    private let shapeDictionary: [Card.Shape: CardView.Shape] = [
        .shape1: CardView.Shape.diamond,
        .shape2: CardView.Shape.oval,
        .shape3: CardView.Shape.squiggle
    ]
    
    private let shadingDictionary: [Card.Shading: CardView.Shade] = [
        .shading1: CardView.Shade.solid,
        .shading2: CardView.Shade.striped,
        .shading3: CardView.Shade.unfilled
    ]
    
    // MARK: - View Config -
    
    
    // MARK: - User Actions -
    
    @objc func selectCard( _ gestureRecognizer: UITapGestureRecognizer) {
        assert(set.playedCards.count == playingCardsMainView.cardViews.count, "set: \(set.playedCards.count) views: \(playingCardsMainView.cardViews.count)")
        if gestureRecognizer.state == .ended {
            // tells set to select card
            let cardView = gestureRecognizer.view as! CardView
            let cardViewIndex = playingCardsMainView.cardViews.index(of: cardView)!
            let card = set.playedCards[cardViewIndex]
            
            set.selectCard(card: card) { result in
                switch result {
                case .selected: selectedCardViews.append(cardView)
                case .deselected:
                    guard let index = selectedCardViews.index(of: cardView) else { return }
                    selectedCardViews.remove(at: index)
                case .reset:
                    if set.deck.isEmpty {
                        // If deck is empty, then the views are shifted.  There are now less card views than before
                        // disable dealcard button
                        dealCard(disable: true)
                        // make new cardviews because there are now less cards being displayed
                        makeCardViews()
                        // there are now less cardViews than before and index of previously selected cardView has now been changed
                        // get the index of the card from played card
                        let index = set.playedCards.index(of: card)!
                        // get the selectedCardview from the new index
                        let updatedSelectedCardView = playingCardsMainView.cardViews[index]
                        selectedCardViews.removeAll()
                        selectedCardViews.append(updatedSelectedCardView)
                    } else { // There's always same or more card views than before.
                        makeCardViews()
                        selectedCardViews.removeAll()
                        selectedCardViews.append(cardView)
                    }
                default: break
                }
                // update score
                self.score = set.score
            }
        }
    }
    @IBAction func newGameButtonTouched(_ sender: UIButton) {
        // reset game
        set.reset()
        // clear selectedCardViews
        self.selectedCardViews.removeAll()
        // update card views
        makeCardViews()
        // update score
        score = set.score
        
    }
    
    @IBAction func dealCardButtonTouched(_ sender: UIButton) {
        dealCards()
    }
    
    @objc func swipeDownToDeal(_ gestureRecognizer: UIGestureRecognizer) {
        if gestureRecognizer.state == .ended {
            dealCards()
        }
    }
    
    @objc func rotateToShuffle(_ gestureRecognizer: UIGestureRecognizer) {
        
        switch gestureRecognizer.state {
        case .ended:
            // shuffle cards if deck isn't empty, and a match hasn't taken place yet
            if !set.deck.isEmpty && set.selectedCards.count < 3 {
                // clear selection cards
                selectedCardViews.removeAll()
                // shuffle remaining cards in play and deck
                set.shuffleRemainingCards()
                // update cardViews
                makeCardViews()
            }
        default: break
        }
        

    }
    private func updateAttributedString(_ string: String) -> NSAttributedString {
        var font = UIFont.preferredFont(forTextStyle: .headline).withSize(scoreLabel.frame.height * 0.85)
        font = UIFontMetrics(forTextStyle: .headline).scaledFont(for: font)
        //        let strokeColor = UIColor.black
        //
        //        let strokeWidth = scoreLabel.frame.height / 2
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        let stringAttributes: [NSAttributedStringKey: Any] = [
            .font: font,
            //            .strokeColor: strokeColor,
            //            .strokeWidth: strokeWidth,
            .paragraphStyle: paragraphStyle
        ]
        return NSAttributedString(string: string, attributes: stringAttributes)
    }
    private func dealCards() {
        // 1. tells game to deal three cards, then display the new cards
        // make new cards views only if:
        // A. A match was performed, but there was no match
        // B. No match was performed.
        set.dealCards { (clearSelection, matchedStatus) in
            if clearSelection { // selections were cleared - that means a match was performed
                if let matchedStatus = matchedStatus {
                    if matchedStatus == false { // (A)
                        makeCardViews()
                    } else { // make cardViews only for those cards replaced
                        for selectedCardView in selectedCardViews {
                            let index = playingCardsMainView.cardViews.index(of: selectedCardView)!
                            let card = set.playedCards[index]
                            makeCardView(cardView: selectedCardView, card: card)
                        }
                    }
                }
                // remove all selected card views
                selectedCardViews.removeAll()
            } else {
                makeCardViews() // (B)
            }
        }
        if set.deck.count == 0 {
            dealCard(disable: true)
        }
    }
    
    // MARK: - Helper Functions -
    
    private func makeCardViews() {
        playingCardsMainView.numberOfCardViews = set.playedCards.count
        for (index, card) in set.playedCards.enumerated() {
            let cardView = playingCardsMainView.cardViews[index]
            makeCardView(cardView: cardView, card: card)
        }
    }
    
    private func makeCardView(cardView: CardView, card: Card) {
        guard let color = colorDictionary[card.color] else { return }
        guard let shape = shapeDictionary[card.shape] else { return }
        let numberOfShapes = card.numberOfShapes.rawValue
        guard let shading = shadingDictionary[card.shading] else { return }
        
        cardView.color = color
        cardView.shade = shading
        cardView.shape = shape
        cardView.numberOfShapes = numberOfShapes
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(selectCard(_:)))
        tap.numberOfTapsRequired = 1
        cardView.addGestureRecognizer(tap)
    }
    
    private func dealCard(disable: Bool) {
        if disable {
            self.dealCardButton.isEnabled = false
            self.dealCardButton.backgroundColor =  UIColor.gray
            self.dealCardButton.setTitleColor(UIColor.black, for: .normal)
        } else {
            self.dealCardButton.isEnabled = true
            self.dealCardButton.backgroundColor =  UIColor.red
            self.dealCardButton.setTitleColor(UIColor.white, for: .normal)
        }
    }
}



