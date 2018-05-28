//
//  Resource.swift
//  ViperWithGenerics
//
//  Created by stzn on 2018/05/28.
//  Copyright © 2018年 stzn. All rights reserved.
//

import Foundation

struct Resource<Value> {
    let requestRouter: RequestRouterProtocol
    let parse: (Data) throws -> Value
}

struct Root<Value: Codable>: Codable {
    enum CodingKeys: String, CodingKey {
        case response
    }
    
    var value: Value
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        value = try container.decode(Value.self, forKey: .response)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(value, forKey: .response)
    }
}

extension Resource where Value: Codable {
    init(requestRouter: RequestRouterProtocol) {
        self.init(requestRouter: requestRouter,
                  parse: { data in
                    let decoder = JSONDecoder()
                    let result = try decoder.decode(Root<Value>.self, from: data)
                    return result.value
        })
    }
}

//extension Resource where Value: Collection, Value.Element: Codable {
//    init(requestRouter: RequestRouterProtocol) {
//        self.init(requestRouter: requestRouter,
//                  parse: { data in
//                    let decoder = JSONDecoder()
//                    let result: [Value.Element] = try decoder.decode(Root<[Value.Element]>.self, from: data).value
//                    return result as! Value
//        })
//    }
//}
//
