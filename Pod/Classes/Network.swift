//
//  Network.swift
//  R3LRackspace
//
//  Created by Juan Carrera on 12/18/15.
//  Copyright © 2015 Rokk3rlabs. All rights reserved.
//

import Foundation

//HTTP calls
public class Network: NSObject, NSURLSessionDelegate, NSURLSessionTaskDelegate, NSURLSessionDataDelegate {
    
    
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

    
    public func sendRequest(method: RSHTTPMethod, endpoint: String? = nil, params: [String:AnyObject]? = nil, headers: [String:AnyObject]? = nil, completion:(data: AnyObject?, response: NSHTTPURLResponse, error:NSError?) -> ()) {
        
        var url: NSURL?
        var authContentType: String?
        if let endpoint = endpoint {
            url = NSURL(string: "\(endpoint)")
        }else if let baseURL =  baseURL {
            url = NSURL(string: "\(baseURL)")
            authContentType = "application/json"

        }
        
        if let url = url {
            
            let request: NSMutableURLRequest = NSMutableURLRequest(URL: url)
            request.HTTPMethod = method.rawValue
            
            if let token = self.token {
                request.addValue(token, forHTTPHeaderField: "X-Auth-Token")
            }
            
            if let headers = headers {
                for (key, header) in headers {
                    if let header = header as? String {
                        request.addValue(header, forHTTPHeaderField: key)
                    }
                }
                
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
                
                
            }else {
                if let authContentType = authContentType {
                   request.addValue(authContentType, forHTTPHeaderField: "Content-type")
                }
            }
            
            if let params = params  {
                request.HTTPBody = serializeParams(params)
            }
            
            if self.debug {
                debugPrint(request)
            }
            
            let session = NSURLSession.sharedSession()
            let task: NSURLSessionTask = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) in
                
                if self.debug {
                    if let error = error {
                        print("Error: \(error.localizedDescription)")
                    }
                }
                
                if let response = response as? NSHTTPURLResponse , let data = data {
                    
                    let dataDict: AnyObject?
                    
                    do {
                        dataDict = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments)
                    } catch {
                        dataDict = nil
                    }
                
                    if self.debug {
                        
                        if let dataDict = dataDict {
                            let jsonData: NSData?
                            do {
                                jsonData = try NSJSONSerialization.dataWithJSONObject(
                                    dataDict ,
                                    options: NSJSONWritingOptions.PrettyPrinted)
                                
                                if let jsonData = jsonData, let theJSONText = NSString(data: jsonData, encoding: NSASCIIStringEncoding) {
                                    print("DEBUG OUTPUT RESPONSE = \n ", theJSONText)
                                }
                                
                            } catch {
                                
                            }
                        }
                    }
                    
                    if let dataDict = dataDict {
                        completion(data: dataDict, response: response, error: error)
                    }else {
                        completion(data: data, response: response, error: error)
                    }
                }
                
            })
            
            task.resume()
            
        }
    }
    
    private func serializeParams(params: [String: AnyObject]) -> NSData? {
        
        var data: NSData?
        
        do {
            
            data = try NSJSONSerialization.dataWithJSONObject(params, options: NSJSONWritingOptions.PrettyPrinted)
            if debug {
                
                if let data = data, let jsonString = NSString(bytes: data.bytes, length: data.length, encoding: NSUTF8StringEncoding) as? String {
                    print("DEBUG OUTPUT REQUEST = \n ", jsonString)
                }
                
            }
            
        } catch {
            data = nil
        }
        
        
        return data
        
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
        
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session =  NSURLSession(configuration: configuration, delegate: self, delegateQueue: NSOperationQueue.mainQueue())
        let task = session.uploadTaskWithRequest(request, fromData: data)
        task.resume()
        
    }
    
    public func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        if let error = error {
            completionUpload?(success: false)
            print("Session \(session) Error ocurred: ", error.userInfo )
        }else {
            completionUpload?(success: true)
            print("Session \(session) upload completed, response \(NSString(data: responseData, encoding: NSUTF8StringEncoding))")
        }
    }
    
    
    
    public func URLSession(session: NSURLSession, task: NSURLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        
        let uploadProgress = Double(totalBytesSent) / Double(totalBytesExpectedToSend)
        print("session \(session) uploaded: \(uploadProgress * 100)%")
        
    }
    
    public func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveResponse response: NSURLResponse, completionHandler: (NSURLSessionResponseDisposition) -> Void) {
        print("session \(session), received response \(response)")
        completionHandler(NSURLSessionResponseDisposition.Allow)
    }
    
    public func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
        responseData.appendData(data)
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







