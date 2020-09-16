//
//  ViewController.swift
//  AppleMusicBackup
//
//  Created by Kuixi Song on 9/15/20.
//  Copyright © 2020 Kuixi Song. All rights reserved.
//

import UIKit
import StoreKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        SKCloudServiceController.requestAuthorization { (status) in
            if status == .authorized {
                print(AppleMusicAPI().fetchStorefrontID())
            }
        }
    }

    @IBAction func backupAction(_ sender: UIButton) {
        AppleMusicAPI().fetchAllSongs()
    }

}

