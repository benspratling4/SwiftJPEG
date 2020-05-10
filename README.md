# SwiftJPEG
JPEG image file reading / writing in pure Swift

Goal: Create a SampledImage (from SwiftGraphicsCore) from JPEG file data & create JPEG file data with a requested compression level with a SampledImage.

WIP feel free to contribute

### Segment reading:

`let data:Data = ...`	//jpeg file data

`let segments:[Segment] = try data.jpegSegments()`
