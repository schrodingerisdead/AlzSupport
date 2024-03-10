//
//  PatientInformationViewController.swift
//  AlzSupport
//
//  Created by Magdalena Oreshkova on 2/21/24.
//
import Foundation
import UIKit
import FirebaseDatabase
import FirebaseAuth


class PatientInformationViewController: UIViewController {

    @IBOutlet weak var Name: UITextField!
    @IBOutlet weak var Date: UITextField!
    @IBOutlet weak var Eat: UITextField!
    @IBOutlet weak var Feel: UITextField!
    @IBOutlet weak var Activity: UITextField!
    @IBOutlet weak var Age: UILabel!
    @IBOutlet weak var Day: UILabel!
    
    var ref: DatabaseReference!
       let dateFormatter: DateFormatter = {
           let formatter = DateFormatter()
           formatter.dateFormat = "dd MM yyyy"
           return formatter
       }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        fetchPatientInfo()
        setupDate()
    }
    
    func fetchPatientInfo() {
            guard let userID = Auth.auth().currentUser?.uid else {
                print("Error: Current user ID not found.")
                return
            }
            
            let patientRef = ref.child("users").child("patients").child(userID)
            patientRef.observeSingleEvent(of: .value) { [weak self] snapshot in
                guard let self = self, let patientData = snapshot.value as? [String: Any] else { return }
                
                if let name = patientData["name"] as? String {
                    self.Name.text = name
                }
                if let age = patientData["age"] as? Int {
                    self.Age.text = "\(age)"
                }
            }
        }
        
        func setupDate() {
            let currentDate = Foundation.Date()
            Date.text = dateFormatter.string(from: Foundation.Date())
            let dayFormatter = DateFormatter()
            dayFormatter.dateFormat = "EEEE"
            Day.text = dayFormatter.string(from: currentDate)
        }
        
    
    @IBAction func saveJournalEntry(_ sender: Any) {
        guard let patientID = Auth.auth().currentUser?.uid,
              let eat = Eat.text, !eat.isEmpty,
              let feel = Feel.text, !feel.isEmpty,
              let activity = Activity.text, !activity.isEmpty,
              let currentDate = Date.text else {
            showAlert(title: "Error", message: "Please fill in all fields.")
            return
        }
        
        ref.child("memories").child(patientID).child(currentDate).observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let self = self else { return }
            
            if snapshot.exists() {
                self.showAlert(title: "Error", message: "You already have an entry for this date.")
            } else {
                let journalEntry = [
                    "eat": eat,
                    "feel": feel,
                    "activity": activity
                ]
                
                self.ref.child("memories").child(patientID).child(currentDate).setValue(journalEntry) { (error, _) in
                    if let error = error {
                        self.showAlert(title: "Error", message: error.localizedDescription)
                    } else {
                        self.showAlert(title: "Success", message: "Journal entry saved successfully.")
                    }
                }
            }
        }
    }

    
    func showAlert(title: String, message: String) {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alertController, animated: true, completion: nil)
        }
    
    
}
