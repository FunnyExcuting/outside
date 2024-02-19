//
//  ViewModel.swift
//  CodeTest
//
//  Created by Maple on 2024/2/19.
//

import Foundation
import Combine

enum SortType: Int {
    case off = 1, price = 2
}


class ViewModel {
    
    //排序类型 1: off  2: price
    @Published var sortType = 1
    @Published var songList: [Song] = []
    @Published var displaySongList: [Song] = []
    
    var cancellables = Set<AnyCancellable>()
    
    init() {
        initialize()
    }
    
    fileprivate func initialize() {
        
    }
    
    func requestSongs(songName: String, completion: @escaping (_ list: [Song]?, _ error: Error?) -> Void) {
        
        let baseUrl = "https://itunes.apple.com/search"
        var components = URLComponents(string: baseUrl)
        var termValue = "a"
        if songName.count > 0 {
            termValue = songName.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        }
        components?.queryItems = [
            URLQueryItem(name: "limit", value: "200"),
            URLQueryItem(name: "country", value: "HK"),
            URLQueryItem(name: "term", value: termValue)
        ]

        if let url = components?.url {
            let requestPublisher = Future<Data?, Error> { promise in
                URLSession.shared.dataTask(with: url) { ( data, response, error) in
                    if (data != nil) && error == nil {
                        promise(.success(data))
                    } else {
                        promise(.failure(error!))
                    }
                }.resume()
            }
            
            let _ = requestPublisher.sink { (result) in
                switch result {
                case .failure(let error):
                    completion(nil, error)
                default: break
                }
            } receiveValue: { value in
                if let value = value {
                    
                    let dcoder = JSONDecoder()
                    do {
                        let result = try dcoder.decode(RequestResult.self, from: value)
                        if let list = result.results {
                            self.songList.removeAll()
                            self.songList.append(contentsOf: list)
                            self.resetSongList()
                        }
                        completion(self.displaySongList, nil)
                        
                    } catch let err {
                        print("decodeErr", err)
                        completion(nil, err)
                    }
                    
                }
                
            }.store(in: &cancellables)
            
            
        }
        
    }
    
    func resetSongList() {
        self.displaySongList = self.songList.sorted(by: {
            if self.sortType == 1 {
                //简单比较文字排序
                return ($0.artistName.unicodeScalars.first?.value ?? 0) < ($1.artistName.unicodeScalars.first?.value ?? 0)
            } else {
                return ($0.trackPrice ?? 0.0) < ($1.trackPrice ?? 0.0)
            }
        })
    }
    
    func updateSortType(type: Int) {
        self.sortType = type
        self.resetSongList()
    }
    

}
