//
//  SongTableViewCell.swift
//  CodeTest
//
//  Created by Maple on 2024/2/19.
//

import UIKit

class SongTableViewCell: UITableViewCell {
    
    @IBOutlet weak var trackNameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    func configureSong(song: Song) {
        self.trackNameLabel.text = song.trackName
        self.artistNameLabel.text = song.artistName
        self.priceLabel.text = String(format: "Price:$%.2f", song.trackPrice ?? 0.0)
    }
}
