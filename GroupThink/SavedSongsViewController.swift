//
//  SavedSongs.swift
//  GroupThink
//
//  Created by Teddy Burns on 12/5/17.
//  Copyright © 2017 Teddy Burns. All rights reserved.
//

import UIKit

class SavedSongsViewController: UITableViewController {

    var tracks: [Spotify.Track]!
    
    @IBOutlet weak var editButton: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        if let data = UserDefaults.standard.value(forKey:"SavedTracks") as? Data {
            self.tracks = try? PropertyListDecoder().decode(Array<Spotify.Track>.self, from: data)
            if self.tracks == nil {
                self.tracks = [Spotify.Track]()
            }
        } else {
            self.tracks = [Spotify.Track]()
        }
        self.tableView.reloadData()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tracks.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TrackCell", for: indexPath) as! TrackCell
        cell.setTrack(tracks[indexPath.row])
        return cell
    }

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.tracks.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            self.saveTracks()
        }
    }



    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        let track = self.tracks.remove(at: fromIndexPath.row)
        self.tracks.insert(track, at: to.row)
        self.saveTracks()
    }
    

    

    
    // MARK: - Navigation
    
    @IBAction func unwindFromSearchWithSave(for segue: UIStoryboardSegue) {
        let source = segue.source as! SearchViewController
        self.tracks.append(source.selectedTrack!)
        self.tableView.reloadData()
        self.saveTracks()
    }
    
     @IBAction func editButtonPressed(_ sender: Any) {
        if self.tableView.isEditing {
            tableView.isEditing = false
            editButton.title = "Edit"
            
        } else {
            tableView.isEditing = true
            editButton.title = "Done"
        }
     }
    
    func saveTracks() {
        UserDefaults.standard.set(try? PropertyListEncoder().encode(self.tracks), forKey:"SavedTracks")
    }
    
    func loadTracks() -> [Spotify.Track]? {
        if let data = UserDefaults.standard.value(forKey:"SavedTracks") as? Data {
            let tracks = try? PropertyListDecoder().decode(Array<Spotify.Track>.self, from: data)
            return tracks
        }
        return nil
    }

    
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ViewTrackDetails" {
            let destination = segue.destination as! DetailViewController
            destination.track = self.tracks[self.tableView.indexPathForSelectedRow!.row]
        }
    }
    

}
