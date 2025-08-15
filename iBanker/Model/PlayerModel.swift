//
//  PlayerModel.swift
//  ibankerInterfaceDesign
//
//  Created by Elizabeth Maiser on 7/22/25.
//


import Foundation

struct Player: Identifiable, Codable, Equatable {
    var id: String         // Could be UUID for now; later can be userID/email
    var name: String
    var token: String
    var isLocalOnly: Bool  // true for pass-the-phone mode
    var authProviderID: String? // Later: Google/Firebase ID
    var sheetRowIndex: Int?     // Optional: where in shared Sheet this player maps
    var salary: Int
}
