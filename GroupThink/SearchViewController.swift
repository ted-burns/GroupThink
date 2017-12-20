//
//  ViewController.swift
//  GroupThink
//
//  Created by Teddy Burns on 11/22/17.
//  Copyright © 2017 Teddy Burns. All rights reserved.
//

import UIKit
import SafariServices
import Alamofire
import SwiftyJSON

class SearchViewController: UIViewController {
    
    @IBOutlet weak var searchField: UITextField!
    var tracks = [Spotify.Track]()
    var selectedTrack: Spotify.Track?
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.searchField.becomeFirstResponder()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        saveButton.isEnabled = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func searchButtonPressed(_ sender: Any) {
        self.searchField.resignFirstResponder()
        Spotify.instance.search(for: searchField.text!, completionHandler: { tracks in
            self.tracks = tracks
            self.tableView.reloadData()
        })
    }
    @IBAction func backButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension SearchViewController: Observer {
    func notify() {
        
    }
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tracks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TrackCell") as! TrackCell
       cell.setTrack(tracks[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        saveButton.isEnabled = true
        self.selectedTrack = self.tracks[indexPath.row]
    }
}



