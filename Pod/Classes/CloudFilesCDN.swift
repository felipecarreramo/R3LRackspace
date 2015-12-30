//
//  cloudFilesCDN.swift
//  Pods
//
//  Created by Juan Carrera on 12/18/15.
//
//

import Foundation


class CloudFilesCDN: ServiceCatalog {

    override init() {
        super.init()
        self.name = "cloudFilesCDN"
        self.type = "rax:object-cdn"
        self.endpoint = ""
    }
    
    
}
