//  FamilyMemberHomeViewController.swift
//  AlzSupport
//
//  Created by Magdalena Oreshkova on 2/20/24.

import UIKit
import FirebaseAuth
import FirebaseDatabase

class FamilyMemberHomeViewController: UIViewController, UICollectionViewDelegate {
    
    @IBOutlet weak var LogOutButton: UIButton!
    @IBOutlet weak var Name: UILabel!
    @IBOutlet weak var reminderCollectionView: UICollectionView! // the ReuseIdentifier is Cell
    var reminders: [Reminder] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchAndDisplayUserName()
        fetchReminders()
        configureCollectionView()
    }
    
    //MARK: - Get the family member's name
    func fetchAndDisplayUserName() {
        // Retrieve the current user's ID from FirebaseAuth
        guard let userID = Auth.auth().currentUser?.uid else {
            print("Error: Current user ID not found.")
            return
        }
        
        // Get a reference to the current user's data in the Firebase Realtime Database
        let usersRef = Database.database().reference().child("users").child("family_members").child(userID)
        
        // Retrieve the user's data from the database
        usersRef.observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let self = self else { return }
            
            if let userData = snapshot.value as? [String: Any] {
                // Debug: Print snapshot data
                print("Snapshot Data: \(userData)")
                
                // Retrieve the user's name from the snapshot data
                if let name = userData["name"] as? String {
                    // Update the UI with the user's name on the main thread
                    DispatchQueue.main.async {
                        self.Name.text = name
                    }
                } else {
                    print("Error: Name not found in snapshot data.")
                }
            } else {
                print("Error: Invalid snapshot data.")
            }
        }
    }
    
    //MARK: - Log Out
    //there seem to be some issues with the log out can you please fix it
    
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
    // MARK: - Fetch reminders from the database
       func fetchReminders() {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
              print("Error: User not authenticated.")
              return
          }

          let remindersRef = Database.database().reference().child("reminders")

          // Fetch reminders for the current user
          remindersRef.queryOrdered(byChild: "createdBy").queryEqual(toValue: currentUserID).observeSingleEvent(of: .value) { [weak self] snapshot in
              guard let self = self else { return }

              guard let remindersData = snapshot.value as? [String: [String: Any]] else {
                  print("Error: Failed to parse reminders data.")
                  return
              }

              // Clear existing reminders
              self.reminders.removeAll()

              // Parse reminder data
              for (reminderID, reminderData) in remindersData {
                  if let text = reminderData["text"] as? String,
                     let status = reminderData["status"] as? String {
                      let reminder = Reminder(id: reminderID, text: text, status: status)
                      self.reminders.append(reminder)
                  }
              }

              // Reload the collection view on the main thread
              DispatchQueue.main.async {
                  self.reminderCollectionView.reloadData()
              }
          }
       }
    
    func configureCollectionView() {
            reminderCollectionView.dataSource = self
            reminderCollectionView.delegate = self
        }
        
}

extension FamilyMemberHomeViewController: UICollectionViewDelegateFlowLayout {
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


extension FamilyMemberHomeViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return reminders.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? ReminderCollectionViewCell else {
            fatalError("Unable to dequeue ReminderCollectionViewCell")
        }

        let reminder = reminders[indexPath.item]
        cell.configure(with: reminder)
        return cell
    }
}

