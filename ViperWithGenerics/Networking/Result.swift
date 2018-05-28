//
//  Result.swift
//  ViperWithGenerics
//
//  Created by stzn on 2018/05/28.
//  Copyright © 2018年 stzn. All rights reserved.
//

import Foundation

enum ServiceResult<Value> {
    case success(Value)
    case failure(ApplicationError)
}

extension ServiceResult where Value: Any {
    func resultMapper<U>() -> ServiceResult<U> {
        switch self {
        case .success(let value):
            return .success(value as! U)
        case .failure(let error):
            return .failure(error)
        }
    }
}
