//
//  GameStateReducer.swift
//  ibankerInterfaceDesign
//
//  Created by Elizabeth Maiser on 7/23/25.
//


import Foundation
class GameStateReducer {
    
    static func reduce(players: [Player], transactions: [GameTransaction]) -> GameState {
        // 1. Initialize the starting state
        var currentGameState = GameState(playerBalances: [:], playerSalaries: [:])

        // Populate initial balances for all players (assuming they start with 0 or a fixed amount)
        for player in players {
            currentGameState.playerBalances[player.id] = 0 // Or some starting money
            currentGameState.playerSalaries[player.id] = 0
        }

        // 2. Iterate through each transaction and apply its effect
        for transaction in transactions {
            let playerID = transaction.playerID
            var currentPlayerBalance = currentGameState.playerBalances[playerID] ?? 0 // Get current balance, or 0 if player somehow not found
            var currentPlayerSalary = currentGameState.playerSalaries[playerID] ?? 0

            switch transaction.action {
            case .collectSalary(let amount):
                currentPlayerBalance += amount
                // You might also subtract from a central "bank" balance here if you track it
                // currentGameState.bankBalance -= amount

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

            case .custom(let description):
                // For custom actions, you'd need more logic or
                // potentially a way to define custom effects for these.
                // For simplicity, let's assume custom actions don't directly
                // affect balances in this basic example, or they'd need
                // to carry explicit amount changes.
                print("Custom action: \(description) by \(playerID)")
            }

            // Update the player's balance in the current state
            currentGameState.playerBalances[playerID] = currentPlayerBalance
            currentGameState.playerSalaries[playerID] = currentPlayerSalary
        }

        // 3. Return the final, calculated state
        return currentGameState
    }
}
