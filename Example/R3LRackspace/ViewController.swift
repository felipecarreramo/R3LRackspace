//
//  ViewController.swift
//  R3LRackspace
//
//  Created by Juan Felipe Carrera Moya on 12/18/2015.
//  Copyright (c) 2015 Juan Felipe Carrera Moya. All rights reserved.
//

import UIKit
import R3LRackspace

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cloud = CloudFiles(username: "##username##", apiKey: "##ApiKey##", region: .Chicago)
        let bundle = NSBundle.mainBundle()
        let path = bundle.pathForResource("eye", ofType: "jpg")
        if let path = path , let data = NSData(contentsOfFile: path) {
            cloud.putObject(data, name: "eye.jpg", container: "##containerName##") { success in
                
                if success {
                    
                    cloud.getPublicURL("##containerName##", name: "eye.jpg") { urlObject in
                        
                        if let urlObject = urlObject {
                            print("URL: \(urlObject)")
                        }
                        
                    }
                    
                }
                
            }
        }
        
        //cloud.createContainer("jugofresh-test-cdn")
        //cloud.getPublicURL("jugofresh-test-cdn", name:"eye.jpg")
        //cloud.getContainers()
        
        //cloud.enableContainerForCDN("jugofresh-test-cdn")
        //cloud.getPublicContainers()
//        cloud.getPublicURL("jugofresh-JC", name: "testImage.jpg") { urlObject in
//            
//            if let urlObject = urlObject {
//                print(urlObject)
//            }
//            
//        }
        
        //cloud.getContainer("jugofresh-JC")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

