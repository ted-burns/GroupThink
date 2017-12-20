//
//  Spotify.swift
//  GroupThink
//
//  Created by Teddy Burns on 11/22/17.
//  Copyright © 2017 Teddy Burns. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

import UIKit

class Spotify {
    
    //MARK:- Class Variables
    
    private static let clientID =  "ed902186bd374baa998c4bafd9ed6e30" //valueForAPIKey(named: "SPOTIFY-CLIENT-ID")
    private static let secretKey = "f61f22154ddc474f8ee53e1c7b187732" //valueForAPIKey(named: "SPOTIFY-SECRET")
    
    private static let apiUrlPrefix = "https://api.spotify.com"
    private static let version = "v1"
    
    static let instance = Spotify()

    
    
    private init() {
        if let authToken = UserDefaults.standard.string(forKey: "AuthToken") {
            self.authToken = authToken
            self.getAccessToken()
            self.notifyObservers()
        } else {
            return
        }
    }
    
    
    //MARK: Instance Variables
    
    private var accessToken: AccessToken?
    private var authToken: String?

    private var observers = [Observer]()
    
    //MARK:-
    
    private enum Scope: String {
        case readPrivatePlaylists = "playlist-read-private"
        case readCollaborativePlaylists = "playlist-read-collaborative"
        case writePublicPlaylists = "playlist-modify-public"
        case writePrivatePlaylists = "playlist-modify-private"
        case readUserLibrary = "user-library-read"
        case writeUserLibrary = "user-library-modify"
        case readBirthDate = "user-read-birthdate"
        case readEmail = "user-read-email"
        case readUserPlaybackState = "user-read-playback-state"
        case writeUserPlaybackState = "user-modify-playback-state"
    }
    
    
    //MARK: Related variables
    private let requestedScopes: [Spotify.Scope] = [
        .readUserPlaybackState,
        .writeUserPlaybackState,
        .readUserLibrary,
        .readPrivatePlaylists,
        .writePrivatePlaylists,
    ]
    
    
    //MARK: Related functions
    private func createAuthURL(with scopes:[Spotify.Scope]) -> String {
        let scopeString = scopes.map({$0.rawValue}).joined(separator: "%20")
        let parameters = [
            "response_type=code",
            "client_id=\(Spotify.clientID)",
            "scope=\(scopeString)",
            "redirect_uri=\(Spotify.URIs.redirectUri.rawValue)"
        ]
        return Spotify.URIs.auth.authorization.rawValue + "?" + parameters.joined(separator: "&")
    }
    
    
    //MARK:- URLs and Endpoints
    
    private enum URIs: String {
        enum auth: String {
            case authorization = "https://accounts.spotify.com/authorize"
            case accessToken = "https://accounts.spotify.com/api/token"
        }
        case redirectUri = "GroupThink://redirectAfterLogin"
    }
    
    private enum Endpoint {
        case album
        case albums
        case albumTracks
        case artist
        case artists
        case artistTopTracks
        case artistAlbums
        case artistRelatedArtists
        case browseFeaturedPlaylists
        case browseNewReleases
        case browseCategories
        case browseCategory
        case browseCategoryPlaylists
        case currentUserProfile
        case currentUserFollowing
        case currentUserTracks
        case currentUserCheckIfTrackSaved
        case currentUserAlbums
        case currentUserCheckIfAlbumSaved
        case currentUserTopArtists
        case currentUserTopTracks
        case currentUserPlaylists
        case currentUserPlayer
        case currentUserDevices
        case currentlyPlaying
        case otherUserProfile
        case otherUserPlaylists
        case otherUserPlaylist
        case otherUserPlalistTracks
        case searchAlbums
        case searchArtists
        case searchPlaylists
        case searchTracks
        case getTrack
        case getTracks
        case search
        case recommendations
        
        func url(id: String?) -> String{
            
            switch self {
            case .currentUserPlayer: return Spotify.apiUrlPrefix + "/" + Spotify.version + "/" + "me/player"
            case .search: return Spotify.apiUrlPrefix + "/" + Spotify.version + "/" + "search"
            case .artistRelatedArtists: return "\(Spotify.apiUrlPrefix)/\(Spotify.version)/artists/\(id!)/related-artists"
            case .artistTopTracks: return "\(Spotify.apiUrlPrefix)/\(Spotify.version)/artists/\(id!)/top-tracks?country=US"
            case .recommendations: return "\(Spotify.apiUrlPrefix)/\(Spotify.version)/recommendations"
            case .currentUserProfile: return "\(Spotify.apiUrlPrefix)/\(Spotify.version)/me"
            default: return ""
            }
            
        }
    }
    
    
    //MARK:-
    
    private struct AccessToken {
        
        //MARK: Class variables
        
         static let authHeaders: HTTPHeaders = [
            "Authorization": "Basic \(Spotify.clientID):\(Spotify.secretKey)"
        ]
        
        
        //MARK: Instance variables
        let accessToken: String
        let tokenType: String
        let expiryTime: Date
        let refreshToken: String
        
