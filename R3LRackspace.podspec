Pod::Spec.new do |s|

    s.name             = "R3LRackspace"
    s.version          = "0.1.9"
    s.summary          = "iOS SDK Rackspace in swift"
    s.description      = "iOS SDK Rackspace in swift to handle CloudFiles"
    s.homepage         = "https://github.com/felipecarreramo/R3LRackspace"
    s.license          = 'MIT'
    s.author           = { "Juan Felipe Carrera Moya" => "pipecamo@gmail.com" }
    s.source           = { :git => "https://github.com/felipecarreramo/R3LRackspace.git", :tag => s.version.to_s }

    s.platform     = :ios, '8.0'
    s.requires_arc = true

    s.source_files = 'Pod/Classes/**/*'
    s.resource_bundles = {
        'R3LRackspace' => ['Pod/Assets/*.png']
    }

    s.dependency 'Alamofire'

end
