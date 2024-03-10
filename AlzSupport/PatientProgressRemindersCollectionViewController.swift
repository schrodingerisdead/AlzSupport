//
//  PatientProgressRemindersCollectionViewController.swift
//  AlzSupport
//
//  Created by Magdalena Oreshkova on 2/21/24.
//

import UIKit

class PatientProgressRemindersCollectionViewController: UICollectionViewController {

    var reminders: [Reminder] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.register(UINib(nibName: "PatientProgressRemindersCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ReminderCell")
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return reminders.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ReminderCell", for: indexPath) as! PatientProgressRemindersCollectionViewCell
        
        let reminder = reminders[indexPath.item]
        cell.configure(with: reminder)
        
        cell.UnCheckedButton.addTarget(self, action: #selector(uncheckedButtonTapped(_:)), for: .touchUpInside)
        
        return cell
    }

    
    @objc func uncheckedButtonTapped(_ sender: UIButton) {
    
            guard let cell = sender.superview?.superview as? PatientProgressRemindersCollectionViewCell else {
                return
            }

            // Get the index path of the cell
            guard let indexPath = collectionView.indexPath(for: cell) else {
                return
            }

            // Get the corresponding reminder object
            let reminder = reminders[indexPath.item]

            // Update the reminder status
            reminders[indexPath.item].status = "finished" // Assuming "finished" indicates the reminder is completed

            // Update the UI to reflect the new status
            cell.UnCheckedButton.isHidden = true
            cell.CheckedButton.isHidden = false

            // Reload the collection view to reflect the changes
            collectionView.reloadData()
    }
}
