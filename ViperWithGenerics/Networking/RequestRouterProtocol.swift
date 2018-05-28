//
//  RequestRouterProtocol.swift
//  ViperWithGenerics
//
//  Created by stzn on 2018/05/28.
//  Copyright © 2018年 stzn. All rights reserved.
//

import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
}


protocol RequestRouterProtocol {
    var path: String { get }
    var baseUrl: String  { get }
    var headers: [String: String] { get }
    var timeoutInterval: TimeInterval { get }
    var parameters: [String: Any]? { get }
    var method: HTTPMethod { get }
}

extension RequestRouterProtocol {
    
    var urlParameters: [String: Any]? {

        switch method {
        case .post:
            return nil
        default:
            return parameters
        }
    }
    
    func urlRequest() -> URLRequest? {
        
        let urlString = baseUrl + path

        switch method {
        case .get:
            guard var components = URLComponents(string: urlString) else {
                return nil
            }
            
            guard let parameters = parameters else {
                return nil
            }

            components.queryItems = method.makeQueryItem(parameter: parameters)

            var urlRequest = URLRequest(url: components.url!)
            urlRequest.httpMethod = method.rawValue
            headers.forEach { urlRequest.setValue($1, forHTTPHeaderField: $0) }

            return urlRequest
            
        case .post:
            guard let url = URL(string: urlString) else {
                return nil
            }
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = method.rawValue
            headers.forEach { urlRequest.setValue($1, forHTTPHeaderField: $0) }
            urlRequest = method.appendHttpBody(for: urlRequest, with: parameters ?? [:])
            return urlRequest
        }
    }
    
}

fileprivate extension HTTPMethod {
    
    func makeQueryItem(parameter: [String:Any]) -> [URLQueryItem] {
        var items :[URLQueryItem] = []
        parameter.forEach { key, value in
            let string = String(describing: value)
            guard !string.isEmpty else { return }
            let value = string.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
            items.append(URLQueryItem(name: key, value: value))
        }
        return items
    }

    func appendHttpBody(for request: URLRequest, with parameters: [String: Any] = [:]) -> URLRequest {
        var mutableRequest = request
        let params = parameters
        switch self {
        case .post:
            do {
                mutableRequest.httpBody = try JSONSerialization.data(
                    withJSONObject: params,
                    options: JSONSerialization.WritingOptions())
            } catch {
                print(error.localizedDescription)
            }
        default:
            break
        }
        return mutableRequest
    }
}
