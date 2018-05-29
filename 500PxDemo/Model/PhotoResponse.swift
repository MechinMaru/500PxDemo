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
}

struct Photo: Codable {
    let id: Int
    let name: String
    let description: String
    let imageUrl: String
    let user: User
}

struct User: Codable {
    let id: Int
    let userName: String
    let firstName: String
    let lastName: String
    let city: String
    let country: String
    let fullName: String
    let userPicUrl: String
    let upgradeStatus: Int
}
