//
//  BlocksTests.swift
//  
//
//  Created by Ben Spratling on 5/10/20.
//

import Foundation
import XCTest
@testable import SwiftJPEG
import SwiftGraphicsCore
import SwiftPNG


class BlocksTests : XCTestCase {
	
	func testReassemblingBlocks() {
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
		let reassmbledYPane = [UInt8](blocks: yBlocks, size: 8, rowLength: yPaddedWidth)
		
		let crBlocks = crPane.blocks(size: 8, rowLength: crPaddedWidth)
		let reassmbledCrPane = [UInt8](blocks: crBlocks, size: 8, rowLength: crPaddedWidth)
		
		let cbBlocks = cbPane.blocks(size: 8, rowLength: crPaddedWidth)
		let reassmbledCbPane = [UInt8](blocks: cbBlocks, size: 8, rowLength: crPaddedWidth)
		
		//split y pane into 8x8 blocks, put them back together, reassmble the iamge
		
		
		let composedImage = SampledImage(width: image.dimensions.width, height: image.dimensions.height, assemlingYPane: reassmbledYPane, subsampling: subsampling, CrPane: reassmbledCrPane, CbPane: reassmbledCbPane).convertedFromYCrCbToRGB
		_ = try? composedImage.pngData?.write(to:fullImageUrl.deletingLastPathComponent().appendingPathComponent("reassembledYBlocks.png"))
	}
}
