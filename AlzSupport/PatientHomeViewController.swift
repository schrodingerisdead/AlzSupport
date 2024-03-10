//
//  PatientHomeViewController.swift
//  AlzSupport
//
//  Created by Magdalena Oreshkova on 2/20/24.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import CoreLocation

struct Quotes: Decodable {
    let quote: String
    let author: String
    let category: String
}

class PatientHomeViewController: UIViewController, UICollectionViewDelegate, PatientReminderCollectionViewCellDelegate  {
    
    var reminders: [Reminder] = []
    @IBOutlet weak var BoredButton: UIButton!
    @IBOutlet weak var Quote: UILabel!   
    @IBOutlet weak var remindersCollectionView: UICollectionView!
    @IBOutlet weak var BoredIdeas: UILabel!
    @IBOutlet weak var LogOutButton: UIButton!
    let apiKey = "LZe+01H832NcnTJO4VePeA==VgboHZB4C7rPoFKk"
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = true

        setupLocationManager()
        //fetchPatientName()
        fetchQuote(category: "inspirational")
        remindersCollectionView.dataSource = self
        remindersCollectionView.delegate = self
        fetchReminders()
    }
    
    // MARK: - Log Out
   
    @IBAction func LogOutButtonClicked(_ sender: Any) {
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
    // MARK: - Fetch Quote
    private func fetchQuote(category: String) {
        let category = category.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://api.api-ninjas.com/v1/quotes?category=\(category)"
        guard let url = URL(string: urlString) else {
            print("Error: Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "X-Api-Key")

        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }

            guard let data = data else {
                print("No data received: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            do {
                let quotes = try JSONDecoder().decode([Quotes].self, from: data)
                DispatchQueue.main.async {
                    if let quote = quotes.first {
                        self.Quote.text = quote.quote
                        self.Quote.numberOfLines = 0 // Allow multiple lines
                        self.Quote.lineBreakMode = .byWordWrapping // Word wrapping
                    }
                }
            } catch {
                print("Error decoding JSON: \(error.localizedDescription)")
            }
        }

        task.resume()
    }


    
    // MARK: - Fetch Reminders
    private func fetchReminders() {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            print("Error: User not authenticated.")
            return
        }

        let usersRef = Database.database().reference().child("users")

        // Search for the user's ID in the "patients" node
        usersRef.child("patients").child(currentUserID).observeSingleEvent(of: .value) { [weak self] patientSnapshot in
            guard let self = self else { return }
            
            guard let patientData = patientSnapshot.value as? [String: Any],
                  let relativeEmail = patientData["relativeEmail"] as? String else {
                print("Error: Failed to parse patient data or relative email not found.")
                return
            }

            print("Patient Snapshot:")
            print(patientData)
            
            // Now, fetch the family member ID using the relative's email
            self.findFamilyMemberID(for: relativeEmail)
        }
    }

    private func findFamilyMemberID(for email: String) {
        let familyMembersRef = Database.database().reference().child("users").child("family_members")

        familyMembersRef.observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let self = self else { return }
            
            guard let familyMembersData = snapshot.value as? [String: [String: Any]] else {
                print("Error: Family members data not found.")
                return
            }
            
            print("Family Members Snapshot:")
            print(familyMembersData)
            
            for (familyMemberID, familyMemberData) in familyMembersData {
                if let memberEmail = familyMemberData["email"] as? String, memberEmail == email {
                    // Found the family member corresponding to the relative email
                    self.fetchFamilyMemberReminders(for: familyMemberID)
                    return
                }
            }
            print("Error: Family member not found for relative email \(email).")
        }
    }

    private func fetchFamilyMemberReminders(for familyMemberID: String) {
        let remindersRef = Database.database().reference().child("reminders")

        remindersRef.observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let self = self else { return }

            if !snapshot.exists() {
                print("No reminders data found.")
                return
            }

            guard let remindersData = snapshot.value as? [String: [String: Any]] else {
                print("Error: Failed to parse reminders data.")
                return
            }

            print("Reminders Data:")
            print(remindersData)

            // Filter reminders based on the family member ID and status
            self.reminders = remindersData.compactMap { (key, value) in
                guard let createdBy = value["createdBy"] as? String, createdBy == familyMemberID,
                      let text = value["text"] as? String,
                      let status = value["status"] as? String,
                      status == "unfinished" else {
                    return nil
                }

                let reminder = Reminder(
                    id: key, // Assuming the ID is the key
                    text: text,
                    status: status
                )

                return reminder
            }

            // Debug print the reminders array
            print("Reminders Count: \(self.reminders.count)")
            print("Reminders: \(self.reminders)")

            // Reload the collection view on the main thread
            DispatchQueue.main.async {
                self.remindersCollectionView.reloadData()
            }
        }
    }


    
    // MARK: - Bored Button Action
    @IBAction func BoredClicked(_ sender: Any) {
        let url = URL(string: "https://www.boredapi.com/api/activity")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            guard let data = data else {
                print("No data received: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            do {
                let result = try JSONDecoder().decode(BoredAPIResponse.self, from: data)
                DispatchQueue.main.async {
                    self.BoredIdeas.text = result.activity
                }
            } catch {
                print("Error decoding JSON: \(error.localizedDescription)")
            }
        }
        
        task.resume()
    }
    
    // MARK: - Location Manager Setup
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    // MARK: - Fetch Patient Name
    /*
    func fetchPatientName() {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("Error: Current user ID not found.")
            return
        }
        
        let patientsRef = Database.database().reference().child("users").child("patients").child(userID)
        
        patientsRef.observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let self = self else { return }
            
            if let userData = snapshot.value as? [String: Any] {
                // Debug: Print snapshot data
                print("Snapshot Data: \(userData)")
                
                if let name = userData["name"] as? String {
                    // Update UI on the main thread
                    DispatchQueue.main.async {
                        self.PatientName.text = name
                    }
                } else {
                    print("Error: Name not found in snapshot data.")
                }
            } else {
                print("Error: Invalid snapshot data.")
            }
        }
    }
*/
    func reminderStatusDidChange(for cell: PatientReminderCollectionViewCell, with reminder: Reminder) {
        guard let indexPath = remindersCollectionView.indexPath(for: cell) else {
            return
        }

        // Update the status of the reminder in the reminders array
        reminders[indexPath.item].status = reminder.status

        // Get the unique identifier of the reminder (assuming it's called 'id')
        let reminderId = reminders[indexPath.item].id

        // Update the reminder status in the database
        updateReminderStatusInDatabase(reminderId: reminderId, newStatus: reminder.status) { [weak self] success in
            guard let self = self else { return }
            if success {
                // Remove the reminder from the array
                self.reminders.remove(at: indexPath.item)

                // Delete the corresponding cell from the collection view
                self.remindersCollectionView.deleteItems(at: [indexPath])
            }
        }
    }

    func updateReminderStatusInDatabase(reminderId: String, newStatus: String, completion: @escaping (Bool) -> Void) {
        // Assuming you have a reference to your reminders node in the database
        let remindersRef = Database.database().reference().child("reminders").child(reminderId)

        // Update the status of the reminder in the database
        remindersRef.child("status").setValue(newStatus) { error, _ in
            if let error = error {
                print("Error updating reminder status in database: \(error.localizedDescription)")
                completion(false)
            } else {
                print("Reminder status updated successfully in database.")
                completion(true)
            }
        }
    }



}

