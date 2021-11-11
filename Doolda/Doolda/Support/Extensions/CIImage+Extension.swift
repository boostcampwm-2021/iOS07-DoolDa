//
//  CIImage+Extension.swift
//  Doolda
//
//  Created by Dozzing on 2021/11/11.
//

import CoreImage
import Foundation

extension CIImage {
    var data: Data? {
        let ciContext = CIContext()
        guard let colorSpace = CGColorSpace(name: CGColorSpace.sRGB),
              let imageData = ciContext.jpegRepresentation(of: self, colorSpace: colorSpace, options: [:]) else {
                  return nil
              }
        return imageData
    }
}
