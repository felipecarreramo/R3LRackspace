//
//  CFObject.swift
//  Pods
//
//  Created by Felipe Carrera on 30/12/15.
//
//

import Foundation

public struct CFObject {
    
    public var data: NSData?
    public var name: String?
    public var container: CFContainer?
    public var uri: String?

    
    public static func objectBy(name: String, data: NSData? = nil) -> CFObject {
        var object = CFObject()
        object.name = name
        if let data = data {
            object.data = data
        }
        return object
    }
    
    
    
}
