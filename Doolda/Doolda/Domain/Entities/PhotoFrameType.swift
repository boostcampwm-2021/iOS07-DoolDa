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
    typealias RawValue = PhotoFrame?
    
    case normal
    case polaroid
    case lifeFourCuts
    
    init?(rawValue: RawValue) {
        self = .lifeFourCuts
    }
    
    var rawValue: PhotoFrame? {
        switch self {
        case .normal: return PhotoFrame.normal
        case .polaroid: return PhotoFrame.polaroid
        case .lifeFourCuts: return PhotoFrame.lifeFourCuts
        }
    }
}

struct PhotoFrame {
    let displayName: String
    let baseImage: CIImage
    let photoBounds: [CGRect]
    var requiredPhotoCount: Int { photoBounds.count }
    
    init?(displayName: String, baseImageName: String?, photoBounds: [CGRect]) {
        guard let baseImageUrl = Bundle.main.url(forResource: baseImageName, withExtension: "jpg"),
              let baseCIImage = CIImage(contentsOf: baseImageUrl) else { return nil }
        self.displayName = displayName
        self.baseImage = baseCIImage
        self.photoBounds = photoBounds
    }
    
    static let normal = PhotoFrame(displayName: "일반 사진", baseImageName: "Normal", photoBounds: [.zero])
    static let polaroid = PhotoFrame(displayName: "폴라로이드", baseImageName: "Polaroid", photoBounds: [.zero])
    static let lifeFourCuts = PhotoFrame(displayName: "인생 네컷", baseImageName: "LifeFourCuts", photoBounds: [.zero, .zero, .zero, .zero])
}
