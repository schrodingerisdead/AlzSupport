//
//  PatientReminderProgressTableViewController.swift
//  AlzSupport
//
//  Created by Magdalena Oreshkova on 2/21/24.
//

import UIKit

class PatientReminderProgressTableViewController: UITableViewController {
    
    // Assuming you have an array of reminders
    var reminders: [Reminder] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Load reminders from the database or any other source
        loadReminders()
    }
    
    // Function to load reminders from the database
    func loadReminders() {
        // Code to fetch reminders from the database and populate the 'reminders' array
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reminders.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReminderCell", for: indexPath) as! PatientReminderProgressTableViewCell
        
        let reminder = reminders[indexPath.row]
        cell.TheReminder.text = reminder.text
        
        // Configure the cell with other properties
        
        return cell
    }

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Remove the reminder from the data source
            reminders.remove(at: indexPath.row)
            // Delete the row from the table view
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}

