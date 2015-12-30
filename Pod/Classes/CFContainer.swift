//
//  CFContainer.swift
//  Pods
//
//  Created by Felipe Carrera on 30/12/15.
//
//

import Foundation


public struct CFContainer {
    
    public var name: String?
    public var uri: String?
    public var objects: [CFObject]?
    private let network: Network
    
    init() {
        network = Network(authURL: CFConstants.AuthURL)
    }
    
    public static func containerBy(name: String) -> CFContainer {
        var container = CFContainer()
        container.name = name
        return container
    }
    
    public func sync(completion:(success: Bool)->()) {
        
        
    }
    
}