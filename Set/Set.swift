//
//  Set.swift
//  Set
//
//  Created by Peter Wu on 4/17/18.
//  Copyright © 2018 Zero. All rights reserved.
//

import Foundation

/*
 Four features:
 1. Symbols - "▲", "◼︎", and "✦".
 2. Numbers - one, two, or three symbols. "▲", "▲▲", and "▲▲▲"
 3. Shading - solid, striped, or open
 4. Color - red, green or purple
 
 Play:
 - Allows user to select 3 cards at a time.  Also allow user to deselect cards that are already selected, but only if there 2 or less cards selected.  Once user select 3 cards, a match/mismatch must be determined.
 - match cards (true/false) when user select 3 cards
 - deal cards, 3 at a time, that does one of the following:
 1. replace the selected cards if there's a match
 2. add 3 cards to the game
 
 Score:
 - Each match is 3 points
 - Each mismatch is -5 points
 - If user already selected a card, and user deselects a card, is - 1 point.
 */
class Set {

    // MARK: Game properties and initializer
    
    var deck: [Card]
    var selectedCards = [Card]()
    var matchedCards = [Card]()
    var playedCards = [Card]()
    private(set) var matched = false
    private(set) var score: Int = 0
    
    init() {
        deck = Card.all
        shuffleCards()
        drawCards()
    }
    
    // MARK: - Game Methdods
    
    func selectCard(card: Card) {
        // 1. Add to selected cards -> return true
        //  a. if the card is not already selected
        //  b.
        // 2. Remove from selected cards -> return false
        //  a. If the card is already selected
        // I. Add or remove cards in selectedCard arrays
        switch self.selectedCards.count {
        case 0, 1: // add/remove from selected cards, depending on if user already selected the card
            addOrRemoveSelectedCard(card)
        case 2:
            // 1. match cards in selectedCards
            // 2. if matched:
            //    a.  check card if it's in the matched card set.
            //        i.  yes:  do nothing
            //        ii. no:   clear selected cards array, add card to selected card array
            // 3. if not matched:
            //    a.  clear selected array, add card to selected card array
            // The user could be 1. selecting a card already selected 2. selecting a new card not already selected
            // if 2. check the cards if they match.  If they match, keep track of them in the matched cards list.
            addOrRemoveSelectedCard(card)
            if selectedCards.count == 3 {
                matchCards()
            }
        case 3:
            // User should not be able to select any of the matched cards.  For any other cards, simply clear the selectedcards array and append new one
            // the 3 cards already selected could be A. matched or B. not-matched
            // the new card user selected could be 1. already selected or 2. not already selected
            // 1. - A.  nothing happens.  User can't select a card that's already matching.
            // 1. - B. clear selected cards, and add user's selected card to the list.
            // 2. - A. The played cards replace selected cards with new cards from deck.  The selected cards are cleared.  User's new select card is added to the selcted cards list.
            // 2. - B. clear selected cards, and add user's selected card to the list
            if !matchedCards.contains(card) {
                if matched && !deck.isEmpty { // replace played cards with cards from deck if there was a match and deck is not empty
                    for selectedCard in selectedCards {
                        replacePlayedCard(atIndex: playedCards.index(of: selectedCard)!)
                    }
                }
                selectedCards.removeAll()
                selectedCards.append(card)
            }
        default: // There should be no more than 3 cards selected at a time
            break
        }
    }
    
    func dealCards() {
        // If there are three selected cards:
        // A. three cards already matched: deal cards to replace matched cards
        // B. three cards not matched:  clear selected cards, and deal 3 cards to add at the end
        // add three cards from deck to played cards at the end
        if selectedCards.count == 3 {
            if matched {
                for selectedCard in selectedCards {
                    replacePlayedCard(atIndex: playedCards.index(of: selectedCard)!)
                }
            } else {
                for _ in 1...3 {
                    dealCard(at: (playedCards.endIndex) - 1)
                }
            }
            selectedCards.removeAll()
        } else {
            for _ in 1...3 {
                dealCard(at: (playedCards.endIndex) - 1)
            }
        }
    }
    func reset() {
        self.deck = Card.all
        shuffleCards()
        selectedCards.removeAll()
        matchedCards.removeAll()
        playedCards.removeAll()
        matched = false
        score = 0
        drawCards()
    }
    
    // MARK: - Helper Methods
    
    private func shuffleCards() {
        
        var shuffledCards = [Card]()
        for _ in 0...(self.deck.count - 1) {
            let randomIndex = self.deck.count.arc4random
            shuffledCards.append(self.deck.remove(at: Int(randomIndex)))
        }
        self.deck = shuffledCards
    }
    private func drawCards() {
        for _ in 0...11 {
            playedCards.append(deck.removeLast())
        }
    }
    
    private func dealCard(at index: Int) {
        playedCards.insert(deck.removeLast(), at: index)
    }
    private func matchCards() {
        // A set of cards are matched when any of the attributes are matched between ONLY two cards
        // If cards are matched, add them to the matched cards
        if onlyTwoEquals(amongst: selectedCards) {
            score += 3
            self.matchedCards.append(contentsOf: selectedCards)
            matched = true
        } else {
            score -= 5
            matched = false
        }
    }
    
    private func addOrRemoveSelectedCard(_ card: Card){
        if selectedCards.contains(card) {
            // get index of the card in selected cards
            let index = selectedCards.index(of: card)!
            selectedCards.remove(at: index)
            score -= 1
        } else {
            selectedCards.append(card)
        }
    }
    private func onlyTwoEquals(amongst cards:[Card]) -> Bool {
        // Go through each card in the array and compare each attribute.  The cards are matched only if all attributes of all cards in a set are same or totally different.
        // Attribute 1 comparison
        let colorAttributeMatch = (cards[0].color == cards[1].color && cards[1].color == cards[2].color) || (cards[0].color != cards[1].color && cards[1].color != cards[2].color && cards[0].color != cards[2].color)
        
        let shadingAttributeMatch = (cards[0].shading == cards[1].shading && cards[1].shading == cards[2].shading) || (cards[0].shading != cards[1].shading && cards[1].shading != cards[2].shading && cards[0].shading != cards[2].shading)
        
        let numberOfSymbolsMatch = (cards[0].numberOfSymbols == cards[1].numberOfSymbols && cards[1].numberOfSymbols == cards[2].numberOfSymbols) || (cards[0].numberOfSymbols != cards[1].numberOfSymbols && cards[1].numberOfSymbols != cards[2].numberOfSymbols && cards[0].numberOfSymbols != cards[2].numberOfSymbols)
        
        let symbolsMatch = (cards[0].symbol == cards[1].symbol && cards[1].symbol == cards[2].symbol) || (cards[0].symbol != cards[1].symbol && cards[1].symbol != cards[2].symbol && cards[0].symbol != cards[2].symbol)
        
        // Only a match if all attributes match
        return symbolsMatch && numberOfSymbolsMatch && shadingAttributeMatch && colorAttributeMatch
//        return true
    }
    private func replacePlayedCard(atIndex index: Int) {
        if !deck.isEmpty {
            playedCards[index] = deck.removeLast()
        }
    }
}

extension Int {
    var arc4random: Int {
        if self >  0 {
            return Int(arc4random_uniform(UInt32(self)))
        } else if self < 0 {
            return Int(arc4random_uniform(UInt32(abs(self))))
        } else {
            return 0
        }
    }
}



