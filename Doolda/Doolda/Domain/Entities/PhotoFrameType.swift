//
//  PhotoFrameType.swift
//  Doolda
//
//  Created by Seunghun Yang on 2021/11/09.
//

import CoreImage
import CoreGraphics
import Foundation

enum PhotoFrameType: RawRepresentable, CaseIterable {
    struct PhotoFrame {
        let baseImage: CIImage
        let photoBounds: [CGRect]
        var requiredPhotoCount: Int { photoBounds.count }
        
        init?(baseImageName: String?, photoBounds: [CGRect]) {
            guard let baseImageUrl = Bundle.main.url(forResource: baseImageName, withExtension: "png"),
                  let baseCIImage = CIImage(contentsOf: baseImageUrl) else { return nil }
            self.baseImage = baseCIImage
            self.photoBounds = photoBounds
        }
        
        // FIXME: 프레임들을 여기에 static let으로 선언
        static let normal = PhotoFrame(baseImageName: "Normal", photoBounds: [.zero])
        static let polaroid = PhotoFrame(baseImageName: "Polaroid", photoBounds: [.zero])
        static let lifeFourCuts = PhotoFrame(baseImageName: "LifeFourCuts", photoBounds: [.zero, .zero, .zero, .zero])
    }
    
    typealias RawValue = PhotoFrame?
    
    case normal
    case polaroid
    case lifeFourCuts
    
    init?(rawValue: RawValue) {
        self = .lifeFourCuts
    }
    
    // FIXME: PhotoFrame내에 선언된 static let인스턴스를 rawValue로 제공
    var rawValue: PhotoFrame? {
        switch self {
        case .normal: return PhotoFrame.normal
        case .polaroid: return PhotoFrame.polaroid
        case .lifeFourCuts: return PhotoFrame.lifeFourCuts
        }
    }
}
