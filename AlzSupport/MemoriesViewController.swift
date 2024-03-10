//
//  MemoriesViewController.swift
//  AlzSupport
//
//  Created by Magdalena Oreshkova on 3/6/24.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class MemoriesViewController: UIViewController {
    
    @IBOutlet weak var memoriesTableView: UITableView!
    
    var dates: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        fetchDates()
    }
    
    @IBAction func LogOutClicked(_ sender: Any) {
        do {
                try Auth.auth().signOut()
                
                // Present the login view controller modally
                if let loginVC = storyboard?.instantiateViewController(withIdentifier: "ViewController") as? ViewController {
                    loginVC.modalPresentationStyle = .fullScreen
                    present(loginVC, animated: true, completion: nil)
                }
            } catch let error as NSError {
                print("Error signing out: \(error.localizedDescription)")
            }
    }
    func setupTableView() {
        memoriesTableView.delegate = self
        memoriesTableView.dataSource = self
        memoriesTableView.register(UITableViewCell.self, forCellReuseIdentifier: "MemoriesCell")
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
            
            self.memoriesTableView.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EntryDetailViewController" {
            if let entryDetailVC = segue.destination as? EntryDetailViewController,
               let selectedDate = sender as? String {
               entryDetailVC.selectedDate = selectedDate
            }
        }
    }
}

extension MemoriesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dates.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MemoriesCell", for: indexPath)
        let date = dates[indexPath.row]
        cell.textLabel?.text = date
        cell.backgroundColor = .yellow
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedDate = dates[indexPath.row]
        performSegue(withIdentifier: "EntryDetailViewController", sender: selectedDate)
    }
}

