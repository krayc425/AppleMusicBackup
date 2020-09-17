//
//  SongTableViewController.swift
//  AppleMusicBackup
//
//  Created by Kuixi Song on 9/16/20.
//  Copyright © 2020 Kuixi Song. All rights reserved.
//

import UIKit
import StoreKit

class SongTableViewController: UITableViewController {

    var songs: [SongModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Apple Music Backup"
    }

    @IBAction func backupAction(_ sender: UIBarButtonItem) {
        SKCloudServiceController.requestAuthorization { [weak self] (status) in
            AppleMusicAPI().fetchAllSongs({ (models) in
                print(models.count)
                self?.songs = models
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            })
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SongTableViewCell.reuseId, for: indexPath) as? SongTableViewCell else {
            return UITableViewCell()
        }
        cell.config(songs[indexPath.row])
        return cell
    }

}