        //MARK: Functions
        
        private init(accessToken: String, tokenType: String, expiryInterval: TimeInterval, refreshToken: String) {
            self.accessToken = accessToken
            self.tokenType = tokenType
            self.refreshToken = refreshToken
            self.expiryTime = Date(timeIntervalSinceNow: expiryInterval)
        }
    
        static func createNewToken(authToken: String, _ completed: @escaping (Spotify.AccessToken) -> () ){
            let parameters: Parameters = [
                "grant_type": "authorization_code",
                "code": authToken,
                "redirect_uri": Spotify.URIs.redirectUri.rawValue,
                "client_id": Spotify.clientID,
                "client_secret": Spotify.secretKey
            ]
            Alamofire.request(
                Spotify.URIs.auth.accessToken.rawValue,
                method: .post,
                parameters: parameters
            ).responseJSON { response in
                let json = JSON(response.result.value!)
//                print(json)
                completed(
                    Spotify.AccessToken(
                        accessToken: json["access_token"].stringValue,
                        tokenType: json["toke_type"].stringValue,
                        expiryInterval: json["expires_in"].doubleValue,
                        refreshToken: json["refresh_token"].stringValue
                    )
                )
            }
        }
        
        func refresh(_ completed: @escaping (Spotify.AccessToken) -> ()) {
            let parameters: Parameters = [
                "grant_type": "refresh_token",
                "code": self.refreshToken,
            ]
            Alamofire.request(
                Spotify.URIs.auth.accessToken.rawValue,
                method: .put,
                parameters: parameters,
                headers: Spotify.AccessToken.authHeaders
            ).responseJSON { response in
                let json = JSON(response)
                completed(
                    Spotify.AccessToken(
                        accessToken: json["access_token"].stringValue,
                        tokenType: json["toke_type"].stringValue,
                        expiryInterval: json["expires_in"].doubleValue,
                        refreshToken: json["refresh_token"].stringValue
                    )
                )
            }
        }
        
        func isValid() -> Bool {
            return self.accessToken != "" && self.expiryTime.compare(Date(timeIntervalSinceNow: 0)).rawValue > 0
        }
    }
    
    //MARK:-
    
    struct Artist: Codable {
        let name:String
        let href: String
        let URI: String
        let id: String
        
        init(name: String, href: String, URI: String, id: String) {
            self.name = name
            self.href = href
            self.URI = URI
            self.id = id
        }
        
        static func fromJSON(json: JSON) -> Artist {
            return Artist(
                name: json["name"].stringValue,
                href:  json["href"].stringValue,
                URI: json["uri"].stringValue,
                id: json["id"].stringValue
            )
        }
    }
    
    struct Track: Codable {
        let artists: [Spotify.Artist]
        let name: String
        let id: String
        let uri: String
        
        init(name: String, id: String, artists: [Artist], uri: String) {
            self.name = name
            self.id = id
            self.artists = artists
            self.uri = uri
        }
        
        static func fromJSON(json: JSON) -> Track {
            var artists = [Artist]()
            for artist in json["artists"].arrayValue {
                artists.append(Artist.fromJSON(json: artist))
            }
            return Track(name: json["name"].stringValue, id: json["id"].stringValue, artists: artists, uri: json["uri"].stringValue)
        }
        
        
        func getArtistsAsString() -> String {
            var artists = ""
            for artist in self.artists {
                if artist.name != self.artists.first!.name {
                    artists += ", "
                }
                artists += artist.name
            }
            return artists
        }
    }
    
    
    
    //MARK:- Login functions
    
    func isAuthenticated() -> Bool {
        return self.accessToken != nil
    }
    
    func openLogin() {
        if let url = URL(string: createAuthURL(with: self.requestedScopes)) {
            UIApplication.shared.open(url)
        }
    }
    
    func handleCallback(_ callbackURL: URL) {
        let url = callbackURL.absoluteString
        if url.contains("="){
            self.authToken = url.components(separatedBy: "=")[1]
            if self.authToken!.contains("#") {
                self.authToken = self.authToken!.components(separatedBy: "#")[0]
            }
            UserDefaults.standard.set(self.authToken!, forKey: "AuthToken")
            self.getAccessToken()
        } else {
            print(url)
        }
    }
    private func getAccessToken() {
        guard let authToken = self.authToken else { return }
        Spotify.AccessToken.createNewToken(authToken: authToken) { accessToken in
            self.accessToken = accessToken
            if accessToken.isValid() {
                self.notifyObservers()
            }
            else {
                self.openLogin()
            }
        }
    }
    
    private func refreshAccessToken() {
        if let accessToken = self.accessToken {
            accessToken.refresh() { accessToken in
                self.accessToken = accessToken
            }
        }
    }
    
