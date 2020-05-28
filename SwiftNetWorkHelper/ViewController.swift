//
//  ViewController.swift
//  SwiftNetWorkHelper
//
//  Created by 罗德良 on 2019/4/10.
//  Copyright © 2019 swagTeam. All rights reserved.
//

import UIKit
import Alamofire
import RxSwift
import Moya

class ViewController: UIViewController {
    var disposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        let rxProvider = MoyaProvider<APIManager>()
        rxProvider.rx.request(.getNbaInfo(getKey: "537f7b3121a797c8d18f4c0523f3c124")).asObservable().mapResponseToObject(type: TestModel.self)
            .subscribe { (test) in
                print(test)
                let model = test.element
                print(model?.reason ?? String.self)
        }
        .disposed(by: disposeBag)
        
//        let testButton = UIButton.init(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
//        testButton.backgroundColor = UIColor.red
//        self.view.addSubview(testButton)
//
//        let one = 1
//        let two = 2
//        let variable = Observable.just(one)
//        let variable2 = Observable.of(one,two)
//        let variable3 = Observable.of([one,two])
//        let variable4 = Observable.from([1,2,3])
        
        
        
        
        
    }
}

