//
//  GameTransaction.swift
//  ibankerInterfaceDesign
//
//  Created by Elizabeth Maiser on 7/23/25.
//

import Foundation
struct GameTransaction: Identifiable, Codable, Equatable {
    var id: String // UUID
    var timestamp: Date
    var playerID: String
    var action: GameAction
    var note: String?
}
