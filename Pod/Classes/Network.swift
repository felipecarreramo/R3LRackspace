//
//  Network.swift
//  R3LRackspace
//
//  Created by Juan Carrera on 12/18/15.
//  Copyright © 2015 Rokk3rlabs. All rights reserved.
//

import Foundation
import Alamofire

//HTTP calls
public class Network: NSObject {
    
    
    public var baseURL: String?
    public var debug: Bool = false
    public var token: String?
    
    private var responseData = NSMutableData()
    private var completionUpload : ((success: Bool) -> ())?
    
    public enum RSHTTPMethod: String {
        case POST   = "POST"
        case GET    = "GET"
        case PUT    = "PUT"
        case DELETE = "DELETE"
        case HEAD = "HEAD"
    }
    
    public init(baseURL: String) {
        self.baseURL = baseURL
    }
    
    public init(authURL: String) {
        self.baseURL = authURL
    }
    
    
    public func sendRequest(method: RSHTTPMethod, endpoint: String? = nil, params: [String: AnyObject]? = nil, headers: [String: String]? = nil, completion:(data: AnyObject?, response: NSHTTPURLResponse?, error: NSError?) -> ()) {
        
        var url: String?
        var parameterEncoding: ParameterEncoding?
        if let endpoint = endpoint {
            url =  "\(endpoint)"
            parameterEncoding = ParameterEncoding.URL
        }else if let baseURL =  baseURL {
            parameterEncoding = ParameterEncoding.JSON
            url = "\(baseURL)"
        }
        
        if let url = url {
            
            var allHeaders = [String: String]()
            
            if let token = self.token {
                allHeaders["X-Auth-Token"] = token
            }
            
            if let headers = headers {

                if self.debug {
                    
                    let jsonData: NSData?
                    do {
                        jsonData = try NSJSONSerialization.dataWithJSONObject(
                            headers ,
                            options: NSJSONWritingOptions.PrettyPrinted)
                        
                        if let jsonData = jsonData, let theJSONText = NSString(data: jsonData, encoding: NSASCIIStringEncoding) {
                            print("DEBUG OUTPUT REQUEST HEADERS = \n ", theJSONText)
                        }
                        
                    } catch {
                        
                    }
                    
                }
            }
            
            var aMethod: Alamofire.Method?
            
            switch method {
                
            case .POST:
                aMethod = Alamofire.Method.POST
            case .GET:
                aMethod = Alamofire.Method.GET
            case .PUT:
                aMethod = Alamofire.Method.PUT
            case .DELETE:
                aMethod = Alamofire.Method.DELETE
            case .HEAD :
                aMethod = Alamofire.Method.HEAD
            }
            
            if let aMethod = aMethod, let parameterEncoding = parameterEncoding{
                Alamofire.request(aMethod, url, parameters: params, encoding: parameterEncoding, headers: allHeaders)
                    .responseJSON() { response in
                        
                        switch response.result {
                        case .Success(let data):
                            print(data)
                            completion(data: data, response: response.response, error: nil)
                        case .Failure(let error):
                            if self.debug {
                                print("Error: \(error.localizedDescription)")
                            }
                            completion(data: nil, response: nil, error: error)
                        }
                }
            }
        }
    }
    
    func uploadFile(data: NSData, url: NSURL, method: RSHTTPMethod, completion: (success: Bool)->()) {
        
        completionUpload = completion
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = method.rawValue
        request.addValue("Keep-Alive", forHTTPHeaderField: "Connection")
        request.addValue(String(data.length), forHTTPHeaderField: "Content-Length" )
        request.addValue(mimeType(data), forHTTPHeaderField: "Content-Type"  )
        
        if let token = self.token {
            request.addValue(token, forHTTPHeaderField: "X-Auth-Token")
        }
        
        Alamofire.upload(request, data: data)
            .response { request, response, data, error in
                if let error = error {
                    self.completionUpload?(success: false)
                    if self.debug {
                        print("Error ocurred: ", error.userInfo )
                    }
                    
                }else {
                    self.completionUpload?(success: true)
                    if self.debug {
                        print("upload completed")
                    }
                    
                }
        }
        
    }
    
    private func mimeType(data: NSData) -> String {
        var c = [UInt32](count: 1, repeatedValue: 0)
        data.getBytes(&c, length: 1)
        switch (c[0]) {
        case 0xFF:
            return "image/jpeg"
        case 0x89:
            return "image/png"
        case 0x47:
            return "image/gif"
        case 0x49, 0x4D:
            return "image/tiff"
        case 0x25:
            return "application/pdf"
        case 0xD0:
            return "application/vnd"
        case 0x46:
            return "text/plain"
        default:
            return "application/octet-stream"
        }
    }
    
}