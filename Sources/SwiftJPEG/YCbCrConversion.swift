//
//  File.swift
//  
//
//  Created by Ben Spratling on 5/9/20.
//

import Foundation

//https://en.wikipedia.org/wiki/YCbCr
func convertRGBToYCbCr(red:UInt8, green:UInt8, blue:UInt8)->(Y:UInt8, Cb:UInt8, Cr:UInt8) {
	let r:Float32 = Float32(red)
	let g:Float32 = Float32(green)
	let b:Float32 = Float32(blue)
	
	let Y:Float32 = 0.299 * r + 0.587 * g + 0.114 * b
	let Cb:Float32 = 128.0 + r * -0.168736 + g * -0.331264 + b * 0.5
	let Cr:Float32 = 128.0 + 0.5 * r + g * -0.418688 + b * -0.081312
	
	return (Y:UInt8(clamping:Int(Y.rounded())),
		Cb:UInt8(clamping:Int(Cb.rounded())),
		Cr:UInt8(clamping:Int(Cr.rounded()))
	)
}

func convertYCbCrToRGB(Y:UInt8, Cb:UInt8, Cr:UInt8)->(red:UInt8, green:UInt8, blue:UInt8) {
	let y:Float32 = Float32(Y)
	let cb:Float32 = Float32(Cb)
	let cr:Float32 = Float32(Cr)
	
	let r:Float32 = y + 1.402 * (cr - 128.0)
	let g:Float32 = y - 0.344136 * (cb - 128.0) - 0.714136 * (cr - 128.0)
	let b:Float32 = y + 1.772 * (cb - 128.0)
	
	return (red:UInt8(clamping:Int(r.rounded())),
		green:UInt8(clamping:Int(g.rounded())),
		blue:UInt8(clamping:Int(b.rounded()))
	)
}
