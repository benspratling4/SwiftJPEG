//
//  File.swift
//  
//
//  Created by Ben Spratling on 5/10/20.
//

import Foundation


public enum BaselineStartOfFrameTableError : Error {
	case reachedEndOfTableUnexpectedly
	case unrecognizedFormat
}

public struct BaselineStartOfFrameTable {
	
	public var precision:Int
	public var verticalLines:Int
	public var horizontalLines:Int
	public var componentCount:Int
	public var componentDesignations:[SubsamplingQuantizationDesignation]
	
	public init(segment:Segment)throws {
		guard segment.data.count > 6 else {
			throw BaselineStartOfFrameTableError.reachedEndOfTableUnexpectedly
		}
		precision = Int(segment.data[0])
		let vLinesHighByte = UInt16(segment.data[1]) << 8
		let vLinesLowByte = UInt16(segment.data[2])
		verticalLines = Int(vLinesHighByte | vLinesLowByte)
		let hLinesHighByte = UInt16(segment.data[3]) << 8
		let hLinesLowByte = UInt16(segment.data[4])
		horizontalLines = Int(hLinesHighByte | hLinesLowByte)
		componentCount = Int(segment.data[5])
		guard segment.data.count > componentCount * 3 + 6 else {
			throw BaselineStartOfFrameTableError.reachedEndOfTableUnexpectedly
		}
		componentDesignations =  try (0..<componentCount).map({ try SubsamplingQuantizationDesignation(data: segment.data, offset: 6 + 3 * $0) })
	}
	
}


public struct SubsamplingQuantizationDesignation {
	public var componentIndex:Int
	public var subsampling:SubSampling
	public var quantizationDesignation:UInt8
	
	public init(data:Data, offset:Int)throws {
		componentIndex = Int(data[offset])
		let subsamplingByte:UInt8 = data[offset+1]
		let h:UInt8 = subsamplingByte & 0xF0
		guard h == 2 else {
			throw BaselineStartOfFrameTableError.unrecognizedFormat
		}
		let v:UInt8 = subsamplingByte & 0x0F
		switch v {
		case 1:
			subsampling = .ss422
		case 2:
			subsampling = .ss420
		default:
			throw BaselineStartOfFrameTableError.unrecognizedFormat
		}
		quantizationDesignation = data[offset+2]
	}
	
	public init(componentIndex:Int, subsampling:SubSampling, quantizationDesignation:UInt8) {
		self.componentIndex = componentIndex
		self.subsampling = subsampling
		self.quantizationDesignation = quantizationDesignation
	}
}
