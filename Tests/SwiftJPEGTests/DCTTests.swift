//
//  DCTTests.swift
//  
//
//  Created by Ben Spratling on 5/10/20.
//

import Foundation
import XCTest
@testable import SwiftJPEG
import SwiftGraphicsCore
import SwiftPNG


class DCTTests : XCTestCase {
	
	func testSampleMatrix() {
		let block:[UInt8] = [ 52, 55, 61, 66, 70, 61, 64, 73,
							  63, 59, 55, 90, 109, 85, 69, 72,
							  62, 59, 68, 113, 144, 104, 66, 73,
							  63, 58, 71, 122, 154, 106, 70, 69,
							  67, 61, 68, 104, 126, 88, 68, 70,
							  79, 65, 60, 70, 77, 68, 58, 75,
							  85, 71, 64, 59, 55, 61, 65, 83,
							  87, 79, 69, 68, 65, 76, 78, 94
		]
		let dctd = block.getDCTSpatialCoefficients()
		let knownAnswers:[Float] =
		[-415.37497, -30.185743, -61.197044, 27.239313, 56.125057, -20.09515, -2.3876204, 0.4618368, 4.465468, -21.857437, -60.75805, 10.253632, 13.145117, -7.0874224, -8.535437, 4.8768854, -46.834446, 7.3705893, 77.12939, -24.561974, -28.911686, 9.933519, 5.41681, -5.6489496, -48.534946, 12.068357, 34.09978, -14.759413, -10.240611, 6.2959714, 1.8311672, 1.9459378, 12.125051, -6.553448, -13.196109, -3.9514341, -1.8750129, 1.7452848, -2.787227, 3.1352808, -7.7347274, 2.905468, 2.3798065, -5.939316, -2.3778002, 0.9413936, 4.303714, 1.8486919, -1.0306497, 0.18306518, 0.41681433, -2.415563, -0.8777945, -3.0193079, 4.12061, -0.66195, -0.16536713, 0.14161515, -1.071533, -4.1929154, -1.1703224, -0.09775835, 0.501268, 1.6754578]
		for (i, value) in block.enumerated() {
			XCTAssertEqual(dctd[i], knownAnswers[i], accuracy: 0.01)
		}
	}
	
	
	func testInverseSampleMatrix() {
		let frequencyData:[Float] = [-416, -33, -60, 32, 48, -40, 0, 0,
									 0, -24, -56, 19, 26, 0, 0, 0,
									 -42, 13, 80, -24, -40, 0, 0, 0,
									 -42, 17, 44, -29, 0, 0, 0, 0,
									 18, 0, 0, 0, 0, 0, 0, 0,
									 0, 0, 0, 0, 0, 0, 0, 0,
									 0, 0, 0, 0, 0, 0, 0, 0,
									 0, 0, 0, 0, 0, 0, 0, 0
		]
		let reconstitutedValues:[UInt8] = [UInt8](DCTSpatialSpatialCoefficients: frequencyData)
		for row in 0..<8 {
			print(reconstitutedValues[row*8..<(row+1)*8])
		}
		
		let sampleAnswerData:[UInt8] = [
			62, 65, 57, 60, 72, 63, 60, 82,
			57, 55, 56, 82, 108, 87, 62, 71,
			58, 50, 60, 111, 148, 114, 67, 65,
			65, 55, 66, 120, 155, 114, 68, 70,
			70, 63, 67, 101, 122, 88, 60, 78,
			71, 71, 64, 70, 80, 62, 56, 81,
			75, 82, 67, 54, 63, 65, 66, 83,
			81, 94, 75, 54, 68, 81, 81, 87
		]
		for (i, value) in reconstitutedValues.enumerated() {
			XCTAssertEqual(value, sampleAnswerData[i])
		}
	}
	
	
	func testDCT() {
		let fullImageUrl:URL = URL(fileURLWithPath:#file).deletingLastPathComponent().appendingPathComponent("SD2016.png")
		guard let pngData:Data = try? Data(contentsOf: fullImageUrl) else {
			XCTFail("unable to read png image data")
			return
		}
		guard let image = try? SampledImage(pngData: pngData) else {
			XCTFail("unable to read png image")
			return
		}
		let ycrcbImage = image.convertedFromRGBToYCrCbImage
		let subsampling:SubSampling = .ss420
		let panes:[[UInt8]] = ycrcbImage.subsampled(subsampling)
		guard panes.count == 3  else {
			XCTFail("did not get 3 panes of data")
			return
		}
		
		//try to re-constitute the y pane as a grayscale image
		
		let yPane:[UInt8] = panes[0]
		let crPane:[UInt8] = panes[1]
		let cbPane:[UInt8] = panes[2]
		//missing panes get 128 as default value
		let yPaddedWidth:Int = image.dimensions.width.paddedToMultiple(of:8)
		let crPaddedWidth = (image.dimensions.width/2).paddedToMultiple(of: 8)
		
		let yBlocks:[[UInt8]] = yPane.blocks(size: 8, rowLength: yPaddedWidth)
		let dctTransformedYBlocks:[[Float]] = yBlocks.map({ $0.getDCTSpatialCoefficients() })
		let iDCTYBlocks = dctTransformedYBlocks.map({ [UInt8](DCTSpatialSpatialCoefficients: $0) })
		
		let reassmbledYPane = [UInt8](blocks: iDCTYBlocks, size: 8, rowLength: yPaddedWidth)
		
		let crBlocks = crPane.blocks(size: 8, rowLength: crPaddedWidth)
		let reassmbledCrPane = [UInt8](blocks: crBlocks, size: 8, rowLength: crPaddedWidth)
		
		let cbBlocks = cbPane.blocks(size: 8, rowLength: crPaddedWidth)
		let reassmbledCbPane = [UInt8](blocks: cbBlocks, size: 8, rowLength: crPaddedWidth)
		
		//split y pane into 8x8 blocks, put them back together, reassmble the iamge
		
		
		let composedImage = SampledImage(width: image.dimensions.width, height: image.dimensions.height, assemlingYPane: reassmbledYPane, subsampling: subsampling, CrPane: reassmbledCrPane, CbPane: reassmbledCbPane).convertedFromYCrCbToRGB
		guard let outPNGData = composedImage.pngData else {
			XCTFail("unable to create png data of image")
			return
		}
		_ = try? outPNGData.write(to:fullImageUrl.deletingLastPathComponent().appendingPathComponent("reassembledYDCTdBlocks.png"))
	}
}
