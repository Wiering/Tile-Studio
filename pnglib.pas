unit pnglib;
{
  PngLib.Pas

  Conversion from C header file to Pascal Unit by Edmund H. Hand in
  April of 1998.
  For conditions of distribution and use, see the COPYRIGHT NOTICE from the
  orginal C Header file below.

  This unit is intended for use with LPng.DLL.  LPng.DLL was compiled with
  Microsoft Visual C++ 5.0 and is comprised of the standard PNG library
  version 1.0.1.  LPng.DLL uses ZLib 1.1.2 internally for compression and
  decompression.  The ZLib functions are also exported in the DLL, but they
  have not yet been defined here.

  The primary word of warning I must offer is that most of the function
  pointers for callback functions have merely been declared as the pascal
  Pointer type. I have only defined one procedure type for read and write
  callback functions.  So if you plan to use other callback types, check the
  included header file for the function definition.

  The header comments of the original C Header file follow.

 * png.h - header file for PNG reference library
 *
 * libpng 1.0.1
 * For conditions of distribution and use, see the COPYRIGHT NOTICE below.
 * Copyright (c) 1995, 1996 Guy Eric Schalnat, Group 42, Inc.
 * Copyright (c) 1996, 1997 Andreas Dilger
 * Copyright (c) 1998 Glenn Randers-Pehrson
 * March 15, 1998
 *
 * Note about libpng version numbers:
 *
 *    Due to various miscommunications, unforeseen code incompatibilities
 *    and occasional factors outside the authors' control, version numbering
 *    on the library has not always been consistent and straightforward.
 *    The following table summarizes matters since version 0.89c, which was
 *    the first widely used release:
 *
 *      source                    png.h   png.h   shared-lib
 *      version                   string    int   version
 *      -------                   ------  ------  ----------
 *      0.89c ("1.0 beta 3")      0.89        89  1.0.89
 *      0.90  ("1.0 beta 4")      0.90        90  0.90  [should have been 2.0.90]
 *      0.95  ("1.0 beta 5")      0.95        95  0.95  [should have been 2.0.95]
 *      0.96  ("1.0 beta 6")      0.96        96  0.96  [should have been 2.0.96]
 *      0.97b ("1.00.97 beta 7")  1.00.97     97  1.0.1 [should have been 2.0.97]
 *      0.97c                     0.97        97  2.0.97
 *      0.98                      0.98        98  2.0.98
 *      0.99                      0.99        98  2.0.99
 *      0.99a-m                   0.99        99  2.0.99
 *      1.00                      1.00       100  2.1.0 [int should be 10000]
 *      1.0.0                     1.0.0      100  2.1.0 [int should be 10000]
 *      1.0.1                     1.0.1    10001  2.1.0
 *
 *    Henceforth the source version will match the shared-library minor
 *    and patch numbers; the shared-library major version number will be
 *    used for changes in backward compatibility, as it is intended.
 *    The PNG_PNGLIB_VER macro, which is not used within libpng but
 *    is available for applications, is an unsigned integer of the form
 *    xyyzz corresponding to the source version x.y.z (leading zeros in y and z).
 *    
 *
 * See libpng.txt for more information.  The PNG specification is available
 * as RFC 2083 <ftp://ftp.uu.net/graphics/png/documents/>
 * and as a W3C Recommendation <http://www.w3.org/TR/REC.png.html>
 *
 * Contributing Authors:
 *    John Bowler
 *    Kevin Bracey
 *    Sam Bushell
 *    Andreas Dilger
 *    Magnus Holmgren
 *    Tom Lane
 *    Dave Martindale
 *    Glenn Randers-Pehrson
 *    Greg Roelofs
 *    Guy Eric Schalnat
 *    Paul Schmidt
 *    Tom Tanner
 *    Willem van Schaik
 *    Tim Wegner
 *
 * The contributing authors would like to thank all those who helped
 * with testing, bug fixes, and patience.  This wouldn't have been
 * possible without all of you.
 *
 * Thanks to Frank J. T. Wojcik for helping with the documentation.
 *
 * COPYRIGHT NOTICE:
 *
 * The PNG Reference Library is supplied "AS IS".  The Contributing Authors
 * and Group 42, Inc. disclaim all warranties, expressed or implied,
 * including, without limitation, the warranties of merchantability and of
 * fitness for any purpose.  The Contributing Authors and Group 42, Inc.
 * assume no liability for direct, indirect, incidental, special, exemplary,
 * or consequential damages, which may result from the use of the PNG
 * Reference Library, even if advised of the possibility of such damage.
 *
 * Permission is hereby granted to use, copy, modify, and distribute this
 * source code, or portions hereof, for any purpose, without fee, subject
 * to the following restrictions:
 * 1. The origin of this source code must not be misrepresented.
 * 2. Altered versions must be plainly marked as such and must not be
 *    misrepresented as being the original source.
 * 3. This Copyright notice may not be removed or altered from any source or
 *    altered source distribution.
 *
 * The Contributing Authors and Group 42, Inc. specifically permit, without
 * fee, and encourage the use of this source code as a component to
 * supporting the PNG file format in commercial products.  If you use this
 * source code in a product, acknowledgment is not required but would be
 * appreciated.
 *}
interface

uses SysUtils;

type PByte      = ^Byte;
type PPByte     = ^PByte;
type PPChar     = ^PChar;
type PWord      = ^Word;
type PPWord     = ^PWord;
type PDouble    = ^Double;
type PSmallint  = ^Smallint;
type PCardinal  = ^Cardinal;
type PPCardinal = ^PCardinal;
type PInteger   = ^Integer;
type PPInteger  = ^PInteger;

const Lib = 'lpng.dll';

// Version information for png.h - this should match the version in png.c
const PNG_LIBPNG_VER_STRING =  '1.0.1';
const PNG_LIBPNG_VER        =  '10001';  // 1.0.1

// Supported compression types for text in PNG files (tEXt, and zTXt).
// The values of the PNG_TEXT_COMPRESSION_ defines should NOT be changed.
const PNG_TEXT_COMPRESSION_NONE_WR: Integer = -3;
const PNG_TEXT_COMPRESSION_zTXt_WR: Integer = -2;
const PNG_TEXT_COMPRESSION_NONE:    Integer = -1;
const PNG_TEXT_COMPRESSION_zTXt:    Integer = 0;
const PNG_TEXT_COMPRESSION_LAST:    Integer = 1;  // Not a valid value

// These describe the color_type field in png_info.
// color type masks
const PNG_COLOR_MASK_PALETTE: Integer = 1;
const PNG_COLOR_MASK_COLOR:   Integer = 2;
const PNG_COLOR_MASK_ALPHA:   Integer = 4;

// color types.  Note that not all combinations are legal
const PNG_COLOR_TYPE_GRAY:       Integer = 0;
const PNG_COLOR_TYPE_PALETTE:    Integer = 3;
const PNG_COLOR_TYPE_RGB:        Integer = 2;
const PNG_COLOR_TYPE_RGB_ALPHA:  Integer = 6;
const PNG_COLOR_TYPE_GRAY_ALPHA: Integer = 4;

// This is for compression type. PNG 1.0 only defines the single type.
const PNG_COMPRESSION_TYPE_BASE:    Integer = 0; // Deflate method 8, 32K window
const PNG_COMPRESSION_TYPE_DEFAULT: Integer = 0;

