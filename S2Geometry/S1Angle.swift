//
//  S1Angle.swift
//  S2Geometry
//
//  Created by Alex Studnicka on 7/1/16.
//  Copyright © 2016 Alex Studnicka. MIT License.
//

#if os(Linux)
	import Glibc
#else
	import Darwin.C
#endif

public struct S1Angle: Equatable, Comparable {
	
	public let radians: Double
	
	public var degrees: Double {
		return radians * (180 / M_PI)
	}
	
	private func getInteger(multipliedBy m: Double) -> Int64 {
		return Int64(round(degrees * m))
	}
	
	public var e5: Int64 { return getInteger(multipliedBy: 1e5) }
	public var e6: Int64 { return getInteger(multipliedBy: 1e6) }
	public var e7: Int64 { return getInteger(multipliedBy: 1e7) }
	
	public init(radians: Double = 0) {
		self.radians = radians
	}
	
	public init(degrees: Double) {
		self.radians = degrees * (M_PI / 180)
	}
	
}

public func ==(lhs: S1Angle, rhs: S1Angle) -> Bool {
	return lhs.radians == rhs.radians
}

public func <(lhs: S1Angle, rhs: S1Angle) -> Bool {
	return lhs.radians < rhs.radians
}

public func +(lhs: S1Angle, rhs: S1Angle) -> S1Angle {
	return S1Angle(radians: lhs.radians + rhs.radians)
}

public func -(lhs: S1Angle, rhs: S1Angle) -> S1Angle {
	return S1Angle(radians: lhs.radians - rhs.radians)
}

public func *(lhs: S1Angle, rhs: S1Angle) -> S1Angle {
	return S1Angle(radians: lhs.radians * rhs.radians)
}
