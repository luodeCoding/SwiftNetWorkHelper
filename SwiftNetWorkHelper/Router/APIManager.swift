//
//  APIManager.swift
//  SwiftNetWorkHelper
//
//  Created by 罗德良 on 2019/4/10.
//  Copyright © 2019 swagTeam. All rights reserved.
//

import Foundation
import Moya

enum APIManager {
    case testApi
    case testApiPara(para1:String,para2:String)
    case testApiDict(Dict:[String:Any])
    case getNbaInfo(getKey:String)
}

extension APIManager:TargetType {
    var baseURL: URL {
        return URL.init(string: "http://op.juhe.cn/onebox/basketball/")!
    }
    
    var path: String {
        switch self {
        case .testApi:
            return "nba"
        case .testApiPara(let para1, let para2):
            return "nba"
        case .testApiDict:
            return "nba"
        case .getNbaInfo:
            return "nba"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .testApi:
            return .get
        default:
            return .post
        }
    }
    
    var sampleData: Data {
        return "".data(using: String.Encoding.utf8)!
    }
    
    var task: Task {
        switch self {
        case .testApi:
            return .requestPlain
        case let .testApiPara(para1, _):
            return .requestParameters(parameters: ["key" : para1], encoding: URLEncoding.default)
        case .testApiDict(let dict):
            return .requestParameters(parameters: dict, encoding: JSONEncoding.default)
        case .getNbaInfo(let getKey):
            return .requestParameters(parameters: ["key" : getKey], encoding: URLEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        return ["Content-Type":"application/x-www-form-urlencoded"]
    }
    
    
}