// This is for filter type. PNG 1.0 only defines the single type.
const PNG_FILTER_TYPE_BASE:    Integer = 0; // Single row per-byte filtering
const PNG_FILTER_TYPE_DEFAULT: Integer = 0;

// These are for the interlacing type.  These values should NOT be changed.
const PNG_INTERLACE_NONE:  Integer = 0; // Non-interlaced image
const PNG_INTERLACE_ADAM7: Integer = 1; // Adam7 interlacing
const PNG_INTERLACE_LAST:  Integer = 2; // Not a valid value

// These are for the oFFs chunk.  These values should NOT be changed.
const PNG_OFFSET_PIXEL:      Integer = 0; // Offset in pixels
const PNG_OFFSET_MICROMETER: Integer = 1; // Offset in micrometers (1/10^6 meter)
const PNG_OFFSET_LAST:       Integer = 2; // Not a valid value

// These are for the pCAL chunk.  These values should NOT be changed.
const PNG_EQUATION_LINEAR:     Integer = 0; // Linear transformation
const PNG_EQUATION_BASE_E:     Integer = 1; // Exponential base e transform
const PNG_EQUATION_ARBITRARY:  Integer = 2; // Arbitrary base exponential transform
const PNG_EQUATION_HYPERBOLIC: Integer = 3; // Hyperbolic sine transformation
const PNG_EQUATION_LAST:       Integer = 4; // Not a valid value

// These are for the pHYs chunk.  These values should NOT be changed.
const PNG_RESOLUTION_UNKNOWN: Integer = 0; // pixels/unknown unit (aspect ratio)
const PNG_RESOLUTION_METER:   Integer = 1; // pixels/meter
const PNG_RESOLUTION_LAST:    Integer = 2; // Not a valid value

// These are for the sRGB chunk.  These values should NOT be changed.
const PNG_sRGB_INTENT_SATURATION: Integer = 0;
const PNG_sRGB_INTENT_PERCEPTUAL: Integer = 1;
const PNG_sRGB_INTENT_ABSOLUTE:   Integer = 2;
const PNG_sRGB_INTENT_RELATIVE:   Integer = 3;
const PNG_sRGB_INTENT_LAST:       Integer = 4; // Not a valid value

{* These determine if an ancillary chunk's data has been successfully read
 * from the PNG header, or if the application has filled in the corresponding
 * data in the info_struct to be written into the output file.  The values
 * of the PNG_INFO_<chunk> defines should NOT be changed.
 *}
const PNG_INFO_gAMA: Integer = $0001;
const PNG_INFO_sBIT: Integer = $0002;
const PNG_INFO_cHRM: Integer = $0004;
const PNG_INFO_PLTE: Integer = $0008;
const PNG_INFO_tRNS: Integer = $0010;
const PNG_INFO_bKGD: Integer = $0020;
const PNG_INFO_hIST: Integer = $0040;
const PNG_INFO_pHYs: Integer = $0080;
const PNG_INFO_oFFs: Integer = $0100;
const PNG_INFO_tIME: Integer = $0200;
const PNG_INFO_pCAL: Integer = $0400;
const PNG_INFO_sRGB: Integer = $0800;   // GR-P, 0.96a

{* The values of the PNG_FILLER_ defines should NOT be changed *}
const PNG_FILLER_BEFORE: Integer = 0;
const PNG_FILLER_AFTER: Integer = 1;

{* Three color definitions.  The order of the red, green, and blue, (and the
 * exact size) is not important, although the size of the fields need to
 * be png_byte or png_uint_16 (as defined below).
 *}
type TPng_Color = record
  red:   Byte;
  green: Byte;
  blue:  Byte;
end;
type PPng_Color  = ^TPng_Color;
type PPPng_Color = ^PPng_Color;

type TPng_Color_16 = record
  index: Byte;     // Used for palette files
  red:   Word;     // For use in reg, green, blue files
  green: Word;
  blue:  Word;
  gray:  Word;     // For use in grayscale files
end;
type PPng_Color_16  = ^TPng_Color_16;
type PPPng_Color_16 = ^PPng_Color_16;

type TPng_Color_8 = record
   red:   Byte;    // for use in red green blue files
   green: Byte;
   blue:  Byte;
   gray:  Byte;    // for use in grayscale files
   alpha: Byte;    // for alpha channel files
end;
type PPng_Color_8  = ^TPng_Color_8;
type PPPng_Color_8 = ^PPng_Color_8;

{* png_text holds the text in a PNG file, and whether they are compressed
 * in the PNG file or not.  The "text" field points to a regular C string.
 *}
type TPng_Text = record
   compression: Integer;   // compression value, see PNG_TEXT_COMPRESSION_
   key:         PChar;     // keyword, 1-79 character description of "text"
   text:        PChar;     // comment, may be an empty string (ie "")
   text_length: Integer;   // length of "text" field
end;
type PPng_Text  = ^TPng_Text;
type PPPng_Text = ^PPng_Text;
type TPng_Text_Array = array[0..65535] of TPng_Text;
type PPng_Text_Array = ^TPng_Text_Array;

{* png_time is a way to hold the time in an machine independent way.
 * Two conversions are provided, both from time_t and struct tm.  There
 * is no portable way to convert to either of these structures, as far
 * as I know.  If you know of a portable way, send it to me.  As a side
 * note - PNG is Year 2000 compliant!
 *}
type TPng_Time = record
   year:   Word; // full year, as in, 1995
   month:  Byte; // month of year, 1 - 12
   day:    Byte; // day of month, 1 - 31
   hour:   Byte; // hour of day, 0 - 23
   minute: Byte; // minute of hour, 0 - 59
   second: Byte; // second of minute, 0 - 60 (for leap seconds)
end;
type PPng_Time  = ^TPng_Time;
type PPPng_Time = ^PPng_Time;

type TM = record            // Standard C time structure
  tm_sec: Integer;     // seconds after the minute - [0,59]
  tm_min: Integer;     // minutes after the hour - [0,59]
  tm_hour: Integer;    // hours since midnight - [0,23]
  tm_mday: Integer;    // day of the month - [1,31]
  tm_mon: Integer;     // months since January - [0,11]
  tm_year: Integer;    // years since 1900
  tm_wday: Integer;    // days since Sunday - [0,6]
  tm_yday: Integer;    // days since January 1 - [0,365]
  tm_isdst: Integer;   // daylight savings time flag
end;
type PTM = ^TM;

{ png_info is a structure that holds the information in a PNG file so
 * that the application can find out the characteristics of the image.
 * If you are reading the file, this structure will tell you what is
 * in the PNG file.  If you are writing the file, fill in the information
 * you want to put into the PNG file, then call png_write_info().
 * The names chosen should be very close to the PNG specification, so
 * consult that document for information about the meaning of each field.
 *
 * With libpng < 0.95, it was only possible to directly set and read the
 * the values in the png_info_struct, which meant that the contents and
 * order of the values had to remain fixed.  With libpng 0.95 and later,
 * however, * there are now functions which abstract the contents of
 * png_info_struct from the application, so this makes it easier to use
 * libpng with dynamic libraries, and even makes it possible to use
 * libraries that don't have all of the libpng ancillary chunk-handing
 * functionality.
 *
 * In any case, the order of the parameters in png_info_struct should NOT
 * be changed for as long as possible to keep compatibility with applications
 * that use the old direct-access method with png_info_struct.
 *}
