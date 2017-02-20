unit PngDef;
{
   Dominique Louis ( Dominique@SavageSoftware.com.au )
   23 Novemebr 2000
   Added $IFDEF so that users can decide at compile time which version of the DLL they wish to use.
   This file has been partially updated to version 1.0.8 of PNGLIB.

   Dominique Louis ( Dominique@SavageSoftware.com.au )
   13 June 2000
   This file has been updated to version 1.0.6 of PNGLIB.
   More data structures and functions within the DLL have been added
   I have also added a few more Delphi style types.

   Uberto Barbini (uberto@usa.net)
   14 Dec 1999.
   This file contains all the Pascal data structures, and declarations of
   the procedures and functions you can call in the DLL.
}

interface

type
  png_uint_32 = Cardinal;
  png_int_32  = Longint;

  png_uint_16pp = ^png_uint_16p;
  png_uint_16p = ^png_uint_16;
  png_uint_16 = Word;

  png_int_16  = Smallint;

  png_bytepp  = ^png_bytep;
  png_bytep   = ^png_byte;
  png_byte    = Byte;

  png_doublep  = ^png_double;
  png_double   = double;

  png_size_t  = png_uint_32;

  png_charpp  = ^png_charp;
  png_charp   = PChar;

  png_voidp    = pointer;

  float       = single;
  int         = Integer;
  time_t       = Longint;
  png_fixed_point = png_int_32;
  int_gamma = png_fixed_point;

  user_error_ptr  = Pointer;

  png_colorpp = ^png_colorp;
  png_colorp = ^png_color;
  png_color = packed record
    red, green, blue: png_byte;
  end;
  TPngColor = png_color;

  png_color_16pp = ^png_color_16p;
  png_color_16p = ^png_color_16;
  png_color_16 = packed record
    index: png_byte;                 //used for palette files
    red, green, blue: png_uint_16;   //for use in red green blue files
    gray: png_uint_16;               //for use in grayscale files
  end;
  TPngColor16 = png_color_16;

  png_color_8pp = ^png_color_8p;
  png_color_8p = ^png_color_8;
  png_color_8 = packed record
    red, green, blue: png_byte;   //for use in red green blue files
    gray: png_byte;               //for use in grayscale files
    alpha: png_byte;              //for alpha channel files
  end;
  TPngColor8 = png_color_8;

 // The following two structures are used for the in-core representation
 // of sPLT chunks.
  png_sPLT_entrypp = ^png_sPLT_entryp;
  png_sPLT_entryp = ^png_sPLT_entry;
  png_sPLT_entry = packed record
    red       : png_uint_16;
    green     : png_uint_16;
    blue      : png_uint_16;
    alpha     : png_uint_16;
    frequency : png_uint_16;
  end;
  TPngsPLTEntry = png_sPLT_entry;

  png_sPLT_tpp = ^png_sPLT_tp;
  png_sPLT_tp = ^png_sPLT_t;
  png_sPLT_t = packed record
    name : png_charp;                // palette name *}
    depth : png_byte;                // depth of palette samples *}
    entries : png_sPLT_entryp;       // palette entries *}
    nentries : png_int_32;           // number of palette entries *}
  end;
  TPngsPLTT = png_sPLT_t;

  png_textpp = ^png_textp;
  png_textp = ^png_text;
  png_text = packed record
    compression: int;            // compression value
    key: png_charp;              // keyword, 1-79 character description of "text"
    text: png_charp;             // comment, may be empty ("")
    text_length: png_size_t;     // length of text field
    itxt_length: png_size_t;     // length of the itxt string
    lang: png_charp;             // language code, 1-79 characters
    lang_key: png_charp;         // keyword translated UTF-8 string, 0 or more
  end;
  TPngText = png_text;

  png_timepp = ^png_timep;
  png_timep = ^png_time;
  png_time = packed record
    year: png_uint_16;           //yyyy
    month: png_byte;             //1..12
    day: png_byte;               //1..31
    hour: png_byte;              //0..23
    minute: png_byte;            //0..59
    second: png_byte;            //0..60 (leap seconds)
  end;
  TPngTime = png_time;

  // png_unknown_chunk is a structure to hold queued chunks for which there is
  // no specific support.  The idea is that we can use this to queue
  // up private chunks for output even though the library doesn't actually
  // know about their semantics.
  png_unknown_chunkpp = ^png_unknown_chunkp;
  png_unknown_chunkp = ^png_unknown_chunk;
  png_unknown_chunk  = packed record
    name : array[0..4] of png_byte;
    data : ^png_byte;
    size : png_size_t ;
    // libpng-using applications should NOT directly modify this byte. *}
    location : png_byte ; // mode of operation at read time
  end;
  TPngUnknownChunk = png_unknown_chunk;

  {* png_info is a structure that holds the information in a PNG file so
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
  * however, there are now functions that abstract the contents of
  * png_info_struct from the application, so this makes it easier to use
  * libpng with dynamic libraries, and even makes it possible to use
  * libraries that don't have all of the libpng ancillary chunk-handing
  * functionality.
  *
  * In any case, the order of the parameters in png_info_struct should NOT
  * be changed for as long as possible to keep compatibility with applications
  * that use the old direct-access method with png_info_struct.
  *
  * The following members may have allocated storage attached that should be
  * cleaned up before the structure is discarded: palette, trans, text,
  * pcal_purpose, pcal_units, pcal_params, hist, iccp_name, iccp_profile,
  * splt_palettes, scal_unit, row_pointers, and unknowns.   By default, these are
  * automatically freed when the info structure is deallocated, if they were
  * allocated internally by libpng.  This behavior can be changed by means
  * of the png_data_freer() function.
  *
  * More allocation details: all the chunk-reading functions that change these
  * members go through the corresponding png_set_* functions.  A function to
  * clear these members is available: see png_free_data().   Some of the
  * png_set_* functions do not depend on being able to point info structure
  * members to any of the storage they are passed (they make their own copies),
  * EXCEPT that the png_set_text functions use the same storage passed to them
  * in the text_ptr or itxt_ptr structure argument, and the png_set_tRNS,
  * png_set_PLTE, png_set_hIST, png_set_iCCP, png_set_rows, png_set_sPLT,
  * and png_set_unknowns do not make their own copies.
  *}
  png_infopp = ^png_infop;
  png_infop = ^png_info;
  png_info  = packed record
    // the following are necessary for every PNG file
    width : png_uint_32 ;       // width of image in pixels (from IHDR) *}
    height : png_uint_32 ;      // height of image in pixels (from IHDR) *}
    valid : png_uint_32 ;       // valid chunk data (see PNG_INFO_ below) *}
    rowbytes : png_uint_32 ;    // bytes needed to hold an untransformed row *}
    palette : png_colorp ;      // array of color values (valid & PNG_INFO_PLTE) *}
    num_palette : png_uint_16 ; // number of color entries in "palette" (PLTE) *}
    num_trans : png_uint_16 ;   // number of transparent palette color (tRNS) *}
    bit_depth : png_byte ;      // 1, 2, 4, 8, or 16 bits/channel (from IHDR) *}
    color_type : png_byte ;     // see PNG_COLOR_TYPE_ below (from IHDR) *}
    compression_type : png_byte ; // must be PNG_COMPRESSION_TYPE_BASE (IHDR) *}
    filter_type : png_byte ;    // must be PNG_FILTER_TYPE_BASE (from IHDR) *}
    interlace_type : png_byte ; // One of PNG_INTERLACE_NONE, PNG_INTERLACE_ADAM7 *}

    // The following is informational only on read, and not used on writes. *}
    channels : png_byte ;       // number of data channels per pixel (1, 2, 3, 4)*}
    pixel_depth : png_byte ;    // number of bits per pixel *}
    spare_byte : png_byte ;     // to align the data, and for future use *}
    signature : array [ 0..7] of png_byte ;   // magic bytes read by libpng from start of file *}

    {* The rest of the data is optional.  If you are reading, check the
    * valid field to see if the information in these are valid.  If you
    * are writing, set the valid field to those chunks you want written,
    * and initialize the appropriate fields below.
    *}

    {$IFDEF PNG_gAMA_SUPPORTED }
      {$IFDEF PNG_FLOATING_POINT_SUPPORTED }
      {* The gAMA chunk describes the gamma characteristics of the system
      * on which the image was created, normally in the range [1.0, 2.5].
      * Data is valid if (valid & PNG_INFO_gAMA) is non-zero.
      *}
      gamma : float; // gamma value of image, if (valid & PNG_INFO_gAMA) *}
      {$ENDIF}
    {$ENDIF}

    {$IFDEF PNG_sRGB_SUPPORTED}
    // GR-P, 0.96a *}
    // Data valid if (valid & PNG_INFO_sRGB) non-zero. *}
    srgb_intent : png_byte ; // sRGB rendering intent [0, 1, 2, or 3] *}
    {$ENDIF}

    {$IFDEF PNG_TEXT_SUPPORTED }
    {* The tEXt, and zTXt chunks contain human-readable textual data in
    * uncompressed, compressed, and optionally compressed forms, respectively.
    * The data in "text" is an array of pointers to uncompressed,
    * null-terminated C strings. Each chunk has a keyword that describes the
    * textual data contained in that chunk.  Keywords are not required to be
    * unique, and the text string may be empty.  Any number of text chunks may
    * be in an image.
    *}
    num_text : integer; // number of comments read/to write *}
    max_text : integer; // current size of text array *}
    text : png_textp ; // array of comments read/to write *}
    {$ENDIF} // PNG_TEXT_SUPPORTED *}

    {$IFDEF PNG_tIME_SUPPORTED }
    {* The tIME chunk holds the last time the displayed image data was
    * modified.  See the png_time struct for the contents of this struct.
    *}
    mod_time : png_time;
    {$ENDIF}

    {$IFDEF PNG_sBIT_SUPPORTED}
    {* The sBIT chunk specifies the number of significant high-order bits
    * in the pixel data.  Values are in the range [1, bit_depth], and are
    * only specified for the channels in the pixel data.  The contents of
    * the low-order bits is not specified.  Data is valid if
    * (valid & PNG_INFO_sBIT) is non-zero.
    *}
    sig_bit : png_color_8 ; // significant bits in color channels *}
    {$ENDIF}

    {$IFDEF PNG_tRNS_SUPPORTED} or
    {$IFDEF PNG_READ_EXPAND_SUPPORTED } or
    {$IFDEF PNG_READ_BACKGROUND_SUPPORTED }
    {* The tRNS chunk supplies transparency data for paletted images and
    * other image types that don't need a full alpha channel.  There are
    * "num_trans" transparency values for a paletted image, stored in the
    * same order as the palette colors, starting from index 0.  Values
    * for the data are in the range [0, 255], ranging from fully transparent
    * to fully opaque, respectively.  For non-paletted images, there is a
    * single color specified that should be treated as fully transparent.
    * Data is valid if (valid & PNG_INFO_tRNS) is non-zero.
    *}
    png_bytep trans; // transparent values for paletted image *}
    png_color_16 trans_values; // transparent color for non-palette image *}
    {$ENDIF}{$ENDIF}{$ENDIF}

    {$IFDEF PNG_bKGD_SUPPORTED } or
    {$IFDEF PNG_READ_BACKGROUND_SUPPORTED }
    {* The bKGD chunk gives the suggested image background color if the
    * display program does not have its own background color and the image
    * is needs to composited onto a background before display.  The colors
    * in "background" are normally in the same color space/depth as the
    * pixel data.  Data is valid if (valid & PNG_INFO_bKGD) is non-zero.
    *}
    png_color_16 background;
    {$ENDIF}{$ENDIF}

    {$IFDEF PNG_oFFs_SUPPORTED }
    {* The oFFs chunk gives the offset in "offset_unit_type" units rightwards
    * and downwards from the top-left corner of the display, page, or other
    * application-specific co-ordinate space.  See the PNG_OFFSET_ defines
    * below for the unit types.  Valid if (valid & PNG_INFO_oFFs) non-zero.
    *}
    x_offset : png_int_32 ; // x offset on page *}
    y_offset : png_int_32 ; // y offset on page *}
    offset_unit_type : png_byte ; // offset units type *}
    {$ENDIF}

    {$IFDEF PNG_pHYs_SUPPORTED}
    {* The pHYs chunk gives the physical pixel density of the image for
    * display or printing in "phys_unit_type" units (see PNG_RESOLUTION_
    * defines below).  Data is valid if (valid & PNG_INFO_pHYs) is non-zero.
    *}
    x_pixels_per_unit : png_uint_32 ; // horizontal pixel density *}
    y_pixels_per_unit : png_uint_32 ; // vertical pixel density *}
    phys_unit_type : png_byte ; // resolution type (see PNG_RESOLUTION_ below) *}
    {$ENDIF}

    {$IFDEF PNG_hIST_SUPPORTED}
    { The hIST chunk contains the relative frequency or importance of the
    * various palette entries, so that a viewer can intelligently select a
    * reduced-color palette, if required.  Data is an array of "num_palette"
    * values in the range [0,65535]. Data valid if (valid & PNG_INFO_hIST)
    * is non-zero.
    *}
    hist : png_uint_16p;
    {$ENDIF}

    {$IFDEF PNG_cHRM_SUPPORTED}
    // The cHRM chunk describes the CIE color characteristics of the monitor
    * on which the PNG was created.  This data allows the viewer to do gamut
    * mapping of the input image to ensure that the viewer sees the same
    * colors in the image as the creator.  Values are in the range
    * [0.0, 0.8].  Data valid if (valid & PNG_INFO_cHRM) non-zero.
    *}
      {$IFDEF PNG_FLOATING_POINT_SUPPORTED}
      x_white: float ;
      y_white: float ;
      x_red : float ;
      y_red : float ;
      x_green : float ;
      y_green : float ;
      x_blue : float ;
      y_blue : float ;
      {$ENDIF}
    {$ENDIF}

    {$IFDEF PNG_pCAL_SUPPORTED}
    { The pCAL chunk describes a transformation between the stored pixel
    * values and original physical data values used to create the image.
    * The integer range [0, 2^bit_depth - 1] maps to the floating-point
    * range given by [pcal_X0, pcal_X1], and are further transformed by a
    * (possibly non-linear) transformation function given by "pcal_type"
    * and "pcal_params" into "pcal_units".  Please see the PNG_EQUATION_
    * defines below, and the PNG-Group's PNG extensions document for a
    * complete description of the transformations and how they should be
    * implemented, and for a description of the ASCII parameter strings.
    * Data values are valid if (valid & PNG_INFO_pCAL) non-zero.
    *}
    pcal_purpose : png_charp;  // pCAL chunk description string *}
    pcal_X0 : png_int_32;      // minimum value *}
    pcal_X1 : png_int_32;      // maximum value *}
    pcal_units : png_charp;    // Latin-1 string giving physical units *}
    pcal_params : png_charpp;  // ASCII strings containing parameter values *}
    pcal_type : png_byte;      // equation type (see PNG_EQUATION_ below) *}
    pcal_nparams : png_byte;   // number of parameters given in pcal_params *}
    {$ENDIF}

    {$IFDEF PNG_FREE_ME_SUPPORTED}
    free_me : png_uint_32 ;     // flags items libpng is responsible for freeing *}
    {$ENDIF}

    {$IFDEF PNG_UNKNOWN_CHUNKS_SUPPORTED}
    // storage for unknown chunks that the library doesn't recognize. *}
    unknown_chunks : png_unknown_chunkp ;
    unknown_chunks_num : png_size_t;
    {$ENDIF}

    {$IFDEF PNG_iCCP_SUPPORTED}
    // iCCP chunk data. *}
    iccp_name : png_charp ;     // profile name *}
    iccp_profile : png_charp ;  // International Color Consortium profile data *}
    iccp_proflen : png_uint_32 ;  // ICC profile data length *}
    iccp_compression : png_byte ; // Always zero *}
    {$ENDIF}

    {$IFDEF PNG_sPLT_SUPPORTED}
    // data on sPLT chunks (there may be more than one). *}
    splt_palettes : png_sPLT_tp ;
    splt_palettes_num : png_uint_32 ;
    {$ENDIF}

    {$IFDEF PNG_sCAL_SUPPORTED}
    {* The sCAL chunk describes the actual physical dimensions of the
    * subject matter of the graphic.  The chunk contains a unit specification
    * a byte value, and two ASCII strings representing floating-point
    * values.  The values are width and height corresponsing to one pixel
    * in the image.  This external representation is converted to double
    * here.  Data values are valid if (valid & PNG_INFO_sCAL) is non-zero.
    *}
    scal_unit : png_byte ;         // unit of physical scale *}
      {$IFDEF PNG_FLOATING_POINT_SUPPORTED }
      scal_pixel_width : double ;    // width of one pixel *}
      scal_pixel_height : double ;   // height of one pixel *}
      {$ENDIF}
      {$IFDEF PNG_FIXED_POINT_SUPPORTED }
      scal_s_width : png_charp ;     // string containing height *}
      scal_s_height : png_charp ;    // string containing width *}
      {$ENDIF}
    {$ENDIF}

    {$IFDEF PNG_INFO_IMAGE_SUPPORTED}
    // Memory has been allocated if (valid & PNG_ALLOCATED_INFO_ROWS) non-zero *}
    // Data valid if (valid & PNG_INFO_IDAT) non-zero *}
    row_pointers : png_bytepp ;        // the image bits *}
    {$ENDIF}

    {$IFDEF PNG_FIXED_POINT_SUPPORTED }
      {$IFDEF PNG_gAMA_SUPPORTED }
      int_gamma : png_fixed_point ; // gamma of image, if (valid & PNG_INFO_gAMA) *}
      {$ENDIF}
    {$ENDIF}

    {$IFDEF PNG_cHRM_SUPPORTED}
      {$IFDEF PNG_FIXED_POINT_SUPPORTED}
      int_x_white : png_fixed_point ;
      int_y_white : png_fixed_point ;
      int_x_red : png_fixed_point ;
      int_y_red : png_fixed_point ;
      int_x_green : png_fixed_point ;
      int_y_green : png_fixed_point ;
      int_x_blue : png_fixed_point;
      int_y_blue : png_fixed_point ;
      {$ENDIF}
    {$ENDIF}
  end;
  TPngInfo = png_info;

  png_row_infopp = ^png_row_infop;
  png_row_infop = ^png_row_info;
  png_row_info = packed record
    width: png_uint_32;          //width of row
    rowbytes: png_size_t;        //number of bytes in row
    color_type: png_byte;        //color type of row
    bit_depth: png_byte;         //bit depth of row
    channels: png_byte;          //number of channels (1, 2, 3, or 4)
    pixel_depth: png_byte;       //bits per pixel (depth * channels)
  end;
  TPngRowInfo = png_row_info;

  png_structpp = ^png_structp;
  png_structp = Pointer;

  // function pointer declarations
  png_error_ptrp = ^png_error_ptr;
  png_error_ptr  = procedure(png_ptr: Pointer; msg: Pointer); stdcall;

  png_rw_ptrp = ^png_rw_ptr;
  png_rw_ptr = procedure(png_ptr: Pointer; var data: Pointer; length: png_size_t); stdcall;

  png_flush_ptrp = ^png_flush_ptr;
  png_flush_ptr = procedure(png_ptr: Pointer); stdcall;

  png_read_status_ptrp = ^png_read_status_ptr;
  png_read_status_ptr = procedure(png_ptr: Pointer; row_number: png_uint_32; pass: int); stdcall;

  png_write_status_ptrp = ^png_write_status_ptr;
  png_write_status_ptr = procedure(png_ptr: Pointer; row_number: png_uint_32; pass: int); stdcall;

  png_progressive_info_ptrp = ^png_progressive_info_ptr;
  png_progressive_info_ptr  = procedure(png_ptr: Pointer; info_ptr: Pointer); stdcall;

  png_progressive_end_ptrp  = ^png_progressive_end_ptr;
  png_progressive_end_ptr   = procedure(png_ptr: Pointer; info_ptr: Pointer); stdcall;

  png_progressive_row_ptrp  = ^png_progressive_row_ptr;
  png_progressive_row_ptr   = procedure(png_ptr: Pointer; data: Pointer; length: png_uint_32; count: int); stdcall;

  png_user_transform_ptrp = ^png_user_transform_ptr;
  png_user_transform_ptr = procedure(png_ptr: Pointer; row_info: Pointer; data: png_bytep); stdcall;

  png_user_chunk_ptrp = ^png_user_chunk_ptr;
  png_user_chunk_ptr = procedure(png_ptr: Pointer; data: png_unknown_chunkp); stdcall;

