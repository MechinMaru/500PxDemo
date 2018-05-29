//
//  PhotoResponse.swift
//  500PxDemo
//
//  Created by MECHIN on 5/28/18.
//  Copyright © 2018 MECHIN. All rights reserved.
//

import Foundation

struct PhotoResponse: Codable {
    
    let feature: String
    let currentPage: Int
    let totalPages: Int
    let totalItems: Int
    let photos: [Photo]
    
    enum CodingKeys: String, CodingKey {
        case feature
        case currentPage = "current_page"
        case totalPages = "total_pages"
        case totalItems = "total_items"
        case photos 

    }
}

struct Photo: Codable {
    let id: Int
    let name: String?
    let description: String?
    let imageUrl: [String]
    let user: User?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case imageUrl = "image_url"
        case user
    }
}

struct User: Codable {
    let id: Int
    let username: String?
    let firstname: String?
    let lastname: String?
    let city: String?
    let country: String?
    let fullname: String?
    let userPicUrl: String
    let upgradeStatus: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case username
        case firstname
        case lastname
        case city
        case country
        case fullname
        case userPicUrl = "userpic_url"
        case upgradeStatus = "upgrade_status"
    }
}
