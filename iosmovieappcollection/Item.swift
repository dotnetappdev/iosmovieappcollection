//
//  Item.swift
//  iosmovieappcollection
//
//  Created by david on 19/07/2025.
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
