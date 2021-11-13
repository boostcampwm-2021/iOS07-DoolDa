//
//  PhotoComponentEntity.swift
//  Doolda
//
//  Created by Dozzing on 2021/11/07.
//

import CoreGraphics
import Foundation

class PhotoComponentEntity: ComponentEntity {
    var imageUrl: URL

    private enum CodingKeys: String, CodingKey {
        case imageUrl
    }
    
    init(frame: CGRect, scale: CGFloat, angle: CGFloat, aspectRatio: CGFloat, imageUrl: URL) {
        self.imageUrl = imageUrl
        super.init(frame: frame, scale: scale, angle: angle, aspectRatio: aspectRatio)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let superdecoder = try container.superDecoder()
        self.imageUrl = try container.decode(URL.self, forKey: .imageUrl)
        try super.init(from: superdecoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(imageUrl, forKey: .imageUrl)
        let superEncoder = container.superEncoder()
        try super.encode(to: superEncoder)
    }
}
