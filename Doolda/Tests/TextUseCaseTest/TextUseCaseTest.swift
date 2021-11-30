//
//  TextUseCaseTest.swift
//  TextUseCaseTest
//
//  Created by 김민주 on 2021/11/30.
//

import XCTest

class TextUseCaseTest: XCTestCase {

    func testGetTextComponent() {
        let textUseCase = TextUseCase()
        let targetText: String = "dummy"
        let targetSize: CGSize = .zero
        let targetOrigin = CGPoint(x: 850 - targetSize.width/2, y: 1500 - targetSize.height/2)
        let targetFontSize: CGFloat = .zero
        let targetColor: FontColorType = .black
        let targetTextComponent = TextComponentEntity(
            frame: CGRect(origin: targetOrigin, size: targetSize),
            scale: 1.0,
            angle: 0,
            aspectRatio: 1,
            text: targetText,
            fontSize: targetFontSize,
            fontColor: targetColor
        )

        let result = textUseCase.getTextComponent(
            with: targetText,
            contentSize: targetSize,
            fontSize: targetFontSize,
            color: targetColor
        )
        
        XCTAssertEqual(targetText, result.text)
        XCTAssertEqual(targetSize, result.frame.size)
        XCTAssertEqual(targetOrigin, result.frame.origin)
        XCTAssertEqual(targetFontSize, result.fontSize)
        XCTAssertEqual(targetColor, result.fontColor)
        
        XCTAssertNotEqual(targetTextComponent, result)
    }
    
    func testChangeTextComponent() {
        let textUseCase = TextUseCase()
        let targetTextComponent = TextComponentEntity(
            frame: CGRect(origin: .zero, size: .zero),
            scale: 1.0,
            angle: 0,
            aspectRatio: 1,
            text: "dummy",
            fontSize: .zero,
            fontColor: .black
        )
        
        let targetText: String = "changedummy"
        let targetSize: CGSize = CGSize(width: 100, height: 100)
        let targetFontSize: CGFloat = 16
        let targetColor: FontColorType = .purple

        let result = textUseCase.changeTextComponent(
            from: targetTextComponent,
            with: targetText,
            contentSize: targetSize,
            fontSize: targetFontSize,
            color: targetColor
        )
        
        XCTAssertEqual(targetTextComponent, result)
        XCTAssertEqual(targetText, result.text)
        XCTAssertEqual(targetSize, result.frame.size)
        XCTAssertEqual(targetFontSize, result.fontSize)
        XCTAssertEqual(targetColor, result.fontColor)
    }
}
