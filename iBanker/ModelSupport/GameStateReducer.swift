//
//  GameStateReducer.swift
//
//  Created by Elizabeth Maiser, Fast Five Products LLC, on 7/23/25.
//  Modified by Pete Maiser, Fast Five Products LLC, on 7/7/26.
//
//  Copyright © 2025, 2026 Fast Five Products LLC. All rights reserved.
//
//  This file is part of a project licensed under the GNU Affero General Public License v3.0.
//  See the LICENSE file at the root of this repository for full terms.
//
//  An exception applies: Fast Five Products LLC retains the right to use this code and
//  derivative works in proprietary software without being subject to the AGPL terms.
//  See LICENSE-EXCEPTIONS.md for details.
//


import Foundation
class GameStateReducer {
    
    static func reduce(players: [Player], transactions: [GameTransaction]) -> GameState {
        // 1. Initialize the starting state
        var currentGameState = GameState(playerBalances: [:], playerSalaries: [:])

        // Every player starts at 0.
        for player in players {
            currentGameState.playerBalances[player.id] = 0
            currentGameState.playerSalaries[player.id] = 0
        }

        // 2. Replay each transaction.
        for transaction in transactions {
            let playerID = transaction.playerID
            var currentPlayerBalance = currentGameState.playerBalances[playerID] ?? 0 // 0 if player somehow absent
            var currentPlayerSalary = currentGameState.playerSalaries[playerID] ?? 0

            switch transaction.action {
            case .collectSalary(let amount):
                currentPlayerBalance += amount

            case .payPlayer(let recipientPlayerID, let amount):
                currentPlayerBalance -= amount
                var recipientBalance = currentGameState.playerBalances[recipientPlayerID] ?? 0
                recipientBalance += amount
                currentGameState.playerBalances[recipientPlayerID] = recipientBalance

            case .addMoney(let amount):
                currentPlayerBalance += amount

            case .subtractMoney(let amount):
                currentPlayerBalance -= amount
                
            case .updateSalary(let newSalary):
                currentPlayerSalary = newSalary
                
            case .resetPlayer(let balance, let salary):
                currentPlayerBalance = balance
                currentPlayerSalary = salary

            case .createPlayer(let balance, let salary):
                currentPlayerBalance = balance
                currentPlayerSalary = salary

            case .custom(let description):
                // Custom actions carry no balance effect; logged only.
                print("Custom action: \(description) by \(playerID)")
            }

            // Write back balance and salary.
            currentGameState.playerBalances[playerID] = currentPlayerBalance
            currentGameState.playerSalaries[playerID] = currentPlayerSalary
        }

        // 3. Return the derived state.
        return currentGameState
    }
}
