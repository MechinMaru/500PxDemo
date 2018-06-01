//
//  mainService.swift
//  500PxDemo
//
//  Created by MECHIN on 5/27/18.
//  Copyright © 2018 MECHIN. All rights reserved.
//

import Foundation
import Moya

enum MainService {
    case photos(categoryType: String, currentPage: Int)
}


extension MainService: TargetType {
    var baseURL: URL {
        return URL(string: "https://api.500px.com/v1")!
    }
    
    var path: String {
        switch self {
            case .photos:
                return "/photos"
        }
    }
    
    /// The HTTP method used in the request.
    var method: Moya.Method {
        switch self {
        case .photos:
            return .get
            
        }
    }
    
    /// Provides stub data for use in testing.
    var sampleData: Data {
        switch self {
        case .photos(_, let currentPage):
            if currentPage == 3 {
                let fileURL = R.file.errorJson()!
                let data = try! Data(contentsOf: fileURL)
                return data
                
            }
            let fileURL = R.file.photosJson()!
            let data = try! Data(contentsOf: fileURL)
            return data
        }
//        return Data()
    }
    
    /// The type of HTTP task to be performed.
    var task: Task {
        switch self {
        case .photos(let categoryType,let currentPage):
            return .requestParameters(parameters: ["feature": "fresh_today",
                                                   "only": categoryType,
                                                    "sort": "created_at",
                                                    "page": currentPage,
                                                    "rpp": 10,
                                                    "image_size": "3,6", 
                                                    "consumer_key": AppConstants.consumerKey],
                                      encoding: URLEncoding.default)
            
        }
    }
    

    
    /// The headers to be used in the request.
    var headers: [String: String]? {
        return nil
    }
}