    private func callAPI(url: String, parameters: Parameters, completionHandler: @escaping (JSON) -> Void) {
        guard let accessToken = self.accessToken?.accessToken else {return}
        let headers: HTTPHeaders = ["Authorization": "Bearer \(accessToken)"]
        Alamofire.request(url, parameters: parameters, headers: headers
            ).responseJSON { response in
                guard let value = response.result.value else { return }
                completionHandler(JSON(value))
                self.notifyObservers()
        }
    }
    private func callAPI(url: String, parameters: Parameters, additionalHeaders: HTTPHeaders?, completionHandler: @escaping (JSON) -> Void) {
        guard let accessToken = self.accessToken?.accessToken else {return}
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(accessToken)",
            "Content-Type": "application/json"
        ]
        Alamofire.request(url, method: .post, parameters: parameters, headers: headers
            ).responseJSON { response in
                guard let value = response.result.value else { return }
                completionHandler(JSON(value))
                self.notifyObservers()
        }
    }
    
    private func callAPI(url: String, completionHandler: @escaping (JSON) -> Void) {
        guard let accessToken = self.accessToken?.accessToken else {return}
        let headers: HTTPHeaders = ["Authorization": "Bearer \(accessToken)"]
        Alamofire.request(url,headers: headers).responseJSON { response in
            print(response)
            guard let value = response.result.value else { return }
            completionHandler(JSON(value))
            self.notifyObservers()
        }
    }

    //MARK:- Currently Playing Information
    
    func getCurrentlyPlayingInformation(notifyWhenDone observer: Observer) {
        callAPI(url: Endpoint.currentUserPlayer.url(id: nil), completionHandler: { response in
            print(response)
            observer.notify()
        })
    }
    
    func search(for string: String,completionHandler completed: @escaping ([Spotify.Track]) -> ()) {
        callAPI(url: Endpoint.search.url(id: nil), parameters: ["q":string.replacingOccurrences(of: " ", with: "+"),"type":"track"] as Parameters, completionHandler: { json in
            var tracks = [Track]()
            for item in json["tracks"]["items"].arrayValue {
                tracks.append(Track.fromJSON(json: item))
            }
            completed(tracks)
        })
    }
    
    func getRelatedTracks(for track: Spotify.Track, completionHandler completed: @escaping ([Spotify.Track]) -> (), sender: DetailViewController){
        for artist in track.artists {
            callAPI(url: Endpoint.artistRelatedArtists.url(id: artist.id), completionHandler: { json in
                let artistArray = json["artists"].arrayValue
                sender.addRelatedArtists(artistArray.count)
                for artistJson in artistArray {
                    let artist = Spotify.Artist.fromJSON(json: artistJson)
                    self.getArtistTopSongs(for: artist, completionHandler: { tracks in
                       completed(tracks)
                    })
                }

                
            })
        }
        
        
        
    }
    
    func getArtistTopSongs(for artist: Spotify.Artist, completionHandler completed: @escaping ([Spotify.Track]) -> ()) {
        callAPI(url: Endpoint.artistTopTracks.url(id: artist.id), completionHandler: {json in
            var tracks = [Spotify.Track]()
            for track in json["tracks"].arrayValue {
                tracks.append(Track.fromJSON(json: track))
            }
            completed(tracks)
        })
        
    }
    
    func getRecommendations(for track: Spotify.Track, completionHandler completed: @escaping ([Spotify.Track]) -> ()) {
        let parameters: Parameters = [
            "seed_tracks": track.id,
            "market": "US"
        ]
        callAPI(url: Endpoint.recommendations.url(id: nil), parameters: parameters, completionHandler: {json in
            let tracks = json["tracks"].arrayValue.map({ Spotify.Track.fromJSON(json: $0)})
            completed(tracks)
        })
    }
    
    func addPlaylist(with tracks: [Spotify.Track], basedOn track: Spotify.Track) {
        callAPI(url: Endpoint.currentUserProfile.url(id: nil), completionHandler: {json in
            let userId = json["id"]
            let uris = tracks.map({$0.uri})
            var uri = ""
            for i in uris {
                if i != uris.first! {
                    uri += ","
                }
                uri += i
            }
            let parameters: Parameters = [
                "uris": uri
            ]
            self.callAPI(url: "https://api.spotify.com/v1/users/\(userId)/playlists", parameters: parameters, additionalHeaders: nil, completionHandler: { json in
                let playlistID = json["id"]
                let parameters: Parameters = [
                    "name": "Playlist based on \(track.name) by \(track.artists[0].name)"
                ]
                self.callAPI(url: "https://api.spotify.com/v1/users/\(userId)/playlists/\(playlistID)/tracks", parameters: parameters, additionalHeaders: nil, completionHandler: { json in
                    
                })
            })
        })
        
    }

    
    //MARK:- Observer Pattern Methods
    
    func addObserver(_ observer: Observer) {
        self.observers.append(observer)
    }
    
    func notifyObservers() {
        for observer in self.observers {
            observer.notify()
        }
    }
    
    
}
