unit PNGImage;
{
  Uberto Barbini (uberto@usa.net)
  23 Jan 2000

  Added Text support ( Title, Author, Description ).
  Added Time support.
  Fixed some bugs.


  14 Dec 1999.

  Disclaimer: I made some quick changes to support both bmp and png images.
  Internally, it works with 24bit DIBs only. If you need some improvements
  just do them and then let me know ;-))

  I used the new Cardinal type with Delphi 4 to avoid warnings.
  If you have D3 or earlier, you have to remove the Default parameters 
  from CopyToBmp. 

  This file is based largely on a similar file produced by Edmund H. Hand.
  This has been modified to work with the newest version of the PNG DLL,
  and many other changes have been made. Do NOT attempt to use this file
  with older versions of the DLL! It requires 1.0.5 (and may work with
  newer versions when they come out).

    
  COPYRIGHT NOTICE:

  The unit is supplied "AS IS".  The Author disclaims all warranties,
  expressed or implied, including, without limitation, the warranties of
  merchantability and of fitness for any purpose.  The Author assumes no
  liability for direct, indirect, incidental, special, exemplary, or
  consequential damages, which may result from the use of this unit, even
  if advised of the possibility of such damage.

  Permission is hereby granted to use, copy, modify, and distribute this
  source code, or portions hereof, for any purpose, without fee, subject
  to the following restrictions:
  1. The origin of this source code must not be misrepresented.
  2. Altered versions must be plainly marked as such and must not be
     misrepresented as being the original source.
  3. This Copyright notice may not be removed or altered from any source or
     altered source distribution.

  I can be reached at:
  Uberto Barbini (uberto@usa.net)
}

interface

uses Windows, SysUtils, Classes, Graphics, PngDef;

type TPngImage = class
  private
    FBitDepth:      integer;
    FBytesPerPixel: integer;
    FColorType:     integer;
    FHeight:        Cardinal; //ub used Cardinal instead of integer
    FWidth:         Cardinal; //ub used Cardinal instead of integer
    Finterlace:     integer;
    Fcompression:   integer;
    Ffilter:        integer;

    Data:           PByte;
    RowPtrs:        PByte;
    RefCount:       Integer;
    FDescription: string;
    FTitle: string;
    FAuthor: string;
    FTextChk: TStringList;
    FLastMod: TdateTime;
  protected
    procedure InitializeDemData;
    procedure SetAuthor(const Value: string);
    procedure SetDescription(const Value: string);
    procedure SetTitle(const Value: string);
    function GetTextChk: TStrings;
  public
    constructor Create;
    destructor  Destroy; override;
    procedure CopyToBmp(var aBmp: TBitmap; originX: integer = 0; originY: Integer = 0);
    procedure CopyFromBmp(const aBmp: TBitmap); 

    procedure Draw(ACanvas: TCanvas; const Rect: TRect);
    function  GetReference: TPngImage;
    procedure LoadFromFile(const Filename: string);
    procedure Release;
    procedure SaveToFile(const Filename: string);
    procedure LoadFromStream( Stream: TStream );
    procedure SaveToStream( Stream: TStream );
  published
    property Title: string read FTitle write SetTitle;
    property Author: string read FAuthor write SetAuthor;
    property Description: string read FDescription write SetDescription;
    property BitDepth:      integer read FBitDepth;
    property BytesPerPixel: integer read FBytesPerPixel;
    property ColorType:     integer read FColorType;
    property Height:        Cardinal read FHeight;
    property Width:         Cardinal read FWidth;

    property Interlace:     integer read Finterlace;
    property Compression:   integer read fcompression;
    property Filter:        integer read ffilter;
    property TextChk: TStrings read GetTextChk;
    property LastModified: TdateTime read FLastMod;
  end;

type TPngGraphic = class(TGraphic)
  private
  protected
    procedure Draw(ACanvas: TCanvas; const Rect: TRect); override;
    function  GetEmpty: Boolean; override;
    function  GetHeight: Integer; override;
    function  GetWidth: Integer; override;
    procedure SetHeight(Value: Integer); override;
    procedure SetWidth(Value: Integer); override;
  public
    Image: TPngImage;

    constructor Create; override;
    destructor Destroy; override;

    procedure Assign(Source: TPersistent); override;
    procedure LoadFromFile(const Filename: string); override;
    procedure SaveToFile(const Filename: string); override;
    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;
    procedure LoadFromClipboardFormat(AFormat: Word; AData: THandle;
              APalette: HPALETTE); override;
    procedure SaveToClipboardFormat(var AFormat: Word; var AData: THandle;
              var APalette: HPALETTE); override;
  published
