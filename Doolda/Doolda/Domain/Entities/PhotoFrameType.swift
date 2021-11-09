//
//  PhotoFrameType.swift
//  Doolda
//
//  Created by Seunghun Yang on 2021/11/09.
//

import CoreImage
import Foundation

struct PhotoFrameType {
    let baseImage: CIImage
    let photoBounds: [CGRect]
    var requiredPhotoCount: Int { photoBounds.count }
    
    init?(baseImage: CIImage?, photoBounds: [CGRect]) {
        guard let baseImage = baseImage else { return nil }
        self.baseImage = baseImage
        self.photoBounds = photoBounds
    }
    
    static let allCases: [PhotoFrameType] = []
}
