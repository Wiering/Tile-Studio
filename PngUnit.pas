{ PngUnit - Read, view and save PNG, convert BMP to PNG (PNG = Portable Network Graphics)
  http://SharePower.VirtualAve.net/png.html
  Freeware (c) 1999, Jack Goman  jack@SharePower.VirtualAve.net
  This unit based of PngImage.Pas - Copyright 1998 Edmund H. Hand  edhand@worldnet.att.net

Sample code:
  WriteBitmapToPngFile('C:\pngtest.png', Image1.Picture.Bitmap,clNone);  //write Image1 to pngtest.png
  WriteBitmapToPngFile('C:\pngtest.png', Image1.Picture.Bitmap,clRed);   //write Image1 to pngtest.png, replace all red Pixel with 100% Transparency
  ReadBitmapFromPngFile('C:\pngtest.png', Bitmap1);                      //read a PNG file


 * libpng.txt - A description on how to use and modify libpng
 * See libpng.txt for more information.  The PNG specification is available
 * as RFC 2083 <ftp://ftp.uu.net/graphics/png/documents/>
 * and as a W3C Recommendation <http://www.w3.org/TR/REC.png.html>
 * Other information about PNG can be found at the PNG home page, <http://www.cdrom.com/pub/png/>.

WARNING! THE CODE IS PROVIDED AS IS WITH NO GUARANTEES OF ANY KIND!
USE THIS AT YOUR OWN RISK - YOU ARE THE ONLY PERSON RESPONSIBLE FOR
ANY DAMAGE THIS CODE MAY CAUSE - YOU HAVE BEEN WARNED!

}
unit PngUnit;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

uses
{$IFnDEF FPC}
  Windows,
{$ELSE}
  LCLIntf, LCLType, LMessages,
{$ENDIF}
  SysUtils, Classes, Graphics, PngLib;

function WriteBitmapToPngFile( Filename : string; Bitmap : TBitmap; TransparentColor:TColor):boolean;
function ReadBitmapFromPngFile( Filename : string; var Bitmap : TBitmap ):boolean;


implementation

// {$O-} // {$Q+} {$R+}

type
  TPicData=record
    Stream:TMemoryStream;
    APtr:Pointer;
    blinewidth,linewidth,Width,Height:INTEGER;
  end;

var Data, RowPtrs:PByte;
    FWidth,FHeight,FColorType,FBytesPerPixel,FBitDepth:Integer;

function SetBitmapStream(Bitmap:TBitmap;var PicData:TPicData):boolean;
VAR dc:hDC;
    I:INTEGER;
BEGIN
  PicData.Stream.Clear;
  PicData.Stream.SetSize(  SizeOf (TBITMAPINFOHEADER)+ Bitmap.Height*(Bitmap.Width+4)*3);
  WITH TBITMAPINFOHEADER(PicData.Stream.Memory^) DO BEGIN biSize := SizeOf(TBITMAPINFOHEADER); biWidth := Bitmap.Width; biHeight := Bitmap.Height;
    biPlanes := 1; biBitCount := 24; biCompression := bi_RGB; biSizeImage := 0; biXPelsPerMeter :=1; biYPelsPerMeter :=1; biClrUsed :=0; biClrImportant :=0; END;

  PicData.Aptr := Pchar(PicData.Stream.Memory) +SizeOf (TBITMAPINFOHEADER);
  dc := GetDC(0);
  I:=GetDIBits(dc, Bitmap.Handle, 0, Bitmap.Height, PicData.Aptr, TBITMAPINFO(PicData.Stream.Memory^), dib_RGB_Colors);
  ReleaseDC(0,dc);

  PicData.Width:=Bitmap.Width;
  PicData.Height:=Bitmap.Height;
  PicData.linewidth := (Bitmap.Width*3);
  PicData.linewidth := ((PicData.linewidth+3)DIV 4)*4;
  PicData.blinewidth := (Bitmap.Height*3);
  PicData.blinewidth := ((PicData.blinewidth+3)DIV 4)*4;