end;

procedure SaveBmpAsPng( aBitmap: TBitmap; FileName: string ); 
procedure LoadBmpAsPng( aBitmap: TBitmap; FileName: string ); 

implementation
uses Dialogs;

procedure SaveBmpAsPng( aBitmap: TBitmap; FileName: string ); 
  var
    png: TPngImage;
  begin
  png := TPngImage.Create;
    try
    png.CopyFromBmp( aBitmap );
    png.SaveToFile( FileName );
    finally
    png.Free;
    end;
  end;

procedure LoadBmpAsPng( aBitmap: TBitmap; FileName: string ); 
  var
    png: TPngImage;
  begin
  png := TPngImage.Create;
    try
    png.LoadFromFile( FileName );
    png.CopyToBmp( aBitmap );
    finally
    png.Free;
    end;
  end;


//
// TPngImage
//
constructor TPngImage.Create;
begin
  Data     := nil;
  RowPtrs  := nil;
  FHeight  := 0;
  FWidth   := 0;
  RefCount := 1;
  // ub default values
  FColorType := PNG_COLOR_TYPE_RGB;
  Finterlace := PNG_INTERLACE_NONE;
  Fcompression := PNG_COMPRESSION_TYPE_DEFAULT;
  Ffilter := PNG_FILTER_TYPE_DEFAULT;
  FTextChk := TStringList.Create;
end;  // TPngImage.Create

destructor  TPngImage.Destroy;
begin
  FTextChk.Free;
  if Data <> nil then
    FreeMem(Data);
  if RowPtrs <> nil then
    FreeMem(RowPtrs);
end;  // TPngImage.Destroy

procedure TPngImage.Draw(ACanvas: TCanvas; const Rect: TRect);
var
  bmp: TBitmap;
begin
bmp := TBitmap.Create;
  try
  CopyToBmp( bmp );
  acanvas.Draw( 0, 0, bmp );
  finally
  bmp.free;
  end;
end;

procedure TPngImage.CopyToBmp( var aBmp: TBitmap; originX: integer = 0; originY: Integer = 0 ); //ub
var
  valuep:  PByte;
  h, w, x, y:    Integer;
  ndx:     Integer;
  sl:      PByteArray;  // Scanline of bitmap
  slbpp:   Integer;     // Scanline bytes per pixel
  a, r, g, b: Byte;
begin
  if Height > Cardinal( MaxInt ) then
    raise Exception.Create( 'Image too high' );
  if Width > Cardinal( MaxInt ) then
    raise Exception.Create( 'Image too wide' );
  h := FHeight;
  w := FWidth;
  if aBmp.Height < h + originy then
    aBmp.Height := h + originy;
  if aBmp.Width < w + originx then
    aBmp.Width  := w + originx;
  case FBytesPerPixel of
    2: begin
      aBmp.PixelFormat := pf16Bit;
      slbpp := 2;
    end;
    else begin
      aBmp.PixelFormat := pf24Bit;
      slbpp := 3;
    end;
  end;

  // point to data
  valuep := Data;
  for y := 0 to FHeight - 1 do
  begin
    sl := aBmp.Scanline[ y + originy ];  // current scanline
    for x := 0 to FWidth - 1 do
    begin
      ndx := ( x + originx ) * slbpp;    // index into current scanline
      if FBytesPerPixel = 2 then
      begin
        // handle 16bit grayscale images, this will display them
        // as a 16bit color image, kinda hokie but fits my needs
        // without altering the data.
        sl[ndx]     := valuep^;  Inc(valuep);
        sl[ndx + 1] := valuep^;  Inc(valuep);
      end
      else if FBytesPerPixel = 3 then
      begin
        // RGB - swap blue and red for windows format
        sl[ndx + 2] := valuep^;  Inc(valuep);
        sl[ndx + 1] := valuep^;  Inc(valuep);
        sl[ndx]     := valuep^;  Inc(valuep);
      end
      else  // 4 bytes per pixel of image data
      begin
        // Alpha chanel present and RGB
        // this is what PNG is all about
        r := valuep^;  Inc(valuep);
        g := valuep^;  Inc(valuep);
        b := valuep^;  Inc(valuep);
        a := valuep^;  Inc(valuep);
        if a = 0 then
        begin
          // alpha is zero so no blending, just image data
          sl[ndx]     := b;
          sl[ndx + 1] := g;
          sl[ndx + 2] := r;
        end
        else if a < 255 then
        begin
          // blend with data from ACanvas as background
          sl[ndx]     := ((sl[ndx] * a) + ((255 - a) * b)) div 255;
          sl[ndx + 1] := ((sl[ndx + 1] * a) + ((255 - a) * g)) div 255;
          sl[ndx + 2] := ((sl[ndx + 2] * a) + ((255 - a) * r)) div 255;
        end;
        // if a = 255 then do not place any color from the image at this
        // pixel, but leave the background intact instead.
      end;
    end;
  end;
