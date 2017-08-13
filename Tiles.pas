unit Tiles;

  {
      Tile Studio

      Copyright (c) 2000-2017, Mike Wiering, Wiering Software

      Permission is hereby granted, free of charge, to any person obtaining a copy
      of this software and associated documentation files (the "Software"), to deal
      in the Software without restriction, including without limitation the rights
      to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
      copies of the Software, and to permit persons to whom the Software is
      furnished to do so, subject to the following conditions:

      The above copyright notice and this permission notice shall be included in all
      copies or substantial portions of the Software.

      THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
      IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
      FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
      AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
      LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
      OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
      SOFTWARE.
  }

  {$I SETTINGS.INC}

interface

  uses
    Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
    Menus, ExtCtrls, ComCtrls, StdCtrls, Grids, jpeg, ToolWin, Buttons, SZPCX;


  const
    TRANS_COLOR             : Integer = $FF + $00 * $100 + $FF * $10000;
    TRANS_COLOR_REPLACEMENT : Integer = $FF + $04 * $100 + $FF * $10000;

    SPECIAL_COLOR  = $F5 + $55 * $100 + $CD * $10000;
    SPECIAL_COLOR1 = $01 + $02 * $100 + $03 * $10000;
    SPECIAL_COLOR2 = $FE + $FD * $100 + $FC * $10000;

  const
    MIRROR_MASK = $8000;
    UPS_MASK    = $4000;
    ROTATE_MASK = $2000;
    TILE_MASK   = $1FFF;

  type
    RGBInt = array[0..2] of Byte;

  type
    OldMapCellRec =
      record
        Back,
        Mid,
        Front: SmallInt;
        MapCode: Byte;
        Bounds: Byte;
      end;

  {
    2.55:

      Bounds

        bit 6  seq code  (new, to allow bounds with sequences)
          bit 7 = 0
            bit 0..3: up/left/down/right
          bit 7 = 1
            bit 0..3: diag mode

  }

    MapCellRec =
      record
        Back,
        Mid,
        Front: SmallInt;
        MapCode: Byte;
        Bounds: ShortInt;
        Tag: SmallInt;
      end;

  type
    aaMapCellRec = array of array of MapCellRec;

  type
    LayerMapPtr = ^LayerMap;
    LayerMap =
      record
        Id: string;
        Map: aaMapCellRec;
        fx,
        fy: string;

        SkipExport: Boolean;  // 2.2
      end;

  type
    MapSetPtr = ^MapSet;
    MapSet =
      record
        aMaps: array of LayerMap;
        CurMap: Integer;
      end;

  type
    RefreshDataRec =
      record
        OrgFilename: string;
        OrgTransX, OrgTransY: Integer;
        OrgTransList: array of Integer;
        OrgSkipX, OrgSkipY,
        OrgSkipW, OrgSkipH: Integer;
        OrgReadBounds: Boolean;
      end;

  type
    TileBitmapRec =
      record
        W, H: Integer;
        Trans: Integer;
        TileCount: Integer;
        TileBitmap: TBitmap;
        Bounds: array of Integer;
        Maps: MapSet;
        Clip: MapSet;
        Seq: MapSet;

        BackGr: Integer;

        Current: Integer;
        Filename: string;
        mcr: MapCellRec;
        BackMidFront: Integer;   { -1, 0, 1 }
        LastScale: Integer;
        Initialized: Boolean;

        Counter: Integer;

        PaletteNumber: Integer;  // 2.0
        Overlap: Integer;  // 2.0
        RefreshData: RefreshDataRec;  // 2.0

        SkipExport: Boolean;  // 2.2

        OffsetX,
        OffsetY: array of Integer;  // 2.4

        LastW, LastH: Integer;  // 2.5

        LastExportW, LastExportH: Integer;  // 3.0
        LastExportTransX, LastExportTransY: Integer;  // 3.0

      end;

  var
    DebugStr: string;

  function FindMapName (var tbr: TileBitmapRec; MapName: string): Integer;  { -1: not found }
  procedure SetMapSize (var map: aaMapCellRec; W, H: Integer);
  function NewMap (var tbr: TileBitmapRec; MapName: string; MapW, MapH: Integer): Boolean;
  function SelectMap (var tbr: TileBitmapRec; MapName: string): LayerMapPtr;
  function NewClipMap (var tbr: TileBitmapRec; MapW, MapH: Integer): Boolean;
  function SelectClipMap (var tbr: TileBitmapRec; N: Integer): LayerMapPtr;
  procedure RemoveClip (var tbr: TileBitmapRec; N: Integer);
  procedure RemoveCurrentMap (var tbr: TileBitmapRec);

  procedure ClearMCR (var mcr: MapCellRec);
  function EmptyMCR (var mcr: MapCellRec): Boolean;

  function NewSeqMap (var tbr: TileBitmapRec; MapW, MapH: Integer): Boolean;
  function SelectSeqMap (var tbr: TileBitmapRec; N: Integer): LayerMapPtr;
  procedure RemoveSeq (var tbr: TileBitmapRec; N: Integer);


  function AddRect (TR1, TR2: TRect): TRect;
  function MakeRect (X, Y, W, H: Integer): TRect;
  function Inside (X, Y: Integer; R: TRect): Boolean;
  procedure ExtendArea (var R: TRect; X, Y: Integer);
  function MakeArea (X1, Y1, X2, Y2: Integer): TRect;



  function CreateNewTBR (TileWidth, TileHeight: Integer): TileBitmapRec;
  procedure FreeTBR (var tbr: TileBitmapRec);

  function ReadTileBitmap (Filename: string;
                           BlockWidth, BlockHeight: Integer;
                           TransX, TransY: Integer;
                           const TransList: array of Integer;
                           SkipX, SkipY, SkipW, SkipH: Integer;
                           var ProgressBar: TProgressBar;
                           ReadBounds: Boolean;
                           bRefresh: Boolean;
                           tbr: TileBitmapRec): TileBitmapRec;

  function WriteTileBitmap (Filename: string;
                            MaxWidth: Integer;
                            TransColor,
                            EdgeColor: Integer;
                            BetweenX, BetweenY, EdgeX, EdgeY: Integer;
                            var tbr: TileBitmapRec;
                            var ProgressBar: TProgressBar;
                            TransRightBottom,
                            StoreBounds: Boolean;
                            PixelFormat: Integer): Boolean;

  function CreateNewTile (var tbr: TileBitmapRec): Boolean;

  function RemoveTile (var tbr: TileBitmapRec): Boolean;
  function CountTileUsed (var tbr: TileBitmapRec): Integer;

  function MoveLeft (var tbr: TileBitmapRec; upd: Boolean): Boolean;
  function MoveRight (var tbr: TileBitmapRec; upd: Boolean): Boolean;

  function InsertNewTile (var tbr: TileBitmapRec; MultEmpty: Boolean): Boolean;

  function RemoveDuplicates (var tbr: TileBitmapRec;
                             var ProgressBar: TProgressBar): Boolean;

  procedure SetBound (var tbr: TileBitmapRec; NewBound: Integer);
  function GetBound (var tbr: TileBitmapRec; n: Integer): Integer;

  function HasNoTiles (var tbr: TileBitmapRec): Boolean;

  function CopyTiles (var src: TileBitmapRec;
                      var dst: TileBitmapRec;
                      SrcStart, SrcCount: Integer;
                      DstStart: Integer;
                      Overwrite,
                      Stretch,
                      UseScaler,
                      CopyBounds,
                      Same: Boolean;
                      ProgressBar: TProgressBar): Integer;

  function ReadTBR (var F: File;
                    var ID: string;
                    var TBR: TileBitmapRec;
                    var Unknown: Boolean): Boolean;

  function SaveTBR (var F: File;
                    ID: string;
                    var TBR: TileBitmapRec): Boolean;

  const
    AllowMultEmptyTiles: Boolean = FALSE;

  procedure WriteBitmapToPNGFile (OutputFilename: string; Bitmap: TBitmap; TransparentColor: Integer);
  procedure ReadBitmapFromPNGFile (InputFilename: string; Bitmap: TBitmap);