type TPng_Info = record
   //the following are necessary for every PNG file
   width:            Cardinal;  // width of image in pixels (from IHDR)
   height:           Cardinal;  // height of image in pixels (from IHDR)
   valid:            Cardinal;  // valid chunk data (see PNG_INFO_ below)
   rowbytes:         Cardinal;  // bytes needed to hold an untransformed row
   palette:          PPng_Color;// array of color values (valid & PNG_INFO_PLTE)
   num_palette:      Word;      // number of color entries in "palette" (PLTE)
   num_trans:        Word;      // number of transparent palette color (tRNS)
   bit_depth:        Byte;      // 1, 2, 4, 8, or 16 bits/channel (from IHDR)
   color_type:       Byte;      // see PNG_COLOR_TYPE_ below (from IHDR)
   compression_type: Byte;      // must be PNG_COMPRESSION_TYPE_BASE (IHDR)
   filter_type:      Byte;      // must be PNG_FILTER_TYPE_BASE (from IHDR)
   interlace_type:   Byte;      // One of PNG_INTERLACE_NONE,PNG_INTERLACE_ADAM7

   // The following is informational only on read, and not used on writes.
   channels:     Byte;    // number of data channels per pixel (1, 3, 4)
   pixel_depth:  Byte;    // number of bits per pixel
   spare_byte:   Byte;    // to align the data, and for future use
   signature: array[0..7] of Byte;// magic bytes read by libpng from start of file

   {* The rest of the data is optional.  If you are reading, check the
    * valid field to see if the information in these are valid.  If you
    * are writing, set the valid field to those chunks you want written,
    * and initialize the appropriate fields below.
    *}

   {* The gAMA chunk describes the gamma characteristics of the system
    * on which the image was created, normally in the range [1.0, 2.5].
    * Data is valid if (valid & PNG_INFO_gAMA) is non-zero.
    *}
   gamma: Single;  // gamma value of image, if (valid & PNG_INFO_gAMA)

    // GR-P, 0.96a
    // Data valid if (valid & PNG_INFO_sRGB) non-zero.
   srgb_intent: Byte;       // sRGB rendering intent [0, 1, 2, or 3]

   {* The tEXt and zTXt chunks contain human-readable textual data in
    * uncompressed and compressed forms, respectively.  The data in "text"
    * is an array of pointers to uncompressed, null-terminated C strings.
    * Each chunk has a keyword which describes the textual data contained
    * in that chunk.  Keywords are not required to be unique, and the text
    * string may be empty.  Any number of text chunks may be in an image.
    *}
   num_text: Integer;   // number of comments read/to write
   max_text: Integer;   // current size of text array
   text:     PPng_Text; // array of comments read/to write

   {* The tIME chunk holds the last time the displayed image data was
    * modified.  See the png_time struct for the contents of this struct.
    *}
   mod_time: TPng_Time;

   {* The sBIT chunk specifies the number of significant high-order bits
    * in the pixel data.  Values are in the range [1, bit_depth], and are
    * only specified for the channels in the pixel data.  The contents of
    * the low-order bits is not specified.  Data is valid if
    * (valid & PNG_INFO_sBIT) is non-zero.
    *}
   sig_bit: TPng_Color_8;  // significant bits in color channels

   {* The tRNS chunk supplies transparency data for paletted images and
    * other image types that don't need a full alpha channel.  There are
    * "num_trans" transparency values for a paletted image, stored in the
    * same order as the palette colors, starting from index 0.  Values
    * for the data are in the range [0, 255], ranging from fully transparent
    * to fully opaque, respectively.  For non-paletted images, there is a
    * single color specified which should be treated as fully transparent.
    * Data is valid if (valid & PNG_INFO_tRNS) is non-zero.
    *}
   trans: PByte; // transparent values for paletted image
   trans_values: TPng_Color_16; // transparent color for non-palette image

   {* The bKGD chunk gives the suggested image background color if the
    * display program does not have its own background color and the image
    * is needs to composited onto a background before display.  The colors
    * in "background" are normally in the same color space/depth as the
    * pixel data.  Data is valid if (valid & PNG_INFO_bKGD) is non-zero.
    *}
   background: TPng_Color_16;

   {* The oFFs chunk gives the offset in "offset_unit_type" units rightwards
    * and downwards from the top-left corner of the display, page, or other
    * application-specific co-ordinate space.  See the PNG_OFFSET_ defines
    * below for the unit types.  Valid if (valid & PNG_INFO_oFFs) non-zero.
    *}
   x_offset:         Cardinal; // x offset on page
   y_offset:         Cardinal; // y offset on page
   offset_unit_type: Byte;     // offset units type

   {* The pHYs chunk gives the physical pixel density of the image for
    * display or printing in "phys_unit_type" units (see PNG_RESOLUTION_
    * defines below).  Data is valid if (valid & PNG_INFO_pHYs) is non-zero.
    *}
   x_pixels_per_unit: Cardinal;  // horizontal pixel density
   y_pixels_per_unit: Cardinal;  // vertical pixel density
   phys_unit_type:    Byte;      // resolution type (see PNG_RESOLUTION_ below)

   {* The hIST chunk contains the relative frequency or importance of the
    * various palette entries, so that a viewer can intelligently select a
    * reduced-color palette, if required.  Data is an array of "num_palette"
    * values in the range [0,65535]. Data valid if (valid & PNG_INFO_hIST)
    * is non-zero.
    *}
   hist: PWord;

   {* The cHRM chunk describes the CIE color characteristics of the monitor
    * on which the PNG was created.  This data allows the viewer to do gamut
    * mapping of the input image to ensure that the viewer sees the same
    * colors in the image as the creator.  Values are in the range
    * [0.0, 0.8].  Data valid if (valid & PNG_INFO_cHRM) non-zero.
    *}
   x_white: Single;
   y_white: Single;
   x_red:   Single;
   y_red:   Single;
   x_green: Single;
   y_green: Single;
   x_blue:  Single;
   y_blue:  Single;

   {* The pCAL chunk describes a transformation between the stored pixel
    * values and original physcical data values used to create the image.
    * The integer range [0, 2^bit_depth - 1] maps to the floating-point
    * range given by [pcal_X0, pcal_X1], and are further transformed by a
    * (possibly non-linear) transformation function given by "pcal_type"
    * and "pcal_params" into "pcal_units".  Please see the PNG_EQUATION_
    * defines below, and the PNG-Group's Scientific Visualization extension
    * chunks document png-scivis-19970203 for a complete description of the
    * transformations and how they should be implemented, as well as the
    * png-extensions document for a description of the ASCII parameter
    * strings.  Data values are valid if (valid & PNG_INFO_pCAL) non-zero.
    *}
   pcal_purpose: PChar;     // pCAL chunk description string
   pcal_X0:      Integer;   // minimum value
   pcal_X1:      Integer;   // maximum value
   pcal_units:   PChar;     // Latin-1 string giving physical units
   pcal_params:  PPChar;    // ASCII strings containing parameter values
   pcal_type:    Byte;      // equation type (see PNG_EQUATION_ below)
   pcal_nparams: Byte;      // number of parameters given in pcal_params
end;
type PPng_Info = ^TPng_Info;
type PPPng_Info = ^PPng_Info;

{* This is used for the transformation routines, as some of them
 * change these values for the row.  It also should enable using
 * the routines for other purposes.
 *}
type TPng_Row_Info = record
   width:       Cardinal; // width of row
   rowbytes:    Cardinal; // number of bytes in row
   color_type:  Byte;     // color type of row
   bit_depth:   Byte;     // bit depth of row
   channels:    Byte;     // number of channels (1, 2, 3, or 4)
   pixel_depth: Byte;     // bits per pixel (depth * channels)