const
  PNG_LIBPNG_VER_STRING = '1.0.8';
  PNG_LIBPNG_VER        =  10008;
   // These should match the first 3 components of PNG_LIBPNG_VER_STRING:
  PNG_LIBPNG_VER_MAJOR   = 1;
  PNG_LIBPNG_VER_MINOR   = 0;
  PNG_LIBPNG_VER_RELEASE = 8;
  // This should match the numeric part of the final component of
  // PNG_LIBPNG_VER_STRING, omitting any leading zero: *}
  PNG_LIBPNG_VER_BUILD   = 0;
  PNG_HEADER_VERSION_STRING  = ' libpng version 1.0.8 - July 24, 2000 (header)'+#13+#10;
  
  PNG_LIBPNG_VER_SONUM  = 2;

// Supported compression types for text in PNG files (tEXt, and zTXt).
// The values of the PNG_TEXT_COMPRESSION_ defines should NOT be changed.
  PNG_TEXT_COMPRESSION_NONE_WR = -3;
  PNG_TEXT_COMPRESSION_zTXt_WR = -2;
  PNG_TEXT_COMPRESSION_NONE    = -1;
  PNG_TEXT_COMPRESSION_zTXt    = 0;
  PNG_ITXT_COMPRESSION_NONE    = 1;
  PNG_ITXT_COMPRESSION_zTXt    = 2;
  PNG_TEXT_COMPRESSION_LAST    = 3;  // Not a valid value

