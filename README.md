# SwiftJPEG
JPEG image file reading / writing in pure Swift
https://www.w3.org/Graphics/JPEG/itu-t81.pdf

Goal: Create a SampledImage (from SwiftGraphicsCore) from JPEG file data & create JPEG file data with a requested compression level with a SampledImage.

WIP feel free to contribute


## Reading JPEG Images

`let image:SampledImage = try SampledImage(jpegData:Data)`

Not yet supported; in development.

### Segment reading:

`let data:Data = ...`	//jpeg file data

`let segments:[Segment] = try data.jpegSegments()`

## Writing JPEG Images

`let image:SampledImage = ...`

`let jpegData:Data = image.jpegData(quality:0.15)`

Not yet supported




## Process


RGB -> YCrCb conversion   √
YCrCb -> RGB conversion √
Pane splitting, subsampling & reconstitution  √
