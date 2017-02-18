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

class HexTileProviderTests: XCTestCase {
    
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
    
    func testSubscript() {
        let tilesProvider: HexTileProvider<TestHex>  = HexTileProvider(mapSize: CGSize(width: 4, height: 4), tileSize: 10.0, lazyGeneration: true)
        
        let hex = HexCube(x: 3, y: 0, z: -3, size: 10.0)
        
        XCTAssertNil(tilesProvider[hex])
        
        tilesProvider[hex] = TestHex(hex: hex)
        
        XCTAssertNotNil(tilesProvider[hex])
        
        tilesProvider[hex] = nil
        
        XCTAssertNil(tilesProvider[hex])
    }
    
    func testTileAtHexLazyGerneration() {
        
        let tilesProvider: HexTileProvider<TestHex>  = HexTileProvider(mapSize: CGSize(width: 4, height: 4), tileSize: 10.0, lazyGeneration: true)
        
        let hex = HexCube(x: 3, y: 0, z: -3, size: 10.0)

        XCTAssertNil(tilesProvider.tile(at: hex))
        
        tilesProvider.add(at: hex, element: TestHex(hex: hex))
        XCTAssertNotNil(tilesProvider.tile(at: hex))
    }
    
    func testTileAtPointLazyGerneration() {
        
        let tilesProvider: HexTileProvider<TestHex>  = HexTileProvider(mapSize: CGSize(width: 4, height: 4), tileSize: 10.0, lazyGeneration: true)
        
        let hex = HexCube(x: 1, y: 0, z: -1, size: 10.0)
        
        let point = CGPoint(x: 0, y:-17)

        XCTAssertNil(tilesProvider.tile(at: point).1)
        
        tilesProvider.add(at: hex, element: TestHex(hex: hex))
        XCTAssertNotNil(tilesProvider.tile(at: point))
    }
    
    func testTotalCount() {
        let tilesProvider: HexTileProvider<TestHex>  = HexTileProvider(mapSize: CGSize(width: 4, height: 4), tileSize: 10.0, lazyGeneration: true)
        XCTAssertEqual(tilesProvider.tileTotalCount, 37)
    }
    
    func testProviderSize() {
        let frameSize = CGSize(width: 100, height: 100)
        var tilesProvider: HexTileProvider<TestHex> = HexTileProvider(mapSize: CGSize(width: 4, height: 4), frameSize: frameSize, lazyGeneration: true)
        XCTAssertEqualWithAccuracy(frameSize.width, tilesProvider.size.width, accuracy: 0.001)
        XCTAssertEqualWithAccuracy(tilesProvider.size.height, 89.8100, accuracy: 0.0001)
        
        tilesProvider = HexTileProvider(mapSize: CGSize(width: 4, height: 4), frameSize: frameSize, tileOrientation: .flatTop, lazyGeneration: true)
        XCTAssertEqualWithAccuracy(tilesProvider.size.width, 89.8100, accuracy: 0.001)
        XCTAssertEqualWithAccuracy(tilesProvider.size.height, frameSize.height, accuracy: 0.001)
    }
    
    func testRandomTile() {
        let tilesProvider: HexTileProvider<TestHex> = HexTileProvider(mapSize: CGSize(width: 4, height: 4), tileSize: 10, lazyGeneration: true)
        XCTAssertTrue(tilesProvider.isValid(point: tilesProvider.randomTitle()))
    }
    
    func testMoveTile() {
        let tilesProvider: HexTileProvider<TestHex> = HexTileProvider(mapSize: CGSize(width: 4, height: 4), tileSize: 10, lazyGeneration: true)
        let hex = HexCube(x: 3, y: 0, z: -3, size: 10.0)
        let otherHex = HexCube(x: -3, y: 0, z: 3, size: 10.0)
        
        tilesProvider.add(at: hex, element: TestHex(hex: hex))
        tilesProvider.move(from: hex, to: otherHex)
        
        let tile = tilesProvider.tile(at: otherHex)
        XCTAssertEqual(tile?.hex, hex)
        XCTAssertNil(tilesProvider.tile(at: hex))
    }
    
    func testPath() {

        let tilesProvider: HexTileProvider<TestHex> = HexTileProvider(mapSize: CGSize(width: 3, height: 3), tileSize: 10, lazyGeneration: true)
        
        let path = [HexCube(x: -3, y: 3, z: 0, size: 10.0),
                    HexCube(x: -2, y: 3, z: -1, size: 10.0),
                    HexCube(x: -1, y: 3, z: -2, size: 10.0),
                    HexCube(x: 0, y: 3, z: -3, size: 10.0)]
    
        let providerPath = tilesProvider.path(from: path.first!, to: path.last!)
        XCTAssertEqual(providerPath, path)
    }
}
