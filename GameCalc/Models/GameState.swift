//
//  GameState.swift
//  ibankerInterfaceDesign
//
//  Created by Elizabeth Maiser on 7/23/25.
//


import Foundation
struct GameState: Equatable, Codable {
    var playerBalances: [String: Int] // Dictionary: Player ID -> Current Balance
    // You might also include other relevant game state, e.g.,
    // var bankBalance: Int // If the bank has its own balance
    // var gameOver: Bool
    // var turn: Int
}
