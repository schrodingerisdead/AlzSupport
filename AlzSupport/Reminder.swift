//  Reminder.swift
//  AlzSupport
//
//  Created by Magdalena Oreshkova on 2/22/24.
//

import Foundation

struct Reminder {
    var id: String // Unique identifier
    var text: String
    var status: String
    
    init(id: String, text: String, status: String) {
        self.id = id
        self.text = text
        self.status = status
    }
}