// MARK: - CLLocationManagerDelegate
extension PatientHomeViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        updatePatientLocation(location)
    }
    
    func updatePatientLocation(_ location: CLLocation) {
        guard let userID = Auth.auth().currentUser?.uid else {
            return
        }
        
        let locationData: [String: Any] = [
            "latitude": location.coordinate.latitude,
            "longitude": location.coordinate.longitude
        ]
        
        Database.database().reference().child("patients_location").child(userID).setValue(locationData)
    }
}
// MARK: - UICollectionViewDelegateFlowLayout
extension PatientHomeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionViewWidth = collectionView.bounds.width
        let spacing: CGFloat = 10 // Adjust the spacing between cells as needed
        let cellWidth = (collectionViewWidth - spacing) / 2 // Divide by the number of cells per row
        
        // Make the cell size square
        return CGSize(width: cellWidth, height: cellWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10 // Adjust the spacing between cells horizontally as needed
    }
}



// MARK: - UICollectionViewDataSource
extension PatientHomeViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return reminders.count
    }
    
    // Inside collectionView(_:cellForItemAt:) method
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
           print("collectionView(_:cellForItemAt:) method called")

           let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! PatientReminderCollectionViewCell
           cell.delegate = self // Set the delegate
           let reminder = reminders[indexPath.item]
           cell.configure(with: reminder)

           return cell
       }
    

}