end;
type PPng_Row_Info = ^TPng_Row_Info;
type PPPng_Row_Info = ^PPng_Row_Info;

{* The structure that holds the information to read and write PNG files.
 * The only people who need to care about what is inside of this are the
 * people who will be modifying the library for their own special needs.
 * It should NOT be accessed directly by an application, except to store
 * the jmp_buf.
 *}
type TPng_Struct = record
   jmpbuf: array[0..10] of Integer; // used in png_error
   error_fn: Pointer;    // function for printing errors and aborting
   warning_fn: Pointer;  // function for printing warnings
   error_ptr: Pointer;       // user supplied struct for error functions
   write_data_fn: Pointer;  // function for writing output data
   read_data_fn: Pointer;   // function for reading input data
   read_user_transform_fn: Pointer; // user read transform
   write_user_transform_fn: Pointer; // user write transform
   io_ptr: Integer;         // ptr to application struct for I/O functions

   mode: Cardinal;          // tells us where we are in the PNG file
   flags: Cardinal;         // flags indicating various things to libpng
   transformations: Cardinal; // which transformations to perform

   zstream: Pointer;          // pointer to decompression structure (below)
   zbuf: PByte;            // buffer for zlib
   zbuf_size: Integer;      // size of zbuf
   zlib_level: Integer;            // holds zlib compression level
   zlib_method: Integer;           // holds zlib compression method
   zlib_window_bits: Integer;      // holds zlib compression window bits
   zlib_mem_level: Integer;        // holds zlib compression memory level
   zlib_strategy: Integer;         // holds zlib compression strategy

   width: Cardinal;         // width of image in pixels
   height: Cardinal;        // height of image in pixels
   num_rows: Cardinal;      // number of rows in current pass
   usr_width: Cardinal;     // width of row at start of write
   rowbytes: Cardinal;      // size of row in bytes
   irowbytes: Cardinal;     // size of current interlaced row in bytes
   iwidth: Cardinal;        // width of current interlaced row in pixels
   row_number: Cardinal;    // current row in interlace pass
   prev_row: PByte;        // buffer to save previous (unfiltered) row
   row_buf: PByte;         // buffer to save current (unfiltered) row
   sub_row: PByte;         // buffer to save "sub" row when filtering
   up_row: PByte;          // buffer to save "up" row when filtering
   avg_row: PByte;         // buffer to save "avg" row when filtering
   paeth_row: PByte;       // buffer to save "Paeth" row when filtering
   row_info: TPng_Row_Info;     // used for transformation routines

   idat_size: Cardinal;     // current IDAT size for read
   crc: Cardinal;           // current chunk CRC value
   palette: PPng_Color;        // palette from the input file
   num_palette: Word;   // number of color entries in palette
   num_trans: Word;     // number of transparency values
   chunk_name: array[0..4] of Byte;   // null-terminated name of current chunk
   compression: Byte;      // file compression type (always 0)
   filter: Byte;           // file filter type (always 0)
   interlaced: Byte;       // PNG_INTERLACE_NONE, PNG_INTERLACE_ADAM7
   pass: Byte;             // current interlace pass (0 - 6)
   do_filter: Byte;        // row filter flags (see PNG_FILTER_ below )
   color_type: Byte;       // color type of file
   bit_depth: Byte;        // bit depth of file
   usr_bit_depth: Byte;    // bit depth of users row
   pixel_depth: Byte;      // number of bits per pixel
   channels: Byte;         // number of channels in file
   usr_channels: Byte;     // channels at start of write
   sig_bytes: Byte;        // magic bytes read/written from start of file

   filler: Byte;           // filler byte for 24->32-bit pixel expansion
   background_gamma_type: Byte;
   background_gamma: Single;
   background: TPng_Color_16;   // background color in screen gamma space
   background_1: TPng_Color_16; // background normalized to gamma 1.0
   output_flush_fn: Pointer;// Function for flushing output
   flush_dist: Cardinal;    // how many rows apart to flush, 0 - no flush
   flush_rows: Cardinal;    // number of rows written since last flush
   gamma_shift: Integer;      // number of "insignificant" bits 16-bit gamma
   gamma: Single;          // file gamma value
   screen_gamma: Single;   // screen gamma value (display_gamma/viewing_gamma
   gamma_table: PByte;     // gamma table for 8 bit depth files
   gamma_from_1: PByte;    // converts from 1.0 to screen
   gamma_to_1: PByte;      // converts from file to 1.0
   gamma_16_table: PPWord; // gamma table for 16 bit depth files
   gamma_16_from_1: PPWord; // converts from 1.0 to screen
   gamma_16_to_1: PPWord; // converts from file to 1.0
   sig_bit: TPng_Color_8;       // significant bits in each available channel
   shift: TPng_Color_8;         // shift for significant bit tranformation
   trans: PByte;           // transparency values for paletted files
   trans_values: TPng_Color_16; // transparency values for non-paletted files
   read_row_fn: Pointer;   // called after each row is decoded
   write_row_fn: Pointer; // called after each row is encoded
   info_fn: Pointer; // called after header data fully read
   row_fn: Pointer;   // called after each prog. row is decoded
   end_fn: Pointer;   // called after image is complete
   save_buffer_ptr: PByte;        // current location in save_buffer
   save_buffer: PByte;            // buffer for previously read data
   current_buffer_ptr: PByte;     // current location in current_buffer
   current_buffer: PByte;         // buffer for recently used data
   push_length: Cardinal;          // size of current input chunk
   skip_length: Cardinal;          // bytes to skip in input data
   save_buffer_size: Integer;      // amount of data now in save_buffer
   save_buffer_max: Integer;       // total size of save_buffer
   buffer_size: Integer;           // total amount of available input data
   current_buffer_size: Integer;   // amount of data now in current_buffer
   process_mode: Integer;                 // what push library is currently doing
   cur_palette: Integer;                  // current push library palette index
   current_text_size: Integer;     // current size of text input data
   current_text_left: Integer;     // how much text left to read in input
   current_text: PByte;           // current text chunk buffer
   current_text_ptr: PByte;       // current location in current_text
   palette_lookup: PByte;         // lookup table for dithering
   dither_index: PByte;           // index translation for palette files
   hist: PWord;                // histogram
   heuristic_method: Byte;        // heuristic for row filter selection
   num_prev_filters: Byte;        // number of weights for previous rows
   prev_filters: PByte;           // filter type(s) of previous row(s)
   filter_weights: PWord;      // weight(s) for previous line(s)
   inv_filter_weights: PWord;  // 1/weight(s) for previous line(s)
   filter_costs: PWord;        // relative filter calculation cost
   inv_filter_costs: PWord;    // 1/relative filter calculation cost
   time_buffer: PByte;            // String to hold RFC 1123 time text
end;
type PPng_Struct = ^TPng_Struct;
type PPPng_Struct = ^PPng_Struct;

type TPng_RW_Fn = procedure(png_ptr: PPng_Struct; data: PByte; length: Integer);

{* Here are the function definitions most commonly used.  This is not
 * the place to find out how to use libpng.  See libpng.txt for the
 * full explanation, see example.c for the summary.  This just provides
 * a simple one line of the use of each function.
 *}

{* Tell lib we have already handled the first <num_bytes> magic bytes.
 * Handling more than 8 bytes from the beginning of the file is an error.
 *}
