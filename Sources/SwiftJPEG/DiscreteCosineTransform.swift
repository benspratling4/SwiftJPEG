//
//  DiscreteCosineTransform.swift
//  
//
//  Created by Ben Spratling on 5/10/20.
//

import Foundation


extension Array where Element == Float {
	
	//index a cosine function from 0 = 0π to 32 = 2 π
	//not sure this is rih
	internal init(discreteCosineCount:Int) {
		self = (0...discreteCosineCount).map({ cos( Element($0) * 2.0 * Element.pi / Element(discreteCosineCount))})
	}
	
}

let sixteenthCosine:[Float] = [Float](discreteCosineCount: 32)
let oneOverSqrtTwo:Float = 1.0/sqrt(2.0)

func normalizingScaleFactor(u:Int)->Float {
	switch u {
	case 0:
		return oneOverSqrtTwo
	default:
		return 1
	}
}

extension Array where Element == Float {
	
	internal init(DCTGridHorizontalSpatialFrequency u:Int, verticalSpatialFrequency v:Int) {
		self.init(repeating: 0.0, count: 64)
		
		for x in 0..<8 {
			for y in 0..<8 {
				let xCos = sixteenthCosine[((2*x+1)*u)%32]
				let yCos = sixteenthCosine[((2*y+1)*v)%32]
				
				self[y*8+x] = xCos * yCos// * normalizingScaleFactor(u:u) * normalizingScaleFactor(u:v) / 4.0
			}
		}
	}
	
}

internal let allDCTs:[[[Float]]] = (0..<8).map { u in
	(0..<8).map { v in
		return [Float](DCTGridHorizontalSpatialFrequency: u, verticalSpatialFrequency: v)
	}
}


//must be 8x8 block each element in the range 0...255
extension Array where Element == UInt8 {
	
	///self must be 64 count
	internal func getDCTSpatialCoefficients()->[Float] {
		let selfOffsetFloats:[Float] = map({ Float($0)-128.0})
		var finalFloats:[Float] = [Float](repeating: 0.0, count: 64)
		for i in 0..<64 {
			let v = i/8
			let u = i%8
			//multiply the original self data times the
			let multiplied:Float = allDCTs[u][v]
				.enumerated()
				.map({ (i, dct) -> Float in
					return selfOffsetFloats[i] * dct
				})
				.reduce(0.0, +)
					* normalizingScaleFactor(u:u) * normalizingScaleFactor(u:v) / 4.0
			finalFloats[i] = multiplied
		}
		return finalFloats
	}
	
	//array must be 64 in count
	internal init(DCTSpatialSpatialCoefficients g:[Float]) {
		var finalFloats:[Float] = [Float](repeating: 0.0, count: 64)
		for i in 0..<64 {
			for u in 0..<8 {
				for v in 0..<8 {
					finalFloats[i] += allDCTs[u][v][i] * g[v*8+u] * normalizingScaleFactor(u:u) * normalizingScaleFactor(u:v) / 4.0
				}
			}
		}
		self = finalFloats.map({ UInt8(clamping: Int($0.rounded() + 128)) })
	}
	
}