end;



procedure InitializeDemData;
var
  cvaluep:  PCardinal;
  y:        Integer;
begin
  // Initialize Data and RowPtrs
  if Data <> nil then FreeMem(Data);
  Data := nil;
  if RowPtrs <> nil then FreeMem(RowPtrs);
  RowPtrs := nil;

  GetMem(Data, FHeight * FWidth * FBytesPerPixel);
  GetMem(RowPtrs, sizeof(Pointer) * FHeight);
  if (Data <> nil) and (RowPtrs <> nil) then begin
    cvaluep := Pointer(RowPtrs);
    for y := 0 to FHeight - 1 do begin
      cvaluep^ := Cardinal(Data) + (FWidth * FBytesPerPixel * y);
      Inc(cvaluep);
    end;
  end;  // if (Data <> nil) and (RowPtrs <> nil) then
end;


procedure LoadPngFromFile(const Filename: string);
var
  png:      PPng_Struct;
  pnginfo:  PPng_Info;
  rowbytes: Cardinal;
  PngFile:  Pointer;
  tmp:      array[0..32] of char;
begin
  pngfile := png_open_file(@Filename[1], 'rb');
  if pngfile = nil then
    raise Exception.Create('Error Opening File ' + Filename + '!');

  try
    StrPCopy(tmp, PNG_LIBPNG_VER_STRING);
    try
      png := png_create_read_struct(tmp, nil, nil, nil);
      if png <> nil then
      begin
        try
          pnginfo := png_create_info_struct(png);
          png_init_io(png, pngfile);
          png_set_read_status_fn(png, nil);
          png_read_info(png, pnginfo);
          png_get_IHDR(png, pnginfo, @FWidth, @FHeight,
                       @FBitDepth, @FColorType, nil, nil, nil);
          png_set_invert_alpha(png);
          // if bit depth is less than 8 then expand...
          if (FColorType = PNG_COLOR_TYPE_PALETTE) and (FBitDepth <= 8) then png_set_expand(png);
          if (FColorType = PNG_COLOR_TYPE_GRAY) and (FBitDepth < 8) then png_set_expand(png);
          // Add alpha channel if pressent
          if png_get_valid(png, pnginfo, PNG_INFO_tRNS) = PNG_INFO_tRNS then png_set_expand(png);
          // expand images to 1 pixel per byte
          if FBitDepth < 8 then png_set_packing(png);
          // Swap 16 bit images to PC Format
          if FBitDepth = 16 then png_set_swap(png);
          // update the info structure
          png_read_update_info(png, pnginfo);
          png_get_IHDR(png, pnginfo, @FWidth, @FHeight, @FBitDepth, @FColorType, nil, nil, nil);

          rowbytes := png_get_rowbytes(png, pnginfo);
          FBytesPerPixel := rowbytes div FWidth;
          InitializeDemData;
          if (Data <> nil) and (RowPtrs <> nil) then
            // Read the image
            png_read_image(png, PPByte(RowPtrs));
        finally
          png_destroy_read_struct(@png, @pnginfo, nil);
        end;  // try pnginfo create
      end;  // png <> nil
    except
      raise Exception.Create('Error Reading File!');
    end;  // try png create

  finally
    png_close_file(pngfile);
  end;
end;


procedure DrawPng(ACanvas: TCanvas; const Rect: TRect);
var
  valuep:  PByte;
  x, y:    Integer;
  ndx:     Integer;
  bm:      TBitmap;
  sl:      PByteArray;  // Scanline of bitmap
  slbpp:   Integer;     // Scanline bytes per pixel
  a, r, g, b: Byte;
