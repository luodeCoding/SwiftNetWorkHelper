    //
    //  RxHandyJSON.swift
    //  SwiftNetWorkHelper
    //
    //  Created by 罗德良 on 2019/4/10.
    //  Copyright © 2019 swagTeam. All rights reserved.
    //

    import Foundation
    import RxSwift
    import HandyJSON
    import Moya


    enum DCUError : Swift.Error {
        case ParseJSONError
        case RequestFailed
        case NoResponse
        case UnexpectedResult(resultCode: Int?,resultMsg:String?)
    }

    enum RequestStatus: Int {
        case requestSuccess = 200
        case requestError
    }

    fileprivate let RESULT_CODE = "code"
    fileprivate let RESULT_MSG = "reason"
    fileprivate let RESULT_DATA = "result"

    public extension Observable {
        func mapResponseToObject<T: HandyJSON>(type: T.Type) -> Observable<T> {
            return map { response in
                guard let response = response as? Moya.Response
                    else {
                        throw DCUError.NoResponse
                }
                guard ((200...209) ~= response.statusCode) else {
                    throw DCUError.RequestFailed
                }
                
                ////////////////////////////////////////////////////////////
                let jsonData = try response.mapJSON() as! [String : Any]
                if let code = jsonData[RESULT_MSG] as? String {
                    if code == "查询成功" {
                        if let model = JSONDeserializer<T>.deserializeFrom(dict: jsonData){
                            return model
                        }
                    }
                }
                
                ////////////////////////////////////////////////////////////
                guard let json = try?JSONSerialization.jsonObject(with: response.data, options: JSONSerialization.ReadingOptions(rawValue: 0)) as? [String:Any] else {
                    throw DCUError.NoResponse
                }
                if let code = json[RESULT_MSG] as? Int {
                    if code == RequestStatus.requestSuccess.rawValue {
                        let data = json[RESULT_DATA]
                        if let data = data as? Data {
                            let jsonString = String(data: data,encoding: .utf8)
                            let object = JSONDeserializer<T>.deserializeFrom(json: jsonString)
                            if object != nil {
                                return object!
                            }else {
                                throw DCUError.ParseJSONError
                            }
                        }else {
                            throw DCUError.ParseJSONError
                        }
                    }else {
                        throw DCUError.UnexpectedResult(resultCode:json[RESULT_CODE] as? Int, resultMsg: json[RESULT_MSG] as? String)
                    }
                }
            else {
                    throw DCUError.ParseJSONError
                }
                
            }
        }
        
        func mapResponseToObjectArray<T: HandyJSON>(type: T.Type) -> Observable<[T]> {
            return map { response in
                
                // 得到response
                guard let response = response as? Moya.Response else {
                    throw DCUError.NoResponse
                }
                
                // 检查状态码
                guard ((200...209) ~= response.statusCode) else {
                    throw DCUError.RequestFailed
                }
                
                guard let json = try? JSONSerialization.jsonObject(with: response.data, options: JSONSerialization.ReadingOptions(rawValue: 0)) as? [String: Any]  else {
                    throw DCUError.NoResponse
                }
                
                // 服务器返回code
                if let code = json[RESULT_CODE] as? Int {
                    if code == RequestStatus.requestSuccess.rawValue {
                        guard let objectsArrays = json[RESULT_DATA] as? NSArray else {
                            throw DCUError.ParseJSONError
                        }
                        // 使用HandyJSON解析成对象数组
                        if let objArray = JSONDeserializer<T>.deserializeModelArrayFrom(array: objectsArrays) {
                            if let objectArray: [T] = objArray as? [T] {
                                return objectArray
                            }else {
                                throw DCUError.ParseJSONError
                            }
                        }else {
                            throw DCUError.ParseJSONError
                        }
                        
                        
                    } else {
                        throw DCUError.UnexpectedResult(resultCode: json[RESULT_CODE] as? Int , resultMsg: json[RESULT_MSG] as? String)
                        
                    }
                } else {
                    throw DCUError.ParseJSONError
                }
            }
        }
    }

