//
//  PhotoFrameType.swift
//  Doolda
//
//  Created by Seunghun Yang on 2021/11/09.
//

import CoreImage
import Foundation

enum PhotoFrameType: RawRepresentable, CaseIterable {
    struct PhotoFrame {
        let baseImage: CIImage
        let photoBounds: [CGRect]
        var requiredPhotoCount: Int { photoBounds.count }
        
        init?(baseImage: CIImage?, photoBounds: [CGRect]) {
            guard let baseImage = baseImage else { return nil }
            self.baseImage = baseImage
            self.photoBounds = photoBounds
        }
        
        // FIXME: 프레임들을 여기에 static let으로 선언
        static let lifeFourCuts = PhotoFrame(baseImage: nil, photoBounds: [.zero])
    }
    
    typealias RawValue = PhotoFrame?
    
    case lifeFourCuts
    
    init?(rawValue: RawValue) {
        self = .lifeFourCuts
    }
    
    // FIXME: PhotoFrame내에 선언된 static let인스턴스를 rawValue로 제공
    var rawValue: PhotoFrame? {
        switch self {
        case .lifeFourCuts: return PhotoFrame.lifeFourCuts
        }
    }
}
