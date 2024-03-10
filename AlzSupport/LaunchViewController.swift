//
//  LaunchViewController.swift
//  AlzSupport
//
//  Created by Magdalena Oreshkova on 3/6/24.
//

import UIKit

class LaunchScreenViewController: UIViewController {
    
    @IBOutlet weak var ImageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let logo1 = UIImage.gifImageWithName("logo1")
        ImageView.image = logo1
    }
    

    
}
