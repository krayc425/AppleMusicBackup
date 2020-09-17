//
//  SongTableViewCell.swift
//  AppleMusicBackup
//
//  Created by Kuixi Song on 9/16/20.
//  Copyright © 2020 Kuixi Song. All rights reserved.
//

import UIKit
import Kingfisher

class SongTableViewCell: UITableViewCell {
    
    static let reuseId = "SongCellId"
    
    @IBOutlet weak var albumImageView: UIImageView?
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var artistLabel: UILabel?

    func config(_ song: SongModel) {
        titleLabel?.text = song.name
        artistLabel?.text = song.artistName
        if !song.artworkURL.isEmpty {
            let replacedString = song.artworkURL.replacingOccurrences(of: "{w}", with: "50").replacingOccurrences(of: "{h}", with: "50")
            if let url = URL(string: replacedString) {
                albumImageView?.kf.setImage(with: url)
            }
        }
    }

}
