//
//  SongTableViewController.swift
//  AppleMusicBackup
//
//  Created by Kuixi Song on 9/16/20.
//  Copyright © 2020 Kuixi Song. All rights reserved.
//

import UIKit
import StoreKit
import SwiftyJSON
import SVProgressHUD

class SongTableViewController: UITableViewController {

    var songs: [SongModel] = []

    @IBAction func backupAction(_ sender: UIBarButtonItem) {
        SKCloudServiceController.requestAuthorization { [weak self] (status) in
            AppleMusicAPI().fetchAllSongs({ (models) in
                print(models.count)
                self?.songs = models
                DispatchQueue.main.async {
                    SVProgressHUD.show(withStatus: "Done")
                    SVProgressHUD.dismiss(withDelay: 2.0)
                    self?.tableView.reloadData()
                }
            })
        }
    }
    
    @IBAction func exportToJSONAction(_ sender: UIBarButtonItem) {
        let filePath = NSHomeDirectory() + "/Documents/all_song_ids.txt"
        var string = ""
        for song in songs {
            string.append(song.id)
            string.append("\n")
        }
        guard !string.isEmpty else {
            SVProgressHUD.show(withStatus: "No song")
            SVProgressHUD.dismiss(withDelay: 2.0)
            return
        }
        try! string.write(toFile: filePath, atomically: true, encoding: .utf8)
        let url = URL(fileURLWithPath: filePath)
        let activity = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        present(activity, animated: true)
    }
    
    @IBAction func importFromJSONAction(_ sender: UIBarButtonItem) {
        let documentsPicker = UIDocumentPickerViewController(documentTypes: ["public.plain-text"], in: .open)
        documentsPicker.delegate = self
        documentsPicker.allowsMultipleSelection = false
        documentsPicker.modalPresentationStyle = .automatic
        present(documentsPicker, animated: true)
    }
    
    private func selectFile(_ url: URL) {
        let string = try! String(contentsOf: url)
        let ids = string.split(separator: "\n").map { String($0) }
        print(ids)
        AppleMusicAPI().addSongs(ids)
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

extension SongTableViewController: UIDocumentPickerDelegate {
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        guard controller.documentPickerMode == .open,
            url.startAccessingSecurityScopedResource() else {
                SVProgressHUD.showError(withStatus: "没有结果")
                return
        }
        defer {
            DispatchQueue.main.async {
                url.stopAccessingSecurityScopedResource()
            }
        }
        controller.dismiss(animated: true)
        selectFile(url)
    }

    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true)
    }
    
}
