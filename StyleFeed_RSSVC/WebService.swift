//
//  WebService.swift
//  CoutureLane
//
//  Created by Bernal Yescas, Francisco on 3/20/18.
//  Copyright © 2018 Couture Lane. All rights reserved.
//

import Foundation
import AFNetworking
import MBProgressHUD

@objc
enum MethodType: Int {
    case post
    case get
}

class WebService: NSObject {
    
    @objc static let shared = WebService()
    
    // TODO: remove this method once we get rid of Obj-C
    @objc func call(_ url: String,
              method: MethodType,
              parameters: [String: Any],
              showIndicator: Bool,
              inView view: UIView?,
              completion: @escaping (Any) -> Void,
              failure: @escaping (Error) -> Void) {
        self.call(url,
                  method: method,
                  parameters: parameters,
                  showIndicator: showIndicator,
                  inView: view,
                  constructingBodyBlock: nil,
                  completion: completion,
                  failure: failure)
    }
    
    func call(_ url: String,
              method: MethodType,
              parameters: [String: Any],
              showIndicator: Bool,
              inView view: UIView?,
              constructingBodyBlock: ((AFMultipartFormData) -> Void)? = nil,
              completion: @escaping (Any) -> Void,
              failure: @escaping (Error) -> Void) {
        
        let serializer = AFJSONRequestSerializer()
        serializer.setValue("application/json", forHTTPHeaderField: "Content-Type")
        serializer.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let manager = AFHTTPSessionManager()
        manager.requestSerializer = serializer
        var acceptableContentTypes = manager.responseSerializer.acceptableContentTypes
        acceptableContentTypes?.insert("text/html")
        manager.responseSerializer.acceptableContentTypes = acceptableContentTypes
        
        if showIndicator,
            let view = view {
            MBProgressHUD.showAdded(to: view, animated: true)
        }
        
        let progress : (Progress) -> Void = { (progress) in
            DispatchQueue.main.async {
                print("Progress: \(progress)")
            }
        }
        let success : (URLSessionTask?, Any?) -> Void = { (task, responseObject) in
            DispatchQueue.main.async {
                guard let responseObject = responseObject else { return }
                print(">> URL: \(url)")
                print("> Params:\n\(parameters)")
                print("> Response:\n\(responseObject)")
                completion(responseObject)
                if showIndicator,
                    let view = view {
                    MBProgressHUD.hide(for: view, animated: true)
                }
            }
        }
        let failureBlock : (URLSessionTask?, Error) -> Void = { (task, error) in
            DispatchQueue.main.async {
                print(">> URL: \(url)")
                print("> Params:\n\(parameters)")
                print("> Error:\n\(error)")
                if showIndicator,
                    let view = view {
                    MBProgressHUD.hide(for: view, animated: true)
                }
                failure(error)
            }
        }
        
        switch method {
        case .get:
            manager.get(url,
                        parameters: parameters,
                        progress: progress,
                        success: success,
                        failure: failureBlock)
        case .post:
            if let constructingBodyBlock = constructingBodyBlock {
                manager.post(url,
                             parameters: parameters,
                             constructingBodyWith: constructingBodyBlock,
                             progress: progress,
                             success: success,
                             failure: failureBlock)
            } else {
                manager.post(url,
                             parameters: parameters,
                             progress: progress,
                             success: success,
                             failure: failureBlock)
            }
        }
    }
    
}
