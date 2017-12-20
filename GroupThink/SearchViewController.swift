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
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.searchField.becomeFirstResponder()
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func apiButtonPressed(_ sender: UIButton) {
        Spotify.instance.getCurrentlyPlayingInformation(notifyWhenDone: self)
//        Alamofire.request("https://api.spotify.com/v1/search?type=track&q=more+than+you+know").response { response in
//            print(response)
//        }
    }
    
    @IBAction func clearButtonPressed(_ sender: UIButton) {
        KeychainWrapper.standard.removeObject(forKey: "AuthToken")
    }
    
    @IBAction func searchButtonPressed(_ sender: Any) {
        self.searchField.resignFirstResponder()
        Spotify.instance.search(for: searchField.text!, completionHandler: { tracks in
            self.tracks = tracks
            self.tableView.reloadData()
            
        })
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
}



