//
//  GameAction.swift
//  ibankerInterfaceDesign
//
//  Created by Elizabeth Maiser on 7/23/25.
//


import Foundation
enum GameAction: Codable, Equatable {
    case collectSalary(amount: Int)
    case payPlayer(_ playerID: String, amount: Int)
    case addMoney(amount: Int)
    case subtractMoney(amount: Int)
    case updateSalary(newSalary: Int)
    case custom(description: String)
}
