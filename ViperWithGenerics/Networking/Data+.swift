//
//  URLResponse+.swift
//  ViperWithGenerics
//
//  Created by stzn on 2018/05/28.
//  Copyright © 2018年 stzn. All rights reserved.
//

import Foundation

extension Data {
    
    func parseError() -> ApplicationError {
        let decoder = JSONDecoder()
        
        do {
            let apiError = try decoder.decode(APIError.self, from: self)
            return apiError
        } catch (let error) {
            print("Error while parsing error: \(error)")
            return ServerError(message: "Wrong Error Format")
        }
    }
    
    func parseData<Value: Codable>() -> ServiceResult<Value> {
        do {
            let decoder = JSONDecoder()
            let result = try decoder.decode(Value.self, from: self)
            return ServiceResult.success(result)
        } catch {
            let error = ParsingError(error: error as! DecodingError)
            print(error.debugDescription)
            return ServiceResult.failure(error)
        }
    }
}

