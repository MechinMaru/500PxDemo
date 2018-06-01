//
//  CategoryModel.swift
//  500PxDemo
//
//  Created by MECHIN on 5/27/18.
//  Copyright © 2018 MECHIN. All rights reserved.
//

import Foundation

enum CategoryType: String {
    case uncategorized = "Uncategorized"
    case abstract = "Abstract"
    case aerial = "Aerial"
    case animals = "Animals"
    case blackAndWhite = "Black and White"
    case celebrities = "Celebrities"
    case cityAndArchitecture = "City and Architecture"
    case commercial = "Commercial"
    case concert = "Concert"
    case family = "Family"
    case fashion = "Fashion"
    case film = "Film"
    case fineArt = "Fine Art"
    case food = "Food"
    case journalism = "Journalism"
    case landscapes = "Landscapes"
    case macro = "Macro"
    case nature = "Nature"
    case night = "Night"
    case nude = "Nude"
    case people = "People"
    case performingArts = "Performing Arts"
    case sport = "Sport"
    case stillLife = "Still Life"
    case street = "Street"
    case transportation = "Transportation"
    case travel = "Travel"
    case underwater = "Underwater"
    case urbanExploration = "Urban Exploration"
    case wedding = "Wedding"
    
    var categoryName: String {
        return self.rawValue
    }
    
    static var categoryList: [CategoryType] {
        return [.uncategorized, .abstract, .aerial, .animals,
                .blackAndWhite, .celebrities, .cityAndArchitecture, .commercial,
                .concert, .family, .fashion, .film,
                .fineArt, .food, .journalism, .landscapes,
                .macro, .nature, .night, .nude,
                .people, .performingArts, .sport, .stillLife,
                .street, .transportation, .travel, .underwater,
                .urbanExploration, .wedding
        ]
    }
}

