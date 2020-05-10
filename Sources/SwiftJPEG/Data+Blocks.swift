//
//  File.swift
//  
//
//  Created by Ben Spratling on 5/10/20.
//

import Foundation





extension Array where Element == UInt8 {
	
	///makes an array of arrays of bytes which each represent a square array row by row of dimension @size, of the original data, assuming the orignal data had a width of @rowLength
	internal func blocks(size:Int, rowLength:Int)->[[UInt8]] {
		let bytesPerBlockCount:Int = size * size
		let horizontalBlockCount:Int = rowLength / size
//		let verticalBlockCount:Int = (count / rowLength)/size
		let bytesPerBlockRow:Int = bytesPerBlockCount * horizontalBlockCount
		let finalBlockCount:Int = count / bytesPerBlockCount
		var outputData:[[UInt8]] = [[UInt8]](repeating: [UInt8](repeating: 0, count: bytesPerBlockCount), count: finalBlockCount)
		for i in 0..<count {
			let row:Int = i / rowLength
			let column:Int = i % rowLength
			//for each byte in the original array, assign it to the correct spot in the outputData
			let blockOriginX:Int = (column / size)*size	//in which column, does this block start?
			let blockOriginY:Int = (row / size)*size	//in which row does this block start
//			let blockIndex:Int = i / bytesPerBlockCount	//the index of this block in the final array	//wrong
			let blockRow:Int = i / bytesPerBlockRow
			let blockColumn:Int = (i%rowLength)/size
			let blockIndex = blockRow * horizontalBlockCount + blockColumn //the index of this block in the final array
			let blockX:Int = column - blockOriginX	//the column inside the block of this point
			let blockY:Int = row - blockOriginY
			let indexInBlock:Int = blockY*size + blockX
			outputData[blockIndex][indexInBlock] = self[i]
		}
		return outputData
	}
	
	//reconstitutes the original data for the method above
	internal init(blocks:[[UInt8]], size:Int, rowLength:Int) {
		let bytesPerBlockCount:Int = size * size
		let horizontalBlockCount:Int = rowLength / size
		let finalByteCount:Int = blocks.count * bytesPerBlockCount
		self.init(repeating: 0, count: finalByteCount)
		
		//for each block, assign each byte to the right position
		for (blockIndex, block) in blocks.enumerated() {
			let blocksRow = blockIndex/horizontalBlockCount
			///the row in the final constituted image of the block
			let blockYOrigin:Int = blocksRow*size
			let blockXOrigin:Int = (blockIndex%horizontalBlockCount)*size
			for y in 0..<size {
				let rowStart:Int = (blockYOrigin+y) * rowLength + blockXOrigin
				for x in 0..<size {
					self[rowStart+x] = block[ y * size + x]
				}
			}
		}
	}
	
}