end;  // TPngImage.CopyToBmp

procedure TPngImage.CopyFromBmp( const aBmp: TBitmap);
var
  valuep:  PByte;
  x, y:    Integer;
  ndx:     Integer;
  sl:      PByteArray;  // Scanline of bitmap
  png:     png_structp; // PPng_Struct;
  pnginfo:  png_infop; //  PPng_Info;
  tmp:      array[0..32] of char;
begin
  aBmp.PixelFormat := pf24Bit;

  FWidth := aBmp.Width;
  FHeight := aBmp.Height;
  FBitDepth := 8; // Single channel
  FColorType := PNG_COLOR_TYPE_RGB;
  FBytesPerPixel := 3; // works with 24bits only

  InitializeDemData;
  tmp := PNG_LIBPNG_VER_STRING;
  png :=  png_create_write_struct(tmp, nil, nil, nil);
  pnginfo := png_create_info_struct( png );
  png_set_IHDR(png, pnginfo, FWidth, FHeight, FBitDepth, FColorType,
               PNG_INTERLACE_NONE, PNG_COMPRESSION_TYPE_DEFAULT,
               PNG_FILTER_TYPE_DEFAULT);
          

  if (Data <> nil) and (RowPtrs <> nil) then // Read the image
  begin

    valuep := Data;
    for y := 0 to FHeight - 1 do
    begin
      sl := aBmp.Scanline[ y  ];  // current scanline
      for x := 0 to FWidth - 1 do
      begin
        ndx := x * 3;    // index into current scanline

          // RGB - swap blue and red for windows format
        valuep^ := sl[ndx + 2];
        Inc(valuep);
        valuep^ := sl[ndx + 1];
        Inc(valuep);
        valuep^ := sl[ ndx ];
        Inc(valuep);
      end;
    end;
  end;

end;  // TPngImage.CopyToBmp

function  TPngImage.GetReference: TPngImage;
begin
  Inc(RefCount);
  Result := Self;
end;  // TPngImage.GetReference

procedure TPngImage.InitializeDemData;
var
  cvaluep:  ^Cardinal; //ub
  y:        Cardinal;
begin
  // Initialize Data and RowPtrs
  if Data <> nil then
    FreeMem(Data);
  Data := nil;
  if RowPtrs <> nil then
    FreeMem(RowPtrs);
  RowPtrs := nil;

  GetMem(Data, FHeight * FWidth * Cardinal( FBytesPerPixel ) );
  GetMem(RowPtrs, sizeof(Pointer) * FHeight);
  if (Data <> nil) and (RowPtrs <> nil) then
  begin
    cvaluep := Pointer(RowPtrs);
    for y := 0 to FHeight - 1 do
    begin
      cvaluep^ := Cardinal(Data) + (FWidth * Cardinal( FBytesPerPixel ) * y);
      Inc(cvaluep);
    end;
  end;  // if (Data <> nil) and (RowPtrs <> nil) then
end;  // TPngImage.InitializeDemData

var
  CurrStream : TStream;
  ioBuffer: array [ 0 .. 8192 ] of byte; //??