procedure png_set_sig_bytes(png_ptr: PPng_Struct; num_bytes: Integer); cdecl; external Lib;

{* Check sig[start] through sig[start + num_to_check - 1] to see if it's a
 * PNG file.  Returns zero if the supplied bytes match the 8-byte PNG
 * signature, and non-zero otherwise.  Having num_to_check == 0 or
 * start > 7 will always fail (ie return non-zero).
 *}
function png_sig_cmp(sig: PByte; start, num_to_check: Integer): Integer; cdecl; external Lib;

{* Simple signature checking function.  This is the same as calling
 * png_check_sig(sig, n) := !png_sig_cmp(sig, 0, n).
 *}
function png_check_sig(sig: PByte; num: Integer): Integer; cdecl; external Lib;

{* Allocate and initialize png_ptr struct for reading, and any other memory. *}
function png_create_read_struct(user_png_ver: PChar;
         error_ptr, error_fn, warn_fn: Pointer): PPng_Struct; cdecl; external Lib;

{* Allocate and initialize png_ptr struct for reading, and any other memory *}
function png_create_write_struct(user_png_ver: PChar;
         error_ptr, error_fn, warn_fn: Pointer): PPng_Struct; cdecl; external Lib;

{* Write a PNG chunk - size, type, (optional) data, CRC. *}
procedure png_write_chunk(png_ptr: PPng_Struct;
          chunk_name, data: PByte; length: Integer); cdecl; external Lib;

{* Write the start of a PNG chunk - length and chunk name. *}
procedure png_write_chunk_start(png_ptr: PPng_Struct;
          chunk_name: PByte; length: Cardinal); cdecl; external Lib;

{* Write the data of a PNG chunk started with png_write_chunk_start(). *}
procedure png_write_chunk_data(png_ptr: PPng_Struct;
          data: PByte; length: Integer); cdecl; external Lib;

{* Finish a chunk started with png_write_chunk_start() (includes CRC). *}
procedure png_write_chunk_end(png_ptr: PPng_Struct); cdecl; external Lib;

{* Allocate and initialize the info structure *}
function png_create_info_struct(png_ptr: PPng_Struct): PPng_Info; cdecl; external Lib;

{* Writes all the PNG information before the image. *}
procedure png_write_info(png_ptr: PPng_Struct; info_ptr: PPng_Info); cdecl; external Lib;

{* read the information before the actual image data. *}
procedure png_read_info(png_ptr: PPng_Struct; info_ptr: PPng_Info); cdecl; external Lib;

function png_convert_to_rfc1123(png_ptr: PPng_Struct;
         ptime: PPng_Time): PChar; cdecl; external Lib;

{* convert from a struct tm to png_time *}
procedure png_convert_from_struct_tm(ptime: PPng_Time;
          ttime: PTM); cdecl; external Lib;

{* convert from time_t to png_time.  Uses gmtime() *}
procedure png_convert_from_time_t(ptime: PPng_Time;
          ttime: Integer); cdecl; external Lib;

{* Expand data to 24 bit RGB, or 8 bit grayscale, with alpha if available. *}
procedure png_set_expand(png_ptr: PPng_Struct); cdecl; external Lib;

{* Use blue, green, red order for pixels. *}
procedure png_set_bgr(png_ptr: PPng_Struct); cdecl; external Lib;

{* Expand the grayscale to 24 bit RGB if necessary. *}
procedure png_set_gray_to_rgb(png_ptr: PPng_Struct); cdecl; external Lib;

{* Reduce RGB to grayscale. (Not yet implemented) *}
procedure png_set_rgb_to_gray(png_ptr: PPng_Struct); cdecl; external Lib;

procedure png_build_grayscale_palette(bit_depth: Integer;
          palette: PPng_Color); cdecl; external Lib;

procedure png_set_strip_alpha(png_ptr: PPng_Struct); cdecl; external Lib;

procedure png_set_swap_alpha(png_ptr: PPng_Struct); cdecl; external Lib;

procedure png_set_invert_alpha(png_ptr: PPng_Struct); cdecl; external Lib;

{* Add a filler byte to 24-bit RGB images. *}
procedure png_set_filler(png_ptr: PPng_Struct; filler: Cardinal;
          flags: Integer); cdecl; external Lib;

{* Swap bytes in 16 bit depth files. *}
procedure png_set_swap(png_ptr: PPng_Struct); cdecl; external Lib;

{* Use 1 byte per pixel in 1, 2, or 4 bit depth files. *}
procedure png_set_packing(png_ptr: PPng_Struct); cdecl; external Lib;

{* Swap packing order of pixels in bytes. *}
procedure png_set_packswap(png_ptr: PPng_Struct); cdecl; external Lib;

{* Converts files to legal bit depths. *}
procedure png_set_shift(png_ptr: PPng_Struct;
          true_bits: PPng_Color_8); cdecl; external Lib;

{* Have the code handle the interlacing.  Returns the number of passes. *}
function png_set_interlace_handling(png_ptr: PPng_Struct): Integer; cdecl; external Lib;

{* Invert monocrome files *}
procedure png_set_invert_mono(png_ptr: PPng_Struct); cdecl; external Lib;

{* Handle alpha and tRNS by replacing with a background color. *}
procedure png_set_background(png_ptr: PPng_Struct;
          background_color: PPng_Color_16;
          background_gamma_code, need_expand: Integer;
          background_gamma: double); cdecl; external Lib;
const PNG_BACKGROUND_GAMMA_UNKNOWN: Integer = 0;
const PNG_BACKGROUND_GAMMA_SCREEN:  Integer = 1;
const PNG_BACKGROUND_GAMMA_FILE:    Integer = 2;
const PNG_BACKGROUND_GAMMA_UNIQUE:  Integer = 3;

{* strip the second byte of information from a 16 bit depth file. *}
procedure png_set_strip_16(png_ptr: PPng_Struct); cdecl; external Lib;

{* Turn on dithering, and reduce the palette to the number of colors available. *}
procedure png_set_dither(png_ptr: PPng_Struct;
          palette: PPng_Color; num_palette, maximum_colors: Integer;
          histogram: PWord; full_dither: Integer); cdecl; external Lib;

{* Handle gamma correction. Screen_gamma=(display_gamma/viewing_gamma) *}
procedure png_set_gamma(png_ptr: PPng_Struct;
          screen_gamma, default_file_gamma: Double); cdecl; external Lib;

{* Set how many lines between output flushes - 0 for no flushing *}
procedure png_set_flush(png_ptr: PPng_Struct;
          nrows: Integer); cdecl; external Lib;

{* Flush the current PNG output buffer *}
procedure png_write_flush(png_ptr: PPng_Struct); cdecl; external Lib;

{* optional update palette with requested transformations *}
procedure png_start_read_image(png_ptr: PPng_Struct); cdecl; external Lib;

{* optional call to update the users info structure *}
procedure png_read_update_info(png_ptr: PPng_Struct;
          info_ptr: PPng_Info); cdecl; external Lib;

{* read a one or more rows of image data.*}
procedure png_read_rows(png_ptr: PPng_Struct; row, display_row: PPByte;
          num_rows: Cardinal); cdecl; external Lib;

{* read a row of data.*}
procedure png_read_row(png_ptr: PPng_Struct; row, display_row: PByte); cdecl; external Lib;

{* read the whole image into memory at once. *}
procedure png_read_image(png_ptr: PPng_Struct; image: PPByte); cdecl; external Lib;

