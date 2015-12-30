//
//  Cloud.swift
//  R3LRackspace
//
//  Created by Juan Carrera on 12/18/15.
//  Copyright © 2015 Rokk3rlabs. All rights reserved.
//

import Foundation

public class CloudFiles {
    
    
    public enum CloudFilesRegion: String {
        
        case Chicago = "ORD"
        case Dallas = "DFW"
        case HongKong = "HKG"
        case London = "LON"
        case NorthernVirginia = "IAD"
        case Sydney = "SYD"
        
    }
    
    private var region: CloudFilesRegion?
    private var services: [ServiceCatalog]?

    
    public var username: String?
    public var apiKey: String?
    
    private var token: String?
    private var tenant: [String: String] = [:]
    private var endpoint:String?
    private var authenticated: Bool = false
    private let network: Network
    
    public init(username: String, apiKey: String, region:CloudFilesRegion) {
        
        self.username = username
        self.apiKey = apiKey
        self.region = region
        services = [CloudFilesCDN(), CloudFilesPrivate()]
        network = Network(authURL: CFConstants.AuthURL)
        network.debug = true
    }
    
    public func authenticate(completion: (authenticated: Bool)->()) {
        
        if let username = username, let apiKey = apiKey {
            
            let credentials =  [ "username": username , "apiKey": apiKey]
            let key = ["RAX-KSKEY:apiKeyCredentials": credentials]
            let auth = ["auth": key]

            network.sendRequest(Network.RSHTTPMethod.POST, params: auth ) {
                (data, response, error) in
                if let data = data as? [String: AnyObject] , let access = data["access"] as? [String: AnyObject] {
                    self.authenticated = true
                    
                    if let tokenDict = access["token"] as? [String: AnyObject] {
                        
                        if let tokenID = tokenDict["id"] as? String {
                            self.token = tokenID
                            self.network.token = self.token
                        }
                        if let tenant = tokenDict["tenant"] as? [String: String] {
                            self.tenant["id"] = tenant["id"]
                            self.tenant["name"] = tenant["name"]
                        }
                    }
                    
                    if let APIServices = access["serviceCatalog"] as? [[String: AnyObject]] {
                        
                        if let installedServices = self.services {
                            for service in installedServices {
                                if let region = self.region, let name = service.name {
                                    
                                    let serviceFix = self.filterAPIService(APIServices, name: name, region: region.rawValue)
                                    
                                    if let serviceFix = serviceFix, let regionEndpoint = serviceFix["endpoints"] as? [String: AnyObject]  {
                                        if let foundedEndpoint = regionEndpoint["publicURL"] as? String {
                                            service.endpoint = foundedEndpoint
                                        }
                                    }
                                }
                                
                            }
                        }
                    }
                    
                } else {
                    self.authenticated = false
                }
                
                completion(authenticated: self.authenticated)
            }
        }
        
        
    }
    
    
    public func putObject(data: NSData, name: String, container: String, completion:(success: Bool)->()) {
        
        let put:()->() = {
            
            if let cdn: CloudFilesPrivate = self.services?[1] as? CloudFilesPrivate, let endpoint = cdn.endpoint {
                
                if let url = NSURL(string: "\(endpoint)/\(container)/\(name)") {
                    self.network.uploadFile(data,
                        url: url,
                        method: Network.RSHTTPMethod.PUT,
                        completion: { success in
                            if success {
                                completion(success: true)
                            }else {
                                completion(success: false)
                            }
                        }
                    )
                }
            }
        }
        
        if authenticated {
            put()
        }else {
            authenticate(){
                success in
            
                if success {
                    self.authenticated = true
                    put()
                }
            }
        }
    }
    
    public func getPublicURL(container: String, name: String, completion:(urlObject: String?) -> ()) {
        
        self.getPublicContainerURL(container) { urlString in
            if let urlString = urlString {
                completion(urlObject: "\(urlString)/\(name)")
            }else {
                completion(urlObject: nil)
            } 
        }
    }
    
    
    public func getContainer(container: String) {
        let get:()->() = {
            
            if let cdn: CloudFilesPrivate = self.services?[1] as? CloudFilesPrivate, let endpoint = cdn.endpoint {
                self.network.sendRequest(Network.RSHTTPMethod.GET,
                    endpoint: "\(endpoint)/\(container)",
                    headers: [
                        "Accept": "application/json"
                    ],
                    completion: { (data, response, error) -> () in
                        guard let _ = error else {
                            print(response)
                            print(data)
                            return
                        }
                })
                
            }
        }
        
        if authenticated {
            get()
        }else {
            authenticate(){
                success in
                
                if success {
                    self.authenticated = true
                    get()
                }
            }
        }
    }
    
