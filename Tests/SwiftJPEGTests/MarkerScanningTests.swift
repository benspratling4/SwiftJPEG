//
//  MarkerScanningTests.swift
//  
//
//  Created by Ben Spratling on 5/9/20.
//

import Foundation
import XCTest
@testable import SwiftJPEG


class MarkerScanningTests : XCTestCase {
	
	func testMarkerScanning() {
		let testImageUrl:URL = URL(fileURLWithPath: #file).deletingLastPathComponent().appendingPathComponent("IMG_0423.jpg")
		guard let fileData = try? Data(contentsOf: testImageUrl) else {
			XCTFail("unable to read test image data")
			return
		}
		do {
			let segments:[Segment] = try fileData.jpegSegments()
			XCTAssertGreaterThan(segments.count, 4)
			XCTAssertEqual(segments[0].marker, .startOfImage)
			XCTAssertEqual(segments.last?.marker, .endOfImage)
			print(segments)
		} catch {
			XCTFail("failed reading segments \(error)")
		}
	}
	
	
	static var allTests = [
		   ("testMarkerScanning", testMarkerScanning),
	   ]
	
}