{* write a row of image data *}
procedure png_write_row(png_ptr: PPng_Struct; row: PByte); cdecl; external Lib;

{* write a few rows of image data *}
procedure png_write_rows(png_ptr: PPng_Struct; row: PPByte;
          num_rows: Cardinal); cdecl; external Lib;

{* write the image data *}
procedure png_write_image(png_ptr: PPng_Struct; image: PPByte); cdecl; external Lib;

{* writes the end of the PNG file. *}
procedure png_write_end(png_ptr: PPng_Struct; info_ptr: PPng_Info); cdecl; external Lib;

{* read the end of the PNG file. *}
procedure png_read_end(png_ptr: PPng_Struct; info_ptr: PPng_Info); cdecl; external Lib;

{* free any memory associated with the png_info_struct *}
procedure png_destroy_info_struct(png_ptr: PPng_Struct;
          info_ptr_ptr: PPPng_Info); cdecl; external Lib;

{* free any memory associated with the png_struct and the png_info_structs *}
procedure png_destroy_read_struct(png_ptr_ptr: PPPng_Struct;
          info_ptr_ptr, end_info_ptr_ptr: PPPng_Info); cdecl; external Lib;

{* free any memory associated with the png_struct and the png_info_structs *}
procedure png_destroy_write_struct(png_ptr_ptr: PPPng_Struct;
          info_ptr_ptr: PPPng_Info); cdecl; external Lib;

{* set the libpng method of handling chunk CRC errors *}
procedure png_set_crc_action(png_ptr: PPng_Struct;
          crit_action, ancil_action: Integer); cdecl; external Lib;

{* Values for png_set_crc_action() to say how to handle CRC errors in
 * ancillary and critical chunks, and whether to use the data contained
 * therein.  Note that it is impossible to "discard" data in a critical
 * chunk.  For versions prior to 0.90, the action was always error/quit,
 * whereas in version 0.90 and later, the action for CRC errors in ancillary
 * chunks is warn/discard.  These values should NOT be changed.
 *
 *      value                       action:critical     action:ancillary
 *}
const PNG_CRC_DEFAULT:      Integer = 0;  // error/quit         warn/discard data
const PNG_CRC_ERROR_QUIT:   Integer = 1;  // error/quit         error/quit
const PNG_CRC_WARN_DISCARD: Integer = 2;  // (INVALID)          warn/discard data
const PNG_CRC_WARN_USE:     Integer = 3;  // warn/use data      warn/use data
const PNG_CRC_QUIET_USE:    Integer = 4;  // quiet/use data     quiet/use data
const PNG_CRC_NO_CHANGE:    Integer = 5;  // use current value  use current value

{* These functions give the user control over the scan-line filtering in
 * libpng and the compression methods used by zlib.  These functions are
 * mainly useful for testing, as the defaults should work with most users.
 * Those users who are tight on memory or want faster performance at the
 * expense of compression can modify them.  See the compression library
 * header file (zlib.h) for an explination of the compression functions.
 *}

{* set the filtering method(s) used by libpng.  Currently, the only valid
 * value for "method" is 0.
 *}
procedure png_set_filter(png_ptr: PPng_Struct;
          method, filters: Integer); cdecl; external Lib;

{* Flags for png_set_filter() to say which filters to use.  The flags
 * are chosen so that they don't conflict with real filter types
 * below, in case they are supplied instead of the #defined constants.
 * These values should NOT be changed.
 *}
const PNG_NO_FILTERS:   Integer = $00;
const PNG_FILTER_NONE:  Integer = $08;
const PNG_FILTER_SUB:   Integer = $10;
const PNG_FILTER_UP:    Integer = $20;
const PNG_FILTER_AVG:   Integer = $40;
const PNG_FILTER_PAETH: Integer = $80;
const PNG_ALL_FILTERS:  Integer = $F8;

{* Filter values (not flags) - used in pngwrite.c, pngwutil.c for now.
 * These defines should NOT be changed.
 *}
const PNG_FILTER_VALUE_NONE:  Integer = 0;
const PNG_FILTER_VALUE_SUB:   Integer = 1;
const PNG_FILTER_VALUE_UP:    Integer = 2;
const PNG_FILTER_VALUE_AVG:   Integer = 3;
const PNG_FILTER_VALUE_PAETH: Integer = 4;
const PNG_FILTER_VALUE_LAST:  Integer = 5;

{* The "heuristic_method" is given by one of the PNG_FILTER_HEURISTIC_
 * defines, either the default (minimum-sum-of-absolute-differences), or
 * the experimental method (weighted-minimum-sum-of-absolute-differences).
 *
 * Weights are factors >= 1.0, indicating how important it is to keep the
 * filter type consistent between rows.  Larger numbers mean the current
 * filter is that many times as likely to be the same as the "num_weights"
 * previous filters.  This is cumulative for each previous row with a weight.
 * There needs to be "num_weights" values in "filter_weights", or it can be
 * NULL if the weights aren't being specified.  Weights have no influence on
 * the selection of the first row filter.  Well chosen weights can (in theory)
 * improve the compression for a given image.
 *
 * Costs are factors >= 1.0 indicating the relative decoding costs of a
 * filter type.  Higher costs indicate more decoding expense, and are
 * therefore less likely to be selected over a filter with lower computational
 * costs.  There needs to be a value in "filter_costs" for each valid filter
 * type (given by PNG_FILTER_VALUE_LAST), or it can be NULL if you aren't
 * setting the costs.  Costs try to improve the speed of decompression without
 * unduly increasing the compressed image size.
 *
 * A negative weight or cost indicates the default value is to be used, and
 * values in the range [0.0, 1.0) indicate the value is to remain unchanged.
 * The default values for both weights and costs are currently 1.0, but may
 * change if good general weighting/cost heuristics can be found.  If both
 * the weights and costs are set to 1.0, this degenerates the WEIGHTED method
 * to the UNWEIGHTED method, but with added encoding time/computation.
 *}
procedure png_set_filter_heuristics(png_ptr: PPng_Struct;
          heuristic_method, num_weights: Integer;
          filter_weights, filter_costs: PDouble); cdecl; external Lib;

{* Heuristic used for row filter selection.  These defines should NOT be
 * changed.
 *}
const PNG_FILTER_HEURISTIC_DEFAULT:    Integer = 0; // Currently "UNWEIGHTED"
const PNG_FILTER_HEURISTIC_UNWEIGHTED: Integer = 1; // Used by libpng < 0.95
const PNG_FILTER_HEURISTIC_WEIGHTED:   Integer = 2; // Experimental feature
const PNG_FILTER_HEURISTIC_LAST:       Integer = 3; // Not a valid value

{* Set the library compression level.  Currently, valid values range from
 * 0 - 9, corresponding directly to the zlib compression levels 0 - 9
 * (0 - no compression, 9 - "maximal" compression).  Note that tests have
 * shown that zlib compression levels 3-6 usually perform as well as level 9
 * for PNG images, and do considerably fewer caclulations.  In the future,
 * these values may not correspond directly to the zlib compression levels.
 *}
procedure png_set_compression_level(png_ptr: PPng_Struct;
          level: Integer); cdecl; external Lib;

procedure png_set_compression_mem_level(png_ptr: PPng_Struct;
          mem_level: Integer); cdecl; external Lib;

procedure png_set_compression_strategy(png_ptr: PPng_Struct;
          strategy: Integer); cdecl; external Lib;