// Maximum positive integer used in PNG is (2^31)-1
  PNG_MAX_UINT : png_uint_32   = $7FFFFFFF;

// These describe the color_type field in png_info.
// color type masks
  PNG_COLOR_MASK_PALETTE   = 1;
  PNG_COLOR_MASK_COLOR     = 2;
  PNG_COLOR_MASK_ALPHA     = 4;

// color types.  Note that not all combinations are legal
  PNG_COLOR_TYPE_GRAY       = 0;
  PNG_COLOR_TYPE_PALETTE    = PNG_COLOR_MASK_COLOR or
                              PNG_COLOR_MASK_PALETTE;
  PNG_COLOR_TYPE_RGB        = PNG_COLOR_MASK_COLOR;
  PNG_COLOR_TYPE_RGB_ALPHA  = PNG_COLOR_MASK_COLOR or
                              PNG_COLOR_MASK_ALPHA;
  PNG_COLOR_TYPE_GRAY_ALPHA = PNG_COLOR_MASK_ALPHA;

// This is for compression type. PNG 1.0 only defines the single type.
  PNG_COMPRESSION_TYPE_BASE    = 0;   // Deflate method 8, 32K window
  PNG_COMPRESSION_TYPE_DEFAULT = PNG_COMPRESSION_TYPE_BASE;

// TThis is for filter type. PNG 1.0-1.2 only define the single type.
  PNG_FILTER_TYPE_BASE    = 0;       // Single row per-byte filtering
  PNG_FILTER_TYPE_DEFAULT = PNG_FILTER_TYPE_BASE;

// These are for the interlacing type.  These values should NOT be changed.
  PNG_INTERLACE_NONE  = 0;      // Non-interlaced image
  PNG_INTERLACE_ADAM7 = 1;      // Adam7 interlacing
  PNG_INTERLACE_LAST  = 2;      // Not a valid value

// These are for the oFFs chunk.  These values should NOT be changed.
  PNG_OFFSET_PIXEL      = 0;    // Offset in pixels
  PNG_OFFSET_MICROMETER = 1;    // Offset in micrometers (1/10^6 meter)
  PNG_OFFSET_LAST       = 2;    // Not a valid value

// These are for the pCAL chunk.  These values should NOT be changed.
  PNG_EQUATION_LINEAR     = 0;  // Linear transformation
  PNG_EQUATION_BASE_E     = 1;  // Exponential base e transform
  PNG_EQUATION_ARBITRARY  = 2;  // Arbitrary base exponential transform
  PNG_EQUATION_HYPERBOLIC = 3;  // Hyperbolic sine transformation
  PNG_EQUATION_LAST       = 4;  //  Not a valid value

// These are for the sCAL chunk.  These values should NOT be changed.
  PNG_SCALE_UNKNOWN        = 0; // unknown unit (image scale)
  PNG_SCALE_METER          = 1; // meters per pixel
  PNG_SCALE_RADIAN         = 2; // radians per pixel
  PNG_SCALE_LAST           = 3; // Not a valid value

// These are for the pHYs chunk.  These values should NOT be changed.
  PNG_RESOLUTION_UNKNOWN = 0;   // pixels/unknown unit (aspect ratio)
  PNG_RESOLUTION_METER   = 1;   // pixels/meter
  PNG_RESOLUTION_LAST    = 2;   // Not a valid value

// These are for the sRGB chunk.  These values should NOT be changed.
  PNG_sRGB_INTENT_PERCEPTUAL = 0;
  PNG_sRGB_INTENT_RELATIVE   = 1;
  PNG_sRGB_INTENT_SATURATION = 2;
  PNG_sRGB_INTENT_ABSOLUTE   = 3;
  PNG_sRGB_INTENT_LAST       = 4; // Not a valid value

// This is for text chunks *}
  PNG_KEYWORD_MAX_LENGTH     = 79;

