//
//  File.swift
//  
//
//  Created by Ben Spratling on 5/10/20.
//

import Foundation
import SwiftGraphicsCore


public enum SubSampling {
	///no subsampling
	case ss444
	
	///
	case ss422
	
	///
	case ss420
	
	var horizontalChromaPitch:Int {
		switch self {
		case .ss444:
			return 1
		case .ss422:
			return 2
		case .ss420:
			return 2
		}
	}
	
	var verticalChromaPitch:Int {
		switch self {
		case .ss444:
			return 1
		case .ss422:
			return 1
		case .ss420:
			return 2
		}
	}
}


extension SampledImage {
	
	///colorspace is a lie
	internal var convertedFromRGBToYCrCbImage:SampledImage {
		let noAlphaColorSpace = GenericRGBAColorSpace(hasAlpha: false)
		let newImage = SampledImage(width: dimensions.width, height: dimensions.height, colorSpace: noAlphaColorSpace, bytes: nil)
		for x in 0..<dimensions.width {
			for y in 0..<dimensions.height {
				///assumes self is rgb and not grayscale
				let bytes:[[UInt8]] = self[x, y].components
				let (Y, cr, cb) = convertRGBToYCbCr(red: bytes[0][0], green: bytes[1][0], blue: bytes[2][0])
				newImage[x, y] = SampledColor(components: [[Y],[cr],[cb]])
			}
		}
		return newImage
	}
	
	internal var convertedFromYCrCbToRGB:SampledImage {
		let noAlphaColorSpace = GenericRGBAColorSpace(hasAlpha: false)
		let newImage = SampledImage(width: dimensions.width, height: dimensions.height, colorSpace: noAlphaColorSpace, bytes: nil)
		for x in 0..<dimensions.width {
			for y in 0..<dimensions.height {
				///assumes self is rgb and not grayscale
				let bytes:[[UInt8]] = self[x, y].components
				let (r,g,b) = convertYCbCrToRGB(Y: bytes[0][0], Cb: bytes[1][0], Cr: bytes[2][0])
				newImage[x, y] = SampledColor(components: [[r],[g],[b]])
			}
		}
		return newImage
	}
	
	///assumes YCrCb colors space
	internal func subsampled(_ subsampling:SubSampling, padding:Int = 8)->[[UInt8]] {
		let yPaddedWidth:Int = dimensions.width.paddedToMultiple(of:padding)
		let yPaddedHeight:Int = dimensions.height.paddedToMultiple(of:padding)
		var yPane:[UInt8] = [UInt8](repeating: 0, count: yPaddedWidth * yPaddedWidth)
		for x in 0..<yPaddedWidth {
			for y in 0..<yPaddedHeight {
				let finalPaneCoordinate:Int = y*yPaddedWidth + x
				let originalImageX:Int = x >= dimensions.width ? dimensions.width-1 : x
				let originalImageY:Int = y >= dimensions.height ? dimensions.height-1 : y
				yPane[finalPaneCoordinate] = self[originalImageX, originalImageY].components[0][0]
			}
		}
		
		let subsampledWidth:Int = (dimensions.width / subsampling.horizontalChromaPitch).paddedToMultiple(of: padding)
		let subsampledHeight:Int = (dimensions.height / subsampling.verticalChromaPitch).paddedToMultiple(of: padding)
		var crPane:[UInt8] = [UInt8](repeating: 0, count: subsampledWidth * subsampledHeight)
		var cbPane:[UInt8] = [UInt8](repeating: 0, count: subsampledWidth * subsampledHeight)
		for x in 0..<subsampledWidth {
			for y in 0..<subsampledHeight {
				let finalPaneCoordinate:Int = y*subsampledWidth + x
				let sampledX = x * subsampling.horizontalChromaPitch
				let sampledY = y * subsampling.verticalChromaPitch
				let originalImageX:Int = sampledX >= dimensions.width ? dimensions.width-1 : sampledX
				let originalImageY:Int = sampledY >= dimensions.height ? dimensions.height-1 : sampledY
				let sample:SampledColor = self[originalImageX, originalImageY]
				crPane[finalPaneCoordinate] = sample.components[1][0]
				cbPane[finalPaneCoordinate] = sample.components[2][0]
			}
		}
		
		return [yPane, crPane, cbPane]
	}
	
	///produces an image whose panes have been de-subsampled & stictche dback together, but are still in YCrCb and falsely show an rgb color space
	internal convenience init(width:Int, height:Int, assemlingYPane:[UInt8], subsampling:SubSampling, CrPane:[UInt8], CbPane:[UInt8]) {
		let rgbColorSpace:ColorSpace = GenericRGBAColorSpace(hasAlpha: false)
		var finalData:[UInt8] = [UInt8](repeating: 128, count: 3 * width * height)
		let yPaddedRowLength:Int = width.paddedToMultiple(of: 8)
		let cPaddedRowLength:Int = (width/subsampling.horizontalChromaPitch).paddedToMultiple(of: 8)
		//set bytes in finalData from the 3 panes
		for x in 0..<width {
			for y in 0..<height {
				let pixelStartIndex:Int = 3 * (y*width + x)
				let yIndex = y*yPaddedRowLength + x
				finalData[pixelStartIndex + 0] = assemlingYPane[yIndex]
				
				let cIndex:Int = (y/subsampling.verticalChromaPitch) * cPaddedRowLength + (x/subsampling.horizontalChromaPitch)
				finalData[pixelStartIndex + 1] = CrPane[cIndex]
				finalData[pixelStartIndex + 2] = CbPane[cIndex]	
			}
		}
		self.init(width:width, height:height, colorSpace:rgbColorSpace, bytes:finalData)
	}
	
	
}

extension Int {
	func paddedToMultiple(of blockSize:Int)->Int {
		return (self/blockSize+(self % blockSize > 0 ? 1 : 0)) * blockSize
	}
}


struct SubSample {
	var yBlock:[[UInt8]]
	var CrBlock:[[UInt8]]
	var CbBlock:[[UInt8]]
	
	
}