procedure ReadData(png_ptr: Pointer;var data: Pointer;length: png_size_t); stdcall;
  begin // Callback to read from stream
  if length <= sizeof( ioBuffer ) then
    CurrStream.ReadBuffer( data, length )
  else
    raise Exception.Create( 'Buffer override: needed ' + inttostr( length ) + 'bytes for buffer !' );
  end;

procedure WriteData(png_ptr: Pointer;var data: Pointer;length: png_size_t); stdcall;
  begin // Callback to read from stream
  // Note that you can write also if data = nil (write 0)
  if length <= sizeof( ioBuffer ) then
    CurrStream.WriteBuffer( data, length )
  else
    raise Exception.Create( 'Buffer override: needed ' + inttostr( length ) );
  end;

procedure FlushData(png_ptr: Pointer); stdcall;
  begin // Callback to flush the stream
  end;
  
procedure TPngImage.LoadFromStream( Stream: TStream );
var
  png:      png_structp;
  pnginfo:  png_infop;
  rowbytes: Cardinal;
  tmp:      array[0..31] of char;
  sig:      array[0..3] of byte;
  Txt : png_textp;
  i, nTxt: integer;
  s: string;
  Time: png_timep;
 
begin
  Stream.ReadBuffer( sig, sizeof( sig ) ); 
  CurrStream := Stream;
  if png_sig_cmp( @sig, 0, sizeof( sig )) <> 0 then
   raise Exception.Create( 'Is not a valid PNG !' );

  tmp := PNG_LIBPNG_VER_STRING;
  png := png_create_read_struct(tmp, nil, nil, nil);
  if assigned( png ) then
  begin
    pnginfo := png_create_info_struct( png );
    try
      if not assigned( pnginfo ) then
        raise Exception.Create( 'Failed to Create info struct' );

      png_set_sig_bytes(png, sizeof( sig ) );

      png_set_read_fn( png, @ioBuffer, ReadData);
      
      png_read_info(png, pnginfo);

      nTxt := 0;
      png_get_text( png, pnginfo, Txt, nTxt );

      FTextChk.Clear;
      for i := 0 to nTxt - 1 do
        begin // load all text in FTextChk
        s := txt^.key;
        s := s + '=' + Txt^.text; // better use no more than a pchar at time
        FTextChk.Add( s );
        if compareText( Txt^.key, 'Title' ) = 0 then
          FTitle := Txt^.text // load Title if present
        else if compareText( Txt^.key, 'Author' ) = 0 then
          FAuthor := Txt^.text// load Author if present
        else if compareText( Txt^.key, 'Description' ) = 0 then
          FDescription := Txt^.text; // load Description if present
        inc( Txt );
        end;

      png_get_IHDR(png, pnginfo, FWidth, FHeight,FBitDepth, FColorType, Finterlace, Fcompression, Ffilter );
     
      png_set_invert_alpha(png);

      // if bit depth is less than 8 then expand...
      if (FColorType = PNG_COLOR_TYPE_PALETTE) and
         (FBitDepth <= 8) then
        png_set_expand(png);
      if (FColorType = PNG_COLOR_TYPE_GRAY) and
         (FBitDepth < 8) then
        png_set_expand(png);
      // Add alpha channel if pressent
      if png_get_valid(png, pnginfo, PNG_INFO_tRNS) = PNG_INFO_tRNS then
        png_set_expand(png);
      // expand images to 1 pixel per byte
      if FBitDepth < 8 then
        png_set_packing(png);
      // Swap 16 bit images to PC Format
      if FBitDepth = 16 then
        png_set_swap(png);
      // update the info structure
      png_read_update_info(png, pnginfo);
      png_get_IHDR(png, pnginfo, FWidth, FHeight,
                   FBitDepth, FColorType, Finterlace, Fcompression, Ffilter );

      rowbytes := png_get_rowbytes(png, pnginfo);
      FBytesPerPixel := rowbytes div FWidth;
      InitializeDemData;
      if (Data <> nil) and (RowPtrs <> nil) then
        // Read the image
        png_read_image(png, png_bytepp(RowPtrs));

      png_read_end(png, pnginfo); // read last information chunks

      if png_get_time( png, pnginfo, Time ) > 0 then
        begin // get time if possible
        FLastMod := EncodeDate( time.year, time.month, time.Day );
        FLastMod := FLastMod + EncodeTime( time.hour, time.minute, time.second, 0 );
        end;
        
    finally
      png_destroy_read_struct(@png, @pnginfo, nil);
    end;  // try pnginfo create
  end;
