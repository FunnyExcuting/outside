//
//  Song.swift
//  CodeTest
//
//  Created by Maple on 2024/2/19.
//

import Foundation

struct RequestResult: Codable {
    var resultCount: Int?
    var results: [Song]?
    
}

struct Song: Codable {
    
    var artistName: String
    var trackName: String
    var trackPrice: Double?
    
}
