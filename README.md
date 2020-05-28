# SwiftNetWorkHelper
RxSwift、Alamofire、Moya和HandyJson的结合使用 

<h2>打造swift网络框架</h2>

> 准备工作

* <h5>使用CocoaPods工具Pod需要使用的相关框架</h5>

具体的pod用法在这里就不做详解了，如有不懂可以查阅 [CocoaPods使用](https://www.jianshu.com/p/b656c3c59af5)

        pod 'Alamofire' 
        pod 'Moya/RxSwift'
        pod 'HandyJSON', '~> 5.0.0-beta.1'

>创建文件


* <h5>APIManager</h5>


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


* <h5>RxHandyJSON</h5>


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
	                
	                let jsonData = try response.mapJSON() as! [String : Any]
	                if let code = jsonData[RESULT_MSG] as? String {
	                    if code == "查询成功" {
	                        if let model = JSONDeserializer<T>.deserializeFrom(dict: jsonData){
	                            return model
	                        }
	                    }
	                }
	    }
	    
* <h5>TestModel</h5>

		//
		//  TestModel.swift
		//  SwiftNetWorkHelper
		//
		//  Created by 罗德良 on 2019/4/10.
		//  Copyright © 2019 swagTeam. All rights reserved.
		//
		
		import HandyJSON
		
		struct TestModel: HandyJSON {
		    var reason :String = ""
		    var result :String = ""
		}

> 实现效果

	let rxProvider = MoyaProvider<APIManager>()
	        rxProvider.rx.request(.getNbaInfo(getKey: "537f7b3121a797c8d18f4c0523f3c124")).asObservable().mapResponseToObject(type: TestModel.self)
	            .subscribe { (test) in
	                print(test)
	                let model = test.element
	                print(model?.reason ?? String.self)
	        }
	        .disposed(by: disposeBag)
		
> 总结


* <h5>APIManager作为接口内容配置，通过接口地址以及接口数据的组建</h5>
* <h5>RxHandyJSON作为由于Moya对HandyJson没有扩展，自己实现的扩展，该文件可以根据后台接口定义做调整</h5>
* <h5>TestModel作为基础数据格式，该处可以创建一个BaseModel，根据后台返回数据进行调整，会有更好的扩展性</h5>
