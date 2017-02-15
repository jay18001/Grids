//
//  HexGridsTests.swift
//  HexGridsTests
//
//  Created by Justin Anderson on 2/12/17.
//  Copyright © 2017 Mountain Buffalo Limited. All rights reserved.
//

import XCTest
@testable import HexGrids

struct TestHex {
    let hex: HexCube
    
    init(hex: HexCube) {
        self.hex = hex
    }
}

class HexGridsTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testTileAtHex() {
        
        let tilesProvider: HexTileProvider<TestHex>  = HexTileProvider(mapSize: CGSize(width: 4, height: 4), tileSize: 10.0)
        
        tilesProvider.generate { (hex) -> TestHex in
            print(hex.x, hex.y, hex.z)
            return TestHex(hex: hex)
        }
        
        let hex = HexCube(x: 0, y: 0, z: 0, size: 10.0)
        
        let textHex = tilesProvider.tile(at: hex)?.hex
        
        XCTAssertEqual(hex, textHex)
    }
    
    func testTileAtPoint() {
        let tilesProvider: HexTileProvider<TestHex>  = HexTileProvider(mapSize: CGSize(width: 4, height: 4), tileSize: 10.0)
        
        tilesProvider.generate { (hex) -> TestHex in
            print(hex.x, hex.y, hex.z)
            return TestHex(hex: hex)
        }
        
        let hex = HexCube(x: 1, y: 0, z: -1, size: 10.0)
        
        let point = CGPoint(x: 0, y:17)
        let (textHex, _) = tilesProvider.tile(at: point)
        
        XCTAssertEqual(hex, textHex)
        XCTAssertEqual(hex.pixel, textHex.pixel)
    }
    
    func testTileAtHexLazyGerneration() {
        
        let tilesProvider: HexTileProvider<TestHex>  = HexTileProvider(mapSize: CGSize(width: 4, height: 4), tileSize: 10.0, lazyGeneration: true)
        
        tilesProvider.generate { (hex) -> TestHex in
            return TestHex(hex: hex)
        }
        
        let hex = HexCube(x: 3, y: 0, z: -3, size: 10.0)
        
        let textHex = tilesProvider.tile(at: hex)
        
        XCTAssertNil(textHex)
        
        tilesProvider.add(at: hex, element: TestHex(hex: hex))
        XCTAssertNotNil(tilesProvider.tile(at: hex))
    }
    
    func testTileAtPointLazyGerneration() {
        
        let tilesProvider: HexTileProvider<TestHex>  = HexTileProvider(mapSize: CGSize(width: 4, height: 4), tileSize: 10.0, lazyGeneration: true)
        
        tilesProvider.generate { (hex) -> TestHex in
            return TestHex(hex: hex)
        }
        
        let hex = HexCube(x: 1, y: 0, z: -1, size: 10.0)
        
        let point = CGPoint(x: 0, y:-17)
        let (_, textHex) = tilesProvider.tile(at: point)
        
        XCTAssertNil(textHex)
        
        tilesProvider.add(at: hex, element: TestHex(hex: hex))
        XCTAssertNotNil(tilesProvider.tile(at: point))
    }
    
    func testTotalCount() {
        let tilesProvider: HexTileProvider<TestHex>  = HexTileProvider(mapSize: CGSize(width: 4, height: 4), tileSize: 10.0, lazyGeneration: true)
        XCTAssertEqual(tilesProvider.tileTotalCount, 61)
    }
}
