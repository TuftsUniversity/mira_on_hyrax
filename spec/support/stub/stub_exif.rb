# frozen_string_literal: true

RSpec.configure do |config|
  config.before do
    output = { source_file: "/Users/mkorcy01/Downloads/MS099.001.001.00041.00002.archival.tif", exif_tool: { "ExifToolVersion" => 10.65 }, system: { "FileName" => "MS099.001.001.00041.00002.archival.tif", "Directory" => "/Users/mkorcy01/Downloads", "FileSize" => "25 MB", "FileModifyDate" => "2018:05:02 10:21:37-04:00", "FileAccessDate" => "2018:05:08 15:16:33-04:00", "FileInodeChangeDate" => "2018:05:02 10:21:37-04:00", "FilePermissions" => "rw-r--r--" }, file: { "FileType" => "TIFF", "FileTypeExtension" => "tif", "MIMEType" => "image/tiff", "ExifByteOrder" => "Little-endian (Intel, II)" }, ifd0: { "SubfileType" => "Full-resolution Image", "ImageWidth" => 5712, "ImageHeight" => 4632, "BitsPerSample" => 8, "Compression" => "Uncompressed", "PhotometricInterpretation" => "BlackIsZero", "StripOffsets" => 24_968, "Orientation" => "Horizontal (normal)", "SamplesPerPixel" => 1, "RowsPerStrip" => 4632, "StripByteCounts" => 26_457_984, "XResolution" => 600, "YResolution" => 600, "ResolutionUnit" => "inches", "Software" => "Adobe Photoshop CS4 Windows", "ModifyDate" => "2015:04:08 13:17:49" }, "xmp-x": { "XMPToolkit" => "Adobe XMP Core 4.2.2-c063 53.352624, 2008/07/30-18:12:18        " }, "xmp-xmp": { "CreatorTool" => "Adobe Photoshop CS4 Windows", "CreateDate" => "2015:04:08 13:17:49-04:00", "MetadataDate" => "2015:04:08 13:17:49-04:00", "ModifyDate" => "2015:04:08 13:17:49-04:00" }, "xmp-dc": { "Format" => "image/tiff" }, "xmp-xmp_mm": { "InstanceID" => "xmp.iid:5080C32E13DEE411A82299871825CE57", "DocumentID" => "xmp.did:5080C32E13DEE411A82299871825CE57", "OriginalDocumentID" => "xmp.did:5080C32E13DEE411A82299871825CE57", "HistoryAction" => "created", "HistoryInstanceID" => "xmp.iid:5080C32E13DEE411A82299871825CE57", "HistoryWhen" => "2015:04:08 13:17:49-04:00", "HistorySoftwareAgent" => "Adobe Photoshop CS4 Windows" }, "xmp-tiff": { "Orientation" => "Horizontal (normal)", "XResolution" => 600, "YResolution" => 600, "ResolutionUnit" => "inches", "NativeDigest" => "256,257,258,259,262,274,277,284,530,531,282,283,296,301,318,319,529,532,306,270,271,272,305,315,33432;7225FC33AA8ECC7A456425B1915CA086", "ImageWidth" => 5712, "ImageHeight" => 4632, "BitsPerSample" => 8, "Compression" => "Uncompressed", "PhotometricInterpretation" => "BlackIsZero", "SamplesPerPixel" => 1 }, "xmp-exif": { "ExifImageWidth" => 5712, "ExifImageHeight" => 4632, "ColorSpace" => "Uncalibrated", "NativeDigest" => "36864,40960,40961,37121,37122,40962,40963,37510,40964,36867,36868,33434,33437,34850,34852,34855,34856,37377,37378,37379,37380,37381,37382,37383,37384,37385,37386,37396,41483,41484,41486,41487,41488,41492,41493,41495,41728,41729,41730,41985,41986,41987,41988,41989,41990,41991,41992,41993,41994,41995,41996,42016,0,2,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,20,22,23,24,25,26,27,28,30;366E15A58788E7673259741C0546F8A6" }, "xmp-photoshop": { "ColorMode" => "Grayscale", "ICCProfileName" => "Dot Gain 20%" }, photoshop: { "IPTCDigest" => "00000000000000000000000000000000", "XResolution" => 600, "DisplayedUnitsX" => "inches", "YResolution" => 600, "DisplayedUnitsY" => "inches", "PrintStyle" => "Centered", "PrintPosition" => "0 0", "PrintScale" => 1, "GlobalAngle" => 30, "GlobalAltitude" => 30, "PrintFlags" => "0 0 0 0 0 0 0 0 1", "PrintFlagsInfo" => "\u0000\u0001\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0002", "BW_HalftoningInfo" => "\u00005\u0000\u0000\u0000\u0001\u0000-\u0000\u0000\u0000\u0006\u0000\u0000\u0000\u0000\u0000\u0001", "BW_TransferFunc" => "\u0000\u0000??????????????????????\u0003?\u0000\u0000", "GridGuidesInfo" => "\u0000\u0000\u0000\u0001\u0000\u0000\u0002@\u0000\u0000\u0002@\u0000\u0000\u0000\u0000", "URL_List" => [], "SlicesGroupName" => "Untitled-22", "NumSlices" => 1, "PixelAspectRatio" => 1, "IDsBaseValue" => 1, "PhotoshopThumbnail" => "(Binary data 6358 bytes, use -b option to extract)", "HasRealMergedData" => "Yes", "WriterName" => "Adobe Photoshop", "ReaderName" => "Adobe Photoshop CS4", "Photoshop_0x0fa0" => "maniIRFR\u0000\u0000\u0000?8BIMAnDs\u0000\u0000\u0000?\u0000\u0000\u0000\u0010\u0000\u0000\u0000\u0001\u0000\u0000\u0000\u0000\u0000\u0000null\u0000\u0000\u0000\u0003\u0000\u0000\u0000\u0000AFStl[...]", "Photoshop_0x0fa1" => "mfri\u0000\u0000\u0000\u0002\u0000\u0000\u0000\u0010\u0000\u0000\u0000\u0001\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0001\u0000\u0000\u0000\u0000" }, exif_ifd: { "ColorSpace" => "Uncalibrated", "ExifImageWidth" => 5712, "ExifImageHeight" => 4632 }, "icc-header": { "ProfileCMMType" => "ADBE", "ProfileVersion" => "2.1.0", "ProfileClass" => "Output Device Profile", "ColorSpaceData" => "GRAY", "ProfileConnectionSpace" => "XYZ ", "ProfileDateTime" => "1999:06:03 00:00:00", "ProfileFileSignature" => "acsp", "PrimaryPlatform" => "Apple Computer Inc.", "CMMFlags" => "Not Embedded, Independent", "DeviceManufacturer" => "none", "DeviceModel" => "", "DeviceAttributes" => "Reflective, Glossy, Positive, Color", "RenderingIntent" => "Media-Relative Colorimetric", "ConnectionSpaceIlluminant" => "0.9642 1 0.82491", "ProfileCreator" => "ADBE", "ProfileID" => 0 }, icc_profile: { "ProfileCopyright" => "Copyright 1999 Adobe Systems Incorporated", "ProfileDescription" => "Dot Gain 20%", "MediaWhitePoint" => "0.9642 1 0.82491", "MediaBlackPoint" => "0 0 0", "GrayTRC" => "(Binary data 524 bytes, use -b option to extract)" }, composite: { "ImageSize" => "5712x4632", "Megapixels" => 26.5 } }
    ruby_mock = instance_double(Exiftool, to_hash: output)
    allow(Exiftool).to receive(:new).and_return(ruby_mock)
  end
end