// These determine if an ancillary chunk's data has been successfully read
// from the PNG header, or if the application has filled in the corresponding
// data in the info_struct to be written into the output file.  The values
// of the PNG_INFO_<chunk> defines should NOT be changed.
  PNG_INFO_gAMA = $0001;
  PNG_INFO_sBIT = $0002;
  PNG_INFO_cHRM = $0004;
  PNG_INFO_PLTE = $0008;
  PNG_INFO_tRNS = $0010;
  PNG_INFO_bKGD = $0020;
  PNG_INFO_hIST = $0040;
  PNG_INFO_pHYs = $0080;
  PNG_INFO_oFFs = $0100;
  PNG_INFO_tIME = $0200;
  PNG_INFO_pCAL = $0400;
  PNG_INFO_sRGB = $0800;  // GR-P, 0.96a
  PNG_INFO_iCCP = $1000;  // ESR, 1.0.6
  PNG_INFO_sPLT = $2000;  // ESR, 1.0.6
  PNG_INFO_sCAL = $4000;  // ESR, 1.0.6
  PNG_INFO_IDAT = $8000;  // ESR, 1.0.6

// Transform masks for the high-level interface
  PNG_TRANSFORM_IDENTITY       = $0000;    // read and write
  PNG_TRANSFORM_STRIP_16       = $0001;    // read only
  PNG_TRANSFORM_STRIP_ALPHA    = $0002;    // read only
  PNG_TRANSFORM_PACKING        = $0004;    // read and write
  PNG_TRANSFORM_PACKSWAP       = $0008;    // read and write
  PNG_TRANSFORM_EXPAND         = $0010;    // read only
  PNG_TRANSFORM_INVERT_MONO    = $0020;    // read and write
  PNG_TRANSFORM_SHIFT          = $0040;    // read and write
  PNG_TRANSFORM_BGR            = $0080;    // read and write
  PNG_TRANSFORM_SWAP_ALPHA     = $0100;    // read and write
  PNG_TRANSFORM_SWAP_ENDIAN    = $0200;    // read and write
  PNG_TRANSFORM_INVERT_ALPHA   = $0200;    // read and write
  PNG_TRANSFORM_STRIP_FILLER   = $0800;    // WRITE only

// Handle alpha and tRNS by replacing with a background color.
  PNG_BACKGROUND_GAMMA_UNKNOWN = 0;
  PNG_BACKGROUND_GAMMA_SCREEN  = 1;
  PNG_BACKGROUND_GAMMA_FILE    = 2;
  PNG_BACKGROUND_GAMMA_UNIQUE  = 3;

// Values for png_set_crc_action() to say how to handle CRC errors in
// ancillary and critical chunks, and whether to use the data contained
// therein.  Note that it is impossible to "discard" data in a critical
// chunk.  For versions prior to 0.90, the action was always error/quit,
// whereas in version 0.90 and later, the action for CRC errors in ancillary
// chunks is warn/discard.  These values should NOT be changed.

//      value                   action:critical     action:ancillary
  PNG_CRC_DEFAULT      = 0;  // error/quit          warn/discard data
  PNG_CRC_ERROR_QUIT   = 1;  // error/quit          error/quit
  PNG_CRC_WARN_DISCARD = 2;  // (INVALID)           warn/discard data
  PNG_CRC_WARN_USE     = 3;  // warn/use data       warn/use data
  PNG_CRC_QUIET_USE    = 4;  // quiet/use data      quiet/use data
  PNG_CRC_NO_CHANGE    = 5;  // use current value   use current value 

// Flags for png_set_filter() to say which filters to use.  The flags
// are chosen so that they don't conflict with real filter types
// below, in case they are supplied instead of the  d constants.
// These values should NOT be changed.
  PNG_NO_FILTERS   = $00;
  PNG_FILTER_NONE  = $08;
  PNG_FILTER_SUB   = $10;
  PNG_FILTER_UP    = $20;
  PNG_FILTER_AVG   = $40;
  PNG_FILTER_PAETH = $80;
  PNG_ALL_FILTERS  = PNG_FILTER_NONE or PNG_FILTER_SUB or
                     PNG_FILTER_UP   or PNG_FILTER_AVG or
                     PNG_FILTER_PAETH;

  // Filter values (not flags) - used in pngwrite.c, pngwutil.c for now.
  // These defines should NOT be changed.
  PNG_FILTER_VALUE_NONE  = 0;
  PNG_FILTER_VALUE_SUB   = 1;
  PNG_FILTER_VALUE_UP    = 2;
  PNG_FILTER_VALUE_AVG   = 3;
  PNG_FILTER_VALUE_PAETH = 4;
  PNG_FILTER_VALUE_LAST  = 5;

  // Heuristic used for row filter selection.  These defines should NOT be
  // changed.
  PNG_FILTER_HEURISTIC_DEFAULT    = 0;  // Currently "UNWEIGHTED"
  PNG_FILTER_HEURISTIC_UNWEIGHTED = 1;  // Used by libpng < 0.95
  PNG_FILTER_HEURISTIC_WEIGHTED   = 2;  // Experimental feature
  PNG_FILTER_HEURISTIC_LAST       = 3;  // Not a valid value

  // flags for png_ptr->free_me and info_ptr->free_me *}
  PNG_FREE_PLTE = $0001;
  PNG_FREE_TRNS = $0002;
  PNG_FREE_TEXT = $0004;
  PNG_FREE_HIST = $0008;
  PNG_FREE_ICCP = $0010;
  PNG_FREE_SPLT = $0020;
  PNG_FREE_ROWS = $0040;
  PNG_FREE_PCAL = $0080;
  PNG_FREE_SCAL = $0100;
  PNG_FREE_UNKN = $0200;
  PNG_FREE_LIST = $0400;
  PNG_FREE_ALL  = $07FF;
  PNG_FREE_MUL  = $4220; // PNG_FREE_SPLT|PNG_FREE_TEXT|PNG_FREE_UNKN

  (*{IFDEF PNG_INTERNAL}
  {* Various modes of operation.  Note that after an init, mode is set to
   * zero automatically when the structure is created.
   *}
     PNG_HAVE_IHDR               = $01;
     PNG_HAVE_PLTE               = $02;
     PNG_HAVE_IDAT               = $04;
     PNG_AFTER_IDAT              = $08;
     PNG_HAVE_IEND               = $10;
     PNG_HAVE_gAMA               = $20;
     PNG_HAVE_cHRM               = $40;
     PNG_HAVE_sRGB               = $80;
     PNG_HAVE_CHUNK_HEADER      = $100;
     PNG_WROTE_tIME             = $200;
     PNG_WROTE_INFO_BEFORE_PLTE = $400;
     PNG_BACKGROUND_IS_GRAY     = $800;

{* flags for the transformations the PNG library does on the image data *}
     PNG_BGR                = $0001;
     PNG_INTERLACE          = $0002;
     PNG_PACK               = $0004;
     PNG_SHIFT              = $0008;
     PNG_SWAP_BYTES         = $0010;
     PNG_INVERT_MONO        = $0020;
     PNG_DITHER             = $0040;
     PNG_BACKGROUND         = $0080;
     PNG_BACKGROUND_EXPAND  = $0100;
                          {*   = $0200 unused *}
     PNG_16_TO_8            = $0400;
     PNG_RGBA               = $0800;
     PNG_EXPAND             = $1000;
     PNG_GAMMA              = $2000;
     PNG_GRAY_TO_RGB        = $4000;
     PNG_FILLER             = $8000;
     PNG_PACKSWAP          = $10000;
     PNG_SWAP_ALPHA        = $20000;
     PNG_STRIP_ALPHA       = $40000;
     PNG_INVERT_ALPHA      = $80000;
     PNG_USER_TRANSFORM   = $100000;
     PNG_RGB_TO_GRAY_ERR  = $200000;
     PNG_RGB_TO_GRAY_WARN = $400000;
     PNG_RGB_TO_GRAY      = $600000;  {* two bits, RGB_TO_GRAY_ERR|WARN *}

{* flags for png_create_struct *}
     PNG_STRUCT_PNG   = $0001;
     PNG_STRUCT_INFO  = $0002;

{* Scaling factor for filter heuristic weighting calculations *}
     PNG_WEIGHT_SHIFT = 8;
     PNG_WEIGHT_FACTOR = (1 shl (PNG_WEIGHT_SHIFT));
     PNG_COST_SHIFT = 3;
     PNG_COST_FACTOR = (1 shl (PNG_COST_SHIFT));

{* flags for the png_ptr->flags rather than declaring a byte for each one *}
     PNG_FLAG_ZLIB_CUSTOM_STRATEGY     = $0001;
     PNG_FLAG_ZLIB_CUSTOM_LEVEL        = $0002;
     PNG_FLAG_ZLIB_CUSTOM_MEM_LEVEL    = $0004;
     PNG_FLAG_ZLIB_CUSTOM_WINDOW_BITS  = $0008;
     PNG_FLAG_ZLIB_CUSTOM_METHOD       = $0010;
     PNG_FLAG_ZLIB_FINISHED            = $0020;
     PNG_FLAG_ROW_INIT                 = $0040;
     PNG_FLAG_FILLER_AFTER             = $0080;
     PNG_FLAG_CRC_ANCILLARY_USE        = $0100;
     PNG_FLAG_CRC_ANCILLARY_NOWARN     = $0200;
     PNG_FLAG_CRC_CRITICAL_USE         = $0400;
     PNG_FLAG_CRC_CRITICAL_IGNORE      = $0800;
     PNG_FLAG_FREE_PLTE                = $1000;
     PNG_FLAG_FREE_TRNS                = $2000;
     PNG_FLAG_FREE_HIST                = $4000;
     PNG_FLAG_KEEP_UNKNOWN_CHUNKS      = $8000;
     PNG_FLAG_KEEP_UNSAFE_CHUNKS       = $10000;
     PNG_FLAG_LIBRARY_MISMATCH         = $20000;

{* For use in png_set_keep_unknown, png_handle_as_unknown *}
     HANDLE_CHUNK_AS_DEFAULT   = 0;
     HANDLE_CHUNK_NEVER        = 1;
     HANDLE_CHUNK_IF_SAFE      = 2;
     HANDLE_CHUNK_ALWAYS       = 3;

     PNG_FLAG_CRC_ANCILLARY_MASK (PNG_FLAG_CRC_ANCILLARY_USE | \
                                     PNG_FLAG_CRC_ANCILLARY_NOWARN)

     PNG_FLAG_CRC_CRITICAL_MASK  (PNG_FLAG_CRC_CRITICAL_USE | \
                                     PNG_FLAG_CRC_CRITICAL_IGNORE)

     PNG_FLAG_CRC_MASK           (PNG_FLAG_CRC_ANCILLARY_MASK | \
                                     PNG_FLAG_CRC_CRITICAL_MASK)

{* save typing and make code easier to understand *}
     PNG_COLOR_DIST(c1, c2) (abs((int)((c1).red) - (int)((c2).red)) + \
   abs((int)((c1).green) - (int)((c2).green)) + \
   abs((int)((c1).blue) - (int)((c2).blue)))

{* variables declared in png.c - only it needs to define PNG_NO_EXTERN *}
    {$IFNDEF PNG_NO_EXTERN} or {IFDEFPNG_ALWAYS_EXTERN }
    {* place to hold the signature string for a PNG file. *}
      {$IFDEF PNG_USE_GLOBAL_ARRAYS }
         PNG_EXPORT_VAR (png_byte FARDATA) png_sig[8];
      {$ELSE}
           png_sig png_sig_bytes(NULL)
      {$ENDIF}
    {$ENDIF} {* PNG_NO_EXTERN *}
  {$ENDIF}*)

 {* Constant strings for known chunk types.  If you need to add a chunk,
 * define the name here, and add an invocation of the macro in png.c and
 * wherever it's needed.
 *}
     PNG_IHDR : array[0..4] of png_byte = ( 73,  72,  68, 82, 0);
     PNG_IDAT : array[0..4] of png_byte = ( 73,  68,  65, 84 , 0 );
     PNG_IEND : array[0..4] of png_byte = ( 73,  69,  78, 68 , 0 );
     PNG_PLTE : array[0..4] of png_byte = ( 80,  76,  84, 69 , 0 );
     PNG_bKGD : array[0..4] of png_byte = ( 98,  75,  71, 68 , 0 );
     PNG_cHRM : array[0..4] of png_byte = ( 99,  72,  82, 77 , 0 );
     PNG_gAMA : array[0..4] of png_byte = ( 103,  65,  77, 65 , 0 );
     PNG_hIST : array[0..4] of png_byte = ( 104,  73,  83, 84 , 0 );
     PNG_iCCP : array[0..4] of png_byte = ( 105,  67,  67, 80 , 0 );
     PNG_iTXt : array[0..4] of png_byte = ( 105,  84,  88, 116 , 0 );
     PNG_oFFs : array[0..4] of png_byte = ( 111,  70,  70, 115 , 0 );
     PNG_pCAL : array[0..4] of png_byte = ( 112,  67,  65,  76 , 0 );
     PNG_sCAL : array[0..4] of png_byte = ( 115,  67,  65,  76 , 0 );
     PNG_pHYs : array[0..4] of png_byte = ( 112,  72,  89, 115 , 0 );
     PNG_sBIT : array[0..4] of png_byte = ( 115,  66,  73,  84 , 0 );
     PNG_sPLT : array[0..4] of png_byte = ( 115,  80,  76,  84 , 0 );
     PNG_sRGB : array[0..4] of png_byte = ( 115,  82,  71,  66 , 0 );
     //PNG_tEXt : array[0..4] of png_byte = ( 116,  69,  88, 116 , 0 );
     //PNG_tIME : array[0..4] of png_byte = ( 116,  73,  77,  69 , 0 );
     PNG_tRNS : array[0..4] of png_byte = ( 116,  82,  78,  83 , 0 );
     PNG_zTXt : array[0..4] of png_byte = ( 122,  84,  88, 116 , 0 );

