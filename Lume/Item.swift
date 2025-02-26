//
//  Item.swift
//  Lume
//
//  Created by Khushmeet Singh on 2/25/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
