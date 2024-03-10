//
//  PatientLocationViewController.swift
//  AlzSupport
//
//  Created by Magdalena Oreshkova on 3/4/24.
//

import UIKit
import CoreLocation
import FirebaseDatabase
import FirebaseAuth
import MapKit

class PatientLocationViewController: UIViewController {

    @IBOutlet weak var LogOutButton: UIButton!
    @IBOutlet weak var Map: MKMapView!
    var ref: DatabaseReference!

      override func viewDidLoad() {
          super.viewDidLoad()

          ref = Database.database().reference()
          fetchPatientLocation()
      }
      
      func fetchPatientLocation() {
          ref.child("patients_location").child("ImMKeMiEkVZ8kjFGcApuu8lP9eT2").observeSingleEvent(of: .value) { snapshot in
              guard let locationData = snapshot.value as? [String: Double],
                    let latitude = locationData["latitude"],
                    let longitude = locationData["longitude"] else {
                  print("Error: Failed to retrieve patient's location from Firebase.")
                  return
              }
              
              let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
              let annotation = MKPointAnnotation()
              annotation.coordinate = coordinate
              annotation.title = "Patient Location"
              self.Map.addAnnotation(annotation)
              let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
              self.Map.setRegion(region, animated: true)
          }
      }
    //MARK: - Log Out the user
    @IBAction func LogOutButtonClicked(_ sender: Any) {
        do {
                try Auth.auth().signOut()
                if let loginVC = storyboard?.instantiateViewController(withIdentifier: "ViewController") as? ViewController {
                    loginVC.modalPresentationStyle = .fullScreen
                    present(loginVC, animated: true, completion: nil)
                }
            } catch let error as NSError {
                print("Error signing out: \(error.localizedDescription)")
            }
    }
    
}