procedure png_build_grayscale_palette(bit_depth: int; palette: png_colorp); stdcall;

function png_check_sig(sig: png_bytep; num: int): int; stdcall;

procedure png_chunk_error(png_ptr: png_structp; const mess: png_charp); stdcall;

procedure png_chunk_warning(png_ptr: png_structp; const mess: png_charp); stdcall;

procedure png_convert_from_time_t(ptime: png_timep; ttime: time_t); stdcall;

function png_convert_to_rfc1123(png_ptr: png_structp; ptime: png_timep): png_charp; stdcall;

function png_create_info_struct(png_ptr: png_structp): png_infop; stdcall;

function png_create_read_struct(user_png_ver: png_charp;
             error_ptr: user_error_ptr; error_fn: png_error_ptr;
             warn_fn: png_error_ptr): png_structp;
             stdcall;

{function png_create_read_struct_2(user_png_ver: png_charp;
             error_ptr: user_error_ptr; error_fn: png_error_ptr;
             warn_fn: png_error_ptr): png_structp;
             stdcall;}
             
function png_get_copyright(png_ptr: png_structp): png_charp;
             stdcall;
function png_get_header_ver(png_ptr: png_structp): png_charp;
             stdcall;
function png_get_header_version(png_ptr: png_structp): png_charp;
             stdcall;
function png_get_libpng_ver(png_ptr: png_structp): png_charp;
             stdcall;
function png_create_write_struct(user_png_ver: png_charp;
             error_ptr: user_error_ptr; error_fn: png_error_ptr;
             warn_fn: png_error_ptr): png_structp;
             stdcall;
procedure png_destroy_info_struct(png_ptr: png_structp;
             info_ptr_ptr: png_infopp);
             stdcall;
procedure png_destroy_read_struct(png_ptr_ptr: png_structpp;
             info_ptr_ptr, end_info_ptr_ptr: png_infopp);
             stdcall;

procedure png_destroy_write_struct(png_ptr_ptr: png_structpp; info_ptr_ptr: png_infopp); stdcall;

procedure png_error( png_ptr : png_structp; error : png_charp );  stdcall;

procedure png_free( png_ptr : png_structp; ptr : png_voidp );  stdcall;

procedure png_free_data(png_ptr: png_structp; info_ptr: png_infop; num: int); stdcall;

procedure png_free_default( png_ptr : png_structp; ptr : png_voidp ); stdcall;

function png_get_IHDR(png_ptr: png_structp; info_ptr: png_infop; var width, height: png_uint_32; var bit_depth, color_type, interlace_type, compression_type, filter_type: int): png_uint_32; stdcall;

function png_get_PLTE(png_ptr: png_structp; info_ptr: png_infop; var palette: png_colorp; var num_palette: int): png_uint_32; stdcall;
             
function png_get_bKGD(png_ptr: png_structp; info_ptr: png_infop; var background: png_color_16p): png_uint_32; stdcall;

function png_get_bit_depth(png_ptr: png_structp; info_ptr: png_infop): png_byte; stdcall;

function png_get_cHRM(png_ptr: png_structp; info_ptr: png_infop; var white_x, white_y, red_x, red_y, green_x, green_y, blue_x, blue_y: double): png_uint_32; stdcall;

function png_get_cHRM_fixed(png_ptr : png_structp; info_ptr : png_infop; int_white_x : png_fixed_point; int_white_y : png_fixed_point; int_red_x : png_fixed_point; int_red_y : png_fixed_point; int_green_x : png_fixed_point; int_green_y : png_fixed_point; int_blue_x : png_fixed_point; int_blue_y : png_fixed_point ): png_uint_32; stdcall;

function png_get_channels(png_ptr: png_structp; info_ptr: png_infop): png_byte; stdcall;

function png_get_color_type(png_ptr: png_structp; info_ptr: png_infop): png_byte; stdcall;

