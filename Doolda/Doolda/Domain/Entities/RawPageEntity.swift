//
//  RawPageEntity.swift
//  Doolda
//
//  Created by 정지승 on 2021/11/04.
//

import CoreGraphics
import Foundation

enum ComponentType: String, Codable {
    case base, photo, sticker, text
}

struct RawPageEntity: Codable {
    var components: [ComponentEntity]
    var backgroundType: BackgroundType
    
    enum CodingKeys: String, CodingKey {
        case components, backgroundType
    }
    
    enum ComponentTypeKey: CodingKey {
        case type
    }
    
    enum Errors: LocalizedError {
        case encounteredUnknonwnComponent
        
        var errorDescription: String? {
            switch self {
            case .encounteredUnknonwnComponent:
                return "알 수 없는 컴포넌트 타입이 포함되어있습니다."
            }
        }
    }
    
    init() {
        self.components = []
        self.backgroundType = .dooldaBackground
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        var componentsContainer = try container.nestedUnkeyedContainer(forKey: CodingKeys.components)
        var typeKeyContainer = componentsContainer
        self.backgroundType = try container.decode(BackgroundType.self, forKey: CodingKeys.backgroundType)
        var components: [ComponentEntity] = []
        
        while !(typeKeyContainer.isAtEnd && componentsContainer.isAtEnd) {
            let componentType = try typeKeyContainer
                .nestedContainer(keyedBy: ComponentTypeKey.self)
                .decode(ComponentType.self, forKey: ComponentTypeKey.type)
            switch componentType {
            case .photo: components.append(try componentsContainer.decode(PhotoComponentEntity.self))
            case .sticker: components.append(try componentsContainer.decode(StickerComponentEntity.self))
            case .text: components.append(try componentsContainer.decode(TextComponentEntity.self))
            default: throw RawPageEntity.Errors.encounteredUnknonwnComponent
            }
        }
        self.components = components
    }
    
    mutating func append(component: ComponentEntity) {
        self.components.append(component)
    }
    
    mutating func remove(at index: Int) {
        self.components.remove(at: index)
    }
    
    func indexOf(component: ComponentEntity) -> Int? {
        return self.components.firstIndex(of: component)
    }
}
