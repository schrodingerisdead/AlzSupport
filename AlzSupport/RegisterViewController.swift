
//  AlzSupport
//
//  Created by Magdalena Oreshkova on 2/20/24.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class RegisterViewController: UIViewController {
//The Family Members fields
    @IBOutlet weak var FamilyMemberName: UITextField!
    @IBOutlet weak var FamilyMemberEmail: UITextField!
    @IBOutlet weak var PatientEmail: UITextField!
    @IBOutlet weak var FamilyMemberPassword: UITextField!
    @IBOutlet weak var Register: UIButton!
    
    
    // The Patients fields
    @IBOutlet weak var PatientName: UITextField!
    @IBOutlet weak var PatientSEmail: UITextField!
    @IBOutlet weak var RelativeEmail: UITextField!
    @IBOutlet weak var Password: UITextField!
    @IBOutlet weak var SignUp: UIButton!
    @IBOutlet weak var Birthdate: UITextField!
    override func viewDidLoad() {
        
        super.viewDidLoad()

       
    }
    //sign up / register for family member
    @IBAction func RegisterClicked(_ sender: Any) {
        guard let email = FamilyMemberEmail.text, let password = FamilyMemberPassword.text else {
            return
        }
        
        // Create user with email and password
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                print("Error registering family member: \(error.localizedDescription)")
            } else {
                // Registration successful, save additional data in Realtime Database
                guard let uid = authResult?.user.uid else { return }
                let familyMemberData = [
                    "name": self.FamilyMemberName.text ?? "",
                    "email": self.FamilyMemberEmail.text ?? "",
                    "password": self.FamilyMemberPassword.text ?? "",
                    "patientEmail": self.PatientEmail.text ?? ""
                ]
                let ref = Database.database().reference().child("users").child("family_members").child(uid) // Change database reference
                ref.setValue(familyMemberData)
                
                print("Family member registered successfully")
            }
        }
    }
    
    // Register patient
    @IBAction func SignUpClicked(_ sender: Any) {
        guard let patientEmail = PatientSEmail.text, !patientEmail.isEmpty,
              let patientName = PatientName.text, !patientName.isEmpty,
              let password = Password.text, !password.isEmpty,
              let relativeEmail = RelativeEmail.text, !relativeEmail.isEmpty,
              let birthdateText = Birthdate.text, !birthdateText.isEmpty else {
            print("Missing required fields for patient registration")
            return
        }
        
        // Convert birthdate string to Date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        guard let birthdate = dateFormatter.date(from: birthdateText) else {
            print("Invalid birthdate format")
            return
        }
        
        // Calculate age
        let age = calculateAge(from: birthdate)
        
        // Register the patient
        Auth.auth().createUser(withEmail: patientEmail, password: password) { authResult, error in
            if let error = error {
                print("Error registering patient: \(error.localizedDescription)")
            } else {
                // Registration successful, save additional data in Realtime Database
                guard let uid = authResult?.user.uid else { return }
                let patientData: [String: Any] = [
                    "name": patientName,
                    "email": patientEmail,
                    "password": password,
                    "relativeEmail": relativeEmail,
                    "birthdate": birthdateText,
                    "age": age
                ]
                let ref = Database.database().reference().child("users").child("patients").child(uid) // Change database reference
                ref.setValue(patientData)
                
                print("Patient registered successfully")
            }
        }
    }

    // Function to calculate age from date of birth
    func calculateAge(from date: Date) -> Int {
        let calendar = Calendar.current
        let currentDate = Date()
        let ageComponents = calendar.dateComponents([.year], from: date, to: currentDate)
        guard let age = ageComponents.year else {
            print("Error: Unable to calculate age")
            return 0
        }
        return age
    }

}