function png_get_compression_type(png_ptr: png_structp; info_ptr: png_infop): png_byte; stdcall;

function png_get_error_ptr(png_ptr: png_structp): png_voidp; stdcall;

function png_get_filter_type(png_ptr: png_structp; info_ptr: png_infop): png_byte; stdcall;

function png_get_gAMA(png_ptr: png_structp; info_ptr: png_infop; var file_gamma: double): png_uint_32; stdcall;

function png_get_gAMA_fixed(png_ptr: png_structp; info_ptr: png_infop; var int_file_gamma : png_fixed_point ): png_uint_32; stdcall;

function png_get_hIST(png_ptr: png_structp; info_ptr: png_infop; var hist: png_uint_16p): png_uint_32; stdcall;

function png_get_iCCP(png_ptr: png_structp; info_ptr: png_infop; name: png_charpp; var compression_type: int; profile: png_charpp; proflen: png_int_32): png_uint_32; stdcall;

function png_get_image_height(png_ptr: png_structp; info_ptr: png_infop): png_uint_32; stdcall;

function png_get_image_width(png_ptr: png_structp; info_ptr: png_infop): png_uint_32; stdcall;

function png_get_interlace_type(png_ptr: png_structp; info_ptr: png_infop): png_byte; stdcall;

function png_get_io_ptr(png_ptr: png_structp): png_voidp; stdcall;

function png_get_oFFs(png_ptr: png_structp; info_ptr: png_infop; var offset_x, offset_y: png_uint_32; var unit_type: int): png_uint_32; stdcall;

function png_get_pCAL(png_ptr: png_structp; info_ptr: png_infop; var purpose: png_charp; var X0, X1: png_int_32; var typ, nparams: int; var units: png_charp; var params: png_charpp): png_uint_32; stdcall;

function png_get_pHYs(png_ptr: png_structp; info_ptr: png_infop; var res_x, res_y: png_uint_32; var unit_type: int): png_uint_32; stdcall;

function png_get_pixel_aspect_ratio(png_ptr: png_structp; info_ptr: png_infop): float; stdcall;

function png_get_pixels_per_meter(png_ptr: png_structp; info_ptr: png_infop): png_uint_32; stdcall;

function png_get_progressive_ptr(png_ptr: png_structp): png_voidp; stdcall;

function png_get_rgb_to_gray_status(png_ptr: png_structp) : png_byte; stdcall;

function png_get_rowbytes(png_ptr: png_structp; info_ptr: png_infop): png_uint_32; stdcall;

function png_get_rows(png_ptr: png_structp; info_ptr: png_infop): png_bytepp; stdcall;

function png_get_sBIT(png_ptr: png_structp; info_ptr: png_infop; var sig_bits: png_color_8p): png_uint_32; stdcall;

function png_get_sCAL(png_ptr: png_structp; info_ptr: png_infop; var units:int; var width: png_uint_32; height: png_uint_32): png_uint_32; stdcall;

function png_get_sCAL_s( png_ptr : png_structp; info_ptr : png_infop; var units : int; swidth : png_charpp; sheight : png_charpp ): png_uint_32; stdcall;

function png_get_sPLT(png_ptr: png_structp; info_ptr: png_infop;  entries: png_sPLT_tpp): png_uint_32;stdcall;

function png_get_sRGB(png_ptr: png_structp; info_ptr: png_infop; var file_srgb_intent: int): png_uint_32;             stdcall;

function png_get_signature(png_ptr: png_structp; info_ptr: png_infop): png_bytep; stdcall;

function png_get_text(png_ptr: png_structp; info_ptr: png_infop; var text_ptr: png_textp; var num_text: int): png_uint_32; stdcall;

function png_get_tIME(png_ptr: png_structp; info_ptr: png_infop; var mod_time: png_timep): png_uint_32; stdcall;

function png_get_tRNS(png_ptr: png_structp; info_ptr: png_infop; var trans: png_bytep; var num_trans: int; var trans_values: png_color_16p): png_uint_32; stdcall;

function png_get_unknown_chunks( png_ptr: png_structp; info_ptr: png_infop; entries : png_unknown_chunkpp ): png_uint_32; stdcall;

function png_get_user_chunk_ptr(png_ptr: png_structp): png_voidp; stdcall;

function png_get_user_transform_ptr( png_ptr : png_structp ): png_voidp; stdcall;

function png_get_valid(png_ptr: png_structp; info_ptr: png_infop; flag: png_uint_32): png_uint_32; stdcall;

function png_get_x_offset_microns(png_ptr: png_structp; info_ptr: png_infop): png_uint_32; stdcall;

function png_get_x_offset_pixels(png_ptr: png_structp; info_ptr: png_infop): png_uint_32; stdcall;

function png_get_x_pixels_per_meter(png_ptr: png_structp; info_ptr: png_infop): png_uint_32; stdcall;

function png_get_y_offset_microns(png_ptr: png_structp; info_ptr: png_infop): png_uint_32; stdcall;

function png_get_y_offset_pixels(png_ptr: png_structp; info_ptr: png_infop): png_uint_32; stdcall;

function png_get_y_pixels_per_meter(png_ptr: png_structp; info_ptr: png_infop): png_uint_32; stdcall;

//procedure png_init_io( png_ptr : png_structp; fp : TFile ); stdcall;

function png_malloc( png_ptr : png_structp; size : png_uint_32 ) : png_voidp; stdcall;

function png_malloc_default( png_ptr : png_structp; size : png_uint_32 ) : png_voidp; stdcall;

function png_memcpy_check( png_ptr : png_structp; s1 : png_voidp; s2 : png_voidp; size : png_uint_32 ) : png_voidp; stdcall;

function png_memset_check( png_ptr : png_structp; s1 : png_voidp; value : int; size : png_uint_32 ) : png_voidp; stdcall;

procedure png_permit_empty_plte( png_ptr: png_structp; empty_plte_permitted : int); stdcall;

procedure png_process_data(png_ptr: png_structp; info_ptr: png_infop; buffer: png_bytep; buffer_size: png_size_t); stdcall;

procedure png_progressive_combine_row(png_ptr: png_structp; old_row, new_row: png_bytep); stdcall;

procedure png_read_end(png_ptr: png_structp; info_ptr: png_infop); stdcall;

procedure png_read_image(png_ptr: png_structp; image: png_bytepp); stdcall;

procedure png_read_info(png_ptr: png_structp; info_ptr: png_infop); stdcall;

procedure png_read_png(png_ptr: png_structp; info_ptr: png_infop; transforms : int; params : Pointer ); stdcall;

procedure png_read_row(png_ptr: png_structp; row, dsp_row: png_bytep); stdcall;

procedure png_read_rows(png_ptr: png_structp; row, display_row: png_bytepp; num_rows: png_uint_32); stdcall;

procedure png_read_update_info(png_ptr: png_structp; info_ptr: png_infop); stdcall;

procedure png_set_IHDR(png_ptr: png_structp; info_ptr: png_infop; width, height: png_uint_32; bit_depth, color_type, interlace_type, compression_type, filter_type: int); stdcall;

procedure png_set_PLTE(png_ptr: png_structp; info_ptr: png_infop; palette: png_colorp; num_palette: int); stdcall;

procedure png_set_bKGD(png_ptr: png_structp; info_ptr: png_infop; background: png_color_16p); stdcall;

procedure png_set_background(png_ptr: png_structp; background_color: png_color_16p; background_gamma_code, need_expand: int; background_gamma: double);  stdcall;

procedure png_set_bgr(png_ptr: png_structp); stdcall;

procedure png_set_cHRM(png_ptr: png_structp; info_ptr: png_infop; white_x, white_y, red_x, red_y, green_x, green_y, blue_x, blue_y: double); stdcall;

procedure png_set_cHRM_fixed(png_ptr: png_structp; info_ptr: png_infop; white_x, white_y, red_x, red_y, green_x, green_y, blue_x, blue_y: png_fixed_point); stdcall;

procedure png_set_compression_level(png_ptr: png_structp; level: int); stdcall;

procedure png_set_compression_mem_level(png_ptr: png_structp; mem_level: int); stdcall;

procedure png_set_compression_method(png_ptr: png_structp; method: int); stdcall;

procedure png_set_compression_strategy(png_ptr: png_structp; strategy: int); stdcall;

procedure png_set_compression_window_bits(png_ptr: png_structp; window_bits: int); stdcall;

procedure png_set_crc_action(png_ptr: png_structp; crit_action, ancil_action: int); stdcall;

procedure png_set_dither(png_ptr: png_structp; plaette: png_colorp; num_palette, maximum_colors: int; histogram: png_uint_16p; full_dither: int); stdcall;

procedure png_set_error_fn(png_ptr: png_structp; error_ptr: png_voidp; error_fn, warning_fn: png_error_ptr); stdcall;

