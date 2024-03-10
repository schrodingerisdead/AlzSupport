

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
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            guard let strongSelf = self else { return }
            
            if let error = error {
                print("Error logging in: \(error.localizedDescription)")
               
                return
            }
            
            let currentUser = Auth.auth().currentUser
            let userEmail = currentUser?.email ?? ""
            
            
            let familyMembersRef = Database.database().reference().child("users").child("family_members")
            familyMembersRef.observeSingleEvent(of: .value) { familySnapshot in
                for familyMember in familySnapshot.children {
                    let familyData = familyMember as! DataSnapshot
                    let familyMemberData = familyData.value as! [String: Any]
                    let familyMemberEmail = familyMemberData["email"] as! String
                    
                    if email == familyMemberEmail {
                        DispatchQueue.main.async {
                            strongSelf.performSegue(withIdentifier: "FamilyMemberHomeViewController", sender: nil)
                        }
                        return
                    }
                }
                
                
                let patientsRef = Database.database().reference().child("users").child("patients")
                patientsRef.observeSingleEvent(of: .value) { patientSnapshot in
                    for patient in patientSnapshot.children {
                        let patientData = patient as! DataSnapshot
                        let patientEmail = patientData.childSnapshot(forPath: "email").value as! String
                        
                        if email == patientEmail {
                            
                            DispatchQueue.main.async {
                                strongSelf.performSegue(withIdentifier: "PatientHomeViewController", sender: nil)
                            }
                            return
                        }
                    }
                    
                    print("User not found in the database")
                }
            }
        }
    }
}

