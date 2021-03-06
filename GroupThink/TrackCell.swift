//
//  TrackCell.swift
//  GroupThink
//
//  Created by Teddy Burns on 12/5/17.
//  Copyright © 2017 Teddy Burns. All rights reserved.
//

import UIKit

class TrackCell: UITableViewCell {

    @IBOutlet weak var trackLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    
    private var track: Spotify.Track?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setTrack(_ track: Spotify.Track) {
        self.track = track
        trackLabel.text = track.name
        artistLabel.text = track.getArtistsAsString()
    }

}