procedure png_set_compression_window_bits(png_ptr: PPng_Struct;
          window_bits: Integer); cdecl; external Lib;

procedure png_set_compression_method(png_ptr: PPng_Struct;
          method: Integer); cdecl; external Lib;

{* These next functions are called for input/output, memory, and error
 * handling.  They are in the file pngrio.c, pngwio.c, and pngerror.c,
 * and call standard C I/O routines such as fread(), fwrite(), and
 * fprintf().  These functions can be made to use other I/O routines
 * at run time for those applications that need to handle I/O in a
 * different manner by calling png_set_???_fn().  See libpng.txt for
 * more information.
 *}

{* Initialize the input/output for the PNG file to the default functions. *}
procedure png_init_io(png_ptr: PPng_Struct; fp: Pointer); cdecl; external Lib;

{* Replace the (error and abort), and warning functions with user
 * supplied functions.  If no messages are to be printed you must still
 * write and use replacement functions. The replacement error_fn should
 * still do a longjmp to the last setjmp location if you are using this
 * method of error handling.  If error_fn or warning_fn is NULL, the
 * default function will be used.
 *}
procedure png_set_error_fn(png_ptr: PPng_Struct;
          error_ptr, error_fn, warning_fn: Pointer); cdecl; external Lib;

{* Return the user pointer associated with the error functions *}
function png_get_error_ptr(png_ptr: PPng_Struct): Pointer; cdecl; external Lib;

{* Replace the default data output functions with a user supplied one(s).
 * If buffered output is not used, then output_flush_fn can be set to NULL.
 * If PNG_WRITE_FLUSH_SUPPORTED is not defined at libpng compile time
 * output_flush_fn will be ignored (and thus can be NULL).
 *}
procedure png_set_write_fn(png_ptr: PPng_Struct; io_ptr: Integer;
          write_data_fn: TPng_RW_Fn; output_flush_fn: Pointer); cdecl; external Lib;

{* Replace the default data input function with a user supplied one. *}
procedure png_set_read_fn(png_ptr: PPng_Struct;
          io_ptr: Integer; read_data_fn: TPng_RW_Fn); cdecl; external Lib;

{* Return the user pointer associated with the I/O functions *}
function png_get_io_ptr(png_ptr: PPng_Struct): Pointer; cdecl; external Lib;

procedure png_set_read_status_fn(png_ptr: PPng_Struct;
          read_row_fn: Pointer); cdecl; external Lib;

procedure png_set_write_status_fn(png_ptr: PPng_Struct;
          write_row_fn: Pointer); cdecl; external Lib;

procedure png_set_read_user_transform_fn(png_ptr: PPng_Struct;
          read_user_transform_fn: Pointer); cdecl; external Lib;

procedure png_set_write_user_transform_fn(png_ptr: PPng_Struct;
          write_user_transform_fn: Pointer); cdecl; external Lib;

{* Sets the function callbacks for the push reader, and a pointer to a
 * user-defined structure available to the callback functions.
 *}
procedure png_set_progressive_read_fn(png_ptr: PPng_Struct;
          progressive_ptr, info_fn, row_fn, end_fn: Pointer); cdecl; external Lib;

{* returns the user pointer associated with the push read functions *}
function png_get_progressive_ptr(png_ptr: PPng_Struct): Pointer; cdecl; external Lib;

{* function to be called when data becomes available *}
procedure png_process_data(png_ptr: PPng_Struct; info_ptr: Pointer;
          buffer: PByte; buffer_size: Integer); cdecl; external Lib;

{* function which combines rows.  Not very much different than the
 * png_combine_row() call.  Is this even used?????
 *}
procedure png_progressive_combine_row(png_ptr: PPng_Struct;
          old_row, new_row: PByte); cdecl; external Lib;

function png_malloc(png_ptr: PPng_Struct; size: Cardinal): Pointer; cdecl; external Lib;

{* frees a pointer allocated by png_malloc() *}
procedure png_free(png_ptr: PPng_Struct; ptr: Pointer); cdecl; external Lib;

function png_memcpy_check(png_ptr: PPng_Struct;
         s1, s2: Pointer; size: Cardinal): Pointer; cdecl; external Lib;

function png_memset_check(png_ptr: PPng_Struct; s1: Pointer;
         value: Integer; size: Cardinal): Pointer; cdecl; external Lib;

{* debugging versions of png_malloc() and png_free() *}
function png_debug_malloc(png_ptr: PPng_Struct;
         size: Cardinal): Pointer; cdecl; external Lib;
procedure png_debug_free(png_ptr: PPng_Struct;
          ptr: Pointer); cdecl; external Lib;

