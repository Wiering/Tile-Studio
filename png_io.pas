unit PNG_IO;

{
2000 Nov 10  Minor change to make writing work,                      [djt]
             and to make 8-bit greyscale images save correctly       [djt]
2000 Nov 18  Make CompressionLevel work correctly on save            [djt]
             Make the three text fields save properly                [djt]
             Add new FilterChoice property                           [djt]
             Add new ForceColor property for input, default True     [djt]
             For 8-bit images, save palettes correctly               [djt]
             For 8-bit images, use palette loaded from PNG           [djt]
2000 Nov 19  Add Software property                                   [djt]
             Unify text saving code                                  [djt]
2000 Nov 21  Add standard OnProgress functions, only tested write.   [djt]
             In this code, moved some up PngImage routines which had
             slipped into the PngGraphic routines.                   [djt]

[djt] => davidtaylor@writeme.com => www.satsignal.net
}


interface

uses
  Windows, SysUtils, Graphics, PngImage, PngDef;

function LoadBmpFromPngFile (bmp: TBitmap;  const Filename: string;
                             const ForceColor: boolean): boolean;

function SaveBmpAsPngFile
   (const bmp: TBitmap;  const Filename: string;
    const Author, Description, Software, Title: string;
    const OnProgress: TProgressEvent{ = nil}): boolean;


implementation

function SaveBmpAsPngFile
   (const bmp: TBitmap;  const filename: string;
    const Author, Description, Software, Title: string;
    const OnProgress: TProgressEvent{ = nil}): boolean;
var
  png: TPngImage;
begin
  png := TPngImage.Create;
  try
    Result := False;
    png.CopyFromBmp (bmp);
    png.CompressionLevel := 4;
    png.Filters := PNG_FILTER_NONE or PNG_FILTER_SUB or PNG_FILTER_PAETH;
    png.Author := Author;
    png.Description := Description;
    png.Software := Software;
    png.Title := Title;
    png.OnProgress := OnProgress;
    png.SaveToFile (Filename);
    Result := True;
  finally
    png.Free;
  end;
end;


function LoadBmpFromPngFile (bmp: TBitmap;  const Filename: string;
                             const ForceColor: boolean): boolean;
var
  png: TPngImage;
begin
  png := TPngImage.Create;
  try
    Result := False;
    png.ForceColor := ForceColor;
    png.LoadFromFile (Filename);
    bmp.Height := 0;
    bmp.Width := 0;
    png.CopyToBmp (bmp);
    Result := True;
  finally
    png.Free;
  end;
end;


end.


