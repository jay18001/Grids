//
//  HexTileProvider.swift
//  HexGrids
//
//  Created by Justin Anderson on 2/12/17.
//  Copyright © 2017 Mountain Buffalo Limited. All rights reserved.
//

import Foundation
import CoreGraphics

func randomInt(_ min: Int, _ max: Int) -> Int {
    if min >= 0 {
        return Int(arc4random_uniform(UInt32(abs(max) - min + 1))) + abs(min)
    } else {
        let diff = abs(min)
        return Int(arc4random_uniform(UInt32(abs(max) + diff + 1))) - abs(max) + (abs(max) - diff)
    }
}

public enum HexLayout: String, Codable {
    case hexagon
}

public class HexTileProvider<T> {
    public typealias Element = T
    
    public typealias GenerationElementHandler = ((HexCube) -> Element)
    
    public var tiles: [HexCube: Element]
    public let layout: HexLayout
    public let radius: Int
    public let mapSize: CGSize
    public let tileSize: Double
    public let tileOrientation: HexOrientation
    public let lazyGeneration: Bool
    public var frameSize: CGSize
    
    public var tileTotalCount: Int {
        let radius = self.radius + 1
        return (3 * radius) * (radius - 1) + 1
    }
    
    public var tileCount: Int {
        return tiles.count
    }
    
    public var size: CGSize {
        let width = 2 * (tileSize + (1.5 * tileSize * Double(radius)))
        let height = 2 * (((sqrt(3) * tileSize) / 2) + (sqrt(3) * tileSize * Double(radius)))
        return CGSize(width: tileOrientation == .pointyTop ? height : width, height: tileOrientation == .pointyTop ? width : height)
    }
    
    public convenience init(mapSize: CGSize, frameSize: CGSize, layout: HexLayout = .hexagon, tileOrientation: HexOrientation = .pointyTop, lazyGeneration: Bool = false) {
        let minSize = Double(min(frameSize.width, frameSize.height))
        let tileSize = minSize / (3.squareRoot() * (2 * Double(mapSize.width) + 1))
        
        self.init(mapSize: mapSize, tileSize: tileSize, layout: layout, tileOrientation: tileOrientation, lazyGeneration: lazyGeneration)
        self.frameSize = frameSize
    }
    
    public init(mapSize: CGSize, tileSize: Double, layout: HexLayout = .hexagon, tileOrientation: HexOrientation = .pointyTop, lazyGeneration: Bool = false) {
        
        self.layout = layout
        tiles = [HexCube: Element]()
        self.mapSize = mapSize
        self.radius = Int(mapSize.width)
        self.tileSize = tileSize
        self.tileOrientation = tileOrientation
        self.lazyGeneration = lazyGeneration
        self.frameSize = .zero
    }
    
    public func generate(elementHandler: GenerationElementHandler) {
        guard !lazyGeneration else {
            return
        }
        
        switch layout {
        case .hexagon:
            generateHexagon(elementHandler: elementHandler)
        }
    }
    
    public func randomTitle() -> HexCube {
        let max = radius
        let min = -(radius)
        let random1 = randomInt(min, max)
        
        let random2: Int
        if random1 >= 0 {
            random2 = randomInt(min, max - random1)
        } else {
            random2 = randomInt(min - random1, max)
        }
        
        let tempSum = random1 + random2

        let random3 = 0 - tempSum
        
        if random3 > max || random3 < min {
            fatalError("Something went bad")
        } else {
            return HexCube(x: random1, y: random2, z: random3, size: tileSize, orientation: tileOrientation)
        }
    }
    
    public func tile(at pixel: CGPoint) -> (HexCube, Element?) {
        let hex = HexCube(pixel: pixel, size: tileSize, orientation: tileOrientation)
        return (hex, tiles[hex])
    }
    
    public func tile(at hex: HexCube) -> Element? {
        return tiles[hex]
    }
    
    public subscript(key: HexCube) -> Element? {
        
        get {
            return tiles[key]
        }
        
        set {
            if let value = newValue {
                self.add(at: key, element: value)
            } else {
                self.move(from: key, to: nil)
            }
        }
    }
    
    public func add(at hex: HexCube, element: Element) {
        guard checkBounds(for: hex) else {
            return
        }
        
        tiles[hex] = element
    }
    
    public func isValid(point: HexCube) -> Bool {
        return checkBounds(for: point)
    }
    
    private func checkBounds(for hex: HexCube) -> Bool {
        return (abs(hex.x) < (self.radius+1)) &&
                (abs(hex.y) < (self.radius+1)) &&
                (abs(hex.z) < (self.radius+1)) &&
                hex.x + hex.y + hex.z == 0
    }
    
    private func generateHexagon(elementHandler: GenerationElementHandler) {
        let center = HexCube(x: 0, y: 0, z: 0, size: tileSize, orientation: tileOrientation)
        for dx in -radius...radius {
            let r1 = max(-radius, -dx - radius)
            let r2 = min(radius, -dx + radius)
            for dy in r1...r2 {
                let hex = center + HexCube(x: dx, y: dy, z: -dx-dy, size: tileSize, orientation: tileOrientation)
                let value = elementHandler(hex)
                tiles[hex] = value
            }
        }
    }
    
    public func move(from: HexCube, to: HexCube?) {
        if from == to {
            return
        }
        
        guard let fromValue = tiles.removeValue(forKey: from) else {
            return
        }
        
        if let destination = to {
            tiles[destination] = fromValue
        }
    }

    public func path(from start: HexCube, to end: HexCube) -> [HexCube] {
        
        func cubeLerp(a: HexCube, b: HexCube, t: Double) -> (x: Double, y: Double, z: Double) { // for hexes
            func lerp(a: Int, b: Int, t: Double) -> Double { // for floats
                return Double(a) + Double(b - a) * t
            }
            
            return (lerp(a: a.x, b: b.x, t: t),
                    lerp(a: a.y, b: b.y, t: t),
                    lerp(a: a.z, b: b.z, t: t))
        }
        
        let distance = Int(start.distance(to: end))
        var results = [HexCube]()
        
        for i in 0...distance {
            let roundedPoints = HexCube.round(values: cubeLerp(a: start, b: end, t: 1.0/Double(distance) * Double(i)))
            results.append(HexCube(x: roundedPoints.x, y: roundedPoints.y, z: roundedPoints.z, size: self.tileSize, orientation: tileOrientation))
        }
        
        return results
    }
    
    public func empty() {
        self.tiles = [:]
    }
}