{* Fatal error in PNG image of libpng - can't continue *}
procedure png_error(png_ptr: PPng_Struct; error: PChar); cdecl; external Lib;

{* The same, but the chunk name is prepended to the error string. *}
procedure png_chunk_error(png_ptr: PPng_Struct; error: PChar); cdecl; external Lib;

{* Non-fatal error in libpng.  Can continue, but may have a problem. *}
procedure png_warning(png_ptr: PPng_Struct; msg: PChar); cdecl; external Lib;

{* Non-fatal error in libpng, chunk name is prepended to message. *}
procedure png_chunk_warning(png_ptr: PPng_Struct; msg: PChar); cdecl; external Lib;

{* The png_set_<chunk> functions are for storing values in the png_info_struct.
 * Similarly, the png_get_<chunk> calls are used to read values from the
 * png_info_struct, either storing the parameters in the passed variables, or
 * setting pointers into the png_info_struct where the data is stored.  The
 * png_get_<chunk> functions return a non-zero value if the data was available
 * in info_ptr, or return zero and do not change any of the parameters if the
 * data was not available.
 *
 * These functions should be used instead of directly accessing png_info
 * to avoid problems with future changes in the size and internal layout of
 * png_info_struct.
 *}
{* Returns "flag" if chunk data is valid in info_ptr. *}
function png_get_valid(png_ptr: PPng_Struct; info_ptr: PPng_Info;
         flag: Cardinal): Cardinal; cdecl; external Lib;

{* Returns number of bytes needed to hold a transformed row. *}
function png_get_rowbytes(png_ptr: PPng_Struct;
         info_ptr: PPng_Info): Cardinal; cdecl; external Lib;

{* Returns number of color channels in image. *}
function png_get_channels(png_ptr: PPng_Struct;
         info_ptr: PPng_Info): Byte; cdecl; external Lib;

{* Returns image width in pixels. *}
function png_get_image_width(png_ptr: PPng_Struct;
         info_ptr: PPng_Info): Cardinal; cdecl; external Lib;

{* Returns image height in pixels. *}
function png_get_image_height(png_ptr: PPng_Struct;
         info_ptr: PPng_Info): Cardinal; cdecl; external Lib;

{* Returns image bit_depth. *}
function png_get_bit_depth(png_ptr: PPng_Struct;
         info_ptr: PPng_Info): Byte; cdecl; external Lib;

{* Returns image color_type. *}
function png_get_color_type(png_ptr: PPng_Struct;
         info_ptr: PPng_Info): Byte; cdecl; external Lib;

{* Returns image filter_type. *}
function png_get_filter_type(png_ptr: PPng_Struct;
         info_ptr: PPng_Info): Byte; cdecl; external Lib;

{* Returns image interlace_type. *}
function png_get_interlace_type(png_ptr: PPng_Struct;
         info_ptr: PPng_Info): Byte; cdecl; external Lib;

{* Returns image compression_type. *}
function png_get_compression_type(png_ptr: PPng_Struct;
         info_ptr: PPng_Info): Byte; cdecl; external Lib;

{* Returns image resolution in pixels per meter, from pHYs chunk data. *}
function png_get_pixels_per_meter(png_ptr: PPng_Struct;
         info_ptr: PPng_Info): Cardinal; cdecl; external Lib;
function png_get_x_pixels_per_meter(png_ptr: PPng_Struct;
         info_ptr: PPng_Info): Cardinal; cdecl; external Lib;
function png_get_y_pixels_per_meter(png_ptr: PPng_Struct;
         info_ptr: PPng_Info): Cardinal; cdecl; external Lib;

{* Returns pixel aspect ratio, computed from pHYs chunk data.  *}
function png_get_pixel_aspect_ratio(png_ptr: PPng_Struct;
         info_ptr: PPng_Info): Single; cdecl; external Lib;

{* Returns image x, y offset in pixels or microns, from oFFs chunk data. *}
function png_get_x_offset_pixels(png_ptr: PPng_Struct;
         info_ptr: PPng_Info): Cardinal; cdecl; external Lib;
function png_get_y_offset_pixels(png_ptr: PPng_Struct;
         info_ptr: PPng_Info): Cardinal; cdecl; external Lib;
function png_get_x_offset_microns(png_ptr: PPng_Struct;
         info_ptr: PPng_Info): Cardinal; cdecl; external Lib;
function png_get_y_offset_microns(png_ptr: PPng_Struct;
         info_ptr: PPng_Info): Cardinal; cdecl; external Lib;

{* Returns pointer to signature string read from PNG header *}
function png_get_signature(png_ptr: PPng_Struct;
         info_ptr: PPng_Info): PByte; cdecl; external Lib;

function png_get_bKGD(png_ptr: PPng_Struct; info_ptr: PPng_Info;
         background: PPng_Color_16): Cardinal; cdecl; external Lib;

procedure png_set_bKGD(png_ptr: PPng_Struct; info_ptr: PPng_Info;
          background: PPng_Color_16); cdecl; external Lib;

function png_get_cHRM(png_ptr: PPng_Struct; info_ptr: PPng_Info;
         white_x, white_y, red_x, red_y, green_x, green_y, blue_x,
         blue_y: PDouble): Cardinal; cdecl; external Lib;

procedure png_set_cHRM(png_ptr: PPng_Struct; info_ptr: PPng_Info;
          white_x, white_y, red_x, red_y, green_x, green_y, blue_x,
          blue_y: Double); cdecl; external Lib;

function png_get_gAMA(png_ptr: PPng_Struct; info_ptr: PPng_Info;
         file_gamma: PDouble): Cardinal; cdecl; external Lib;

procedure png_set_gAMA(png_ptr: PPng_Struct; info_ptr: PPng_Info;
          file_gamma: Double); cdecl; external Lib;

function png_get_hIST(png_ptr: PPng_Struct; info_ptr: PPng_Info;
         hist: PWord): Cardinal; cdecl; external Lib;

procedure png_set_hIST(png_ptr: PPng_Struct; info_ptr: PPng_Info;
          hist: PWord); cdecl; external Lib;

function png_get_IHDR(png_ptr: PPng_Struct; info_ptr: PPng_Info;
         width, height: PCardinal; bit_depth, color_type, interlace_type,
         compression_type, filter_type: PInteger): Cardinal; cdecl; external Lib;

procedure png_set_IHDR(png_ptr: PPng_Struct; info_ptr: PPng_Info;
          width, height: Cardinal; bit_depth, color_type, interlace_type,
          compression_type, filter_type: Integer); cdecl; external Lib;

function png_get_oFFs(png_ptr: PPng_Struct; info_ptr: PPng_Info;
         offset_x, offset_y: PCardinal; unit_type: PInteger): Cardinal; cdecl; external Lib;

procedure png_set_oFFs(png_ptr: PPng_Struct; info_ptr: PPng_Info;
          offset_x, offset_y: Cardinal; unit_type: Integer); cdecl; external Lib;

function png_get_pCAL(png_ptr: PPng_Struct; info_ptr: PPng_Info;
         purpose: PPChar; X0, X1, typ, nparams: PInteger;
         units, params: PPChar): Cardinal; cdecl; external Lib;

procedure png_set_pCAL(png_ptr: PPng_Struct; info_ptr: PPng_Info;
          purpose: PChar; X0, X1, typ, nparams: Integer;
          units: PChar; params: PPChar); cdecl; external Lib;

function png_get_pHYs(png_ptr: PPng_Struct; info_ptr: PPng_Info;
         res_x, res_y: PCardinal; unit_type: PInteger): Cardinal; cdecl; external Lib;

procedure png_set_pHYs(png_ptr: PPng_Struct; info_ptr: PPng_Info;
          res_x, res_y: Cardinal; unit_type: Integer); cdecl; external Lib;

function png_get_PLTE(png_ptr: PPng_Struct; info_ptr: PPng_Info;
         palette: PPPng_Color; num_palette: PInteger): Cardinal; cdecl; external Lib;

procedure png_set_PLTE(png_ptr: PPng_Struct; info_ptr: PPng_Info;
          palette: PPng_Color; num_palette: Integer); cdecl; external Lib;

function png_get_sBIT(png_ptr: PPng_Struct; info_ptr: PPng_Info;
         sig_bit: PPPng_Color_8): Cardinal; cdecl; external Lib;

procedure png_set_sBIT(png_ptr: PPng_Struct; info_ptr: PPng_Info;
          sig_bit: PPng_Color_8); cdecl; external Lib;

function png_get_sRGB(png_ptr: PPng_Struct; info_ptr: PPng_Info;
         intent: PInteger): Cardinal; cdecl; external Lib;

procedure png_set_sRGB(png_ptr: PPng_Struct; info_ptr: PPng_Info;
          intent: Integer); cdecl; external Lib;

procedure png_set_sRGB_gAMA_and_cHRM(png_ptr: PPng_Struct;
          info_ptr: PPng_Info; intent: Integer); cdecl; external Lib;

{* png_get_text also returns the number of text chunks in text_ptr *}
function png_get_text(png_ptr: PPng_Struct; info_ptr: PPng_Info;
         text_ptr: PPPng_Text; num_text: PInteger): Cardinal; cdecl; external Lib;

procedure png_set_text(png_ptr: PPng_Struct; info_ptr: PPng_Info;
          text_ptr: PPng_Text; num_text: Integer); cdecl; external Lib;

function png_get_tIME(png_ptr: PPng_Struct; info_ptr: PPng_Info;
         mod_time: PPPng_Time): Cardinal; cdecl; external Lib;

procedure png_set_tIME(png_ptr: PPng_Struct; info_ptr: PPng_Info;
          mod_time: PPng_Time); cdecl; external Lib;

function png_get_tRNS(png_ptr: PPng_Struct; info_ptr: PPng_Info;
         trans: PPByte; num_trans: PInteger;
         trans_values: PPPng_Color_16): Cardinal; cdecl; external Lib;

procedure png_set_tRNS(png_ptr: PPng_Struct; info_ptr: PPng_Info;
          trans: PByte; num_trans: Integer;
          trans_values: PPng_Color_16); cdecl; external Lib;

function png_open_file(fname, mode: PChar): Pointer; cdecl; external Lib;
function png_close_file(filep: Pointer): Integer; cdecl; external Lib;

implementation

end.
