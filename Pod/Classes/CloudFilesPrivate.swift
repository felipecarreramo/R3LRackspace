//
//  CloudFilesPrivate.swift
//  Pods
//
//  Created by Juan Carrera on 12/18/15.
//
//

import Foundation

class CloudFilesPrivate: ServiceCatalog {
    
    override init() {
        super.init()
        self.name = "cloudFiles"
        self.type = "object-store"
        self.endpoint = ""
    }
}