end;

procedure TPngImage.LoadFromFile(const Filename: string);
var
  pngf: TFileStream;
begin
  pngf := TFileStream.Create( FileName, fmOpenRead );
  try
    pngf.Position := 0;
    LoadFromStream( pngf );
  finally
    pngf.free;
  end;
end;

procedure TPngImage.Release;
begin
  Dec(RefCount);
  if RefCount <= 0 then
    Destroy;
end;  // TPngImage.Release

procedure TPngImage.SaveToStream( Stream: TStream );
var
  png:      png_structp; // PPng_Struct;
  pnginfo:  png_infop; // PPng_Info;
  tmp:      array[0..32] of char;
//  costs, weights: array[ 0..4] of double;
  Txt : array[ 0 .. 2 ] of png_text;
  Time: png_time;
  yy, mm, dd, hh, mi, ss, ms: word;
begin
  CurrStream := Stream;
  tmp := PNG_LIBPNG_VER_STRING;
  png := png_create_write_struct(tmp, nil, nil, nil);
  if assigned( png ) then
  begin
    // create info struct and init io functions
    pnginfo := png_create_info_struct(png);
    try
      // set image attributes, compression, etc...
      png_set_write_fn(png, @ioBuffer, writedata, flushdata );

      png_set_IHDR(png, pnginfo, FWidth, FHeight, FBitDepth, FColorType, Finterlace, Fcompression, Ffilter );

      if ( FAuthor <> '' ) or ( FTitle <> '' ) or ( FDescription <> '' ) then
        begin // save text information only when needed
        Txt[ 0 ].key := 'Author';
        Txt[ 0 ].text := pchar( FAuthor );
        Txt[ 0 ].text_length := length( FAuthor );
        Txt[ 0 ].compression := PNG_TEXT_COMPRESSION_NONE;
        Txt[ 1 ].key := 'Title';
        Txt[ 1 ].text := pchar( FTitle );
        Txt[ 1 ].text_length := length( FTitle );
        Txt[ 1 ].compression := PNG_TEXT_COMPRESSION_NONE;
        Txt[ 2 ].key := 'Description';
        Txt[ 2 ].text := pchar( FDescription );
        Txt[ 2 ].text_length := length( FDescription );
        Txt[ 2 ].compression := PNG_TEXT_COMPRESSION_zTXt;
        png_set_text(png, pnginfo, @Txt, 3);
        end;

      png_write_info(png, pnginfo); 

      png_set_compression_level( png, 9 ); //best compression
      
{      // this'd force the DLL to calculate best filter for each row
       // but it doen't worth of. I'm not sure why.
      weights[ 0 ] := 1.0;
      weights[ 1 ] := 1.0;
      weights[ 2 ] := 1.0;
      weights[ 3 ] := 1.0;
      weights[ 4 ] := 1.0;
      costs[ 0 ] := 1.0;
      costs[ 1 ] := 1.0;
      costs[ 2 ] := 1.0;
      costs[ 3 ] := 1.0;
      costs[ 4 ] := 1.0;
      png_set_filter_heuristics( png, PNG_FILTER_HEURISTIC_WEIGHTED, 5, @weights, @costs );
}
      png_set_filter( png, PNG_FILTER_TYPE_BASE, PNG_FILTER_NONE or PNG_FILTER_SUB or PNG_FILTER_UP); // fast and good filtering
      
      if (Data <> nil) and (RowPtrs <> nil) then
        begin
          // Swap 16 bit images from PC Format
          if FBitDepth = 16 then
            png_set_swap(png);
          // Write the image
          png_write_image(png, png_bytepp(RowPtrs));

          // Now you can add text or time thunks to pnginfo if you want them save after image
          // I added time chunk for example but you'd use it only if you have changed the image.
          DecodeDate( Now, yy, mm, dd );
          DecodeTime( Now, hh, mi, ss, ms );
          time.year := yy;
          Time.month := mm;
          Time.day := dd;
          Time.hour := hh;
          Time.minute := mi;
          Time.second := ss;
          png_set_tIME( png, pnginfo, @time );
          
          png_write_end(png, pnginfo );             
        end;  // if buf <> nil
      finally
        png_destroy_write_struct(@png, @pnginfo);
      end;  // try pnginfo create
    end;
  end;

