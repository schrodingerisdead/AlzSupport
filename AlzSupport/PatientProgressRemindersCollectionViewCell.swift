//
//  PatientProgressRemindersCollectionViewCell.swift
//  AlzSupport
//
//  Created by Magdalena Oreshkova on 2/21/24.
//

import UIKit

class PatientProgressRemindersCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var Reminder: UILabel!
    @IBOutlet weak var UnCheckedButton: UIButton!
    @IBOutlet weak var CheckedButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    func configure(with reminder: Reminder) {
            Reminder.text = reminder.text
            
            // Show the appropriate button based on the reminder status
            if reminder.status == "finished" {
                UnCheckedButton.isHidden = true
                CheckedButton.isHidden = false
            } else {
                UnCheckedButton.isHidden = false
                CheckedButton.isHidden = true
            }
        }
    }
