//
//  AppleMusicAPI.swift
//  MusicPlayer
//
//  Created by Sai Kambampati on 5/30/20.
//  Copyright © 2020 Sai Kambmapati. All rights reserved.
//

import Foundation
import StoreKit
import SwiftyJSON

class AppleMusicAPI {

    func getUserToken() -> String {
        var userToken = String()
        let lock = DispatchSemaphore(value: 0)
        SKCloudServiceController().requestUserToken(forDeveloperToken: developerToken) { (receivedToken, error) in
            guard error == nil else {
                return
            }
            if let token = receivedToken {
                userToken = token
                lock.signal()
            }
        }
        lock.wait()
        return userToken
    }
    
    func fetchAllSongs() -> [SongModel] {
        let lock = DispatchSemaphore(value: 0)
        var resultSongs: [SongModel] = []
        
        let musicURL = URL(string: "https://api.music.apple.com/v1/me/library/songs")!
        var musicRequest = URLRequest(url: musicURL)
        musicRequest.httpMethod = "GET"
        musicRequest.addValue("Bearer \(developerToken)", forHTTPHeaderField: "Authorization")
        musicRequest.addValue(getUserToken(), forHTTPHeaderField: "Music-User-Token")
        
        URLSession.shared.dataTask(with: musicRequest) { (data, response, error) in
            guard error == nil else { return }
            
            if let json = try? JSON(data: data!) {
                let results = (json["data"]).array!
                for result in results {
                    let id = result.dictionaryValue["id"]?.stringValue
                    let name = result.dictionaryValue["attributes"]?.dictionaryValue["name"]?.stringValue
                    resultSongs.append(SongModel(id: id ?? "",
                                            name: name ?? "",
                                            artistName: "",
                                            artworkURL: ""))
                }
                lock.signal()
            }
        }.resume()
        
        lock.wait()
        return resultSongs
    }
    
}