procedure TPngImage.SaveToFile(const Filename: string);
var
  pngf: TFileStream;
begin
  pngf := TFileStream.Create( FileName, fmCreate );
  try
    pngf.Position := 0;
    SaveToStream( pngf );
  finally
    pngf.free;
  end;
end;
  // TPngImage.SaveToFile

//
// TPngGraphic
//
constructor TPngGraphic.Create;
begin
inherited; 
  SetTransparent(True);
  Image := TPngImage.Create; 
end;  // TPngGraphic.Create

destructor TPngGraphic.Destroy;
begin
  Image.Release;
inherited; 
end;  // TPngGraphic.Destroy

procedure TPngGraphic.Assign(Source: TPersistent);
begin
  if Source is TPngGraphic then
  begin
    if Assigned(Image) then
      Image.Release;

    if Assigned(Source) then
    begin
      Image := TPngGraphic(Source).Image;
    end
    else
    begin
      Image := TPngImage.Create;
    end;
    Changed(Self);
    Image := TPngGraphic(Source).Image.GetReference;
  end
  else
    inherited Assign(Source);
end;  // TPngGraphic.Assign

procedure TPngGraphic.Draw(ACanvas: TCanvas; const Rect: TRect);
begin
  if Assigned(Image) then
    Image.Draw(ACanvas, Rect);
end;  // TPngGraphic.Draw

function  TPngGraphic.GetEmpty: Boolean;
begin
  if Assigned(Image) then
    Result := False
  else
    Result := True;
end;  // TPngGraphic.GetEmpty

function TPngGraphic.GetHeight: Integer;
begin
  Result := Image.Height;
end;  // TPngGraphic.GetHeight

function TPngGraphic.GetWidth: Integer;
begin
  Result := Image.Width;
end;  // TPngGraphic.GetWidth

procedure TPngGraphic.LoadFromClipboardFormat(AFormat: Word; AData: THandle;
          APalette: HPALETTE);
begin
  raise Exception.Create('Cannot load a TPngGraphic from the Clipboard');
end;  // TPngGraphic.LoadFromClipboardFormat

procedure TPngGraphic.LoadFromFile(const Filename: string);
begin
  if not Assigned(Image) then
    Image := TPngImage.Create;
  Image.LoadFromFile(Filename);
end;  // TPngGraphic.LoadFromFile

procedure TPngGraphic.LoadFromStream(Stream: TStream);
begin
  if Assigned(Image) then
    Image.LoadFromStream( Stream );
end;  // TPngGraphic.LoadFromStream

procedure TPngGraphic.SaveToClipboardFormat(var AFormat: Word;
          var AData: THandle; var APalette: HPALETTE);
begin
  raise Exception.Create('Cannot save a TPngGraphic to the Clipboard');
end;  // TPngGraphic.SaveToClipboardFormat

procedure TPngGraphic.SaveToFile(const Filename: string);
begin
  if Assigned(Image) then
    Image.SaveToFile(Filename);
end;  // TPngGraphic.SaveToFile

procedure TPngGraphic.SaveToStream(Stream: TStream);
begin
  if Assigned(Image) then
    Image.SaveToStream( Stream );
end;  // TPngGraphic.SaveToStream

procedure TPngGraphic.SetHeight(Value: Integer);
begin
  raise Exception.Create('Cannot set height on a TPngGraphic');
end;  // TPngGraphic.SetHeight

procedure TPngGraphic.SetWidth(Value: Integer);
begin
  raise Exception.Create('Cannot set width on a TPngGraphic');
end;  // TPngGraphic.SetWidth

procedure TPngImage.SetAuthor(const Value: string);
begin
  FAuthor := Value;
end;

procedure TPngImage.SetDescription(const Value: string);
begin
  FDescription := Value;
end;

procedure TPngImage.SetTitle(const Value: string);
begin
  FTitle := Value;
end;

function TPngImage.GetTextChk: TStrings;
begin
  result := FTextChk;
end;

initialization
  TPicture.RegisterFileFormat('PNG', 'Portable Network Graphics', TPngGraphic);

end.
