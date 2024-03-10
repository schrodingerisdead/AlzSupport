//
//  EntryDetailViewController.swift
//  Pods
//
//  Created by Magdalena Oreshkova on 3/6/24.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class EntryDetailViewController: UIViewController {

    var selectedDate: String?
    @IBOutlet weak var eatLabel: UILabel!
    @IBOutlet weak var feelLabel: UILabel!
    @IBOutlet weak var activityLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchEntryDetails()
    }
    
    func fetchEntryDetails() {
        guard let patientID = Auth.auth().currentUser?.uid,
              let selectedDate = selectedDate else {
            return
        }
        
        let ref = Database.database().reference().child("memories").child(patientID).child(selectedDate)
        
        ref.observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let self = self, snapshot.exists() else {
                // Handle case where no entry exists for the selected date
                print("No entry found for selected date.")
                return
            }
            
            if let entryData = snapshot.value as? [String: Any] {
                if let eat = entryData["eat"] as? String {
                    self.eatLabel.text = eat
                }
                if let feel = entryData["feel"] as? String {
                    self.feelLabel.text = feel
                }
                if let activity = entryData["activity"] as? String {
                    self.activityLabel.text = activity
                }
            } else {
                // Handle case where entry data is invalid
                print("Invalid entry data format.")
            }
        }
    }

    @IBAction func LogOutButtonClicked(_ sender: Any) {
        //log out the user
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
}
