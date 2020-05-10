//
//  YCrCbSumSamplingTests.swift
//  
//
//  Created by Ben Spratling on 5/10/20.
//

import Foundation
import XCTest
@testable import SwiftJPEG
import SwiftGraphicsCore
import SwiftPNG


class YCrCbSumSamplingTests : XCTestCase {
	
	func testSubSampling() {
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
		let deconvertedImage = ycrcbImage.convertedFromYCrCbToRGB
		//write out as png for testing
		guard let toundTripPngData:Data = deconvertedImage.pngData else {
			XCTFail("did not create png image from data")
			return
		}
		_ = try? toundTripPngData.write(to: fullImageUrl.deletingLastPathComponent().appendingPathComponent("testycrcbconversionroundtrip.png"))
	}
	
	
	func testPanesSubSampledData() {
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
		//missing panes get 128 as default value
		let yPaddedWidth:Int = image.dimensions.width.paddedToMultiple(of:8)
		let yPaddedHeight:Int = image.dimensions.height.paddedToMultiple(of:8)
		var reassembledData:[UInt8] = [UInt8](repeating: 128, count: 3*yPane.count)
		for i in 0..<yPane.count {
			reassembledData[i*3] = yPane[i]
		}
		let fakeColorSpace = GenericRGBAColorSpace(hasAlpha: false)
		let deconvertedImage = SampledImage(width: yPaddedWidth, height: yPaddedHeight, colorSpace: fakeColorSpace, bytes: reassembledData)
		//TODO: crop image to original size
		guard let toundTripPngData:Data = deconvertedImage.convertedFromYCrCbToRGB.pngData else {
			XCTFail("did not create png image from data")
			return
		}
		_ = try? toundTripPngData.write(to: fullImageUrl.deletingLastPathComponent().appendingPathComponent("yPane.png"))
		
		//   Cr pane
		let crPane:[UInt8] = panes[1]
		let crPaddedWidth = (image.dimensions.width/2).paddedToMultiple(of: 8)
		let crPaddedHeight = (image.dimensions.height/2).paddedToMultiple(of: 8)
		var reassembledCrData = [UInt8](repeating: 128, count: 3*crPane.count)
		for i in 0..<crPane.count {
			reassembledCrData[i*3+1] = crPane[i]
		}
		let deconvertedCrImage = SampledImage(width: crPaddedWidth, height: crPaddedHeight, colorSpace: fakeColorSpace, bytes: reassembledCrData)
		_ = try? deconvertedCrImage.convertedFromYCrCbToRGB.pngData?.write(to: fullImageUrl.deletingLastPathComponent().appendingPathComponent("crPane.png"))
		
		
		//   Cr pane
		let cbPane:[UInt8] = panes[2]
		let cbPaddedWidth = (image.dimensions.width/2).paddedToMultiple(of: 8)
		let cbPaddedHeight = (image.dimensions.height/2).paddedToMultiple(of: 8)
		var reassembledCbData = [UInt8](repeating: 128, count: 3*cbPane.count)
		for i in 0..<cbPane.count {
			reassembledCbData[i*3+1] = cbPane[i]
		}
		let deconvertedCbImage = SampledImage(width: cbPaddedWidth, height: cbPaddedHeight, colorSpace: fakeColorSpace, bytes: reassembledCbData)
		_ = try? deconvertedCbImage.convertedFromYCrCbToRGB.pngData?.write(to: fullImageUrl.deletingLastPathComponent().appendingPathComponent("cbPane.png"))
		
		
		//re-compose original full image
		
		let composedImage = SampledImage(width: image.dimensions.width, height: image.dimensions.height, assemlingYPane: yPane, subsampling: subsampling, CrPane: crPane, CbPane: cbPane).convertedFromYCrCbToRGB
		_ = try? composedImage.pngData?.write(to:fullImageUrl.deletingLastPathComponent().appendingPathComponent("reconstitutedImage.png"))
		
		
	}
	
	
}
