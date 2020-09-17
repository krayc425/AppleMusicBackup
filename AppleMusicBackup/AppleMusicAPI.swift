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
    
    func checkPermissions() {
        let status = SKCloudServiceController.authorizationStatus()
        switch status {
        case .notDetermined:
            SKCloudServiceController.requestAuthorization { [weak self] (status) in
                self?.checkPermissions()
            }
        case .authorized:
            print("Authorized")
        default:
            print("Denied")
        }
    }
    
    func fetchAllSongs(_ handler: @escaping (([SongModel]) -> ())) {
        checkPermissions()
        var resultSongs: [SongModel] = []
        
        SKCloudServiceController().requestUserToken(forDeveloperToken: developerToken) { (receivedToken, error) in
            guard error == nil else {
                return
            }
            if let token = receivedToken {
                let userToken = token
                var musicURL: String? = "/v1/me/library/songs"
                let semaphore = DispatchSemaphore(value: 0)
                while let url = musicURL, !url.isEmpty {
                    print("Fetching \(url) \(resultSongs.count)")
                    var musicRequest = URLRequest(url: URL(string: "https://api.music.apple.com" + url)!)
                    musicRequest.httpMethod = "GET"
                    musicRequest.addValue("Bearer \(developerToken)", forHTTPHeaderField: "Authorization")
                    musicRequest.addValue(userToken, forHTTPHeaderField: "Music-User-Token")
                    URLSession.shared.dataTask(with: musicRequest) { (data, response, error) in
                        guard error == nil else {
                            semaphore.signal()
                            handler([])
                            return
                        }
                        if let data = data,
                           let json = try? JSON(data: data),
                           let results = (json["data"]).array {
                            for result in results {
                                let id = result.dictionaryValue["id"]?.stringValue
                                let attributes = result.dictionaryValue["attributes"]?.dictionaryValue
                                let name = attributes?["name"]?.stringValue
                                let artistName = attributes?["artistName"]?.stringValue
                                let artworkURL = attributes?["artwork"]?.dictionaryValue["url"]?.stringValue
                                resultSongs.append(SongModel(id: id ?? "",
                                                        name: name ?? "",
                                                        artistName: artistName ?? "",
                                                        artworkURL: artworkURL ?? ""))
                            }
                            musicURL = json["next"].stringValue
                        }
                        semaphore.signal()
                    }.resume()
                    semaphore.wait()
                }
                print("Done")
                handler(resultSongs)
            }
        }
    }
    
}
