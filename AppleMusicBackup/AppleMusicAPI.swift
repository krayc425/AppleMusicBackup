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
import SVProgressHUD

class AppleMusicAPI {
    
    private static let baseURL = "https://api.music.apple.com"
    
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
    
    func addSongs(_ ids: [String]) {
        checkPermissions()
        DispatchQueue.global(qos: .userInitiated).async {
            SKCloudServiceController().requestUserToken(forDeveloperToken: developerToken) { (receivedToken, error) in
                guard error == nil else {
                    return
                }
                if let token = receivedToken {
                    for id in ids {
                        let playListURL = "https://api.music.apple.com/v1/me/library?ids[songs]=" + id
                        var request = URLRequest(url: URL(string: playListURL)!)
                        request.httpMethod = "POST"
                        request.addValue("Bearer \(developerToken)", forHTTPHeaderField: "Authorization")
                        request.addValue(token, forHTTPHeaderField: "Music-User-Token")
                        URLSession.shared.dataTask(with: request) { (data, response, error) in
                            print(response)
                            guard error == nil else {
                                return
                            }
                        }.resume()
                    }
                }
            }
        }
    }
    
    func fetchAllSongs(_ handler: @escaping (([SongModel]) -> ())) {
        checkPermissions()
        var resultSongs: [SongModel] = []
        SVProgressHUD.show(withStatus: "Fetching")
        DispatchQueue.global(qos: .userInitiated).async {
            SKCloudServiceController().requestUserToken(forDeveloperToken: developerToken) { (receivedToken, error) in
                guard error == nil else {
                    return
                }
                if let userToken = receivedToken {
                    var musicURL: String? = "/v1/me/library/songs"
                    let semaphore = DispatchSemaphore(value: 0)
                    while let url = musicURL, !url.isEmpty {
                        print("Fetching \(url) \(resultSongs.count)")
                        var musicRequest = URLRequest(url: URL(string: AppleMusicAPI.baseURL + url)!)
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
                    handler(resultSongs)
                }
            }
        }
    }
    
}