procedure png_set_expand(png_ptr: png_structp); stdcall;

procedure png_set_filler(png_ptr: png_structp; filler: png_uint_32; filler_loc: int); stdcall;

procedure png_set_filter(png_ptr: png_structp; method, filters: int); stdcall;

procedure png_set_filter_heuristics(png_ptr: png_structp; heuristic_method, num_weights: int; filter_weights, filter_costs: png_doublep); stdcall;

procedure png_set_flush(png_ptr: png_structp; nrows: int); stdcall;

procedure png_set_gAMA(png_ptr: png_structp; info_ptr: png_infop; file_gamma: double); stdcall;

procedure png_set_gAMA_fixed(png_ptr: png_structp; info_ptr: png_infop; file_gamma: png_fixed_point); stdcall;

procedure png_set_gamma(png_ptr: png_structp; screen_gamma, default_file_gamma: double); stdcall;

procedure png_set_gray_1_2_4_to_8(png_ptr: png_structp); stdcall;

procedure png_set_gray_to_rgb(png_ptr: png_structp); stdcall;

procedure png_set_hIST(png_ptr: png_structp; info_ptr: png_infop; hist: png_uint_16p); stdcall;

function png_set_interlace_handling(png_ptr: png_structp): int; stdcall;

procedure png_set_invert_alpha(png_ptr: png_structp); stdcall;

procedure png_set_invert_mono(png_ptr: png_structp); stdcall;

procedure png_set_itxt( png_ptr : png_structp; info_ptr : png_infop; text_ptr : png_textp; num_text : int ); stdcall;

procedure png_set_keep_unknown_chunks( png_ptr : png_structp; keep : int; chunk_list : png_bytep; num_chunks : int ); stdcall;

procedure png_set_oFFs(png_ptr: png_structp; info_ptr: png_infop; offset_x, offset_y: png_uint_32; unit_type: int); stdcall;

procedure png_set_palette_to_rgb(png_ptr: png_structp); stdcall;

procedure png_set_pCAL(png_ptr: png_structp; info_ptr: png_infop; purpose: png_charp; X0, X1: png_int_32; typ, nparams: int; units: png_charp; params: png_charpp); stdcall;

procedure png_set_pHYs(png_ptr: png_structp; info_ptr: png_infop; res_x, res_y: png_uint_32; unit_type: int); stdcall;

procedure png_set_packing(png_ptr: png_structp); stdcall;

procedure png_set_packswap(png_ptr: png_structp); stdcall;

procedure png_set_progressive_read_fn(png_ptr: png_structp; progressive_ptr: png_voidp; info_fn: png_progressive_info_ptr;             row_fn: png_progressive_row_ptr; end_fn: png_progressive_end_ptr); stdcall;

procedure png_set_read_fn(png_ptr : png_structp; io_ptr : png_voidp; read_data_fn : png_rw_ptr); stdcall;

procedure png_set_read_status_fn(png_ptr: png_structp; read_row_fn: png_read_status_ptr); stdcall;

procedure png_set_read_user_chunk_fn(png_ptr: png_structp; read_user_chunk_fn: png_user_chunk_ptr); stdcall;

procedure png_set_read_user_transform_fn(png_ptr: png_structp; read_user_transform_fn: png_user_transform_ptr); stdcall;

procedure png_set_rgb_to_gray(png_ptr: png_structp; error_action : int; red_weight, green_weight: double); stdcall;

procedure png_set_rgb_to_gray_fixed(png_ptr: png_structp;  error_action: int; red_weight, green_weight: png_fixed_point); stdcall;

procedure png_set_rows(png_ptr: png_structp; info_ptr: png_infop; row_pointers: png_bytepp); stdcall;

procedure png_set_sBIT(png_ptr: png_structp; info_ptr: png_infop; sig_bits: png_color_8p); stdcall;

procedure png_set_sCAL( png_ptr : png_structp; info_ptr: png_infop; units : int; width : double; height : double ); stdcall;

procedure png_set_sCAL_s( png_ptr : png_structp; info_ptr: png_infop; units : int; width : png_charp; height : png_charp ); stdcall;

procedure png_set_sRGB(png_ptr: png_structp; info_ptr: png_infop; intent: int); stdcall;

procedure png_set_sRGB_gAMA_and_cHRM(png_ptr: png_structp; info_ptr: png_infop; intent: int); stdcall;

procedure png_set_shift(png_ptr: png_structp; true_bits: png_color_8p); stdcall;

procedure png_set_sig_bytes(png_ptr: png_structp; num_bytes: int); stdcall;

procedure png_set_strip_16(png_ptr: png_structp); stdcall;

procedure png_set_strip_alpha(png_ptr: png_structp); stdcall;

procedure png_set_swap(png_ptr: png_structp); stdcall;

procedure png_set_swap_alpha(png_ptr: png_structp); stdcall;

procedure png_set_tIME(png_ptr: png_structp; info_ptr: png_infop; mod_time: png_timep); stdcall;

procedure png_set_tRNS(png_ptr: png_structp; info_ptr: png_infop; trans: png_bytep; num_trans: int; trans_values: png_color_16p); stdcall;

procedure png_set_tRNS_to_alpha(png_ptr: png_structp); stdcall;

procedure png_set_text(png_ptr: png_structp; info_ptr: png_infop; text_ptr: png_textp; num_text: int); stdcall;

procedure png_set_write_fn(png_ptr: png_structp; io_ptr : png_voidp; write_data_fn : png_rw_ptr; output_flush_fn : png_flush_ptr); stdcall;

procedure png_set_write_status_fn(png_ptr: png_structp; write_row_fn: png_write_status_ptr); stdcall;

procedure png_set_write_user_transform_fn(png_ptr: png_structp; write_user_transform_fn: png_user_transform_ptr); stdcall;

procedure png_set_unknown_chunks( png_ptr: png_structp; info_ptr : png_infop; unknowns : png_unknown_chunkp; num_unknowns : int ) ; stdcall;

procedure png_set_user_transform_info(png_ptr: png_structp; user_transform_ptr : png_voidp; user_transform_depth : int; user_transform_channels : int ); stdcall;

function png_sig_cmp(sig: png_bytep; start, num_to_check: png_size_t): int; stdcall;

procedure png_start_read_image(png_ptr: png_structp); stdcall;

procedure png_warning( png_ptr : png_structp; msg : png_charp ); stdcall;

procedure png_write_chunk(png_ptr: png_structp; chunk_name, data: png_bytep; length: png_size_t); stdcall;

procedure png_write_chunk_data(png_ptr: png_structp; data: png_bytep; length: png_size_t); stdcall;

procedure png_write_chunk_end(png_ptr: png_structp); stdcall;

procedure png_write_chunk_start(png_ptr: png_structp; chunk_name: png_bytep; length: png_uint_32); stdcall;

procedure png_write_end(png_ptr: png_structp; info_ptr: png_infop); stdcall;

procedure png_write_flush(png_ptr: png_structp); stdcall;

procedure png_write_image(png_ptr: png_structp; image: png_bytepp); stdcall;

procedure png_write_info(png_ptr: png_structp; info_ptr: png_infop); stdcall;

procedure png_write_info_before_PLTE(png_ptr: png_structp; info_ptr: png_infop); stdcall;

procedure png_write_png(png_ptr: png_structp; info_ptr: png_infop; transforms : int; params : Pointer ); stdcall;

procedure png_write_row(png_ptr: png_structp; row: png_bytep); stdcall;

procedure png_write_rows(png_ptr: png_structp; row: png_bytepp; num_rows: png_uint_32); stdcall;
             
procedure png_set_iCCP(png_ptr: png_structp; info_ptr: png_infop; name: png_charp; compression_type: int; profile: png_charp; proflen: int); stdcall;

procedure png_set_sPLT(png_ptr: png_structp; info_ptr: png_infop; entries: png_sPLT_tp; nentries: int); stdcall;

// Alpha Macros

function png_composite( Foreground, Alpha, Background: Byte ) : Byte;

function png_composite_16( Foreground, Alpha, Background: Byte ) : png_uint_32;

function png_composite_integer( Foreground, Alpha, Background: Byte ) : Byte;

function png_composite_16_integer( Foreground, Alpha, Background: Byte ) : png_uint_32;

implementation

const
{$IFDEF PNGPX}
  pngDLL = 'lpng-px.dll';
{$ELSE}
  pngDLL = 'lpng.dll';
{$ENDIF}

