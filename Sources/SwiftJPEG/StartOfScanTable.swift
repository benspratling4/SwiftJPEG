//
//  StartOfScanTable.swift
//  
//
//  Created by Ben Spratling on 5/10/20.
//

import Foundation





struct StartOfScanTable {
	
	var componentsInScan:Int
	
	public init(segment:Segment)throws {
		guard segment.data.count > 1 else {
			throw BaselineStartOfFrameTableError.reachedEndOfTableUnexpectedly
		}
		componentsInScan = Int(segment.data[0])
		//TODO: write me
	}
	
	
	
	struct Selector {
		var componentSelector:UInt8
		var huffmanTableSelector:UInt8
	}
}

