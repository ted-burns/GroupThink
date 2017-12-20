//
//  DetailViewController.swift
//  GroupThink
//
//  Created by Teddy Burns on 12/5/17.
//  Copyright © 2017 Teddy Burns. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    var track: Spotify.Track!
    var suggestedTracks: [Spotify.Track]!
    var allRelatedTracks = [Spotify.Track]()
    var numberOfRelatedArtists = 0
    var timesTracksAdded = 0
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var songNameLabel: UILabel!
    @IBOutlet weak var songArtistLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.suggestedTracks = [Spotify.Track]()
        
        self.songNameLabel.text = self.track.name
        self.songArtistLabel.text = self.track.getArtistsAsString()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        Spotify.instance.getRecommendations(for: self.track, completionHandler: { tracks in
            self.suggestedTracks = tracks
            self.tableView.reloadData()
        })
        
    }
    
    
    func addRelatedArtists(_ num: Int) {
        self.numberOfRelatedArtists += num
    }
    
    func analyzeRelatedTracks() {
        print("analyzing!")
    }
    
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func exportPressed(_ sender: UIButton) {
        Spotify.instance.addPlaylist(with: self.suggestedTracks, basedOn: self.track)
    }
    
}

extension DetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return suggestedTracks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TrackCell") as! TrackCell
        cell.setTrack(self.suggestedTracks[indexPath.row])
        return cell 
    }
    

}
