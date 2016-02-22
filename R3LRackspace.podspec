Pod::Spec.new do |s|

    s.name             = "R3LRackspace"
    s.version          = "0.1.10"
    s.summary          = "iOS SDK Rackspace in swift"
    s.description      = "iOS SDK Rackspace in swift to handle CloudFiles"
    s.homepage         = "https://bitbucket.org/rokk3rlabs/cobuild-rackspace-ios-pod"
    s.license          = 'MIT'
    s.author           = { "Juan Felipe Carrera Moya" => "juan.carrera@rokk3rlabs.com" }
    s.source           = { :git => "https://bitbucket.org/rokk3rlabs/cobuild-rackspace-ios-pod", :tag => s.version.to_s }

    s.platform     = :ios, '8.0'
    s.requires_arc = true

    s.source_files = 'Pod/Classes/**/*'
    s.resource_bundles = {
        'R3LRackspace' => ['Pod/Assets/*.png']
    }

    s.dependency 'Alamofire', '~> 3.1.5'

end