    public func getContainers() {
        let get:()->() = {
            
            if let cdn: CloudFilesPrivate = self.services?[1] as? CloudFilesPrivate, let endpoint = cdn.endpoint {
                self.network.sendRequest(Network.RSHTTPMethod.GET,
                    endpoint: "\(endpoint)",
                    headers: [
                        "Accept": "application/json"
                    ],
                    completion: { (data, response, error) -> () in
                        guard let _ = error else {
                            print(response)
                            print(data)
                            return
                        }
                })
                
            }
        }
        
        if authenticated {
            get()
        }else {
            authenticate(){
                success in
                
                if success {
                    self.authenticated = true
                    get()
                }
            }
        }
    }
    
    
    public func enableContainerForCDN(container: String, completion:(success: Bool)->()) {
        
        let put:()->() = {
            
            if let cdn: CloudFilesPrivate = self.services?[1] as? CloudFilesPrivate, let endpoint = cdn.endpoint {
                self.network.sendRequest(Network.RSHTTPMethod.PUT,
                    endpoint: "\(endpoint)/\(container)",
                    headers: [
                        "X-CDN-Enabled": "True"
                    ],
                    completion: { (data, response, error) -> () in
                        print(NSString(data: data as! NSData, encoding: NSUTF8StringEncoding))
                        print(response)
                        guard let _ = error else {
                            completion(success: true)
                            return
                        }
                        completion(success: false)
                })
                
            }
        }
        
        if authenticated {
            put()
        }else {
            authenticate(){
                success in
                
                if success {
                    self.authenticated = true
                    put()
                }
            }
        }
    }
    
    
    public func getPublicContainers() {
        
        let get:()->() = {
            
            if let cdn: CloudFilesCDN = self.services?.first as? CloudFilesCDN, let endpoint = cdn.endpoint {
                self.network.sendRequest(Network.RSHTTPMethod.GET,
                    endpoint: "\(endpoint)",
                    headers: [
                        "Accept": "application/json"
                    ],
                    completion: { (data, response, error) -> () in
                        guard let _ = error else {
                            print(response)
                            print(data)
                            return
                        }
                })
                
            }
        }
        
        if authenticated {
            get()
        }else {
            authenticate(){
                success in
                
                if success {
                    self.authenticated = true
                    get()
                }
            }
        }
    }
    
    private func publicContainerInfo(containerName:String, completionInfo:(urlString: String?)->()){
        
        if let cdn: CloudFilesCDN = self.services?.first as? CloudFilesCDN, let endpoint = cdn.endpoint {
            self.network.sendRequest(Network.RSHTTPMethod.HEAD,
                endpoint: "\(endpoint)/\(containerName)",
                completion: { (data, response, error) -> () in
                    
                    print(response)
                    if let _ = error {
                        completionInfo(urlString: nil)
                    }else {
                        if let headers = response.allHeaderFields as? [String: AnyObject] {
                            let urlString = headers["X-Cdn-Ssl-Uri"] as? String
                            completionInfo(urlString: urlString)
                        }
                        
                    }
            })
        }
    }
    
    
    public func getPublicContainerURL(containerName: String, completion: (urlString: String?)->()){
    
        if authenticated {
            publicContainerInfo(containerName) { urlString in
                completion(urlString: urlString)
            }
        }else {
            authenticate(){
                success in
                
                if success {
                    self.authenticated = true
                    self.publicContainerInfo(containerName) { urlString in
                        completion(urlString: urlString)
                    }
                }
            }
        }
    }
    
    public func createContainer(name: String) {
        
        let put:()->() = {
            
            if let cdn: CloudFilesPrivate = self.services?[1] as? CloudFilesPrivate, let endpoint = cdn.endpoint, let account = self.tenant["id"]{
                self.network.sendRequest(Network.RSHTTPMethod.PUT,
                    endpoint: "\(endpoint)/\(account)/\(name)",
                    completion: { (data, response, error) -> () in
                        guard let _ = error else {
                            print(response)
                            print(data)
                            return
                        }
                })
                
            }
        }
        
        if authenticated {
            put()
        }else {
            authenticate(){
                success in
                
                if success {
                    self.authenticated = true
                    put()
                }
            }
        }

    }

    private func filterAPIService(APIServices: [[String: AnyObject]], name: String, region: String? = nil) -> [String: AnyObject]? {
        
        let filteredByName = APIServices.filter({ service in
            
            if let serviceName = service["name"] as? String where name == serviceName {
                return true
            }else {
                return false
            }
        })
        
        if let region = region {
            
            if var serviceByName = filteredByName.first, let endpoints = serviceByName["endpoints"] as? [AnyObject]{
                
                let regionEndpointsAPI = endpoints.filter({ ep in
                    if let APIRegion = ep["region"] as? String where APIRegion == region {
                        return true
                    }else {
                        return false
                    }
                })
                if let regionEndpoint = regionEndpointsAPI.first {
                    serviceByName.updateValue(regionEndpoint, forKey: "endpoints")
                }
                
                return serviceByName
            }else {
                return nil
            }
            
        }else {
            return filteredByName.first
        }
    }
}