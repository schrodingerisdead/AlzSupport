//
//  AddReminderViewController.swift
//  AlzSupport
//
//  Created by Magdalena Oreshkova on 2/21/24.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase


class AddReminderViewController: UIViewController {

    @IBOutlet weak var reminder: UITextField!
    @IBOutlet weak var AddReminder: UIButton!
    @IBOutlet weak var reminderTableView: UITableView!
    var ref: DatabaseReference!
    var reminders: [Reminder] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        setupTableView()
        fetchReminders()
    }
    
    func setupTableView() {
           reminderTableView.dataSource = self
           reminderTableView.delegate = self
       }
    
    func fetchReminders() {

        self.reminders.removeAll()
        
        ref.child("reminders").observe(.value) { snapshot in
            guard let snapshotValue = snapshot.value as? [String: Any] else {
                print("No reminders data found.")
                return
            }
            
            for (reminderID, reminderData) in snapshotValue {
                guard let reminderInfo = reminderData as? [String: Any],
                      let text = reminderInfo["text"] as? String,
                      let status = reminderInfo["status"] as? String else {
                    print("Error: Failed to parse reminder data for ID \(reminderID).")
                    continue
                }
                
                // Assuming you have a Reminder struct
                let reminder = Reminder(id: reminderID, text: text, status: status)
                self.reminders.append(reminder)
            }
            
            DispatchQueue.main.async {
                self.reminderTableView.reloadData()
            }
        }
    }



    @IBAction func AddReminderClicked(_ sender: Any) {
        guard let reminderText = reminder.text, !reminderText.isEmpty else {
                showAlert(withTitle: "Error", message: "Please enter a reminder")
                return
            }
            
            guard let currentUserID = Auth.auth().currentUser?.uid else {
                showAlert(withTitle: "Error", message: "User ID not available")
                return
            }

            let reminderID = ref.child("reminders").childByAutoId().key ?? "default"
            
            let reminderData: [String: Any] = [
                "text": reminderText,
                "createdBy": currentUserID,
                "status": "unfinished" // Default status when adding the reminder
            ]
            
            // Save the reminder data to the database under the 'reminders' node
            ref.child("reminders").child(reminderID).setValue(reminderData) { (error, ref) in
                if let error = error {
                    // Show an alert if there's an error while saving the reminder
                    self.showAlert(withTitle: "Error", message: error.localizedDescription)
                } else {
                    // Show a success message if the reminder is successfully saved
                    self.showAlert(withTitle: "Success", message: "Reminder added successfully")
                    
                    // Clear the text field after adding the reminder
                    self.reminder.text = ""
                    
                    // Fetch updated reminders from the database
                    self.fetchReminders()
                }
            }
        }
            
            // Helper method to show an alert with the given title and message
            func showAlert(withTitle title: String, message: String) {
                let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(okAction)
                present(alertController, animated: true, completion: nil)
            }
}

extension AddReminderViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Number of reminders: \(reminders.count)")
        return reminders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("Configuring cell for row: \(indexPath.row)")
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ReminderTableViewCell", for: indexPath) as? ReminderTableViewCell else {
            fatalError("Unable to dequeue ReminderTableViewCell")
        }
        cell.delegate = self
        let reminder = reminders[indexPath.row]
        cell.Reminder.text = reminder.text
        cell.Status.text = reminder.status
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let reminderToRemove = reminders[indexPath.row]
            let reminderID = reminderToRemove.id // Assuming Reminder struct has an 'id' property
            ref.child("reminders").child(reminderID).removeValue { (error, _) in
                if let error = error {
                    self.showAlert(withTitle: "Error", message: error.localizedDescription)
                } else {
                    self.reminders.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                    self.reminderTableView.reloadData()
                }
            }
        }
    }
}

extension AddReminderViewController: ReminderTableViewCellDelegate {
    func didTapRemoveButton(in cell: ReminderTableViewCell) {
        guard let indexPath = reminderTableView.indexPath(for: cell) else { return }
        
        let removedReminder = reminders[indexPath.row]
        
        ref.child("reminders").child(removedReminder.id).removeValue { [weak self] (error, _) in
            if let error = error {
                self?.showAlert(withTitle: "Error", message: error.localizedDescription)
            } else {
                // Remove from local array
                self?.reminders.remove(at: indexPath.row)
                
                // Fetch reminders again to update the local array
                self?.fetchReminders()
                
                self?.showAlert(withTitle: "Success", message: "Reminder removed successfully")
            }
        }
    }
}





