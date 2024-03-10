//
//  PatientReminderProgressTableViewCell.swift
//  AlzSupport
//
//  Created by Magdalena Oreshkova on 2/21/24.
//

import UIKit
import FirebaseDatabase

protocol PatientReminderProgressTableViewCellDelegate: AnyObject {
    func reminderDeleted(reminderID: String)
}

class PatientReminderProgressTableViewCell: UITableViewCell {
    
//the reminder already exists in the database
// it's created by the family member for the patient
    // this is what the database looks like
    /*
     reminders
     :
     Value
     Value
     -NrCXtakFgigUbywI50M
     createdBy
     :
     "8n7aSvfDSWU1qY1brhsxhOpOW153"
     status
     :
     "unfinished"
     text
     :
     "take medication"     */
    // this view is supposed to show the patients progress

// the delete button is supposed to delete it from
// both the database and the table
    
    @IBOutlet weak var TheReminder: UILabel!
    @IBOutlet weak var DeleteButton: UIButton!
    var reminderID: String?
    var databaseRef: DatabaseReference?
    weak var delegate: PatientReminderProgressTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    @IBAction func DeleteButtonClicked(_ sender: Any) {
        guard let reminderID = reminderID else {
                  return
              }
              
              // Delete the reminder from the database
              databaseRef?.child("reminders").child(reminderID).removeValue { error, _ in
                  if let error = error {
                      print("Error deleting reminder: \(error.localizedDescription)")
                  } else {
                      // Notify the delegate (if any) that a reminder has been deleted
                      // This allows the delegate (likely a view controller) to update its data source and refresh the table view
                      self.delegate?.reminderDeleted(reminderID: reminderID)
                  }
              }
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