begin
  // Create temporary bitmap
  bm := TBitmap.Create;
  bm.Height := FHeight;
  bm.Width  := FWidth;
  case FBytesPerPixel of
    2: begin
      bm.PixelFormat := pf16Bit;
      slbpp := 2;
    end;
    else begin
      bm.PixelFormat := pf24Bit;  //this is standard
      slbpp := 3;
    end;
  end;
  // Copy canvas to temporary bitmap
  BitBlt(bm.Canvas.Handle, 0, 0, FWidth, FHeight, ACanvas.Handle, Rect.Left, Rect.Top, SRCCOPY);

  // point to data
  valuep := Data;
  for y := 0 to FHeight - 1 do
  begin
    sl := bm.Scanline[y];  // current scanline
    for x := 0 to FWidth - 1 do
    begin
      ndx := x * slbpp;    // index into current scanline
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
  BitBlt(ACanvas.Handle, Rect.Left, Rect.Top, FWidth, FHeight, bm.Canvas.Handle, 0, 0, SRCCOPY);
  bm.Free;
end;

procedure SaveBitsToPngFile(const Filename: string);
var
  png:      PPng_Struct;
  pnginfo:  PPng_Info;
  tmp:      array[0..32] of char;
  pngfile:  Pointer;
  pngtext:  PPng_Text;
begin
  pngfile := png_open_file(@Filename[1], 'wb');
  if pngfile = nil then
  begin
    raise Exception.Create('Error Opening File ' + Filename + '!');
    exit;
  end;

  try
    StrPCopy(tmp, PNG_LIBPNG_VER_STRING);
    try
      png := png_create_write_struct(tmp, nil, nil, nil);
      if png <> nil then
      begin
        try
          // create info struct and init io functions
          pnginfo := png_create_info_struct(png);
          png_init_io(png, pngfile);
          png_set_write_status_fn(png, nil);
          // set image attributes, compression, etc...
          png_set_IHDR(png, pnginfo, FWidth, FHeight, FBitDepth, FColorType,
                       PNG_INTERLACE_NONE, PNG_COMPRESSION_TYPE_DEFAULT,
                       PNG_FILTER_TYPE_DEFAULT);


       //   pngtext.key := 'Software'; //The keywords that are given in the PNG Specification are: Title, Author, Description, Copyright, Creation Time, Software, Comment...
       //   pngtext.text := 'PngUnit'; // http://SharePower.VirtualAve.net/png.html'; // obsolete
       //   pngtext.compression := PNG_TEXT_COMPRESSION_NONE;
       //   png_set_text(png, pnginfo, pngtext, 1);

          png_write_info(png, pnginfo);
          if (Data <> nil) and (RowPtrs <> nil) then
          begin
            // Swap 16 bit images from PC Format
            if FBitDepth = 16 then png_set_swap(png);
            // Write the image
            png_write_image(png, PPByte(RowPtrs));
            png_write_end(png, pnginfo);
            png_write_flush(png);
          end;  // if buf <> nil
          pngtext:=nil;
        finally
          png_destroy_write_struct(@png, @pnginfo);
        end;  // try pnginfo create
      end;  // png <> nil
    except
      raise Exception.Create('Error Writing PNG File!');
    end;  // try png create
  finally
    png_close_file(pngfile);
  end;
end;



function ReadBitmapFromPngFile( Filename : string; var Bitmap : TBitmap ):boolean;
begin
  Data     := nil;
  RowPtrs  := nil;
  FHeight  := 0;
  FWidth   := 0;

  LoadPngFromFile(FileName);
  Bitmap.Width:=FWidth;
  Bitmap.Height:=FHeight;
  DrawPng(Bitmap.Canvas, Rect(0,0,Bitmap.Width,Bitmap.Height));
  //Bitmap.Canvas.Refresh;
  //Bitmap.Canvas.Invalidate;

  if Data <> nil then FreeMem(Data);
  if RowPtrs <> nil then FreeMem(RowPtrs);
end;


function WriteBitmapToPngFile( Filename : string; Bitmap : TBitmap; TransparentColor:TColor):boolean;
var x,y:integer;
    AktPicP,AktP:PChar;
    PicData:TPicData;
    valueP:  PByte;
var
  P: PChar;
  i, j, k: Integer;
  r, g, b: Integer;

