

import UIKit
import FirebaseAuth
import FirebaseDatabase

class ViewController: UIViewController {

    @IBOutlet weak var Email: UITextField!
    @IBOutlet weak var Password: UITextField!
    @IBOutlet weak var LogInButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func LogInButtonPressed(_ sender: Any) {
        guard let email = Email.text, let password = Password.text else {
            return
        }
        
        // Sign in user with email and password
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            guard let strongSelf = self else { return }
            
            if let error = error {
                print("Error logging in: \(error.localizedDescription)")
                // Handle login error (e.g., display error message to user)
                return
            }
            
            // Login successful, retrieve user email
            let currentUser = Auth.auth().currentUser
            let userEmail = currentUser?.email ?? ""
            
            // Query the Firebase Realtime Database to check if the user exists in the "family_members" node
            let familyMembersRef = Database.database().reference().child("users").child("family_members")
            familyMembersRef.observeSingleEvent(of: .value) { familySnapshot in
                for familyMember in familySnapshot.children {
                    let familyData = familyMember as! DataSnapshot
                    let familyMemberData = familyData.value as! [String: Any]
                    let familyMemberEmail = familyMemberData["email"] as! String
                    
                    if email == familyMemberEmail {
                        // User found as a family member, navigate to family member dashboard or perform family member-specific actions
                        DispatchQueue.main.async {
                            strongSelf.performSegue(withIdentifier: "FamilyMemberHomeViewController", sender: nil)
                        }
                        return
                    }
                }
                
                // User not found in the "family_members" node, check if the user exists in the "patients" node
                let patientsRef = Database.database().reference().child("users").child("patients")
                patientsRef.observeSingleEvent(of: .value) { patientSnapshot in
                    for patient in patientSnapshot.children {
                        let patientData = patient as! DataSnapshot
                        let patientEmail = patientData.childSnapshot(forPath: "email").value as! String
                        
                        if email == patientEmail {
                            // User found as a patient, navigate to patient dashboard or perform patient-specific actions
                            DispatchQueue.main.async {
                                strongSelf.performSegue(withIdentifier: "PatientHomeViewController", sender: nil)
                            }
                            return
                        }
                    }
                    
                    // User not found in both "family_members" and "patients" nodes
                    print("User not found in the database")
                    // Handle accordingly (e.g., display error message to user)
                }
            }
        }
    }
}

