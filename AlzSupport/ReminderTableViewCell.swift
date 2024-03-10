//
//  ReminderTableViewCell.swift
//  AlzSupport
//
//  Created by Magdalena Oreshkova on 3/4/24.
//

import UIKit

protocol ReminderTableViewCellDelegate: AnyObject {
    func didTapRemoveButton(in cell: ReminderTableViewCell)
}

class ReminderTableViewCell: UITableViewCell {

    @IBOutlet weak var Reminder: UILabel!
    @IBOutlet weak var Status: UILabel!
    @IBOutlet weak var RemoveButton: UIButton!
    weak var delegate: ReminderTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func RemoveButtonClicked(_ sender: Any) {
        // when the remove button is clicked it's supposed to delete the reminder from the database
        delegate?.didTapRemoveButton(in: self)
        
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
