//
//  RequestRouter.swift
//  ViperWithGenerics
//
//  Created by stzn on 2018/05/28.
//  Copyright © 2018年 stzn. All rights reserved.
//

import Foundation

enum RequestRouter: RequestRouterProtocol {
    
    case fetchList(query: String, page: Int)
    
    var path: String {
        switch self {
        case .fetchList:
            return "/items"
        }
    }
    
    var baseUrl: String {
        return "https://qiita.com/api/v2"
    }
    
    var headers: [String : String] {
        return [:]
    }
    
    var timeoutInterval: TimeInterval {
        return 60.0
    }
    
    var parameters: [String : Any]? {
        switch self {
        case .fetchList(let query, let page):
            return [FetchListParameters.query: query,
                    FetchListParameters.page: page,
                    FetchListParameters.perPage: 30]
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .fetchList:
            return .get
        }
    }
    
}

