//
//  File.swift
//  
//
//  Created by Ben Spratling on 5/9/20.
//

import Foundation

//https://www.w3.org/Graphics/JPEG/jfif3.pdf

public enum JpegFileError : Error {
	case invalidFormat
	case unexpectedEndOfFile
	case unknownMarker(/*marker*/UInt8, /*index*/Int)
}


public struct Segment {
	public var marker:Marker
	public var data:Data
	public var entropyCoded:Data?
	public init(marker:Marker, data:Data, entropyCoded:Data? = nil) {
		self.marker = marker
		self.data = data
		self.entropyCoded = entropyCoded
	}
}


extension Data {
	
	public func jpegSegments()throws->[Segment] {
		var segments:[Segment] = []
		
		var index:Int = 0
		repeat {
			let (entrophyDataOrNil, nextMarkerIndexOrNil) = entrophyEncodedDataAndNextMarkerIndex(atOrAfter:index)
			if let entrophyData:Data = entrophyDataOrNil, segments.count > 0 {
				segments[segments.count-1].entropyCoded = entrophyData
			}
			guard let markerIndex:Int = nextMarkerIndexOrNil else { break }
			index = markerIndex
			//read the marker type
			guard let marker:Marker = Marker(byte: self[markerIndex]) else {
				throw JpegFileError.unknownMarker(self[markerIndex], markerIndex)
			}
			//read the length
			let length:Int = try lengthOfSegment(marker: marker, at: markerIndex+1)
			//read the payload
			let payloadBeginsAfterLengthBytes:Bool = marker.fixedLength == nil
			index = markerIndex + 1 + length
			let dataStartWithoutLengthBytes:Int = markerIndex + 1 + (payloadBeginsAfterLengthBytes ? 2 : 0)
			let dataEndWithoutLengthBytes:Int = dataStartWithoutLengthBytes + (payloadBeginsAfterLengthBytes ? length - 2  : length )
			guard dataEndWithoutLengthBytes <= count else {
				throw JpegFileError.unexpectedEndOfFile
			}
			let segmentPayload:Data = self[dataStartWithoutLengthBytes..<dataEndWithoutLengthBytes]
			segments.append(Segment(marker: marker, data: segmentPayload, entropyCoded: nil))
			index = dataEndWithoutLengthBytes
		} while index < count
		
		return segments
	}
	
	/*
	public init(segments:[Segment]) {
		//TODO: write me
		//insert length uint16 where appropriate, and insert 0x00 as needed to rpevent confusion of 0xff as segment markers
	}
	*/
}


extension Data {
	
	func entrophyEncodedDataAndNextMarkerIndex(atOrAfter index:Int)->(Data?, Int?) {
		guard index < count else { return (nil, nil) }
		var entrophyCodedBytes:[UInt8] = []
		var previousByteWasFF:Bool = false
		func wrappedUpData()->Data? {
			return entrophyCodedBytes.count > 0 ? Data(entrophyCodedBytes) : nil
		}
		for i in index..<count {
			let byte:UInt8 = self[i]
			if previousByteWasFF {
				if byte == 0x00 {
					entrophyCodedBytes.append(0xFF)
					previousByteWasFF = false
					continue
				} else if byte == 0xFF {
					previousByteWasFF = true
					//previous byte was valid (or is this padding?)
					entrophyCodedBytes.append(0xFF)
					continue
				} else {
					return (wrappedUpData(), i)
				}
			}
			if byte == 0xFF {
				previousByteWasFF = true
			} else {
				previousByteWasFF = false
				entrophyCodedBytes.append(byte)
			}
		}
		return (wrappedUpData(), nil)
	}
	
	
	func lengthOfSegment(marker:Marker, at index:Int)throws->Int {
		if let fixedSize = marker.fixedLength {
			return fixedSize
		}
		guard index + 1 < count else {
			throw JpegFileError.unexpectedEndOfFile
		}
		//read 2 bytes
		let highByte:UInt16 = UInt16(self[index + 0]) << 8
		let lowByte:UInt16 = UInt16(self[index + 1])
		return Int(highByte | lowByte)
	}
	
}
