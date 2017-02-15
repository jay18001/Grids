//
//  Hex.swift
//  HexGrids
//
//  Created by Justin Anderson on 2/12/17.
//  Copyright © 2017 Mountain Buffalo Limited. All rights reserved.
//

import Foundation

func +(lhs: HexCube, rhs: HexCube) -> HexCube {
    return HexCube(x: lhs.x + rhs.x, y: lhs.y + rhs.y, z: lhs.z + rhs.z, size: lhs.size, orientation: lhs.orientation)
}

public func ==(lhs: HexCube, rhs: HexCube) -> Bool {
    return (lhs.x == rhs.x &&
        lhs.y == rhs.y &&
        lhs.z == rhs.z &&
        lhs.orientation == rhs.orientation &&
        lhs.size == rhs.size)
}

public enum HexOrientation {
    case flatTop
    case pointyTop
}

public enum HexDirection {
    case top
    case topLeft
    case topRight
    case bottom
    case bottomLeft
    case bottomRight
    case left
    case right
    
    public init?(angle : Double, orientation: HexOrientation) {
        if orientation == .pointyTop {
            switch angle {
            case 0.0..<60:
                self = .topRight
            case 60.0..<120:
                self = .right
            case 120.0..<180:
                self = .bottomRight
            case 180.0..<240:
                self = .bottomLeft
            case 240.0..<300:
                self = .left
            case 300.0..<360:
                self = .topLeft
            default:
                return nil
            }
        } else {
            switch angle {
            case 0..<30, 330...360:
                self = .top
            case 30..<90:
                self = .topRight
            case 90..<150:
                self = .bottomRight
            case 150..<210:
                self = .bottom
            case 210..<270:
                self = .bottomLeft
            case 270..<330:
                self = .topLeft
            default:
                return nil
            }
        }
    }
    
    
    public var inverse: HexDirection {
        switch self {
        case .top:
            return .bottom
        case .topLeft:
            return .bottomRight
        case .topRight:
            return .bottomLeft
        case .bottom:
            return .top
        case .bottomLeft:
            return .topRight
        case .bottomRight:
            return .topLeft
        case .left:
            return .right
        case .right:
            return .left
        }
    }
    
}

public struct HexCube: Hashable {
    public let x: Int
    public let y: Int
    public let z: Int
    public let orientation: HexOrientation
    public let size: Double
    
    public var hashValue: Int {
        return "\(self.x),\(self.y),\(self.z),\(self.orientation),\(self.size)".hashValue
    }
    
    
    var q: Int {
        return self.x
    }
    
    var r: Int {
        return self.z
    }
    
    public init(point: CGPoint, size: Double, orientation: HexOrientation = .pointyTop) {
        self.init(x: Int(point.x), y: Int(-point.x-point.y), z: Int(point.y), size: size, orientation: orientation)
    }
    
    public init(x: Int, y: Int, z: Int, size: Double, orientation: HexOrientation = .pointyTop) {
        self.x = x
        self.y = y
        self.z = z
        self.orientation = orientation
        self.size = size
    }
    
    public init(pixel: CGPoint, size: Double, orientation: HexOrientation = .pointyTop) {
        let q = (Double(pixel.x) * sqrt(3)/3 - Double(-pixel.y) / 3) / size
        let r = Double(-pixel.y) * 2/3 / size
        
        let hexPoints = HexCube.round(x: q, y: -q-r, z: r)
        
        self.init(x: hexPoints.x, y: hexPoints.y, z: hexPoints.z, size: size, orientation: orientation)
    }
    
    public func distance(to other: HexCube) -> Double {
        let x = Double(self.x - other.x)
        let y = Double(self.y - other.y)
        let z = Double(self.z - other.z)
        return (abs(x) + abs(y) + abs(z)) / 2.0
    }
    
    
    public var pixel: CGPoint {
        //Negitive y because the axis on the iPhone is upside down
        if orientation == .pointyTop {
            let x = self.size * sqrt(3) * (Double(self.q) + Double(self.r) / 2.0)
            let y = self.size * (3.0 / 2.0) * Double(self.r)
            return CGPoint(x: x, y: -y)
        } else {
            let x = size * (3.0 / 2.0) * Double(self.q)
            let y = size * sqrt(3) * (Double(self.r) + Double(self.q) / 2.0)
            return CGPoint(x: x, y: -y)
        }
    }

    public func next(for direction: HexDirection) -> HexCube {
        let size = self.size
        let orientation = self.orientation
        
        if self.orientation == .pointyTop {
            switch direction {
            case .topLeft:
                return HexCube(x: self.x, y: self.y + 1, z: self.z - 1, size: size, orientation: orientation)
            case .topRight:
                return HexCube(x: self.x + 1, y: self.y, z: self.z - 1, size: size, orientation: orientation)
            case .right:
                return HexCube(x: self.x + 1, y: self.y - 1, z: self.z, size: size, orientation: orientation)
            case .bottomRight:
                return HexCube(x: self.x, y: self.y - 1, z: self.z + 1, size: size, orientation: orientation)
            case .bottomLeft:
                return HexCube(x: self.x - 1, y: self.y, z: self.z + 1, size: size, orientation: orientation)
            case .left:
                return HexCube(x: self.x - 1, y: self.y + 1, z: self.z, size: size, orientation: orientation)
            default:
                fatalError("Unsupported Type")
            }
        } else {
            switch direction {
            case .topLeft:
                return HexCube(x: self.x - 1, y: self.y + 1, z: self.z, size: size, orientation: orientation)
            case .top:
                return HexCube(x: self.x, y: self.y + 1, z: self.z - 1, size: size, orientation: orientation)
            case .topRight:
                return HexCube(x: self.x + 1, y: self.y, z: self.z - 1, size: size, orientation: orientation)
            case .bottomRight:
                return HexCube(x: self.x + 1, y: self.y - 1, z: self.z, size: size, orientation: orientation)
            case .bottom:
                return HexCube(x: self.x, y: self.y - 1, z: self.z + 1, size: size, orientation: orientation)
            case .bottomLeft:
                return HexCube(x: self.x - 1, y: self.y, z: self.z + 1, size: size, orientation: orientation)
            default:
                fatalError("Unsupported Type")
            }
        }

        
    }
    
    public func rotate(left: Bool) -> HexCube {
        if left {
            return HexCube(x: -self.y, y: -self.z, z: -self.x, size: self.size, orientation: self.orientation)
        } else {
            return HexCube(x: -self.z, y: -self.x, z: -self.y, size: self.size, orientation: self.orientation)
        }
    }
    
    
    static func round(values: (x :Double, y: Double, z: Double)) -> (x: Int, y: Int, z: Int) {
        return round(x: values.x, y: values.y, z: values.z)
    }
    
    static func round(x: Double, y: Double, z: Double) -> (x: Int, y: Int, z: Int) {
        var rx = Darwin.round(x)
        var ry = Darwin.round(y)
        var rz = Darwin.round(z)
        
        let x_diff = abs(rx - x)
        let y_diff = abs(ry - y)
        let z_diff = abs(rz - z)
        
        if x_diff > y_diff && x_diff > z_diff {
            rx = -ry-rz
        } else if y_diff > z_diff {
            ry = -rx-rz
        } else {
            rz = -rx-ry
        }
        
        return (x: Int(rx), y: Int(ry), z: Int(rz))
    }
}
