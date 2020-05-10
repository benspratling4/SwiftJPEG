//
//  File.swift
//  
//
//  Created by Ben Spratling on 5/9/20.
//

import Foundation



public enum Marker : Equatable {
	case startOfImage
	case startOfFrameBaseline
	case startOfFrameProgressive
	case defineHuffmanTables
	case defineQuantizationTables
	case defineRestartInterval
	case startOfScan
	case restart(UInt8)
	case applicationSpecific(UInt8)
	case comment
	case endOfImage
	
	public init?(byte:UInt8) {
		switch byte {
		case 0xD8:
			self = .startOfImage
		case 0xC0:
			self = .startOfFrameBaseline
		case 0xC2:
			self = .startOfFrameProgressive
		case 0xC4:
			self = .defineHuffmanTables
		case 0xDB:
			self = .defineQuantizationTables
		case 0xDD:
			self = .defineRestartInterval
		case 0xDA:
			self = .startOfScan
		case 0xFE:
			self = .comment
		case 0xD9:
			self = .endOfImage
		case 0xD0...0xD7:
			self = .restart(byte & 0x07)
		case 0xE0...0xEF:
			self = .applicationSpecific(byte & 0x0F)
		default:
			return nil
		}
	}
	
	public var bytes:[UInt8] {
		switch self {
		case .startOfImage:
			return [0xFF, 0xD8]
		case .startOfFrameBaseline:
			return [0xFF, 0xC0]
		case .startOfFrameProgressive:
			return [0xFF, 0xC2]
		case .defineHuffmanTables:
			return [0xFF, 0xC4]
		case .defineQuantizationTables:
			return [0xFF, 0xDB]
		case .defineRestartInterval:
			return [0xFF, 0xDD]
		case .startOfScan:
			return [0xFF, 0xDA]
		case .restart(let number):
			return [0xFF, 0xD0 | number]
		case .applicationSpecific(let number):
			return [0xFF, 0xE0 | number]
		case .comment:
			return [0xFF, 0xFE]
		case .endOfImage:
			return [0xFF, 0xD9]
		}
	}
	
	
	public var fixedLength:Int? {
		switch self {
		case .startOfImage:
			return 0
			
		case .defineRestartInterval:
			return 4
			
		case .restart(_):
			return 0
			
		case .endOfImage:
			return 0
			
		default:
			return nil
		}
	}
	
}

