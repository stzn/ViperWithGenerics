//
//  BaseAPIClient.swift
//  ViperWithGenerics
//
//  Created by stzn on 2018/05/28.
//  Copyright © 2018年 stzn. All rights reserved.
//

import Foundation
import Reachability

typealias RequestCompletion<T> = (ServiceResult<T>) -> ()

class BaseAPIClient {
    
    private var session = URLSession()
    static let shared = BaseAPIClient()
    private let reachability = Reachability()!
    
    init() {
        let configuration = URLSessionConfiguration.default
        configuration.urlCache = nil
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        session = URLSession(configuration: configuration)
    }
    
    func signOut () {
        session.invalidateAndCancel()
        session = URLSession()
    }
    
    @discardableResult
    func request<Value: Codable>(_ resource: Resource<Value>, completion: @escaping RequestCompletion<Value>) throws -> URLSessionTask {
        
        guard let request = resource.requestRouter.urlRequest() else {
            throw ServerError(message: "Invalid Request")
        }
        return call(urlRequest: request, completion: completion)
    }
    
    @discardableResult
    private func call<Value: Codable>(urlRequest: URLRequest, completion: @escaping RequestCompletion<Value>) -> URLSessionTask {
        
        let task = session.dataTask(with: urlRequest) { data, response, error in
            
            guard let response = response as? HTTPURLResponse,
                 (200...299) ~= response.statusCode
                else {
                    let error = ServerError(message: "Invalid Data")
                    completion(ServiceResult.failure(error))
                    return
            }
            
            if error != nil {
                
                let isReachable = self.reachability.connection != .none
                
                if isReachable {
                    completion(ServiceResult.failure(ServerError(
                        message: error!.localizedDescription)))
                } else {
                    completion(ServiceResult.failure(InternetError()))
                }
                return
            }
            
            guard let data = data else {
                let error = ServerError(message: "Invalid Data")
                completion(ServiceResult.failure(error))
                return
            }
            let result: ServiceResult<Value> = data.parseData()
            completion(result)
        }
        task.resume()
        return task
    }
}

