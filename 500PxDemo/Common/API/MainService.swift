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
    case photos(categoryType: String)
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
        return Data()
    }
    
    /// The type of HTTP task to be performed.
    var task: Task {
        switch self {
        case .photos(let categoryType):
            return .requestParameters(parameters: ["feature": "fresh_today",
                                                   "only": categoryType,
                                                    "sort": "created_at",
                                                    "page": 1,
                                                    "rpp": 10,
                                                    "image_size": "3,6"],
                                      encoding: URLEncoding.default)
            
        }
    }
    

    
    /// The headers to be used in the request.
    var headers: [String: String]? {
        return nil
    }
}