implementation


{$IFDEF HAS_UNIT_PNGIMAGE}
  uses
    PNGImage;

  procedure WriteBitmapToPNGFile (OutputFilename: string; Bitmap: TBitmap; TransparentColor: Integer);
    var
      png: TPngObject;
      i, j: Integer;
  begin
    png := TPngObject.Create ();
    png.AssignHandle(Bitmap.Handle, True, TransparentColor);
    png.CreateAlpha ();
    png.SaveToFile (OutputFilename);
    png.Free;
  end;

  procedure ReadBitmapFromPNGFile (InputFilename: string; Bitmap: TBitmap);
    var
      png: TPngObject;
  begin
    png := TPngObject.Create ();
    png.AssignHandle(Bitmap.Handle, png.TransparentColor <> clNone, png.TransparentColor);
    png.Free;
  end;
{$ELSE}
  uses
    PNGUnit;

  procedure WriteBitmapToPNGFile (OutputFilename: string; Bitmap: TBitmap; TransparentColor: Integer);
  begin
    PNGUnit.WriteBitmapToPNGFile (OutputFilename, Bitmap, TransparentColor);
  end;

  procedure ReadBitmapFromPNGFile (InputFilename: string; Bitmap: TBitmap);
  begin
    PNGUnit.ReadBitmapFromPngFile (InputFilename, Bitmap)
  end;
{$ENDIF}


  procedure Msg (s: string);
  begin
    MessageDlg (s, mtInformation, [mbOk], 0);
  end;

  type
    TMapUpdate = (muInsert,
                  muDelete,
                  muSwap,
                  muReplace,
                  muRemoveSeq,
                  muCount);

  procedure UpdateMaps (var tbr: TileBitmapRec;
                        mu: TMapUpdate;
                        data1, data2: Integer);

    procedure UpdateTile (var tile: SmallInt);
      var
        i: Integer;
    begin
      if Tile <> -1 then
      begin
        i := Tile and (not TILE_MASK);
        Tile := Tile and TILE_MASK;
        case mu of
          muInsert:
            if Tile >= data1 then
              Inc (Tile);
          muDelete:
            if Tile = data1 then
              Tile := -1
            else
              if Tile > data1 then
                Dec (Tile);
          muSwap:
            if Tile = data1 then
              Tile := data2
            else
              if Tile = data2 then
                Tile := data1;
          muReplace:
            if Tile = data1 then
              Tile := data2;
          muCount:
            if Tile = data1 then
              Inc (tbr.Counter);
        end;
        if Tile <> -1 then
          Tile := Tile or i;
      end;
    end;

    procedure UpdateMCR (var mcr: MapCellRec);
    begin
      with mcr do
        case mu of
          muRemoveSeq:
            if Bounds and $40 <> 0 then
            begin
              if (Back = -1) and (Mid = -1) and (Front = -1) then
                if MapCode = data1 then
                begin
                  Bounds := 0;
                  MapCode := 0;
                end
                else
                  if MapCode > data1 then
                    Dec (MapCode);
            end;
        else
          begin
            UpdateTile (Back);
            UpdateTile (Mid);
            UpdateTile (Front);
          end;
        end;
    end;

    var
      i, j, k: Integer;
  begin
    with tbr.Maps do
      for k := 0 to Length (aMaps) - 1 do
        for j := 0 to Length (aMaps[k].Map) - 1 do
          for i := 0 to Length (aMaps[k].Map[j]) - 1 do
            UpdateMCR (aMaps[k].Map[j, i]);
    with tbr.Clip do
      for k := 0 to Length (aMaps) - 1 do
        for j := 0 to Length (aMaps[k].Map) - 1 do
          for i := 0 to Length (aMaps[k].Map[j]) - 1 do
            UpdateMCR (aMaps[k].Map[j, i]);
    with tbr.Seq do
      for k := 0 to Length (aMaps) - 1 do
        for j := 0 to Length (aMaps[k].Map) - 1 do
          for i := 0 to Length (aMaps[k].Map[j]) - 1 do
            UpdateMCR (aMaps[k].Map[j, i]);
    if mu <> muCount then   // bug fix
      UpdateMCR (tbr.mcr);
  end;


  function FindMapName (var tbr: TileBitmapRec; MapName: string): Integer;
    var
      i: Integer;
  begin
    Result := -1;
    with tbr.Maps do
      for i := 0 to Length (aMaps) - 1 do
        if aMaps[i].Id = MapName then
          Result := i;
  end;

  procedure SetMapSize (var map: aaMapCellRec; W, H: Integer);
    var
      i, j, k, l: Integer;
  begin
    l := Length (map);
    for j := H to l - 1 do
      SetLength (map[j], 0);
    SetLength (map, H);
    for j := 0 to H - 1 do
    begin
      k := Length (map[j]);
      SetLength (map[j], W);
      for i := k to Length (map[j]) - 1 do
        ClearMCR (map[j, i]);
    end;
  end;

  function NewMap (var tbr: TileBitmapRec; MapName: string; MapW, MapH: Integer): Boolean;
  begin
    with tbr do
      with Maps do
      begin
        CurMap := Length (aMaps);
        SetLength (aMaps, CurMap + 1);
        with aMaps[CurMap] do
        begin
          Id := MapName;
          SetMapSize (Map, MapW, MapH);
          fx := 'x';
          fy := 'y';

          SkipExport := FALSE;  // 2.2

        end;
      end;
    NewMap := TRUE;
  end;

  function SelectMap (var tbr: TileBitmapRec; MapName: string): LayerMapPtr;
    var
      i: Integer;
  begin
    Result := nil;
    with tbr.Maps do
      for i := 0 to Length (aMaps) - 1 do
        if aMaps[i].Id = MapName then
        begin
          Result := @aMaps[i];
          CurMap := i;
        end;
  end;

  function NewClipMap (var tbr: TileBitmapRec; MapW, MapH: Integer): Boolean;
  begin
    with tbr do
      with Clip do
      begin
        CurMap := Length (aMaps);
        SetLength (aMaps, CurMap + 1);
        with aMaps[CurMap] do
          SetMapSize (Map, MapW, MapH);
      end;
    NewClipMap := TRUE;
  end;

  function SelectClipMap (var tbr: TileBitmapRec; N: Integer): LayerMapPtr;
  begin
    with tbr.Clip do
      if N <= Length (aMaps) - 1 then
      begin
        Result := @aMaps[N];
        CurMap := N;
      end
      else
        Result := nil;
  end;

  procedure RemoveClip (var tbr: TileBitmapRec; N: Integer);
    var
      i: Integer;
  begin
    with tbr do
      if N < Length (tbr.Clip.aMaps) then
        with tbr.Clip do
        begin
          SetMapSize (aMaps[N].Map, 0, 0);
          for i := N + 1 to Length (aMaps) - 1 do
            aMaps[i - 1] := aMaps[i];
          SetLength (aMaps, Length (aMaps) - 1);
        end;
  end;


  procedure ClearMCR (var mcr: MapCellRec);
  begin
    with mcr do
    begin
      Back := -1;
      Mid := -1;
      Front := -1;
      MapCode := 0;
      Bounds := 0;
    end;
  end;

  function EmptyMCR (var mcr: MapCellRec): Boolean;
  begin
    with mcr do
      EmptyMCR := (Back = -1) and (Mid = -1) and (Front = -1) and
                  (MapCode = 0) and (Bounds = 0);
  end;



  procedure RemoveCurrentMap (var tbr: TileBitmapRec);
    var
      i: Integer;
  begin
    with tbr do
      with tbr.Maps do
      begin
        SetMapSize (aMaps[CurMap].Map, 0, 0);
        for i := CurMap + 1 to Length (aMaps) - 1 do
          aMaps[i - 1] := aMaps[i];
        SetLength (aMaps, Length (aMaps) - 1);
      end;
  end;




  function NewSeqMap (var tbr: TileBitmapRec; MapW, MapH: Integer): Boolean;
  begin
    with tbr do
      with Seq do
      begin
        CurMap := Length (aMaps);
        SetLength (aMaps, CurMap + 1);
        with aMaps[CurMap] do
          SetMapSize (Map, MapW, MapH);
      end;
    NewSeqMap := TRUE;
  end;

  function SelectSeqMap (var tbr: TileBitmapRec; N: Integer): LayerMapPtr;
  begin
    with tbr.Seq do
      if N <= Length (aMaps) - 1 then
      begin
        Result := @aMaps[N];
        CurMap := N;
      end
      else
        Result := nil;
  end;

  procedure RemoveSeq (var tbr: TileBitmapRec; N: Integer);
    var
      i: Integer;
  begin
    with tbr do
      if N < Length (tbr.Seq.aMaps) then
        with tbr.Seq do
        begin
          UpdateMaps (tbr, muRemoveSeq, N, 0);
          SetMapSize (aMaps[N].Map, 0, 0);
          for i := N + 1 to Length (aMaps) - 1 do
            aMaps[i - 1] := aMaps[i];
          SetLength (aMaps, Length (aMaps) - 1);
        end;
  end;





  function MakeRect (X, Y, W, H: Integer): TRect;
  begin
    MakeRect := Rect (X, Y, X + W, Y + H);
  end;

  function AddRect (TR1, TR2: TRect): TRect;
  begin
    AddRect := Rect (TR1.Left + TR2.Left,
                     TR1.Top + TR2.Top,
                     TR1.Right + TR2.Right,
                     TR1.Bottom + TR2.Bottom);
  end;

  function Inside (X, Y: Integer; R: TRect): Boolean;
  begin
    Inside := (X >= R.Left) and (X <= R.Right) and
               (Y >= R.Top) and (Y <= R.Bottom);
  end;

  procedure ExtendArea (var R: TRect; X, Y: Integer);
  begin
    if X < R.Left then
      R.Left := X;
    if Y < R.Top then
      R.Top := Y;
    if X > R.Right then
      R.Right := X;
    if Y > R.Bottom then
      R.Bottom := Y;
  end;

  function MakeArea (X1, Y1, X2, Y2: Integer): TRect;
    var
      R: TRect;
  begin
    if X1 < X2 then
    begin
      R.Left := X1;
      R.Right := X2;
    end
    else
    begin
      R.Right := X1;
      R.Left := X2;
    end;
    if Y1 < Y2 then
    begin
      R.Top := Y1;
      R.Bottom := Y2;
    end
    else
    begin
      R.Bottom := Y1;
      R.Top := Y2;
    end;
    MakeArea := R;
  end;



  function CreateNewTBR (TileWidth, TileHeight: Integer): TileBitmapRec;
    var
      tbr: TileBitmapRec;
  begin
    with tbr do
    begin
      W := TileWidth;
      H := TileHeight;
      Trans := TRANS_COLOR;
      TileCount := 0;
      Current := 0;
      TileBitmap := TBitmap.Create;
      TileBitmap.PixelFormat := pf24bit;
      TileBitmap.Transparent := TRUE;
      TileBitmap.TransparentColor := TRANS_COLOR;
      TileBitmap.Width := 0;
      TileBitmap.Height := H;
      Filename := '';

      BackMidFront := 0;
      ClearMCR (mcr);

      PaletteNumber := -1;
      Overlap := 0;

      RefreshData.OrgFilename := '';

      SkipExport := FALSE;  // 2.2

      tbr.LastExportW := 0;  // 3.0
      tbr.LastExportH := 0;
      tbr.LastExportTransX := -1;
      tbr.LastExportTransY := -1;

      Initialized := TRUE;
    end;
    CreateNewTBR := tbr;
  end;


  procedure FreeTBR (var tbr: TileBitmapRec);
    var
      i: Integer;
  begin
    if tbr.Initialized then
      with tbr do
      begin
        tbr.TileCount := 0;
        tbr.TileBitmap.Free;
        SetLength (tbr.Bounds, 0);

        SetLength (tbr.OffsetX, 0);  // 2.4
        SetLength (tbr.OffsetY, 0);

        for i := Length (tbr.Maps.aMaps) - 1 downto 0 do
        begin
          tbr.Maps.CurMap := i;
          RemoveCurrentMap (tbr);
        end;
        for i := Length (tbr.Clip.aMaps) - 1 downto 0 do
          RemoveClip (tbr, i);
        for i := Length (tbr.Seq.aMaps) - 1 downto 0 do
          RemoveSeq (tbr, i);

        if Length (RefreshData.OrgTransList) > 0 then
          SetLength (RefreshData.OrgTransList, 0);


        Initialized := FALSE;
      end;
  end;

  procedure RemoveEmptyTiles (var tbr: TileBitmapRec);
    var
      i, j, x: Integer;
  begin
    with tbr do
    begin
      if TileBitmap.Width div W > TileCount then
        TileBitmap.Width := TileCount * W;
      repeat
        x := (TileCount - 1) * W;
        for j := 0 to H - 1 do
          for i := 0 to W - 1 do
          begin
            if TileBitmap.Canvas.Pixels[x + i, j] <> Trans then
            begin
              TileBitmap.Width := TileCount * W;
              SetLength (Bounds, TileCount);

              SetLength (OffsetX, TileCount);  // 2.4
              SetLength (OffsetY, TileCount);

              Exit;
            end;
          end;
        Dec (TileCount);
      until (TileCount = 0);
      TileBitmap.Width := 0;
    end;
  end;

  function ReadTileBitmap (Filename: string;
                           BlockWidth, BlockHeight: Integer;
                           TransX, TransY: Integer;
                           const TransList: array of Integer;
                           SkipX, SkipY, SkipW, SkipH: Integer;
                           var ProgressBar: TProgressBar;
                           ReadBounds: Boolean;
                           bRefresh: Boolean;
                           tbr: TileBitmapRec): TileBitmapRec;
    var
      WW, HH, BW, BH: Integer;
      TempBitmap: TBitmap;
      i, x, y, z: Integer;
      Src, Dst: TRect;
      bnd: Integer;
      bResult: Boolean;
      Error: Boolean;
      Img: TImage;

  begin

    if bRefresh then
    begin
      with tbr.RefreshData do
      begin
        Filename := OrgFilename;
        TransX := OrgTransX;
        TransY := OrgTransY;
      {
        SetLength (TransList, Length (OrgTransList));
        for i := 0 to Length (TransList) - 1 do
          TransList[i] := OrgTransList[i];
      }
        SkipX := OrgSkipX;
        SkipY := OrgSkipY;
        SkipW := OrgSkipW;
        SkipH := OrgSkipH;
        ReadBounds := OrgReadBounds;
      end;
    end
    else
    begin
      tbr := CreateNewTBR (BlockWidth, BlockHeight);

      with tbr.RefreshData do
      begin

        OrgFilename := Filename;
        OrgTransX := TransX;
        OrgTransY := TransY;
        SetLength (OrgTransList, Length (TransList));
        for i := 0 to Length (OrgTransList) - 1 do
          OrgTransList[i] := TransList[i];
        OrgSkipX := SkipX;
        OrgSkipY := SkipY;
        OrgSkipW := SkipW;
        OrgSkipH := SkipH;
        OrgReadBounds := ReadBounds;
      end;
    end;

    Error := FALSE;

    if ReadBounds then
      if (SkipX < 1) or (SkipY < 1) then
        ReadBounds := FALSE;

    if Progressbar <> nil then  // 2.5
    begin
      ProgressBar.Min := 0;
      ProgressBar.Position := 0;
    end;

    TempBitmap := TBitmap.Create;
    TempBitmap.PixelFormat := pf24bit;
    bResult := TRUE;
    tbr.Filename := Filename;
    with tbr do
    begin
      if Uppercase (ExtractFileExt (Filename)) = '.PNG' then
        ReadBitmapFromPngFile (Filename, TempBitmap)
      else
      begin
      //  if Uppercase (ExtractFileExt (Filename)) = '.PCX' then
        begin
          Img := TImage.Create (nil);
          Img.Picture.LoadFromFile(Filename);


         // TempBitmap := Img.Picture.Bitmap;  /// todo: this doesn't work properly, so:

                  TempBitmap.LoadFromFile (Filename);



          if Img.Picture.Bitmap.PixelFormat = pf8bit then
          begin


             // to do: store palette


          end;

          Img.Free;
        end
      //  else
      //    TempBitmap.LoadFromFile (Filename);
      end;

      TempBitmap.PixelFormat := pf24bit;
      if bResult then
      begin
        W := BlockWidth;
        H := BlockHeight;
        BW := W + SkipW;
        BH := H + SkipH;
        WW := TempBitmap.Width - SkipX;
        HH := TempBitmap.Height - SkipY;

        if Progressbar <> nil then
          ProgressBar.Max := (HH div BH) * (WW div BW);

        if (WW >= W) and (HH >= H) then
        begin
          TransX := (TransX + WW) mod WW;
          TransY := (TransY + HH) mod HH;

          if Length (RefreshData.OrgTransList) <> 1 then
            Trans := -1
          else
            Trans := TempBitmap.Canvas.Pixels[TransX, TransY];
          if (Trans <> TRANS_COLOR) or (Length (RefreshData.OrgTransList) > 1) then
          begin

            if Progressbar <> nil then
              with ProgressBar do
              begin
                Min := -TempBitmap.Height * 8;
                Position := Min;
              end;

            for y := 0 to TempBitmap.Height - 1 do
            begin
              for x := 0 to TempBitmap.Width - 1 do
              begin
                if Trans = -1 then
                begin
                  if Length (RefreshData.OrgTransList) = 0 then
                  begin
                    if TempBitmap.Canvas.Pixels[x, y] = TRANS_COLOR then
                      TempBitmap.Canvas.Pixels[x, y] := TRANS_COLOR_REPLACEMENT;
                  end
                  else
                    for z := 0 to Length (RefreshData.OrgTransList) - 1 do
                      if TempBitmap.Canvas.Pixels[x, y] = RefreshData.OrgTransList[z] then
                        TempBitmap.Canvas.Pixels[x, y] := TRANS_COLOR;
                end
                else
                  if TempBitmap.Canvas.Pixels[x, y] = Trans then
                    TempBitmap.Canvas.Pixels[x, y] := TRANS_COLOR;
              end;

              if Progressbar <> nil then
                with ProgressBar do
                  Position := Position + 8;

            end;
            Trans := TRANS_COLOR;
          end;

          TempBitmap.Transparent := TRUE;
          TempBitmap.TransparentMode := tmFixed;
          TempBitmap.TransparentColor := Trans;

         // TileBitmap := TBitmap.Create;
          if not bRefresh then
            TileBitmap.PixelFormat := pf24bit;

          with TileBitmap do
          begin
           // Width := 0;
            if not bRefresh then
            begin
              Height := 0;
              Transparent := TRUE;
              TransparentMode := tmFixed;
              TransparentColor := Trans;
            end;

            i := (HH div BH) * (WW div BW);
            while (i * W) * 3 > 65536 - 16 do
              Dec (i);

            if Width < i * W then
              Width := i * W;
            if Length (Bounds) < i then
              SetLength (Bounds, i);

            if (Length (OffsetX) < i) then  // 2.4
              SetLength (OffsetX, i);
            if (Length (OffsetY) < i) then
              SetLength (OffsetY, i);


            if not bRefresh then
              Height := H;

            TileCount := 0;
            for y := 0 to HH div BH - 1 do
              for x := 0 to WW div BW - 1 do
              begin
                if Progressbar <> nil then
                  with ProgressBar do
                    Position := Position + 1;

                Src := MakeRect (SkipX + x * (W + SkipW),
                                 SkipY + y * (H + SkipH), W, H);

                if (TileCount * W + W + W) * 3 > 65535 - 16 then
                begin
                  if not Error then
                    MessageDlg ('Too many tiles',
                      mtError, [mbOk], 0);
                  Error := TRUE;
                end
                else
                begin
                  Dst := MakeRect (TileCount * W, 0, W, H);
                  Canvas.CopyRect (Dst, TempBitmap.Canvas, Src);
                end;

                if ReadBounds then
                  with TempBitmap.Canvas do
                  begin
                    bnd := 0;
                    if (Pixels[Src.Left - 1, Src.Top - 1] = clWhite) and
                       (Pixels[Src.Right + 1, Src.Bottom + 1] = clWhite) then
                      bnd := $81
                    else
                      if (Pixels[Src.Right + 1, Src.Top - 1] = clWhite) and
                         (Pixels[Src.Left - 1, Src.Bottom + 1] = clWhite) then
                        bnd := $80
                      else
                      begin
                        if (Pixels[Src.Left, Src.Top - 1] = clWhite) and
                           (Pixels[Src.Right, Src.Top - 1] = clWhite) then
                          bnd := bnd xor $1;
                        if (Pixels[Src.Left - 1, Src.Top] = clWhite) and
                           (Pixels[Src.Left - 1, Src.Bottom] = clWhite) then
                          bnd := bnd xor $2;
                        if (Pixels[Src.Left, Src.Bottom + 1] = clWhite) and
                           (Pixels[Src.Right, Src.Bottom + 1] = clWhite) then
                          bnd := bnd xor $4;
                        if (Pixels[Src.Right + 1, Src.Top] = clWhite) and
                           (Pixels[Src.Right + 1, Src.Bottom] = clWhite) then
                          bnd := bnd xor $8;
                      end;
                    if not Error then
                      Bounds[TileCount] := bnd;
                  end;

                if not Error then
                  Inc (TileCount);
              end;
          end;
          RemoveEmptyTiles (tbr);
          Current := 0;
        end
        else
          bResult := FALSE;
      end;
    end;
    if not bResult then
      MessageDlg ('Error reading ' + Filename, mtError, [mbOk], 0);
    ReadTileBitmap := tbr;
    TempBitmap.Free;
  end;

  function WriteTileBitmap (Filename: string;
                            MaxWidth: Integer;
                            TransColor,
                            EdgeColor: Integer;
                            BetweenX, BetweenY, EdgeX, EdgeY: Integer;
                            var tbr: TileBitmapRec;
                            var ProgressBar: TProgressBar;
                            TransRightBottom,
                            StoreBounds: Boolean;
                            PixelFormat: Integer): Boolean;
    var
      TempBitmap: TBitmap;
      i, j, bnd: Integer;
      xx, yy, ww, hh: Integer;
      Ext: string;

  begin
    if Progressbar <> nil then  // 2.5
    begin
      ProgressBar.Min := 0;
      ProgressBar.Position := 0;
    end;

    TempBitmap := TBitmap.Create;
    if TempBitmap.PixelFormat < pf16bit then
      TempBitmap.PixelFormat := pf16bit;
    case PixelFormat of
      1: TempBitmap.PixelFormat := pf24bit;
      2: TempBitmap.PixelFormat := pf16bit;
      3: TempBitmap.PixelFormat := pf15bit;
      4: TempBitmap.PixelFormat := pf8bit;
      5: TempBitmap.PixelFormat := pf4bit;
      6: TempBitmap.PixelFormat := pf1bit;
    end;
    TempBitmap.PixelFormat := pf24bit;
    TempBitmap.TransparentColor := TRANS_COLOR;
    tbr.Filename := Filename;
    with tbr do
    begin
      ww := W;
      hh := H;
      if StoreBounds then
      begin
        Inc (ww, 2);
        Inc (hh, 2);
      end;
      i := 1;
      while ((i + 1) * (ww + BetweenX) + 2 * EdgeX - BetweenX <= MaxWidth)
            and (TileCount > i) do
        Inc (i);
      TempBitmap.Canvas.Brush.Color := EdgeColor;
      TempBitmap.Width := i * (ww + BetweenX) +
                           2 * EdgeX - BetweenX;
      TempBitmap.Height := (tbr.TileCount + i - 1) div i *
                           (hh + BetweenY) +
                            2 * EdgeY - BetweenY;

      if Progressbar <> nil then
        ProgressBar.Max := TileCount;

      xx := EdgeX;
      yy := EdgeY;
      for i := 0 to TileCount - 1 do
      begin
        if Progressbar <> nil then
          ProgressBar.Position := i;

        if StoreBounds then
          with TempBitmap.Canvas do
          begin
            Brush.Color := clBlack;
            FillRect (MakeRect (xx, yy, ww, hh));
            bnd := Bounds[i];

            Brush.Color := clWhite;
            if bnd and $80 = 0 then
            begin
              if bnd and $1 = $1 then
                FillRect (MakeRect (xx + 1, yy, ww - 2, 1));
              if bnd and $2 = $2 then
                FillRect (MakeRect (xx, yy + 1, 1, hh - 2));
              if bnd and $4 = $4 then
                FillRect (MakeRect (xx + 1, yy + hh - 1, ww - 2, 1));
              if bnd and $8 = $8 then
                FillRect (MakeRect (xx + ww - 1, yy + 1, 1, hh - 2));
            end
            else
            begin
              if bnd and $1 = $1 then
              begin
                Pixels[xx, yy] := clWhite;
                Pixels[xx + ww - 1, yy + hh - 1] := clWhite;
              end
              else
              begin
                Pixels[xx + ww - 1, yy] := clWhite;
                Pixels[xx, yy + hh - 1] := clWhite;
              end
            end;
          end;

        TempBitmap.Canvas.CopyRect
           (MakeRect (xx + Byte (StoreBounds),
                      yy + Byte (StoreBounds), W, H),
            TileBitmap.Canvas, MakeRect (i * W, 0, W, H));
        Inc (xx, ww + BetweenX);
        if xx + EdgeX >= TempBitmap.Width then
        begin
          xx := EdgeX;
          Inc (yy, hh + BetweenY);
        end;
      end;

      with TempBitmap do
      begin
        TempBitmap.Canvas.Brush.Color := TRANS_COLOR;
        if TransRightBottom then
          if Canvas.Pixels[Width - 1, Height - 1] <> TRANS_COLOR then
            if Canvas.Pixels[Width - 1, Height - 1] = EdgeColor then
            begin
              Canvas.Pixels[Width - 1, Height - 1] := TRANS_COLOR;
              Inc (xx, EdgeX - BetweenX);
              Inc (yy, EdgeY - BetweenY);
              if (xx < Width) and (yy < Height) then
                Canvas.FillRect (Rect (xx, yy, Width, Height));
            end
            else
              Height := Height + 1;

        if TransColor <> TRANS_COLOR then
        begin
          TempBitmap.TransparentColor := TransColor;
          for j := 0 to Height - 1 do
            for i := 0 to Width - 1 do
              if Canvas.Pixels[i, j] = TRANS_COLOR then
              begin
                Canvas.Pixels[i, j] := TransColor;

                tbr.LastExportTransX := i;  // 3.0
                tbr.LastExportTransY := j;
              end;
        end;

        tbr.LastExportW := TempBitmap.Width;   // 3.0
        tbr.LastExportH := TempBitmap.Height;
      end;

      Ext := UpperCase (ExtractFileExt (Filename));
      if Ext = '.PNG' then
        WriteBitmapToPngFile (Filename, TempBitmap, TransColor)
      else
        TempBitmap.SaveToFile (FileName);
    end;
    TempBitmap.Free;
    WriteTileBitmap := TRUE;
  end;

  function CreateNewTile (var tbr: TileBitmapRec): Boolean;
    const
      Error: Boolean = FALSE;
  begin
    if not AllowMultEmptyTiles then
      RemoveEmptyTiles (tbr);
    with tbr do
    begin
      if (TileBitmap.Width + W + W) * 3 + 16 < 65536 then
      begin
        TileBitmap.Canvas.Brush.Color := TRANS_COLOR;
        TileBitmap.Canvas.Pen.Color := TRANS_COLOR;
        TileBitmap.Width := TileBitmap.Width + W;
        TileBitmap.Canvas.FillRect (MakeRect (TileCount * W, 0, W, H));
        Current := TileCount;
        Inc (TileCount);
        SetLength (Bounds, TileCount);

        SetLength (OffsetX, TileCount);  // 2.4
        SetLength (OffsetY, TileCount);

        Error := FALSE;
      end
      else
        if not Error then
        begin
          MessageDlg ('Too many tiles',
                      mtError, [mbOk], 0);
          Current := TileCount - 1;
          Error := TRUE;
        end;
    end;
    CreateNewTile := not Error;
  end;

  procedure SwapTile (var tbr: TileBitmapRec; n1, n2: Integer; upd: Boolean);
    var
      i, j, k: Integer;
  begin
    if upd then
      UpdateMaps (tbr, muSwap, n1, n2);
    with tbr do
    begin
      SetLength (Bounds, TileCount);  // fix: 2.53
      SetLength (OffsetX, TileCount);
      SetLength (OffsetY, TileCount);

      k := OffsetX[n1];  // 2.4
      OffsetX[n1] := OffsetX[n2];
      OffsetX[n2] := k;
      k := OffsetY[n1];
      OffsetY[n1] := OffsetY[n2];
      OffsetY[n2] := k;

      k := Bounds[n1];
      Bounds[n1] := Bounds[n2];
      Bounds[n2] := k;
      n1 := n1 * W;
      n2 := n2 * W;
      for j := 0 to H - 1 do
        for i := 0 to W - 1 do
          with TileBitmap.Canvas do
          begin
            k := Pixels[n1 + i, j];
            Pixels[n1 + i, j] := Pixels[n2 + i, j];
            Pixels[n2 + i, j] := k;
          end;
    end;
  end;

  function RemoveTile (var tbr: TileBitmapRec): Boolean;
    var
      Src, Dst: TRect;
      Wid: Integer;
      n, i: Integer;
  begin
    with tbr do
      if TileCount = 0 then
        RemoveTile := FALSE
      else
      begin
        n := Current;
        Dec (TileCount);

        if Current < TileCount then
        begin
          Wid := (TileCount - Current) * W;
          Src := MakeRect (Current * W + W, 0, Wid, H);
          Dst := MakeRect (Current * W, 0, Wid, H);
          TileBitmap.Canvas.CopyRect (Dst, TileBitmap.Canvas, Src);

          for i := Current to TileCount - 1 do   // 2.53: bug fix delete tile messed up bounds
          begin
            Bounds[i] := Bounds[i + 1];
            OffsetX[i] := OffsetX[i + 1];
            OffsetY[i] := OffsetX[i + 1];
          end;
          SetLength (Bounds, TileCount);
          SetLength (OffsetX, TileCount);  // 2.4
          SetLength (OffsetY, TileCount);
        end
        else
          Dec (Current);
        TileBitmap.Width := TileBitmap.Width - W;
        RemoveTile := TRUE;
        UpdateMaps (tbr, muDelete, n, 0);
      end;
  end;

  function CountTileUsed (var tbr: TileBitmapRec): Integer;
  begin
    with tbr do
      if TileCount = 0 then
        CountTileUsed := 0
      else
      begin
        Counter := 0;
        UpdateMaps (tbr, muCount, Current, 0);
        CountTileUsed := Counter;
      end;
  end;

  function MoveLeft (var tbr: TileBitmapRec; upd: Boolean): Boolean;
  begin
    with tbr do
      if Current = 0 then
        MoveLeft := FALSE
      else
      begin
        SwapTile (tbr, Current - 1, Current, upd);
        Dec (Current);
        MoveLeft := TRUE;
      end;
  end;

  function MoveRight (var tbr: TileBitmapRec; upd: Boolean): Boolean;
  begin
    with tbr do
      if Current = TileCount - 1 then
        MoveRight := FALSE
      else
      begin
        SwapTile (tbr, Current, Current + 1, upd);
        Inc (Current);
        MoveRight := TRUE;
      end;
  end;

  function InsertNewTile (var tbr: TileBitmapRec; MultEmpty: Boolean): Boolean;
    var
      Cur: Integer;
      LastAllowMultEmpty: Boolean;
  begin
    LastAllowMultEmpty := AllowMultEmptyTiles;
    AllowMultEmptyTiles := MultEmpty;

    InsertNewTile := FALSE;
    Cur := tbr.Current;
    if CreateNewTile (tbr) then
    begin
      while tbr.Current > Cur do
        MoveLeft (tbr, FALSE);
      UpdateMaps (tbr, muInsert, Cur, -1);
      InsertNewTile := TRUE;
    end;

    AllowMultEmptyTiles := LastAllowMultEmpty;
  end;

  function GetChkSumChar (var tbr: TileBitmapRec; n: Integer): Char;
    var
      x, y: Integer;
      chk: Integer;
  begin
    with tbr do
    begin
      chk := Bounds[n];

      chk := chk xor (OffsetX[n] xor OffsetY[n]);  // 2.4

      for y := 0 to H - 1 do
        for x := 0 to W - 1 do
        begin
          chk := chk xor (chk shr 1);
          Inc (chk, TileBitmap.Canvas.Pixels[n * W + x, y]);
        end;
    end;
    GetChkSumChar := Chr (chk and $FF);
  end;

  function CompareTiles (var tbr: TileBitmapRec; n1, n2: Integer): Boolean;
    var
      x, y: Integer;
  begin
    CompareTiles := FALSE;
    with tbr do
    begin
      if Bounds[n1] <> Bounds[n2] then
        Exit;

      if OffsetX[n1] <> OffsetX[n2] then
        Exit;
      if OffsetY[n1] <> OffsetY[n2] then
        Exit;

      n1 := n1 * W;
      n2 := n2 * W;
      for y := 0 to H - 1 do
        for x := 0 to W - 1 do
          with TileBitmap.Canvas do
            if Pixels[n1 + x, y] <> Pixels[n2 + x, y] then
              Exit;
    end;
    CompareTiles := TRUE;
  end;

  function RemoveDuplicates (var tbr: TileBitmapRec;
                     var ProgressBar: TProgressBar): Boolean;
    var
      ChkSum: string;
      i, j: Integer;
      c: Char;
      FoundAt: Integer;
  begin
    ProgressBar.Min := 0;
    ChkSum := '';
    i := 0;
    with tbr do
      while i < TileCount do
      begin
        ProgressBar.Max := TileCount;
        ProgressBar.Position := i;
        Current := i;
        c := GetChkSumChar (tbr, i);
        FoundAt := -1;
        if Pos (c, ChkSum) > 0 then
          for j := 0 to i - 1 do
            if c = ChkSum[j + 1] then
              if CompareTiles (tbr, j, Current) then
                FoundAt := j;
        if FoundAt <> -1 then
        begin
          UpdateMaps (tbr, muReplace, Current, FoundAt);
          RemoveTile (tbr);
        end
        else
        begin
          ChkSum := ChkSum + c;
          Inc (i);
        end;
      end;
    tbr.Current := 0;
    RemoveDuplicates := TRUE;
  end;

  procedure SetBound (var tbr: TileBitmapRec; NewBound: Integer);
  begin
    with tbr do
    begin
      if Current > Length (Bounds) - 1 then
        SetLength (Bounds, Current + 1);
      Bounds[Current] := NewBound;
    end;
  end;

  function GetBound (var tbr: TileBitmapRec; n: Integer): Integer;
  begin
    with tbr do
    begin
      if n = -1 then
        n := Current;
      if n > Length (Bounds) - 1 then
        GetBound := 0
      else
        GetBound := Bounds[n];
    end;
  end;

  function HasNoTiles (var tbr: TileBitmapRec): Boolean;
    var
      i, j: Integer;
  begin
    with tbr do
    begin
      HasNoTiles := FALSE;
      with TileBitmap do
        for j := 0 to Height - 1 do
          for i := 0 to Width - 1 do
            if Canvas.Pixels[i, j] <> TRANS_COLOR then
              Exit;
      HasNoTiles := TRUE;
    end;
  end;



  procedure Scale2X (SrcCanvas: TCanvas; SR: TRect; DstCanvas: TCanvas; DR: TRect; EdgeColor: TColor);
  // en.wikipedia.org/wiki/Pixel_art_scaling_algorithms
    var
      i, j: Integer;
      P, A, B, C, D: TColor;
      P1, P2, P3, P4: TColor;
  begin
    for j := 0 to SR.Bottom - 1 do
      for i := 0 to SR.Right - 1 do
      begin
        P := SrcCanvas.Pixels[SR.Left + i, SR.Top + j];
        A := EdgeColor;  B := EdgeColor;  C := EdgeColor;  D := EdgeColor;
        if (i > 0)             then C := SrcCanvas.Pixels[SR.Left + i - 1, SR.Top + j];
        if (j > 0)             then A := SrcCanvas.Pixels[SR.Left + i,     SR.Top + j - 1];
        if (i < SR.Right - 1)  then B := SrcCanvas.Pixels[SR.Left + i + 1, SR.Top + j];
        if (j < SR.Bottom - 1) then D := SrcCanvas.Pixels[SR.Left + i,     SR.Top + j + 1];
        P1 := P;  P2 := P;  P3 := P;  P4 := P;
        if (C = A) and (C <> D) and (A <> B) then P1 := A;
        if (A = B) and (A <> C) and (B <> D) then P2 := B;
        if (D = C) and (D <> B) and (C <> A) then P3 := C;
        if (B = D) and (B <> A) and (D <> C) then P4 := D;
        DstCanvas.Pixels[DR.Left + 2 * i,     DR.Top + 2 * j] := P1;
        DstCanvas.Pixels[DR.Left + 2 * i + 1, DR.Top + 2 * j] := P2;
        DstCanvas.Pixels[DR.Left + 2 * i,     DR.Top + 2 * j + 1] := P3;
        DstCanvas.Pixels[DR.Left + 2 * i + 1, DR.Top + 2 * j + 1] := P4;
      end;

  end;



  function CopyTiles (var src: TileBitmapRec;
                      var dst: TileBitmapRec;
                      SrcStart, SrcCount: Integer;
                      DstStart: Integer;
                      Overwrite,
                      Stretch,
                      UseScaler,
                      CopyBounds,
                      Same: Boolean;
                      ProgressBar: TProgressBar): Integer;
    var
      SW, SH, DW, DH: Integer;
      DstCount: Integer;
      SameSize: Boolean;
      mulw, mulh, divw, divh: Integer;
      SrcCur: Integer;
      i, j, k: Integer;
      s, d: TRect;
      Cur: Integer;
      OldAllowMultEmptyTiles: Boolean;

    procedure SwapCur;
      var
        c: Integer;
    begin
      if Same then
      begin
        c := Cur;
        Cur := Src.Current;
        Src.Current := c;
      end;
    end;

  begin
    debugstr := '';

    Cur := Src.Current;
    CopyTiles := 0;
    SwapCur;

    ProgressBar.Min := 0;
    ProgressBar.Max := SrcCount;
    ProgressBar.Position := 0;

    if SrcCount <= 0 then
      SrcCount := Src.TileCount;
    if DstStart < 0 then
      DstStart := Dst.TileCount;

    SW := Src.W;
    SH := Src.H;
    DW := Dst.W;
    DH := Dst.H;
    SrcCur := Src.Current;
    SameSize := (SW = DW) and (SH = DH);
    DstCount := SrcCount;
    mulw := 1;
    mulh := 1;
    divw := 1;
    divh := 1;

    if not (SameSize or Stretch) then
    begin
      if Src.W > Dst.W then
      begin
        SW := Dst.W;
        mulw := (Src.W + SW - 1) div SW;
        DstCount := DstCount * mulw;
      end;
      if Src.H > Dst.H then
      begin
        SH := Dst.H;
        mulh := (Src.H + SH - 1) div SH;
        DstCount := DstCount * mulh;
      end;

      if Src.W < Dst.W then
      begin
        DW := Src.W;
        divw := (Dst.W + DW - 1) div DW;
        DstCount := (DstCount + divw - 1) div divw;
      end;
      if Src.H < Dst.H then
      begin
        DH := Src.H;
        divh := (Dst.H + DH - 1) div DH;
        DstCount := (DstCount + divh - 1) div divh;
      end;
    end;

    Src.Current := SrcStart;
    SwapCur;
    Dst.Current := DstStart;
    SwapCur;

    with Src do
      if Current + SrcCount > TileCount then
        SrcCount := TileCount - Current;

    Dec (Src.Current);
    SwapCur;
    Dec (Dst.Current);
    SwapCur;

    for k := 0 to SrcCount * mulw * mulh - 1 do
    begin
      i := k mod (mulw * mulh);
      with Src do
      begin
        if i = 0 then
        begin
          Inc (Current);
          if same and (not Overwrite) then
            if Current > Cur then
              Inc (Current);
          ProgressBar.Position := ProgressBar.Position + 1;
        end;
        s := MakeRect (Current * W + (i mod mulw) * SW,
                       ((i div mulw) mod mulh) * SH,
                       SW, SH);
      end;

      j := k mod (divw * divh);
      SwapCur;
      with Dst do
      begin
        if j = 0 then
        begin
          Inc (Current);
          if (not Overwrite) or (Current >= TileCount) then
          begin
            if not InsertNewTile (Dst, TRUE) then
              Exit;
          end;
        end;
        d := MakeRect (Current * W + (j mod divw) * DW,
                       ((j div divw) mod divh) * DH,
                       DW, DH);
        SwapCur;
      end;
      Dst.TileBitmap.Canvas.CopyRect (d, Src.TileBitmap.Canvas, s);

      if UseScaler then
      begin
        if (d.Bottom = 2 * s.Bottom) then
          Scale2X (Src.TileBitmap.Canvas, s, Dst.TileBitmap.Canvas, d, TRANS_COLOR);
      end;

      SwapCur;
      i := Dst.Current;
      SwapCur;

     // debugstr := debugstr + chr (ord ('0') + i) + chr (ord ('0') + src.current) + ' ';

     if (i < 0) or (src.Current > length (src.offsetx) - 1) then
      asm nop end;

     if SameSize or Stretch then
     begin
       if CopyBounds then
          Dst.Bounds[i] := Src.Bounds[Src.Current];

        if Src.Current > Length (Src.OffsetX) - 1 then  // 2.51
          Dst.OffsetX[i] := 0
        else
          Dst.OffsetX[i] := Src.OffsetX[Src.Current];  // 2.4

        if Src.Current > Length (Src.OffsetY) - 1 then
          Dst.OffsetY[i] := 0
        else
          Dst.OffsetY[i] := Src.OffsetY[Src.Current];
      end;

    end;

    Src.Current := SrcCur;
    SwapCur;
    Dst.Current := DstStart;
    CopyTiles := DstCount;
  end;



  function SaveTBR (var F: File; ID: string; var TBR: TileBitmapRec): Boolean;

    procedure SaveInt (i: Integer);
    begin
      BlockWrite (F, i, SizeOf (i));
    end;

    procedure SaveChar (c: Char);
      var
        ch: {$IFDEF UNICODE} AnsiChar {$ELSE} Char {$ENDIF};
    begin
      ch := {$IFDEF UNICODE} AnsiChar {$ENDIF} (c);
      BlockWrite (F, ch, SizeOf (ch));
    end;

    procedure SaveString (s: string);
      var
        i: Integer;
    begin
      SaveInt (SizeOf (Integer) + Length (s));
      SaveInt (Length (s));
      for i := 1 to Length (s) do
        SaveChar (s[i]);
    end;

    procedure SaveIntSize (i: Integer);
    begin
      SaveInt (i * SizeOf (Integer));
    end;

    procedure SaveRGB (i: Integer);
      var
        rgb: RGBInt;
    begin
      Move (i, rgb, SizeOf (rgb));
      BlockWrite (F, rgb, SizeOf (rgb));
    end;

    procedure SaveBitmap (bmp: TBitmap);
      var
        i, j: Integer;
    begin
      SaveInt (Ord ('B'));  // BMP

      SaveInt (2 * SizeOf (Integer) +
               (bmp.Width * bmp.Height) * SizeOf (RGBInt));

      SaveInt (bmp.Width);
      SaveInt (bmp.Height);

      for j := 0 to bmp.Height - 1 do
        for i := 0 to bmp.Width - 1 do
          SaveRGB (bmp.Canvas.Pixels[i, j]);
    end;

    procedure SaveIntArray (c: Char; ai: array of Integer);
      var
        i: Integer;
    begin
      SaveInt (Ord (c));  // Array
      SaveIntSize (Length (ai));
      for i := 0 to Length (ai) - 1 do
        SaveInt (ai[i]);
    end;

    procedure SaveMCR (mcr: MapCellRec);
    begin
      BlockWrite (F, mcr, SizeOf (OldMapCellRec));
    end;

    procedure SaveMap (map: aaMapCellRec);
      var
        i, j: Integer;
    begin
      SaveInt (Ord ('L'));  // Layer Map
      i := SizeOf (Integer);
      for j := 0 to Length (map) - 1 do
        Inc (i, Length (map[j]) * SizeOf (MapCellRec) + SizeOf (Integer));
      SaveInt (i);

      SaveInt (Length (map));
      for j := 0 to Length (map) - 1 do
      begin
        SaveInt (Length (map[j]));
        for i := 0 to Length (map[j]) - 1 do
          SaveMCR (map[j, i]);
      end;
    end;

    procedure SaveLayerMap (lmp: LayerMap);
    begin
      SaveInt (Ord ('I'));  // ID
      SaveString (lmp.ID);
      SaveMap (lmp.Map);
    end;

    procedure SaveMapSet (MS: MapSet);
      var
        i: Integer;
    begin
      SaveInt (Ord ('N'));  // Length
      SaveIntSize (1);
      SaveInt (Length (MS.aMaps));

      SaveInt (Ord ('C'));  // Current
      SaveIntSize (1);
      SaveInt (MS.CurMap);

      for i := 0 to Length (MS.aMaps) - 1 do
      begin
        SaveInt (Ord ('X'));
        SaveString (MS.aMaps[i].fx);
        SaveInt (Ord ('Y'));
        SaveString (MS.aMaps[i].fy);

        SaveInt (Ord ('K'));  // 2.2   // 2.33 fixed, must be before SaveLayerMap
        SaveIntSize (1);
        SaveInt (Integer (MS.aMaps[i].SkipExport));


        SaveLayerMap (MS.aMaps[i]);
      end;

      SaveInt (0);  // End of MapSet
      SaveInt (0);
    end;

    var
      i: Integer;

  begin
    SaveInt (Ord ('I'));  // ID
    SaveString (ID);

    SaveInt (Ord ('D'));  // Dimensions
    SaveIntSize (2);
    SaveInt (TBR.W);
    SaveInt (TBR.H);

    SaveInt (Ord ('T'));  // Trans
    SaveIntSize (1);
    SaveInt (TBR.Trans);

    SaveInt (Ord ('N'));  // Tile Count
    SaveIntSize (1);
    SaveInt (TBR.TileCount);

    SaveInt (Ord ('L'));  // Last Scale
    SaveIntSize (1);
    SaveInt (TBR.LastScale);

    SaveInt (Ord ('G'));  // Background Color
    SaveIntSize (1);
    SaveInt (TBR.BackGr);

    SaveBitmap (TBR.TileBitmap);

    SaveIntArray ('A', TBR.Bounds);

    SaveInt (Ord ('M'));  // Maps
    SaveIntSize (0);
    SaveMapSet (TBR.Maps);

    SaveInt (Ord ('C'));  // Clip
    SaveIntSize (0);
    SaveMapSet (TBR.Clip);

    SaveInt (Ord ('S'));  // Seq
    SaveIntSize (0);
    SaveMapSet (TBR.Seq);

    // 2.0
    SaveInt (Ord ('P'));  // PaletteNumber
    SaveIntSize (1);
    SaveInt (TBR.PaletteNumber);

    SaveInt (Ord ('O'));  // Overlap
    SaveIntSize (1);
    SaveInt (TBR.Overlap);

    if TBR.RefreshData.OrgFilename <> '' then
      with TBR.RefreshData do
      begin
        SaveInt (Ord ('R'));  // RefreshData
        SaveInt ( SizeOf (Integer) +  // version
                  2 * SizeOf (Integer) + Length (OrgFileName) +
                 (8 + Length (OrgTransList)) * SizeOf (Integer));

        SaveInt (1);  // refreshdata version
        SaveString (OrgFilename);
        SaveInt (OrgTransX);
        SaveInt (OrgTransY);
        SaveInt (Length (OrgTransList));
        for i := 0 to Length (OrgTransList) - 1 do
          SaveInt (OrgTransList[i]);
        SaveInt (OrgSkipX);
        SaveInt (OrgSkipY);
        SaveInt (OrgSkipW);
        SaveInt (OrgSkipH);
        SaveInt (Integer (OrgReadBounds));
      end;

    SaveInt (Ord ('K'));  // 2.2
    SaveIntSize (1);
    SaveInt (Integer (TBR.SkipExport));

    // 2.4

    SaveIntArray ('X', TBR.OffsetX);
    SaveIntArray ('Y', TBR.OffsetY);

    
    //


    SaveInt (0);   // End of TBR
    SaveInt (0);

    Result := TRUE;
  end;



  function ReadTBR (var F: File;
                    var ID: string;
                    var TBR: TileBitmapRec;
                    var Unknown: Boolean): Boolean;

    var
      Error: Boolean;

    function ReadInt: Integer;
      var
        i: Integer;
    begin
      BlockRead (F, i, SizeOf (i));
      ReadInt := i;
    end;

    function ReadChar: Char;
      var
        c: {$IFDEF UNICODE} AnsiChar {$ELSE} Char {$ENDIF};
    begin
      BlockRead (F, c, SizeOf (c));
      ReadChar := Char (c);
    end;

    function ReadString: string;
      var
        i, L: Integer;
        s: string;
    begin
      s := '';
      L := ReadInt;
      for i := 1 to L do
        s := s + ReadChar;
      ReadString := s;
    end;

    function ReadRGB: Integer;
      var
        rgb: RGBInt;
        i: Integer;
    begin
      BlockRead (F, rgb, SizeOf (rgb));
      i := 0;
      Move (rgb, i, SizeOf (rgb));
      if i = tbr.Trans then
        i := TRANS_COLOR;
      ReadRGB := i;
    end;

    function ReadMCR: MapCellRec;
      var
        mcr: MapCellRec;
    begin
      FillChar (mcr, SizeOf (mcr), 0);
      BlockRead (F, mcr, SizeOf (OldMapCellRec));

      if mcr.Bounds = -1 then  // 2.55: convert to new format
       // mcr.Bounds := ShortInt ($80);
        mcr.Bounds := ShortInt ($40);

      ReadMCR := mcr;
    end;

    procedure ReadMap (var map: aaMapCellRec);
      var
        i, j: Integer;
    begin
      if ReadInt <> Ord ('L') then
      begin
        Error := TRUE;
        Exit;
      end;
      ReadInt;  // total length

      SetLength (map, ReadInt);
      for j := 0 to Length (map) - 1 do
      begin
        SetLength (map[j], ReadInt);
        for i := 0 to Length (map[j]) - 1 do
          map[j, i] := ReadMCR;
      end;
    end;

    procedure ReadMapSet (var MS: MapSet);
      var
        Cmd: Char;
        Len: Integer;
        Done: Boolean;
        i, n: Integer;
    begin
      Done := FALSE;
      n := 0;
      repeat
        Cmd := Chr (ReadInt);
        Len := ReadInt;
        case Cmd of
          #0 : Done := TRUE;
          'N': SetLength (MS.aMaps, ReadInt);
          'C': MS.CurMap := ReadInt;
          'X': MS.aMaps[n].fx := ReadString;
          'Y': MS.aMaps[n].fy := ReadString;

          'K': begin
                 i := n;
                 if i = Length (MS.aMaps) then   // in case file was saved with 2.2
                   Dec (i);
                 MS.aMaps[i].SkipExport := Boolean (ReadInt);  // 2.2
               end;


          'I': begin
                 with MS.aMaps[n] do
                 begin
                   ID := ReadString;
                   ReadMap (map);
                 end;

                 Inc (n);
               end;


        else
          begin
            for i := 1 to Len do
              ReadChar;
            Unknown := TRUE;
            if not (Cmd in ['A'..'Z', 'a'..'z', '0'..'9']) then
              Error := TRUE;
          end;
        end;
      until Error or Done;
    end;

  var
    Cmd: Char;
    Len: Integer;
    Done: Boolean;
    i: Integer;
    W, H: Integer;
    x, y: Integer;
    tmpVer: Integer;

  begin  { ReadTBR }
    Error := FALSE;

    tbr.Trans := TRANS_COLOR;

    Done := FALSE;
    repeat
      Cmd := Chr (ReadInt);
      Len := ReadInt;

      case Cmd of
        #0 : Done := TRUE;
        'I': begin
               ID := ReadString;
             end;
        'D': begin
               W := ReadInt;
               H := ReadInt;
               tbr := CreateNewTBR (W, H);
               tbr.BackGr := -1;
             end;
        'T': tbr.Trans := ReadInt;
        'N': tbr.TileCount := ReadInt;
        'G': tbr.BackGr := ReadInt;
        'L': tbr.LastScale := ReadInt;
        'B': with tbr.TileBitmap do
             begin
               Width := ReadInt;
               Height := ReadInt;
               for y := 0 to Height - 1 do
                 for x := 0 to Width - 1 do
                   Canvas.Pixels[x, y] := ReadRGB;
             end;
        'A': begin
               Len := Len div SizeOf (Integer);
               SetLength (tbr.Bounds, Len);
               for i := 0 to Len - 1 do
                 tbr.Bounds[i] := ReadInt;
             end;
        'M': ReadMapSet (tbr.Maps);
        'C': ReadMapSet (tbr.Clip);
        'S': ReadMapSet (tbr.Seq);

        'P': tbr.PaletteNumber := ReadInt;  // 2.0
        'O': tbr.Overlap := ReadInt;  // 2.0

        'R': with tbr.RefreshData do
             begin   // 2.0
               tmpVer := ReadInt;  // 1
               ReadInt;  // skip extra string length
               OrgFileName := ReadString;
               OrgTransX := ReadInt;
               OrgTransY := ReadInt;
               SetLength (OrgTransList, ReadInt);
               for i := 0 to Length (OrgTransList) - 1 do
                 OrgTransList[i] := ReadInt;
               OrgSkipX := ReadInt;
               OrgSkipY := ReadInt;
               OrgSkipW := ReadInt;
               OrgSkipH := ReadInt;
               OrgReadBounds := Boolean (ReadInt);
               if tmpVer > 1 then
               begin
                 { nop }
               end;
             end;

        'K': tbr.SkipExport := Boolean (ReadInt);  // 2.2

        // 2.4

        'X': begin
               Len := Len div SizeOf (Integer);
               SetLength (tbr.OffsetX, Len);
               for i := 0 to Len - 1 do
                 tbr.OffsetX[i] := ReadInt;
             end;
        'Y': begin
               Len := Len div SizeOf (Integer);
               SetLength (tbr.OffsetY, Len);
               for i := 0 to Len - 1 do
                 tbr.OffsetY[i] := ReadInt;
             end;


        else
        begin
          for i := 1 to Len do
            ReadChar;
          Unknown := TRUE;
          if not (Cmd in ['A'..'Z', 'a'..'z', '0'..'9']) then
            Error := TRUE;
        end;
      end;
    until Done or Error;

    tbr.Trans := TRANS_COLOR;

    ReadTBR := not Error;
  end;


end.
