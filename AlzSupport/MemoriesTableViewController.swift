//
//  MemoriesTableViewController.swift
//  AlzSupport
//
//  Created by Magdalena Oreshkova on 3/6/24.
//


//Let me explain this other part of my app
//The user gets the dates for a certain user's entries
// and just displays the date in the cells of the MemoriesTableViewController
// when you click on that certain cell it's supposed to put all of the info for that certain date in a
//different ViewController that has Labels for eat, feel, activity
//Do i need to create a MemoriesTableViewCell
import UIKit
import FirebaseAuth
import FirebaseDatabase

class MemoriesTableViewController: UITableViewController {
    var dates: [String] = [] // Array to store dates
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchDates()
    }
    
    func fetchDates() {
        guard let patientID = Auth.auth().currentUser?.uid else {
                    print("Error: Current user ID not found.")
                    return
                }
                
                let memoriesRef = Database.database().reference().child("memories").child(patientID)
                
                memoriesRef.observeSingleEvent(of: .value) { [weak self] snapshot in
                    guard let self = self, let snapshots = snapshot.children.allObjects as? [DataSnapshot] else { return }
                    
                    for snap in snapshots {
                        self.dates.append(snap.key)
                    }
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dates.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MemoriesCell", for: indexPath) as! MemoriesTableViewCell
        let date = dates[indexPath.row]
        cell.dateLabel.text = date
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedDate = dates[indexPath.row]
        performSegue(withIdentifier: "ShowEntryDetail", sender: selectedDate)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowEntryDetail" {
            if let entryDetailVC = segue.destination as? EntryDetailViewController,
               let selectedDate = sender as? String {
               entryDetailVC.selectedDate = selectedDate
            }
        }
    }
}
