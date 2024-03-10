//
//  PatientReminderCollectionViewCell.swift
//  AlzSupport
//
//  Created by Magdalena Oreshkova on 3/3/24.
//

import UIKit

class PatientReminderCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var DoneButton: UIButton!
    @IBOutlet weak var Reminder: UILabel!
    
    private var reminder: Reminder?
    
    // Define a delegate property
    weak var delegate: PatientReminderCollectionViewCellDelegate?
    
    func configure(with reminder: Reminder) {
        Reminder.text = reminder.text
        DoneButton.isHidden = reminder.status != "unfinished" // Show the button if status is "unfinished"
        self.reminder = reminder
    }

    @IBAction func DoneButtonClicked(_ sender: Any) {
        guard var reminder = reminder else {
            return
        }
        
        reminder.status = "finished"
        
        // Call the delegate method
        delegate?.reminderStatusDidChange(for: self, with: reminder)
    }
}
protocol PatientReminderCollectionViewCellDelegate: AnyObject {
    func reminderStatusDidChange(for cell: PatientReminderCollectionViewCell, with reminder: Reminder)
}