begin
  PicData.Stream:=TMemoryStream.Create;
  SetBitmapStream(Bitmap,PicData);

  Data:=nil;
  RowPtrs:=nil;
  FWidth:=PicData.Width;
  FHeight:=PicData.Height;
  if TransparentColor=clNone then begin
    FColorType:=PNG_COLOR_TYPE_RGB; //PNG_COLOR_TYPE_PALETTE; //PNG_COLOR_TYPE_GRAY  PNG_COLOR_TYPE_RGB_ALPHA
    FBytesPerPixel:=3; //2 - gray, 3 - RGB, 4 - RGB+Alpha
  end else begin
    FColorType:=PNG_COLOR_TYPE_RGB_ALPHA;
    FBytesPerPixel:=4;
  end;

  FBitDepth:=8;
  InitializeDemData;

  if TransparentColor=clNone then begin
    FOR y := 0 TO  PicData.Height-1 DO FOR x:=0 TO PicData.Width-1 DO BEGIN
      AktPicP := PChar(PicData.Aptr) +  y*PicData.LineWidth + x*3;
      AktP := PChar(Data) +  (PicData.Height-1-y)*(FBytesPerPixel*PicData.Width) + x*FBytesPerPixel;
      BYTE((AktP+0)^):=BYTE((AktPicP+2)^); //Red
      BYTE((AktP+1)^):=BYTE((AktPicP+1)^); //Green
      BYTE((AktP+2)^):=BYTE((AktPicP+0)^); //Blue
    end;
  end else begin
    FOR y := 0 TO  PicData.Height-1 DO FOR x:=0 TO PicData.Width-1 DO BEGIN
      AktPicP := PChar(PicData.Aptr) +  y*PicData.LineWidth + x*3;
      AktP := PChar(Data) +  (PicData.Height-1-y)*(FBytesPerPixel*PicData.Width) + x*FBytesPerPixel;
      BYTE((AktP+0)^):=BYTE((AktPicP+2)^);  //Red
      BYTE((AktP+1)^):=BYTE((AktPicP+1)^);  //Green
      BYTE((AktP+2)^):=BYTE((AktPicP+0)^);  //Blue
      if RGB(BYTE((AktPicP+2)^),BYTE((AktPicP+1)^),BYTE((AktPicP+0)^))=TransparentColor AND $FFFFFF then BYTE((AktP+3)^):=0 else BYTE((AktP+3)^):=255;
    end;

    // MW 2009: prevent the transparent color from showing by replacing it with the closest visible color

    FOR y := 0 TO  PicData.Height-1 DO FOR x:=0 TO PicData.Width-1 DO BEGIN
      AktP := PChar(Data) +  (PicData.Height-1-y)*(FBytesPerPixel*PicData.Width) + x*FBytesPerPixel;
      if BYTE((AktP+3)^) = 0 then
      begin
        r := 0;
        g := 0;
        b := 0;
        k := 0;
        for j := -1 to 1 do
          for i := -1 to 1 do
            if (i <> 0) or (j <> 0) then
              if (x + i >= 0) and (x + i <= PicData.Width - 1) then
                if (y + j >= 0) and (y + j <= PicData.Height - 1) then
              begin
                P := PChar(Data) + (PicData.Height-1-(y+j))*(FBytesPerPixel*PicData.Width) + (x+i)*FBytesPerPixel;
                if BYTE((P+3)^) <> 0 then
                begin
                  Inc (r, BYTE((P+0)^));
                  Inc (g, BYTE((P+1)^));
                  Inc (b, BYTE((P+2)^));
                  inc (k);
                end;
              end;
        if (k > 0) then
        begin
          Byte ((AktP + 0)^) := Byte (r div k);
          Byte ((AktP + 1)^) := Byte (g div k);
          Byte ((AktP + 2)^) := Byte (b div k);
        end;
      end;
    end;

  end;

  SaveBitsToPngFile(Filename);
  PicData.Stream.Free;

  if Data <> nil then FreeMem(Data);
  if RowPtrs <> nil then FreeMem(RowPtrs);
end;


end.

