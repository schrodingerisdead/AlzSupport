//
//  ReminderCollectionViewCell.swift
//  AlzSupport
//
//  Created by Magdalena Oreshkova on 3/4/24.
//

import UIKit

class ReminderCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var Reminder: UILabel!
    @IBOutlet weak var Status: UILabel!
    
    func configure(with reminder: Reminder) {
           Reminder.text = reminder.text
           Status.text = reminder.status
        
        if reminder.status == "finished" {
                    backgroundColor = UIColor.green // Set to green for finished reminders
                } else {
                    backgroundColor = UIColor.red // Set to red for unfinished reminders
                }
       }
    
}