procedure png_build_grayscale_palette; external pngDLL;
function png_check_sig; external pngDLL;
procedure png_chunk_error; external pngDLL;
procedure png_chunk_warning; external pngDLL;
procedure png_convert_from_time_t; external pngDLL;
function png_convert_to_rfc1123; external pngDLL;
function png_create_info_struct; external pngDLL;
function png_create_read_struct; external pngDLL;
function png_get_copyright; external pngDLL;
function png_get_header_ver; external pngDLL;
function png_get_header_version; external pngDLL;
function png_get_libpng_ver; external pngDLL;
function png_create_write_struct; external pngDLL;
procedure png_destroy_info_struct; external pngDLL;
procedure png_destroy_read_struct; external pngDLL;
procedure png_destroy_write_struct; external pngDLL;
procedure png_error; external pngDLL;
procedure png_free; external pngDLL;
procedure png_free_data; external pngDLL;
procedure png_free_default; external pngDLL;
function png_get_IHDR; external pngDLL;
function png_get_PLTE; external pngDLL;
function png_get_bKGD; external pngDLL;
function png_get_bit_depth; external pngDLL;
function png_get_cHRM; external pngDLL;
function png_get_cHRM_fixed; external pngDLL;
function png_get_channels; external pngDLL;
function png_get_color_type; external pngDLL;
function png_get_compression_type; external pngDLL;
function png_get_error_ptr; external pngDLL;
function png_get_filter_type; external pngDLL;
function png_get_gAMA; external pngDLL;
function png_get_gAMA_fixed; external pngDLL;
function png_get_hIST; external pngDLL;
function png_get_image_height; external pngDLL;
function png_get_image_width; external pngDLL;
function png_get_interlace_type; external pngDLL;
function png_get_io_ptr; external pngDLL;

function png_get_iCCP; external pngDLL;
function png_get_oFFs; external pngDLL;
function png_get_sCAL; external pngDLL;
function png_get_sCAL_s; external pngDLL;
function png_get_sPLT; external pngDLL;
function png_get_pCAL; external pngDLL;
function png_get_pHYs; external pngDLL;
function png_get_pixel_aspect_ratio; external pngDLL;
function png_get_pixels_per_meter; external pngDLL;
function png_get_progressive_ptr; external pngDLL;
function png_get_rgb_to_gray_status; external pngDLL;
function png_get_rowbytes; external pngDLL;
function png_get_rows; external pngDLL;
function png_get_sBIT; external pngDLL;
function png_get_sRGB; external pngDLL;
function png_get_signature; external pngDLL;
function png_get_text; external pngDLL;
function png_get_tIME; external pngDLL;
function png_get_tRNS; external pngDLL;
function png_get_unknown_chunks; external pngDLL;
function png_get_user_chunk_ptr; external pngDLL;
function png_get_user_transform_ptr; external pngDLL;
function png_get_valid; external pngDLL;
function png_get_x_offset_microns; external pngDLL;
function png_get_x_offset_pixels; external pngDLL;
function png_get_x_pixels_per_meter; external pngDLL;
function png_get_y_offset_microns; external pngDLL;
function png_get_y_offset_pixels; external pngDLL;
function png_get_y_pixels_per_meter; external pngDLL;
procedure png_init_io; external pngDLL;
function png_malloc; external pngDLL;
function png_malloc_default; external pngDLL;
function png_memcpy_check; external pngDLL;
function png_memset_check; external pngDLL;
procedure png_permit_empty_plte; external pngDLL;
procedure png_process_data; external pngDLL;
procedure png_progressive_combine_row; external pngDLL;
procedure png_read_end; external pngDLL;
procedure png_read_image; external pngDLL;
procedure png_read_info; external pngDLL;
procedure png_read_png; external pngDLL;
procedure png_read_row; external pngDLL;
procedure png_read_rows; external pngDLL;
procedure png_read_update_info; external pngDLL;
procedure png_set_bKGD; external pngDLL;
procedure png_set_background; external pngDLL;
procedure png_set_bgr; external pngDLL;
procedure png_set_cHRM; external pngDLL;
procedure png_set_cHRM_fixed; external pngDLL;
procedure png_set_compression_level; external pngDLL;
procedure png_set_compression_mem_level; external pngDLL;
procedure png_set_compression_method; external pngDLL;
procedure png_set_compression_strategy; external pngDLL;
procedure png_set_compression_window_bits; external pngDLL;
procedure png_set_crc_action; external pngDLL;
procedure png_set_dither; external pngDLL;
procedure png_set_error_fn; external pngDLL;
procedure png_set_expand; external pngDLL;
procedure png_set_filler; external pngDLL;
procedure png_set_filter; external pngDLL;
procedure png_set_filter_heuristics; external pngDLL;
procedure png_set_flush; external pngDLL;
procedure png_set_gAMA; external pngDLL;
procedure png_set_gAMA_fixed; external pngDLL;
procedure png_set_gamma; external pngDLL;
procedure png_set_gray_1_2_4_to_8; external pngDLL;
procedure png_set_gray_to_rgb; external pngDLL;
procedure png_set_hIST; external pngDLL;
procedure png_set_iCCP; external pngDLL;
procedure png_set_IHDR; external pngDLL;
function png_set_interlace_handling; external pngDLL;
procedure png_set_invert_alpha; external pngDLL;
procedure png_set_invert_mono; external pngDLL;
procedure png_set_itxt; external pngDLL;
procedure png_set_keep_unknown_chunks; external pngDLL;
procedure png_set_oFFs; external pngDLL;
procedure png_set_palette_to_rgb; external pngDLL;
procedure png_set_pCAL; external pngDLL;
procedure png_set_pHYs; external pngDLL;
procedure png_set_PLTE; external pngDLL;
procedure png_set_packing; external pngDLL;
procedure png_set_packswap; external pngDLL;
procedure png_set_progressive_read_fn; external pngDLL;
procedure png_set_read_fn; external pngDLL;
procedure png_set_read_status_fn; external pngDLL;
procedure png_set_read_user_chunk_fn; external pngDLL;
procedure png_set_read_user_transform_fn; external pngDLL;
procedure png_set_rgb_to_gray; external pngDLL;
procedure png_set_rgb_to_gray_fixed; external pngDLL;
procedure png_set_rows; external pngDLL;
procedure png_set_sBIT; external pngDLL;
procedure png_set_sCAL; external pngDLL;
procedure png_set_sCAL_s; external pngDLL;
procedure png_set_sPLT; external pngDLL;
procedure png_set_sRGB; external pngDLL;
procedure png_set_sRGB_gAMA_and_cHRM; external pngDLL;
procedure png_set_shift; external pngDLL;
procedure png_set_sig_bytes; external pngDLL;
procedure png_set_strip_16; external pngDLL;
procedure png_set_strip_alpha; external pngDLL;
procedure png_set_swap; external pngDLL;
procedure png_set_swap_alpha; external pngDLL;
procedure png_set_tIME; external pngDLL;
procedure png_set_tRNS; external pngDLL;
procedure png_set_tRNS_to_alpha; external pngDLL;
procedure png_set_text; external pngDLL;
procedure png_set_write_fn; external pngDLL;
procedure png_set_write_status_fn; external pngDLL;
procedure png_set_write_user_transform_fn; external pngDLL;
procedure png_set_unknown_chunks; external pngDLL;
procedure png_set_user_transform_info; external pngDLL;
function png_sig_cmp; external pngDLL;
procedure png_start_read_image; external pngDLL;
procedure png_warning;external pngDLL;
procedure png_write_chunk; external pngDLL;
procedure png_write_chunk_data; external pngDLL;
procedure png_write_chunk_end; external pngDLL;
procedure png_write_chunk_start; external pngDLL;
procedure png_write_end; external pngDLL;
procedure png_write_flush; external pngDLL;
procedure png_write_image; external pngDLL;
procedure png_write_info; external pngDLL;
procedure png_write_info_before_PLTE; external pngDLL;
procedure png_write_png; external pngDLL;
procedure png_write_row; external pngDLL;
procedure png_write_rows; external pngDLL;

function png_composite( Foreground, Alpha, Background: Byte ) : png_byte;
var
  temp : png_byte;
begin
  temp :=  Foreground * Alpha + Background * ( 255 - Alpha ) + 128;
  result := ( temp + ( temp shr 8 ) ) shr 8;
end;

function png_composite_integer( Foreground, Alpha, Background: Byte ) : png_byte;
begin
  result := png_byte( ( Foreground * Alpha + Background * ( 255 - Alpha ) + 127 ) div 255 );
end;

function png_composite_16( Foreground, Alpha, Background: Byte ) : png_uint_32;
var
  temp : png_uint_32;
begin
  temp :=  Foreground * Alpha + Background * ( 65535 - Alpha ) + 32768;
  result := png_uint_32( ( temp + ( temp shr 16 ) ) shr 16 );
end;

function png_composite_16_integer( Foreground, Alpha, Background: Byte ) : png_uint_32;
begin
  result := png_uint_32( ( Foreground * Alpha + Background * ( 65535 - Alpha ) + 32767 ) div 65535 );
end;

end.





