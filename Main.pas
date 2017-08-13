unit Main;

  {
      TILE STUDIO - http://tilestudio.sourceforge.net/

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


  {

    To do:

      - 256 colors

      - variable tile sizes (for fonts)?
      - font generator
      - flag bits
      - diagonal bounds (y=x/2 and y=2x)
      - automatically detect mirror / upsidedown /rotate (#tile command)
      - alpha layer in map editor
      - update documentation and add more images


      to do: update html tutorial:
         - sequencedata --> bounds ???



    History:

      - fixed: paste button was often disabled when trying to copy from external source
      - fixed: when removing an animation sequence, the numbers of the others in the maps are now properly lowered


    Version 3.0

      - select next/previous clips with Ctrl+Shift+Alt Left/Right
      - added Tile->Replace color under cursor (Ctrl+R)
      - added (simple) union skinning: show a vague image of a different tile while drawing a tile,
        right-click on other tile (at the bottom)
      - added 'text' quotes also allowed for strings in addition to "text", useful for '"'
      - added option !StartWithEmptyTile
      - added opacity slider (for most drawing tools)
      - fixed import palette
      - 256-color palette DEFAULT.PAL (F8 to switch)
      - added <Counter1>..<Counter99>
      - changed PNG unit to PNGImage ???
      - RGB conversion scripts

      - #readtextfile (<TextFileLine>, <TextFileLineValue>, <LineNumber>)
      - #readbinfile (<BinFileChar>, <BinFileByte>, <BinFilePos>)
      - project lists / #list <(Name)Item/Value(n)>
      - added history panel for coordinates
      - added (limited) .PCX support
      - added <TileSetBitmapWidth>, <TileSetBitmapHeight>, <HorizontalTileCount>
        and <VerticalTileCount> in case there are no maps (now refer to last #tstilebitmap)
      - added Replace Current Tile Sequence (Ctrl+Shift+F7)
      - added #sequenceframe ... #end sequencframe: same as #sequencedata, but goes through
        each frame n+1 times (where n is the duration of each frame)



    Version 2.55

      - fixed: Edit, Replace Colors, Replace All was replacing complete tiles
      - added: Quick keys 0-9 for tools
      - starting a new selection in the map doesn't change the bounds anymore
      - sequences can have bounds
      - #sequencedata .. #end sequencedata can now contain variable <Bounds>
        (the bounds of the tiles used to make the sequence)
      - fixed <MapCount>
      - fixed: config file not loaded when starting from other directory
      - transparent color can be changed by editing the config file TS.TSC
      - paste images half size
      - fixed bug introduced in 2.54: #bitmapfile didn't use target directory


    Version 2.54

      - export separate tiles with #TILEBITMAP or #TSTILEBITMAP
      - #file ...\\... now creates path
      - Replace Colors - OtherFromToList
      - fixed range check error when placing mirrored tile in map with 1234 tool
      - View menu: show back/mid/front layer
      - copy current tile combination to clipboard (to paste as new tile)
      - TilesetBitmapWidth and TilesetBitmapHeight are updated directly after #TilesetBitmap
      - Map grid guidelines


    Version 2.53

      - fixed: move tile left/right (range check error)
      - added: scale down factor 1/2/4/8 for export map as image
      - added: smart pattern selection / pick up pattern (Alt + RMB)
      - fixed: delete tile messed up bounds
      - fixed: <MapCount> included maps that weren't exported
      - added: <TSBackTile1>, <TSMidTile1>, <TSFrontTile1> tile 0 = 1
      - fixed: TileData: N parameter - check for compatibility!
      - fixed: progressbar during generate code works better now


    Version 2.52

      - added: replace tiles in map
      - added: replace color in tile: Ctrl + fill tool


    Version 2.51

      - added: tile grid (Ctrl+G to enable/disable)
      - fixed: exporting map as image would only export the visible region
      - added: pick up several colors to make a color pattern (Ctrl + right click)
      - added: used color palette shows RGB values when moving the mouse


    Version 2.5
      - .tsd file in project directory
      - added #TSTILEBITMAP keyword
      - fixed access violation error (drawing small maps with overlap > 0)
      - #uniquetextile
      - export complete maps as images
      - right-click in map selects tile
      - lighting direction can be selected (shift+left mouse button on bound box)
      - binary output files: #BINFILE
      - tile rotation in maps (TSBackR, TSMidR, TSFrontR)
      - rotate tiles right/left (tile editor)
      - hide tile set panel
      - show selection size in status bar
      - scale down tilesets while generating code (anti-aliasing)



    2.44 and before: see website

      Modified by Rainer Deyke (rainerd@eldwood.com)  // 2.42

  }

  {$I SETTINGS.INC}

  { PNG is now handled by PngImage instead of PngUnit }



interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Menus, ExtCtrls, ComCtrls, StdCtrls, Grids, jpeg, ToolWin, Buttons, Tiles,
  ExtDlgs, ShellAPI, ImgList, Spin, Math, Noise, SZPCX;

const
  APPL_NAME = 'Tile Studio';
  ApplPath: string = '';
  VERSION_NUMBER: string = '3.0';
  DEFAULT_NAME = 'Untitled';
  DEFAULT_EXT = '.tsp';
  URL = 'http://tilestudio.sourceforge.net/';
  OutputPath: string = '';
  pfMap = pf16bit;
  pfFinal = pf24bit;
  pfOutput = pf24bit;
  CONFIG_FILE = 'ts.tsc';
{$IFDEF CREATE_BACKUP_FILES}
  BACKUP_EXT = '.$$$';
{$ENDIF}
  DEFAULT_PAL = 'default.pal';
  RGBCONV_FILE = 'rgbconv.txt';

const
  Filename: string = '';
  FileToOpen: string = '';

const
  MAX_PALETTE_ORDER = 6;
  MAX_FROM_TO = 9;
  DEFAULT_COLOR = $676767;
  DEFAULT_BACKGR_COLOR = $AAAAAA;
  BORDER_W = 5;
  BORDER_H = 5;
  DEFAULT_SCALE = 8;
  MAX_SCALE = 16;
  MAX_UNDO = 50;
  DEFAULT_CURSOR_SIZE = 4;
  MAX_ZOOM = 9;
  ZOOM_FACTOR = 3;
  DEFAULT_ANIMATION_SPEED = 500;
  DEFAULT_SEQ_SPEED = 25;
  LONG_LINE = 74;

type
  TileTabRec =
    record
      tbr: TileBitmapRec;
      id: string;
      lastscrollpos: Integer;
      lastscale: Integer;

      AnimStart, AnimEnd: Integer;
      BackGrColor: Integer;
    end;

type
  UndoRec =
    record
      ActionName: string;
      Bmp: TBitmap;
      HistoryCoords: string;  // 3.00
    end;

type
  TFromToList = array[0..MAX_FROM_TO - 1] of Integer;
  TExFromToList = array[0..MAX_FROM_TO - 1, 0..2] of Integer;

type
  FTSaveRec =
    record
      FT: TFromToList;
      EXFT: TExFromToList;
      F, L: Integer;

    end;

type
  TEditorMode = (mTile, mMap);

type
  TDrawingTool = (dtPoint,
                  dtBrush,
                  dtLine,
                  dtRect,
                  dtRoundRect,
                  dtEllipse,
                  dtFill,
                  dtFilledRect,
                  dtFilledRoundRect,
                  dtFilledEllipse,
                  dtSelection);

  TMapDrawingTool = (mdtPoint, mdtFilledRect,
                     mdtZOrder, mdtRect);

const
  FirstSaveUndoTools = [dtPoint, dtBrush, dtFill];

function WithoutExt (Name: string; Ext: string): string;

type
  TMainForm = class(TForm)
    TilePanel: TPanel;
    RightPanel: TPanel;
    MainMenu: TMainMenu;
    File1: TMenuItem;
    NewGame1: TMenuItem;
    N2: TMenuItem;
    Open1: TMenuItem;
    Save1: TMenuItem;
    SaveAs1: TMenuItem;
    N1: TMenuItem;
    Exit1: TMenuItem;
    Edit1: TMenuItem;
    Undo1: TMenuItem;
    N3: TMenuItem;
    Cut1: TMenuItem;
    Copy1: TMenuItem;
    Paste1: TMenuItem;
    Delete1: TMenuItem;
    View1: TMenuItem;
    RearrangePalette1: TMenuItem;
    ScrollBox: TScrollBox;
    PalettePanel: TPanel;
    ColorsPanel: TPanel;
    Palette: TPaintBox;
    ColorPanel: TPanel;
    BackgroundPanel: TPanel;
    FromToPanel: TPanel;
    Color: TShape;
    Background: TShape;
    FromTo: TPaintBox;
    ZoomIn1: TMenuItem;
    ZoomOut1: TMenuItem;
    Tile: TImage;
    Toolbar: TToolBar;
    Move1: TMenuItem;
    Up1: TMenuItem;
    Down1: TMenuItem;
    Left1: TMenuItem;
    Right1: TMenuItem;
    Tile1: TMenuItem;
    Flip1: TMenuItem;
    Horizontal1: TMenuItem;
    Vertical1: TMenuItem;
    Clear1: TMenuItem;
    PatternPanel: TPanel;
    N5: TMenuItem;
    Pattern1: TMenuItem;
    Pattern: TImage;
    N6: TMenuItem;
    ImportTiles1: TMenuItem;
    ExportTiles1: TMenuItem;
    OpenPictureDialog: TOpenPictureDialog;
    NewTile1: TMenuItem;
    MatchColors1: TMenuItem;
    Help1: TMenuItem;
    About1: TMenuItem;
    Redo1: TMenuItem;
    N8: TMenuItem;
    MoveTile1: TMenuItem;
    MoveTileLeft: TMenuItem;
    MoveTileRight: TMenuItem;
    N9: TMenuItem;
    RemoveDuplicateTiles1: TMenuItem;
    Homepage1: TMenuItem;
    N10: TMenuItem;
    SavePictureDialog: TSavePictureDialog;
    SetBounds1: TMenuItem;
    Left2: TMenuItem;
    Right2: TMenuItem;
    Top1: TMenuItem;
    Bottom1: TMenuItem;
    N13: TMenuItem;
    DiagonalUp1: TMenuItem;
    DiagonalDown1: TMenuItem;
    N12: TMenuItem;
    ClearAll1: TMenuItem;
    NewTileSet1: TMenuItem;
    Map1: TMenuItem;
    N11: TMenuItem;
    Properties1: TMenuItem;
    ProgressPanel: TPanel;
    ProgressBar: TProgressBar;
    Toolbar1: TMenuItem;
    ImageList: TImageList;
    NewButton: TToolButton;
    OpenButton: TToolButton;
    SaveButton: TToolButton;
    ToolButton1: TToolButton;
    CutButton: TToolButton;
    CopyButton: TToolButton;
    PasteButton: TToolButton;
    ToolButton2: TToolButton;
    UndoButton: TToolButton;
    RedoButton: TToolButton;
    DeleteButton: TToolButton;
    ToolButton3: TToolButton;
    Zoom1: TMenuItem;
    ZoomButton: TToolButton;
    ActualSize1: TMenuItem;
    FitinWindow1: TMenuItem;
    RGBColorDepth1: TMenuItem;
    N61: TMenuItem;
    N71: TMenuItem;
    N81: TMenuItem;
    N91: TMenuItem;
    StatusBar: TStatusBar;
    Tab: TTabControl;
    TileScrollBox: TScrollBox;
    TileBitmap: TImage;
    ZoomInButton: TToolButton;
    ZoomOutButton: TToolButton;
    DuplicateTile1: TMenuItem;
    N101: TMenuItem;
    Palette1: TMenuItem;
    N4: TMenuItem;
    ColorBrightness1: TMenuItem;
    N_1: TMenuItem;
    N_2: TMenuItem;
    N_3: TMenuItem;
    N_4: TMenuItem;
    N_5: TMenuItem;
    N_6: TMenuItem;
    N_7: TMenuItem;
    N_8: TMenuItem;
    N_9: TMenuItem;
    ToolButton7: TToolButton;
    NewTileButton: TToolButton;
    ColorMatchButton: TToolButton;
    ToolButton4: TToolButton;
    ColorDialog: TColorDialog;
    N14: TMenuItem;
    Map2: TMenuItem;
    BackgroundColor1: TMenuItem;
    N15: TMenuItem;
    CursorImage: TImage;
    CurTilePanel: TPanel;
    TilePartsPanel: TPanel;
    CopyTiles1: TMenuItem;
    InsertNewTile1: TMenuItem;
    PreviousTile1: TMenuItem;
    NextTile1: TMenuItem;
    N16: TMenuItem;
    FirstTile1: TMenuItem;
    LastTile1: TMenuItem;
    pBack: TPanel;
    pMid: TPanel;
    pFront: TPanel;
    bmpBack: TImage;
    bmpMid: TImage;
    bmpFront: TImage;
    pPreview: TPanel;
    bmpPreview: TImage;
    StretchPaste1: TMenuItem;
    ToggleMultiple1: TMenuItem;
    bUps: TSpeedButton;
    mUps: TSpeedButton;
    fUps: TSpeedButton;
    bMir: TSpeedButton;
    mMir: TSpeedButton;
    fMir: TSpeedButton;
    bRot: TSpeedButton;
    mRot: TSpeedButton;
    fRot: TSpeedButton;
    FlipCurrentTile1: TMenuItem;
    Horizontal2: TMenuItem;
    Vertical2: TMenuItem;
    SelectCurrentTile1: TMenuItem;
    SelectBackMidFront1: TMenuItem;
    Next1: TMenuItem;
    Previous1: TMenuItem;
    ToggleTileMapEditor1: TMenuItem;
    LeftPanel: TPanel;
    ToolPanel: TPanel;
    PencilButton: TSpeedButton;
    LineButton: TSpeedButton;
    RectButton: TSpeedButton;
    RoundRectButton: TSpeedButton;
    EllipseButton: TSpeedButton;
    BrushButton: TSpeedButton;
    FillButton: TSpeedButton;
    FilledRectButton: TSpeedButton;
    FilledRoundRectButton: TSpeedButton;
    FilledEllipseButton: TSpeedButton;
    LightButton: TSpeedButton;
    DarkButton: TSpeedButton;
    PlusButton: TSpeedButton;
    RandomButton: TSpeedButton;
    LineToolPanel: TPanel;
    LineTool: TShape;
    ExtraPanel: TPanel;
    BoundPanel: TPanel;
    BoundBox: TPaintBox;
    MapCodeButton: TSpeedButton;
    MapTab: TTabControl;
    MapScrollBox: TScrollBox;
    MapDisplay: TPaintBox;  // 2.42
    ClipTab: TTabControl;
    ClipScrollBox: TScrollBox;
    UsedColors: TPanel;
    ShowUsedColors1: TMenuItem;
    UsedColorsImage: TImage;
    N18: TMenuItem;
    MapProperties1: TMenuItem;
    InvPanel: TPanel;
    ShowGrid1: TMenuItem;
    MapToolPanel: TPanel;
    MapPointButton: TSpeedButton;
    MapRectButton: TSpeedButton;
    ShowMapCodes1: TMenuItem;
    bmp1: TImage;
    bmp2: TImage;
    ShowBounds1: TMenuItem;
    SelBmp: TImage;
    ZOrderButton: TSpeedButton;
    BlockButton: TSpeedButton;
    N20: TMenuItem;
    ClearArea1: TMenuItem;
    ClipBitmap: TImage;
    RandomFill1: TMenuItem;
    N21: TMenuItem;
    RemoveTileSet1: TMenuItem;
    RemoveMap1: TMenuItem;
    OpenDialog: TOpenDialog;
    SaveDialog: TSaveDialog;
    AnimationTimer: TTimer;
    Animation1: TMenuItem;
    FirstFrame1: TMenuItem;
    LastFrame1: TMenuItem;
    N22: TMenuItem;
    NextFrame1: TMenuItem;
    Animate1: TMenuItem;
    PreviousFrame1: TMenuItem;
    N23: TMenuItem;
    Faster1: TMenuItem;
    Slower1: TMenuItem;
    AnimationSpeed1: TMenuItem;
    Default1: TMenuItem;
    TileModeButton: TToolButton;
    MapModeButton: TToolButton;
    ToolButton8: TToolButton;
    ToolButton5: TToolButton;
    AnimateButton: TToolButton;
    ToolButton6: TToolButton;
    ToolButton9: TToolButton;
    ToolButton10: TToolButton;
    SeqTab: TTabControl;
    N24: TMenuItem;
    ConverttoTileSequence1: TMenuItem;
    InsertTileSequence1: TMenuItem;
    RemoveTileSequence1: TMenuItem;
    SeqBitmap: TImage;
    SeqTimer: TTimer;
    Code1: TMenuItem;
    Generate1: TMenuItem;
    CodeGenerationSettings1: TMenuItem;
    PreviousPattern1: TMenuItem;
    NextPattern1: TMenuItem;
    ColorPatterns1: TMenuItem;
    AddColorPattern1: TMenuItem;
    RemoveColorPattern1: TMenuItem;
    N17: TMenuItem;
    SelectOutputDirectory1: TMenuItem;
    ReplaceColors1: TMenuItem;
    ReplaceColorsButton: TToolButton;
    MapScrollFunction1: TMenuItem;
    N25: TMenuItem;
    SaveCurrentTile1: TMenuItem;
    ImportEdlev: TToolButton;
    ToolButton12: TToolButton;
    Sequence1: TMenuItem;
    N19: TMenuItem;
    InsertHorizontal1: TMenuItem;
    DeleteHorizontal1: TMenuItem;
    InsertVertical1: TMenuItem;
    DeleteVertical1: TMenuItem;
    Tutorial1: TMenuItem;
    N26: TMenuItem;
    N27: TMenuItem;
    OutputtoProjectDirectory1: TMenuItem;
    N28: TMenuItem;
    RecentProjects1: TMenuItem;
    SmoothPalette1: TMenuItem;
    N29: TMenuItem;
    PaletteManager1: TMenuItem;
    N30: TMenuItem;
    ImportPovRayanimation1: TMenuItem;
    MovePixels1: TMenuItem;
    Right3: TMenuItem;
    Left3: TMenuItem;
    Down2: TMenuItem;
    Up2: TMenuItem;
    NoDelay1: TMenuItem;
    ShowCurrentPalette1: TMenuItem;
    N31: TMenuItem;
    ImportMap1: TMenuItem;
    ImportMapDialog: TOpenDialog;
    ExportMapDialog: TSaveDialog;
    ExportMap1: TMenuItem;
    RefreshImportedTiles1: TMenuItem;
    SelectionButton: TSpeedButton;
    TileSelection: TShape;
    GradientFill1: TMenuItem;
    Horizontal3: TMenuItem;
    Vertical3: TMenuItem;
    Diagonal1: TMenuItem;
    N32: TMenuItem;
    ProjectInformation1: TMenuItem;
    Fill1: TMenuItem;
    Lighten1: TMenuItem;
    Darken1: TMenuItem;
    N33: TMenuItem;
    N7: TMenuItem;
    RealTimeLightening1: TMenuItem;
    RTTimer: TTimer;
    N34: TMenuItem;
    Darker1: TMenuItem;
    Lighter1: TMenuItem;
    ChangeOffset1: TMenuItem;
    Up3: TMenuItem;
    Down3: TMenuItem;
    Left4: TMenuItem;
    Right4: TMenuItem;
    ResetOffset1: TMenuItem;
    HideTileSetPanel1: TMenuItem;
    N35: TMenuItem;
    UseOldNoiseFunctions1: TMenuItem;
    ExportMapasImage1: TMenuItem;
    RotateRight1: TMenuItem;
    RotateLeft1: TMenuItem;
    AntiAliasing1: TMenuItem;
    aaOff: TMenuItem;
    aa2: TMenuItem;
    aa3: TMenuItem;
    aa4: TMenuItem;
    ReplaceColors2: TMenuItem;
    Grid: TImage;
    ShowTileGrid1: TMenuItem;
    ReplaceSelectedTile1: TMenuItem;
    N36: TMenuItem;
    MoveMapLeft1: TMenuItem;
    MoveMapRight1: TMenuItem;
    NextMap1: TMenuItem;
    PreviousMap1: TMenuItem;
    N37: TMenuItem;
    MapExportScaleDownFactor1: TMenuItem;
    N210: TMenuItem;
    N41: TMenuItem;
    N82: TMenuItem;
    N110: TMenuItem;
    SplitColorPattern1: TMenuItem;
    ShowMapLayer1: TMenuItem;
    ShowBackLayer: TMenuItem;
    ShowMidLayer: TMenuItem;
    ShowFrontLayer: TMenuItem;
    SetGridGuidelines1: TMenuItem;
    ScaledPaste1: TMenuItem;
    HalfSize1: TMenuItem;
    N256ColorPalette1: TMenuItem;
    N38: TMenuItem;
    ReplaceCurrentTileSequence1: TMenuItem;
    HistoryPanel: TPanel;
    HistoryControlPanel: TPanel;
    HistoryListBox: TListBox;
    bHistoryRec: TSpeedButton;
    bHistoryShow: TSpeedButton;
    bHistoryClear: TSpeedButton;
    ProjectLists1: TMenuItem;
    UtilsTab: TPageControl;
    RGBTab: TTabSheet;
    PosTab: TTabSheet;
    RGBPanel: TPanel;
    RGBControlPanel: TPanel;
    bRGBConvertAll: TSpeedButton;
    bRGBEdit: TSpeedButton;
    bRGBRun: TSpeedButton;
    RGBConvListBox: TListBox;
    Clip1: TMenuItem;
    SelectNextClip1: TMenuItem;
    SelectPreviousClip1: TMenuItem;
    ReplaceColorUnderCursor1: TMenuItem;
    OpacityTrackBar: TTrackBar;
    N39: TMenuItem;
    UseAsAlphaChannel1: TMenuItem;
    AlphaPanel: TPanel;
    AlphaPaintBox: TPaintBox;
    ColorPatternsPanel: TPanel;
    ColorPatternsImage: TImage;
    N40: TMenuItem;
    ShowUsedColorPatterns1: TMenuItem;
    DoubleSize1: TMenuItem;
    procedure Exit1Click(Sender: TObject);
    procedure PalettePaint(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure PaletteMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PaletteMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure PaletteMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormCreate(Sender: TObject);
    procedure BackGroundMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure RearrangePalette1Click(Sender: TObject);
    procedure FromToPaint(Sender: TObject);
    procedure FromToMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FromToMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FromToMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ColorMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ZoomIn1Click(Sender: TObject);
    procedure ZoomOut1Click(Sender: TObject);
    procedure TileMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure TileMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure TileMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure SetDrawingTool(Sender: TObject);
    procedure Up1Click(Sender: TObject);
    procedure Down1Click(Sender: TObject);
    procedure Left1Click(Sender: TObject);
    procedure Right1Click(Sender: TObject);
    procedure Horizontal1Click(Sender: TObject);
    procedure Vertical1Click(Sender: TObject);
    procedure Clear1Click(Sender: TObject);
    procedure LineToolMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Pattern1Click(Sender: TObject);
    procedure ImportTiles1Click(Sender: TObject);
    procedure NewTile1Click(Sender: TObject);
    procedure TileBitmapMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure MatchColors1Click(Sender: TObject);
    procedure Undo1Click(Sender: TObject);
    procedure Redo1Click(Sender: TObject);
    procedure Copy1Click(Sender: TObject);
    procedure Paste1Click(Sender: TObject);
    procedure Delete1Click(Sender: TObject);
    procedure Cut1Click(Sender: TObject);
    procedure MoveTileLeftClick(Sender: TObject);
    procedure MoveTileRightClick(Sender: TObject);
    procedure RemoveDuplicateTiles1Click(Sender: TObject);
    procedure ColorMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure BackGroundMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure About1Click(Sender: TObject);
    procedure Homepage1Click(Sender: TObject);
    procedure ExportTiles1Click(Sender: TObject);
    procedure BoundBoxPaint(Sender: TObject);
    procedure Top1Click(Sender: TObject);
    procedure Bottom1Click(Sender: TObject);
    procedure Left2Click(Sender: TObject);
    procedure Right2Click(Sender: TObject);
    procedure DiagonalUp1Click(Sender: TObject);
    procedure DiagonalDown1Click(Sender: TObject);
    procedure ClearAll1Click(Sender: TObject);
    procedure BoundBoxMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure NewTileCollection1Click(Sender: TObject);
    procedure CreateNewTileCollection (Name: string; BW, BH: Integer; AddNew: Boolean);
    procedure Properties1Click(Sender: TObject);
    procedure TabChange(Sender: TObject);
    procedure Toolbar1Click(Sender: TObject);
    procedure ActualSize1Click(Sender: TObject);
    procedure FitinWindow1Click(Sender: TObject);
    procedure SetPaletteDepth(Sender: TObject);
    procedure DuplicateTile1Click(Sender: TObject);
    procedure SetBrightness(Sender: TObject);
    procedure PaletteDblClick(Sender: TObject);
    procedure SetEditorMode(NewMode: TEditorMode);
    procedure BackgroundColor1Click(Sender: TObject);
    procedure CopyTiles1Click(Sender: TObject);
    procedure InsertNewTile1Click(Sender: TObject);
    procedure PreviousTile1Click(Sender: TObject);
    procedure NextTile1Click(Sender: TObject);
    procedure FirstTile1Click(Sender: TObject);
    procedure LastTile1Click(Sender: TObject);
    procedure StretchPaste1Click(Sender: TObject);
    procedure ToggleMultiple1Click(Sender: TObject);
    procedure SelectBackMidFront(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure MirTileMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure fUpsClick(Sender: TObject);
    procedure Horizontal2Click(Sender: TObject);
    procedure Vertical2Click(Sender: TObject);
    procedure SelectCurrentTile1Click(Sender: TObject);
    procedure Next1Click(Sender: TObject);
    procedure Previous1Click(Sender: TObject);
    procedure ToggleTileMapEditor1Click(Sender: TObject);
    procedure DrawBounds (c: TCanvas; X, Y, Wid, Ht, lw, Bounds, Color: Integer);
    procedure MapCodeButtonClick(Sender: TObject);
    procedure Map1Click(Sender: TObject);
    procedure ShowUsedColors1Click(Sender: TObject);
    procedure UsedColorsImageMouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure UsedColorsImageMouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: Integer);
    procedure UsedColorsImageMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure MapProperties1Click(Sender: TObject);
    procedure MapTabChange(Sender: TObject);
    procedure ShowGrid1Click(Sender: TObject);
    procedure bmpMapMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure bmpMapMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure bmpMapMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure SetMapDrawingTool(Sender: TObject);
    procedure bmpPreviewMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ShowMapCodes1Click(Sender: TObject);
    procedure ShowBounds1Click(Sender: TObject);
    procedure ClearArea1Click(Sender: TObject);
    procedure ClipTabChange(Sender: TObject);
    procedure RandomFill1Click(Sender: TObject);
    procedure RemoveMap1Click(Sender: TObject);
    procedure RemoveTileSet1Click(Sender: TObject);
    procedure Save1Click(Sender: TObject);
    procedure SaveAs1Click(Sender: TObject);
    procedure Open1Click(Sender: TObject);
    procedure NewGame1Click(Sender: TObject);
    procedure Animate1Click(Sender: TObject);
    procedure FirstFrame1Click(Sender: TObject);
    procedure LastFrame1Click(Sender: TObject);
    procedure NextFrame1Click(Sender: TObject);
    procedure PreviousFrame1Click(Sender: TObject);
    procedure AnimationTimerTimer(Sender: TObject);
    procedure Default1Click(Sender: TObject);
    procedure Faster1Click(Sender: TObject);
    procedure Slower1Click(Sender: TObject);
    procedure TileModeButtonClick(Sender: TObject);
    procedure MapModeButtonClick(Sender: TObject);
    procedure ConverttoTileSequence1Click(Sender: TObject);
    procedure SeqTabChange(Sender: TObject);
    procedure SeqTimerTimer(Sender: TObject);
    procedure RemoveTileSequence1Click(Sender: TObject);
    procedure InsertTileSequence1Click(Sender: TObject);
    procedure Generate1Click(Sender: TObject);
    procedure CodeGenerationSettings1Click(Sender: TObject);
    procedure PreviousPattern1Click(Sender: TObject);
    procedure NextPattern1Click(Sender: TObject);
    procedure AddColorPattern1Click(Sender: TObject);
    procedure RemoveColorPattern1Click(Sender: TObject);
    procedure SelectOutputDirectory1Click(Sender: TObject);
    procedure ReplaceColors1Click(Sender: TObject);
    procedure MapScrollFunction1Click(Sender: TObject);
    procedure SaveCurrentTile1Click(Sender: TObject);
    procedure ImportEdlevClick(Sender: TObject);
    procedure InsertHorizontal1Click(Sender: TObject);
    procedure DeleteHorizontal1Click(Sender: TObject);
    procedure InsertVertical1Click(Sender: TObject);
    procedure DeleteVertical1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Tutorial1Click(Sender: TObject);
    procedure OutputtoProjectDirectory1Click(Sender: TObject);
    procedure SmoothPalette1Click(Sender: TObject);
    procedure PaletteManager1Click(Sender: TObject);
    procedure ImportPovRayanimation1Click(Sender: TObject);
    procedure Up2Click(Sender: TObject);
    procedure Down2Click(Sender: TObject);
    procedure Left3Click(Sender: TObject);
    procedure Right3Click(Sender: TObject);
    procedure NoDelay1Click(Sender: TObject);
    procedure ShowCurrentPalette1Click(Sender: TObject);
    procedure ImportMap1Click(Sender: TObject);
    procedure ExportMap1Click(Sender: TObject);
    procedure RefreshImportedTiles1Click(Sender: TObject);
    procedure TileSelectionMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure TileSelectionMouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: Integer);
    procedure TileSelectionMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Horizontal3Click(Sender: TObject);
    procedure Vertical3Click(Sender: TObject);
    procedure Diagonal1Click(Sender: TObject);
    procedure ProjectInformation1Click(Sender: TObject);
    procedure Fill1Click(Sender: TObject);
    procedure Lighten1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure RealTimeLightening1Click(Sender: TObject);
    procedure RTTimerTimer(Sender: TObject);
    procedure Darker1Click(Sender: TObject);
    procedure Lighter1Click(Sender: TObject);
    procedure Up3Click(Sender: TObject);
    procedure Down3Click(Sender: TObject);
    procedure Left4Click(Sender: TObject);
    procedure Right4Click(Sender: TObject);
    procedure ResetOffset1Click(Sender: TObject);
    procedure MapDisplayPaint(Sender: TObject);
    procedure HideTileSetPanel1Click(Sender: TObject);
    procedure UseOldNoiseFunctions1Click(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure ExportMapasImage1Click(Sender: TObject);
    procedure RotateRight1Click(Sender: TObject);
    procedure RotateLeft1Click(Sender: TObject);
    procedure aaClick(Sender: TObject);
    procedure ReplaceColors2Click(Sender: TObject);
    procedure ShowTileGrid1Click(Sender: TObject);
    procedure ReplaceSelectedTile1Click(Sender: TObject);
    procedure MoveMapLeft1Click(Sender: TObject);
    procedure MoveMapRight1Click(Sender: TObject);
    procedure NextMap1Click(Sender: TObject);
    procedure PreviousMap1Click(Sender: TObject);
    procedure N110Click(Sender: TObject);
    procedure SplitColorPattern1Click(Sender: TObject);
    procedure ShowBackLayerClick(Sender: TObject);
    procedure ShowMidLayerClick(Sender: TObject);
    procedure ShowFrontLayerClick(Sender: TObject);
    procedure SetGridGuidelines1Click(Sender: TObject);
    procedure HalfSize1Click(Sender: TObject);
    procedure N256ColorPalette1Click(Sender: TObject);
    procedure ReplaceCurrentTileSequence1Click(Sender: TObject);
    procedure bHistoryClearClick(Sender: TObject);
    procedure bHistoryShowClick(Sender: TObject);
    procedure HistoryListBoxClick(Sender: TObject);
    procedure ProjectLists1Click(Sender: TObject);
    procedure bRGBEditClick(Sender: TObject);
    procedure bRGBRunClick(Sender: TObject);
    procedure SelectNextClip1Click(Sender: TObject);
    procedure SelectPreviousClip1Click(Sender: TObject);
    procedure ReplaceColorUnderCursor1Click(Sender: TObject);
    procedure Edit1Click(Sender: TObject);
    procedure UseAsAlphaChannel1Click(Sender: TObject);
    procedure AlphaPaintBoxPaint(Sender: TObject);
    procedure ShowUsedColorPatterns1Click(Sender: TObject);
    procedure ColorPatternsImageMouseMove(Sender: TObject;
      Shift: TShiftState; X, Y: Integer);
    procedure ColorPatternsImageMouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure ColorPatternsImageMouseUp(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure DoubleSize1Click(Sender: TObject);
    procedure Edit1DrawItem(Sender: TObject; ACanvas: TCanvas;
      ARect: TRect; Selected: Boolean);
  private
    { Private declarations }
  public
    { Public declarations }
    Modified: Boolean;
    Mode: TEditorMode;
    W, H: Integer;
    Scale: Integer;
    Bounds: Integer;
    bmpMap,
    Bmp,
    TempBmp,
    VisualBmp,
    ClipBmp: TBitmap;
    bmpMapImage: TBitmap;  // 2.5 - export map
    UnionSkinBmp: TBitmap;  // 2.5 - union skin
    AlphaBmp: TBitmap;  // 2.5 - use tile as alpha channel
    LastTileEdited: Integer;
    UnionSkinTile: Integer;
    TileTab: array of TileTabRec;
    // tbr: TileBitmapRec;
    // IgnorePaletteMouseDown: Boolean;
    ColorSelect,
    RightMouseButton,
    FromToSelect,
    FromToBackgroundSelect: Boolean;
    PaletteOrder: Integer;  { 0..MAX_PALETTE_ORDER - 1 }
    LastFromToFirst,
    LastFromToLast,
    FromToFirst,
    FromToLast: Integer;
    FromToList: TFromToList;
    ExFromToList: TExFromToList;
    FromToCount: Integer;
    LineSize: array[TDrawingTool] of Integer;
    Erasing,
    ShiftErasing: Boolean;   // 2.0
    Drawing: Boolean;
    ReadingColor: Boolean;
    ShowOrigin: Boolean;
    OrigColor: Integer;
    Origin, CurPos: TPoint;
    LastX, LastY: Integer;
    LastShift: TShiftState;
    LastButton: TMouseButton;
    Busy: Boolean;
    DrawingTool: TDrawingTool;
    DrawColor,
    FillColor: Integer;
    DrawingShape: Boolean;
    LineList: string;
    Undo: array[0..MAX_UNDO - 1] of UndoRec;
    UndoCount,
    UndoPos: Integer;
    Action: string;
    SpecialColor: Integer;
    UsedColorSelect: Boolean;
    UsedPatternSelect: Boolean;
    MaxRGB,
    MaxR,
    MaxG,
    MaxB: Integer;
    PaletteValues: array of Integer;
    PalW, PalH, PalNH, PalNV: Integer;
    CursorSize: Integer;
    RightPanelWidth: Integer;
    BMFCenterAdd: Integer;
    lmp,
    Clip,
    Seq: LayerMapPtr;
    CurMapW, CurMapH: Integer;
    ClipW, ClipH: Integer;
    SeqW, SeqH,
    SeqFrame: Integer;
   // bmp1, bmp2: TImage;
    Zoom: Integer;
    Area, LastArea: TRect;
    DrawingInMap,
    ReadingFromMap: Boolean;
    MapDrawingTool: TMapDrawingTool;
    MapOrigin: TPoint;
    MapPos: TPoint;
    Selection: Boolean;
    ShiftState: TShiftState;
    SkipDraw: Boolean;
    FromToSave: array of FTSaveRec;
    FromToSavePos: Integer;
    OtherFromTo: FTSaveRec;  // 2.54
    StartTime: TDateTime;
    Sessions: Integer;
    History: string;
    CDROM: Boolean;
    ReadParamFile: Boolean;
    RecentFiles: TStringList;
    WinLeft, WinTop, WinWidth, WinHeight: Integer;  // 2.55
    TileSelX1, TileSelY1,          // 2.0
    TileSelX2, TileSelY2: Integer;
    TileAreaX, TileAreaY, TileAreaW, TileAreaH: Integer;
    TileSelOrgX, TileSelOrgY: Integer;
    MovingTileSel, MovingTileSelPixels: Boolean;
    GradientH, GradientV, GradientD: Boolean;   // 2.0
    VisibleMapRegion: TRect;  // 2.42

    XShade: Integer;  // 2.44
    YShade: Integer;

    aaN: Integer;  // 2.5

    MapGridX, MapGridY: Integer;  // 2.54
    Quitting: Boolean;  // 2.54

    Pal256: Boolean;  // 3.0
    Index256: Integer;
    Row256: Integer;
    LastIndex256: Integer;
    Enable256,
    LastEnable256: array[0..255] of Boolean;

    RGBConvScripts: array of TStringList;

    ColorUnderMousePointer: Integer;


    procedure UpdateRecentFilesMenu;
    function ColorMatch (C: Integer): Integer;
    procedure InitUndo;
    procedure ClearUndo;
    procedure SaveUndo (Action: string);
    procedure UpdateTileBitmap;
    procedure UpdateBmp (UpdateAll: Boolean);
    procedure SetTileSize (Width, Height: Integer);
    procedure SetFromTo (N: Integer);
    procedure DrawUsedFromToList;
    procedure SetColor (NewColor: Integer; SetFT: Boolean; AddFT: Boolean);
    procedure SetBackgroundColor (NewColor: Integer; Select: Boolean);
    procedure DrawShape (X1, Y1, X2, Y2: Integer; C: TCanvas);
    procedure DrawFTShape (X1, Y1, X2, Y2: Integer; C: TCanvas);
    procedure DrawFTCircle (C: TCanvas; xp, yp: Integer; Shift: Boolean);
    procedure DrawCursor;
    procedure ShowStatusInfo;
    procedure StartEdit (UpdateAll: Boolean);
    procedure SwapWithUndo;
    procedure SaveTempBmp;
    procedure ShowRGB (color: Integer);
    procedure HFlipBounds (var Bounds: Integer);
    procedure VFlipBounds (var Bounds: Integer);
    procedure RotateBounds (var Bounds: Integer; deg: Integer);
    function NewTCName: string;
    function NewMapName: string;
    function TCNameOK (s: string; MayExist: Boolean): Boolean;
    procedure IdError (id: string);
    function HasCurrentBounds (Tile: SmallInt): Boolean;
    procedure GetMCRTile (var MCR: MapCellRec; var Tile: Integer;
                                var Mir: Boolean; var Ups: Boolean);
    procedure SetMCRTile (var MCR: MapCellRec; Tile: Integer;
                                Mir, Ups: Boolean);
    procedure AddMCR (var MCR: MapCellRec; n: Integer);
    procedure MirSwap (var mcr1: MapCellRec; var mcr2: MapCellRec; MirBoth: Boolean);
    procedure UpsSwap (var mcr1: MapCellRec; var mcr2: MapCellRec; MirBoth: Boolean);
    procedure DrawTile (TabIndex, N: Integer; var bmp: TImage;
              var Mir: Boolean; var Ups: Boolean; var Rot: Boolean;
              var FullBmp: TImage);
    procedure DrawCurrentTile;
    procedure ShowSelectedTile;
    procedure SelectCurrentTile (n: Integer);
    procedure HideUsedColors;
    procedure DrawMap (Area: TRect; ExportingImage: Boolean; Clp, Sq: Boolean);
    procedure ZoomMap;
    function CombineMCR (OldMCR, NewMCR: MapCellRec): MapCellRec;
    procedure CloseAll;
    function SaveChanges: Boolean;
    procedure ToggleAnimation;
    function FindCurrentColorPattern (FindColor: Integer; All: Boolean): Integer;
    procedure FindPatternForColor;
    procedure SelectSavedFromToList;
{$IFDEF IMPORTEDLEV}
    procedure ImportLevelTiles (dir, name: string; ww, hh: Integer; extc: Char = #0);
    procedure ImportAnySize (dir: string; extc: Char);
    procedure ImportLevelMap (dir, filename, name: string);
{$ENDIF}
    procedure RecentFileClick (Sender: TObject);
    procedure AddFileToRecentProjects (Filename: string);
    procedure ReadConfigFile;
    procedure WriteConfigFile;
    procedure ShowTileSelection (Clip: Boolean);
    procedure GetTileArea;
    procedure SwapInt (var x, y: Integer);
    function ColorPerc (RGB1, RGB2, Perc2, MaxPerc: Integer): Integer;
    function ColorPercFT (i1, i2, Perc2, MaxPerc: Integer): Integer;
    procedure UpdateMap;
    procedure UpdateMapRegion(Region: TRect);
    procedure UpdateTileGrid;
    function CountEnabledColors: Integer;
    procedure SaveHistoryCoords (x1, y1, x2, y2: Integer);
    procedure LoadRGBConvNames;
    function ConvertPixel (color: Integer): Integer;
  end;

var
  MainForm: TMainForm;

implementation

uses Import, Clipbrd, About, Create, TileCopy, MCEdit, Hex, CGSettings,
  SelectDir, Export, Scroll, Calc, PalMan, ImpPovAni, ReplaceColors,
  InfoForm, Settings, ListsForm, RGBConvForm;

{$R *.DFM}



procedure ShowMessage (const sMsg: string);
begin
  MessageDlg (sMsg, mtInformation, [mbOK], 0);
end;


var
  DtTm: TDateTime;
  aiDtTm: array[0..1] of Integer absolute DtTm;

function UpCaseStr (s: string): string;
  var
    i: Integer;
begin
  for i := 1 to Length (s) do
    s[i] := UpCase (s[i]);
  UpCaseStr := s;
end;

function FileExists (Filename: string): Boolean;
  var
    SR: TSearchRec;
begin
  Result := FindFirst (Filename, faArchive, SR) = 0;
  FindClose (SR);
end;

function DirExists (Filename: string): Boolean;
  var
    SR: TSearchRec;
begin
  Result := FindFirst (Filename, faDirectory, SR) = 0;
  FindClose (SR);
end;

procedure Msg (s: string);
begin
  MessageDlg (s, mtInformation, [mbOk], 0);
end;


function FilePath (Name: string): string;
begin
  if Pos ('\', Name) = 0 then
    FilePath := ''
  else
  begin
    while (Length (Name) > 0) and (Name[Length (Name)] <> '\') do
      Delete (Name, Length (Name), 1);
    FilePath := Name;
  end;
end;

function WithoutPath (Name: string): string;
  var
    i: Integer;
begin
  i := Length (Name);
  while (i > 0) and (Name[i] <> '\') do
    Dec (i);
  Delete (Name, 1, i);
  WithoutPath := Name;
end;

function WithoutExt (Name: string; Ext: string): string;
  var
   { i: Integer; }
    sPath, sFile: string;
begin
{
  i := Pos (Ext, Name);
  if i <> Length (Name) - Length (Ext) + 1 then
    WithoutExt := Name
  else
    WithoutExt := Copy (Name, 1, Length (Name) - Length (Ext));
}
  // 2.34
  sPath := FilePath (Name);
  sFile := WithoutPath (Name);
  while Pos ('.', sFile) > 0 do
    Delete (sFile, Length (sFile), 1);
  WithoutExt := sPath + sFile;
end;

function CreatePath (Name: string): string;
  var
    i: Integer;
    p, s: string;
begin
  s := Name;
  while Pos ('\', s) > 0 do
  begin
    i := Pos ('\', s);
    p := Copy (Name, 1, i - 1);
    if not ((Length (p) = 2) and (p[2] = ':')) then
      if not DirExists (p) then
        mkdir (p);
    s[i] := #0;
  end;
end;

function ProjectName: string;
  var
    Name: string;
begin
  Name := Filename;
  if Name = '' then
    Name := DEFAULT_NAME + DEFAULT_EXT;
  ProjectName := WithoutPath (WithoutExt (Name, DEFAULT_EXT));
end;

function ValidNumber (var s: string): Boolean;
  var
    N: Integer;
    Code: Integer;
begin
  if (Length (s) > 1) then
    if Copy (UpCaseStr (s), 1, 2) = '0X' then
    begin
      Delete (s, 1, 2);
      Insert ('$', s, 1);
      Val (s, N, Code);
      Str (N, s);
    end;
  Val (s, N, Code);
  ValidNumber := Code = (N - N);
end;

procedure ResizeBitmap (var img: TImage);
begin
  img.Picture.Bitmap.PixelFormat := pf24bit;
  img.Picture.Bitmap.Width := img.Width;
  img.Picture.Bitmap.Height := img.Height;
end;

procedure FillBitmap (var img: TImage; rgb: Integer);
  var
    i: Integer;
begin
  img.Picture.Bitmap.PixelFormat := pf24bit;
  with img.Picture.Bitmap.Canvas do
  begin
    Brush.Style := bsSolid;
    Brush.Color := rgb;
    i := pen.Width;
    FillRect (Rect (-i, -i,
          img.Picture.Bitmap.Width + i,
          img.Picture.Bitmap.Height + i));
  end;
end;

procedure TMainForm.InitUndo;
  var
    i: Integer;
begin
  for i := 0 to MAX_UNDO - 1 do
  begin
    Undo[i].Bmp := TBitmap.Create;
    Undo[i].Bmp.PixelFormat := pf24bit;
  end;
end;

procedure TMainForm.ClearUndo;
begin
  UndoCount := 0;
  UndoPos := -1;
  Redo1.Enabled := FALSE;
{
  RedoButton.Down := FALSE;
  RedoButton.Enabled := FALSE;
}
  Undo1.Enabled := FALSE;
{
  UndoButton.Down := FALSE;
  UndoButton.Enabled := FALSE;
}
end;

procedure TMainForm.SaveUndo (Action: string);
  var
    i: Integer;
    ur: UndoRec;
begin
  if UndoPos + 1 <> UndoCount then
  begin
    UndoCount := UndoPos + 1;
    Redo1.Caption := '&Redo';
    Redo1.Enabled := FALSE;
  {
    RedoButton.Down := FALSE;
    RedoButton.Enabled := FALSE;
  }
  end;
  if UndoCount >= MAX_UNDO - 1 then
  begin
    ur := Undo[0];
    for i := 0 to UndoCount - 1 do
      Undo[i] := Undo[i + 1];
    Undo[UndoCount] := ur;  // don't lose initialized TBitmaps!
  end
  else
  begin
    Inc (UndoCount);
    Inc (UndoPos);
  end;
  Undo[UndoPos].Bmp.Width := W;
  Undo[UndoPos].Bmp.Height := H;
  Undo[UndoPos].Bmp.Canvas.CopyRect (Rect (0, 0, W, H),
       Bmp.Canvas, MakeRect (BORDER_W, BORDER_H, W, H));
  Undo[UndoPos].ActionName := Action;
  Undo[UndoPos].HistoryCoords := '';

  Undo1.Caption := '&Undo ' + Action;
  Undo1.Enabled := TRUE;
{
  UndoButton.Enabled := TRUE;
}
end;

procedure TMainForm.Exit1Click(Sender: TObject);
begin
//  if Modified then
//    if not SaveChanges then
//      Exit;
  Close;
end;


function LimitRGB (X: Integer): Integer;
begin
  if X < 0 then
    LimitRGB := 0
  else
    if X > 255 then
      LimitRGB := 255
    else
      LimitRGB := X;
end;

function MakePalRGB (r, g, b, l: Integer): Integer;
  var
    Light: Integer;
begin
  Light := l;
  MakePalRGB := RGB (LimitRGB (r + Light),
                     LimitRGB (g + Light),
                     LimitRGB (b + Light));
end;



procedure TMainForm.PalettePaint(Sender: TObject);
  var
    Max: Integer;
    iW, iH, x1, y1, x2, y2, k: Integer;
    R, G, B, RR, GG, BB: Integer;
    Wd, Ht: Integer;
    i, j, l, m, n, p: Integer;
    OldShowCurPal: Boolean;

  function GetColorCircle (i, j: Integer): Integer;
    var
      k, l, m, n: Integer;
  begin
    k := (j * 6) mod Ht;
    l := (j * 6) div Ht;
    m := 256 * k div Ht;
    n := 256 - m;
    case l of
      0: begin
           RR := 255;
           GG := 0;
           BB := n;
          // BB := Round (256 * Cos (k / Ht));
         end;
      1: begin
           RR := 255;
           GG := m;
           BB := 0;
         end;
      2: begin
           RR := n;
           GG := 255;
           BB := 0;
         end;
      3: begin
           RR := 0;
           GG := 255;
           BB := m;

         end;
      4: begin
           RR := 0;
           GG := n;
           BB := 255;
         end;
      else
         begin
           RR := m;
           GG := 0;
           BB := 255;
         end;
    end;

    Result := MakePalRGB (i * RR div Wd,
                          i * GG div Wd,
                          i * BB div Wd,
                          i * 255 div Wd);
  end;

begin
  Max := MaxR * MaxG * MaxB;
  iW := 2 * MaxB;
  iH := Max div iW;

  if Pal256 then
  begin
    iW := 8;
    iH := 32;
  end;

  j := (RightPanel.Height div 2) div iH * iH + 10;
  if j <> PalettePanel.Height then
    PalettePanel.Height := j;

  Wd := Palette.Width;
  Ht := Palette.Height;
  if Ht > 2 * Wd then
  begin
    iW := 1 * MaxB;
    iH := Max div iW;
  end;
  if Wd > Ht then
  begin
    iW := 3 * MaxB;
    iH := Max div iW;
  end;

  if Pal256 then
  begin
    Max := 256;
    iW := 8;
    iH := 32;
  end;

  SetLength (PaletteValues, Max);
  PalNH := iW;
  PalNV := iH;
  PalW := Wd;
  PalH := Ht;

  with Palette.Canvas do
  begin
    if Pal256 then
    begin  // 256-color palette
      with TileTab[Tab.TabIndex].tbr do
      begin
        p := PaletteNumber;
        OldShowCurPal := ShowCurrentPalette1.Checked;
        ShowCurrentPalette1.Checked := FALSE;


          for k := 0 to 255 do
          begin

            Brush.Color := 0;
            if (p >= 0) then
            begin
              if (k < aiPalSize[p]) then
                Brush.Color := aaiPal[p, k];
            end
            else
              Brush.Color := GetColorCircle (Wd * (k mod 8) div 8, Ht * (k div 8) div 32);

            Brush.Style := bsSolid;
            Pen.Style := psClear;
            x1 := (k mod iW) * Wd div iW;
            y1 := (k div iW) * Ht div iH;
            x2 := ((k mod iW) + 1) * Wd div iW;
            y2 := ((k div iW) + 1) * Ht div iH;
            Rectangle (x1, y1, x2 + 1, y2 + 1);
            PaletteValues[k] := Brush.Color;

            if not Enable256[k] then
            begin
              Brush.Style := bsBDiagonal;
              Brush.Color := clBlack;
              Rectangle (x1, y1, x2 + 1, y2 + 1);
              Brush.Style := bsFDiagonal;
              Brush.Color := clWhite;
              Rectangle (x1, y1, x2 + 1, y2 + 1);
            end;
          end;


        ShowCurrentPalette1.Checked := OldShowCurPal;
      end;
    end
    else
    begin
      if not SmoothPalette1.Checked then   // generated 6x6x6/7x7x7/8x8x8 palettes
      begin
        OldShowCurPal := ShowCurrentPalette1.Checked;
        ShowCurrentPalette1.Checked := FALSE;
        k := 0;
        for R := 0 to MaxR - 1 do
          for G := 0 to MaxG - 1 do
            for B := 0 to MaxB - 1 do
            begin
              case PaletteOrder of
                1: begin RR := G; GG := B; BB := R; end;
                2: begin RR := B; GG := R; BB := G; end;
                3: begin RR := R; GG := B; BB := G; end;
                4: begin RR := G; GG := R; BB := B; end;
                5: begin RR := B; GG := G; BB := R; end;
              else begin RR := R; GG := G; BB := B; end;
              end;
              Brush.Color :=
                 ColorMatch (RGB (RR * 255 div (MaxR - 1),
                                  GG * 255 div (MaxG - 1),
                                  BB * 255 div (MaxB - 1)));
              Brush.Style := bsSolid;
              Pen.Style := psClear;
              x1 := (k mod iW) * Wd div iW;
              y1 := (k div iW) * Ht div iH;
              x2 := ((k mod iW) + 1) * Wd div iW;
              y2 := ((k div iW) + 1) * Ht div iH;
              Rectangle (x1, y1, x2 + 1, y2 + 1);

              PaletteValues[k] := Brush.Color;

              Inc (k);
            end;
        ShowCurrentPalette1.Checked := OldShowCurPal;
      end
      else
      begin  // smooth palette
        for j := 0 to Ht - 1 do
          for i := 0 to Wd - 1 do
            Pixels[i, j] := GetColorCircle (i, j);
      end;
    end;

  end;

  RearrangePalette1.Enabled := not SmoothPalette1.Checked;
end;

procedure TMainForm.FormResize(Sender: TObject);
  var
    Wd, Ht: Integer;
    X, Y: Integer;
    i: Integer;
begin
  if Quitting then Exit;

  Wd := (W + 2 * BORDER_W) * Scale;
  Ht := (H + 2 * BORDER_H) * Scale;
  X := ScrollBox.ClientWidth div 2 - Wd div 2;
  Y := ScrollBox.ClientHeight div 2 - Ht div 2;
  if X < 0 then
    X := 0;
  if Y < 0 then
    Y := 0;
  with Tile do
  begin
    Left := X;
    Top := Y;
    Width := Wd;
    Height := Ht;
  end;

  Palette.Repaint;
  i := RightPanel.Height - PalettePanel.Height - ColorsPanel.Height - ProgressPanel.Height;
  PatternPanel.Height := PatternPanel.Width;
  if PatternPanel.Height > i then
    PatternPanel.Height := i;
  UpdateBmp (TRUE);

  if Mode = mTile then
  begin
    StatusBar.Panels[4].Text := Format ('%dx', [Scale]);
    ZoomOut1.Enabled := (Scale > 1);
    ZoomIn1.Enabled := (Scale < MAX_SCALE);
  end;
  if Mode = mMap then
  begin
    ZoomIn1.Enabled := (Zoom > 1);
    ZoomOut1.Enabled := (Zoom < MAX_ZOOM);
  end;

  DrawCursor;
end;

procedure TMainForm.PaletteMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
  var
    i, j, k: Integer;
begin
{
  if IgnorePaletteMouseDown then
  begin
    IgnorePaletteMouseDown := FALSE;
    Exit;
  end;
}
  LastIndex256 := -1;

  i := X * PalNH div PalW;
  j := Y * PalNV div PalH;

  if (i >= 0) and (i < PalNH) and (j >= 0) and (j < PalNV) then
  begin
    Row256 := 32 * j div PalNV;
    Index256 := Row256 * 8 + (8 * i div PalNH);

    if SmoothPalette1.Checked then
      k := Palette.Canvas.Pixels[X - 1, Y - 1]
    else
      k := PaletteValues[j * PalNH + i];
  end;

  if Button = mbLeft then
  begin
    if k = Color.Brush.Color then
      Inc (FromToCount);
    ColorSelect := TRUE;
  end;
  if Button = mbRight then
    RightMouseButton := TRUE;
  PaletteMouseMove (Sender, Shift, X, Y);
end;

procedure GetRGB (RGB: Integer; var R: Integer; var G: Integer; var B: Integer);
begin
  R := RGB;
  G := RGB div $100;
  B := RGB div $10000;
  R := R and $FF;
  G := G and $FF;
  B := B and $FF;
end;

function ColorBetween (RGB1, RGB2: Integer): Integer;
  var
    R1, G1, B1: Integer;
    R2, G2, B2: Integer;
    C: Integer;
begin
  GetRGB (RGB1, R1, G1, B1);
  GetRGB (RGB2, R2, G2, B2);
  C := RGB ((R1 + R2) div 2, (G1 + G2) div 2, (B1 + B2) div 2);
  if C = TRANS_COLOR then
    if (RGB1 <> TRANS_COLOR) and (RGB2 <> TRANS_COLOR) then
      Inc (C);
  ColorBetween := C;
end;

function Grey (RGB: Integer): Integer;
  var
    R, G, B: Integer;
begin
  GetRGB (RGB, R, G, B);
  Grey := (R + G + B) div 3;
end;

function Blend (RGB1, RGB2: Integer; w1, w2: Integer): Integer;
  var
    R1, G1, B1: Integer;
    R2, G2, B2: Integer;
    C: Integer;
begin
  GetRGB (RGB1, R1, G1, B1);
  GetRGB (RGB2, R2, G2, B2);
  C := RGB ((w1 * R1 + w2 * R2) div (w1 + w2),
            (w1 * G1 + w2 * G2) div (w1 + w2),
            (w1 * B1 + w2 * B2) div (w1 + w2));
  if C = TRANS_COLOR then
    if (RGB1 <> TRANS_COLOR) and (RGB2 <> TRANS_COLOR) then
      Inc (C);
  Blend := C;
end;

procedure TMainForm.PaletteMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
  var
    i, j, k, Index: Integer;
    ft: Integer;
    R, G, B: Integer;
begin
  i := X * PalNH div PalW;
  j := Y * PalNV div PalH;
  if (i >= 0) and (i < PalNH) and (j >= 0) and (j < PalNV) then
  begin
    Index := j * PalNH + i;
    if SmoothPalette1.Checked then
      k := Palette.Canvas.Pixels[X - 1, Y - 1]
    else
      k := PaletteValues[j * PalNH + i];

    if Pal256 then
    begin
      k := PaletteValues[Index];

      if ColorSelect then
        if not Enable256[Index] then
          if CountEnabledColors < 256 then
          begin
            LastEnable256 := Enable256;
            for i := 0 to 255 do
              Enable256[i] := True;
            Palette.Repaint;
          end;
    end;

    // 2.0  select from current color to new

    if ssShift in Shift then
    begin
      ShowRGB (k);

      if ColorSelect then
      begin

        if (FromToFirst = FromToLast) then
        begin
          for ft := 0 to MAX_FROM_TO - 1 do
            FromToList[ft] := ColorPerc (Color.Brush.Color,
                                         k, ft, MAX_FROM_TO);
          FromToFirst := 0;
          FromToLast := MAX_FROM_TO - 1;
        end
        else
        begin
          for ft := FromToFirst + 1 to FromToLast do
            FromToList[ft] := ColorPerc (FromToList[FromToFirst],
                               k, Abs (ft - FromToFirst),
                               Abs (FromToLast - FromToFirst));
          for ft := FromToFirst - 1 downto FromToLast do
            FromToList[ft] := ColorPerc (FromToList[FromToFirst],
                               k, Abs (ft - FromToFirst),
                               Abs (FromToLast - FromToFirst));
        end;

      end;

      // 2.43 (bug fix)
      for ft := 0 to MAX_FROM_TO - 1 do
      begin
        GetRGB (FromToList[ft], R, G, B);
        ExFromToList[ft, 0] := R;
        ExFromToList[ft, 1] := G;
        ExFromToList[ft, 2] := B;
      end;
      FromToPaint (Sender);

    end
    else
    begin
      ShowRGB (k);
      if ColorSelect then
        SetColor (k, TRUE, ssCtrl in Shift);
    end;


    if RightMouseButton then
      if Pal256 then
      begin
        j := Byte (not Enable256[Index]);
        if Index <> LastIndex256 then
        begin
          case (2 * byte (ssCtrl in Shift) + byte (ssShift in Shift)) of
            1: begin  { shift }
                 for i := 0 to 7 do
                   Enable256[(Index and (not 7)) + i] := Boolean (j);
                 LastIndex256 := Index;
                 Palette.Repaint;
               end;
            2: begin  { ctrl }
                 Enable256[Index] := Boolean (j);
                 LastIndex256 := Index;
                 Palette.Repaint;
               end;
            3: begin  { shift + ctrl }
                 for i := 0 to 255 do
                   Enable256[i] := False;
                 for i := 0 to 7 do
                   Enable256[(Index and (not 7)) + i] := True;
                 LastIndex256 := Index;
                 Palette.Repaint;
                 ShowRGB (k);
                 ColorSelect := TRUE;
                 SetColor (k, TRUE, FALSE);
                 ColorSelect := FALSE;
               end;

          else
            if CountEnabledColors = 256 then
              SetBackgroundColor (k, FALSE)
            else
            begin
              for i := 0 to 255 do
                Enable256[i] := Boolean (j);
              LastIndex256 := Index;
              Palette.Repaint;
            end;

          end;
        end;


      end
      else
        SetBackgroundColor (k, FALSE);

  end;
end;

procedure TMainForm.PaletteMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then
    ColorSelect := FALSE;
  if Button = mbRight then
    RightMouseButton := FALSE;
end;


procedure TMainForm.UpdateRecentFilesMenu;
  var
    mi: TMenuItem;
    i, j: Integer;
begin
  for i := RecentProjects1.Count - 1 downto 0 do
    RecentProjects1.Delete (i);
  j := RecentFiles.Count;
  if j > 9 then
    j := 9;
  for i := 0 to j - 1 do
  begin
    mi := TMenuItem.Create (MainMenu);
    mi.Caption := '&' + IntToStr (i + 1) + '  ' + RecentFiles.Strings[i];
    mi.Tag := i;
    mi.OnClick := RecentFileClick;
    RecentProjects1.Add (mi);
  end;
  RecentProjects1.Enabled := RecentFiles.Count > 0;
end;


procedure TMainForm.FormCreate(Sender: TObject);
  var
    s: string;
    i: Integer;
    F: TextFile;
    tdt: TDrawingTool;
begin
  StartTime := Now;
  Sessions := 0;
{$IFDEF IMPORTEDLEV}
  ImportEdlev.Visible := TRUE;
{$ENDIF}

  // 2.43
  for tdt := Low (LineSize) to High (LineSize) do
    LineSize[tdt] := 1;

  CursorSize := DEFAULT_CURSOR_SIZE;
  RightPanelWidth := RightPanel.Width;
  LastFromToFirst := 0;
  LastFromToLast := MAX_FROM_TO - 1;
  Zoom := ZOOM_FACTOR;

  VisibleMapRegion := Rect(0, 0, 0, 0);

  ApplPath := ParamStr (0);
  i := Length (ApplPath);
  while (i > 0) and (ApplPath[i] <> '\') do
  begin
    Delete (ApplPath, Length (ApplPath), 1);
    Dec (i);
  end;


  RecentFiles := TStringList.Create;
  ReadConfigFile;


  CDROM := FALSE;
  try
    AssignFile (F, ApplPath + '$TS$Tmp$.$$$');
    ReWrite (F);
    CloseFile (F);
    Erase (F);
  except
    CDROM := TRUE;
  end;
  if CDROM then
  begin
    ShowMessage ('Tile Studio is running from a read-only drive. '#13 +
                 'Some options might not be available.');
  end;

  PatternPanel.Height := PatternPanel.Width;
  Pattern.Height := Pattern.Width;

  Homepage1.Caption := APPL_NAME + ' &Homepage';
  OpenDialog.DefaultExt := DEFAULT_EXT;
  SaveDialog.DefaultExt := DEFAULT_EXT;
  s := APPL_NAME + ' Project (*' + DEFAULT_EXT +
       ')|*' + DEFAULT_EXT + '|All files (*.*)|*.*';
  OpenDialog.Filter := s;
  SaveDialog.Filter := s;

  MapDisplay.Canvas.Brush.Style := bsClear;
  MapDisplay.ControlStyle := MapDisplay.ControlStyle + [csOpaque];
  bmpMap := TBitmap.Create;
  bmpMap.PixelFormat := pfMap;
  ClipBitmap.Picture.Bitmap.PixelFormat := pfMap;
  SeqBitmap.Picture.Bitmap.PixelFormat := pfMap;

{  bmp1 := TImage.Create (InvPanel); }
  bmp1.Transparent := TRUE;
  bmp1.Picture.Bitmap.TransparentColor := TRANS_COLOR;
{  bmp2:= TImage.Create (InvPanel); }
  bmp2.Transparent := FALSE;
  SelBmp.Transparent := TRUE;
  SelBmp.Picture.Bitmap.TransparentColor := TRANS_COLOR;
{
  if not Ok then
  begin
    MessageDlg ('This program cannot run with 16 or 256 color display,' +
        'Please change your desktop settings to High Color or True Color.',
        mtError, [mbOk], 0);
    Close;
  end;
}


  // SetEditorMode (mTile);   // [ 732697 ] Access violation when starting TS 2.41 on XP

  SpecialColor := SPECIAL_COLOR;

  MaxRGB := 8;
  MaxR := 8;
  MaxG := 8;
  MaxB := 8;

  InitUndo;
  ClearUndo;

  VisualBmp := TBitmap.Create;
  VisualBmp.PixelFormat := pf24bit;
  VisualBmp.TransparentColor := TRANS_COLOR;
  SetStretchBltMode(VisualBmp.Canvas.Handle, HALFTONE);

  TempBmp := TBitmap.Create;
  TempBmp.PixelFormat := pf24bit;
  TempBmp.TransparentColor := TRANS_COLOR;
  SetStretchBltMode(TempBmp.Canvas.Handle, HALFTONE);

  Bmp := TBitmap.Create;
  Bmp.PixelFormat := pf24bit;
  Bmp.TransparentColor := TRANS_COLOR;
  SetStretchBltMode(Bmp.Canvas.Handle, HALFTONE);

  ClipBmp := TBitmap.Create;
  ClipBmp.PixelFormat := pf24bit;
  ClipBmp.TransparentColor := TRANS_COLOR;
  SetStretchBltMode(ClipBmp.Canvas.Handle, HALFTONE);

  UnionSkinBmp := TBitmap.Create;
  UnionSkinBmp.PixelFormat := pf24bit;
  UnionSkinBmp.TransparentColor := TRANS_COLOR;
  SetStretchBltMode(UnionSkinBmp.Canvas.Handle, HALFTONE);
  UnionSkinTile := -1;
  LastTileEdited := -1;

  AlphaBmp := TBitmap.Create;
  AlphaBmp.PixelFormat := pf24bit;
  AlphaBmp.TransparentColor := TRANS_COLOR;
  SetStretchBltMode(AlphaBmp.Canvas.Handle, HALFTONE);


  CreateNewTileCollection (NewTCName, 32, 32, TRUE);

  SetEditorMode (mTile);  // 2.43  moved to here

  StartEdit (TRUE);

  Paste1.Enabled := ClipBoard.HasFormat (CF_BITMAP);
  StretchPaste1.Enabled := ClipBoard.HasFormat (CF_BITMAP);
  ScaledPaste1.Enabled := ClipBoard.HasFormat (CF_BITMAP);

  Scale := DEFAULT_SCALE;
  ColorSelect := FALSE;
  RightMouseButton := FALSE;
  FromToCount := 0;
  SetBackgroundColor (DEFAULT_BACKGR_COLOR, FALSE);
  SetColor (ColorMatch (DEFAULT_COLOR), TRUE, FALSE);
//  SetFromTo (FromToCount);
  Erasing := FALSE;
  ShiftErasing := FALSE;

  PaletteOrder := 1;
  SelectBackMidFront (pMid, mbLeft, [], 1, 1);

  Application.Title := APPL_NAME + ' - ' + ProjectName;
  MainForm.Caption := Application.Title;

  ReadParamFile := ParamCount > 0;
  if ReadParamFile then
    FileToOpen := ParamStr (1);

  TileSelX1 := 0;
  TileSelY1 := 0;
  TileSelX2 := -1;
  TileSelY2 := -1;
  MovingTileSel := FALSE;
  MovingTileSelPixels := FALSE;

  Busy := FALSE;

  Modified := FALSE;

  // apply config data
  UpdateRecentFilesMenu;

  MainForm.Position := poDesigned;
  MainForm.Left := WinLeft;
  MainForm.Top := WinTop;
  MainForm.Width := WinWidth;
  MainForm.Height := WinHeight;


  XShade := 0;
  YShade := 0;

  ShowTileGrid1.Checked := Grid.Visible;

  MapGridX := 0;
  MapGridY := 0;
  Quitting := False;

  Pal256 := FALSE;

  ClipTab.Align := alClient;
  UtilsTab.Align := alClient;

  LoadRGBConvNames;

end;  { FormCreate }

procedure TMainForm.BackGroundMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbRight then
    SetBackgroundColor (DEFAULT_BACKGR_COLOR, TRUE)
  else
    SetBackgroundColor (Background.Brush.Color, TRUE);
end;

procedure TMainForm.UpdateTileBitmap;
begin
  with TileTab[Tab.TabIndex] do
  begin
    TileBitmap.Picture.Bitmap := tbr.TileBitmap;
    TileBitmap.Width := tbr.TileCount * tbr.W;
    TileBitmap.Height := tbr.H;
    TileBitmap.Picture.Bitmap.Width := tbr.TileCount * tbr.W;
    TileBitmap.Picture.Bitmap.Height := tbr.H;

    with TileBitmap.Picture.Bitmap.Canvas do
    begin
      Brush.Color := BackGround.Brush.Color;
      FillRect (Rect (0, 0, TileBitmap.Width, TileBitmap.Height));
      Draw (0, 0, tbr.TileBitmap);
    end;

  end;
end;

procedure TMainForm.UpdateBmp (UpdateAll: Boolean);
  var
    x, y, i, j, k, ov: Integer;
    TmpBmp: TBitmap;

  procedure ClearEdge;
    var
      ov: Integer;
  begin
    with VisualBmp.Canvas do
    begin
      Pen.Style := psClear;
      Brush.Style := bsSolid;
      Brush.Color := ColorBetween (Background.Brush.Color, clSilver);
      FillRect (MakeRect (0, 0, W + 2 * BORDER_W, BORDER_H));
      FillRect (MakeRect (0, BORDER_H, BORDER_W, H));
      FillRect (MakeRect (W + BORDER_W, BORDER_H, BORDER_W, H));
      FillRect (MakeRect (0, H + BORDER_H, W + 2 * BORDER_W, BORDER_H));
      ov := TileTab[Tab.TabIndex].tbr.Overlap;
      if ov > 0 then
      begin
        Brush.Color := ColorBetween (Brush.Color, clSilver);
        FillRect (MakeRect (0, 0, W + 2 * BORDER_W, BORDER_H));
        FillRect (MakeRect (0, BORDER_H, BORDER_W, ov));
        FillRect (MakeRect (W + BORDER_W, BORDER_H, BORDER_W, ov));
      end;
    end;
  end;

  var
    OfsX, OfsY: Integer;  // 2.4
    tmpX1, tmpY1, tmpX2, tmpY2: Integer; // 3.0
    tmpS, sNum: string;
    iCode: Integer;
    oldRGB, newRGB: Integer;
    opacity: Integer;
    alpha: Integer;
    w1, w2: Integer;

begin  { UpdateBMP }
//  Caption := Format ('UndoPos: %d UndoCount: %d', [UndoPos, UndoCount]);

  ShowStatusInfo;

  if Quitting then Exit;

  if Mode = mTile then
  begin
    alpha := -1;
    if UseAsAlphaChannel1.Checked then
      if (AlphaBmp.Width = W) and (AlphaBmp.Height = H) then
      begin
        if LastTileEdited <> TileTab[Tab.TabIndex].tbr.Current then
          LastTileEdited := TileTab[Tab.TabIndex].tbr.Current
        else
          alpha := 0;
      end;

    // set opacity of last action
    opacity := OpacityTrackBar.Position;
    if UpdateAll then
      if (opacity <> OpacityTrackBar.Max) or (alpha <> -1) then
        if (UndoCount > 0) and (UndoPos >= 0) then
        begin
          for tmpY1 := 0 to H - 1 do
            for tmpX1 := 0 to W - 1 do
            begin
              newRGB := Bmp.Canvas.Pixels[tmpX1 + BORDER_W, tmpY1 + BORDER_H];
              oldRGB := Undo[UndoPos].Bmp.Canvas.Pixels[tmpX1, tmpY1];
              if (newRGB <> TRANS_COLOR) and (oldRGB <> TRANS_COLOR) then
              begin
                w1 := OpacityTrackBar.Max;
                w2 := opacity;

                if alpha <> -1 then
                begin
                  alpha := AlphaBmp.Canvas.Pixels[tmpX1, tmpY1];
                  if (alpha = TRANS_COLOR) then
                    alpha := 0
                  else
                    alpha := Grey (alpha);
                  w1 := 256 * OpacityTrackBar.Max;
                  w2 := 256 * alpha * opacity div 256;
                end;

                //w1 := OpacityTrackBar.Max - opacity;
                //w2 := opacity;


                Bmp.Canvas.Pixels[tmpX1 + BORDER_W, tmpY1 + BORDER_H] := Blend (oldRGB, newRGB, w1 - w2, w2);

              end;
            end;
        end;


    TmpBmp := TBitmap.Create;
    SetStretchBltMode(TmpBmp.Canvas.Handle, HALFTONE);
    with TmpBmp do
    begin
      PixelFormat := pf24bit;
      Width := W;
      Height := H;
      Transparent := TRUE;
     // TransparentMode := tmFixed;
      TransparentColor := TRANS_COLOR;

      Canvas.CopyRect (Rect (0, 0, W, H), Bmp.Canvas,
                   MakeRect (BORDER_W, BORDER_H, W, H));
    end;
    ClearEdge;
    with VisualBmp.Canvas do
    begin
      Brush.Color := Background.Brush.Color;
      FillRect (MakeRect (BORDER_W, BORDER_H, W, H));
      Draw (BORDER_W, BORDER_H, TmpBmp);
    end;

    if UnionSkinTile <> -1 then
    begin
      for tmpY1 := 0 to H - 1 do
        for tmpX1 := 0 to W - 1 do
        begin
          newRGB := UnionSkinBmp.Canvas.Pixels[tmpX1 + BORDER_W, tmpY1 + BORDER_H];
          oldRGB := VisualBmp.Canvas.Pixels[tmpX1 + BORDER_W, tmpY1 + BORDER_H];
          if (newRGB <> TRANS_COLOR) and (oldRGB <> TRANS_COLOR) then
            VisualBmp.Canvas.Pixels[tmpX1 + BORDER_W, tmpY1 + BORDER_H] := Blend (oldRGB, newRGB, 125, 50);
        end;
    end;

    if Drawing then
      if DrawingShape then
      begin
        VisualBmp.Canvas.Pen := Bmp.Canvas.Pen;
        VisualBmp.Canvas.Brush := Bmp.Canvas.Brush;
        if Bmp.Canvas.Pen.Color = TRANS_COLOR then
        begin
          VisualBmp.Canvas.Pen.Color := Background.Brush.Color;
          if VisualBmp.Canvas.Brush.Style <> bsClear then             // 2.44: bug fix
            VisualBmp.Canvas.Brush.Color := Background.Brush.Color;
        end;
        DrawFTShape (Origin.X, Origin.Y, CurPos.X, CurPos.Y, VisualBmp.Canvas);
        DrawingShape := FALSE;
        ClearEdge;
      end;


    if bHistoryShow.Down then
    begin
      for i := 0 to HistoryListBox.Items.Count - 1 do
        if HistoryListBox.Selected[i] then
        begin
          tmpS := HistoryListBox.Items[i];
          if tmpS <> '' then
          begin
            tmpS := tmpS + ',';
            for j := 1 to 4 do
            begin
              k := Pos (',', tmpS);
              sNum := Copy (tmpS, 1, k - 1);
              Delete (tmpS, 1, k);
              case j of
                1: Val (sNum, tmpX1, iCode);
                2: Val (sNum, tmpY1, iCode);
                3: Val (sNum, tmpX2, iCode);
                4: Val (sNum, tmpY2, iCode);
              end;
            end;
            VisualBmp.Canvas.Pixels[tmpX1 + BORDER_W, tmpY1 + BORDER_H] := $F808F8;
            VisualBmp.Canvas.Pixels[tmpX2 + BORDER_W, tmpY2 + BORDER_H] := $F808F8;

          end;
        end;
    end;

    if UpdateAll then
      with TileTab[Tab.TabIndex] do
      begin
        if (tbr.TileBitmap <> nil) and (tbr.Current < tbr.TileCount) then
        begin
          TileBitmap.Width := tbr.TileBitmap.Width;
          TileBitmap.Height := tbr.TileBitmap.Height;

          // update the actual Tile Bitmap:
          tbr.TileBitmap.Canvas.CopyRect (MakeRect (tbr.Current * W, 0, W, H),
              TmpBmp.Canvas, Rect (0, 0, W, H));


          TileBitmap.Picture.Bitmap.Canvas.CopyRect
             (MakeRect (tbr.Current * W, 0, W, H),
             // TmpBmp.Canvas, Rect (0, 0, W, H));
              VisualBmp.Canvas,
              MakeRect (BORDER_W, BORDER_H, W, H));
        end;
//        TileBitmap.Picture.Bitmap := tbr.TileBitmap;
      end;


    with Pattern.Canvas do
    begin
      ov := TileTab[Tab.TabIndex].tbr.Overlap;
      x := Pattern.Width div 2 - W div 2;
      y := Pattern.Height div 2 - (H - ov) div 2;

      OfsX := 0;  // 2.4
      OfsY := 0;
      with TileTab[Tab.TabIndex].tbr do
      begin
        if Current < Length (OffsetX) then
          OfsX := OffsetX[Current];
        if Current < Length (OffsetY) then
          OfsY := OffsetY[Current];
      end;

      if UpdateAll or (OfsX <> 0) or (OfsY <> 0) then
      begin
        Brush.Color := Background.Brush.Color;
        FillRect (MakeRect (0, 0, Width, Height));
      end;

      if (not Pattern1.Checked) or (not UpdateAll) then
      begin
       { if ov > 0 then }
        Draw (x + OfsX, y + OfsY, TmpBmp);
        TmpBmp.Canvas.CopyRect (Rect (0, ov, W, H - ov), VisualBmp.Canvas,
                 MakeRect (BORDER_W, BORDER_H + ov, W, H - ov));
      end
      else
      begin
        Inc (x, OfsX);
        Inc (y, OfsY);

        while x > 0 do
          Dec (x, W);
        while y > -ov do
          Dec (y, H - ov);

        repeat
          i := 0;
          repeat
            if ov > 0 then
              Draw (x + i, y, TmpBmp);
            Pattern.Canvas.CopyRect (MakeRect (x + i, y + ov, W, H - ov),
                   VisualBmp.Canvas, MakeRect (BORDER_W, BORDER_H + ov, W, H - ov));

            Inc (i, W);
          until x + i >= Pattern.Width;
          Inc (y, H - ov);
        until y >= Pattern.Height;
      end;
    end;

    Tile.Picture.Graphic := VisualBmp;

  //  with TileTab[Tab.TabIndex].tbr do
  //    Tile.Canvas.Rectangle (Current * W, 0, Current * W + W, H);


    TmpBmp.Free;

    with TileTab[Tab.TabIndex] do
    begin
      lastscale := Scale;
      lastscrollpos := TileScrollBox.HorzScrollBar.Position;
      BackGrColor := Background.Brush.Color;
    end;
  end;

  UpdateTileGrid;

end;  { UpdateBMP }

procedure TMainForm.SetTileSize (Width, Height: Integer);
  var
    BW, BH: Integer;
    i, j: Integer;
begin
 // StatusBar.Panels[0].Text := Format ('Size: %d x %d', [Width, Height]);
  W := Width;
  H := Height;
  with CursorImage do
  begin
    Picture.Bitmap.PixelFormat := pf24bit;
    Picture.Bitmap.TransparentColor := clRed;
    Picture.Bitmap.Transparent := True;
    Width := W;
    Height := H + 1;
    Picture.Bitmap.Width := W;
    Picture.Bitmap.Height := H + 1;
    with Canvas do
    begin
      Brush.Color := clRed;  // transparent color for cursor
      Brush.Style := bsSolid;
      Pen.Color := clRed;
      Pen.Style := psSolid;
      Rectangle (0, 0, W + 1, H + 2);
    end;
  end;
  BW := W + 2 * BORDER_W;
  BH := H + 2 * BORDER_H;
  with Bmp do
  begin
    Width := BW;
    Height := BH;
    Transparent := TRUE;
    TransparentMode := tmFixed;
    TransparentColor := TRANS_COLOR;
    with Canvas do
    begin
      Brush.Style := bsSolid;
      Brush.Color := TRANS_COLOR;
      Pen.Style := psClear;
      FillRect (Rect (0, 0, W + 2 * BORDER_W, H + 2 * BORDER_H));
      Pen.Style := psSolid;
      Pen.Color := Color.Brush.Color;
    end;
  end;
  with TempBmp do
  begin
    Width := BW;
    Height := BH;
  end;
  with VisualBmp do
  begin
    Width := BW;
    Height := BH;
  end;
  with UnionSkinBmp do
  begin
    Width := BW;
    Height := BH;
  end;

  bmp1.Width := BW;
  bmp1.Height := BH;
  ResizeBitmap (bmp1);

  bmp2.Width := BW;
  bmp2.Height := BH;
  ResizeBitmap (bmp2);

  SelBmp.Width := BW;
  SelBmp.Height := BH;
  ResizeBitmap (SelBmp);
  FillBitmap (SelBmp, TRANS_COLOR);
  for j := 0 to BH - 1 do
    for i := 0 to BW - 1 do
      case (i + j) mod 8 of
        0: SelBmp.Picture.Bitmap.Canvas.Pixels[i, j] := clYellow;
        4: SelBmp.Picture.Bitmap.Canvas.Pixels[i, j] := clWhite;
      end;

  UpdateBmp (TRUE);
end;


procedure TMainForm.SetFromTo (N: Integer);
  var
    R, G, B, iR, iG, iB, RR, GG, BB: Integer;
    C, i, j: Integer;
begin
  C := Color.Brush.Color;
  GetRGB (C, R, G, B);
  i := (255 div (MaxRGB - 1));
  R := R div i;
  G := G div i;
  B := B div i;

  if Pal256 and (FromToCount = -1) then
  begin
    j := Row256 * 8;
    for i := 0 to MAX_FROM_TO - 1 do
    begin
      if i = MAX_FROM_TO - 1 then Dec (j);
      GetRGB (PaletteValues[j + i], iR, iG, iB);
      ExFromToList[i, 0] := iR;
      ExFromToList[i, 1] := iG;
      ExFromToList[i, 2] := iB;
      FromToList[i] := PaletteValues[j + i];
      FromToFirst := Index256 mod 8;
      FromToLast := Index256 mod 8;
    end;
  end
  else
  begin
    case FromToCount mod 12 of
      1: begin RR := 3; GG := 3; BB := 3; end;
      2: begin RR := 2; GG := 2; BB := 2; end;
      3: begin RR := 2; GG := 2; BB := 1; end;
      4: begin RR := 1; GG := 2; BB := 2; end;
      5: begin RR := 2; GG := 1; BB := 2; end;
      6: begin RR := 2; GG := 1; BB := 1; end;
      7: begin RR := 1; GG := 2; BB := 1; end;
      8: begin RR := 1; GG := 1; BB := 2; end;
      9: begin RR := 2; GG := 2; BB := 4; end;
     10: begin RR := 4; GG := 2; BB := 2; end;
     11: begin RR := 2; GG := 4; BB := 2; end;
    else begin RR := 4; GG := 4; BB := 4; end;
    end;

    j := MAX_FROM_TO div 2;

    for i := -j to MAX_FROM_TO - j - 1 do
    begin
      iR := (256 div (MaxB - 1)) * (R + (RR * i) div 2);
      iG := (256 div (MaxB - 1)) * (G + (GG * i) div 2);
      iB := (256 div (MaxB - 1)) * (B + (BB * i) div 2);
      ExFromToList[j + i, 0] := iR;
      ExFromToList[j + i, 1] := iG;
      ExFromToList[j + i, 2] := iB;
      iR := LimitRGB (iR);
      iG := LimitRGB (iG);
      iB := LimitRGB (iB);
      iR := ColorMatch (iR);
      iG := ColorMatch (iG);
      iB := ColorMatch (iB);
      if (j + i) in [0..MAX_FROM_TO] then
      FromToList[j + i] := RGB (LimitRGB (iR), LimitRGB (iG), LimitRGB (iB));
    end;
  end;

  FromTo.Repaint;
end;

procedure TMainForm.SetColor (NewColor: Integer; SetFT: Boolean; AddFT: Boolean);
  var
    i: Integer;
    Found: Boolean;
begin
  Background.Pen.Style := psClear;
  Erasing := FALSE;
  ShiftErasing := FALSE;

  if AddFT then
    SetFT := FALSE;

  // don't remove palette when selecting a color with right mouse button
  if UsedColors.Visible then
  begin
    Found := FALSE;
    // is the new color in the palette?
    with UsedColorsImage.Picture.Bitmap do
      for i := 0 to Height - 1 do
        if Canvas.Pixels[0, i] = NewColor then
          Found := TRUE;
    SetFT := not Found;
  end;

  if SetFT then
  begin
    ShowRGB (NewColor);
    if Color.Brush.Color <> NewColor then
      FromToCount := 0 - Byte (Pal256);
    FromToFirst := MAX_FROM_TO div 2;
    FromToLast := MAX_FROM_TO div 2;
    if FromToCount > 0 - Byte (Pal256) then
    begin
      FromToFirst := 0;
      FromToLast := MAX_FROM_TO - 1;
    end;

    HideUsedColors;  // the new color is not in the palette
  end;
  Color.Pen.Style := psSolid;
  Color.Brush.Color := NewColor;

  Bmp.Canvas.Pen.Color := NewColor;
  DrawColor := NewColor;
  FillColor := NewColor;

  if AddFT then  // 2.51 - add colors to FT list
  begin
    if (FromToFirst = MAX_FROM_TO div 2) and
       (FromToLast = MAX_FROM_TO div 2) then
    begin
      FromToFirst := MAX_FROM_TO - 1;
      FromToLast := MAX_FROM_TO - 1;
      FromToList[FromToFirst] := NewColor;
      FromTo.Repaint;
    end
    else
      if FromToFirst <= FromToLast then
        if FromToList[FromToFirst] <> NewColor then
      begin
        if FromToFirst = 0 then
        begin
          if FromToLast < MAX_FROM_TO - 1 then
          begin
            Inc (FromToLast);
            for i := MAX_FROM_TO - 1 downto FromToFirst + 1 do
              FromToList[i] := FromToList[i - 1];
          end;
        end
        else
          Dec (FromToFirst);

        FromToList[FromToFirst] := NewColor;
        FromTo.Repaint;
      end;
  end;

  if SetFT then
  begin
    SetFromTo (FromToCount);

    i := FindCurrentColorPattern (NewColor, FALSE);
    if i = -1 then
      i := FindCurrentColorPattern (NewColor, TRUE);
    Found := i > -1;
    if Found then
    begin
      FromToSavePos := i;
      SelectSavedFromToList;

      if FindCurrentColorPattern (NewColor, FALSE) = -1 then  // to set the selection
        FindCurrentColorPattern (NewColor, TRUE);
      FromToPaint (nil);
    end;
  end;
end;

procedure TMainForm.SetBackgroundColor (NewColor: Integer; Select: Boolean);
begin
  if Select then
  begin
    ShowRGB (NewColor);
    Background.Pen.Style := psSolid;
    Color.Pen.Style := psClear;

    Bmp.Canvas.Pen.Color := TRANS_COLOR;
    DrawColor := TRANS_COLOR;
    FillColor := TRANS_COLOR;

    Erasing := TRUE;
  end;

  TileTab[Tab.TabIndex].tbr.BackGr := NewColor;

  if UsedColors.Visible then
    UsedColorsImage.Picture.Bitmap.Canvas.Pixels[0, 0] := NewColor;

  Background.Brush.Color := NewColor;
//  TileScrollBox.Color := NewColor;
  UpdateBmp (TRUE);

{
  Tile.Color := NewColor;
  DrawingBoard.Brush.Color := NewColor;
}
  pBack.Color := BackGround.Brush.Color;
  pMid.Color := BackGround.Brush.Color;
  pFront.Color := BackGround.Brush.Color;

  UpdateTileBitmap;
  Modified := TRUE;
end;

procedure TMainForm.RearrangePalette1Click(Sender: TObject);
begin
  PaletteOrder := (PaletteOrder + 1) mod MAX_PALETTE_ORDER;
  Palette.Repaint;
end;

procedure TMainForm.FromToPaint(Sender: TObject);
  var
    i, j, k, W, Y1, Y2, Y3, AH: Integer;
    Split: Boolean;
begin
  Split := SplitColorPattern1.Checked;
  W := FromTo.Width div MAX_FROM_TO;
  Y1 := 6;
  Y2 := 20 - 4 * Byte (Split);
  Y3 := 22;
  AH := 2;
  with FromTo.Canvas do
  begin
    Brush.Style := bsSolid;
    for i := 0 to MAX_FROM_TO - 1 do
    begin
      Brush.Color := FromToList[i];
      Pen.Style := psClear;
      Rectangle (i * W, Y1, (i + 1) * W + 1, Y2);
      if Split then
      begin
        Brush.Color := OtherFromTo.FT[i];
        Rectangle (i * W, Y2, (i + 1) * W + 1, Y3);
      end;
    end;
    Pen.Style := psSolid;
    Brush.Style := bsClear;
    Pen.Color := FromToPanel.Color;
    Rectangle (0, AH, MAX_FROM_TO * W, AH + 1);
    Pen.Color := clBlack;
    i := FromToFirst * W;
    j := FromToLast * W;
    k := j + W - 2;
    if i > j then
    begin
      j := FromToFirst * W;
      i := FromToLast * W;
      k := i + 2;
    end;
    Rectangle (i, AH, j + W, AH + 1);
    if FromToFirst <> FromToLast then
      Rectangle (k, AH - 1, k + 1, AH + 2);
  end;
  i := (FromToFirst + 1) * Byte (FromToFirst = FromToLast);
  ToggleMultiple1.Checked := i = 0;
  N_1.Checked := i = 1;
  N_2.Checked := i = 2;
  N_3.Checked := i = 3;
  N_4.Checked := i = 4;
  N_5.Checked := i = 5;
  N_6.Checked := i = 6;
  N_7.Checked := i = 7;
  N_8.Checked := i = 8;
  N_9.Checked := i = 9;
end;

procedure TMainForm.FromToMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
  var
    W: Integer;
begin
  W := FromTo.Width div MAX_FROM_TO;
  if Button = mbLeft then
  begin
    FromToSelect := TRUE;
    FromToFirst := X div W;
    FromToLast := FromToFirst;
  end;
  if Button = mbRight then
    FromToBackgroundSelect := TRUE;
  FromToMouseMove (Sender, Shift, X, Y);
end;

procedure TMainForm.FromToMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
  var
    W, n, k: Integer;
begin
  W := FromTo.Width div MAX_FROM_TO;
  n := X div W;
  if (n >= 0) and (n < MAX_FROM_TO) then
  begin
    k := FromToList[n];
    ShowRGB (k);
    if FromToSelect then
    begin
      SetColor (k, FALSE, FALSE);
      FromToLast := X div W;
      if FromToLast < 0 then
        FromToLast := 0;
      if FromToLast >= MAX_FROM_TO then
        FromToLast := MAX_FROM_TO - 1;
      FromTo.Repaint;
  {
      if (FromToSavePos < Length (FromToSave)) then
      begin
        FromToSave[FromToSavePos].F := FromToFirst;
        FromToSave[FromToSavePos].L := FromToLast;
      end;
  }
    end;
    if FromToBackgroundSelect then
      SetBackgroundColor (k, FALSE);
  end;
end;

procedure TMainForm.FromToMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then
    FromToSelect := FALSE;
  if Button = mbRight then
    FromToBackgroundSelect := FALSE;
end;

procedure TMainForm.ColorMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then
    if Erasing then
      SetColor (Color.Brush.Color, TRUE, FALSE)
    else
    begin
      ColorDialog.Color := Color.Brush.Color;
      if ColorDialog.Execute then
      begin
        ColorSelect := FALSE;
        SetColor (ColorDialog.Color, FALSE, FALSE);
      end;
      ShowRGB (ColorDialog.Color);
    end;
  if Button = mbRight then
    SetColor (ColorMatch (Color.Brush.Color), TRUE, FALSE);
end;

procedure TMainForm.ZoomIn1Click(Sender: TObject);
begin
  if Mode = mTile then
    if Scale < MAX_SCALE then
    begin
      Inc (Scale);
      MainForm.Resize;
    end;
  if Mode = mMap then
    if Zoom > 1 then
    begin
      Dec (Zoom);
      ZoomMap;
      UpdateMap;
    end;
  if TileSelection.Visible then
    ShowTileSelection (TRUE);
end;

procedure TMainForm.ZoomOut1Click(Sender: TObject);
begin
  if Mode = mTile then
    if Scale > 1 then
    begin
      Dec (Scale);
      MainForm.Resize;
    end;
  if Mode = mMap then
    if Zoom < MAX_ZOOM then
    begin
      Inc (Zoom);
      ZoomMap;
      UpdateMap;
    end;
  if TileSelection.Visible then
    ShowTileSelection (TRUE);
end;

function IntStr (x: Integer): string;
  var
    bin: array[0..SizeOf (Integer) - 1] of Char absolute x;
    s: string;
    i: Integer;
begin
  s := '';
  for i := 0 to SizeOf (Integer) - 1 do
    s := s + bin[i];
  IntStr := s;
end;

function StrInt (s: string): Integer;
  var
    x: Integer;
    bin: array[0..SizeOf (Integer) - 1] of Char absolute x;
    i: Integer;
begin
  for i := 0 to SizeOf (Integer) - 1 do
    bin[i] := s[i + 1];
  StrInt := x;
end;

function ActName (dt: TDrawingTool): string;
begin
  case dt of
    dtBrush:             ActName := 'Brush';
    dtLine:              ActName := 'Line';
    dtRect,
    dtFilledRect:        ActName := 'Rectangle';
    dtRoundRect,
    dtFilledRoundRect:   ActName := 'Round Rectangle';
    dtEllipse,
    dtFilledEllipse:     ActName := 'Ellipse';
    dtFill:              ActName := 'Flood Fill';
  else
    ActName := 'Drawing';
  end;
end;

procedure TMainForm.TileMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
  var
    xp, yp: Integer;
begin
  Busy := TRUE;
  LastShift := Shift;
  LastButton := Button;
  GradientH := FALSE;
  GradientV := FALSE;
  GradientD := FALSE;

  Horizontal3.Enabled := TRUE;
  Vertical3.Enabled := TRUE;
  Diagonal1.Enabled := TRUE;
  Horizontal3.Checked := FALSE;
  Vertical3.Checked := FALSE;
  Diagonal1.Checked := FALSE;

  LastX := X;
  LastY := Y;
  ShiftState := Shift;
  xp := X div Scale;
  yp := Y div Scale;
  if (Button = mbLeft) then
  begin
    if DrawingTool in FirstSaveUndoTools then
      SaveUndo (ActName (DrawingTool));
    if  (ssShift in ShiftState) or
       LightButton.Down or
       DarkButton.Down or
       PlusButton.Down or
       RandomButton.Down then
        SaveTempBmp;
    Drawing := TRUE;
    LineList := '';
    Bmp.Canvas.MoveTo (xp, yp);
    Origin := Point (xp, yp);
    CurPos := Origin;
    OrigColor := Bmp.Canvas.Pixels[xp, yp];
    Bmp.Canvas.Pen.Color := DrawColor;
    if Bmp.Canvas.Brush.Style = bsSolid then
      Bmp.Canvas.Brush.Color := FillColor;
    Modified := TRUE;
  end;
  if Button = mbRight then
    if (ssShift in ShiftState) then
    begin
      SaveUndo ('Erase');
      ShiftErasing := TRUE;
      Bmp.Canvas.MoveTo (xp, yp);
      Origin := Point (xp, yp);
      CurPos := Origin;
      Bmp.Canvas.Pen.Color := TRANS_COLOR;
      Modified := TRUE;
    end
    else
      ReadingColor := TRUE;
  if not (Erasing or ShiftErasing) then
    if  (ssShift in ShiftState) or
       LightButton.Down or
       DarkButton.Down or
       PlusButton.Down or
       RandomButton.Down then
    begin
      if DarkButton.Down then
        SpecialColor := SPECIAL_COLOR1
      else
        if LightButton.Down then
          SpecialColor := SPECIAL_COLOR2
        else
          SpecialColor := $FFFFFF - BackGround.Brush.Color and $FFFFFF;
      Bmp.Canvas.Pen.Color := SpecialColor;
      if Bmp.Canvas.Brush.Style = bsSolid then
        Bmp.Canvas.Brush.Color := SpecialColor;
    end;
  TileMouseMove (Sender, Shift, X, Y);
  Busy := FALSE;
end;

procedure TMainForm.TileMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
  var
    i, j, k, l, m, n, o, p, xx, yy: Integer;
    R, G, B, RR, GG, BB: Integer;
    cm: Boolean;
    Ex: Boolean;
    RX, RY, NS: Real;
    RndX, RndY: Integer;

begin
  Busy := TRUE;
  LastShift := Shift;
  LastButton := Button;
  LastX := X;
  LastY := Y;
  Ex := FALSE;
  if Button = mbLeft then
    if Drawing then
    begin
      if not (DrawingTool in FirstSaveUndoTools) then
        SaveUndo (ActName (DrawingTool));
      DrawFTShape (Origin.X, Origin.Y, CurPos.X, CurPos.Y, Bmp.Canvas);
      SaveHistoryCoords (Origin.X - BORDER_W, Origin.Y - BORDER_H, CurPos.X - BORDER_W, CurPos.Y - BORDER_H);
      Undo[UndoPos].HistoryCoords := HistoryListBox.Items[HistoryListBox.Items.Count - 1];  // 3.00
      AddColorPattern1Click (Sender);
      Drawing := FALSE;
    end;
  if Button = mbRight then
  begin
    ReadingColor := FALSE;
    ShiftErasing := FALSE;
  end;
  if (ssShift in ShiftState) or
     LightButton.Down or
     DarkButton.Down or
     PlusButton.Down or
     RandomButton.Down then
  begin
    l := 256 div (MaxRGB - 1);

  //  NoiseSizeX := W div LineTool.Height;  // 2.43
  //  NoiseSizeY := H div LineTool.Height;
  //  if NoiseSizeX < 2 then NoiseSizeX := 2;
  //  if NoiseSizeY < 2 then NoiseSizeY := 2;
    RndX := Random (1000);
    RndY := Random (1000);

    if RandomButton.Down then
    begin
      for j := BORDER_H - 1 to BORDER_H + H + 1 do
        for i := BORDER_W - 1 to BORDER_W + W + 1 do
          with TempBmp.Canvas do
          begin
            RX := RndX + i * (15 - LineTool.Height);
            RY := RndY + j * (15 - LineTool.Height);
            NS := Noise2 (RX / W, RY / H);

            n := Abs (FromToLast - FromToFirst);
            m := Byte (FromToLast > FromToFirst) - Byte (FromToFirst > FromToLast);
            k := Pixels[i, j];
            if (n = 0) xor (ssCtrl in ShiftState) then
            begin
              if k <> TRANS_COLOR then
              begin
                GetRGB (k, R, G, B);
                if ssShift in ShiftState then
                begin
                  if UseOldNoiseFunctions1.Checked then
                    m := l * (Random (3) - 1)
                  else
                    m := Round (System.Int (l * (2 * NS - 1)))
                end
                else
                  m := 0;  { smooth }
                Pixels[i, j] := RGB (LimitRGB (R + m), LimitRGB (G + m), LimitRGB (B + m));
              end;
            end
            else
            //  Pixels[i, j] := FromToList[FromToFirst + m * Random (n + 1)];
            begin
              Ex := TRUE;
              if UseOldNoiseFunctions1.Checked then
                p := FromToFirst + m * Random (n + 1)
              else
                p := Round (System.Int (FromToFirst + m * NS * (n + 1)));
              R := ExFromToList[p, 0] div 4 + 96;
              G := ExFromToList[p, 1] div 4 + 96;
              B := ExFromToList[p, 2] div 4 + 96;
              Pixels[i, j] := RGB (LimitRGB (R), LimitRGB (G), LimitRGB (B));
            end;
          end;
    end;

    for j := BORDER_H to BORDER_H + H do
      for i := BORDER_W to BORDER_W + W do
      begin
        k := Bmp.Canvas.Pixels[i, j];
        if k = SpecialColor then
        begin
          k := TempBmp.Canvas.Pixels[i, j];
          if RandomButton.Down then
          begin
            if k <> TRANS_COLOR then
            begin
              n := 2 + 6 * Byte ((ssAlt in ShiftState) or (RealTimeLightening1.Checked));
              o := n;
              GetRGB (k, RR, GG, BB);
              RR := n * RR;
              GG := n * GG;
              BB := n * BB;

              for n := -1 to 1 do
                for m := -1 to 1 do
                begin
                  xx := i + m;
                  yy := j + n;
                  if xx < BORDER_W then
                    Inc (xx, W)
                  else if xx >= W + BORDER_W then
                    Dec (xx, W);
                  if yy < BORDER_H then
                    Inc (yy, H)
                  else if yy >= H + BORDER_H then
                    Dec (yy, H);
                  p := TempBmp.Canvas.Pixels[xx, yy];
                  if p <> TRANS_COLOR then
                  begin
                    GetRGB (p, R, G, B);
                    Inc (RR, R);
                    Inc (GG, G);
                    Inc (BB, B);
                    Inc (o);
                  end;
                end;
              RR := RR div o;
              GG := GG div o;
              BB := BB div o;
              if Ex then
              begin
                RR := (RR - 96) * 4;
                GG := (GG - 96) * 4;
                BB := (BB - 96) * 4;
              end;
              R := LimitRGB (RR);
              G := LimitRGB (GG);
              B := LimitRGB (BB);
              k := RGB (R, G, B);
            end;
          end
          else
          begin
            if k = TRANS_COLOR then
              k := DrawColor
            else
            begin
              if PlusButton.Down then
              begin
                if (ssAlt in ShiftState) or (RealTimeLightening1.Checked) then
                  k := ColorBetween (k, ColorBetween (k, ColorBetween (k, Color.Brush.Color)))
                else
                  k := ColorBetween (k, Color.Brush.Color);
              end
              else
              begin
                p := 1 + 5 * Byte ((ssAlt in ShiftState) or (RealTimeLightening1.Checked));
                cm := k = ColorMatch (k);
                GetRGB (k, R, G, B);
                if LightButton.Down then
                  k := RGB (LimitRGB (R + l div p), LimitRGB (G + l div p), LimitRGB (B + l div p))
                else
                  k := RGB (LimitRGB (R - l div p), LimitRGB (G - l div p), LimitRGB (B - l div p));
                if cm and (p = 1) then
                  k := ColorMatch (k);
              end;
            end;
          end;
          Bmp.Canvas.Pixels[i, j] := k;
        end;
      end;
  end;

  Horizontal3.Checked := FALSE;
  Vertical3.Checked := FALSE;
  Diagonal1.Checked := FALSE;
  Horizontal3.Enabled := FALSE;
  Vertical3.Enabled := FALSE;
  Diagonal1.Enabled := FALSE;

  UpdateBmp (TRUE);
  Busy := FALSE;
end;

procedure TMainForm.TileMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
  var
    xp, yp, c: Integer;
    i, j, k, l: Integer;
begin
  Busy := TRUE;
  LastShift := Shift;
  LastX := X;
  LastY := Y;
  xp := X div Scale;
  yp := Y div Scale;

  i := xp - BORDER_W;
  j := yp - BORDER_H;
  if (i >= 0) and (i < W) and
     (j >= 0) and (j < H) then
    ShowRGB (Bmp.Canvas.Pixels[xp, yp])
  else
    ShowRGB (TRANS_COLOR);

  StatusBar.Panels[1].Text := Format ('(%d, %d)', [i, j]);
  ShowOrigin := Drawing and (DrawingTool in [dtLine, dtRect,
       dtRoundRect, dtEllipse, dtFilledRect,
       dtFilledRoundRect, dtFilledEllipse, dtSelection]);
  if ShowOrigin then
  begin
    k := Origin.x - BORDER_W;
    l := Origin.y - BORDER_H;
    StatusBar.Panels[1].Text := Format ('(%d, %d)-', [k, l]) +
        StatusBar.Panels[1].Text +
           Format (' [%d, %d]', [Abs (k - i), Abs (l - j)]);   // 2.5
  end;

  if ReadingColor then
  begin
   { i := FromToFirst;
    j := FromToLast; }
    c := Bmp.Canvas.Pixels[xp, yp];
    if c = TRANS_COLOR then
      SetBackgroundColor (Background.Brush.Color, TRUE)
    else
    begin
      SetColor (c, TRUE, ssCtrl in LastShift);
    {
      if ssCtrl in LastShift then
      begin
        FromToFirst := i;     // 2.2
        FromToLast := j;
        FromToPaint (Sender);
      end; }  // 2.51 - removed, now use Ctrl to add to FT selection
    end;
  end;

  if Drawing then
  begin
    case DrawingTool of
      dtFill:
        begin
          for i := -1 to W do
          begin
            Bmp.Canvas.Pixels[BORDER_W + i, BORDER_H - 1] := TRANS_COLOR;
            Bmp.Canvas.Pixels[BORDER_W + i, BORDER_H + H] := TRANS_COLOR;
          end;
          for j := -1 to H do
          begin
            Bmp.Canvas.Pixels[BORDER_W - 1, BORDER_H + j] := TRANS_COLOR;
            Bmp.Canvas.Pixels[BORDER_W + W, BORDER_H + j] := TRANS_COLOR;
          end;

          if ssCtrl in LastShift then  // 2.53 - replace color in tile
          begin
            k := Bmp.Canvas.Pixels[xp, yp];
            for j := 0 to H - 1 do
              for i := 0 to W - 1 do
                if Bmp.Canvas.Pixels[BORDER_W + i, BORDER_H + j] = k then
                  Bmp.Canvas.Pixels[BORDER_W + i, BORDER_H + j] := Bmp.Canvas.Pen.Color;
          end
          else
            Bmp.Canvas.FloodFill (xp, yp, Bmp.Canvas.Pixels[xp, yp], fsSurface);
        end;
      dtPoint:
        begin
          Bmp.Canvas.Pixels[xp, yp] := Bmp.Canvas.Pen.Color;
          Bmp.Canvas.LineTo (xp, yp);
          CurPos := Point (xp, yp);
        end;
      dtBrush:
        begin
          if (ssAlt in ShiftState) or (FromToFirst = FromToLast) then
          begin
            Bmp.Canvas.Pixels[xp, yp] := Bmp.Canvas.Pen.Color;
            Bmp.Canvas.LineTo (xp, yp);
          end
          else
            DrawFTCircle (BMP.Canvas, xp, yp, ssShift in ShiftState);
          if DrawingTool = dtBrush then
            if (CurPos.x <> xp) or (CurPos.y <> y) or (LineList = '') then
              LineList := LineList + IntStr (xp) + IntStr (yp);
          CurPos := Point (xp, yp);
        end;
      else
        begin
          CurPos := Point (xp, yp);
          DrawingShape := TRUE;
        end;
    end;
    UpdateBmp (FALSE);
  end;
  if ShiftErasing then
  begin
    Bmp.Canvas.Pixels[xp, yp] := TRANS_COLOR;
    Bmp.Canvas.LineTo (xp, yp);
    CurPos := Point (xp, yp);
    UpdateBmp (FALSE);
  end;
  Busy := FALSE;
end;

procedure TMainForm.ShowTileSelection (Clip: Boolean);
  var
    X1, Y1, X2, Y2: Integer;
begin
  X1 := TileSelX1;
  Y1 := TileSelY1;
  X2 := TileSelX2;
  Y2 := TileSelY2;

  if Clip then
  begin
    if X1 - BORDER_W < 0 then X1 := BORDER_W;
    if Y1 - BORDER_H < 0 then Y1 := BORDER_H;
    if X2 - BORDER_W > W then X2 := W + BORDER_W;
    if Y2 - BORDER_H > H then Y2 := H + BORDER_H;

    if X2 - BORDER_W < 0 then X2 := BORDER_W;
    if Y2 - BORDER_H < 0 then Y2 := BORDER_H;
    if X1 - BORDER_W > W then X1 := W + BORDER_W;
    if Y1 - BORDER_H > H then Y1 := H + BORDER_H;

    TileSelX1 := X1;
    TileSelY1 := Y1;
    TileSelX2 := X2;
    TileSelY2 := Y2;
  end;

  with TileSelection do
  begin
    Left := X1 * Scale + Tile.Left;
    Top := Y1 * Scale + Tile.Top;
    Width := (X2 - X1) * Scale;
    Height := (Y2 - Y1) * Scale;
    Visible := TRUE;
  end;
end;


procedure TMainForm.SwapInt (var x, y: Integer);
  var
    i: Integer;
begin
  i := x;
  x := y;
  y := i;
end;

function TMainForm.ColorPerc (RGB1, RGB2, Perc2, MaxPerc: Integer): Integer;
  var
    R1, G1, B1: Integer;
    R2, G2, B2: Integer;
    C: Integer;
    Perc1: Integer;
begin
  GetRGB (RGB1, R1, G1, B1);
  GetRGB (RGB2, R2, G2, B2);
  Perc1 := MaxPerc - Perc2;
  C := MakePalRGB ((R1 * Perc1 + R2 * Perc2) div MaxPerc,
                   (G1 * Perc1 + G2 * Perc2) div MaxPerc,
                   (B1 * Perc1 + B2 * Perc2) div MaxPerc, 0);
  ColorPerc := C;
end;

function TMainForm.ColorPercFT (i1, i2, Perc2, MaxPerc: Integer): Integer;
  var
    Perc1: Integer;
    N: Integer;
    c1, c2, p1, p2: Integer;
begin
  Perc1 := MaxPerc - Perc2;
  if i1 > i2 then
  begin
    SwapInt (i1, i2);
    SwapInt (Perc1, Perc2);
  end;
  Inc (Perc1);  // 2.43 bug fix: range check error

 // MainForm.Caption := Format (' %d %d    %d %d %d ', [i1, i2, perc1, perc2, maxperc]);

  N := i2 - i1;
  c1 := i1 + N * Perc2 div MaxPerc;
  c2 := c1 + 1;
  p1 := (100 * N * Perc2 div MaxPerc) mod 100;
  p2 := 100;
  if (c1 < Low (FromToList)) then
    c1 := Low (FromToList);
  if (c2 > High (FromToList)) then
    c2 := High (FromToList);
  ColorPercFT := ColorPerc (FromToList[c1], FromToList[c2], p1, p2);
end;

procedure TMainForm.DrawFTShape (X1, Y1, X2, Y2: Integer; C: TCanvas);
  var
    i, j, k, l, M, N, o, p, x, y: Integer;
    oi, pi: Integer;
    OrigX1, OrigX2, OrigY1, OrigY2: Integer;
    sh, alt, ctrl: Boolean;
    found: Boolean;
    OColor: Integer;

begin
  OrigX1 := X1;
  OrigX2 := X2;
  OrigY1 := Y1;
  OrigY2 := Y2;
  sh := ssShift in ShiftState;
  alt := ssAlt in ShiftState;
  ctrl := ssCtrl in ShiftState;

  if DrawingTool in [dtRect, dtRoundRect, dtEllipse,
     dtFilledRect, dtFilledRoundRect, dtFilledEllipse] then
  begin
    if X2 >= X1 then Inc (X2) else Inc (X1);
    if Y2 >= Y1 then Inc (Y2) else Inc (Y1);
  end;

  with TileSelection do
    if (DrawingTool in [dtSelection]) and
       (not ((X1 = X2) and (Y1 = Y2))) then
    begin
      if X1 > X2 then begin i := X1; X1 := X2; X2 := i; end;
      if Y1 > Y2 then begin i := Y1; Y1 := Y2; Y2 := i; end;
      TileSelX1 := X1;
      TileSelY1 := Y1;
      TileSelX2 := X2;
      TileSelY2 := Y2;
      ShowTileSelection (TRUE);
    end
    else
      Visible := FALSE;

  N := Byte (FromToLast > FromToFirst) -
       Byte (FromToLast < FromToFirst);
  if Erasing or
     LightButton.Down or
     DarkButton.Down or
     PlusButton.Down or
     RandomButton.Down or
     (N = 0) or
     (not (DrawingTool in [dtPoint,
                           dtBrush,
                           dtFilledRect,
                           dtFilledRoundRect,
                           dtFilledEllipse])) then
    DrawShape (X1, Y1, X2, Y2, C)
  else
  begin
    if X1 > X2 then begin i := X1; X1 := X2; X2 := i; end;
    if Y1 > Y2 then begin i := Y1; Y1 := Y2; Y2 := i; end;
    i := FromToFirst;

    if (DrawingTool in [dtPoint, dtBrush]) and Alt then        {  ***  }
    begin
      M := Length (LineList) div (2 * SizeOf (Integer));

      for j := 0 to M - 1 do
      begin

        if SmoothPalette1.Checked then
        begin
          if Ctrl then
          begin
            OColor := OrigColor;
            if OColor = TRANS_COLOR then
              OColor := Background.Brush.Color;  // 2.43
            o := ColorPerc (OColor, FromToList[FromToLast], j, M);
          end
          else
          begin
            oi := FromToFirst;
            pi := FromToLast;
            o := ColorPercFT (oi, pi, j, M);
          end;
        end
        else
        begin
          if M - 1 = 0 then
            i := FromToLast
          else
            i := FromToFirst + (j * Abs (FromToLast - FromToFirst) div (M - 1)) * N;
          o := FromToList[i];
        end;

        C.Pen.Color := o;
        C.Brush.Color := o;

        x := StrInt (Copy (LineList, 1, SizeOf (Integer)));
        Delete (LineList, 1, SizeOf (Integer));
        y := StrInt (Copy (LineList, 1, SizeOf (Integer)));
        Delete (LineList, 1, SizeOf (Integer));
        if j = 0 then
          C.MoveTo (x, y)
        else
          C.LineTo (x, y);
      end;

    end
    else
      if Ctrl or GradientH or GradientV or GradientD then
      begin
        if not (GradientH or GradientV or GradientD) then
          GradientD := TRUE;

        SaveTempBmp;

        with TempBmp.Canvas do
        begin
          Pen.Color := SpecialColor;
          Brush.Color := SpecialColor;
        end;

        DrawShape (X1, Y1, X2, Y2, TempBmp.Canvas);

        k := 0;
        l := 1;
        for y := Y1 - 1 to Y2 + 1 do
          for x := X1 - 1 to X2 + 1 do
          begin
            if TempBmp.Canvas.Pixels[x, y] = SpecialColor then
            begin
              TempBmp.Canvas.Pixels[x, y] := C.Pixels[x, y];
              if Ctrl then
              begin
                oi := -1;
                o := C.Pixels[x, y];
                if o = TRANS_COLOR then
                  o := BackGround.Brush.Color;
              end
              else
              begin
                oi := FromToFirst;
                o := FromToList[oi];
              end;
              pi := FromToLast;
              p := FromToList[pi];
              if GradientH then
              begin
                k := x - X1;
                l := X2 - X1;
              end;
              if GradientV then
              begin
                k := y - Y1;
                l := Y2 - Y1;
              end;
              if GradientD then
              begin
                if OrigX1 > OrigX2 then
                  k := Abs (X2 - x)
                else
                  k := Abs (x - X1);
                if OrigY1 > OrigY2 then
                  Inc (k, Abs (Y2 - y))
                else
                  Inc (k, Abs (y - Y1));
                l := Abs (X2 - X1) + Abs (Y2 - Y1);
              end;
              if (GradientH and (OrigX1 > OrigX2)) or
                 (GradientV and (OrigY1 > OrigY2)) then
              begin
                SwapInt (oi, pi);
                SwapInt (o, p);
              end;
              if (oi >= 0) and (pi >= 0) then
              begin
                C.Pixels[x, y] := ColorPercFT (oi, pi, Abs (k), Abs (l));
              end
              else
                C.Pixels[x, y] := ColorPerc (o, p, Abs (k), Abs (l));
            end;
          end;


      end
      else
      repeat           { draw filled shape (outside -> inside) }
        if sh then
        begin
          C.Pen.Color := SpecialColor;
          C.Brush.Color := SpecialColor;
          SaveTempBmp;
        end
        else
        begin
          C.Pen.Color := FromToList[i];
          C.Brush.Color := FromToList[i];
        end;
        DrawShape (X1, Y1, X2, Y2, C);

        if sh then
        begin
          for y := Y1 - LineTool.Height to Y2 + LineTool.Height do     // 2.44
            for x := X1 - LineTool.Height to X2 + LineTool.Height do
            begin
              if Bmp.Canvas.Pixels[x, y] = SpecialColor then
              begin
                found := FALSE;
                k := i;
                repeat
                  if TempBmp.Canvas.Pixels[x, y] = FromToList[k] then
                    found := TRUE;
                  k := k + N;
                until ((N < 0) and (k - N = 0))
                   or ((N > 0) and (k - N = MAX_FROM_TO - 1));
                if not Found then
                  Bmp.Canvas.Pixels[x, y] := FromToList[i]
                else
                  Bmp.Canvas.Pixels[x, y] := TempBmp.Canvas.Pixels[x, y];
              end;

            end;
        end;

        // 2.44
        if not ((XShade < 0) and (i mod (3 - Abs (XShade)) = 0)) then
          Inc (X1, LineTool.Height);
        if not ((YShade < 0) and (i mod (3 - Abs (YShade)) = 0)) then
          Inc (Y1, LineTool.Height);
        if not ((XShade > 0) and (i mod (3 - Abs (XShade)) = 0)) then
          Dec (X2, LineTool.Height);
        if not ((YShade > 0) and (i mod (3 - Abs (YShade)) = 0)) then
          Dec (Y2, LineTool.Height);
        i := i + N;
      until (X1 >= X2) or (Y1 >= Y2) or (i - N = FromToLast);
    C.Pen.Color := Color.Brush.Color;
    C.Brush.Color := Color.Brush.Color;
  end;
end;

procedure TMainForm.DrawFTCircle (C: TCanvas; xp, yp: Integer; Shift: Boolean);
  var
    x, y, x1, y1, x2, y2: Integer;
    d: Real;
    N: Integer;
    i, k: Integer;
    Found: Boolean;
begin
  N := Byte (FromToLast > FromToFirst) -
       Byte (FromToLast < FromToFirst);

  x1 := xp - C.Pen.Width;
  y1 := yp - C.Pen.Width;
  x2 := xp + C.Pen.Width;
  y2 := yp + C.Pen.Width;

  for y := Y1 to Y2 do
    for x := X1 to X2 do
    begin
      d := 1 + (Sqrt (Sqr (x - xp) + Sqr (y - yp)));
      if d < (C.Pen.Width + 1) then
      begin
        d := 1 + (Sqrt (Sqr (x - xp - XShade) + Sqr (y - yp - YShade)));   // 2.44
        if d > C.Pen.Width then
          d := C.Pen.Width;
        i := FromToFirst + N * (C.Pen.Width - Round (System.Int (d)));
        if ((N < 0) and (i < FromToLast)) or
           ((N > 0) and (i > FromToLast)) then
             i := FromToLast;

        Found := FALSE;
        k := i;
        if N <> 0 then
        repeat
          if C.Pixels[x, y] = FromToList[k] then
            Found := TRUE;
          k := k + N;
        until ((N < 0) and (k - N <= 0))
           or ((N > 0) and (k - N >= MAX_FROM_TO - 1));

        if (Shift) or (not Found) then
          C.Pixels[x, y] := FromToList[i];
      end;
    end;

end;

procedure TMainForm.DrawShape (X1, Y1, X2, Y2: Integer; C: TCanvas);
  var
    DX, DY: Integer;

begin
  with C do
  begin
    case DrawingTool of
      dtLine:
        begin
          MoveTo (X1, Y1);
          LineTo (X2, Y2);
        end;
      dtRect,
      dtFilledRect:
        Rectangle (X1, Y1, X2, Y2);
      dtRoundRect,
      dtFilledRoundRect:
        RoundRect (X1, Y1, X2, Y2,
                  (X1 - X2) div 2, (Y1 - Y2) div 2); 
       { Polybezier ([Point (X1, Y1), Point (X2, Y1), Point (X2, Y2), Point (X1, Y2)]); }
       {  Arc (X1, Y1, X2, Y2, curpos.X, curpos.Y, origin.X, origin.Y); }
       {
         begin
           DX := X2 - X1;
           DY := Y2 - Y1;
           if CurPos.Y > Origin.Y then
             if CurPos.X > Origin.X then
               Polybezier ([Point (X1, Y1), Point (X2, Y1), Point (X2, Y2), Point (X1, Y1)])
             else
               Polybezier ([Point (X2, Y1), Point (X1, Y1), Point (X1, Y2), Point (X2, Y1)])
           else
             if CurPos.X > Origin.X then
               Polybezier ([Point (X1, Y2), Point (X2, Y2), Point (X2, Y1), Point (X1, Y2)])
             else
               Polybezier ([Point (X2, Y2), Point (X1, Y2), Point (X1, Y1), Point (X2, Y2)])

         end;
       }


      dtEllipse,
      dtFilledEllipse:
        Ellipse (X1, Y1, X2, Y2);
    end;
  end;
end;

procedure TMainForm.SetDrawingTool(Sender: TObject);
begin
{
  if DrawingTool = dtSelection then
  begin
    SaveUndo ('Drop Selection');
    UpdateBmp (TRUE);
    Modified := TRUE;
  end;
}
  Bmp.Canvas.Brush.Style := bsClear;

  if Sender = SelectionButton then
    ShowTileSelection (TRUE)
  else
    TileSelection.Visible := FALSE;

  if (Sender = PencilButton) or
     (Sender = BrushButton) then
    Tile.Cursor := crDefault
  else
    Tile.Cursor := crCross;

  LineSize[DrawingTool] := LineTool.Height;   // 2.43

  if (Sender = LineButton) or
     (Sender = RectButton) or
     (Sender = RoundRectButton) or
     (Sender = EllipseButton) or
     (Sender = BrushButton) then
  begin
    LineTool.Brush.Color := clBlack;
    LineTool.Pen.Color := clBlack;
    Bmp.Canvas.Pen.Width := LineTool.Height;
    VisualBmp.Canvas.Pen.Width := LineTool.Height;
  end
  else
  begin
    LineTool.Brush.Color := clGray;
    LineTool.Pen.Color := clGray;
    Bmp.Canvas.Pen.Width := 1;
    VisualBmp.Canvas.Pen.Width := 1;
  end;

  if Sender = PencilButton then
    DrawingTool := dtPoint
  else
  begin
    if Sender = BrushButton then
      DrawingTool := dtBrush
    else
      if Sender = LineButton then
        DrawingTool := dtLine
      else
        if Sender = RectButton then
          DrawingTool := dtRect
        else
          if Sender = RoundRectButton then
            DrawingTool := dtRoundRect
          else
            if Sender = EllipseButton then
              DrawingTool := dtEllipse
            else
            begin
              Bmp.Canvas.Brush.Style := bsSolid;
              Bmp.Canvas.Brush.Color := FillColor;
              if Sender = FillButton then
                DrawingTool := dtFill
              else
                if Sender = FilledRectButton then
                  DrawingTool := dtFilledRect
                else
                  if Sender = FilledRoundRectButton then
                    DrawingTool := dtFilledRoundRect
                  else
                    if Sender = FilledEllipseButton then
                      DrawingTool := dtFilledEllipse
                    else
                      if Sender = SelectionButton then
                        DrawingTool := dtSelection;
            end;
  end;

  LineTool.Height := LineSize[DrawingTool];   // 2.43
  LineToolMouseDown(nil, mbMiddle, [], 0, 0);
end;

procedure TMainForm.GetTileArea;
begin
  TileAreaX := BORDER_W;
  TileAreaY := BORDER_H;
  TileAreaW := W;
  TileAreaH := H;
  if TileSelection.Visible then
  begin
    TileAreaX := TileSelX1;
    TileAreaY := TileSelY1;
    TileAreaW := TileSelX2 - TileSelX1;
    TileAreaH := TileSelY2 - TileSelY1;
  end;
end;

procedure TMainForm.Up1Click(Sender: TObject);
  var
    i, j, k, x, y: Integer;
    b: Boolean;
begin
  GetTileArea;
  with Bmp.Canvas do
  begin
    x := TileAreaX;
    for i := 0 to TileAreaW - 1 do
    begin
      y := TileAreaY;
      k := Pixels[x, y];
      for j := 0 to TileAreaH - 2 do
        Pixels[x, y + j] := Pixels[x, y + j + 1];
      Pixels[x, y + TileAreaH - 1] := k;
      Inc (x);
    end;
  end;

  b := UseAsAlphaChannel1.Enabled;
  UseAsAlphaChannel1.Enabled := FALSE;
  UpdateBmp (TRUE);
  UseAsAlphaChannel1.Enabled := b;

  Modified := TRUE;
end;

procedure TMainForm.Down1Click(Sender: TObject);
  var
    i, j, k, x, y: Integer;
    b: Boolean;
begin
  GetTileArea;
  with Bmp.Canvas do
  begin
    x := TileAreaX;
    for i := 0 to TileAreaW - 1 do
    begin
      y := TileAreaY;
      k := Pixels[x, y + TileAreaH - 1];
      for j := TileAreaH - 1 downto 1 do
        Pixels[x, y + j] := Pixels[x, y + j - 1];
      Pixels[x, y] := k;
      Inc (x);
    end;
  end;

  b := UseAsAlphaChannel1.Enabled;
  UseAsAlphaChannel1.Enabled := FALSE;
  UpdateBmp (TRUE);
  UseAsAlphaChannel1.Enabled := b;

  Modified := TRUE;
end;

procedure TMainForm.Left1Click(Sender: TObject);
  var
    i, j, k, x, y: Integer;
    b: Boolean;
begin
  GetTileArea;
  with Bmp.Canvas do
  begin
    y := TileAreaY;
    for j := 0 to TileAreaH - 1 do
    begin
      x := TileAreaX;
      k := Pixels[x, y];
      for i := 0 to TileAreaW - 2 do
        Pixels[x + i, y] := Pixels[x + i + 1, y];
      Pixels[x + TileAreaW - 1, y] := k;
      Inc (y);
    end;
  end;

  b := UseAsAlphaChannel1.Enabled;
  UseAsAlphaChannel1.Enabled := FALSE;
  UpdateBmp (TRUE);
  UseAsAlphaChannel1.Enabled := b;

  Modified := TRUE;
end;

procedure TMainForm.Right1Click(Sender: TObject);
  var
    i, j, k, x, y: Integer;
    b: Boolean;
begin
  GetTileArea;
  with Bmp.Canvas do
  begin
    y := TileAreaY;
    for j := 0 to TileAreaH - 1 do
    begin
      x := TileAreaX;
      k := Pixels[x + TileAreaW - 1, y];
      for i := TileAreaW - 1 downto 1 do
        Pixels[x + i, y] := Pixels[x + i - 1, y];
      Pixels[x, y] := k;
      Inc (y);
    end;
  end;

  b := UseAsAlphaChannel1.Enabled;
  UseAsAlphaChannel1.Enabled := FALSE;
  UpdateBmp (TRUE);
  UseAsAlphaChannel1.Enabled := b;

  Modified := TRUE;
end;

procedure TMainForm.HFlipBounds;
  var
    b1, b2: Boolean;
begin
  if Bounds <> 0 then
  begin
   // if Bounds < $10 then
    if ShortInt (Bounds) > 0 then  // 2.55
    begin
      b1 := Bounds and $2 <> 0;
      b2 := Bounds and $8 <> 0;
      Bounds := Bounds and (not ($2 or $8));
      Bounds := Bounds or ((Byte(b1) shl 3) or (Byte(b2) shl 1));
    end
    else
      Bounds := Bounds xor 1;
    BoundBox.RePaint;
    Modified := TRUE;
  end;
end;

procedure TMainForm.RotateBounds (var Bounds: Integer; deg: Integer);  // 2.5
  var
    b0, b1, b2, b3: Boolean;
begin
  if Bounds <> 0 then
  begin
   // if Bounds < $10 then
    if ShortInt (Bounds) > 0 then  // 2.55
    begin
      b0 := Bounds and $1 <> 0;
      b1 := Bounds and $2 <> 0;
      b2 := Bounds and $4 <> 0;
      b3 := Bounds and $8 <> 0;
      Bounds := Bounds and (not ($F));
      if deg > 0 then  { rotate left }
        Bounds := Bounds or (Byte(b0) shl 1) or (Byte(b1) shl 2) or (Byte(b2) shl 3) or (Byte(b3) shl 0)
      else
        Bounds := Bounds or (Byte(b0) shl 3) or (Byte(b1) shl 0) or (Byte(b2) shl 1) or (Byte(b3) shl 2);
    end
    else
      Bounds := Bounds xor 1;  { diagonal bounds, only 45 degrees so far }
    BoundBox.RePaint;
    Modified := TRUE;
  end;
end;

procedure TMainForm.Horizontal1Click(Sender: TObject);
  var
    i, j, k, x, y: Integer;
    b: Boolean;
begin
  SaveUndo ('Flip Horizontal');
  GetTileArea;
  with Bmp.Canvas do
  begin
    y := TileAreaY;
    for j := 0 to TileAreaH - 1 do
    begin
      x := TileAreaX;
      for i := 0 to TileAreaW div 2 - 1 do
      begin
        k := Pixels[x + i, y];
        Pixels[x + i, y] := Pixels[x + TileAreaW - 1 - i, y];
        Pixels[x + TileAreaW - 1 - i, y] := k;
      end;
      Inc (y);
    end;
  end;
  if not TileSelection.Visible then
    HFlipBounds (Bounds);

  b := UseAsAlphaChannel1.Enabled;
  UseAsAlphaChannel1.Enabled := FALSE;
  UpdateBmp (TRUE);
  UseAsAlphaChannel1.Enabled := b;
end;

procedure TMainForm.VFlipBounds;
  var
    b1, b2: Boolean;
begin
  if Bounds <> 0 then
  begin
   // if Bounds < $10 then
    if ShortInt (Bounds) > 0 then  // 2.55
    begin
      b1 := Bounds and $1 <> 0;
      b2 := Bounds and $4 <> 0;
      Bounds := Bounds and (not ($1 or $4));
      Bounds := Bounds or ((Byte(b1) shl 2) or (Byte(b2) shl 0));
    end
    else
      Bounds := Bounds xor 1;
    BoundBox.RePaint;
    Modified := TRUE;
  end;
end;

procedure TMainForm.Vertical1Click(Sender: TObject);
  var
    i, j, k, x, y: Integer;
    b: Boolean;
begin
  SaveUndo ('Flip Vertical');

  GetTileArea;
  with Bmp.Canvas do
  begin
    x := TileAreaX;
    for i := 0 to TileAreaW - 1 do
    begin
      y := TileAreaY;
      for j := 0 to TileAreaH div 2 - 1 do
      begin
        k := Pixels[x, y + j];
        Pixels[x, y + j] := Pixels[x, y + TileAreaH - 1 - j];
        Pixels[x, y + TileAreaH - 1 - j] := k;
      end;
      Inc (x);
    end;
  end;

  if not TileSelection.Visible then
    VFlipBounds (Bounds);

  b := UseAsAlphaChannel1.Enabled;
  UseAsAlphaChannel1.Enabled := FALSE;
  UpdateBmp (TRUE);
  UseAsAlphaChannel1.Enabled := b;
end;

procedure TMainForm.Clear1Click(Sender: TObject);
  var
    i, j: Integer;
    b: Boolean;
begin
  SaveUndo ('Clear');
  GetTileArea;
  for i := 0 to TileAreaW - 1 do
    for j := 0 to TileAreaH - 1 do
      Bmp.Canvas.Pixels[i + TileAreaX, j + TileAreaY] := TRANS_COLOR;

  b := UseAsAlphaChannel1.Enabled;
  UseAsAlphaChannel1.Enabled := FALSE;
  UpdateBmp (TRUE);
  UseAsAlphaChannel1.Enabled := b;

  Modified := TRUE;
end;

procedure TMainForm.LineToolMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then
    if LineTool.Height < 12 then
      LineTool.Height := LineTool.Height + 1;
  if Button = mbRight then
    if LineTool.Height > 1 then
      LineTool.Height := LineTool.Height - 1;
  LineTool.Top := LineToolPanel.Height div 2 - (LineTool.Height + 1) div 2;
  if DrawingTool = dtPoint then
  begin
    Bmp.Canvas.Pen.Width := 1;
    VisualBmp.Canvas.Pen.Width := 1;
  end
  else
  begin
    Bmp.Canvas.Pen.Width := LineTool.Height;
    VisualBmp.Canvas.Pen.Width := LineTool.Height;
  end;
end;

procedure TMainForm.Pattern1Click(Sender: TObject);
begin
  Pattern1.Checked := not Pattern1.Checked;
  UpdateBmp (TRUE);
end;


procedure TMainForm.ImportTiles1Click(Sender: TObject);
  var
    BlockW, BlockH,
    SkipX, SkipY,
    SkipW, SkipH: Integer;
    ai: array of Integer;
    i: Integer;
begin

  if OpenPictureDialog.Execute then
  begin
    ImportTiles.Result := FALSE;
    ImportTiles.ShowModal;
    if ImportTiles.Result then
    begin
      with ImportTiles do
      begin
        BlockW := TileWidth.Value;
        BlockH := TileHeight.Value;
        SkipX := ClipLeft.Value;
        SkipY := ClipTop.Value;
        SkipW := HorzSpace.Value;
        SkipH := VertSpace.Value;

        if (BlockW >= 4) and (BlockH >= 4) and
           (SkipX >= 0) and (SkipY >= 0) and
           (SkipW >= 0) and (SkipH >= 0) then
        begin

          CreateNewTileCollection (Identifier.Text, BlockW, BlockH, TRUE);

          SetLength (ai, Length (TransList));
          for i := 0 to Length (ai) - 1 do
            ai[i] := TransList[i];
      (*
          with TileTab[Tab.TabIndex] do
            if tbr.TileBitmap <> nil then
              tbr.TileBitmap.Free;
      *)
          FreeTBR (TileTab[Tab.TabIndex].tbr);

          MainForm.ProgressPanel.Visible := TRUE;

          TileTab[Tab.TabIndex].tbr :=
              ReadTileBitmap (OpenPictureDialog.Filename,
                  BlockW, BlockH, TransX, TransY,
                  ai,
                  SkipX, SkipY,
                  SkipW, SkipH,
                  ProgressBar, FALSE,
                  FALSE,
                  TileTab[Tab.TabIndex].tbr);

          TileTab[Tab.TabIndex].tbr.BackGr := BackGround.Brush.Color;

          SetLength (ai, 0);

          MainForm.ProgressPanel.Visible := FALSE;
        end
        else
          ShowMessage ('Invalid parameters.');
      end;

      TabChange (Sender);
      Modified := TRUE;
    end;
  end;
  UpdateTileBitmap;
end;

procedure TMainForm.DrawCursor;
  var
    L, C: Integer;

  procedure Rct (Canvas: TCanvas; X, Y, W, H: Integer);
  begin
    Canvas.Rectangle (X, Y, X + W, Y + H);
  end;

begin
  C := CursorSize;
  with TileTab[Tab.TabIndex] do
  begin
    with CursorImage do
    begin
      L := tbr.Current * W - TileScrollBox.HorzScrollBar.ScrollPos;

      while (L < 0) and (TileScrollBox.HorzScrollBar.Position >= W) do
      begin
        TileScrollBox.HorzScrollBar.Position := TileScrollBox.HorzScrollBar.Position - W;
        L := tbr.Current * W - TileScrollBox.HorzScrollBar.ScrollPos;
      end;
      if L < 0 then
        TileScrollBox.HorzScrollBar.Position := 0;

      while L > TileScrollBox.Width - W do
      begin
        TileScrollBox.HorzScrollBar.Position := TileScrollBox.HorzScrollBar.Position + W;
        L := tbr.Current * W - TileScrollBox.HorzScrollBar.ScrollPos;
      end;
      Left := L;
      Top := 0;
      with Canvas do
      begin
        Pen.Color := clBlack;
        Pen.Style := psSolid;
        Brush.Color := clWhite;
        Brush.Style := bsSolid;
      end;

      Rct (Canvas, 0, 0, C, C);
      Rct (Canvas, W div 2 - C div 2, 0, C, C);
      Rct (Canvas, W - C, 0, C, C);
      Rct (Canvas, 0, H div 2 - C div 2, C, C);
      Rct (Canvas, W - C, H div 2 - C div 2, C, C);
      Rct (Canvas, 0, H - C, C, C);
      Rct (Canvas, W div 2 - C div 2, H - C, C, C);
      Rct (Canvas, W - C, H - C, C, C);
    end;
  end;

  TileSelection.Visible := FALSE;

end;

procedure TMainForm.ShowStatusInfo;
  var
    b: Boolean;
    OfsX, OfsY: Integer;
begin
  if Tab.TabIndex > -1 then
    with TileTab[Tab.TabIndex] do
    begin
      StatusBar.Panels[3].Text := Format ('Tile %d of %d', [tbr.Current + 1, tbr.TileCount]);

      with StatusBar.Panels[5] do  // 2.4
      begin
        with tbr do
          if (Current < Length (OffsetX)) and (Current < Length (OffsetY)) then
          begin
            OfsX := tbr.OffsetX[tbr.Current];
            OfsY := tbr.OffsetY[tbr.Current];
            Text := Format ('(%d, %d)', [OfsX, OfsY]);
          end
          else
            Text := '';
        if Text = '(0, 0)' then
          Text := '';
      end;
    end;

  if Mode = mTile then
  begin
    StatusBar.Panels[0].Text := Format ('Size: %d x %d', [W, H]);

    Copy1.Enabled := TRUE;
    Cut1.Enabled := TRUE;
    Delete1.Enabled := TRUE;
    Paste1.Enabled := ClipBoard.HasFormat (CF_BITMAP);
    StretchPaste1.Enabled := ClipBoard.HasFormat (CF_BITMAP);
    ScaledPaste1.Enabled := ClipBoard.HasFormat (CF_BITMAP);
    RandomFill1.Enabled := FALSE;
    ClearArea1.Enabled := FALSE;
    MapScrollFunction1.Enabled := FALSE;
    ReplaceSelectedTile1.Enabled := FALSE;

    RemoveMap1.Enabled := FALSE;
    MapProperties1.Enabled := FALSE;
  end;

  Copy1.Caption := 'Copy';

  if Mode = mMap then
  begin
    with TileTab[Tab.TabIndex].tbr.Maps do  // 2.53
    begin
      NextMap1.Enabled := Length (aMaps) > 0;
      PreviousMap1.Enabled := Length (aMaps) > 0;
      MoveMapLeft1.Enabled := (Length (aMaps) > 0) and  // 2.55
                              (CurMap > 0);
      MoveMapRight1.Enabled := (Length (aMaps) > 0) and  // 2.55
                               (CurMap < Length (aMaps) - 1);

      ScaledPaste1.Enabled := FALSE;
    end;

    if lmp <> nil then
      StatusBar.Panels[0].Text := Format ('Size: %d x %d', [CurMapW, CurMapH])
    else
      StatusBar.Panels[0].Text := '';

  // StatusBar.Panels[1].Text := Format ('(%d, %d)', [i, j]);
  // StatusBar.Panels[1].Text := Format ('(%d, %d)-', [i, j]) +
  //    StatusBar.Panels[1].Text;

    Copy1.Enabled := true; // { bug: } (ClipTab.TabIndex > -1);  // Selection;   // 2.54 copy current tile
    if not Selection then Copy1.Caption := 'Copy Tile Combination';

    Cut1.Enabled := Selection;
    Delete1.Enabled := Selection or (ClipTab.TabIndex > -1);

    ConverttoTileSequence1.Enabled := Selection;
    InsertTileSequence1.Enabled := Selection;
    RemoveTileSequence1.Enabled := SeqTab.TabIndex > -1;
    ReplaceCurrentTileSequence1.Enabled := Selection and (SeqTab.TabIndex > -1);

    b := Selection and (ClipTab.TabIndex > -1);
    Paste1.Enabled := b;
    StretchPaste1.Enabled := b;
    RandomFill1.Enabled := b;
    ClearArea1.Enabled := b;
    ReplaceSelectedTile1.Enabled := b;

    RemoveMap1.Enabled := MapTab.TabIndex > -1;
    MapProperties1.Enabled := MapTab.TabIndex > -1;
    MapScrollFunction1.Enabled := MapTab.TabIndex > -1;

  end;

  UtilsTab.Visible := (Mode = mTile);

  b := (Mode = mMap) and (MapTab.TabIndex > -1);
  InsertHorizontal1.Enabled := b;
  InsertVertical1.Enabled := b;
  DeleteHorizontal1.Enabled := b;
  DeleteVertical1.Enabled := b;
  ImportMap1.Enabled := b;
  ExportMap1.Enabled := b;

  ShowMapLayer1.Enabled := b;  // 2.54

  ReplaceColorUnderCursor1.Enabled := (Mode = mTile);
end;

procedure TMainForm.StartEdit (UpdateAll: Boolean);
begin
  if Length (TileTab) > 0 then
    with TileTab[Tab.TabIndex] do
    begin
      if tbr.TileCount = 0 then
      begin
        CreateNewTile (tbr);
        UpdateTileBitmap;
      end;

      if UpdateAll then
      begin
      //  TileBitmap.Width := tbr.TileCount * tbr.W;
      //  TileBitmap.Height := tbr.H;

       // TileBitmap.Picture.Bitmap := tbr.TileBitmap;

       // TileScrollBox.HorzScrollBar.Range := TileBitmap.Width;
        TileScrollBox.HorzScrollBar.Increment := tbr.W;
        TilePanel.Height :=
               tbr.H
             + 16  // (TileScrollBox.Height - TileScrollBox.ClientHeight)
             + (Tab.TabHeight)
             + StatusBar.Height
             + 10;
      end;

      if Mode = mTile then
      begin
        Bmp.Canvas.CopyRect (MakeRect (BORDER_W, BORDER_H, W, H),
            tbr.TileBitmap.Canvas, MakeRect (tbr.Current * W, 0, W, H));

        Tile.Transparent := FALSE;
        Tile.Stretch := TRUE;
        Tile.Picture.Graphic := VisualBmp;

        Bounds := GetBound (tbr, -1);
      end;

      TileMouseMove (nil, [], LastX, LastY);

      BoundBox.RePaint;
      DrawCursor;

      if UpdateAll then
        MainForm.Resize;

      if Mode = mTile then
      begin
        ClearUndo;
        if not UpdateAll then
          UpdateBmp (TRUE);
      end
      else
        ShowStatusInfo;
    end;
end;


procedure TMainForm.NewTile1Click(Sender: TObject);
begin
  UpdateBmp (TRUE);
  AllowMultEmptyTiles := Sender = NewTile1;
  CreateNewTile (TileTab[Tab.TabIndex].tbr);
  AllowMultEmptyTiles := FALSE;
  UpdateTileBitmap;
  StartEdit (TRUE);

  Modified := TRUE;
end;

procedure TMainForm.TileBitmapMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  var i, j: Integer;
begin
  if Button = mbRight then
  begin
    if UnionSkinTile = X div W then
      UnionSkinTile := -1
    else
    begin
      UnionSkinTile := X div W;
      with TileTab[Tab.TabIndex] do
        UnionSkinBmp.Canvas.CopyRect (MakeRect (BORDER_W, BORDER_H, W, H),
                  tbr.TileBitmap.Canvas, MakeRect (UnionSkinTile * W, 0, W, H));
    end;
    UpdateBMP (TRUE);
    Exit;
  end;
  UnionSkinTile := -1;

  if Sender = TileBitmap then
    TileTab[Tab.TabIndex].tbr.Current := X div W;

  if Mode = mMap then
    if Button = mbLeft then
    begin
      SelectCurrentTile (TileTab[Tab.TabIndex].tbr.Current);
      DrawCurrentTile;
    end;

  StartEdit (TRUE);
end;

function TMainForm.ColorMatch (C: Integer): Integer;
  var
    R, G, B: Integer;
    rr, gg, bb: Integer;
    i, j, k, l: Integer;
begin
  GetRGB (C, R, G, B);

  if Pal256 and (CountEnabledColors > 0) then
  begin

    k := -1;
    l := -1;
    for i := 0 to 255 do
      if Enable256[i] then
      begin
        GetRGB (PaletteValues[i], rr, gg, bb);
        j := sqr ((r - rr) * 2) + sqr ((g - gg) * 2) + sqr ((b - bb) * 2);
        if (k = -1) or (j < l) then
        begin
          k := i;
          l := j;
        end;
      end;
    ColorMatch := PaletteValues[k];
    Exit;

  end
  else

    if ShowCurrentPalette1.Checked then
      with UsedColorsImage.Picture.Bitmap do
        if Height > 1 then
        begin
          k := -1;
          l := -1;
          for i := 0 to Height - 1 do
          begin
            GetRGB (Canvas.Pixels[0, i], rr, gg, bb);
            j := sqr ((r - rr) * 2) + sqr ((g - gg) * 2) + sqr ((b - bb) * 2);
            if (k = -1) or (j < l) then
            begin
              k := i;
              l := j;
            end;
          end;
          ColorMatch := Canvas.Pixels[0, k];
          Exit;
        end;

  i := 128 div (MaxRGB - 1);
  j := 255 div (MaxRGB - 1);

  R := LimitRGB ((R + i) div j * j);
  G := LimitRGB ((G + i) div j * j);
  B := LimitRGB ((B + i) div j * j);

  Inc (R, R div 64);
  Inc (G, G div 64);
  Inc (B, B div 64);

  if R > 255 then R := 255;
  if G > 255 then G := 255;
  if B > 255 then B := 255;

  c := RGB (R, G, B);
  if c = TRANS_COLOR then
    c := TRANS_COLOR_REPLACEMENT;

  ColorMatch := c;
end;

procedure TMainForm.MatchColors1Click(Sender: TObject);
  var
    i, j, k, x, y: Integer;
begin
  GetTileArea;
  SaveUndo ('Match Colors');
  for j := 0 to TileAreaH do
    for i := 0 to TileAreaW do
    begin
      x := TileAreaX + i;
      y := TileAreaY + j;
      k := Bmp.Canvas.Pixels[x, y];
      if k <> TRANS_COLOR then
        Bmp.Canvas.Pixels[x, y] := ColorMatch (k);
    end;
  UpdateBmp (TRUE);
  Modified := TRUE;
end;

procedure TMainForm.SwapWithUndo;
  var
    ur: UndoRec;
begin
  ur.Bmp := TBitmap.Create;
  SetStretchBltMode(ur.Bmp.Canvas.Handle, HALFTONE);
  ur.Bmp.PixelFormat := pf24bit;
  ur.Bmp.Width := W;
  ur.Bmp.Height := H;
  ur.Bmp.Canvas.CopyRect (Rect (0, 0, W, H),
      Undo[UndoPos].Bmp.Canvas, Rect (0, 0, W, H));
  ur.ActionName := Undo[UndoPos].ActionName;

  Undo[UndoPos].Bmp.Canvas.CopyRect (Rect (0, 0, W, H),
       Bmp.Canvas, MakeRect (BORDER_W, BORDER_H, W, H));
  Undo[UndoPos].ActionName := Action;

  Bmp.Canvas.CopyRect (MakeRect (BORDER_W, BORDER_H, W, H),
      ur.Bmp.Canvas, Rect (0, 0, W, H));
  Action := ur.ActionName;
  ur.Bmp.Free;
  Modified := TRUE;
end;

procedure TMainForm.Undo1Click(Sender: TObject);
begin
//  UndoButton.Down := FALSE;
  if not Undo1.Enabled then
    Exit;

  if Undo[UndoPos].HistoryCoords <> '' then
    HistoryListBox.Items.Delete(HistoryListBox.Items.Count - 1);

  SwapWithUndo;

  if UndoPos = 0 then
  begin
    Undo1.Caption := '&Undo';
    Undo1.Enabled := FALSE;
  {
    UndoButton.Down := FALSE;
    UndoButton.Enabled := FALSE;
  }
  end
  else
    Undo1.Caption := '&Undo ' + Undo[UndoPos - 1].ActionName;

  Redo1.Caption := '&Redo ' + Action;
  Redo1.Enabled := TRUE;
{
  RedoButton.Enabled := TRUE;
}
  Dec (UndoPos);

  UpdateBmp (TRUE);
end;

procedure TMainForm.Redo1Click(Sender: TObject);
begin
//  RedoButton.Down := FALSE;
  if not Redo1.Enabled then
    Exit;

  Inc (UndoPos);

  SwapWithUndo;

  if Undo[UndoPos].HistoryCoords <> '' then
    HistoryListBox.Items.Add(Undo[UndoPos].HistoryCoords);

  if UndoPos = UndoCount - 1 then
  begin
    Redo1.Caption := '&Redo';
    Redo1.Enabled := FALSE;
  {
    RedoButton.Down := FALSE;
    RedoButton.Enabled := FALSE;
  }
  end
  else
    Redo1.Caption := '&Redo ' + Action;

  Undo1.Caption := '&Undo ' + Undo[UndoPos].ActionName;
  Undo1.Enabled := TRUE;
{
  UndoButton.Enabled := TRUE;
}
  UpdateBmp (TRUE);
end;

procedure TMainForm.SaveTempBmp;
begin
  TempBmp.Canvas.CopyRect (Rect (0, 0, W + 2 * BORDER_W, H + 2 * BORDER_H),
               Bmp.Canvas, Rect (0, 0, W + 2 * BORDER_W, H + 2 * BORDER_H));
end;

procedure TMainForm.Copy1Click(Sender: TObject);
  var
    n, i, j: Integer;
begin
  if Mode = mTile then
  begin
    if TileSelection.Visible and
       (TileSelX2 <> TileSelX1) and
       (TileSelY2 <> TileSelY1) then
    begin
      i := TileSelX2 - TileSelX1;
      j := TileSelY2 - TileSelY1;
      ClipBmp.Width := i;
      ClipBmp.Height := j;
      ClipBmp.Canvas.CopyRect (Rect (0, 0, i, j),
            Bmp.Canvas, MakeRect (TileSelX1, TileSelY1, i, j));
      ClipBoard.Assign (ClipBmp);
      TileSelection.Visible := FALSE;
    end
    else
    begin
      ClipBmp.Width := W;
      ClipBmp.Height := H;
      ClipBmp.Canvas.CopyRect (Rect (0, 0, W, H),
                   Bmp.Canvas, MakeRect (BORDER_W, BORDER_H, W, H));
      ClipBoard.Assign (ClipBmp);
    end;
    ScaledPaste1.Enabled := TRUE;
  end;
  if Mode = mMap then
  begin
    if not Selection then
    begin
      ClipBmp.Width := W;
      ClipBmp.Height := H;
      ClipBmp.Canvas.CopyRect (Rect (0, 0, W, H),
                   bmpPreview.Canvas, MakeRect (0, 0, W, H));
      ClipBoard.Assign (ClipBmp);  // 2.54
      Exit;
    end;

    with Area do
    begin
      ClipW := Right - Left + 1;
      ClipH := Bottom - Top + 1;
      NewClipMap (TileTab[Tab.TabIndex].tbr, ClipW, ClipH);
    end;
    n := ClipTab.Tabs.Count;

    ClipTab.TabIndex := ClipTab.Tabs.Add (IntToStr (n));

    clip := SelectClipMap (TileTab[Tab.TabIndex].tbr, n);
    with Area do
      for j := Top to Bottom do
        for i := Left to Right do
          clip^.Map[j - Top, i - Left] := lmp^.Map[j, i];

    ClipTabChange (Sender);

    Selection := FALSE;
    UpdateMapRegion(Area);

  end;
  Paste1.Enabled := TRUE;
  StretchPaste1.Enabled := TRUE;
end;


procedure TMainForm.Paste1Click(Sender: TObject);
  var
    i, j, k: Integer;
    x, y: Integer;
    X1, Y1, X2, Y2: Integer;
begin
  if Mode = mTile then
    if Clipboard.HasFormat(CF_BITMAP) then
    begin
      SaveUndo ('Paste');
      ClipBmp.Assign(Clipboard);
      ClipBmp.Canvas.Draw(0, 0, ClipBmp);

      with ClipBmp do
      begin
        X1 := 0;
        Y1 := 0;
        X2 := W;
        Y2 := H;

        if TileSelection.Visible and
           (TileSelX2 <> TileSelX1) and
           (TileSelY2 <> TileSelY1) then
        begin
          X1 := TileSelX1 - BORDER_W;
          Y1 := TileSelY1 - BORDER_H;
          X2 := TileSelX2 - BORDER_W - 1;
          Y2 := TileSelY2 - BORDER_H - 1;
        end;

      //  Bmp.Canvas.Draw(BORDER_W, BORDER_H, ClipBmp);
        for j := Y1 to Y2 do
          for i := X1 to X2 do
          begin
            x := i - X1;
            y := j - Y1;
            if (x < ClipBmp.Width) and (y < ClipBmp.Height) then
            begin
              k := ClipBmp.Canvas.Pixels[x, y];
              if k <> TRANS_COLOR then
                Bmp.Canvas.Pixels[BORDER_W + i, BORDER_H + j] := k;
            end;
          end;
      end;
      TileSelection.Visible := FALSE;
      UpdateBmp (TRUE);
    end;
  if Mode = mMap then
    if Selection and (ClipTab.TabIndex > -1) and (clip <> nil) then
    begin
      with Area do
        for j := Top to Bottom do
          for i := Left to Right do
          begin
            y := (j - Top) mod ClipH;
            x := (i - Left) mod ClipW;
            lmp^.Map[j, i] := clip^.Map[y, x];
          end;
      Selection := FALSE;
      UpdateMapRegion(Area);
    end;
  Modified := TRUE;
end;

procedure TMainForm.Delete1Click(Sender: TObject);
  var
    i, j: Integer;
begin
  if Mode = mTile then
  begin
    if TileSelection.Visible then
    begin
      SaveUndo ('Clear');

      for j := TileSelY1 to TileSelY2 - 1 do
        for i := TileSelX1 to TileSelX2 - 1 do
          Bmp.Canvas.Pixels[i, j] := TRANS_COLOR;

      TileSelection.Visible := FALSE;
      UpdateBmp (TRUE);
      Modified := TRUE;
    end
    else
    begin

      ClearUndo;  // bugfix

      UpdateBmp (TRUE);
    //  Clear1Click (Sender);
      with TileTab[Tab.TabIndex] do
      begin
        i := CountTileUsed (tbr);
        if i > 0 then
          if MessageDlg ('Tile is used ' + IntToStr (i) +
               ' time(s). Remove anyway?', mtWarning,
               [mbOk, mbCancel], 0) = mrCancel then
                 Exit;
        RemoveTile (tbr);
        if tbr.TileCount = 0 then
          CreateNewTile (tbr);
        UpdateTileBitmap;
      end;
      Modified := TRUE;
      StartEdit (TRUE);
    end;
  end;

  if Mode = mMap then
  begin
    if Selection then
    begin
      for j := Area.Top to Area.Bottom do
        for i := Area.Left to Area.Right do
          ClearMCR (lmp^.Map[j, i]);
      Modified := TRUE;
      Selection := FALSE;
      UpdateMapRegion(Area);
      Modified := TRUE;
    end
    else
      if ClipTab.TabIndex > -1 then
      begin
        RemoveClip (TileTab[Tab.TabIndex].tbr, ClipTab.TabIndex);
        with ClipTab do
        begin
          j := TabIndex;
          Tabs.Delete (TabIndex);
          for i := j to Tabs.Count - 1 do
            Tabs.Strings[i] := IntToStr (StrToInt (Tabs.Strings[i]) - 1);

          if j <= Tabs.Count - 1 then
            TabIndex := j
          else
            TabIndex := Tabs.Count - 1;
        end;
        ClipTabChange (Sender);
        Modified := TRUE;
      end
      else
        SelectCurrentTile (-1);

    Delete1.Enabled := Selection or (ClipTab.TabIndex > -1);
  end;

end;

procedure TMainForm.Cut1Click(Sender: TObject);
  var
    Sel, TSel: Boolean;
begin
  Sel := Selection;
  TSel := TileSelection.Visible;
  Copy1Click (Sender);
  if Sel then
    Selection := TRUE;
  if TSel then
    TileSelection.Visible := TRUE;
  Delete1Click (Sender);
end;

procedure TMainForm.MoveTileLeftClick(Sender: TObject);
begin
  UpdateBmp (TRUE);
  if MoveLeft (TileTab[Tab.TabIndex].tbr, TRUE) then
  begin
   // TileBitmap.Picture.Bitmap := TileTab[tab.TabIndex].tbr.TileBitmap;
    UpdateTileBitmap;
    DrawCursor;
    Modified := TRUE;
  end;
  //  StartEdit;
  ShowStatusInfo;
end;

procedure TMainForm.MoveTileRightClick(Sender: TObject);
begin
  UpdateBmp (TRUE);
  if MoveRight (TileTab[Tab.TabIndex].tbr, TRUE) then
  begin
   // TileBitmap.Picture.Bitmap := TileTab[tab.TabIndex].tbr.TileBitmap;
    UpdateTileBitmap;
    DrawCursor;
    Modified := TRUE;
  end;
  //  StartEdit;
  ShowStatusInfo;
end;

procedure TMainForm.RemoveDuplicateTiles1Click(Sender: TObject);
begin
  ProgressPanel.Visible := TRUE;
  Tiles.RemoveDuplicates (TileTab[Tab.TabIndex].tbr, ProgressBar);
  StartEdit (TRUE);
  ProgressPanel.Visible := FALSE;
  UpdateTileBitmap;
  Modified := TRUE;
end;

procedure TMainForm.ShowRGB (color: Integer);
  const
    LastColor: Integer = -1;
  var
    R, G, B: Integer;
    cR, cG, cB: Char;
begin
  ColorUnderMousePointer := color;  // 3.0
  cR := 'r'; cG := 'g'; cB := 'b';
  if color <> LastColor then
  begin
    GetRGB (color, R, G, B);
    if color <> ColorMatch (color) then
      begin cR := 'R'; cG := 'G'; cB := 'B'; end;
    if color = TRANS_COLOR then
      StatusBar.Panels[2].Text := 'Transparent'
    else
      StatusBar.Panels[2].Text := Format ('%s: %d, %s: %d, %s: %d',
         [cR, R, cG, G, cB, B]);
    LastColor := color;
  end;
end;

procedure TMainForm.ColorMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  ShowRGB (Color.Brush.Color);
end;

procedure TMainForm.BackGroundMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  ShowRGB (TRANS_COLOR);
end;

procedure TMainForm.About1Click(Sender: TObject);
begin
  AboutForm.WebSite.Caption := URL;
  AboutForm.ShowModal;
end;

procedure TMainForm.Homepage1Click(Sender: TObject);
  var
    Param: string;
begin
  Param := URL;
  ShellExecute (0, 'open', PChar (Param), Nil, Nil, SW_SHOWNORMAL);
end;

procedure TMainForm.ExportTiles1Click(Sender: TObject);
begin
  with TileTab[Tab.TabIndex] do
  begin
    if tbr.TileCount = 0 then
      Exit;

    ExportTiles.ShowModal;

    with ExportTiles do
      if Result then
      begin
        SavePictureDialog.DefaultExt := GraphicExtension(TBitmap);
        SavePictureDialog.FileName := tbr.Filename;
        if SavePictureDialog.Execute then
        begin
          ProgressPanel.Visible := TRUE;
          WriteTileBitmap (SavePictureDialog.FileName,
              MaxWidth.Value,
              TransColor.Brush.Color,
              BorderColor.Brush.Color,
              Between.Value, Between.Value,
              Edge.Value, Edge.Value,
              tbr,
              ProgressBar,
              TransBottomRight.Checked,
              FALSE,
              SavePictureDialog.FilterIndex);
          ProgressPanel.Visible := FALSE;
        end;
      end;

  end;
end;

procedure TMainForm.DrawBounds (c: TCanvas; X, Y, Wid, Ht, lw, Bounds, Color: Integer);
  var
    X1, Y1, X2, Y2: Integer;
    W, H, HW, HH: Integer;
    MirV: Integer;
begin
  with c do
  begin
    Pen.Style := psSolid;
    Pen.Color := Color;
    Pen.Width := lw;

    X1 := X + 1 + lw div 2;
    Y1 := Y + 1 + lw div 2;
    X2 := X + Wid - 1 - X1 - Byte (lw = 1);
    Y2 := Y + Ht - 1 - Y1 - Byte (lw = 1);
    W := X2 - X1;
    H := Y2 - Y1;
    HW := W div 2;
    HH := H div 2;

    if Bounds <> 0 then
     // if Bounds and $70 = 0 then
      if ShortInt (Bounds) > 0 then
      begin
        { horizontal and vertical }

        if (Bounds and $1 = 1) then
        begin
          MoveTo (X1, Y1);
          LineTo (X2, Y1);
          Pixels[X2, Y1] := Color;
        end;
        if (Bounds and $2 = 2) then
        begin
          MoveTo (X1, Y1);
          LineTo (X1, Y2);
          Pixels[X1, Y2] := Color;
        end;
        if (Bounds and $4 = 4) then
        begin
          MoveTo (X1, Y2);
          LineTo (X2, Y2);
          Pixels[X2, Y2] := Color;
        end;
        if (Bounds and $8 = 8) then
        begin
          MoveTo (X2, Y1);
          LineTo (X2, Y2);
          Pixels[X2, Y2] := Color;
        end;

      end
      else
      begin
        { diagonal }

        MirV := 0;
        if Bounds and $1 = $1 then
          MirV := X2 - X1;

        case (Bounds and $3F) shr 1 of
          0: begin MoveTo (X2 - MirV, Y1); LineTo (X1 + MirV, Y2);      end;
          1: begin MoveTo (X1 + HW, Y1);   LineTo (X1 + MirV, Y2);      end;
          2: begin MoveTo (X2 - MirV, Y1); LineTo (X2 - HW, Y2);        end;
          3: begin MoveTo (X1 + MirV, Y2); LineTo (X2 - MirV, Y2 - HH); end;
          4: begin MoveTo (X1 + MirV, Y1 + HH); LineTo (X2 - MirV, Y1); end;

        end;

      end;

  end;
end;

procedure TMainForm.BoundBoxPaint(Sender: TObject);
  const
    LastBounds: Integer = 0;
  var
    i, j, b: Integer;
begin
  if Tab.TabIndex = -1 then
    Exit;

  if Bounds = LastBounds then
    if (Mode = mMap) and Selection then
      Exit;   // quick fix for strange bug: select area in map, set diagonal bound, keeps refreshing

  with BoundBox.Canvas do
  begin
    Brush.Style := bsSolid;
    Brush.Color := clBtnFace;
    Pen.Style := psClear;
    FillRect (Rect (0, 0, Width, Height));
  end;
  DrawBounds (BoundBox.Canvas, 0, 0, BoundBox.Width, BoundBox.Height, 3, Bounds, clBlack);

  if Mode = mTile then
    with BoundBox.Canvas do
    begin
      Pen.Style := psSolid;
      Pen.Width := 1;
      Pen.Color := clGray;
      Brush.Style := bsClear;
      i := BoundBox.Width div 2;
      i := i + XShade * i div 3;
      j := BoundBox.Height div 2;
      j := j + YShade * j div 3;
      Ellipse (i - 5, j - 5, i + 5, j + 5);
    end;

  if Mode = mTile then
    SetBound (TileTab[Tab.TabIndex].tbr, Bounds)
  else
    if TileTab[Tab.TabIndex].tbr.mcr.Bounds and (not $40) <> Bounds and (not $40) then
    begin
      TileTab[Tab.TabIndex].tbr.mcr.Bounds :=
          ShortInt ((TileTab[Tab.TabIndex].tbr.mcr.Bounds and $40) or (Bounds and (not $40)));
      ShowSelectedTile;
    end;

  if (Mode = mMap) and Selection then
    if Bounds <> LastBounds then
    begin
     // if Bounds < $10 then
     // if Bounds and $70 = 0 then
      if ShortInt (Bounds) > 0 then  // 2.55
      begin
        for j := Area.Top to Area.Bottom do
          for i := Area.Left to Area.Right do
          begin
            b := lmp^.Map[j, i].Bounds and (not $40);
            if b > $F then
              b := 0;
            if (Bounds and 1) <> (LastBounds and 1) then
              b := (b and (not 1)) or ((Bounds and 1) * (Byte (j = Area.Top)));
            if (Bounds and 2) <> (LastBounds and 2) then
              b := (b and (not 2)) or ((Bounds and 2) * (Byte (i = Area.Left)));
            if (Bounds and 4) <> (LastBounds and 4) then
              b := (b and (not 4)) or ((Bounds and 4) * (Byte (j = Area.Bottom)));
            if (Bounds and 8) <> (LastBounds and 8) then
              b := (b and (not 8)) or ((Bounds and 8) * (Byte (i = Area.Right)));
            lmp^.Map[j, i].Bounds := (lmp^.Map[j, i].Bounds and $40) or ShortInt (b);
          end;
      //  Selection := FALSE;

        UpdateMapRegion(Area);
        Modified := TRUE;

      end
      else
      begin

        for j := Area.Top to Area.Bottom do
          for i := Area.Left to Area.Right do
          begin
            b := lmp^.Map[j, i].Bounds and (not $40);
            if ((Bounds = $81) and (i - Area.Left = j - Area.Top)) or
               ((Bounds = $80) and (Area.Right - i = j - Area.Top)) then
              b := Bounds;
{
            b := lmp^.Map[j, i].Bounds;
            if (Bounds and 1) <> (LastBounds and 1) then
              b := (b and (not 1)) or ((Bounds and 1) * (Byte (j = Area.Top)));
            if (Bounds and 2) <> (LastBounds and 2) then
              b := (b and (not 2)) or ((Bounds and 2) * (Byte (i = Area.Left)));
            if (Bounds and 4) <> (LastBounds and 4) then
              b := (b and (not 4)) or ((Bounds and 4) * (Byte (j = Area.Bottom)));
            if (Bounds and 8) <> (LastBounds and 8) then
              b := (b and (not 8)) or ((Bounds and 8) * (Byte (i = Area.Right)));
}
            lmp^.Map[j, i].Bounds := (lmp^.Map[j, i].Bounds and $40) or ShortInt (b);
          end;
      //  Selection := FALSE;
        UpdateMapRegion(Area);
        Modified := TRUE;

      end;
    end;

  LastBounds := Bounds;
end;

procedure TMainForm.Top1Click(Sender: TObject);
begin
  if Bounds and $80 = 0 then
    Bounds := Bounds xor $1
  else
    Bounds := $1;
  BoundBox.RePaint;
  Modified := TRUE;
end;

procedure TMainForm.Bottom1Click(Sender: TObject);
begin
  if Bounds and $80 = 0 then
    Bounds := Bounds xor $4
  else
    Bounds := $4;
  BoundBox.RePaint;
  Modified := TRUE;
end;

procedure TMainForm.Left2Click(Sender: TObject);
begin
  if Bounds and $80 = 0 then
    Bounds := Bounds xor $2
  else
    Bounds := $2;
  BoundBox.RePaint;
  Modified := TRUE;
end;

procedure TMainForm.Right2Click(Sender: TObject);
begin
  if Bounds and $80 = 0 then
    Bounds := Bounds xor $8
  else
    Bounds := $8;
  BoundBox.RePaint;
  Modified := TRUE;
end;

procedure TMainForm.DiagonalUp1Click(Sender: TObject);
begin
  if Bounds = $80 then
    Bounds := $00
  else
    Bounds := $80;
  BoundBox.RePaint;
  Modified := TRUE;
end;

procedure TMainForm.DiagonalDown1Click(Sender: TObject);
begin
  if Bounds = $81 then
    Bounds := $00
  else
    Bounds := $81;
  BoundBox.RePaint;
  Modified := TRUE;
end;

procedure TMainForm.ClearAll1Click(Sender: TObject);
begin
  Bounds := 0;
  BoundBox.RePaint;
  Modified := TRUE;
end;

procedure TMainForm.BoundBoxMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  var
    xx, yy: Boolean;
begin
  Dec (X, BoundBox.Width div 2);
  Dec (Y, BoundBox.Height div 2);
  xx := Abs (X) >= BoundBox.Width div 4;
  yy := Abs (Y) >= BoundBox.Height div 4;

  if (ssShift in Shift) then
  begin
    XShade := X div (BoundBox.Width div 5);
    YShade := Y div (BoundBox.Height div 5);
    BoundBox.Repaint;
  end
  else
  begin
    if xx and yy then
      if X * Y < 0 then
        DiagonalUp1Click (Sender)
      else
        DiagonalDown1Click (Sender)
    else if xx then
    begin
      if X > 0 then
        Right2Click (Sender)
      else
        Left2Click (Sender);
    end
    else if yy then
    begin
      if Y > 0 then
        Bottom1Click (Sender)
      else
        Top1Click (Sender);
    end
    else
      ClearAll1Click (Sender);
  end;
end;

procedure TMainForm.NewTileCollection1Click(Sender: TObject);
begin
  with NewForm do
  begin
    NewMode := nmNewTileSet;
    DefaultName := NewTCName;
    CanChangeSize := TRUE;
    DefaultOverlap := 0;
    ShowModal;
    if Result then
    begin
      if TileWidth.Value < 1 then TileWidth.Value := 1;   // 2.4
      if TileHeight.Value < 1 then TileHeight.Value := 1;

      CreateNewTileCollection (Identifier.Text, TileWidth.Value, TileHeight.Value, TRUE);
      TabChange (Sender);
      TileTab[Tab.TabIndex].tbr.Overlap := Overlap.Value;
      TileTab[Tab.TabIndex].tbr.SkipExport := Skip.Checked;  // 2.2
      Modified := TRUE;
    end;
  end;
end;

procedure TMainForm.CreateNewTileCollection (Name: string; BW, BH: Integer; AddNew: Boolean);
  var
    cr: Integer;
begin
  if AddNew then
  begin
    cr := Length (TileTab);
    SetLength (TileTab, cr + 1);
    Tab.Tabs.Add (Name);
    Tab.TabIndex := cr;
  end;

  SetTileSize (BW, BH);

  TileTab[Tab.TabIndex].id := Name;

  Scale := DEFAULT_SCALE - BW div 8 + 4 - BH div 8 + 4;
  if Scale < 1 then Scale := 1;
  while (Scale * (BW + 2 * BORDER_W) < ScrollBox.ClientWidth) and
        (Scale * (BH + 2 * BORDER_H) < ScrollBox.ClientHeight - 2 * BH) do
      Inc (Scale);

  if Scale > MAX_SCALE then Scale := MAX_SCALE;
  with TileTab[Tab.TabIndex] do
  begin
    lastscale := Scale;
    lastscrollpos := 0;
    AnimStart := -1;
    AnimEnd := -1;
    BackGrColor := Background.Brush.Color;
  end;

  TileTab[Tab.TabIndex].tbr := CreateNewTBR (BW, BH);

  CreateNewTile (TileTab[Tab.TabIndex].tbr);
  UpdateTileBitmap;

  DrawCursor;
end;

function TMainForm.NewTCName: string;
  var
    Name: string;
    i: Integer;
begin
  i := 0;
  repeat
    Inc (i);
    Name := 'Tiles' + IntToStr (i);
  until Tab.Tabs.IndexOf (Name) = -1;
  NewTCName := Name;
end;

function TMainForm.NewMapName: string;
  var
    Name: string;
    i: Integer;
begin
  i := 0;
  repeat
    Inc (i);
    Name := 'Map' + IntToStr (i);
  until MapTab.Tabs.IndexOf (Name) = -1;
  NewMapName := Name;
end;

procedure TMainForm.Properties1Click(Sender: TObject);
  var
    OldW, OldH, NewW, NewH: Integer;
begin
  with NewForm do
  begin
    NewMode := nmTileSetProperties;
    DefaultName := TileTab[Tab.TabIndex].id;
    CanChangeSize := HasNoTiles (TileTab[Tab.TabIndex].tbr);
    OldW := TileTab[Tab.TabIndex].tbr.W;
    OldH := TileTab[Tab.TabIndex].tbr.H;
    TileWidth.Value := OldW;
    TileHeight.Value := OldH;

    Skip.Checked := TileTab[Tab.TabIndex].tbr.SkipExport;  // 2.2

    DefaultOverlap := TileTab[Tab.TabIndex].tbr.Overlap;
    ShowModal;
    if Result then
      with TileTab[Tab.TabIndex] do
      begin
        id := Identifier.Text;
        Tab.Tabs.Strings[Tab.TabIndex] := Identifier.Text;
        tbr.Overlap := Overlap.Value;

        if TileWidth.Value < 1 then TileWidth.Value := 1;  // 2.4
        if TileHeight.Value < 1 then TileHeight.Value := 1;

        NewW := TileWidth.Value;
        NewH := TileHeight.Value;

        tbr.SkipExport := Skip.Checked;  // 2.2

        if (NewW <> OldW) or (NewH <> OldH) then
        begin
          CreateNewTileCollection (Identifier.Text, NewW, NewH, FALSE);

          MainForm.Resize;
          StartEdit (TRUE);
        end;
        SetEditorMode (mTile);
        Modified := TRUE;
      end;
  end;
end;

function TMainForm.TCNameOK (s: string; MayExist: Boolean): Boolean;
  var
    i: Integer;
begin
  if Tab.Tabs.IndexOf (s) <> -1 then
    TCNameOK := MayExist and (Tab.Tabs.IndexOf (s) = Tab.TabIndex)
  else
  begin
    TCNameOK := FALSE;
    if s = '' then
      Exit;
    if not (UpCase (s[1]) in ['A'..'Z']) then
      Exit;
    for i := 1 to Length (s) do
      if not (UpCase (s[i]) in ['A'..'Z', '0'..'9', '_']) then
        Exit;
    TCNameOK := TRUE;
  end;
end;

procedure TMainForm.IdError (id: string);
begin
  if id = '' then
    MessageDlg ('An identifier is required.', mtError, [mbOk], 0)
  else
    if TCNameOk (id, TRUE) and (Tab.Tabs.IndexOf (id) <> Tab.TabIndex) then   // 2.33 and ipv or
      MessageDlg ('The name already exists.', mtError, [mbOk], 0)
    else
      MessageDlg ('The identifier "' + id + '" contains invalid characters.', mtError, [mbOk], 0);
end;

procedure TMainForm.TabChange(Sender: TObject);
  var
    Cur: Integer;
begin
//  UpdateBmp (TRUE);

//  if Mode <> mTile then
//    SetEditorMode (mTile);

  with TileTab[Tab.TabIndex] do
  begin
    Cur := tbr.Current;
    Background.Brush.Color := BackGrColor;
    TileScrollBox.HorzScrollBar.Position := lastscrollpos;
    Scale := lastscale;
    tbr.Current := tbr.TileCount; // avoid clearing current tile

    SetTileSize (tbr.W, tbr.H);

    tbr.Current := Cur;
  end;

  UpdateTileBitmap;


 // MainForm.ScrollBox.SetFocus;
  if Mode = mMap then
  begin
    MapDisplay.Visible := FALSE;
    SetEditorMode (mMap);
  end;

  StartEdit (TRUE);
  HideUsedColors;
end;

procedure TMainForm.Toolbar1Click(Sender: TObject);
begin

  Toolbar1.Checked := not Toolbar1.Checked;
  ToolBar.Visible := Toolbar1.Checked;
  MainForm.Resize;
end;

procedure TMainForm.ActualSize1Click(Sender: TObject);
begin
  if Mode = mTile then
  begin
    Scale := 1;
    MainForm.Resize;
  end;
  if Mode = mMap then
  begin
    Zoom := ZOOM_FACTOR;
    ZoomMap;
    UpdateMap;
  end;
end;

procedure TMainForm.FitinWindow1Click(Sender: TObject);
  var
    WinW, WinH, iw, ih: Integer;
begin
  WinW := ScrollBox.Width - 4;
  WinH := ScrollBox.Height - 4;
  iw := W + 2 * BORDER_W;
  ih := H + 2 * BORDER_H;
  Scale := 2;
  while (iw * Scale < WinW) and (ih * Scale < WinH)
                and (Scale <= MAX_SCALE) do
    Inc (Scale);
  Dec (Scale);
  MainForm.Resize;
end;

procedure TMainForm.SetPaletteDepth(Sender: TObject);
begin
  if Sender = N61 then MaxRGB := 6 else
  if Sender = N71 then MaxRGB := 7 else
  if Sender = N81 then MaxRGB := 8 else
  if Sender = N91 then MaxRGB := 9 else
  MaxRGB := 10;
  N61.Checked := MaxRGB = 6;
  N71.Checked := MaxRGB = 7;
  N81.Checked := MaxRGB = 8;
  N91.Checked := MaxRGB = 9;
  N101.Checked := MaxRGB = 10;
  MaxR := MaxRGB; MaxG := MaxRGB; MaxB := MaxRGB;
  if SmoothPalette1.Checked then
    SmoothPalette1Click (Sender)
  else
    Palette.Repaint;
end;

procedure TMainForm.DuplicateTile1Click(Sender: TObject);
  var
    TempBmp: TBitmap;
    bnd: Integer;
begin
  bnd := Bounds;
  UpdateBmp (TRUE);
  TempBmp := TBitmap.Create;
  TempBmp.PixelFormat := pf24bit;
  SetStretchBltMode(TempBmp.Canvas.Handle, HALFTONE);
  with TempBmp do
  begin
    Width := W;
    Height := H;
    Canvas.CopyRect (Rect (0, 0, W, H), Bmp.Canvas,
        MakeRect (BORDER_W, BORDER_H, W, H));
  end;
  CreateNewTile (TileTab[Tab.TabIndex].tbr);
  UpdateTileBitmap;
//  StartEdit;
  Bmp.Canvas.CopyRect (MakeRect (BORDER_W, BORDER_H, W, H),
      TempBmp.Canvas, Rect (0, 0, W, H));
  Bounds := bnd;
  BoundBox.RePaint;
  UpdateBmp (TRUE);
  DrawCursor;
  TempBmp.Free;
  Modified := TRUE;
end;

procedure TMainForm.SetBrightness(Sender: TObject);
  var
    N: Integer;
begin
  if Sender = N_1 then N := 0 else
  if Sender = N_2 then N := 1 else
  if Sender = N_3 then N := 2 else
  if Sender = N_4 then N := 3 else
  if Sender = N_5 then N := 4 else
  if Sender = N_6 then N := 5 else
  if Sender = N_7 then N := 6 else
  if Sender = N_8 then N := 7 else
  N := 8;
  FromToFirst := N;
  FromToLast := N;
  SetColor (FromToList[N], FALSE, FALSE);
  FromTo.Repaint;
end;

procedure TMainForm.PaletteDblClick(Sender: TObject);
begin
{  IgnorePaletteMouseDown := TRUE;
  ColorDialog.Color := Color.Brush.Color;
  if ColorDialog.Execute then
  begin
    ColorSelect := FALSE;
    SetColor (ColorDialog.Color, FALSE, FALSE);
  end;
  ShowRGB (ColorDialog.Color);
}
end;

procedure TMainForm.SetEditorMode (NewMode: TEditorMode);
  var
    TW, TH: Integer;
  const
    SPC_W = 3;
    SPC_H = 3;

  procedure Arrange (var p: TPanel;
                     var bmp: TImage;
                     var spm: TSpeedButton;
                     var spu: TSpeedButton;
                     var spr: TSpeedButton;  // 2.5
                     n: Integer);
  begin
    with p do
    begin
      Left := 4 + n * (TW + 2);
      Width := TW;
      Height := TH;
    end;
    spu.Top := p.Top + p.Height + SPC_H + 2;
    spm.Top := spu.Top;
    spr.Top := spu.Top;
    spu.Left := p.Left + p.Width div 3;
    spm.Left := spu.Left - spm.Width;
    spr.Left := spu.Left + spm.Width;

    with bmp do
    begin
      Left := SPC_W + BMFCenterAdd;
      Top := SPC_H;
      Width := W;
      Height := H;
    end;
    ResizeBitmap (bmp);
    FillBitmap (bmp, TRANS_COLOR);
    bmp.Picture.Bitmap.TransparentColor := TRANS_COLOR;
  end;

  var
    i: Integer;

begin  { SetEditorMode - switch Tile/Map mode }
  Mode := NewMode;

  ShowUsedColors1.Enabled := Mode = mTile;
  ShowCurrentPalette1.Enabled := Mode = mTile;

  ShowUsedColorPatterns1.Enabled := Mode = mTile;

  TileSelection.Visible := FALSE;

  ShiftState := [];

  for i := 0 to StatusBar.Panels.Count - 1 do
    StatusBar.Panels[i].Text := '';

  if Mode = mMap then
  begin
    AnimationTimer.Enabled := False;

    MapTab.Tabs.Clear;
    ClipTab.Tabs.Clear;
    SeqTab.Tabs.Clear;


    with TileTab[Tab.TabIndex] do
    begin
      for i := 0 to Length (tbr.Maps.aMaps) - 1 do
        MapTab.Tabs.Add (tbr.Maps.aMaps[i].id);
      MapTab.TabIndex := tbr.Maps.CurMap;

      for i := 0 to Length (tbr.Clip.aMaps) - 1 do
        ClipTab.Tabs.Add (IntToStr (i));
      ClipTab.TabIndex := tbr.Clip.CurMap;

      for i := 0 to Length (tbr.Seq.aMaps) - 1 do
        SeqTab.Tabs.Add (IntToStr (i));
      SeqTab.TabIndex := tbr.Seq.CurMap;

      Selection := FALSE;
      Area := Rect (0, 0, 0, 0);
    end;

    ScrollBox.Align := alNone;
    ScrollBox.Visible := FALSE;

    ToolPanel.Visible := FALSE;

    UsedColors.Visible := FALSE;
    PatternPanel.Visible := FALSE;
    ColorsPanel.Visible := FALSE;
    PalettePanel.Visible := FALSE;


    CurTilePanel.Visible := TRUE;
    TilePartsPanel.Visible := TRUE;

    TH := H + 2 * SPC_H;
    TW := (RightPanelWidth - 12) div 3;
    if TW < (W + 2 * SPC_W)  then
      TW := (W + 2 * SPC_W);
    BMFCenterAdd := (TW - (W + 2 * SPC_W)) div 2;

    RightPanel.Width := 3 * TW + 12;
    CurTilePanel.Height := TH + H + 10;
    TilePartsPanel.Height := TH + 8 + bMir.Height + 2 * SPC_H;

    Arrange (pBack, bmpBack, bMir, bUps, bRot, 0);
    Arrange (pMid, bmpMid, mMir, mUps, mRot, 1);
    Arrange (pFront, bmpFront, fMir, fUps, fRot, 2);

    pPreview.Width  := W + 2 * SPC_W;
    pPreview.Height := H + 2 * SPC_H;
    ResizeBitmap (bmpPreview);
    bmpPreview.Left    := SPC_W;
    bmpPreview.Top     := SPC_H;
    bmpPreview.Width   := 2 * W;
    bmpPreview.Height  := 2 * H;
    bmpPreview.Stretch := TRUE;
    pPreview.Width  := 2 * W + 2 * SPC_W;
    pPreview.Height := 2 * H + 2 * SPC_H;
    pPreview.Top  := 6;
    pPreview.Left := CurTilePanel.Width div 2 - pPreview.Width div 2;

    ShowSelectedTile;

    MapToolPanel.Visible := TRUE;
    ExtraPanel.Align := alBottom;
    ExtraPanel.Height := 100;
    ExtraPanel.Align := alTop;

    SeqTab.Align := alBottom;
    SeqTab.Visible := TRUE;
    SeqTab.Height := H + 2 * SPC_H + 32;

    ClipTab.Align := alClient;
    ClipTab.Visible := TRUE;

    MapTab.Align := alClient;
    MapTab.Visible := TRUE;

    Bounds := TileTab[Tab.TabIndex].tbr.mcr.Bounds;
    BoundBox.Hint := 'Bounds';

    SelectCurrentTile (TileTab[Tab.TabIndex].tbr.Current);
    DrawCurrentTile;
  end
  else
  if Mode = mTile then
  begin
    SeqTimer.Enabled := FALSE;


    ClipTab.Align := alNone;
    ClipTab.Visible := FALSE;
    SeqTab.Align := alNone;
    SeqTab.Visible := FALSE;
    MapTab.Align := alNone;
    MapTab.Visible := FALSE;


    TilePartsPanel.Visible := FALSE;
    CurTilePanel.Visible := FALSE;


    RightPanel.Width := RightPanelWidth;
    PalettePanel.Visible := TRUE;
    ColorsPanel.Visible := TRUE;
    PatternPanel.Visible := TRUE;

    ToolPanel.Visible := TRUE;

    ScrollBox.Align := alClient;
    ScrollBox.Visible := TRUE;

    ExtraPanel.Height := 65;
    MapToolPanel.Visible := FALSE;

    UsedColors.Visible := ShowUsedColors1.Checked or
                          ShowCurrentPalette1.Checked;
    ColorPatternsPanel.Visible := ShowUsedColorPatterns1.Checked;

    if Length (TileTab) > 0 then
      Bounds := GetBound (TileTab[Tab.TabIndex].tbr, -1)
    else
      Bounds := 0;
    BoundBox.Hint := 'Default Bounds';
  end;

  Up1.Enabled := Mode = mTile;  // 2.53
  Down1.Enabled := Mode = mTile;
  Left1.Enabled := Mode = mTile;
  Right1.Enabled := Mode = mTile;

  SelectNextClip1.Enabled := Mode = mMap;
  SelectPreviousClip1.Enabled := Mode = mMap;

  FirstFrame1.Enabled := Mode = mTile;
  LastFrame1.Enabled := Mode = mTile;
  NextFrame1.Enabled := Mode = mTile;
  PreviousFrame1.Enabled := Mode = mTile;
  Animate1.Enabled := Mode = mTile;
  Faster1.Enabled := Mode = mTile;
  Default1.Enabled := Mode = mTile;
  Slower1.Enabled := Mode = mTile;

  Pattern1.Enabled := Mode = mTile;
  FitInWindow1.Enabled := Mode = mTile;

  RemoveTileSet1.Enabled := Mode = mTile;

  SaveCurrentTile1.Enabled := Mode = mTile;
  ExportMapAsImage1.Enabled := Mode = mMap;

  SetGridGuidelines1.Enabled := Mode = mMap;

  NewTile1.Enabled := Mode = mTile;
  Clear1.Enabled := Mode = mTile;
  MatchColors1.Enabled := Mode = mTile;
  ReplaceColors1.Enabled := Mode = mTile;
  SplitColorPattern1.Enabled := Mode = mTile;
  Move1.Enabled := Mode = mTile;
  DuplicateTile1.Enabled := Mode = mTile;
  Flip1.Enabled := Mode = mTile;

  ToggleMultiple1.Enabled := Mode = mTile;
  N_1.Enabled := Mode = mTile;
  N_2.Enabled := Mode = mTile;
  N_3.Enabled := Mode = mTile;
  N_4.Enabled := Mode = mTile;
  N_5.Enabled := Mode = mTile;
  N_6.Enabled := Mode = mTile;
  N_7.Enabled := Mode = mTile;
  N_8.Enabled := Mode = mTile;
  N_9.Enabled := Mode = mTile;
  RearrangePalette1.Enabled := Mode = mTile;
  N61.Enabled := Mode = mTile;
  N71.Enabled := Mode = mTile;
  N81.Enabled := Mode = mTile;
  N91.Enabled := Mode = mTile;
  N101.Enabled := Mode = mTile;

  ConverttoTileSequence1.Enabled := FALSE;
  InsertTileSequence1.Enabled := FALSE;
  RemoveTileSequence1.Enabled := FALSE;
  ReplaceCurrentTileSequence1.Enabled := FALSE;

  FlipCurrentTile1.Enabled := Mode = mMap;
  SelectBackMidFront1.Enabled := Mode = mMap;
  SelectCurrentTile1.Enabled := Mode = mMap;

  ShowGrid1.Enabled := Mode = mMap;
  ShowMapCodes1.Enabled := Mode = mMap;
  ShowBounds1.Enabled := Mode = mMap;
  ClearArea1.Enabled := Mode = mMap;

  Properties1.Enabled := TRUE;
//  MapProperties1.Enabled := Mode = mMap;

  DrawingInMap := FALSE;
  ReadingFromMap := FALSE;

 // MapEditor1.Checked  := Sender = MapEditor1;
 // TileEditor1.Checked := Sender = TileEditor1;


  ShowTileGrid1.Enabled := Mode = mTile;

  ClearUndo;

  if Mode = mTile then
  begin
    StartEdit (TRUE);

    AnimationTimer.Enabled := Animate1.Checked;
  end
  else
  begin
    MapTabChange (nil);
    ClipTabChange (nil);
    SeqTabChange (nil);
  end;


  if Mode = mTile then
  begin
    MoveMapLeft1.Enabled := FALSE;  // 2.53
    MoveMapRight1.Enabled := FALSE;
    NextMap1.Enabled := FALSE;
    PreviousMap1.Enabled := FALSE;
  end;


  MapModeButton.Down := Mode = mMap;
  MapModeButton.Enabled := Mode <> mMap;
  TileModeButton.Down := Mode = mTile;
  TileModeButton.Enabled := Mode <> mTile;


  UndoButton.Visible := Mode = mTile;
  RedoButton.Visible := Mode = mTile;
  ToolButton3.Visible := Mode = mTile;

  NewTileButton.Visible := Mode = mTile;
  ColorMatchButton.Visible := Mode = mTile;
  ReplaceColorsButton.Visible := Mode = mTile;
  ToolButton5.Visible := Mode = mTile;

  AnimateButton.Visible := Mode = mTile;

  ShowStatusInfo;

  ShowMapLayer1.Enabled := Mode = mMap;  // 2.54
  if Mode = mMap then
  begin
    ShowBackLayer.Checked := TRUE;
    ShowMidLayer.Checked := TRUE;
    ShowFrontLayer.Checked := TRUE;
  end;

  // 3.00
  //HistoryPanel.Enabled := Mode = mTile;
  HistoryPanel.Visible := Mode = mTile;

end;

procedure TMainForm.BackgroundColor1Click(Sender: TObject);
begin
  ColorDialog.Color := Background.Brush.Color;
  if ColorDialog.Execute then
  begin
    SetBackgroundColor (ColorDialog.Color, FALSE);
    if (Mode = mMap) and (MapTab.TabIndex <> -1) then
      MapTabChange (Sender);
  end;
end;

procedure TMainForm.CopyTiles1Click(Sender: TObject);
  var
    i, j: Integer;
    ovr, str, scaler, bnds: Boolean;
begin
  with CopyTilesForm do
  begin
    Src.Text := TileTab[Tab.TabIndex].id;
    Src.Items := Tab.Tabs;
    Dst.Text := TileTab[Tab.TabIndex].id;
    Dst.Items := Tab.Tabs;
    with TileTab[Tab.TabIndex] do
    begin
      StartTile.Value := tbr.Current + 1;
      TileCount.Value := tbr.TileCount - tbr.Current;
    end;
    ShowModal;
    if Result then
    begin
      i := Src.Items.IndexOf (Src.Text);
      j := Src.Items.IndexOf (Dst.Text);
      if (i >= 0) and (j >= 0) { and (TileCount.Value > 0) } then   // 2.51 bug fix
      begin
        MainForm.ProgressPanel.Visible := TRUE;

        ovr := Overwrite.Enabled and Overwrite.Checked;
        str := Stretch.Enabled and Stretch.Checked;
        scaler := UseScaler.Enabled and UseScaler.Checked;
        bnds := CopyBounds.Enabled and CopyBounds.Checked;

        if (i = j) and (StartTile.Value = DstStartTile.Value) then
          ShowMessage ('Nothing to do.')
        else
          CopyTiles (TileTab[i].tbr,
                     TileTab[j].tbr,
                     StartTile.Value - 1,
                     TileCount.Value,
                     DstStartTile.Value - 1,
                     ovr, str, scaler, bnds,
                     i = j,
                     ProgressBar);

       // mainform.caption := debugstr;

        MainForm.ProgressPanel.Visible := FALSE;

        Tab.TabIndex := j;
        TabChange (Sender);
        StartEdit (TRUE);
        Modified := TRUE;
      end;

    end;
  end;
end;

procedure TMainForm.InsertNewTile1Click(Sender: TObject);
begin
  UpdateBmp (TRUE);
  InsertNewTile (TileTab[Tab.TabIndex].tbr, FALSE);
  UpdateTileBitmap;
  Modified := TRUE;
  StartEdit (TRUE);
end;

procedure TMainForm.PreviousTile1Click(Sender: TObject);
begin
  with TileTab[Tab.TabIndex].tbr do
    if Current > 0 then
    begin
      Dec (Current);
      StartEdit (FALSE);
    end;
  DrawCursor;
end;

procedure TMainForm.NextTile1Click(Sender: TObject);
begin
  with TileTab[Tab.TabIndex].tbr do
    if Current < TileCount - 1 then
    begin
      Inc (Current);
      StartEdit (FALSE);
    end
    else
      if Mode = mTile then
        NewTile1Click (Sender);
  DrawCursor;
end;

procedure TMainForm.FirstTile1Click(Sender: TObject);
begin
  with TileTab[Tab.TabIndex].tbr do
    Current := 0;
  StartEdit (FALSE);
end;

procedure TMainForm.LastTile1Click(Sender: TObject);
begin
  with TileTab[Tab.TabIndex].tbr do
    Current := TileCount - 1;
  StartEdit (FALSE);
end;

procedure TMainForm.StretchPaste1Click(Sender: TObject);
  var
    i, j, x, y: Integer;
    X1, Y1, X2, Y2: Integer;
begin
  if Mode = mTile then
  begin
    if Clipboard.HasFormat(CF_BITMAP) then
    begin
      X1 := BORDER_W;
      Y1 := BORDER_H;
      X2 := X1 + W;
      Y2 := Y1 + H;

      if TileSelection.Visible and
         (TileSelX2 <> TileSelX1) and
         (TileSelY2 <> TileSelY1) then
      begin
        X1 := TileSelX1;
        Y1 := TileSelY1;
        X2 := TileSelX2;
        Y2 := TileSelY2;
      end;

      SaveUndo ('Paste');
      ClipBmp.Assign(Clipboard);
      ClipBmp.Canvas.Draw(0, 0, ClipBmp);
      SetStretchBltMode(Bmp.Canvas.Handle, HALFTONE);
      with ClipBmp do
        Bmp.Canvas.CopyRect (Rect (X1, Y1, X2, Y2),
          ClipBmp.Canvas, MakeRect (0, 0, ClipBmp.Width, ClipBmp.Height));
      UpdateBmp (TRUE);
      TileSelection.Visible := FALSE;
      Modified := TRUE;
    end;
  end;
  if Mode = mMap then
    if Selection and (ClipTab.TabIndex > -1) and (clip <> nil) then
    begin
      with Area do
        for j := Top to Bottom do
          for i := Left to Right do
          begin
            y := (j - Top) mod ClipH;
            if ClipH > 2 then
              y := 1 + ((j - Top) mod (ClipH - 2));
            x := (i - Left) mod ClipW;
            if ClipW > 2 then
              x := 1 + ((i - Left) mod (ClipW - 2));
            if Top < Bottom then
            begin
              if j = Top then y := 0;
              if j = Bottom then y := ClipH - 1;
            end;
            if Left < Right then
            begin
              if i = Left then x := 0;
              if i = Right then x := ClipW - 1;
            end;
            lmp^.Map[j, i] := clip^.Map[y, x];
          end;
      Selection := FALSE;
      Modified := TRUE;
      UpdateMapRegion(Area);
    end;
end;

procedure TMainForm.ToggleMultiple1Click(Sender: TObject);
  var
    F, L: Integer;
begin
  F := LastFromToFirst;
  L := LastFromToLast;
  LastFromToFirst := FromToFirst;
  LastFromToLast := FromToLast;

  if FromToFirst = FromToLast then
  begin
    if F <> L then
    begin
      FromToFirst := F;
      FromToLast := L;
    end
    else
    begin
      FromToFirst := 0;
      FromToLast := MAX_FROM_TO - 1;
    end;
  end
  else
  begin
    if F = L then
    begin
      FromToFirst := F;
      FromToLast := L;
    end
    else
    begin
      FromToFirst := F + (L - F) div 2;
      FromToLast := FromToFirst;
    end;
  end;
  FromTo.Repaint;
end;


procedure TMainForm.SelectBackMidFront(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);

  procedure SetBevel (var p: TPanel; Down: Boolean);
  begin
    if Down then
    begin
      p.BevelInner := bvLowered;
      p.BevelOuter := bvLowered;
    end
    else
    begin
      p.BevelInner := bvRaised;
      p.BevelOuter := bvRaised;
    end;
  end;

  var
    LastBMF: Integer;
begin
  with TileTab[Tab.TabIndex].tbr do
  begin
    LastBMF := BackMidFront;
    if (Sender = pBack) or (Sender = bmpBack) then
      BackMidFront := -1
    else if (Sender = pFront) or (Sender = bmpFront) then
      BackMidFront := 1
    else
      BackMidFront := 0;

    if Button = mbLeft then
      SelectCurrentTile (Current)
    else
      if BackMidFront = LastBMF then
        SelectCurrentTile (-1);
  end;
  ShowSelectedTile;
end;

procedure TMainForm.ShowSelectedTile;

  procedure SetBevel (var p: TPanel; Down: Boolean);
  begin
    if Down then
    begin
      p.BevelInner := bvLowered;
      p.BevelOuter := bvLowered;
    end
    else
    begin
      p.BevelInner := bvRaised;
      p.BevelOuter := bvRaised;
    end;
  end;

begin
  with TileTab[Tab.TabIndex].tbr do
  begin
    SetBevel (pBack, BackMidFront = -1);
    SetBevel (pMid, BackMidFront = 0);
    SetBevel (pFront, BackMidFront = 1);
  end;
  DrawCurrentTile;
end;

procedure TMainForm.DrawTile (TabIndex, N: Integer;
            var bmp: TImage;
            var Mir: Boolean;
            var Ups: Boolean;
            var Rot: Boolean;
            var FullBmp: TImage);
  var
    Tile: Integer;
    RR: TRect;
    m, u, r: Boolean;
    MirW, UpsH: Integer;
    i, j: Integer;
    TmpBmp1, TmpBmp2: TBitmap;

begin
  with TileTab[TabIndex].tbr do
  begin

    if n = -1 then
    begin
      Mir := FALSE;
      Ups := FALSE;
      Rot := FALSE;
      FillBitmap (bmp, TRANS_COLOR);
    end
    else
    begin
      m := n and MIRROR_MASK = MIRROR_MASK;
      u := n and UPS_MASK = UPS_MASK;
      r := n and ROTATE_MASK = ROTATE_MASK;
      Mir := m;
      Ups := u;
      Rot := r;
      MirW := Byte (m);
      UpsH := Byte (u);
      Tile := n and TILE_MASK;
      RR := Rect (MirW * (W - 1),
                  UpsH * (H - 1),
                  W - MirW * (W + 1),
                  H - UpsH * (H + 1));
      bmp.Canvas.CopyRect (RR, TileBitmap.Canvas,
             MakeRect (tile * W, 0, W, H));

      if r then
      begin
        TmpBmp1 := TBitmap.Create;
        SetStretchBltMode(TmpBmp1.Canvas.Handle, HALFTONE);
        with TmpBmp1 do
        begin
          PixelFormat := pf24bit;
          Width := W;
          Height := H;
          Transparent := TRUE;
          TransparentColor := TRANS_COLOR;
          for j := 0 to Height - 1 do
            for i := 0 to Width - 1 do
              Canvas.Pixels[i, j] := Bmp.Canvas.Pixels[i, j];
        end;
        TmpBmp2 := TBitmap.Create;
        SetStretchBltMode(TmpBmp2.Canvas.Handle, HALFTONE);
        with TmpBmp2 do
        begin
          PixelFormat := pf24bit;
          Width := H;
          Height := W;
          Transparent := TRUE;
          TransparentColor := TRANS_COLOR;
          for j := 0 to Height - 1 do
            for i := 0 to Width - 1 do
              Canvas.Pixels[i, j] := TRANS_COLOR;
          Canvas.StretchDraw (Rect (0, 0, H, W), TmpBmp1);
        end;
        for j := 0 to H - 1 do
          for i := 0 to W - 1 do
            bmp.Canvas.Pixels[i, j] := TmpBmp2.Canvas.Pixels[j, W - 1 - i];
        TmpBmp1.Free;
        TmpBmp2.Free;
      end;

      FullBMP.Canvas.Draw (0, 0, bmp.Picture.Graphic);
    end;
  end;
end;


procedure TMainForm.DrawCurrentTile;
  var
    m, u, r: Boolean;
    s: string;
    tx, ty, tw, th: Integer;
    ti: Integer;
    ov: Integer;
begin
  FillBitmap (bmpPreview, BackGround.Brush.Color);

  ti := Tab.TabIndex;
  with TileTab[ti].tbr do
  begin
    DrawTile (ti, mcr.Back, bmpBack, m, u, r, bmpPreview);
    bMir.Down := m;
    bUps.Down := u;
    bRot.Down := r;
    DrawTile (ti, mcr.Mid, bmpMid, m, u, r, bmpPreview);
    mMir.Down := m;
    mUps.Down := u;
    mRot.Down := r;
    DrawTile (ti, mcr.Front, bmpFront, m, u, r, bmpPreview);
    fMir.Down := m;
    fUps.Down := u;
    fRot.Down := r;

    ov := TileTab[Tab.TabIndex].tbr.Overlap;
    if (ShowBounds1.Checked) and (mcr.Bounds <> 0) then
      DrawBounds (bmpPreview.Canvas, 0, ov, W, H, 1, mcr.Bounds, clWhite);

    if (ShowMapCodes1.Checked) and (mcr.MapCode <> 0) then
    begin
      FillBitmap (bmp1, TRANS_COLOR);
      with bmp1.Picture.Bitmap.Canvas do
      begin
        s := Hex2 (mcr.MapCode);
        tw := TextWidth (s);
        th := TextHeight (s);
        tx := W div 2 - tw div 2;
        ty := H div 2 - th div 2;
        Font.Color := clBlack;
        TextOut (tx, ty, s);
        bmpPreview.Picture.Bitmap.Canvas.Draw (0, 0, bmp1.Picture.Bitmap);
        Font.Color := clWhite;
        TextOut (tx, ty, s);
        bmpPreview.Picture.Bitmap.Canvas.Draw (-1, -1, bmp1.Picture.Bitmap);
      end;
    end;

  end;

  BoundBox.Repaint;
  if Mode = mMap then
    with MapCodeButton do
      Caption := Hex2 (TileTab[Tab.TabIndex].tbr.mcr.MapCode);
end;

procedure TMainForm.SelectCurrentTile (n: Integer);
  var
    i, j, k, Bnds: Integer;
begin
  with TileTab[Tab.TabIndex].tbr do
  begin
    Bnds := 0;
    if n < TileCount then
    begin
      k := n;
      Bnds := GetBound (TileTab[Tab.TabIndex].tbr, -1);
    end
    else
      k := -1;
    if k = -1 then
      case BackMidFront of
        -1: if HasCurrentBounds (mcr.Back) then
              MainForm.Bounds := 0;
         0: if HasCurrentBounds (mcr.Mid) then
              MainForm.Bounds := 0;
         1: if HasCurrentBounds (mcr.Front) then
              MainForm.Bounds := 0;
      end
    else
      if Bnds <> 0 then
        if Mode = mTile then
          mcr.Bounds := Bnds
        else
          MainForm.Bounds := Bnds;
    case BackMidFront of
      -1: mcr.Back := k;
       0: mcr.Mid := k;
       1: mcr.Front := k;
    end;
    mcr.MapCode := 0;

    if Selection then
    begin
      for j := Area.Top to Area.Bottom do
        for i := Area.Left to Area.Right do
        begin
          with lmp^.Map[j, i] do
            case BackMidFront of
              -1: Back := k;
               0: Mid := k;
               1: Front := k;
            end;
        end;
      Selection := FALSE;
      UpdateMapRegion(Area);
    end;

  end;
end;


procedure TMainForm.MirTileMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  with Sender as TSpeedButton do
    Down := TRUE;

end;

function TMainForm.HasCurrentBounds (Tile: SmallInt): Boolean;
  var
    i: Integer;
    b: Integer;
    m, u: Boolean;
begin
  Result := FALSE;
  if Tile <> -1 then
  begin
    i := Tile and TILE_MASK;
    m := Tile and MIRROR_MASK <> 0;
    u := Tile and UPS_MASK <> 0;
    b := GetBound (TileTab[Tab.TabIndex].tbr, i);
    if m then
      HFlipBounds (b);
    if u then
      VFlipBounds (b);
    Result := b = Bounds;
  end;
end;

procedure TMainForm.fUpsClick(Sender: TObject);

  procedure Flip (m, u, r: Boolean; var Tile: SmallInt);
  begin
    if Tile <> -1 then
    begin
      if m then
      begin
        if HasCurrentBounds (Tile) then
          HFlipBounds (Bounds);
        Tile := SmallInt (Word (Tile) xor MIRROR_MASK);
      end;
      if u then
      begin
        if HasCurrentBounds (Tile) then
          VFlipBounds (Bounds);
        Tile := SmallInt (Word (Tile) xor UPS_MASK);
      end;
      if r then
      begin
        if HasCurrentBounds (Tile) then
          RotateBounds (Bounds, -90);
        Tile := SmallInt (Word (Tile) xor ROTATE_MASK);
      end;
    end;
  end;

begin
  with TileTab[Tab.TabIndex].tbr.mcr do
  begin
    Flip (Sender = bMir, Sender = bUps, Sender = bRot, Back);
    Flip (Sender = mMir, Sender = mUps, Sender = mRot, Mid);
    Flip (Sender = fMir, Sender = fUps, Sender = fRot, Front);
  end;
  DrawCurrentTile;
end;

procedure FlipBit (var i: SmallInt; Mask: Integer);
begin
  if i <> -1 then
    i := i xor SmallInt (Mask);
end;

procedure TMainForm.MirSwap (var mcr1: MapCellRec; var mcr2: MapCellRec; MirBoth: Boolean);
  var
    mcr: MapCellRec;
    i: Integer;
begin
  mcr := mcr1;
  mcr1 := mcr2;
  mcr2 := mcr;

  i := mcr1.Bounds;
  HFlipBounds (i);
  mcr1.Bounds := i;
  with mcr1 do
  begin
    FlipBit (Back, MIRROR_MASK);
    FlipBit (Mid, MIRROR_MASK);
    FlipBit (Front, MIRROR_MASK);
  end;

  if MirBoth then
  begin
    i := mcr2.Bounds;
    HFlipBounds (i);
    mcr2.Bounds := i;
    with mcr2 do
    begin
      FlipBit (Back, MIRROR_MASK);
      FlipBit (Mid, MIRROR_MASK);
      FlipBit (Front, MIRROR_MASK);
    end;
  end;
end;

procedure TMainForm.UpsSwap (var mcr1: MapCellRec; var mcr2: MapCellRec; MirBoth: Boolean);
  var
    mcr: MapCellRec;
    i: Integer;
begin
  mcr := mcr1;
  mcr1 := mcr2;
  mcr2 := mcr;

  i := mcr1.Bounds;
  VFlipBounds (i);
  mcr1.Bounds := i;
  with mcr1 do
  begin
    FlipBit (Back, UPS_MASK);
    FlipBit (Mid, UPS_MASK);
    FlipBit (Front, UPS_MASK);
  end;

  if MirBoth then
  begin
    i := mcr2.Bounds;
    VFlipBounds (i);
    mcr2.Bounds := i;
    with mcr2 do
    begin
      FlipBit (Back, UPS_MASK);
      FlipBit (Mid, UPS_MASK);
      FlipBit (Front, UPS_MASK);
    end;
  end;
end;

procedure TMainForm.Horizontal2Click(Sender: TObject);
  var
    i, j, k, l: Integer;
begin
  if Mode <> mMap then
    Exit;
  if Selection then
  begin
    k := (Area.Right - Area.Left + 2) div 2;
    for j := Area.Top to Area.Bottom do
      for i := Area.Left to (Area.Left + k - 1) do
      begin
        l := Area.Right - (i - Area.Left);
        MirSwap (lmp^.Map[j, i], lmp^.Map[j, l], i <> l);
      end;
    Modified := TRUE;
  // Selection := FALSE;
    UpdateMapRegion(Area);
  end
  else
    with TileTab[Tab.TabIndex].tbr do
    case BackMidFront of
      -1: fUpsClick (bMir);
       0: fUpsClick (mMir);
       1: fUpsClick (fMir);
    end;
end;

procedure TMainForm.Vertical2Click(Sender: TObject);
  var
    i, j, k, l: Integer;
begin
  if Mode <> mMap then
    Exit;
  if Selection then
  begin
    k := (Area.Bottom - Area.Top + 2) div 2;
    for j := Area.Top to Area.Top + k - 1 do
      for i := Area.Left to Area.Right do
      begin
        l := Area.Bottom - (j - Area.Top);
        UpsSwap (lmp^.Map[j, i], lmp^.Map[l, i], j <> l);
      end;
    Modified := TRUE;
  // Selection := FALSE;
    UpdateMapRegion(Area);
  end
  else
    with TileTab[Tab.TabIndex].tbr do
    case BackMidFront of
      -1: fUpsClick (bUps);
       0: fUpsClick (mUps);
       1: fUpsClick (fUps);
    end;
end;

procedure TMainForm.SelectCurrentTile1Click(Sender: TObject);
begin
  SelectCurrentTile (TileTab[Tab.TabIndex].tbr.Current);
  DrawCurrentTile;
end;

procedure TMainForm.Next1Click(Sender: TObject);
begin
  with TileTab[Tab.TabIndex].tbr do
  begin
    Inc (BackMidFront, 2);
    BackMidFront := BackMidFront mod 3;
    Dec (BackMidFront);
  end;
  ShowSelectedTile;
end;

procedure TMainForm.Previous1Click(Sender: TObject);
begin
  with TileTab[Tab.TabIndex].tbr do
  begin
    BackMidFront := (BackMidFront + 3) mod 3;
    Dec (BackMidFront);
  end;
  ShowSelectedTile;
end;

procedure TMainForm.ToggleTileMapEditor1Click(Sender: TObject);
begin
  if Mode = mTile then
    SetEditorMode (mMap)
  else
    if Mode = mMap then
      SetEditorMode (mTile);
end;

procedure TMainForm.MapCodeButtonClick(Sender: TObject);
  var
    i, j: Integer;
begin
  MapCode.Value := TileTab[Tab.TabIndex].tbr.mcr.MapCode;
  MapCode.ShowModal;
  TileTab[Tab.TabIndex].tbr.mcr.MapCode := MapCode.Value;
 // if MapCode.Value < $A then
  MapCodeButton.Caption := Hex2 (MapCode.Value);
  ShowSelectedTile;

  if Selection then
  begin
    for j := Area.Top to Area.Bottom do
      for i := Area.Left to Area.Right do
        lmp^.Map[j, i].MapCode := MapCode.Value;
    { RD: Clear selection; redraw area }
    Selection := FALSE;
    UpdateMapRegion(Area);
  end;

 // else
 //   MapCodeButton.Caption := '0x' + Hex2 (MapCode.Value);
end;

procedure TMainForm.Map1Click(Sender: TObject);
begin
  with NewForm do
  begin
    NewMode := nmNewMap;
    CreateNew := TRUE;
    DefaultName := NewMapName;
    CanChangeSize := TRUE;
    DefaultOverlap := TileTab[Tab.TabIndex].tbr.Overlap;
    ShowModal;

    if Result then
      if MapTab.Tabs.IndexOf (Identifier.Text) <> -1 then  // bug fix
        Msg ('Name ' + Identifier.Text + ' already in use.')
      else
      begin
        NewMap (TileTab[Tab.TabIndex].tbr, Identifier.Text, NH.Value, NV.Value);

        MapTab.TabIndex := MapTab.Tabs.Add (Identifier.Text);
        MapTabChange (Sender);

        with TileTab[Tab.TabIndex].tbr do
          Maps.aMaps[Maps.CurMap].SkipExport := Skip.Checked;  // 2.2

        if Mode = mTile then
          SetEditorMode (mMap);
      end;
  end;
end;

procedure TMainForm.ShowUsedColors1Click(Sender: TObject);
  var
    bmp: TBitmap;
    x, y: Integer;
    i, j, k: Integer;
    Found: Boolean;
    ai: array of Integer;
    ColorMask: Integer;
begin
  if N61.Checked then
    ColorMask := $FCFCFC
  else
    if N71.Checked then
      ColorMask := $FEFEFE
    else
      ColorMask := $FFFFFF;
  with ShowUsedColors1 do
  begin
    Checked := not Checked;
    if Checked then
    begin
      with ProgressBar do
      begin
        Min := 0;
        with TileTab[Tab.TabIndex].tbr.TileBitmap do
          Max := Width * Height;
        Position := Min;
      end;
      ProgressPanel.Visible := TRUE;
      bmp := TBitmap.Create;
      SetStretchBltMode(bmp.Canvas.Handle, HALFTONE);
      with bmp do
      begin
        PixelFormat := pf24bit;
        Width := 1;
        Height := 1;
        Canvas.Pixels[0, 0] := TRANS_COLOR;
        k := 1;
        SetLength (ai, k);
        ai[0] := TRANS_COLOR;
        with TileTab[Tab.TabIndex].tbr.TileBitmap do
          for y := 0 to Height - 1 do
          begin
            for x := 0 to Width - 1 do
            begin
              i := Canvas.Pixels[x, y];
              if i <> TRANS_COLOR then
                i := (i and ColorMask);
              Found := FALSE;
              for j := 0 to k - 1 do
                if not Found then
              //    if bmp.Canvas.Pixels[0, j] = i then
                  if ai[j] = i then
                    Found := TRUE;
              if not Found then
              begin
                Inc (k);
                SetLength (ai, k);
                ai[k - 1] := i;
                bmp.Height := k;
                bmp.Canvas.Pixels[0, k - 1] := i;
              end;
              if x mod 16 = 0 then
                ProgressBar.Position := y * Width + x;
            end;
          end;
        Canvas.Pixels[0, 0] := BackGround.Brush.Color;
        SetLength (ai, 0);
      end;
      ProgressPanel.Visible := FALSE;
      UsedColorsImage.Picture.Bitmap := bmp;
      UsedColors.Hint := IntToStr (bmp.Height) + ' colors used';
      UsedColors.ShowHint := TRUE;
      bmp.Free;
      UsedColorsImage.Stretch := TRUE;
      UsedColors.Visible := TRUE;
      MainForm.Resize;
    end
    else
      HideUsedColors;
  end;
  UsedColorSelect := FALSE;
end;

procedure TMainForm.HideUsedColors;
begin
  if UsedColors.Visible then
  begin
    UsedColors.Visible := FALSE;
    ShowUsedColors1.Checked := FALSE;
    ShowCurrentPalette1.Checked := FALSE;
    MainForm.Resize;
  end;
  UsedColorSelect := FALSE;
end;

procedure TMainForm.UsedColorsImageMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  UsedColorSelect := TRUE;
  UsedColorsImageMouseMove (Sender, Shift, X, Y);
end;

procedure TMainForm.UsedColorsImageMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
  var
    c, j: Integer;
begin
  with UsedColorsImage.Picture do
  begin
    j := y * Bitmap.Height div UsedColorsImage.Height;
    c := Bitmap.Canvas.Pixels[0, j];
    ShowRGB (c);  // 2.51
  end;
  if UsedColorSelect then
    SetColor (c, FALSE, FALSE)
end;

procedure TMainForm.UsedColorsImageMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Color.Brush.Color = BackGround.Brush.Color then
    SetBackGroundColor (Color.Brush.Color, TRUE);
  UsedColorSelect := FALSE;
end;

procedure TMainForm.MapProperties1Click(Sender: TObject);
begin
  if MapTab.TabIndex > -1 then
  with NewForm do
  begin
    NewMode := nmMapProperties;
    CreateNew := FALSE;
    DefaultName := MapTab.Tabs.Strings[MapTab.TabIndex];

    with TileTab[Tab.TabIndex].tbr do
      Skip.Checked := Maps.aMaps[Maps.CurMap].SkipExport; // 2.2

    with lmp^ do
    begin
      NH.Value := Length (Map[0]);
      NV.Value := Length (Map);
    end;
    CanChangeSize := TRUE;
    DefaultOverlap := TileTab[Tab.TabIndex].tbr.Overlap;

    // todo: something causes a breakpoint in ntdll.dll here
    ShowModal;

    if Result then
    begin
      if Identifier.Text <> DefaultName then
        if MapTab.Tabs.IndexOf (Identifier.Text) <> -1 then   // bug fix
        begin
          Msg ('Name ' + Identifier.Text + ' already in use.');
          Identifier.Text := DefaultName;
        end;

      with lmp^ do
      begin
        Id := Identifier.Text;
        SetMapSize (Map, NH.Value, NV.Value);
      end;
      MapTab.Tabs.Strings[MapTab.TabIndex] := Identifier.Text;
      MapTabChange (Sender);

      with TileTab[Tab.TabIndex].tbr do
        Maps.aMaps[Maps.CurMap].SkipExport := Skip.Checked;  // 2.2

      if Mode = mTile then
        SetEditorMode (mMap);
      { RD: Redraw whole map (with altered dimensions) }
      UpdateMap;
    end;
  end;

end;

procedure TMainForm.GetMCRTile (var MCR: MapCellRec; var Tile: Integer;
                                var Mir: Boolean; var Ups: Boolean);
begin
  with MCR do
    case TileTab[Tab.TabIndex].tbr.BackMidFront of
     -1: Tile := Back;
      0: Tile := Mid;
      1: Tile := Front;
    end;
  if Tile <> -1 then
  begin
    Mir := (Tile and MIRROR_MASK) <> 0;
    Ups := (Tile and UPS_MASK) <> 0;
    Tile := Tile and TILE_MASK;
  end
  else
  begin
    Mir := FALSE;
    Ups := FALSE;
  end;
end;

procedure TMainForm.SetMCRTile (var MCR: MapCellRec; Tile: Integer;
                                Mir, Ups: Boolean);
begin
  if Tile <> -1 then
  begin
    if Mir then Tile := Tile or MIRROR_MASK;
    if Ups then Tile := Tile or UPS_MASK;
  end;
  with MCR do
    case TileTab[Tab.TabIndex].tbr.BackMidFront of
     -1: Back := SmallInt (Tile);   // 2.54: bugfix (Range check error)
      0: Mid := SmallInt (Tile);
      1: Front := SmallInt (Tile);
    end;
  Modified := TRUE;
end;

procedure TMainForm.AddMCR (var MCR: MapCellRec; n: Integer);
  var
    Tile: Integer;
    m, u: Boolean;
    Max: Integer;
begin
  GetMCRTile (MCR, Tile, m, u);
  if Tile < 0 then
  begin
    Tile := TileTab[Tab.TabIndex].tbr.Current;
    m := FALSE;
    u := FALSE;
  end;
  Inc (Tile, n);
  Max := TileTab[Tab.TabIndex].tbr.TileCount;  /// - 1;
  if Max < 1 then
    Max := 1;
  Tile := Tile mod Max;
  SetMCRTile (MCR, Tile, m, u);
end;

procedure TMainForm.DrawMap (Area: TRect; ExportingImage: Boolean; Clp, Sq: Boolean);
  var
    i, j, tx, ty, tw, th, tmpw, tmph, min_i, min_j, ii, jj: Integer;
    mcr: MapCellRec;
    m, u, r: Boolean;
    DrawAll: Boolean;
    s: string;
    X1, Y1, X2, Y2, EY1, EY2: Integer;
    bmpBitmap: TBitmap;
    ptr: LayerMapPtr;
    ov: Integer;
    Selected, CellSelected: Boolean;
    CL1, CL2: Integer;
begin

  min_i := 0;
  min_j := 0;

  Selected := false;
  if Selection then Selected := true;
  if DrawingInMap and (MapDrawingTool in [mdtFilledRect, mdtRect, mdtZOrder]) then
    Selected := true;
  if Sq or Clp then
    Selected := false;

  SkipDraw := TRUE;
  DrawAll := (Area.Left = 0) and (Area.Top = 0) and
             (Area.Right = -1) and (Area.Bottom = -1);

  ov := TileTab[Tab.TabIndex].tbr.Overlap;

  if Sq then
  begin
    ptr := seq;
    bmpBitmap := SeqBitmap.Picture.Bitmap;
    DrawAll := FALSE;
  end
  else
  begin
    if Clp then
    begin
      ptr := clip;
      bmpBitmap := ClipBitmap.Picture.Bitmap;
    end
    else
    begin
      ptr := lmp;
      if ExportingImage then  // 2.5
        bmpBitmap := bmpMapImage
      else
        bmpBitmap := bmpMap;
    end;
  end;

  if ptr <> nil then
    with ptr^ do
      if Length (Map) > 0 then
      begin
        if not Sq then
        begin
          CurMapH := Length (Map);
          CurMapW := Length (Map[0]);
          if Clp or ExportingImage then  // 2.51 bug fix
          begin
            bmpBitmap.Width := CurMapW * W;
            bmpBitmap.Height := CurMapH * (H - ov);
          end
          else
          begin
            bmpBitmap.Width := (VisibleMapRegion.Right - VisibleMapRegion.Left + 1) * W;
            bmpBitmap.Height := (VisibleMapRegion.Bottom - VisibleMapRegion.Top + 1) * (H - ov);
          end;
        end;

       // ResizeBitmap (bmpMap);
        if DrawAll then
        begin
          X1 := 0;
          Y1 := 0;
          X2 := CurMapW - 1;
          Y2 := CurMapH - 1;
        end
        else
        begin
          X1 := Area.Left;
          Y1 := Area.Top;
          X2 := min(Area.Right, CurMapW - 1);
          Y2 := min(Area.Bottom, CurMapH - 1);
        end;

        if not (Clp or Sq or ExportingImage) then   // 2.51 bug fix
        begin
          X1 := max(X1, VisibleMapRegion.Left);
          Y1 := max(Y1, VisibleMapRegion.Top);
          X2 := min(X2, VisibleMapRegion.Right);
          Y2 := min(Y2, VisibleMapRegion.Bottom);
          min_i := VisibleMapRegion.Left;
          min_j := VisibleMapRegion.Top;
        end;

        EY1 := Y1;
        EY2 := Y2;

      {
        // 2.5 - removed

        if (not (Sq or Clp)) and (ov > 0) then
        begin
          if EY1 > 0 then Dec (EY1);
          if EY2 < SizeOf ??? (map) then Inc (EY2);
        end;
      }

        ///*

        begin
          for j := EY1 to EY2 do
            for i := X1 to X2 do
             // if DrawAll or Inside (i, j, Area) then
              begin
                mcr := map[j, i];
                CellSelected := Selected and Inside(i, j, Self.Area);
                FillBitmap (bmp1, TRANS_COLOR);
                if Sq then
                  FillBitmap (bmp2, BackGround.Brush.Color)
                else
                  FillBitmap (bmp2, TRANS_COLOR);

                if ShowGrid1.Checked then
                  with bmp2.Picture.Bitmap.Canvas do
                  begin
                    CL1 := clBlack;
                    CL2 := clWhite;

                    if MapGridX > 0 then   // 2.54
                    begin
                      if i mod MapGridX = 0 then CL1 := clRed;
                      if (i + 1) mod MapGridX = 0 then CL2 := clRed;
                    end;
                    if MapGridY > 0 then
                    begin
                      if j mod MapGridY = 0 then CL1 := clRed;
                      if (j + 1) mod MapGridY = 0 then CL2 := clRed;
                    end;

                    if MapGridX > 0 then
                      for jj := ov to H - 1 do
                      begin
                        if i mod MapGridX = 0 then Pixels[0, jj] := clWhite;
                        if (i + 1) mod MapGridX = 0 then Pixels[W - 1, jj] := clBlack;
                      end;

                    if MapGridY > 0 then
                      for ii := 0 to W - 1 do
                      begin
                        if j mod MapGridY = 0 then Pixels[ii, ov] := clWhite;
                        if (j + 1) mod MapGridY = 0 then Pixels[ii, H - 1] := clBlack;
                      end;

                    Pixels[0, 0 + ov] := CL1;
                    Pixels[W - 1, H - 1] := CL2;
                  end;

               // if mcr.Bounds <> $FF then
                if mcr.Bounds and $40 = 0 then  // 2.55
                begin
                  if CellSelected then
                  begin
                    if MapDrawingTool in [mdtFilledRect, mdtZOrder] then
                    begin
                      mcr := TileTab[Tab.TabIndex].tbr.mcr;
                      if MapDrawingTool in [mdtZOrder] then
                        AddMCR (mcr, i - X1 + (j - Y1) * (X2 - X1 + 1));
                    end;
                  end;
                  if mcr.Back <> -1 then
                    if ShowBackLayer.Checked then
                      DrawTile (Tab.TabIndex, mcr.Back, bmp1, m, u, r, bmp2);
                  if mcr.Mid <> -1 then
                    if ShowMidLayer.Checked then
                      DrawTile (Tab.TabIndex, mcr.Mid, bmp1, m, u, r, bmp2);
                  if mcr.Front <> -1 then
                    if ShowFrontLayer.Checked then
                      DrawTile (Tab.TabIndex, mcr.Front, bmp1, m, u, r, bmp2);
                end;

                if sq then
                  bmpBitmap.Canvas.CopyRect
                    (MakeRect (0, 0, W, H),
                     bmp2.Picture.Bitmap.Canvas,
                     Rect (0, 0, W, H))
                else
                begin

                 // if mcr.Bounds <> $FF then  // 2.55
                 // if mcr.Bounds <> 0 then
              //     if mcr.Bounds and $40 = 0 then   // allow bounds with sequences
                  begin
                    if CellSelected then
                      if MapDrawingTool in [mdtRect] then
                        bmp2.Picture.Bitmap.Canvas.Draw (0, 0, SelBmp.Picture.Bitmap);

                    if ShowBounds1.Checked then
                      DrawBounds (bmp2.Canvas, 0, ov, W, H, 1, mcr.Bounds, clWhite);
                  end;

                  if (ShowMapCodes1.Checked and (mcr.MapCode <> 0)) or
                    // (mcr.Bounds = $FF) then  // 2.55
                    // (mcr.Bounds < 0) then
                      (mcr.Bounds and $40 <> 0) then
                    begin
                      FillBitmap (bmp1, TRANS_COLOR);
                      with bmp1.Picture.Bitmap.Canvas do
                      begin
                        s := Hex2 (mcr.MapCode);
                        tw := TextWidth (s);
                        th := TextHeight (s);
                        tx := W div 2 - tw div 2;
                        ty := ov + (H - ov) div 2 - th div 2;
                        Font.Color := clBlack;
                        TextOut (tx, ty, s);
                        bmp2.Picture.Bitmap.Canvas.Draw (0, 0, bmp1.Picture.Bitmap);
                        Font.Color := clWhite;
                       // if mcr.Bounds = $FF then
                       // if mcr.Bounds < 0 then  // 2.55
                        if mcr.Bounds and $40 <> 0 then
                          Font.Color := clRed;
                        TextOut (tx, ty, s);
                        bmp2.Picture.Bitmap.Canvas.Draw (-1, -1, bmp1.Picture.Bitmap);
                      end;
                    end;

                  if ExportingImage then
                   // if (not ShowMapCodes1.Checked) and (mcr.Bounds = $FF) then  // 2.55
                    if (not ShowMapCodes1.Checked) and (mcr.Bounds and $40 <> 0) then
                    begin
                      SeqTab.TabIndex := mcr.MapCode;
                      SkipDraw := FALSE;
                      SeqTabChange (nil);
                      SkipDraw := TRUE;
                      bmp2.Picture.Bitmap.Canvas.Draw (0, 0, SeqBitmap.Picture.Bitmap);
                    end;

                  bmp1.Picture.Bitmap.Canvas.CopyRect
                    (MakeRect (0, 0, W, H),
                     bmp2.Picture.Bitmap.Canvas,
                       Rect (0, 0, W, H));

                  FillBitmap (bmp2, BackGround.Brush.Color);
                  bmp2.Picture.Bitmap.Canvas.Draw (0, 0, bmp1.Picture.Bitmap);

                  if (j >= Y1) and (j <= Y2) then
                    bmpBitmap.Canvas.CopyRect
                      (MakeRect ((i - min_i) * W, (j - min_j) * (H - ov), W, H - ov),
                       bmp2.Picture.Bitmap.Canvas,
                       Rect (0, 0 + ov, W, H));

                  if (ov > 0) then
                    if (j > Y1) or (not CellSelected) then
                      with bmp1.Picture.Graphic do
                      begin
                        tmpw := Width;
                        tmph := Height;
                        Width := W;
                        Height := ov;
                        bmpBitmap.Canvas.Draw
                          ((i - min_i) * W, (j - min_j) * (H - ov) - ov,
                           bmp1.Picture.Graphic);
                        Width := tmpw;
                        Height := tmph;
                      end;

                end;

              end;
        end;
      end;

  SkipDraw := FALSE;
end;

procedure TMainForm.ZoomMap;
  var
    z1, z2: Integer;
begin
//  MapDisplay.Width := bmpMap.Width * ZOOM_FACTOR div Zoom;
//  MapDisplay.Height := bmpMap.Height * ZOOM_FACTOR div Zoom;

  ZoomIn1.Enabled := (Zoom > 1);
  ZoomOut1.Enabled := (Zoom < MAX_ZOOM);
  z1 := ZOOM_FACTOR;
  z2 := Zoom;
  if (z1 mod 3 = 0) and (z2 mod 3 = 0) then
  begin
    z1 := z1 div 3;
    z2 := z2 div 3;
  end;
  if (z1 mod 2 = 0) and (z2 mod 2 = 0) then
  begin
    z1 := z1 div 2;
    z2 := z2 div 2;
  end;
  StatusBar.Panels[4].Text := Format ('%d:%d', [z1, z2]);
end;

procedure TMainForm.MapTabChange(Sender: TObject);
  var
    tw, th: integer;
begin
 // SeqTimer.Enabled := FALSE;
  if MapTab.TabIndex >= 0 then
  begin
    MapDisplay.Visible := TRUE;

    // 2.42
    with TileTab[Tab.TabIndex].tbr.Maps.aMaps[MapTab.TabIndex] do
    begin
      CurMapH := Length (Map);
      CurMapW := Length (Map[0]);
    end;
    with TileTab[Tab.TabIndex].tbr do
    begin
      tw := W * ZOOM_FACTOR div Zoom;
      th := (H - Overlap) * ZOOM_FACTOR div Zoom;
    end;
    MapDisplay.Width := tw * CurMapW;
    MapDisplay.Height := th * CurMapH;

    ZoomIn1.Enabled := (Zoom > 1);
    ZoomOut1.Enabled := (Zoom < MAX_ZOOM);

    UpdateMap;
  end
  else
    MapDisplay.Visible := FALSE;

  ShowStatusInfo;  // 2.53

  Selection := FALSE;
  Area := Rect (0, 0, 0, 0);
end;

procedure TMainForm.ShowGrid1Click(Sender: TObject);
begin
  ShowGrid1.Checked := not ShowGrid1.Checked;
  if ShowGrid1.Checked then
    ShowGrid1.Tag := ShowGrid1.Tag + 1;
  UpdateMap;
end;

procedure TMainForm.bmpMapMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
  var
    MapX, MapY: Integer;
    ov: Integer;
begin
  ov := TileTab[Tab.TabIndex].tbr.Overlap;
  ShiftState := Shift;
  MapX := (X * Zoom div ZOOM_FACTOR) div W;
  MapY := (Y * Zoom div ZOOM_FACTOR) div (H - ov);
  if MapDrawingTool in [mdtRect] then
    if Selection then
    begin
      Selection := FALSE;
      UpdateMapRegion(Area);
    end;

  if Button = mbLeft then
  begin
    // 2.55 - don't erase bounds
    if (MapDrawingTool = mdtRect) then
    begin
      Bounds := 0;
      BoundBox.RePaint;
    end;
  end;

  MapOrigin := Point (MapX, MapY);
  Area := MakeRect (MapX, MapY, 0, 0);
  LastArea := Area;
  if Button = mbLeft then
  begin
    DrawingInMap := TRUE;
    Modified := TRUE;
  end;
  if Button = mbRight then
    ReadingFromMap := TRUE;
  bmpMapMouseMove (Sender, Shift, X, Y);
  MapPos := Point (-1, -1);
end;

procedure TMainForm.bmpMapMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
  var
    MapX, MapY: Integer;
    Tile: Integer;
    m, u: Boolean;
    ov: Integer;
begin
  ov := TileTab[Tab.TabIndex].tbr.Overlap;
  MapX := (X * Zoom div ZOOM_FACTOR) div W;
  MapY := (Y * Zoom div ZOOM_FACTOR) div (H - ov);
  StatusBar.Panels[1].Text := Format ('(%d, %d)', [MapX, MapY]);
 // ExtendArea (Area, MapX, MapY);
  if lmp <> nil then
    if (MapX >= 0) and (MapX < CurMapW) and
       (MapY >= 0) and (MapY < CurMapH) then
      with lmp^ do
      begin
        if DrawingInMap then
        begin
          if MapDrawingTool = mdtPoint then
          begin
            if ssShift in ShiftState then
            begin
              GetMCRTile (TileTab[Tab.TabIndex].tbr.mcr, Tile, m, u);

              SetMCRTile (lmp^.Map[MapY, MapX], Tile, m, u);
            end
            else
              lmp^.Map[MapY, MapX] := TileTab[Tab.TabIndex].tbr.mcr;
            { RD: Redraw new tile }
            UpdateMapRegion(Area);
            Area := MakeRect (MapX, MapY, 0, 0);
          end;

          if MapDrawingTool in [mdtFilledRect, mdtRect, mdtZOrder] then
          begin
            if (MapX <> MapPos.X) or (MapY <> MapPos.Y) then
            begin
              Area := MakeArea (MapOrigin.X, MapOrigin.Y, MapX, MapY);
              if MapPos.X = -1 then LastArea := Area;
              MapPos := Point (MapX, MapY);
              UpdateMapRegion(Rect(min(Area.Left, LastArea.Left),
                             min(Area.Top, LastArea.Top),
                             max(Area.Right, LastArea.Right),
                             max(Area.Bottom, LastArea.Bottom)));
              LastArea := Area;
            end;
          end;

        end;

        if ReadingFromMap then
        begin
          TileTab[Tab.TabIndex].tbr.mcr := lmp^.Map[MapY, MapX];
          Bounds := TileTab[Tab.TabIndex].tbr.mcr.Bounds;
          ShowSelectedTile;


          // 2.5 - go to selected tile
          Tile := -1;
          with TileTab[Tab.TabIndex].tbr.mcr do
          begin
            if Front <> -1 then
              Tile := Front and TILE_MASK
            else
              if Mid <> -1 then
                Tile := Mid and TILE_MASK
              else
                if Back <> -1 then
                  Tile := Back and TILE_MASK;
          end;

          if Tile <> -1 then
          begin
            with TileTab[Tab.TabIndex].tbr do
              Current := Tile;
            StartEdit (FALSE);
          end;

        end;

      end;

  ShowStatusInfo;
end;

function TMainForm.CombineMCR (OldMCR, NewMCR: MapCellRec): MapCellRec;
  var
    Tile: Integer;
    m, u: Boolean;
    mcr: MapCellRec;
begin
  mcr := OldMCR;
  GetMCRTile (NewMCR, Tile, m, u);
  SetMCRTile (mcr, Tile, m, u);
  CombineMCR := mcr;
end;

procedure TMainForm.bmpMapMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
  var
    i, j: Integer;
    mcr: MapCellRec;
begin
  if Button = mbLeft then
  begin
    DrawingInMap := FALSE;
    if MapDrawingTool in [mdtFilledRect, mdtZOrder] then
      for j := Area.Top to Area.Bottom do
        for i := Area.Left to Area.Right do
        begin
          mcr := TileTab[Tab.TabIndex].tbr.mcr;
          if MapDrawingTool in [mdtZOrder] then
          begin
            AddMCR (mcr, i - Area.Left + (j - Area.Top) *
                              (Area.Right - Area.Left + 1));
            lmp^.Map[j, i] := CombineMCR (lmp^.Map[j, i], mcr);
          end
          else
            lmp^.Map[j, i] := mcr;
        end;
    if MapDrawingTool in [mdtRect] then
    begin
      Selection := TRUE;
      ClearMCR (TileTab[Tab.TabIndex].tbr.mcr);
      Bounds := TileTab[Tab.TabIndex].tbr.mcr.Bounds;
      ShowSelectedTile;
    end
    else
      UpdateMapRegion(Area);
  end;
  if Button = mbRight then
    ReadingFromMap := FALSE;
end;

procedure TMainForm.SetMapDrawingTool(Sender: TObject);
begin
  if Selection then
  begin
    UpdateMapRegion(Area);
    Selection := FALSE;
  end;

  if Sender = MapPointButton then
  begin
    MapDrawingTool := mdtPoint;


  end;

  if Sender = MapRectButton then
  begin
    MapDrawingTool := mdtFilledRect;

  end;

  if Sender = ZOrderButton then
  begin
    MapDrawingTool := mdtZOrder;

  end;

  if Sender = BlockButton then
  begin
    MapDrawingTool := mdtRect;

  end;

  ShowStatusInfo;
  Modified := TRUE;
end;

procedure TMainForm.bmpPreviewMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbRight then
  begin
    ClearMCR (TileTab[Tab.TabIndex].tbr.mcr);
    ShowSelectedTile;
  end;
end;

procedure TMainForm.ShowMapCodes1Click(Sender: TObject);
begin
  ShowMapCodes1.Checked := not ShowMapCodes1.Checked;
  UpdateMap;
  ShowSelectedTile;
end;

procedure TMainForm.ShowBounds1Click(Sender: TObject);
begin
  ShowBounds1.Checked := not ShowBounds1.Checked;
  UpdateMap;
  ShowSelectedTile;
end;

procedure TMainForm.ClearArea1Click(Sender: TObject);
begin
  if Mode = mMap then
    SelectCurrentTile (-1);
end;

procedure TMainForm.ClipTabChange(Sender: TObject);
  var
    i: Integer;
    ov: Integer;
begin
  if ClipTab.TabIndex < 0 then
  begin
    clip := nil;
    ClipBitmap.Visible := FALSE;

    Exit;
  end;
  ov := TileTab[Tab.TabIndex].tbr.Overlap;
  clip := SelectClipMap (TileTab[Tab.TabIndex].tbr, ClipTab.TabIndex);
  if clip <> nil then
  begin
    ClipH := Length (clip^.map);
    if ClipH > 0 then
    begin
      ClipW := Length (clip^.map[0]);

      ClipBitmap.Visible := TRUE;
      ClipBitmap.Width := ClipW * W;
      ClipBitmap.Height := ClipH * (H - ov);
      ResizeBitmap (ClipBitmap);

      { RD: draw clipped map }
      DrawMap (Rect (0, 0, ClipW - 1, ClipH - 1), FALSE, TRUE, FALSE);

      ClipBitmap.Stretch := TRUE;
      i := 1;
      repeat
        ClipBitmap.Width := ClipW * W div i;
        ClipBitmap.Height := ClipH * (H - ov) div i;
        Inc (i);
      until (i >= 5) or
        ((ClipBitmap.Width < ClipScrollBox.ClientWidth) and
         (ClipBitmap.Height < ClipScrollBox.ClientHeight));

     // ClipBitmap.Repaint;
    end;
  end;
end;

procedure TMainForm.RandomFill1Click(Sender: TObject);
  var
    i, j, x, y: Integer;
begin
  if Mode = mMap then
    if Selection and (ClipTab.TabIndex > -1) and (clip <> nil) then
    begin
      with Area do
        for j := Top to Bottom do
          for i := Left to Right do
          begin
            y := Random (ClipH);
            x := Random (ClipW);
            lmp^.Map[j, i] := clip^.Map[y, x];
          end;
      { RD: clear selection }
      Selection := FALSE;
      UpdateMapRegion(Area);
    end;
  Modified := TRUE;
end;

procedure TMainForm.RemoveMap1Click(Sender: TObject);  // remove map
  var
    i: Integer;
begin
  if MapTab.TabIndex > -1 then
  begin
    RemoveCurrentMap (TileTab[Tab.TabIndex].tbr);
    with MapTab do
    begin
      i := TabIndex;
      Tabs.Delete (i);
      if i <= Tabs.Count - 1 then
        TabIndex := i
      else
        TabIndex := Tabs.Count - 1;
    end;
    MapTabChange (Sender);
    Modified := TRUE;
  end;
end;

procedure TMainForm.RemoveTileSet1Click(Sender: TObject);
  var
    i: Integer;
begin
  if (Length (TileTab[Tab.TabIndex].tbr.Maps.aMaps) = 0) or
     (Sender = nil) or
     (MessageDlg ('One or more maps will be deleted. Continue?',
                               mtWarning, [mbYes, mbNo], 0) = mrYes) then
  begin
    FreeTBR (TileTab[Tab.TabIndex].tbr);
    for i := Tab.TabIndex + 1 to Length (TileTab) - 1 do
      TileTab[i - 1] := TileTab[i];
    SetLength (TileTab, Length (TileTab) - 1);
    i := Tab.TabIndex;
    Tab.Tabs.Delete (Tab.TabIndex);
    if i <= Tab.Tabs.Count - 1 then
      Tab.TabIndex := i
    else
      Tab.TabIndex := Tab.Tabs.Count - 1;

    if Sender <> nil then
    begin
      if Tab.Tabs.Count = 0 then
        CreateNewTileCollection (NewTCName, 32, 32, TRUE);
      TabChange (Sender);
      SetEditorMode (mTile);
    end;
    Modified := TRUE;
  end;
end;

procedure TMainForm.Save1Click(Sender: TObject);
  var
    F: File;
    i, j, k, np, n: Integer;
    TmpStr: string;

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

begin
  if Filename = '' then
    SaveAs1Click (Sender)
  else
  begin
{$IFDEF CREATE_BACKUP_FILES}
    if FileExists (Filename) then
    begin
      try
        if FileExists (Filename + BACKUP_EXT) then
          DeleteFile (Filename + BACKUP_EXT);
        RenameFile (Filename, Filename + BACKUP_EXT);
      except
        if MessageDlg ('Error while creating backup file ' +
            FileName + BACKUP_EXT + '. Continue?', mtError, [mbYes, mbNo], 0) = mrNo then
              Exit;
      end;
    end;
{$ENDIF}

    ProgressPanel.Visible := TRUE;
    ProgressBar.Position := 1;
    ProgressBar.Min := 0;
    ProgressBar.Max := Length (TileTab);

    AssignFile (F, Filename);
    try
      ReWrite (F, 1);


      SaveInt (Ord ('T'));  // file signature
      SaveInt (Ord ('S'));

      SaveInt (Ord (VERSION_NUMBER[1]) - Ord ('0'));  // version
      SaveInt (Ord (VERSION_NUMBER[3]) - Ord ('0'));

      SaveInt (Ord ('I'));  // 2.0   Project Information
      with Info do
        TmpStr := #0 + Author.Text + #0 + Notes.Text + #0 + Copyright.Text +
             #0 + Chr (Byte (Startup.Checked));
      SaveString (TmpStr);

      SaveInt (Ord ('O'));   // Output Path
      if OutputtoProjectDirectory1.Checked then
        SaveString ('')
      else
        SaveString (OutputPath);

      if Length (FromToSave) > 0 then
      begin
        SaveInt (Ord ('F'));  // FromTo
        SaveInt (Length (FromToSave) * SizeOf (FromToSave[0]));
        for i := 0 to Length (FromToSave) - 1 do
          BlockWrite (F, FromToSave[i], SizeOf (FromToSave[i]));
      end;

      SaveInt (Ord ('C'));  // 2.0  Config/options
      TmpStr := 'S' + Chr (Ord ('0') + Byte (SmoothPalette1.Checked)) +
                'A' + Chr (aaN);
      SaveString (TmpStr);

      SaveInt (Ord ('B'));  // Background color
      SaveInt (SizeOf (Integer));
      SaveInt (Background.Brush.Color);

      if CodeGen.LastDef <> '' then
      begin
        SaveInt (Ord ('D'));   // Definition file
        SaveString (CodeGen.LastDef);
      end;

      SaveInt (Ord ('N'));  // # TBRs
      SaveInt (SizeOf (Integer));
      n := Length (TileTab);
      SaveInt (n);

  {$IFDEF SAVETOTALTIME}
      SaveInt (Ord ('Z'));
      SaveInt (3 * SizeOf (Integer));
      DtTm := Now - StartTime;
      SaveInt (aiDtTm[0]);
      SaveInt (aiDtTm[1]);
      SaveInt (Sessions);
  {$ENDIF}

      SaveInt (Ord ('H'));  // History
      SaveString (History);

      SaveInt (Ord ('T'));  // TBR data
      SaveInt (0);

      for i := 0 to n - 1 do
      begin

        TileTab[i].tbr.LastScale := TileTab[i].lastscale;


        SaveTBR (F, TileTab[i].ID, TileTab[i].tbr);

        ProgressBar.Position := i + 1;
      end;


      // 2.0
    //  np := Length (aaiPal);
      // 2.33
      np := Length (aiPalSize);
      if np > 0 then
      begin
        SaveInt (Ord ('P'));

        k := 0;  // total palette data size
        for i := 0 to np - 1 do
          Inc (k, aiPalSize[i]);
        j := 0;
        for i := 0 to np - 1 do
          Inc (j, SizeOf (Integer) + Length (PaletteManager.GetID (i)));

        SaveInt ((1 +  // version
                  1 +  // # palettes
                  np +  // PalSize
                  np +  // Preset
                  k +  // palette data
                  2)   // DefaultPalette, SelectedPalette
                  * SizeOf (Integer) +
                  j);  // ID's

        SaveInt (1);  // version
        SaveInt (np);
        for i := 0 to np - 1 do
          SaveInt (aiPalSize[i]);
        for i := 0 to np - 1 do
          SaveInt (aiPreset[i]);

        for i := 0 to np - 1 do
          for j := 0 to aiPalSize[i] - 1 do
            SaveInt (aaiPal[i, j]);

        for i := 0 to np - 1 do
          SaveString (PaletteManager.GetID (i));

        SaveInt (DefaultPalette);
        SaveInt (SelectedPalette);
      end;
      //



      SaveInt (Ord ('L'));  // 3.0   Project Lists
      with Lists do
        SaveString (Notes.Text);





      SaveInt (0);  // End
      SaveInt (0);
      Modified := FALSE;
    except
      MessageDlg ('Cannot save file ' + FileName, mtError, [mbOk], 0);
    end;
    CloseFile (F);
    ProgressPanel.Visible := FALSE;

    AddFileToRecentProjects (FileName);
  end;
  Application.Title := APPL_NAME + ' - ' + ProjectName;
  MainForm.Caption := Application.Title;
end;

procedure TMainForm.SaveAs1Click(Sender: TObject);
begin
  SaveDialog.Filename := Filename;
  if SaveDialog.Execute then
  begin
    Filename := SaveDialog.Filename;
    Save1Click (Sender);
  end;
end;

procedure TMainForm.Open1Click(Sender: TObject);

  var
    F: File;
    i, j, k, np, n: Integer;
    PalVer: Integer;
    Error,
    Unknown: Boolean;
    Cmd: Char;
    Len: Integer;
    Done: Boolean;
    tbr: TileBitmapRec;
    ID: string;
    VersionHi,
    VersionLo: Char;
    s: string;
    TmpStr: string;
    ShowInfo: Boolean;
    BackColor: Integer; // 3.0

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

begin
  VersionHi := '0';
  VersionLo := '0';

  ShowInfo := FALSE;

  BackColor := -1;

  if ReadParamFile or OpenDialog.Execute then
  begin
    if Modified then
      if not SaveChanges then
        Exit;

    if ReadParamFile then
    begin
      Filename := FileToOpen;
      if not FileExists (Filename) then
        Filename := Filename + DEFAULT_EXT;
      if not FileExists (Filename) then
      begin
        MessageDlg ('Cannot open file: ' + Filename, mtError, [mbOk], 0);
        Exit;
      end;
      s := FileName;
      if Tab.Tabs.Count > 0 then
        CloseAll;
      FileName := s;
    end
    else
    begin
      CloseAll;
      Filename := OpenDialog.Filename;
    end;

    ProgressPanel.Visible := TRUE;
    ProgressBar.Min := 0;


    Error := FALSE;
    Unknown := FALSE;
    AssignFile (F, Filename);
    try
      Reset (F, 1);
      try

        VersionHi := VERSION_NUMBER[1];
        VersionLo := VERSION_NUMBER[3];

        History := '';
        aaN := 0;  { no anti-aliasing }

        if (FileSize (F) > 2 * SizeOf (Integer)) and
             (ReadInt = Ord ('T')) and (ReadInt = Ord ('S')) then
        begin
          StartTime := Now;
          DtTm := 0.0;

          ProgressBar.Position := 0;

          VersionHi := Char (ReadInt + Ord ('0'));  // Version
          VersionLo := Char (ReadInt + Ord ('0'));

          n := 0;
          Done := FALSE;
          repeat
            Cmd := Chr (ReadInt);
            Len := ReadInt;

            case Cmd of
              #0 : Done := TRUE;
              'L': Lists.Notes.Text := ReadString;
              'I': begin
                     TmpStr := ReadString;
                     if TmpStr[1] = #0 then
                       with Info do
                       begin
                         Delete (TmpStr, 1, 1);

                         i := Pos (#0, TmpStr);
                         Author.Text := Copy (TmpStr, 1, i);
                         Delete (TmpStr, 1, i);
                         i := Pos (#0, TmpStr);
                         Notes.Text := Copy (TmpStr, 1, i);
                         Delete (TmpStr, 1, i);
                         i := Pos (#0, TmpStr);
                         Copyright.Text := Copy (TmpStr, 1, i);
                         Delete (TmpStr, 1, i);
                         Startup.Checked := TmpStr <> #0;
                       end;
                   end;
              'N': begin
                     n := ReadInt;  // # TBRs
                     ProgressBar.Max := n;
                   end;
              'T': for i := 1 to n do
                   begin

                     if not ReadTBR (F, ID, tbr, Unknown) then
                       Error := TRUE;

                     if Tab.Tabs.IndexOf (ID) > -1 then
                       ID := NewTCName;
                     Tab.Tabs.Add (ID);
                     Tab.TabIndex := Tab.Tabs.IndexOf (ID);
                     SetLength (TileTab, Length (TileTab) + 1);
                     TileTab[Tab.TabIndex].tbr := tbr;
                     TileTab[Tab.TabIndex].id := ID;
                     TileTab[Tab.TabIndex].lastscrollpos := 0;
                     TileTab[Tab.TabIndex].lastscale := tbr.LastScale;
                     if tbr.BackGr = -1 then
                       TileTab[Tab.TabIndex].BackGrColor := Background.Brush.Color
                     else
                       TileTab[Tab.TabIndex].BackGrColor := tbr.BackGr;

                     ProgressBar.Position := i;
                   end;
              'F': for i := 0 to (Len div SizeOf (FromToSave[0])) - 1 do
                   begin
                     SetLength (FromToSave, i + 1);
                     BlockRead (F, FromToSave[i], SizeOf (FromToSave[i]));
                   end;
              'B': BackColor := ReadInt;
              'D': CodeGen.LastDef := ReadString;
              'C': begin
                     TmpStr := ReadString;
                     i := 1;
                     while i < Length (TmpStr) do
                     begin
                       case TmpStr[i] of
                         'S': SmoothPalette1.Checked := TmpStr[i + 1] = '1';
                         'A': aaN := Ord (TmpStr[i + 1]);
                       end;
                       Inc (i, 2);
                     end;
                   end;
              'O': begin
                     OutputPath := ReadString;
                     SelectOutputDirectory1.Checked := OutputPath <> '';
                     OutputtoProjectDirectory1.Checked := OutputPath = '';
                     if OutputPath = '' then
                       OutputPath := FilePath (FileName);
                   end;
              'Z': begin
                     aiDtTm[0] := ReadInt;
                     aiDtTm[1] := ReadInt;
                     StartTime := Now - DtTm;
                     Sessions := ReadInt + 1;
                   end;
              'H': History := ReadString;

            // 2.0
              'P': begin
                     PalVer := ReadInt;
                     // version 1
                     np := ReadInt;

                     for i := 0 to Length (aaiPal) - 1 do
                        SetLength (aaiPal[i], 0);
                     SetLength (aaiPal, np);
                     SetLength (aiPalSize, np);
                     for i := 0 to np - 1 do
                     begin
                       k := ReadInt;
                       aiPalSize[i] := k;
                       SetLength (aaiPal[i], k);
                     end;
                     SetLength (aiPreset, np);
                     for i := 0 to np - 1 do
                       aiPreset[i] := ReadInt;

                     for i := 0 to np - 1 do
                       for j := 0 to aiPalSize[i] - 1 do
                         aaiPal[i, j] := ReadInt;

                     for i := 0 to np - 1 do
                     begin
                       ReadInt;  // skip size
                       PaletteManager.SetID (i, ReadString);
                     end;

                     DefaultPalette := ReadInt;
                     SelectedPalette := ReadInt;

                     if PalVer = 2 then
                       ;
                   end;
            //
              else
              begin
                for i := 1 to Len do
                  ReadChar;
                Unknown := TRUE;
                if not (Cmd in ['A'..'Z']) then
                  Error := TRUE;
              end;
            end;
          until Done or Error;
          if Done then
            ShowInfo := TRUE;
        end
        else
          Error := TRUE;
      except
        CloseFile (F);
        MessageDlg ('File ' + Filename + ' seems to contain errors.', mtError, [mbOk], 0);
        ProgressPanel.Visible := FALSE;
      {  CloseAll;
        NewGame1Click (Sender);  }
        Exit;
      end;

      CloseFile (F);
    except
      Error := TRUE;
    end;


    if Error then
    begin
      MessageDlg ('Cannot open file: ' + Filename, mtError, [mbOk], 0);
      CloseAll;
      NewGame1Click (Sender);
    end
    else
    begin
      with ProgressBar do
        Position := Max;

      if Unknown then
      begin
        if (VersionHi > VERSION_NUMBER[1]) or
           ((VersionHi = VERSION_NUMBER[1]) and
            (VersionLo > VERSION_NUMBER[3])) then
          MessageDlg ('The file ' + Filename +
                      ' was saved with a newer version of ' +
                      APPL_NAME + ' (version ' +
                      VersionHi + '.' + VersionLo + ').' + #13 +
                      'Some data could not be loaded.',
                       mtWarning, [mbOk], 0)
        else
          MessageDlg (Filename + ' has an unknown format. ' +
                      'Some data could not be loaded.',
                       mtWarning, [mbOk], 0);
      end;

      if Tab.Tabs.Count = 0 then
        CreateNewTileCollection (NewTCName, 32, 32, TRUE);
      Tab.TabIndex := 0;
      TabChange (nil);
      UpdateTileBitmap;
      SetEditorMode (mTile);

      DrawUsedFromToList;

      if (BackColor <> -1) then
        SetBackgroundColor (BackColor, TRUE);

      AddFileToRecentProjects (FileName);
    end;

    case aaN of
      2: aa2.Click;
      3: aa3.Click;
      4: aa4.Click;
    else
       aaOff.Click;
    end;

    ProgressPanel.Visible := FALSE;
    Modified := Unknown;

{$IFDEF SHOWTOTALTIME}
    ShowMessage ('Total time: ' + Format (' %1.5f ', [DtTm]) +
                 ' in ' + IntToStr (Sessions) + ' session(s)');
{$ENDIF}

  end;
  Application.Title := APPL_NAME + ' - ' + ProjectName;
  MainForm.Caption := Application.Title;
  if ShowInfo then
    if (Info.Startup.Checked) then
      ProjectInformation1Click(Sender);
  FitInWindow1Click (Sender);
end;

procedure TMainForm.CloseAll;
begin
 { SetEditorMode (mTile); }
  ClearUndo;
  while Tab.TabIndex > -1 do
    RemoveTileSet1Click (nil);
  SetLength (FromToSave, 0);
  Modified := FALSE;
  Filename := '';
  OutputPath := '';
  CodeGen.LastDef := '';
  StartTime := Now;
  Sessions := 0;

  PaletteManager.ClearPalettes;

  SelectOutputDirectory1.Checked := FALSE;
  OutputtoProjectDirectory1.Checked := TRUE;

  with Lists do
    Notes.Text := '';

  with Info do
  begin
    Author.Text := '';
    Notes.Text := '';
    Copyright.Text := '';
    Startup.Checked := FALSE;
  end;

  aaOff.Click;
end;

function TMainForm.SaveChanges: Boolean;
begin
  SaveChanges := FALSE;
  if Modified then
  begin
    case MessageDlg ('Save changes to ' + ProjectName + '?',
            mtConfirmation, [mbYes, mbNo, mbCancel], 0) of
      mrYes:
        begin
          Save1Click (nil);
          if Modified then
            Exit;
        end;
      mrCancel:
        Exit;
    end;
  end;
  SaveChanges := TRUE;
end;

procedure TMainForm.NewGame1Click(Sender: TObject);
begin
  if Modified then
    if not SaveChanges then
      Exit;
  CloseAll;

  CreateNewTileCollection (NewTCName, 32, 32, TRUE);

  SetEditorMode (mTile);   // 2.43 bug fix: access violation

  StartEdit (TRUE);

  Filename := '';
  Application.Title := APPL_NAME + ' - ' + ProjectName;
  MainForm.Caption := Application.Title;
end;

procedure TMainForm.ToggleAnimation;
begin
  if Animate1.Checked then
  begin
    with TileTab[Tab.TabIndex] do
    begin
      if AnimStart = AnimEnd then
      begin
        AnimStart := -1;
        AnimEnd := -1;
      end;
      if AnimStart = -1 then
        AnimStart := 0;
      if (AnimEnd = -1) or (AnimEnd > tbr.TileCount - 1) then
        AnimEnd := tbr.TileCount - 1;
      if AnimStart = AnimEnd then
        Animate1.Checked := FALSE;
    end;
  end;
end;

procedure TMainForm.Animate1Click(Sender: TObject);
begin
  Animate1.Checked := not Animate1.Checked;
  ToggleAnimation;

  AnimationTimer.Enabled := Animate1.Checked;


  if Animate1.Checked then
    AnimateButton.Style := tbsCheck
  else
    AnimateButton.Style := tbsButton;
  AnimateButton.Down := Animate1.Checked;
  AnimateButton.Refresh;

end;



procedure TMainForm.FirstFrame1Click(Sender: TObject);
begin
  with TileTab[Tab.TabIndex] do
    AnimStart := tbr.Current;
end;

procedure TMainForm.LastFrame1Click(Sender: TObject);
begin
  with TileTab[Tab.TabIndex] do
    AnimEnd := tbr.Current;
end;

procedure TMainForm.NextFrame1Click(Sender: TObject);
begin
  with TileTab[Tab.TabIndex] do
  begin
    if (AnimStart = -1) or (AnimEnd > tbr.TileCount - 1) then
      AnimStart := 0;
    if (AnimEnd = -1) or (AnimEnd > tbr.TileCount - 1) then
      AnimEnd := tbr.TileCount - 1;
    if tbr.Current + 1 <= AnimEnd then
      Inc (tbr.Current)
    else
      tbr.Current := AnimStart;
  end;
  StartEdit (FALSE);
  DrawCursor;
end;

procedure TMainForm.PreviousFrame1Click(Sender: TObject);
begin
  with TileTab[Tab.TabIndex] do
  begin
    if (AnimStart = -1) or (AnimEnd > tbr.TileCount - 1) then
      AnimStart := 0;
    if (AnimEnd = -1) or (AnimEnd > tbr.TileCount - 1) then
      AnimEnd := tbr.TileCount - 1;
    if tbr.Current - 1 >= AnimStart then
      Dec (tbr.Current)
    else
      tbr.Current := AnimEnd;
  end;
  StartEdit (FALSE);
  DrawCursor;
end;

procedure TMainForm.AnimationTimerTimer(Sender: TObject);
begin
 // if AllowTimer then
  begin

    if Drawing then
    begin
      TileMouseUp (Sender, mbLeft, ShiftState, LastX, LastY);

      NextFrame1Click (Sender);

      TileMouseDown (Sender, mbLeft, ShiftState, LastX, LastY);
    end
    else
      NextFrame1Click (Sender);

  end;
end;

procedure TMainForm.Default1Click(Sender: TObject);
begin
  AnimationTimer.Interval := DEFAULT_ANIMATION_SPEED;
end;

procedure TMainForm.Faster1Click(Sender: TObject);
  var
    i: Integer;
begin
  if AnimationTimer.Enabled then
  begin
    i := AnimationTimer.Interval;
    Dec (i, 5 + i div 10);
    if i < 25 then
      i := 25;
    AnimationTimer.Interval := i;
  end;
end;

procedure TMainForm.Slower1Click(Sender: TObject);
  var
    i: Integer;
begin
  if AnimationTimer.Enabled then
  begin
    i := AnimationTimer.Interval;
    Inc (i, 5 + i div 10);
    if i > 1500 then
      i := 1500;
    AnimationTimer.Interval := i;
  end;
end;

procedure TMainForm.TileModeButtonClick(Sender: TObject);
begin
  SetEditorMode (mTile);
end;

procedure TMainForm.MapModeButtonClick(Sender: TObject);
begin
  SetEditorMode (mMap);
end;

procedure TMainForm.ConverttoTileSequence1Click(Sender: TObject);
  var
    i, j, m, n: Integer;
    mcr: MapCellRec;
begin
  if Mode = mMap then
  begin
    if not Selection then
      Exit;

    // check if not empty
    n := 0;
    m := 0;  // frame lengths provided as map codes?
    with Area do
      for j := Top to Bottom do
        for i := Left to Right do
        begin
          mcr := lmp^.Map[j, i];
          if mcr.MapCode > m then
            m := mcr.MapCode;
          if not EmptyMCR (mcr) then
            Inc (n);
        end;

    if n < 1 then
      Exit;

    SeqW := n;
    SeqH := 1;
    NewSeqMap (TileTab[Tab.TabIndex].tbr, SeqW, SeqH);

    n := SeqTab.Tabs.Count;
    SeqTab.TabIndex := SeqTab.Tabs.Add (IntToStr (n));
    seq := SelectSeqMap (TileTab[Tab.TabIndex].tbr, n);

    n := 0;
    with Area do
    begin
      for j := Top to Bottom do
        for i := Left to Right do
        begin
          mcr := lmp^.Map[j, i];
          if not EmptyMCR (mcr) then
          begin
//            if m = 0 then
//              mcr.MapCode := 25;
            seq^.Map[0, n] := mcr;
            Inc (n);
          end;
        end;
    end;

    SeqTabChange (Sender);

    { RD: clear selection }
    Selection := FALSE;
    UpdateMapRegion(Area);
    Modified := TRUE;
  end;
end;

procedure TMainForm.SeqTabChange(Sender: TObject);
begin
  SeqTimer.Enabled := FALSE;

  if SeqTab.TabIndex < 0 then
  begin
    seq := nil;
    SeqBitmap.Visible := FALSE;
    SeqTimer.Enabled := FALSE;

    Exit;
  end;
  seq := SelectSeqMap (TileTab[Tab.TabIndex].tbr, SeqTab.TabIndex);
  if seq <> nil then
  begin

    SeqH := Length (seq^.map);
    if SeqH > 0 then
    begin
      SeqW := Length (seq^.map[0]);

      SeqBitmap.Width := W;
      SeqBitmap.Height := H;
      ResizeBitmap (SeqBitmap);
      SeqBitmap.Left := (SeqTab.ClientWidth - W) div 2;
      SeqBitmap.Top := 8; // (SeqTab.ClientHeight - H) div 2;

      SeqBitmap.Visible := TRUE;

    (*
      { RD: draw sequence map }
      DrawMap (Rect (0, 0, -1, -1), FALSE, FALSE, TRUE);
    *)

      // 2.5 draw first frame right away
      SeqFrame := SeqW;
      SeqTimerTimer (nil);

      SeqTimer.Interval := Seq^.map[0, 0].MapCode * 10 + 1;
      SeqTimer.Enabled := TRUE;
    end;
  end;

  Modified := TRUE;
  MapTab.SetFocus;
end;

procedure TMainForm.SeqTimerTimer(Sender: TObject);
  var
    mcr: MapCellRec;
    OldSel: Boolean;
begin
  // draw frame and set timer for next

  if SkipDraw then
  begin
    SeqTimer.Interval := 10;
    SeqTimer.Enabled := TRUE;
  end
  else
  begin
    Inc (SeqFrame);
    if SeqFrame >= SeqW then
      SeqFrame := 0;

    if (Seq <> nil)
        and (Length (Seq^.map) > 0)
        and (Length (Seq^.map[0]) > SeqFrame) then
    begin
      mcr := Seq^.map[0, SeqFrame];

      OldSel := Selection;
      Selection := FALSE;
      { RD: draw tile from sequence }
      DrawMap (Rect (SeqFrame, 0, SeqFrame, 0), FALSE, FALSE, TRUE);
      Selection := OldSel;

      SeqTimer.Interval := mcr.MapCode * 10 + 1;
      SeqTimer.Enabled := TRUE;
    end;
  end;
end;


// if the BMP file header was not correctly written to disk, correct it
procedure PatchBMPFile (FileName: string);
  var
    F: file;
    Buffer: array of Char;
    Size, Diff, HS: Integer;
    s: string;
begin
  AssignFile (F, FileName);
  Reset (F, 1);
  Size := FileSize (F);
  SetLength (Buffer, Size);
  BlockRead (F, Buffer[0], Size);
  CloseFile (F);

  HS := StrInt (Buffer[2] + Buffer[3] + Buffer[4] + Buffer[5]);
  if HS <> Size then
    if MessageDlg ('The BMP file has not been saved correctly. Correct header?',
           mtWarning, [mbYes, mbNo], 0) = mrYes then
    begin
      if HS > Size then
        ShowMessage ('Cannot correct header')
      else
      begin
        Diff := Size - HS;
        s := IntStr (Size);
        Buffer[2] := s[1];
        Buffer[3] := s[2];
        Buffer[4] := s[3];
        Buffer[5] := s[4];
        s := IntStr (StrInt (Buffer[10] + Buffer[11] + Buffer[12] + Buffer[13]) + Diff);
        Buffer[10] := s[1];
        Buffer[11] := s[2];
        Buffer[12] := s[3];
        Buffer[13] := s[4];
        DeleteFile (FileName);
        AssignFile (F, FileName);
        ReWrite (F, 1);
        BlockWrite (F, Buffer[0], Size);
        CloseFile (F);
      end;
    end;

  SetLength (Buffer, 0);
end;


procedure TMainForm.RemoveTileSequence1Click(Sender: TObject);
  var
    i, j: Integer;
begin
  if SeqTab.TabIndex > -1 then
  begin
    RemoveSeq (TileTab[Tab.TabIndex].tbr, SeqTab.TabIndex);
    Modified := TRUE;
    with SeqTab do
    begin
      j := TabIndex;
      Tabs.Delete (TabIndex);
      for i := j to Tabs.Count - 1 do
        Tabs.Strings[i] := IntToStr (StrToInt (Tabs.Strings[i]) - 1);
      if j <= Tabs.Count - 1 then
        TabIndex := j
      else
        TabIndex := Tabs.Count - 1;
    end;
    SeqTabChange (Sender);
    UpdateMapRegion (Rect(0, 0, -1, -1));
    Modified := TRUE;
  end
end;

procedure TMainForm.InsertTileSequence1Click(Sender: TObject);
  var
    i, j: Integer;
begin
  if (Mode = mMap) and Selection and (SeqTab.TabIndex > -1) then
  begin
    if Selection then
    begin
      for j := Area.Top to Area.Bottom do
        for i := Area.Left to Area.Right do
        begin
          with lmp^.Map[j, i] do
          begin
            Back := -1;
            Mid := -1;
            Front := -1;
            MapCode := SeqTab.TabIndex;
          // Bounds := $FF;
          //  Bounds := ShortInt (Bounds or $80);
            Bounds := ShortInt (Bounds or $40);  // 2.55
          end;
        end;
      Modified := TRUE;
      Selection := FALSE;
      UpdateMapRegion(Area);
      Modified := TRUE;
    end;
  end;
end;

procedure TMainForm.PreviousPattern1Click(Sender: TObject);
begin
  if FromToSavePos > 0 then
    Dec (FromToSavePos)
  else
    FromToSavePos := Length (FromToSave) - 1;
  if FromToSavePos >= 0 then
    SelectSavedFromToList;
end;

procedure TMainForm.NextPattern1Click(Sender: TObject);
begin
  if FromToSavePos < Length (FromToSave) - 1 then
    Inc (FromToSavePos)
  else
    FromToSavePos := 0;
  SelectSavedFromToList;
end;

procedure TMainForm.SelectSavedFromToList;
{  var
    i, R, G, B: Integer; }
begin
  if FromToSavePos < Length (FromToSave) then
    with FromToSave[FromToSavePos] do
    begin
      FromToList := FT;
      ExFromToList := EXFT;
    {
      for i := 0 to MAX_FROM_TO - 1 do
      begin
        R := LimitRGB (EXFT[i, 0]);
        G := LimitRGB (EXFT[i, 1]);
        B := LimitRGB (EXFT[i, 2]);
        FromToList[i] := RGB (R, G, B);
      end;
    }
      FromToFirst := F;
      FromToLast := L;
      FromTo.Repaint;
    end;
end;

function TMainForm.FindCurrentColorPattern (FindColor: Integer; All: Boolean): Integer;
  var
    i, j, k, diff: Integer;
    FTF, FTL: Integer;
begin
  for k := Length (FromToSave) - 1 downto 0 do
    with FromToSave[k] do
    begin
      FindCurrentColorPattern := k;

      if (FindColor <> -1) then  // 2.53
      begin
        FTF := FromToSave[k].F;
        FTL := FromToSave[k].L;
        if All then
        begin
          FTF := 0;
          FTL := MAX_FROM_TO - 1;
        end;
        for i := FTF to FTL do
          if FT[i] = FindColor then
          begin
            if (not (ssAlt in LastShift)) then
            begin
              FromToFirst := i;
              FromToLast := i;
            end;
            Exit;
          end;
      end
      else
      begin
        diff := byte ((FromToSave[k].F <> FromToFirst) or
                      (FromToSave[k].L <> FromToLast));
        for i := 0 to MAX_FROM_TO - 1 do
          for j := 0 to 2 do
            if EXFT[i, j] <> ExFromToList[i, j] then
              Inc (diff);
        if diff = 0 then
          Exit;
      end;
    end;
  FindCurrentColorPattern := -1;
end;

procedure TMainForm.FindPatternForColor;
begin

end;

procedure TMainForm.AddColorPattern1Click(Sender: TObject);
begin
  if FindCurrentColorPattern (-1, FALSE) > -1 then
    Exit;
  SetLength (FromToSave, Length (FromToSave) + 1);
  FromToSavePos := Length (FromToSave) - 1;
  with FromToSave[FromToSavePos] do
  begin
    FT := FromToList;
    EXFT := ExFromToList;
    F := FromToFirst;
    L := FromToLast;
  end;
  DrawUsedFromToList;
  Modified := TRUE;
end;

procedure TMainForm.DrawUsedFromToList;
  var
    bmp: TBitmap;
    x, y: Integer;
begin
  bmp := TBitmap.Create;
  SetStretchBltMode(bmp.Canvas.Handle, HALFTONE);
  with bmp do
  begin
    PixelFormat := pf24bit;
    width := MAX_FROM_TO;
    height := Length (FromToSave);

    for y := 0 to height - 1 do
      for x := 0 to MAX_FROM_TO - 1 do
      begin
        Canvas.Pixels[x, y] := ColorPatternsPanel.Color;
        if FromToSave[y].F < FromToSave[y].L then
        begin
          if (x >= FromToSave[y].F) and (x <= FromToSave[y].L) then
            Canvas.Pixels[x, y] := FromToSave[y].FT[x];
        end
        else
          if (x >= FromToSave[y].L) and (x <= FromToSave[y].F) then
            Canvas.Pixels[x, y] := FromToSave[y].FT[MAX_FROM_TO - 1 - x];
      end;

    ColorPatternsImage.Picture.Bitmap := bmp;
    ColorPatternsImage.Stretch := TRUE;
    bmp.Free;
  end;
end;

procedure TMainForm.RemoveColorPattern1Click(Sender: TObject);
  var
    i: Integer;
begin
  i := FindCurrentColorPattern (-1, FALSE);
  if i = -1 then
    Exit
  else
    FromToSavePos := i;
  if FromToSavePos < Length (FromToSave) then
  begin
    for i := FromToSavePos + 1 to Length (FromToSave) - 1 do
      FromToSave[i - 1] := FromToSave[i];
    SetLength (FromToSave, Length (FromToSave) - 1);
    if FromToSavePos >= Length (FromToSave) then
      FromToSavePos := 0;
    SelectSavedFromToList;
  end;
  Modified := TRUE;
end;



  var
    itab, imap, itile, itstile, { itinytile, } idat,
    iseq, iseqdat, ipal, ipaldat: Integer;
    itilemap, icorner, icornerdat,  // 2.4
    itmpdat,
    ihedge, ihedgedat,
    ivedge, ivedgedat,
    itile0: Integer;

    iutt: Integer;  // 2.5

    itb: Integer;  // 2.54

    ifile: Integer; // 3.00 (input file text line / bin pos)


procedure TMainForm.Generate1Click(Sender: TObject);

  type
    TVarType = (vtNum, vtStr);
    TVarRec =
      record
        Name: string;
      case vt: TVarType of
        vtNum: (Num: Integer);
        vtStr: (Str: string[255]);    // 2.0
      end;

  const
    ExprChars = [' ', '+', '-', '*', '/', '(', ')', '&', '|', '%', '!'];

  // 2.4
  const
    EdgesX: array[0..7] of Integer = (-1, 0, 1, -1, 1, -1, 0, 1);
    EdgesY: array[0..7] of Integer = (-1, -1, -1, 0, 0, 1, 1, 1);
    EdgeToCorner: array[0..7] of Integer = (3, -1, 2, -1, -1, 1, -1, 0);
    CornerToEdge: array[0..3] of Integer = (0, 2, 5, 7);

  var
    EdgeSrc: array[0..7] of TRect;
    EdgeDst: array[0..7] of TRect;
    TileCornerX: array[0..3] of Integer;
    TileCornerY: array[0..3] of Integer;
    TmpCorner: array[0..3] of Integer;

  type
    CornerRec =
      record
        Tiles: array[0..3] of Integer;
        Count: Integer;
        Colors: array[0..3] of Integer;
        Number: Integer;
        Used: Boolean;
      end;

    EdgeRec =
      record
        Tiles: array[0..1] of Integer;
        Count: Integer;
      end;

  var
    Corners: array of array of CornerRec;
    HEdges: array of array of EdgeRec;
    VEdges: array of array of EdgeRec;

  type
    FlipType = (NOFLIP, HFLIP, VFLIP, HVFLIP);
    FlipInts = array[FlipType] of Integer;

  var
    ValidTileSet: Boolean;
    ValidTSTileSet: Boolean;  // 3.0

    VarList: array of TVarRec;

    aMCR: array of array of MapCellRec;
    aFinalRef: array of array of Integer;
    bmpFinal: array of TBitmap;
    bmpAlpha: array of TBitmap;  // 2.5
    aFinalTileCount: array of Integer;
    bmpCurTile: TBitmap;  // 2.54
    CurRGB: Integer;
    DataW, DataH: Integer;

    // 2.4
    TexTiles: Boolean;
    bmpTexTiles: array of TBitmap;
    bmpTexAlpha: array of TBitmap;  // 2.5
    aMCRSur: array of array of array[0..7] of array of Integer;
    aSameAs: array of array of array[0..7] of Integer;
    aTrans: array of array of array[0..7] of Integer;
    aCornerCount: array of Integer;
    aHEdgeCount: array of Integer;
    aVEdgeCount: array of Integer;

    // 2.5 - UniuqeTexTiles
    UTT: Boolean;
    aUTTRef: array of array of array of array[0..8] of Integer;
    aUTTIndex: array of array of Integer;
    aUTTCount: array of Integer;
    aTransTile: array of Integer;

    // 2.2
    TinyTiles: Boolean;
    aFinalTinyTileCount: array of FlipInts;
    aFinalTinyTiles: array of array[FlipType] of array of Integer;
    aFinalTinyRef: array of array of FlipInts;
    TinyW, TinyH: Integer;
    TinyNH, TinyNV: Integer;
    TinyFlip: FlipType;

    code: string;
    Error: Boolean;
    MapWd, MapHt, tmpW, tmpH: Integer;
    SeqLen: Integer;
  //  crc: string;
    TransX, TransY: array of Integer;
    NumericExpr: Boolean;  // all variables used are numbers?
    TransReplace: string;  // 2.0
    Quote: Boolean;  // 2.1

    // 2.5
    aa: Boolean;
    aaX, aaY: Integer;

    // 3.0
    SeqFrames: Integer;

    // options
    StartWithEmptyTile: Boolean;



  const
    MAX_COUNTER = 100;

  var
    Counters: array[0..MAX_COUNTER] of LongInt;
    ReadingAhead: Boolean;

    

  function GetTinyNH: Integer;
  begin
    if TinyTiles then
      GetTinyNH := TinyNH
    else
      GetTinyNH := 1;
  end;

  function GetTinyNV: Integer;
  begin
    if TinyTiles then
      GetTinyNV := TinyNV
    else
      GetTinyNV := 1;
  end;


  procedure SetNumVar (ID: string; Value: Integer);
    var
      i: Integer;
  begin
    ID := UpCaseStr (ID);
    for i := 0 to Length (VarList) - 1 do
      if VarList[i].Name = ID then
      begin
        VarList[i].vt := vtNum;
        VarList[i].Num := Value;
        Exit;
      end;
    SetLength (VarList, Length (VarList) + 1);
    i := Length (VarList) - 1;
    VarList[i].Name := ID;
    VarList[i].vt := vtNum;
    VarList[i].Num := Value;
  end;

  procedure SetStrVar (ID: string; Value: string);
    var
      i: Integer;
  begin
    ID := UpCaseStr (ID);
    for i := 0 to Length (VarList) - 1 do
      if VarList[i].Name = ID then
      begin
        VarList[i].vt := vtStr;
        VarList[i].Str := Value;
        Exit;
      end;
    SetLength (VarList, Length (VarList) + 1);
    i := Length (VarList) - 1;
    VarList[i].Name := ID;
    VarList[i].vt := vtStr;
    VarList[i].Str := Value;
  end;

  function AddLeadingZeros (s, Fmt: string): string;
    var
      p: Integer;
  begin
    p := Pos ('%0', Fmt);
    if p > 0 then
      while (p < Length (s)) and (s[p] = ' ') do
      begin
        s[p] := '0';
        Inc (p);
      end;
    AddLeadingZeros := s;
  end;

  function GetVarValue (ID, Fmt: string): string;
    var
      i: Integer;
      s: string;
      N: LongInt;
  begin
    s := UpCaseStr (ID);
    for i := 0 to Length (VarList) - 1 do
      if VarList[i].Name = s then
      case VarList[i].vt of
        vtStr:
          begin
           // if (s <> 'SHR') and (s <> 'SHL') then
            if (Pos (' ' + s + ' ', '  SHR SHL IF THEN ELSE NOT EQUALS ABOVE BELOW  ') <= 0) then
              NumericExpr := FALSE;
            GetVarValue := VarList[i].Str;
            Exit;
          end;
        vtNum:
          begin
            s := Format (Fmt, [VarList[i].Num]);
            GetVarValue := AddLeadingZeros (s, Fmt);
            Exit;
          end;
      end;

    if (Copy (s, 1, 7) = 'COUNTER') and (Length (s) > 7) then  // 3.0
    begin
      Delete (s, 1, 7);
      Val (s, N, i);
      if (i = 0) and (N <= MAX_COUNTER) then
      begin
        i := N;
        N := Counters[i];
        s := Format (Fmt, [N]);
        if not ReadingAhead then
          Inc (Counters[i]);
        GetVarValue := AddLeadingZeros (s, Fmt);
        Exit;
      end;
    end;

  {
    MessageDlg ('Error in code generation definition: uninitialized variable (' +
                ID + ').', mtError, [mbOk], 0);
  }
    Error := TRUE;
    GetVarValue := '';
  end;





  procedure GetTinyPos (itab, p: Integer; var x, y: Integer);
    var
      NH: Integer;
      TileNo, TileX, TileY: Integer;
  begin
    if p = -1 then   // transparant
    begin
      x := -1;
      y := -1;
    end
    else
      with TileTab[itab] do
      begin
        NH := bmpFinal[itab].Width div tbr.W;
        TileNo := p div (TinyNH * TinyNV);
        p := p mod (TinyNH * TinyNV);
        TileX := TileNo mod NH;
        TileY := TileNo div NH;
        x := TileX * tbr.W + (p mod TinyNH) * TinyW;
        y := TileY * tbr.H + (p div TinyNH) * TinyH;
      end;
  end;

  // 2.2
  procedure SetupTinyTiles (W, H: Integer; F: FlipType);
    var
      itab: Integer;

    const
      EmptyFlipInt: FlipInts = (0, 0, 0, 0);


    function FindTinyTile (P: Integer; F: FlipType): Integer;
      var
        n: Integer;
        PX, PY: Integer;
        x, y, i, j: Integer;
        Diff: Boolean;
        Found: Integer;
    begin
      Found := -1;
      if P <> -1 then
        with TileTab[itab] do
        begin
          GetTinyPos (itab, P, PX, PY);
          for n := 0 to aFinalTinyTileCount[itab][F] - 1 do
            if Found = -1 then
            begin
              GetTinyPos (itab, aFinalTinyTiles[itab][TinyFlip][n],
                               x, y);

              Diff := FALSE;
              for j := 0 to TinyH - 1 do
                for i := 0 to TinyW - 1 do
                  if not Diff then
                    if (x = -1) or (y = -1) then
                    begin
                      if (bmpFinal[itab].Canvas.Pixels[PX + i, PY + j]) <> TRANS_COLOR then
                          Diff := TRUE;
                    end
                    else
                    begin
                      if (bmpFinal[itab].Canvas.Pixels[PX + i, PY + j]) <>
                         (bmpFinal[itab].Canvas.Pixels[x + i, y + j]) then
                           Diff := TRUE;
                    end;

              if not Diff then
                Found := n;  // aFinalTinyTiles[itab][TinyFlip][n];
            end;
        end;
      FindTinyTile := Found;
    end;

    function AddTinyTile (i: Integer; F: FlipType): Integer;
      var
        n, l: Integer;
    begin
      n := FindTinyTile (i, F);
      if (n = -1) then
      begin
        l := aFinalTinyTileCount[itab][F];
        Inc (aFinalTinyTileCount[itab][F]);
        SetLength (aFinalTinyTiles[itab][F], l + 1);
        aFinalTinyTiles[itab][F][l] := i;
        n := l;
      end;
      AddTinyTile := n;
    end;

    var
      i: Integer;

  begin  { SetupTinyTiles }
    TinyFlip := F;
    if (W = TinyW) and (H = TinyH) then
      Exit;

    TinyW := W;
    TinyH := H;

    for itab := 0 to Tab.Tabs.Count - 1 do
    begin
      SetLength (aFinalTinyTiles[itab][NOFLIP], 0);
      SetLength (aFinalTinyTiles[itab][HFLIP], 0);
      SetLength (aFinalTinyTiles[itab][VFLIP], 0);
      SetLength (aFinalTinyTiles[itab][HVFLIP], 0);

      SetLength (aFinalTinyRef[itab], 0);
    end;

    for itab := 0 to Tab.Tabs.Count - 1 do
      with TileTab[itab] do
      begin
        aFinalTinyTileCount[itab] := EmptyFlipInt;
        if (W > 0) and (tbr.W mod W = 0) and
           (H > 0) and (tbr.H mod H = 0) then
        begin
          TinyNH := tbr.W div W;
          TinyNV := tbr.H div H;

          SetLength (aFinalTinyRef[itab],
               aFinalTileCount[itab] * TinyNH * TinyNV);

          AddTinyTile (-1, NOFLIP);  // add empty tile
          for i := 0 to aFinalTileCount[itab] * TinyNH * TinyNV - 1 do
            aFinalTinyRef[itab][i][TinyFlip] := AddTinyTile (i, NOFLIP);
        end;
      end;
  end;


  procedure ShowProgress (Pos, Max: Integer);
  begin
    ProgressBar.Position := 100 * itab + Pos * 100 div Max;
  end;

  function FindMCR (const mcr: MapCellRec): Integer;  // -1: not found
    var
      i: Integer;
  begin
    for i := 0 to Length (aMCR[itab]) - 1 do
      if (aMCR[itab][i].Back = mcr.Back) and
         (aMCR[itab][i].Mid = mcr.Mid) and
         (aMCR[itab][i].Front = mcr.Front) then
      begin
        FindMCR := i;
        Exit;
      end;
    FindMCR := -1;
  end;

  procedure AddMCR (const mcr: MapCellRec);
    var
      i: Integer;
      Found: Boolean;
  begin
    i := FindMCR (mcr);
   // Found := (i > -1) or (mcr.Bounds = $FF);  // skip sequence
    Found := (i > -1) or (mcr.Bounds and $40 <> 0);  // skip sequence
    if not Found then
    begin
      i := Length (aMCR[itab]);
      SetLength (aMCR[itab], i + 1);
      aMCR[itab][i] := mcr;
    end;
  end;

  procedure AddMCRs (const aaMaps: aaMapCellRec);
    var
      i, j: Integer;
  begin
    for j := 0 to Length (aaMaps) - 1 do
      for i := 0 to Length (aaMaps[j]) - 1 do
        AddMCR (aaMaps[j, i]);
  end;



  procedure AddEdge (Edge: Integer; const mcr, mcr2: MapCellRec);
    var
      i, j, k, l: Integer;
      Found: Boolean;
  begin
    j := FindMCR (mcr);
    if j > -1 then
    begin
      j := aFinalRef[itab][j];

      k := FindMCR (mcr2);
      if k > -1 then
        k := aFinalRef[itab][k];

      Found := FALSE;
      l := Length (aMCRSur[itab][j][Edge]);
      for i := 0 to l - 1 do
        if i mod 2 = 0 then
          if aMCRSur[itab][j][Edge][i] = k then
          begin
            Inc (aMCRSur[itab][j][Edge][i + 1]);
            Found := TRUE;
          end;
      if not Found then
      begin
        SetLength (aMCRSur[itab][j][Edge], l + 2);
        aMCRSur[itab][j][Edge][l] := k;
        aMCRSur[itab][j][Edge][l + 1] := 1;
      end;

    end;
  end;


  procedure AddAllEdges (Edge: Integer; const mcr, mcr2: MapCellRec; const Seq: MapSet);
    var
      i, j: Integer;
  begin
   // if mcr.Bounds <> $FF then
    if mcr.Bounds and $40 = 0 then
     // if mcr2.Bounds <> $FF then
      if mcr2.Bounds and $40 = 0 then
        AddEdge (Edge, mcr, mcr2)
      else
        for i := 0 to Length (Seq.aMaps[mcr2.MapCode].Map[0]) - 1 do
          AddEdge (Edge, mcr, Seq.aMaps[mcr2.MapCode].Map[0, i])
    else
     // if mcr2.Bounds <> $FF then
      if mcr2.Bounds and $40 = 0 then
        for j := 0 to Length (Seq.aMaps[mcr.MapCode].Map[0]) - 1 do
          AddEdge (Edge, Seq.aMaps[mcr.MapCode].Map[0, j], mcr2)
      else
        if mcr.MapCode = mcr2.MapCode then  // 2.43
        begin
          for i := 0 to Length (Seq.aMaps[mcr.MapCode].Map[0]) - 1 do
              AddEdge (Edge, Seq.aMaps[mcr.MapCode].Map[0, i],
                             Seq.aMaps[mcr2.MapCode].Map[0, i]);
        end
        else
          for j := 0 to Length (Seq.aMaps[mcr.MapCode].Map[0]) - 1 do
            for i := 0 to Length (Seq.aMaps[mcr2.MapCode].Map[0]) - 1 do
              AddEdge (Edge, Seq.aMaps[mcr.MapCode].Map[0, j],
                           Seq.aMaps[mcr2.MapCode].Map[0, i])
  end;


  procedure AddCorner (const mcr0, mcr1, mcr2, mcr3: MapCellRec);
    var
      CR: CornerRec;
      i, j, L: Integer;
  begin
    CR.Tiles[0] := FindMCR (mcr0);
    CR.Tiles[1] := FindMCR (mcr1);
    CR.Tiles[2] := FindMCR (mcr2);
    CR.Tiles[3] := FindMCR (mcr3);

    j := -1;
    L := Length (Corners[itab]);
    for i := 0 to L - 1 do
      with Corners[itab][i] do
        if (CR.Tiles[0] = Tiles[0]) and
           (CR.Tiles[1] = Tiles[1]) and
           (CR.Tiles[2] = Tiles[2]) and
           (CR.Tiles[3] = Tiles[3]) then
          j := i;

    if j <> -1 then
      Inc (Corners[itab][j].Count)
    else
    begin
      CR.Count := 1;
      CR.Used := FALSE;
      SetLength (Corners[itab], L + 1);
      Corners[itab][L] := CR;
    end;
  end;


  procedure AddAllCorners (const mcr0, mcr1, mcr2, mcr3: MapCellRec; const Seq: MapSet);

    function GetCount (const mcr: MapCellRec): Integer;
    begin
     // if mcr.Bounds <> $FF then
      if mcr.Bounds and $40 = 0 then
        Result := 1
      else
        Result := Length (Seq.aMaps[mcr.MapCode].Map[0]);
    end;

    function GetMCR (const mcr: MapCellRec; N: Integer): MapCellRec;
    begin
     // if mcr.Bounds <> $FF then
      if mcr.Bounds and $40 = 0 then
        Result := mcr
      else
        Result := Seq.aMaps[mcr.MapCode].Map[0][N];
    end;


    var
      i, j, k, l: Integer;
  begin
    for i := 0 to GetCount (mcr0) - 1 do
      for j := 0 to GetCount (mcr1) - 1 do
        for k := 0 to GetCount (mcr2) - 1 do
          for l := 0 to GetCount (mcr3) - 1 do
            AddCorner (GetMCR (mcr0, i),
                       GetMCR (mcr1, j),
                       GetMCR (mcr2, k),
                       GetMCR (mcr3, l));
  end;


  procedure CreateEdgeData (const aaMaps: aaMapCellRec; const Seq: MapSet);
    var
      W, H, X, Y: Integer;
      i, j, edge: Integer;
  begin
    H := Length (aaMaps);
    for j := 0 to H - 1 do
    begin
      W := Length (aaMaps[j]);
      for i := 0 to W - 1 do
      begin

        for edge := 0 to 7 do
          if EdgeToCorner[edge] = -1 then
          begin
            X := (i + EdgesX[edge] + W) mod W;
            Y := (j + EdgesY[edge] + H) mod H;
            AddAllEdges (edge, aaMaps[j, i], aaMaps[Y, X], Seq);
          end;

        X := (i + 1) mod W;
        Y := (j + 1) mod H;
        AddAllCorners (aaMaps[j, i], aaMaps[j, X], aaMaps[Y, i], aaMaps[Y, X], Seq);

      end;
    end;
  end;



  function GetTransCount (tile, edge: Integer): Integer;
    var
      i, j, k: Integer;
      Y: Integer;
  begin
    k := 0;
    with TileTab[itab].tbr do
      Y := (tile - 1) * (H + 2);
    with bmpTexTiles[itab].Canvas do
      with EdgeSrc[edge] do
        for j := top to bottom - 1 do
          for i := left to right - 1 do
            if (Y < 0) or (Pixels[i, Y + j] = TRANS_COLOR) then
              Inc (k);
    Result := k;
  end;


  function CompareEdge (tile1, tile2, edge: Integer): Boolean;
    var
      i, j: Integer;
      Y1, Y2: Integer;
  begin
    Result := FALSE;
    with TileTab[itab].tbr do
    begin
      Y1 := (tile1 - 1) * (H + 2);
      Y2 := (tile2 - 1) * (H + 2);
    end;
    with bmpTexTiles[itab].Canvas do
      with EdgeSrc[7 - edge] do
        for j := top to bottom - 1 do
          for i := left to right - 1 do
            if Pixels[i, Y1 + j] <> Pixels[i, Y2 + j] then
              Exit;

    Result := TRUE;
  end;


  procedure FindSameEdges;
    var
      i, tile, edge, N: Integer;
  begin
    for tile := 0 to Length (aMCRSur[itab]) - 1 do
      for edge := 0 to 7 do
        aTrans[itab][tile][edge] := GetTransCount (tile, edge);

    for edge := 0 to 7 do
      if EdgeToCorner[edge] = -1 then
      begin
        N := Length (aMCRSur[itab]);
        for tile := 0 to N - 1 do
        begin
          i := tile - 1;
          while (i >= 0) and (not CompareEdge (i, tile, edge)) do
            Dec (i);
          aSameAs[itab][tile][edge] := i;
        end;
      end;
  end;



  // 2.5

  function CompareAllEdges (tile: Integer; sur1, sur2: Integer): Boolean;
    var
      t1, t2: Integer;
      edge: Integer;
      i: Integer;

  begin
    Result := FALSE;
    for edge := 0 to 7 do
    begin
      t1 := aUTTRef[itab][tile][sur1][edge];
      t2 := aUTTRef[itab][tile][sur2][edge];

      if t1 <> t2 then
        if EdgeToCorner[edge] = -1 then
        begin
          if not CompareEdge (t1, t2, edge) then
            Exit;
        end
        else
        begin
          for i := 0 to 3 do
            if Corners[itab][t1].Colors[i] <> Corners[itab][t2].Colors[i] then
              Exit;
        end;
    end;

    Result := TRUE;
  end;


  function FindCorner (t0, t1, t2, t3: Integer): Integer;
    var
      i: Integer;
  begin
    Result := -1;

    for i := 0 to Length (Corners[itab]) - 1 do
      with Corners[itab][i] do
        if (t0 = Tiles[0]) and
           (t1 = Tiles[1]) and
           (t2 = Tiles[2]) and
           (t3 = Tiles[3]) then
          Result := i;
  end;


  function AddTileCombination (tile: Integer; surtiles: array of Integer): SmallInt;
    var
      i, j, l, t: Integer;
      Same, Found: Boolean;
  begin
    Result := tile;
    if tile <= 0 then
      Exit;

   { ((0, 1, 0, 1, 1, 0, 1, 1, 3), (0, 1, 0, 1, 1, 1, 2, 2, 4), (0, 1, 0, 1, 1, 2, 1, 0, 5),
      (0, 1, 1, 1, 2, 0, 1, 3, 6),                              (2, 1, 0, 2, 1, 4, 1, 0, 7),
      (0, 1, 3, 1, 1, 0, 1, 0, 8), (3, 2, 4, 1, 1, 0, 1, 0, 9), (4, 1, 0, 1, 1, 0, 1, 0, 10)) }

    surtiles[0] := FindCorner (surtiles[0], surtiles[1], surtiles[3], tile);
    surtiles[2] := FindCorner (surtiles[1], surtiles[2], tile, surtiles[4]);
    surtiles[5] := FindCorner (surtiles[3], tile, surtiles[5], surtiles[6]);
    surtiles[7] := FindCorner (tile, surtiles[4], surtiles[6], surtiles[7]);

    for i := 0 to Length (aUTTRef[itab][tile]) - 1 do
    begin
      Same := TRUE;
      for j := 0 to 7 do
        if surtiles[j] <> aUTTRef[itab][tile][i][j] then
          Same := FALSE;
      if Same then
      begin
        Result := aUTTRef[itab][tile][i][8];
        Exit;
      end;
    end;

    Found := FALSE;
    for j := 0 to 7 do
    begin
      l := Length (aMCRSur[itab][tile][j]);
      for i := 0 to l - 1 do
        if i mod 2 = 0 then
        begin
          t := aMCRSur[itab][tile][j][i];
         { if EdgeToCorner[j] <> -1 then
            t := corners[itab][t].Tiles[3 - EdgeToCorner[j]]; }

          if t = surtiles[j] then
            Found := TRUE;
        end;
    end;
    if not Found then
      Exit;

    l := Length (aUTTRef[itab][tile]);
    SetLength (aUTTRef[itab][tile], l + 1);
    for j := 0 to 7 do
      aUTTRef[itab][tile][l][j] := surtiles[j];

    Found := FALSE;
    for i := 0 to l - 1 do
      if not Found then
        if CompareAllEdges (tile, i, l) then
        begin
          t := aUTTRef[itab][tile][i][8];
          aUTTRef[itab][tile][l][8] := t;
          Result := t;
          Found := TRUE;
        end;
    if not Found then
    begin
      i := aUTTCount[itab];
      aUTTRef[itab][tile][l][8] := i + 1;
      SetLength (aUTTIndex[itab], i + 1);

      aUTTIndex[itab][i] := tile;
      Inc (aUTTCount[itab]);
      Result := i + 1;
    end;
  end;


  procedure CreateUTTData (const aaMaps: aaMapCellRec; const Seq: MapSet);
    var
      W, H, X, Y: Integer;
      i, j, edge: Integer;
      aMCR: array[0..7] of MapCellRec;

    function AddAllCombinations (mcr: MapCellRec): SmallInt;

      function GetCount (const mcr: MapCellRec): Integer;
      begin
       // if mcr.Bounds <> $FF then
        if mcr.Bounds and $40 = 0 then
          Result := 1
        else
          Result := Length (Seq.aMaps[mcr.MapCode].Map[0]);
      end;

      function GetMCR (const mcr: MapCellRec; N: Integer): MapCellRec;
      begin
       // if mcr.Bounds <> $FF then
        if mcr.Bounds and $40 = 0 then
          Result := mcr
        else
          Result := Seq.aMaps[mcr.MapCode].Map[0][N];
      end;

      var
        i, j, k, l, m, n, o, p, q: Integer;
        a: Integer;
        ai: array[0..7] of Integer;
    begin
      Result := -1;
      for i := 0 to GetCount (aMCR[0]) - 1 do
      begin
        ai[0] := FindMCR (GetMCR (aMCR[0], i));
        for j := 0 to GetCount (aMCR[1]) - 1 do
        begin
          ai[1] := FindMCR (GetMCR (aMCR[1], j));
          for k := 0 to GetCount (aMCR[2]) - 1 do
          begin
            ai[2] := FindMCR (GetMCR (aMCR[2], k));
            for l := 0 to GetCount (aMCR[3]) - 1 do
            begin
              ai[3] := FindMCR (GetMCR (aMCR[3], l));
              for m := 0 to GetCount (mcr) - 1 do
              begin
                a := FindMCR (GetMCR (mcr, m));
                for n := 0 to GetCount (aMCR[4]) - 1 do
                begin
                  ai[4] := FindMCR (GetMCR (aMCR[4], n));
                  for o := 0 to GetCount (aMCR[5]) - 1 do
                  begin
                    ai[5] := FindMCR (GetMCR (aMCR[5], o));
                    for p := 0 to GetCount (aMCR[6]) - 1 do
                    begin
                      ai[6] := FindMCR (GetMCR (aMCR[6], p));
                      for q := 0 to GetCount (aMCR[7]) - 1 do
                      begin
                        ai[7] := FindMCR (GetMCR (aMCR[7], q));
                        Result := AddTileCombination (a, ai);
                      end;
                    end;
                  end;
                end;
              end;
            end;
          end;
        end;
      end;
    end;

  begin
    H := Length (aaMaps);
    for j := 0 to H - 1 do
    begin
      W := Length (aaMaps[j]);
      for i := 0 to W - 1 do
      begin

        for edge := 0 to 7 do
        begin
          X := (i + EdgesX[edge] + W) mod W;
          Y := (j + EdgesY[edge] + H) mod H;
          aMCR[edge] := aaMaps[Y, X];
        end;

        aaMaps[j, i].Tag := AddAllCombinations (aaMaps[j, i]);
      end;
    end;
  end;



  procedure SetEdgeRects (W, H: Integer);
  begin
    EdgeSrc[0] := MakeRect (W, H, 1, 1);
    EdgeSrc[1] := MakeRect (1, H, W, 1);
    EdgeSrc[2] := MakeRect (1, H, 1, 1);
    EdgeSrc[3] := MakeRect (W, 1, 1, H);
    EdgeSrc[4] := MakeRect (1, 1, 1, H);
    EdgeSrc[5] := MakeRect (W, 1, 1, 1);
    EdgeSrc[6] := MakeRect (1, 1, W, 1);
    EdgeSrc[7] := MakeRect (1, 1, 1, 1);

    EdgeDst[0] := MakeRect (0, 0, 1, 1);
    EdgeDst[1] := MakeRect (1, 0, W, 1);
    EdgeDst[2] := MakeRect (W + 1, 0, 1, 1);
    EdgeDst[3] := MakeRect (0, 1, 1, H);
    EdgeDst[4] := MakeRect (W + 1, 1, 1, H);
    EdgeDst[5] := MakeRect (0, H + 1, 1, 1);
    EdgeDst[6] := MakeRect (1, H + 1, W, 1);
    EdgeDst[7] := MakeRect (W + 1, H + 1, 1, 1);

    TileCornerX[0] := 0;
    TileCornerY[0] := 0;
    TileCornerX[1] := W;
    TileCornerY[1] := 0;
    TileCornerX[2] := 0;
    TileCornerY[2] := H;
    TileCornerX[3] := W;
    TileCornerY[3] := H;
  end;


  procedure GetEdgeColors;
    var
      i, j, k, x, y: Integer;
  begin
    for i := 0 to Length (Corners[itab]) - 1 do
      with Corners[itab][i] do
      begin

        for j := 0 to 3 do
        begin
          with EdgeSrc[CornerToEdge[j]] do
          begin
            x := Left;
            y := Top;
          end;

          with TileTab[itab].tbr do
          begin
            k := (Tiles[j] - 1) * (H + 2);
            if k < 0 then
              Colors[j] := TRANS_COLOR
            else
              Colors[j] := bmpTexTiles[itab].Canvas.Pixels[x, y + k];
          end;
        end;

      end;
  end;


  function GetBestCorner (tile, corner: Integer; ai: array of Integer): Integer;
    var
      i, j, N, Total: Integer;
      othercorner: Integer;
      Diff: Boolean;
  begin
    N := -1;
    othercorner := 3 - corner;
    Total := -1;
    for i := 0 to Length (Corners[itab]) - 1 do
      with Corners[itab][i] do
        if tile = Tiles[corner] then
        begin
          Diff := FALSE;
          for j := 0 to 3 do
            if j <> othercorner then
              if Colors[j] <> ai[j] then
                Diff := TRUE;
          if not Diff then
          begin
            if Count > Total then
            begin
              N := i;
              Total := Count;
            end;
          end;
        end;

    Result := N;
  end;


  function NumberCornerData: Integer;

    function Cmp (N1, N2: Integer): Boolean;
      var
        i: Integer;
    begin
      Cmp := TRUE;
      for i := 0 to 3 do
        if (Corners[itab][N1].Tiles[i] < Corners[itab][N2].Tiles[i]) then
        begin
          Cmp := FALSE;
          Exit;
        end
        else
          if (Corners[itab][N1].Tiles[i] > Corners[itab][N2].Tiles[i]) then
          begin
            Cmp := TRUE;
            Exit;
          end;
    end;

    var
      i, j, k: Integer;
      N: Integer;
      ai: array of Integer;
  begin
    N := 0;
    for i := 0 to Length (Corners[itab]) - 1 do
      with Corners[itab][i] do
        if Used then
        begin
          Inc (N);
          SetLength (ai, N);
          ai[N - 1] := i;
        end
        else
          Number := -1;

    for i := 0 to N - 1 do
      for j := i + 1 to N - 1 do
        if Cmp (ai[i], ai[j]) then
        begin
          k := ai[i];
          ai[i] := ai[j];
          ai[j] := k;
        end;

    for i := 0 to N - 1 do
      Corners[itab][ai[i]].Number := i;

    SetLength (ai, 0);

    Result := N;
  end;


  procedure CreateCornerData (tile, edge, N: Integer; ai: array of Integer);
    var
      i, j, k, l, tc: Integer;
      corner: Integer;
      Found: Boolean;
      Diff: Boolean;
  begin
    corner := EdgeToCorner[edge];

    for i := 0 to Length (Corners[itab]) - 1 do
      with Corners[itab][i] do
        if Tiles[corner] = tile then
        begin
          TC := 0;
          Diff := FALSE;
          for j := 0 to 3 do
          begin
            if Colors[j] <> ai[j] then
              Diff := TRUE;
            if Colors[j] = TRANS_COLOR then
              Inc (TC);
          end;

          if (TC < 4) and Diff then
          begin
            Found := FALSE;
            k := i;
            l := Length (aMCRSur[itab][tile][edge]);
            for j := 0 to l - 1 do
              if j mod 2 = 0 then
                if aMCRSur[itab][tile][edge][j] = k then
                begin
                  Inc (aMCRSur[itab][tile][edge][j + 1], Count);
                  Found := TRUE;
                end;
            if not Found then
            begin
              SetLength (aMCRSur[itab][tile][edge], l + 2);
              aMCRSur[itab][tile][edge][l] := k;
              aMCRSur[itab][tile][edge][l + 1] := Count;
            end;
            Used := TRUE;
          end;
        end;
  end;


  procedure CreateHVEdgeData;

    procedure AddHEdge (tile1, tile2, Cnt: Integer);
      var
        i, L: Integer;
    begin
      L := Length (HEdges[itab]);
      for i := 0 to L - 1 do
        with HEdges[itab][i] do
          if (Tiles[0] = tile1) and (Tiles[1] = tile2) then
          begin
            Inc (Count, Cnt);
            Exit;
          end;
      SetLength (HEdges[itab], L + 1);
      with HEdges[itab][L] do
      begin
        Tiles[0] := tile1;
        Tiles[1] := tile2;
        Count := Cnt;
      end;
      aHEdgeCount[itab] := L + 1;
    end;

    procedure AddVEdge (tile1, tile2, Cnt: Integer);
      var
        i, L: Integer;
    begin
      L := Length (VEdges[itab]);
      for i := 0 to L - 1 do
        with VEdges[itab][i] do
          if (Tiles[0] = tile1) and (Tiles[1] = tile2) then
          begin
            Inc (Count, Cnt);
            Exit;
          end;
      SetLength (VEdges[itab], L + 1);
      with VEdges[itab][L] do
      begin
        Tiles[0] := tile1;
        Tiles[1] := tile2;
        Count := Cnt;
      end;
      aVEdgeCount[itab] := L + 1;
    end;

    var
      tile, edge, L, i: Integer;
  begin
    for tile := 0 to Length (aMCRSur[itab]) - 1 do
    begin
      edge := 6;
      L := Length (aMCRSur[itab][tile][edge]);
      for i := 0 to L - 1 do
        if i mod 2 = 0 then
          AddHEdge (tile, aMCRSur[itab][tile][edge][i], aMCRSur[itab][tile][edge][i + 1]);
      edge := 1;
      L := Length (aMCRSur[itab][tile][edge]);
      for i := 0 to L - 1 do
        if i mod 2 = 0 then
          AddHEdge (aMCRSur[itab][tile][edge][i], tile, aMCRSur[itab][tile][edge][i + 1]);

      edge := 4;
      L := Length (aMCRSur[itab][tile][edge]);
      for i := 0 to L - 1 do
        if i mod 2 = 0 then
          AddVEdge (tile, aMCRSur[itab][tile][edge][i], aMCRSur[itab][tile][edge][i + 1]);
      edge := 3;
      L := Length (aMCRSur[itab][tile][edge]);
      for i := 0 to L - 1 do
        if i mod 2 = 0 then
          AddVEdge (aMCRSur[itab][tile][edge][i], tile, aMCRSur[itab][tile][edge][i + 1]);
    end;
  end;


  procedure SortMCRSur;
    var
      tile, edge, L, i, j, t1, t2, n1, n2: Integer;
  begin
    for tile := 0 to Length (aMCRSur[itab]) - 1 do
      for edge := 0 to 7 do
      begin
        L := Length (aMCRSur[itab][tile][edge]);
        for i := 0 to L - 1 do
          if i mod 2 = 0 then
            for j := i + 2 to L - 1 do
              if j mod 2 = 0 then
              begin
                t1 := aMCRSur[itab][tile][edge][i];
                t2 := aMCRSur[itab][tile][edge][j];
                n1 := aMCRSur[itab][tile][edge][i + 1];
                n2 := aMCRSur[itab][tile][edge][j + 1];
                if n1 < n2 then
                begin
                  aMCRSur[itab][tile][edge][i] := t2;
                  aMCRSur[itab][tile][edge][j] := t1;
                  aMCRSur[itab][tile][edge][i + 1] := n2;
                  aMCRSur[itab][tile][edge][j + 1] := n1;
                end;
              end;
      end;
  end;


  function GetMostSurTile (itab, tile, edge: Integer): Integer;

    procedure RemoveMCRSur (P: Integer);
      var
        i, L: Integer;
    begin
      L := Length (aMCRSur[itab][tile][edge]);
      for i := P to L - 2 - 1 do
        aMCRSur[itab][tile][edge][i] := aMCRSur[itab][tile][edge][i + 2];
      SetLength (aMCRSur[itab][tile][edge], L - 2);
    end;

    var
      i, j, k, L, M, N, C: Integer;
      TT, TransTile, TC, TransCount: Integer;
  begin  { GetMostSurTile }
    M := -1;
    N := -1;
    TransTile := -1;
    TransCount := 0;
    L := Length (aMCRSur[itab][tile][edge]);
    for i := 0 to L - 1 do
      if i mod 2 = 0 then
      begin
        C := aMCRSur[itab][tile][edge][i + 1];

        TT := aMCRSur[itab][tile][edge][i];
        TC := aTrans[itab][TT][edge];
        if TC > TransCount then
        begin
          TransCount := TC;
          TransTile := TT;
        end;

        k := aSameAs[itab][aMCRSur[itab][tile][edge][i]][7 - edge];
        while k > -1 do
        begin
          for j := 0 to L - 1 do
            if j mod 2 = 0 then
              if aMCRSur[itab][tile][edge][j] = k then
                Inc (C, aMCRSur[itab][tile][edge][j + 1]);
          k := aSameAs[itab][k][7 - edge];
        end;

        if C > N then
        begin
          N := C;
          M := aMCRSur[itab][tile][edge][i];
        end;
      end;

    if TransCount = 0 then
    begin
      k := M;
      while k > -1 do
      begin
        for j := Length (aMCRSur[itab][tile][edge]) - 1 downto 0 do
          if j mod 2 = 0 then
            if aMCRSur[itab][tile][edge][j] = k then
              RemoveMCRSur (j);
        k := aSameAs[itab][k][7 - edge];
      end;
      Result := M;
    end
    else
      Result := TransTile;
  end;


  function RunCode: string;
    var
      CurPos: Integer;
      ErrorPos: Integer;
      ErrorMsg: string;

      WritingFile: Boolean;
      WritingBinFile: Boolean;  // 2.5
      DefaultBinFileBits: Integer;

      ReadingTextFile: Boolean;  // 3.0
      ReadingBinFile: Boolean;
      InputFileName: string;
      InputFilePos: LongInt;
      TI: TextFile;
      FI: file of Byte;



    procedure CodeError (P: Integer; Msg: string);
      var
        i, Line: Integer;
        S: string;
    begin
      if not Error then
      begin
        Line := 0;
        i := 1;
        S := '';
        while i < P do
        begin
          if i <= Length (code) then
          begin
            if code[i] = #0 then
            begin
              S := '';
              Inc (Line);
            end
            else
              S := S + code[i];
            Inc (i);
          end;
        end;
        while (i <= Length (code)) and (code[i] <> #0) do
        begin
          S := S + code[i];
          Inc (i);
        end;
        Error := TRUE;
        ErrorMsg := 'Error in line ' + IntToStr (Line) + ':'#13#10 +
                     S + #13#10 +
                     Msg;
        ErrorPos := P;
      end;
    end;

    function GetToken: string;
      var
        s: string;
    begin
      Quote := FALSE;
      GetToken := '';
      if CurPos > Length (code) then
        Exit
      else
      begin
        s := '';
        if code[CurPos] in ['a'..'z', 'A'..'Z', '0'..'9'] then
          repeat
            s := s + code[CurPos];
            Inc (CurPos);
          until not (code[CurPos] in ['a'..'z', 'A'..'Z', '0'..'9'])
        else
        begin
          s := code[CurPos];
          Inc (CurPos);
          if s = '\' then
          begin
            Quote := TRUE;
            s := code[CurPos];
            Inc (CurPos);
            if s = 'n' then
              s := #13#10;
            if s = 'b' then
              s := #8;
            if s = 't' then
              s := #9;
         //   if s = '0' then     // 2.0
         //     s := #0;          // #0: eof
          end;
        end;
        GetToken := s;
      end;
    end;

    function LookAheadToken: string;
      var
        oldpos: Integer;
    begin
      oldpos := CurPos;
      ReadingAhead := TRUE;
      LookAheadToken := GetToken;
      ReadingAhead := FALSE;
      CurPos := oldpos;
    end;

    function GetLine: string;
      var
        t, s: string;
    begin
      t := '';
      repeat
        s := LookAheadToken;
        if s <> #0 then
          t := t + GetToken;
      until (s = '') or (s = #0);
      GetLine := t;
    end;

    function UGetToken: string;
    begin
      UGetToken := UpCaseStr (GetToken);
    end;

    function USGetToken: string;
      var
        s: string;
    begin
      repeat
        s := UpCaseStr (GetToken);
      until s <> ' ';
      USGetToken := s;
    end;

    procedure FindEnd (Token: string);
      var
        s: string;
        P: Integer;
        RecursiveCount: Integer;
      label
        again;
    begin
      P := CurPos;
      RecursiveCount := 0;
    again:
      repeat
        s := GetToken;
      until ((s = #0) and (LookAheadToken = '#')) or
             (s = '');
      if s = '' then
      begin
        CodeError (P, 'No matching #END ' + Token + ' found');
        Exit;
      end;
      s := GetToken;  // '#'
      s := UGetToken;
      if s = Token then
      begin
        Inc (RecursiveCount);
        goto again;
      end;
      if s <> 'END' then
        goto again;
      if USGetToken <> Token then
        goto again;
      if RecursiveCount > 0 then
      begin
        Dec (RecursiveCount);
        goto again;
      end;
    end;

    function GetString: string;
      var
        s, t: string;
        P: Integer;
    begin
      t := '';
      while LookAheadToken = ' ' do
        s := GetToken;
      s := GetToken;
      if s = #0 then
      begin
        GetString := '';
        Dec (CurPos);
        Exit;
      end;
      if s = '"' then
      begin
        P := CurPos;
        while LookAheadToken <> '"' do
        begin
          s := GetToken;
          t := t + s;
          if s = '' then
          begin
            CodeError (P, 'Unterminated string');
            Exit;
          end;
        end;
        s := GetToken;
      end
      else   // allow '...' as well as "..."
        if s = #39 then
        begin
          P := CurPos;
          while LookAheadToken <> #39 do
          begin
            s := GetToken;
            t := t + s;
            if s = '' then
            begin
              CodeError (P, 'Unterminated string');
              Exit;
            end;
          end;
          s := GetToken;
        end
        else
        begin
          repeat
            t := t + s;
            s := GetToken;
          until (s = ' ') or (s = #0) or (s = '');
          if s <> '' then
            Dec (CurPos);
        end;
      GetString := t;
    end;


    function GetTokenSpecial: string;
      var
        s, t, u, v, fmt: string;
        oldpos, erp: Integer;
        Number: Integer;
        NumberBytes: packed array[0..3] of Byte absolute Number;
        F: ShortString;
        i, bits: Integer;
    begin
      if WritingBinFile and (not Quote) and (LookAheadToken = '"') then  // 2.5
      begin
        GetTokenSpecial := GetString;
        Exit;
      end
      else
        t := GetToken;

      if (t = '<') and (not Quote) then
      begin
        NumericExpr := TRUE;

        oldpos := CurPos;
        t := '';
        repeat
          s := GetToken;
          if (ValidNumber (s)) or
              ((Length (s) = 1) and (s[1] in ExprChars)) then
            t := t + s
          else
            t := t + GetVarValue (s, '%d');
          u := LookAheadToken;
        until (u = ':') or (u = '>') or (u = #0);
        u := GetToken;

        if u = ':' then
        begin
          fmt := GetString;
          u := GetToken;
        end
        else
          if WritingBinFile then
            fmt := IntToStr (DefaultBinFileBits)
          else
            fmt := '%d';

        if (s = '<') or (u <> '>') then
        begin
          CurPos := oldpos;
          if s = '<' then
            t := GetToken;
          GetTokenSpecial := t;
          Exit;
        end;

        if NumericExpr then
        begin
          F := t;
          if not Evaluate (Number, F, Erp) then
            Error := TRUE
          else
          begin

            if WritingBinFile then
            begin
              bits := -1;
              if (ValidNumber (Fmt)) then
                bits := StrToInt (Fmt);

              if bits = -1 then
                Error := TRUE
              else
              begin
                if bits < 0 then  // 2.52 - big endian
                begin
                  bits := Abs (bits);
                  asm
                    push ebx
                    mov eax, Number
                    mov ecx, bits
                    mov ebx, 0
                  @@1:
                    shr eax, 1
                    rcl ebx, 1
                    dec ecx
                    jnz @@1

                    mov Number, ebx
                    pop ebx
                  end;
                end;

                v := '';
                for i := 0 to bits div 8 - 1 do
                  v := v + Chr (NumberBytes[i]);
                GetTokenSpecial := #0 + v + #0;
              end;

            end
            else
            begin
              v := Format (Fmt, [Number]);
              GetTokenSpecial := AddLeadingZeros (v, Fmt);
            end;

          end;
        end
        else
          GetTokenSpecial := t;

        if Error then
        begin
          Error := FALSE;
          if NumericExpr then
            CodeError (oldpos, 'Error in expression (' + t + ').')
          else
            CodeError (oldpos, 'Unknown variable (' + t + ').');
        end;

      end
      else
        GetTokenSpecial := t;
    end;


    function GetStringOrToken: string;
    begin
      Result := GetString;
      exit;
    
      while LookAheadToken = ' ' do
        GetToken;
      if LookAheadToken = #0 then
        GetStringOrToken := ''
      else
        if (not WritingBinFile) or (LookAheadToken = '"') then
          GetStringOrToken := GetString
        else
          GetStringOrToken := GetTokenSpecial;
    end;


    function GetFilename: string;
      var
        s, t: string;
    begin
      repeat
        s := GetTokenSpecial;
      until s <> ' ';
      t := s;
      while (s <> '') and (s <> ' ') and (s <> #0) do
      begin
        s := GetTokenSpecial;
        t := t + s;
      end;
      if s <> '' then
      begin
        Dec (CurPos);
        if t <> '' then
          Delete (t, Length (t), 1);  // bug fix 2.5 (saving .PNG files)
      end;

      if (t[1] in ['"', #39]) and (t[Length (t)] = t[1]) then
        t := Copy (t, 2, Length (t) - 2);

      GetFilename := t;
    end;


    function AdjustFilename (Filename: string; Path: string): string;
    begin
      if (Filename = '') or (Pos (':', Filename) = 2) or (Filename[1] = '\') then
        AdjustFilename := Filename
      else
        AdjustFilename := Path + Filename;
    end;


    function GetTextFileLineCount (Filename: string): LongInt;
      var
        TF: TextFile;
        N: LongInt;
    begin
      if not FileExists (Filename) then
      begin
        GetTextFileLineCount := 0;
        Exit;
      end;
      AssignFile (TF, Filename);
      N := 0;
      Reset (TF);
      while not Eof (TF) do
      begin
        ReadLn (TF);
        Inc (N);
      end;
      CloseFile (TF);
      GetTextFileLineCount := N;
    end;

    function GetBinFileSize (Filename: string): LongInt;
      var
        F: file of Byte;
    begin
      AssignFile (F, Filename);
      Reset (F);
      GetBinFileSize := FileSize (F);
      CloseFile (F);
    end;


    function GetValidTileSet: Boolean;
    begin
      GetValidTileSet := TRUE;
      while itab < Tab.Tabs.Count do
        with TileTab[itab] do
        begin
          if not TileTab[itab].tbr.SkipExport then  // 2.2
          begin
            ValidTileSet := TRUE;
            ValidTSTileSet := TRUE;
            if (bmpFinal[itab].Height > 0) then
              Exit;
            ValidTileSet := FALSE;
            if (tbr.TileCount > 0) then
              Exit;
            ValidTSTileSet := FALSE;
          end;
          Inc (itab);
        end;
      ValidTileSet := FALSE;
      ValidTSTileSet := FALSE;
      GetValidTileSet := FALSE;
    end;


    // 2.4
    function InitCornerVars: Boolean;  // false if no more corners
      var
        i: Integer;
    begin
      InitCornerVars := FALSE;
      SetNumVar ('CornerNumber', -1);
      if TexTiles then
      begin
        for i := 0 to Length (Corners[itab]) - 1 do
          with Corners[itab][i] do
            if icorner = Number then
            begin
              SetNumVar ('TopLeftTile', Tiles[0]);
              SetNumVar ('TopRightTile', Tiles[1]);
              SetNumVar ('BottomLeftTile', Tiles[2]);
              SetNumVar ('BottomRightTile', Tiles[3]);
            {
              SetNumVar ('TopLeftColor', Colors[0]);
              SetNumVar ('TopRightColor', Colors[1]);
              SetNumVar ('BottomLeftColor', Colors[2]);
              SetNumVar ('BottomRightColor', Colors[3]);
            }
              SetNumVar ('CornerNumber', icorner);
              InitCornerVars := TRUE;
            end;
      end;
    end;

    procedure InitHEdgeVars;
    begin
      SetNumVar ('HEdgeNumber', ihedge);
      with HEdges[itab][ihedge] do
      begin
        SetNumVar ('TopTile', Tiles[0]);
        SetNumVar ('BottomTile', Tiles[1]);
      end;
    end;

    procedure InitVEdgeVars;
    begin
      SetNumVar ('VEdgeNumber', ivedge);
      with VEdges[itab][ivedge] do
      begin
        SetNumVar ('LeftTile', Tiles[0]);
        SetNumVar ('RightTile', Tiles[1]);
      end;
    end;



    procedure InitPaletteVars;
      var
        s: string;
    begin
      SetNumVar ('PaletteNumber', ipal);
      s := PaletteManager.GetID (ipal);
      SetStrVar ('PaletteIdentifier', s);
      if s = '' then
      begin
        SetNumVar ('PaletteSize', 0);
        SetNumVar ('PalettePreset', 0);
      end
      else
      begin
        SetNumVar ('PaletteSize', aiPalSize[ipal]);
        SetNumVar ('PalettePreset', aiPreset[ipal]);
      end;
    end;

    procedure InitTileSetVars;
      var
        R, G, B: Integer;
        NH, NV: Integer;
        N, MC: Integer;
    begin
      with TileTab[itab] do
      begin
        GetRGB (TRANS_COLOR, R, G, B);
        NH := bmpFinal[itab].Width div tbr.W;
        NV := bmpFinal[itab].Height div tbr.H;

        SetStrVar ('TileSetIdentifier', tab.Tabs[itab]);
        SetNumVar ('TileSetNumber', itab);
        SetNumVar ('TileWidth', tbr.W div GetTinyNH);
        SetNumVar ('TileHeight', tbr.H div GetTinyNV);

      //  SetNumVar ('TileCount', NH * NV);
        if TinyTiles then
        begin
          SetNumVar ('TileCount', aFinalTinyTileCount[itab][NOFLIP]);
          SetNumVar ('TSTileCount', tbr.TileCount * TinyNH * TinyNV);  // 2.2
        end
        else
        begin
          SetNumVar ('TileCount', aFinalTileCount[itab]);  // 2.0
          SetNumVar ('TSTileCount', tbr.TileCount);  // 2.2

          if UTT then
            SetNumVar ('UniqueTexTileCount', aUTTCount[itab]);  // 2.5
        end;

        SetNumVar ('SequenceCount', 0);  // 2.52
        SetNumVar ('MapCount', 0);  // 2.53

        if ValidTileSet then
        begin
          SetNumVar ('HorizontalTileCount', NH);
          SetNumVar ('VerticalTileCount', NV);
          SetNumVar ('TileSetBitmapWidth', bmpFinal[itab].Width);
          SetNumVar ('TileSetBitmapHeight', bmpFinal[itab].Height);
          SetNumVar ('TransparentPosX', TransX[itab]);    // 2.0 update documentation!
          SetNumVar ('TransparentPosY', TransY[itab]);

         // SetNumVar ('MapCount', Length (tbr.Maps.aMaps));
          MC := 0;
          for N := 0 to Length (tbr.Maps.aMaps) - 1 do   // 2.53: fixed: MapCount doesn't include skipped maps
            if not tbr.Maps.aMaps[N].SkipExport then Inc (MC);   // 2.55: fixed MapCount
          SetNumVar ('MapCount', MC);

          SetNumVar ('SequenceCount', Length (tbr.Seq.aMaps));
        end
        else  // 3.0
          if (tbr.LastExportW <> 0) and (tbr.LastExportH <> 0) then
          begin
            SetNumVar ('HorizontalTileCount', tbr.LastExportW div tbr.W);
            SetNumVar ('VerticalTileCount', tbr.LastExportH div tbr.H);
            SetNumVar ('TileSetBitmapWidth', tbr.LastExportW);
            SetNumVar ('TileSetBitmapHeight', tbr.LastExportH);
            SetNumVar ('TransparentPosX', tbr.LastExportTransX);
            SetNumVar ('TransparentPosY', tbr.LastExportTransY);
          end;

        SetNumVar ('TransparentColorR', R);
        SetNumVar ('TransparentColorG', G);
        SetNumVar ('TransparentColorB', B);
        GetRGB (BackGrColor, R, G, B);
        SetNumVar ('BackgroundColorR', R);
        SetNumVar ('BackgroundColorG', G);
        SetNumVar ('BackgroundColorB', B);

        SetNumVar ('Overlap', tbr.Overlap);  // 2.0

        // 2.0
      //  if ipal = -1 then   // bug fix 2.34 (caused all tile sets to use first palette)
        begin
          ipal := tbr.PaletteNumber;
          InitPaletteVars;
        end;

        // 2.4
        if TexTiles then
        begin
          SetNumVar ('CornerCount', aCornerCount[itab]);
          SetNumVar ('HEdgeCount', aHEdgeCount[itab]);
          SetNumVar ('VEdgeCount', aVEdgeCount[itab]);
        end;

        SetEdgeRects (tbr.W, tbr.H);  // 2.5
      end;
    end;


    procedure InitTileVars (Tile0: Boolean);

      procedure InitSurVar (VarName: string; Edge: Integer);
        var
          it: Integer;
      begin
        if Tile0 then
          it := 0
        else
          it := itile + 1;
        SetNumVar (VarName, 0);
        if TexTiles and (iutt < 0) then
          if it < Length (aMCRSur[itab]) then
            SetNumVar (VarName, Integer (Boolean (Length (aMCRSur[itab][it][Edge]) <> 0)))
      end;

    begin  { InitTileVars }

      if tile0 then
        SetNumVar ('TileNumber', -1)
      else
        if iutt >= 0 then
          SetNumVar ('TileNumber', iutt)
        else
          if itstile >= 0 then
            SetNumVar ('TileNumber', itstile)
          else
            SetNumVar ('TileNumber', itile);

      // 2.4
      InitSurVar ('OtherTopLeftCorners', 0);
      InitSurVar ('OtherTopEdges', 1);
      InitSurVar ('OtherTopRightCorners', 2);
      InitSurVar ('OtherLeftEdges', 3);
      InitSurVar ('OtherRightEdges', 4);
      InitSurVar ('OtherBottomLeftCorners', 5);
      InitSurVar ('OtherBottomEdges', 6);
      InitSurVar ('OtherBottomRightCorners', 7);

      // 2.5
      if TexTiles then
      begin
        SetNumVar ('UniqueTexTileNumber', iutt);
      end;
    end;


    // 2.4
    procedure InitPixelVars (RGB: Integer; A: Integer);
      var
        i, R, G, B: Integer;
        rr, gg, bb, index, tmp, best: Integer;
    begin
      GetRGB (RGB, R, G, B);
      SetNumVar ('RGB', RGB);

      SetNumVar ('R', R);
      SetNumVar ('G', G);
      SetNumVar ('B', B);

      if A > 255 then A := 255 else if A < 0 then A := 0;
      SetNumVar ('A', A);

      SetNumVar ('Pixel', 0);

      if (ipal >= 0) and (Length (aaiPal) > 0) then
        if Length (aaiPal[ipal]) > 0 then
        begin
          best := -1;
          index := -1;

          for i := 0 to { Length (aaiPal[ipal]) } aiPalSize[ipal] - 1 do    // 2.41
          begin
            GetRGB (aaiPal[ipal][i], rr, gg, bb);
            tmp := sqr ((R - rr) * 2) + sqr ((G - gg) * 2) + sqr ((B - bb) * 2);
            if (index = -1) or (tmp < best) then
            begin
              index := i;
              best := tmp;
            end;
          end;
          SetNumVar ('Pixel', index);
        end;

      if RGB = TRANS_COLOR then
      begin
        SetNumVar ('Pixel', -1);
        SetNumVar ('A', 0);
      end;

      CurRGB := RGB;  // 2.54
    end;


    function InitHEdgeDatVars: Boolean;
      var
        i, j: Integer;
        RGB: Integer;
        A: Integer;
    begin
      with TileTab[itab] do
      begin
        with HEdges[itab][ihedge] do
        begin
          i := 1 + (ihedgedat mod tbr.W);
          if ihedgedat div tbr.W = 0 then
            j := (Tiles[0] - 1) * (tbr.H + 2) + tbr.H
          else
            j := (Tiles[1] - 1) * (tbr.H + 2) + 1;

          if j < 0 then
            RGB := TRANS_COLOR
          else
            RGB := bmpTexTiles[itab].Canvas.Pixels[i, j];

          A := 255;
          if aa then
            A := bmpTexAlpha[itab].Canvas.Pixels[i, j];
          InitPixelVars (RGB, A);

          SetNumVar ('X', ihedgedat mod tbr.W);
          SetNumVar ('Y', ihedgedat div tbr.W);
        end;
      end;
      InitHEdgeDatVars := RGB <> TRANS_COLOR;
    end;


    function InitVEdgeDatVars: Boolean;
      var
        i, j: Integer;
        RGB: Integer;
        A: Integer;
    begin
      with TileTab[itab] do
      begin
        with VEdges[itab][ivedge] do
        begin
          if ivedgedat mod 2 = 0 then
            i := tbr.W
          else
            i := 1;
          j := (Tiles[ivedgedat mod 2] - 1) * (tbr.H + 2) + (ivedgedat div 2) + 1;
          if j < 0 then
            RGB := TRANS_COLOR
          else
            RGB := bmpTexTiles[itab].Canvas.Pixels[i, j];

          A := 255;
          if aa then
            A := bmpTexAlpha[itab].Canvas.Pixels[i, j];
          InitPixelVars (RGB, A);

          SetNumVar ('X', ivedgedat mod 2);
          SetNumVar ('Y', ivedgedat div 2);
        end;
      end;
      InitVEdgeDatVars := RGB <> TRANS_COLOR;
    end;


    function InitCornerDatVars: Boolean;
      var
        i: Integer;
        RGB: Integer;
    begin
      RGB := TRANS_COLOR;
     { SetNumVar ('CornerNumber', -1); }
      for i := 0 to Length (Corners[itab]) - 1 do
        with Corners[itab][i] do
          if icorner = Number then
          begin
            RGB := Colors[icornerdat];
            InitPixelVars (RGB, 255);
           { SetNumVar ('Index', icornerdat); }
            SetNumVar ('X', icornerdat mod 2);
            SetNumVar ('Y', icornerdat div 2);
          end;
      InitCornerDatVars := RGB <> TRANS_COLOR;
    end;



  {
    procedure InitTinyTileVars;
    begin
      SetNumVar ('TinyTileNumber', itinytile);
    end;
  }

  {
    function InitTinyTileDatVars: Boolean;
      var
        x, y: Integer;
        i, RGB, R, G, B: Integer;
        rr, gg, bb, index, tmp, best: Integer;
    begin
      with TileTab[itab] do
      begin
        GetTinyPos (itab, aFinalTinyTiles[itab][TinyFlip][itinytile], x, y);
        Inc (x, idat mod TinyW);
        Inc (y, idat div TinyH);

        RGB := bmpFinal[itab].Canvas.Pixels[x, y];

        InitPixelVars (RGB, 255);
      end;
      InitTinyTileDatVars := RGB <> TRANS_COLOR;
    end;
  }

    // returns FALSE if pixel is transparent
    function InitTileDatVars: Boolean;
      var
        NH, x, y: Integer;
        tbrtilenr, tinytilenr: Integer;
        RGB: Integer;
        xpos, ypos: Integer;  // 2.34
        A: Integer;  // 2.5
        i, j, k: Integer;
        rr, gg, bb: Integer;
        tr, tg, tb, ta: Integer;
    begin
      with TileTab[itab] do
      begin
        if itstile >= 0 then
        begin
          if TinyTiles then
          begin

           // if 4 * itstile div (TinyNH * TinyNV) > 0 then
           //   asm nop end;

            tbrtilenr := itstile div (TinyNH * TinyNV);
            tinytilenr := itstile mod (TinyNH * TinyNV);
            x := tbr.w * tbrtilenr;
            y := 0;
            Inc (x, (tinytilenr mod TinyNH) * TinyW);
            Inc (y, (tinytilenr div TinyNH) * TinyH);
          {
            x := tbr.W * itstile div (TinyNH * TinyNV) +
                 TinyW * ((itstile mod (TinyNH * TinyNV)) mod TinyNH);
            y := TinyH * ((itstile mod (TinyNH * TinyNV)) div TinyNH);
          }
            XPos := idat mod TinyW;
            YPos := idat div TinyW;
          end
          else
          begin  { not tinytiles }
            x := tbr.W * itstile;
            y := 0;
            XPos := idat mod tbr.W;
            YPos := idat div tbr.W;
          end;

          if aa then
          begin
            tr := 0;  tg := 0;  tb := 0;  ta := 0;
            k := 0;

            for j := 0 to aaY - 1 do
              for i := 0 to aaX - 1 do
              begin
                RGB := tbr.TileBitmap.Canvas.Pixels[x * aaX + XPos * aaX + i, y * aaY + YPos * aaY + j];
                if RGB <> TRANS_COLOR then
                begin
                  GetRGB (RGB, rr, gg, bb);
                  Inc (tr, rr);
                  Inc (tg, gg);
                  Inc (tb, bb);
                  Inc (ta, 255);
                  Inc (k);
                end;
              end;
            if ta = 0 then
            begin
              RGB := TRANS_COLOR;
              A := 0;
            end
            else
            begin
              RGB := (tr div k) + ((tg div k) shl 8) + ((tb div k) shl 16);
              A := ta div (aaX * aaY);
            end;

          end
          else
          begin
            RGB := tbr.TileBitmap.Canvas.Pixels[x + XPos, y + YPos];
            A := 255;
          end;

        end
        else
        begin  { itstile = -1 }

          if TinyTiles then
          begin
            GetTinyPos (itab, aFinalTinyTiles[itab][TinyFlip][itile], x, y);
            XPos := idat mod TinyW;
            YPos := idat div TinyW;
            if (x = -1) or (y = -1) then
            begin
              RGB := TRANS_COLOR;
              A := 0;
            end
            else
            begin
              Inc (x, XPos);
              Inc (y, YPos);
              RGB := bmpFinal[itab].Canvas.Pixels[x, y];
              if aa then
                A := bmpAlpha[itab].Canvas.Pixels[x, y]
              else
                A := 255;
            end;
          end
          else
          begin  { not TinyTiles }
            NH := bmpFinal[itab].Width div tbr.W;
            x := (itile mod NH) * tbr.W;
            y := (itile div NH) * tbr.H;
            XPos := idat mod tbr.W;
            YPos := idat div tbr.W;
            Inc (x, XPos);
            Inc (y, YPos);
            RGB := bmpFinal[itab].Canvas.Pixels[x, y];
            if aa then
              A := bmpAlpha[itab].Canvas.Pixels[x, y]
            else
              A := 255;
          end;

        end;

        InitPixelVars (RGB, A);

        // 2.34
        SetNumVar ('X', XPos);
        SetNumVar ('Y', YPos);

      end;
      InitTileDatVars := RGB <> TRANS_COLOR;
    end;



    // 2.4
    function InitTexTileDatVars: Boolean;  // FALSE: transparent
      var
        NH, x, y: Integer;
        xpos, ypos: Integer;
        RGB: Integer;
        t, tile, j, k, l, edge: Integer;
        tmpx, tmpy: Integer;
        A: Integer;

    function Inside (X, Y: Integer; R: TRect): Boolean;
    begin
      Inside := (X >= R.Left) and (X < R.Right) and
                 (Y >= R.Top) and (Y < R.Bottom);
    end;

    begin
      with TileTab[itab] do
      begin
        NH := bmpTexTiles[itab].Width div (tbr.W + 2);

        if UTT and (iutt >= 0) then
        begin
          t := aUTTIndex[itab][iutt] - 1;
          tile := t;
          XPos := idat mod (tbr.W + 2);
          YPos := (idat div (tbr.W + 2)) mod (tbr.H + 2);
          tmpx := XPos;
          tmpy := YPos;

          {
            tmpx := XPos - EdgeDst[edge].Left + EdgeSrc[7 - edge].Left;
            tmpy := YPos - EdgeDst[edge].Top + EdgeSrc[7 - edge].Top;
          }

          for edge := 0 to 7 do
            if Inside (XPos, YPos, EdgeDst[edge]) then
              if (t + 1 < Length (aUTTRef[itab])) then
              begin

                l := Length (aUTTRef[itab][t + 1]);
                for j := 0 to l - 1 do
                  if aUTTRef[itab][t + 1][j][8] = iutt + 1 then
                  begin
                    k := aUTTRef[itab][t + 1][j][edge];
                    if EdgeToCorner[edge] = -1 then
                      tile := k - 1
                    else
                      tile := Corners[itab][k].Tiles[EdgeToCorner[7 - edge]] - 1;
                    tmpx := XPos - EdgeDst[edge].Left + EdgeSrc[edge].Left;
                    tmpy := YPos - EdgeDst[edge].Top + EdgeSrc[edge].Top;
                  end;
              end;

          if tile = -1 then
          begin
            RGB := TRANS_COLOR;
            A := 0;
          end
          else
          begin
            x := (tile mod NH) * (tbr.W + 2);
            y := (tile div NH) * (tbr.H + 2);
            Inc (x, tmpx);
            Inc (y, tmpy);
            RGB := bmpTexTiles[itab].Canvas.Pixels[x, y];
            A := 255;
            if aa then
              A := bmpTexAlpha[itab].Canvas.Pixels[x, y];
          end;

        end
        else
        begin
          x := (itile mod NH) * (tbr.W + 2);
          y := (itile div NH) * (tbr.H + 2);
          XPos := idat mod (tbr.W + 2);
          YPos := idat div (tbr.W + 2);
          Inc (x, XPos);
          Inc (y, YPos);
          RGB := bmpTexTiles[itab].Canvas.Pixels[x, y];
          A := 255;
          if aa then
            A := bmpTexAlpha[itab].Canvas.Pixels[x, y];
        end;

        InitPixelVars (RGB, A);

        SetNumVar ('X', XPos);
        SetNumVar ('Y', YPos);
      end;
      InitTexTileDatVars := RGB <> TRANS_COLOR;
    end;


    procedure InitMapVars;
    begin
      with TileTab[itab].tbr.Maps.aMaps[imap] do
      begin
        SetStrVar ('MapIdentifier', ID);
        SetNumVar ('MapNumber', imap);
        MapHt := Length (Map) * GetTinyNV;
        if MapHt = 0 then
          MapWd := 0
        else
          MapWd := Length (Map[0]) * GetTinyNH;
        SetNumVar ('MapHeight', MapHt);
        SetNumVar ('MapWidth', MapWd);
        SetStrVar ('ScrollX', fx);    // 2.0 update documentation!
        SetStrVar ('ScrollY', fy);

      end;
    end;


    procedure InitTileMapVars;
      var
        x, y: Integer;
    begin
      if not TinyTiles then
        Exit;

      x := itilemap mod TinyNH;
      y := (itilemap div TinyNH) mod TinyNV;

      SetNumVar ('TinyTileNumber', aFinalTinyRef[itab][itile * 4 + itilemap][NOFLIP]);  // ????????

      SetNumVar ('X', x);
      SetNumVar ('Y', y);
    end;


    procedure InitMCRVars (mcr: MapCellRec);
      var
        TotalOfsX,
        TotalOfsY: Integer;   // 2.4

      procedure AddOfs (tile: Integer);
      begin
        tile := tile and TILE_MASK;
        with TileTab[itab].tbr do
        begin
          if tile < Length (OffsetX) then
            Inc (TotalOfsX, OffsetX[tile]);
          if tile < Length (OffsetY) then
            Inc (TotalOfsY, OffsetY[tile]);
        end;
      end;

    begin
      TotalOfsX := 0;
      TotalOfsY := 0;

     // if mcr.Bounds = $FF then
      if mcr.Bounds and $40 <> 0 then
      begin
       // SetNumVar ('TSBackTile', -1);    // 2.2
        SetNumVar ('TSBackTile', -(mcr.MapCode + 1));
        SetNumVar ('TSBackTile1', -(mcr.MapCode + 1));  // 2.53
        SetNumVar ('TSBackHF', 0);
        SetNumVar ('TSBackVF', 0);
        SetNumVar ('TSBackR', 0);
       // SetNumVar ('TSMidTile', -1);
        SetNumVar ('TSMidTile', -(mcr.MapCode + 1));
        SetNumVar ('TSMidTile1', -(mcr.MapCode + 1));
        SetNumVar ('TSMidHF', 0);
        SetNumVar ('TSMidVF', 0);
        SetNumVar ('TSMidR', 0);
       // SetNumVar ('TSFrontTile', -1);
        SetNumVar ('TSFrontTile', -(mcr.MapCode + 1));
        SetNumVar ('TSFrontTile1', -(mcr.MapCode + 1));
        SetNumVar ('TSFrontHF', 0);
        SetNumVar ('TSFrontVF', 0);
        SetNumVar ('TSFrontR', 0);
      end
      else
      begin
        if mcr.Back = -1 then
        begin
          SetNumVar ('TSBackTile', -1);
          SetNumVar ('TSBackTile1', 0);
          SetNumVar ('TSBackHF', 0);
          SetNumVar ('TSBackVF', 0);
          SetNumVar ('TSBackR', 0);
        end
        else
        begin
          AddOfs (mcr.Back);
          SetNumVar ('TSBackTile', mcr.Back and TILE_MASK);
          SetNumVar ('TSBackTile1', (mcr.Back and TILE_MASK) + 1);
          SetNumVar ('TSBackHF', Byte (mcr.Back and MIRROR_MASK <> 0));
          SetNumVar ('TSBackVF', Byte (mcr.Back and UPS_MASK <> 0));
          SetNumVar ('TSBackR', Byte (mcr.Back and ROTATE_MASK <> 0));
        end;

        if mcr.Mid = -1 then
        begin
          SetNumVar ('TSMidTile', -1);
          SetNumVar ('TSMidTile1', 0);
          SetNumVar ('TSMidVF', 0);
          SetNumVar ('TSMidHF', 0);
          SetNumVar ('TSMidR', 0);
        end
        else
        begin
          AddOfs (mcr.Mid);
          SetNumVar ('TSMidTile', mcr.Mid and TILE_MASK);
          SetNumVar ('TSMidTile1', (mcr.Mid and TILE_MASK) + 1);
          SetNumVar ('TSMidHF', Byte (mcr.Mid and MIRROR_MASK <> 0));
          SetNumVar ('TSMidVF', Byte (mcr.Mid and UPS_MASK <> 0));
          SetNumVar ('TSMidR', Byte (mcr.Mid and ROTATE_MASK <> 0));
        end;

        if mcr.Front = -1 then
        begin
          SetNumVar ('TSFrontTile', -1);
          SetNumVar ('TSFrontTile1', 0);
          SetNumVar ('TSFrontHF', 0);
          SetNumVar ('TSFrontVF', 0);
          SetNumVar ('TSFrontR', 0);
        end
        else
        begin
          AddOfs (mcr.Front);
          SetNumVar ('TSFrontTile', mcr.Front and TILE_MASK);
          SetNumVar ('TSFrontTile1', (mcr.Front and TILE_MASK) + 1);
          SetNumVar ('TSFrontHF', Byte (mcr.Front and MIRROR_MASK <> 0));
          SetNumVar ('TSFrontVF', Byte (mcr.Front and UPS_MASK <> 0));
          SetNumVar ('TSFrontR', Byte (mcr.Front and ROTATE_MASK <> 0));
        end;
      end;

      SetNumVar ('OffsetX', TotalOfsX);
      SetNumVar ('OffsetY', TotalOfsY);
    end;

    procedure InitMapDatVars;
      var
        x, y, i, j: Integer;
        mcr: MapCellRec;
    begin
      with TileTab[itab].tbr.Maps.aMaps[imap] do
      begin
        y := idat div MapWd;
        x := idat mod MapWd;
        mcr := Map[y div GetTinyNV, x div GetTinyNH];
        InitMCRVars (mcr);
       // if mcr.Bounds = $FF then
        if mcr.Bounds and $40 <> 0 then
        begin
          i := mcr.MapCode;
          j := -(i + 1);
         // if mcr.Bounds and $7F = 0 then   // 2.55
         //   mcr.Bounds := TileTab[itab].tbr.Seq.aMaps[i].Map[0, 0].Bounds;
        end
        else
        begin
          i := FindMCR (mcr);
          j := aFinalRef[itab][i];
        end;

        if TinyTiles then
        begin
          if j > 0 then
          begin
            Dec (j);
            j := aFinalTinyRef[itab][j * GetTinyNH * GetTinyNV +
                     (y mod GetTinyNV) * GetTinyNH +
                     (x mod GetTinyNH)][TinyFlip];
           { j := aFinalTinyTiles[itab][TinyFlip][j] + 1; }
          end
          else  // 2.34
            if j < 0 then
            begin
              j := (j + 1) * GetTinyNH * GetTinyNV - 1 -
                         ((y mod GetTinyNV) * GetTinyNH + (x mod GetTinyNH));
            end;
        end; { tinytiles }

        // 2.5
        if TexTiles then
        begin
          if j < 0 then
            SetNumVar ('UniqueTexTileNumber', j)
          else
            SetNumVar ('UniqueTexTileNumber', mcr.Tag);
        end;

        SetNumVar ('TileNumber', j);
        SetNumVar ('TileNumberLoByte', j mod $100);
        SetNumVar ('TileNumberHiByte', j div $100);
        with mcr do
        begin
          if j < 0 then
            MapCode := 0;
          SetNumVar ('Bounds', Bounds and (not $40));
          SetNumVar ('MapCode', MapCode);
          SetNumVar ('BoundMapValue', (Bounds and (not $40)) + (MapCode shl 8));
        end;

        // 2.34
        SetNumVar ('X', x);
        SetNumVar ('Y', y);

      end;
    end;

    procedure InitSeqVars;
      var
        m, c: Integer;
        i, j, k: Integer;
        Count: Integer;
       { LastSize: Integer; }
        isq: Integer;
        nvh: Integer;
       // x, y: Integer;
        s: string[255];
    begin
      nvh := GetTinyNH * GetTinyNV;  // 2.34 tinytiles sequences
      isq := iseq div nvh;
      k := iseq mod nvh;
     // x := k mod GetTinyNH;
     // y := k div GetTinyNH;

      SeqFrames := 0;
      if Length (TileTab[itab].tbr.Seq.aMaps) <= 0 then
        SeqLen := 0
      else
        with TileTab[itab].tbr.Seq.aMaps[isq] do
        begin
          if Length (Map) < 1 then
            SeqLen := 0
          else
          begin
            SeqLen := Length (Map[0]);
            for i := 0 to SeqLen - 1 do  // 3.0
              Inc (SeqFrames, 1 + Map[0][i].MapCode);
          end;

          SetStrVar ('SpriteName', tab.Tabs[itab]);
          SetNumVar ('SpriteNumber', iseq);
         { LastSize := -1; }
          with TileTab[itab].tbr.Maps do
            for m := 0 to Length (aMaps) - 1 do
              with aMaps[m] do
              begin
                Count := 0;
                s := '';
                if Length (Map) > 0 then
             {     if (LastSize = -1) or
                     (Length (Map) * Length (Map[0]) <= LastSize) then  }
                  begin
                   { LastSize := Length (Map) * Length (Map[0]); }
                    for j := 0 to Length (Map) - 1 do
                      for i := 0 to Length (Map[j]) - 1 do
                       // if (Map[j, i].Bounds = $FF) then
                        if (Map[j, i].Bounds and $40 <> 0) then
                        begin
                          c := Map[j, i].MapCode;
                        //  if Pos (Chr (c), s) = 0 then   { huh??? }
                          begin
                            s := s + Chr (c);
                            Inc (Count);

                            if c = isq then
                            begin
                              SetStrVar ('SpriteName',
                                TileTab[itab].tbr.Maps.aMaps[m].ID);

                              if TinyTiles then
                                SetNumVar ('SpriteNumber', (Count - 1) * nvh + 1 + k)
                              else
                                SetNumVar ('SpriteNumber', Count);
                            end;
                          end;
                        end;
                  end;
              end;

         // SetNumVar ('SpriteNumber', iseq);    // 2.43
          SetNumVar ('SequenceNumber', iseq + 1);
        end;
      SetNumVar ('SequenceLength', SeqLen);
      SetNumVar ('SpriteLength', SeqLen);
    end;

    procedure InitPalDatVars;
      var
        i, R, G, B: Integer;
    begin
      i := aaiPal[ipal][ipaldat];
      SetNumVar ('RGB', i);
      GetRGB (i, R, G, B);
      SetNumVar ('Index', ipaldat);
      SetNumVar ('R', R);
      SetNumVar ('G', G);
      SetNumVar ('B', B);
    end;

    procedure InitSeqDatVars;
      var
        i, j, k: Integer;
        mcr: MapCellRec;
        isq, nvh: Integer;
       // t, x, y: Integer;
    begin
      nvh := GetTinyNH * GetTinyNV;  // 2.34 tinytiles sequences
      isq := iseq div nvh;
      k := iseq mod nvh;

      with TileTab[itab].tbr.Seq.aMaps[isq] do
      begin
        mcr := Map[0, iseqdat];
        InitMCRVars (mcr);
        i := FindMCR (mcr);
        j := aFinalRef[itab][i];

        if TinyTiles then
          if j > 0 then
          begin
            Dec (j);
            j := aFinalTinyRef[itab][j * nvh + k][TinyFlip];
          end;

        SetNumVar ('TileNumber', j);
        SetNumVar ('FrameCount', mcr.MapCode);

        // 2.5
        if TexTiles then
          SetNumVar ('UniqueTexTileNumber', mcr.Tag);

        // 2.34
        SetNumVar ('Frame', iseqdat);


        SetNumVar ('TileNumberLoByte', j mod $100);   // 2.55
        SetNumVar ('TileNumberHiByte', j div $100);
        with mcr do
        begin
          if j < 0 then
            MapCode := 0;
          SetNumVar ('Bounds', Bounds and (not $40));
          SetNumVar ('MapCode', MapCode);
          SetNumVar ('BoundMapValue', (Bounds and (not $40)) + (MapCode shl 8));
        end;


      end;
    end;


    procedure InitSeqFrameVars;
      var
        i, j, k: Integer;
        mcr: MapCellRec;
        isq, nvh: Integer;
       // t, x, y: Integer;
    begin
      nvh := GetTinyNH * GetTinyNV;  // 2.34 tinytiles sequences
      isq := iseq div nvh;
      k := iseq mod nvh;

      with TileTab[itab].tbr.Seq.aMaps[isq] do
      begin

        i := iseqdat;
        j := 0;
        repeat
          mcr := Map[0, j];
          Dec (i, mcr.MapCode + 1);
          if i >= 0 then
            Inc (j);
        until (i < 0) or (j >= Length (Map[0]));

        InitMCRVars (mcr);
        i := FindMCR (mcr);
        j := aFinalRef[itab][i];

        if TinyTiles then
          if j > 0 then
          begin
            Dec (j);
            j := aFinalTinyRef[itab][j * nvh + k][TinyFlip];
          end;

        SetNumVar ('TileNumber', j);
        SetNumVar ('FrameCount', mcr.MapCode);

        // 2.5
        if TexTiles then
          SetNumVar ('UniqueTexTileNumber', mcr.Tag);

        // 2.34
        SetNumVar ('Frame', iseqdat);


        SetNumVar ('TileNumberLoByte', j mod $100);   // 2.55
        SetNumVar ('TileNumberHiByte', j div $100);
        with mcr do
        begin
          if j < 0 then
            MapCode := 0;
          SetNumVar ('Bounds', Bounds and (not $40));
          SetNumVar ('MapCode', MapCode);
          SetNumVar ('BoundMapValue', (Bounds and (not $40)) + (MapCode shl 8));
        end;


      end;
    end;


    procedure GetList (ListName: string; var str: TStringList);
      var
        i: Integer;
        Copying: Boolean;
        s, t: string;
    begin
      str.Clear;
      Copying := FALSE;
      for i := 0 to Lists.Notes.Lines.Count - 1 do
      begin
        s := Lists.Notes.Lines.Strings[i];
        t := Trim (s);
        if t = '' then
          Copying := FALSE
        else
          if (t[1] = '[') and (t[Length(t)] = ']') then
            Copying := FALSE;
        if Copying then
          str.Add (s);
        if Trim (UpCaseStr (s)) = '[' + UpCaseStr (ListName) + ']' then
          Copying := TRUE;
      end;
    end;


    function GetListLength (ListName: string): Integer;
      var
        str: TStringList;
    begin
      str := TStringList.Create ();
      GetList (ListName, str);
      GetListLength := str.Count;
      str.Free;
    end;


    procedure InitListVars (ListName: string; Index: Integer; Depth: Integer);
      var
        str: TStringList;
        s: string;
    begin
      str := TStringList.Create ();
      GetList (ListName, str);
      if Index < str.Count then
      begin
        s := str[Index];
        SetNumVar ('Index', Index);
        SetStrVar ('Item', s);
        if ValidNumber (s) then SetNumVar ('ItemValue', StrToInt (s));
        SetNumVar (ListName + 'Index', Index);
        SetStrVar (ListName + 'Item', s);
        if ValidNumber (s) then SetNumVar (ListName + 'ItemValue', StrToInt (s));
        SetNumVar (ListName + 'Index' + IntToStr (Depth), Index);
        SetStrVar (ListName + 'Item' + IntToStr (Depth), s);
        if ValidNumber (s) then SetNumVar (ListName + 'ItemValue' + IntToStr (Depth), StrToInt (s));
      end;
      str.Free;
    end;


    procedure InitFileDatVars;
      var
        s: string;
        b: Byte;
    begin
      if ReadingTextFile then
      begin
        ReadLn (TI, s);
        SetStrVar ('TextFileLine', s);
        if ValidNumber (s) then SetNumVar ('TextFileLineValue', StrToInt (s));
        SetNumVar ('LineNumber', InputFilePos);
      end;
      if ReadingBinFile then
      begin
        BlockRead (FI, b, 1);
        SetStrVar ('BinFileChar', Chr (b));
        SetNumVar ('BinFileByte', b);
        SetNumVar ('BinFilePos', InputFilePos);
      end;
      Inc (InputFilePos);
    end;



    // --------------


    procedure WidenBitmap (NewWidth: Integer);
      var
        W, H: Integer;
        Wd, M, N: Integer;
        x, y, i, j: Integer;
        Found: Boolean;
    begin
      W := TileTab[itab].tbr.W;
      H := TileTab[itab].tbr.H;
      if (W = 0) or (bmpFinal[itab].Width <> W) then
        Exit;
      N := 1;
      Wd := W;
      while Wd + W <= NewWidth do
      begin
        Inc (Wd, W);
        Inc (N);
      end;
      if N <= 1 then
        Exit;
      M := bmpFinal[itab].Height div H;
      if M > N then
      begin
        j := (M + (N - 1)) div N;   // height
        i := j * N - M;   // # unused
        while i >= j do
        begin
          Dec (Wd, W);
          Dec (N);
          Dec (i, j);
        end;
      end;
      with bmpFinal[itab] do
      begin
        Canvas.Brush.Color := TRANS_COLOR;
        Width := Wd;
        for i := 0 to M - 1 do
        begin
          x := (i mod N) * W;
          y := (i div N) * H;
          Canvas.CopyRect (MakeRect (x, y, W, H), Canvas, MakeRect (0, i * H, W, H));
        end;
        Height := ((M + (N - 1)) div N) * H;
        if M <= N then
          Width := M * W;

        Found := FALSE;
        for j := 0 to Height - 1 do
          for i := 0 to Width - 1 do
            if not Found then
              if Canvas.Pixels[i, j] = TRANS_COLOR then
              begin
                TransX[itab] := i;
                TransY[itab] := j;
                Found := TRUE;
              end;

        // if not Found then ....    impossible!
      end;
    end;


    type
      CmdType = (ctFile, ctBinFile, ctTileSet, ctTile, ctTSTile, ctTinyTiles,
                 ctTileData, ctTexTileData, ctMap, ctMapData,
                 ctPalette, ctPaletteData, ctSequence, ctSequenceData,
                 ctSequenceFrame,  // 3.00
                 ctCorner, ctCornerData,
                 ctHEdge, ctHEdgeData, ctVEdge, ctVEdgeData,
                 ctTileMap, ctTile0, ctUTTile,
                 ctTileBitmap, ctTSTileBitmap,
                 ctList,
                 ctReadTextFile, ctReadBinFile
                 );

      CommandRec =
        record
          KeyWord,
          Parameters: string;
          ReqCmd: set of CmdType;
          idx: ^Integer;
          NewLine: Boolean;

          sFilename,
          sListName,
          sBegin,
          sSeparator,
          sLongLineSeparator,
          sNextSeparator,
          sEnd,
          sTrans: string;

          DataWidth,
          DataHeight,
          CodeStart: Integer;
        end;

    const
      SupportedCmds = [ctTile, ctTexTileData, ctCorner, ctCornerData,
                       ctMap, ctMapData, ctSequence, ctSequenceData,
                       ctSequenceFrame,
                       ctHEdge, ctHEdgeData, ctVEdge, ctVEdgeData,
                       ctTileData, ctTileMap, ctTile0, ctTSTile,
                       ctPalette, ctPaletteData, ctUTTile,
                       ctTileBitmap, ctTSTileBitmap,
                       ctList,
                       ctReadTextFile, ctReadBinFile
                       ];

    const
      Commands: array[CmdType] of CommandRec =
      (
        ( KeyWord: 'FILE';          Parameters: 'F';       ReqCmd: [];                  idx: nil;           NewLine: FALSE; ),
        ( KeyWord: 'BINFILE';       Parameters: 'FW';      ReqCmd: [];                  idx: nil;           NewLine: FALSE; ),
        ( KeyWord: 'TILESET';       Parameters: 'S';       ReqCmd: [];                  idx: @itab;         NewLine: TRUE; ),
        ( KeyWord: 'TILE';          Parameters: 'S';       ReqCmd: [ctTileSet];         idx: @itile;        NewLine: TRUE; ),
        ( KeyWord: 'TSTILE';        Parameters: 'S';       ReqCmd: [ctTileSet];         idx: @itstile;      NewLine: TRUE; ),
        ( KeyWord: 'TINYTILES';     Parameters: 'WH';      ReqCmd: [ctTileSet];         idx: nil;           NewLine: FALSE; ),
        ( KeyWord: 'TILEDATA';      Parameters: 'BSLNET';  ReqCmd: [ctTile, ctTSTile];  idx: @idat;         NewLine: FALSE; ),
        ( KeyWord: 'TEXTILEDATA';   Parameters: 'BSLNET';  ReqCmd: [ctTile, ctUTTile];  idx: @idat;         NewLine: FALSE; ),
        ( KeyWord: 'MAP';           Parameters: 'S';       ReqCmd: [ctTileSet];         idx: @imap;         NewLine: TRUE; ),
        ( KeyWord: 'MAPDATA';       Parameters: 'BSLNE';   ReqCmd: [ctMap];             idx: @idat;         NewLine: FALSE; ),
        ( KeyWord: 'PALETTE';       Parameters: 'S';       ReqCmd: [];                  idx: @ipal;         NewLine: TRUE; ),
        ( KeyWord: 'PALETTEDATA';   Parameters: 'BSE';     ReqCmd: [ctPalette];         idx: @ipaldat;      NewLine: FALSE; ),
        ( KeyWord: 'SEQUENCE';      Parameters: 'S';       ReqCmd: [ctTileSet];         idx: @iseq;         NewLine: TRUE; ),
        ( KeyWord: 'SEQUENCEDATA';  Parameters: 'BSE';     ReqCmd: [ctSequence];        idx: @iseqdat;      NewLine: FALSE; ),
        ( KeyWord: 'SEQUENCEFRAME'; Parameters: 'BSE';     ReqCmd: [ctSequence];        idx: @iseqdat;      NewLine: FALSE; ),
        ( KeyWord: 'CORNER';        Parameters: 'S';       ReqCmd: [ctTileSet];         idx: @icorner;      NewLine: TRUE; ),
        ( KeyWord: 'CORNERDATA';    Parameters: 'BSET';    ReqCmd: [ctCorner];          idx: @icornerdat;   NewLine: FALSE; ),
        ( KeyWord: 'HEDGE';         Parameters: 'S';       ReqCmd: [ctTileSet];         idx: @ihedge;       NewLine: TRUE; ),
        ( KeyWord: 'HEDGEDATA';     Parameters: 'BSLNET';  ReqCmd: [ctHEdge];           idx: @ihedgedat;    NewLine: FALSE; ),
        ( KeyWord: 'VEDGE';         Parameters: 'S';       ReqCmd: [ctTileSet];         idx: @ivedge;       NewLine: TRUE; ),
        ( KeyWord: 'VEDGEDATA';     Parameters: 'BSLNET';  ReqCmd: [ctVEdge];           idx: @ivedgedat;    NewLine: FALSE; ),
        ( KeyWord: 'TILEMAP';       Parameters: 'BSLNE';   ReqCmd: [ctTile, ctTSTile];  idx: @itilemap;     NewLine: FALSE; ),
        ( KeyWord: 'TILE0';         Parameters: '';        ReqCmd: [ctTileSet];         idx: @itile0;       NewLine: TRUE; ),
        ( KeyWord: 'UNIQUETEXTILE'; Parameters: 'S';       ReqCmd: [ctTileSet];         idx: @iutt;         NewLine: TRUE; ),
        ( KeyWord: 'TILEBITMAP';    Parameters: 'X';       ReqCmd: [];                  idx: @itb;          NewLine: FALSE; ),
        ( KeyWord: 'TSTILEBITMAP';  Parameters: 'X';       ReqCmd: [];                  idx: @itb;          NewLine: FALSE; ),
        ( KeyWord: 'LIST';          Parameters: 'PBSLE';   ReqCmd: [];                  idx: nil;           NewLine: FALSE; ),
        ( KeyWord: 'READTEXTFILE';  Parameters: 'FBSLE';   ReqCmd: [];                  idx: @ifile;        NewLine: FALSE; ),
        ( KeyWord: 'READBINFILE';   Parameters: 'FBSLE';   ReqCmd: [];                  idx: @ifile;        NewLine: FALSE; )
      );


    var
      Done: Boolean;
      s, t: string;

      FirstLine: Boolean;
      WritingMapData: Boolean;
      WritingTileData: Boolean;
      WritingTexTileData: Boolean;
     { WritingTinyTileData: Boolean; }
      WritingSeqData: Boolean;
      WritingSeqFrames: Boolean;  // 3.0
      WritingPalData: Boolean;
      WritingCornerData: Boolean;
      OutputFileName: string;
      OutputWidth: Integer;  // 2.5
      F: TextFile;
      TileSetStart,
      MapStart,
      MapDatStart,
      TileStart,
      TSTileStart,
     { TinyTileStart, }
      TileDatStart,
      TexTileDatStart,
     { TinyTileDatStart, }
      SeqStart,
      SeqDatStart,
      PaletteStart,
      PalDatStart,
      CornerStart,
      CornerDatStart: Integer;
      fmtSequenceSeparator: string;
      fmtStart, fmtSep, fmtSepOutputLine,
      fmtSepLine, fmtEnd, fmtMapSep, fmtTileSep,
      fmtTinyTileSep,
      fmtTSSep, fmtPalSep, fmtTrans: string;
      fmtCornerSep: string;
      filepos: Integer;
      LastPos: Integer;

      tmpi, tmpj: Integer;

      iCmd,
      tmpCmd,
      CurCmd: CmdType;
      CmdList: string;
      CmdOk: Boolean;
      sMsg: string;
      CurTrans: Boolean;

      // 3.0
      ListCount: Integer;
      ListIdx: array of Integer;
      ListDataWidth: array of Integer;
      ListDataHeight: array of Integer;
      ListCodeStart: array of Integer;
      ListStr: array of String;
      ListCmdRec: array of CommandRec;
      tmpCmdRec: CommandRec;



      procedure WritePos (s: string);
        var
          i: Integer;
      begin

        if WritingBinFile then
        begin
          if (s <> '') and (s[1] = #0) and (s[Length (s)] = #0) then
          begin
            Delete (s, Length (s), 1);
            Delete (s, 1, 1);
          end;
        end
        else
          for i := 1 to Length (s) do
            if s[i] in [#13, #10] then
              filepos := 0
            else
              Inc (filepos);

        Write (F, s);
      end;





      procedure InitDatVars (Cmd: CmdType);
      begin
        case Cmd of

          ctTile,
          ctTSTile,
          ctTile0,
          ctUTTile:         InitTileVars (Cmd = ctTile0);

          ctTileData:       CurTrans := not InitTileDatVars;

          ctTexTileData:    CurTrans := not InitTexTileDatVars;

          ctMap:            InitMapVars;
          ctMapData:        InitMapDatVars;

          ctPalette:        InitPaletteVars;
          ctPaletteData:    InitPalDatVars;

          ctCorner:         InitCornerVars;
          ctCornerData:     CurTrans := not InitCornerDatVars;

          ctSequence:       InitSeqVars;
          ctSequenceData:   InitSeqDatVars;
          ctSequenceFrame:  InitSeqFrameVars;

          ctHEdge:          InitHEdgeVars;
          ctHEdgeData:      CurTrans := not InitHEdgeDatVars;

          ctVEdge:          InitVEdgeVars;
          ctVEdgeData:      CurTrans := not InitVEdgeDatVars;

          ctTileMap:        InitTileMapVars;

          ctList:           InitListVars (ListStr[ListCount - 1], ListIdx[ListCount - 1], ListCount - 1);

          ctReadTextFile,
          ctReadBinFile:    InitFileDatVars;

        end;
      end;


  begin   { runcode  / (generatecode) }
    CodeError (0, '');
    Error := FALSE;

    SetLength (VarList, 0);

    SetNumVar ('TileSetCount', Tab.Tabs.Count);
    SetNumVar ('TileSetNumber', -1);

    SetStrVar ('ProjectName', ProjectName);

    // new 2.0
    SetStrVar ('OutputDir', OutputPath);
    SetStrVar ('CurrentDate', DateToStr (Date));
    SetStrVar ('CurrentTime', TimeToStr (Time));
    SetStrVar ('TSVersion', VERSION_NUMBER);
    SetNumVar ('PaletteCount', Length (aaiPal));

    SetStrVar ('shl', 'SHL');
    SetStrVar ('shr', 'SHR');
    SetStrVar ('if', 'IF');
    SetStrVar ('then', 'THEN');
    SetStrVar ('else', 'ELSE');
    SetStrVar ('not', 'NOT');
    SetStrVar ('equals', 'EQUALS');
    SetStrVar ('above', 'ABOVE');
    SetStrVar ('below', 'BELOW');


    with Info do
    begin
      SetStrVar ('Author', Author.Text);
      SetStrVar ('Notes', Notes.Text);
      SetStrVar ('Copyright', Copyright.Text);
    end;


    FilePos := 0;
    CurPos := 1;
    Done := FALSE;
    WritingFile := FALSE;
    WritingBinFile := FALSE;
    FirstLine := FALSE;
    WritingMapData := FALSE;
    WritingTileData := FALSE;
    WritingTexTileData := FALSE;
    WritingCornerData := FALSE;
   { WritingTinyTileData := FALSE; }
    WritingSeqData := FALSE;
    WritingSeqFrames := FALSE;
    WritingPalData := FALSE;
    itab := -1;
    TileSetStart := -1;
    imap := -1;
    MapStart := -1;
    idat := -1;
    TileStart := -1;
    TSTileStart := -1;
   { TinyTileStart := -1; }
    TileDatStart := -1;
    TexTileDatStart := -1;
   { TinyTileDatStart := -1; }
    itile := -1;
    itstile := -1;
   { itinytile := -1; }
    MapDatStart := -1;
    iseq := -1;
    SeqStart := -1;
    iseqdat := -1;
    SeqDatStart := -1;
    OutputFileName := '';
    OutputWidth := 256;  // 2.5
    SeqLen := -1;
    ipal := -1;
    PaletteStart := -1;
    ipaldat := -1;
    PalDatStart := -1;

    itilemap := -1;
    icornerdat := -1;
    CornerStart := -1;

    ListCount := 0;  // 3.0

    for tmpi := 0 to MAX_COUNTER do
      Counters[tmpi] := 0;

    ReadingAhead := FALSE;

    ReadingTextFile := FALSE;
    ReadingBinFile := FALSE;
    InputFileName := '';
    InputFilePos := 0;
    ifile := -1;



    StartWithEmptyTile := FALSE;

    SetNumVar ('TRUE', 1);
    SetNumVar ('FALSE', 0);





    CmdList := '';
    for tmpCmd := Low (CmdType) to High (CmdType) do
      with Commands[tmpCmd] do
      begin
        if idx <> nil then
          idx^ := -1;
        CodeStart := -1;
      end;


    s := '';
    repeat
      if s <> #0 then
        s := GetTokenSpecial;
      if s = '' then
        Done := TRUE;
      LastPos := CurPos;
      t := LookAheadToken;
      if (s = #0) and ((t = ';') or (t = '#')) then
      begin
        s := GetTokenSpecial;
        if s = '!' then  // ignore options here
        begin
          s := GetLine;
          s := '';
        end;
        if s = ';' then
        begin
          s := GetLine;
          s := '';
        end;
        if s = '#' then
        begin
          LastPos := CurPos;
          s := UGetToken;

          // commands without #END could be placed here
          //
          // s := '';

          if (s <> '') then
            for iCmd := Low (CmdType) to High (CmdType) do
              if iCmd in SupportedCmds then
              with Commands[icmd] do
                if s = KeyWord then
                begin
                  if CurCmd <> CmdType (-1) then
                    Insert (Chr (Ord (CurCmd)), CmdList, 1);
                  CurCmd := iCmd;

                  sMsg := '';
                  CmdOk := ReqCmd = [];
                  for tmpCmd := Low (CmdType) to High (CmdType) do
                    if tmpCmd in ReqCmd then
                    begin
                      if sMsg <> '' then
                        sMsg := sMsg + ' / ';
                      sMsg := sMsg + Commands[tmpCmd].KeyWord;
                      if (Commands[tmpCmd].idx = nil) or (Commands[tmpCmd].idx^ >= 0) then
                        CmdOk := TRUE;
                    end;
                  if not CmdOk then
                    CodeError (LastPos, 'Only allowed between #' + sMsg + ' and #END ' + sMsg)
                  else
                  begin
                    tmpCmdRec := Commands[CurCmd];

                    sFilename := '';
                    sListName := '';
                    sBegin := '';
                    sSeparator := '';
                    sLongLineSeparator := '';
                    sNextSeparator := '';
                    sEnd := '';
                    sTrans := '';

                    for tmpi := 1 to Length (Parameters) do
                      case Parameters[tmpi] of
                        'F': sFilename := GetFilename;  // GetString;  3.00
                        'P': begin  // list (recursive)
                               sListName := GetString;
                               Inc (ListCount);
                               SetLength (ListIdx, ListCount);
                               SetLength (ListDataWidth, ListCount);
                               SetLength (ListDataHeight, ListCount);
                               SetLength (ListCodeStart, ListCount);
                               SetLength (ListStr, ListCount);
                               SetLength (ListCmdRec, ListCount);
                               ListIdx[ListCount - 1] := -1;
                               idx := @(ListIdx[ListCount - 1]);
                               ListDataWidth[ListCount - 1] := DataWidth;
                               ListDataHeight[ListCount - 1] := DataHeight;
                               ListCodeStart[ListCount - 1] := CodeStart;
                               ListStr[ListCount - 1] := sListName;
                               ListCmdRec[ListCount - 1] := tmpCmdRec;
                             end;
                        'B': sBegin := GetStringOrToken;
                        'S': sSeparator := GetStringOrToken;
                        'L': if not WritingBinFile then
                               sLongLineSeparator := GetString;
                        'N': sNextSeparator := GetStringOrToken;
                        'E': sEnd := GetStringOrToken;
                        'T': sTrans := GetStringOrToken;

                      end;

                    CodeStart := CurPos;
                    idx^ := 0;

                    DataWidth := 0;
                    DataHeight := 1;

                    case CurCmd of

                      ctTile:         if ValidTileSet then
                                        if TinyTiles then
                                          DataWidth := aFinalTinyTileCount[itab][TinyFlip]
                                        else
                                          DataWidth := aFinalTileCount[itab];

                      ctTile0:        if ValidTileSet then
                                        DataWidth := 1;

                      ctTSTile:       if ValidTSTileSet then
                                        DataWidth := TileTab[itab].tbr.TileCount * GetTinyNH * GetTinyNV;

                      ctTileData:     if ValidTileSet then
                                        if TinyTiles then
                                        begin
                                          DataWidth := TinyW;
                                          DataHeight := TinyH;
                                        end
                                        else
                                        begin  // 2.53 - N parameter is now set
                                          DataWidth := TileTab[itab].tbr.W;
                                          DataHeight := TileTab[itab].tbr.H;
                                        end;
                                        //  DataWidth := TileTab[itab].tbr.W * TileTab[itab].tbr.H;

                      ctTexTileData:  begin
                                        DataWidth := TileTab[itab].tbr.W + 2;
                                        DataHeight := TileTab[itab].tbr.H + 2;
                                      end;

                      ctMap:          if ValidTileSet then
                                        with TileTab[itab].tbr do
                                        begin
                                          DataWidth := Length (Maps.aMaps);
                                          while (Maps.aMaps[imap].SkipExport = TRUE) do
                                            Inc (imap);
                                        end;

                      ctMapData:      begin
                                        DataWidth := MapWd;
                                        DataHeight := MapHt;
                                      end;

                      ctCorner:       DataWidth := aCornerCount[itab];

                      ctCornerData:   DataWidth := 4;

                      ctSequence:     if ValidTileSet then
                                        with TileTab[itab].tbr do
                                          DataWidth := GetTinyNH * GetTinyNV *
                                                         Length (Seq.aMaps);

                      ctSequenceData: if ValidTileSet then
                                        DataWidth := SeqLen;

                      ctSequenceFrame: if ValidTileSet then
                                         DataWidth := SeqFrames;

                      ctHEdge:        DataWidth := aHEdgeCount[itab];

                      ctHEdgeData:    begin
                                        DataWidth := TileTab[itab].tbr.W;
                                        DataHeight := 2;
                                      end;

                      ctVEdge:        DataWidth := aVEdgeCount[itab];

                      ctVEdgeData:    begin
                                        DataWidth := 2;
                                        DataHeight := TileTab[itab].tbr.H;
                                      end;

                      ctTileMap:      begin
                                        DataWidth := TinyNH;
                                        DataHeight := TinyNV;
                                      end;

                      ctPalette:      DataWidth := Length (aaiPal);

                      ctPaletteData:  DataWidth := aiPalSize[ipal];  // Length (aaiPal[ipal]);


                      ctUTTile:       if ValidTileSet then
                                        DataWidth := aUTTCount[itab];

                      ctTileBitmap,
                      ctTSTileBitmap: begin
                                        DataWidth := 1;
                                        DataHeight := 1;
                                      end;

                      ctList:         DataWidth := GetListLength (sListName);

                      ctReadTextFile: if sFilename <> '' then
                                      begin
                                        InputFileName := AdjustFilename (sFilename, OutputPath);
                                        if InputFileName <> '' then
                                        begin
                                          DataWidth := GetTextFileLineCount (InputFileName);
                                          AssignFile (TI, InputFileName);
                                          Reset (TI);
                                          ReadingTextFile := TRUE;
                                          InputFilePos := 0;
                                        end;
                                      end;

                      ctReadBinFile:  if sFilename <> '' then
                                      begin
                                        InputFileName := AdjustFilename (sFilename, OutputPath);
                                        if InputFileName <> '' then
                                        begin
                                          DataWidth := GetBinFileSize (InputFileName);
                                          AssignFile (FI, InputFileName);
                                          Reset (FI);
                                          ReadingBinFile := TRUE;
                                          InputFilePos := 0;
                                        end;
                                      end;

                    end;

                    if (idx^ >= DataWidth * DataHeight) or
                       (DataWidth * DataHeight <= 0) then
                    begin
                      FindEnd (s);

                      idx^ := -1;
                      CodeStart := -1;

                      if CurCmd = ctList then
                      begin
                        Dec (ListCount);
                        if ListCount > 0 then
                        begin
                          Commands[CurCmd] := ListCmdRec[ListCount];
                          DataWidth := ListDataWidth[ListCount];
                          DataHeight := ListDataHeight[ListCount];
                          CodeStart := ListCodeStart[ListCount];
                          idx := @(ListIdx[ListCount - 1]);
                        end
                        else
                          idx := nil;
                        SetLength (ListIdx, ListCount);
                        SetLength (ListDataWidth, ListCount);
                        SetLength (ListDataHeight, ListCount);
                        SetLength (ListCodeStart, ListCount);
                        SetLength (ListStr, ListCount);
                        SetLength (ListCmdRec, ListCount);
                      end;

                      if CmdList <> '' then
                      begin
                        CurCmd := CmdType (CmdList[1]);
                        Delete (CmdList, 1, 1);
                      end
                      else
                        CurCmd := CmdType (-1);
                    end
                    else
                      InitDatVars (CurCmd);

                  end;
                  if not (Pos ('X', Commands[CurCmd].Parameters) > 0) then
                  begin
                    s := '';
                    FilePos := 0;
                  end;
                end;


          if s = 'FILE' then
          begin
            if WritingFile or WritingBinFile then
              CodeError (LastPos, 'Already writing a file')
            else
            begin
              OutputFileName := GetFilename;

              if OutputFileName <> '' then
              begin
                if (Pos (':', OutputFileName) = 2) or (OutputFileName[1] = '\') then
                  AssignFile (F, OutputFileName)
                else
                begin
                  CreatePath (OutputPath + OutputFileName);   // 2.54 bug fix
                  AssignFile (F, OutputPath + OutputFileName);
                end;
                ReWrite (F);
                WritingFile := TRUE;
                FirstLine := TRUE;
              end;
            end;
            s := '';
          end;

          if s = 'BINFILE' then
          begin
            if WritingFile or WritingBinFile then
              CodeError (LastPos, 'Already writing a file')
            else
            begin
              OutputFileName := GetFilename;
              if OutputFileName <> '' then
              begin
                if (Pos (':', OutputFileName) = 2) or (OutputFileName[1] = '\') then
                  AssignFile (F, OutputFileName)
                else
                begin
                  CreatePath (OutputPath + OutputFileName);   // 2.54 bug fix
                  AssignFile (F, OutputPath + OutputFileName);
                end;
                ReWrite (F);
                WritingBinFile := TRUE;
               // FirstLine := TRUE;
              end;

              DefaultBinFileBits := 8;
              tmpi := -1;
              s := LookAheadToken;
              while s = ' ' do
              begin
                s := GetToken;
                s := LookAheadToken;
              end;
              if ValidNumber (s) then
              begin
                s := GetToken;
                tmpi := StrToInt (s);
              end;
              if tmpi in [8, 16, 24, 32] then
                DefaultBinFileBits := tmpi
              else
                CodeError (LastPos, 'Allowed values are 8, 16, 24 or 32 bits');

            end;
            s := '';
          end;



  (*
          // 2.0
          if s = 'PALETTE' then
          begin
            fmtPalSep := GetString;
            PaletteStart := CurPos;
            ipal := 0;

            { 2.1 }
            if (ipal >= 0) and (Length (aaiPal) > 0) and
               (PaletteManager.GetID (ipal) <> '') then
              InitPaletteVars
            else
              FindEnd (s);
            s := '';
          end;
          //

          // 2.4
          if s = 'CORNER' then
            if itab = -1 then
              CodeError (LastPos, 'Only allowed between #TILESET and #END TILESET')
            else
            begin
              fmtCornerSep := GetString;
              CornerStart := CurPos;
              icorner := 0;

              if not InitCornerVars then
                FindEnd (s);
              s := '';
            end;
            //
  *)


          // 2.2
          if s = 'TINYTILES' then
            if itab = -1 then
              CodeError (LastPos, 'Only allowed between #TILESET and #END TILESET')
            else
            begin
              tmpi := -1;
              s := LookAheadToken;
              while s = ' ' do
              begin
                s := GetToken;
                s := LookAheadToken;
              end;
              if ValidNumber (s) then
              begin
                s := GetToken;
                tmpi := StrToInt (s);
              end;

              tmpj := -1;
              s := LookAheadToken;
              while s = ' ' do
              begin
                s := GetToken;
                s := LookAheadToken;
              end;
              if ValidNumber (s) then
              begin
                s := GetToken;
                tmpj := StrToInt (s);
              end;

              if (tmpi <= 0) or (tmpj <= 0) then
                CodeError (LastPos, 'Illegal size value(s)')
              else
              begin

                if ValidTileSet then
                  SetupTinyTiles (tmpi, tmpj, NOFLIP)
                else
                begin
                  TinyW := tmpi;
                  TinyH := tmpj;

                end;

                if (TinyW <= 0) or (TinyH <= 0) then
                  FindEnd ('TINYTILES')
                else
                begin
                  with TileTab[itab] do
                  begin
                    TinyNH := tbr.W div TinyW;
                    TinyNV := tbr.H div TinyH;
                  end;

                  TinyTiles := TRUE;

                  InitTileSetVars;

                end;
              end;
              s := '';
            end;


          if s = 'TILESET' then
          begin
            fmtTSSep := GetStringOrToken;       // 2.0
            TileSetStart := CurPos;
            itab := 0;
            ShowProgress (0, 100);  // 2.53
            if GetValidTileSet then
              InitTileSetVars
            else
              FindEnd (s);
            s := '';
          end;


          if s = 'TSTILEBITMAP' then   // 2.5
            if itab = -1 then
              CodeError (LastPos, 'Only allowed between #TILESET and #END TILESET')
            else
            begin
              OutputFileName := GetFilename;
              s := LookAheadToken;
              while s = ' ' do
              begin
                s := GetToken;
                s := LookAheadToken;
              end;
              if ValidNumber (s) then
              begin
                s := GetToken;
                OutputWidth := StrToInt (s);
              end;

              s := '';
            end;


          if s = 'TILEBITMAP' then
            if itab = -1 then
              CodeError (LastPos, 'Only allowed between #TILESET and #END TILESET')
            else
            begin
              OutputFileName := GetFilename;
              s := LookAheadToken;
              while s = ' ' do
              begin
                s := GetToken;
                s := LookAheadToken;
              end;
              if ValidNumber (s) then
              begin
                s := GetToken;
                WidenBitmap (StrToInt (s));
                InitTileSetVars;
              end;

              s := '';
            end;


          if (s = ';') or (s = '#') then
          begin
            if WritingFile then
            begin
              if not FirstLine then
                WriteLn (F);
              FirstLine := FALSE;
              Write (F, s);
            end;
            s := '';
          end;



          if s = 'END' then
          begin
            s := USGetToken;


            // 2.2
            if s = 'TINYTILES' then
            begin
              TinyTiles := FALSE;

              InitTileSetVars;

              TinyW := -1;
              TinyH := -1;
              s := '';
            end;


            if s = 'FILE' then
            begin
              if not WritingFile then
                CodeError (LastPos, 'Misplaced #END statement')
              else
              begin
                CloseFile (F);
                WritingFile := FALSE;
                FirstLine := FALSE;
                OutputFileName := '';
              end;
              s := '';
            end;

            if s = 'BINFILE' then
            begin
              if not WritingBinFile then
                CodeError (LastPos, 'Misplaced #END statement')
              else
              begin
                CloseFile (F);
                WritingBinFile := FALSE;
               // FirstLine := FALSE;
                OutputFileName := '';
              end;
              s := '';
            end;


            if (CurCmd in SupportedCmds) and (s <> '') then
              with Commands[CurCmd] do
              begin
                if (s <> KeyWord) or (idx^ < 0) or (CodeStart < 0) then
                  CodeError (LastPos, 'Misplaced #END statement')
                else
                begin

                  // next ...
                  case CurCmd of
                    ctMap:
                      with TileTab[itab].tbr do
                      begin
                        Inc (imap);

                        while (imap <= Length (Maps.aMaps) - 1) and  // 2.43 bug fix  (last map was always exported)
                              (Maps.aMaps[imap].SkipExport = TRUE) do
                          Inc (imap);

                        if imap < Length (Maps.aMaps) then
                          if WritingFile or WritingBinFile then
                            WritePos (sSeparator);
                      end;

                    else
                      if WritingFile or WritingBinFile then
                      begin
                        if idx^ mod DataWidth = DataWidth - 1 then
                        begin
                          if idx^ = DataWidth * DataHeight - 1 then
                            WritePos (sEnd)
                          else
                            if Pos ('N', Parameters) > 0 then
                              WritePos (sNextSeparator)
                            else
                              WritePos (sSeparator);
                        end
                        else
                          if (FilePos > LONG_LINE) and (Pos ('L', Parameters) > 0) then
                            WritePos (sLongLineSeparator)
                          else
                            WritePos (sSeparator);
                      end;

                    Inc (idx^);

                  end;

                  if not (Pos ('X', Commands[CurCmd].Parameters) > 0) then
                  begin
                    if (idx^ < DataWidth * DataHeight) then
                    begin
                      CurPos := CodeStart;

                      InitDatVars (CurCmd);

                    end
                    else
                    begin
                      idx^ := -1;
                      CodeStart := -1;

                      // finally ...
                      case CurCmd of
                        ctList:
                          begin
                            Dec (ListCount);
                            if ListCount > 0 then
                            begin
                              Commands[CurCmd] := ListCmdRec[ListCount];
                              DataWidth := ListDataWidth[ListCount];
                              DataHeight := ListDataHeight[ListCount];
                              CodeStart := ListCodeStart[ListCount];
                              idx := @(ListIdx[ListCount - 1]);
                            end
                            else
                              idx := nil;
                            SetLength (ListIdx, ListCount);
                            SetLength (ListDataWidth, ListCount);
                            SetLength (ListDataHeight, ListCount);
                            SetLength (ListCodeStart, ListCount);
                            SetLength (ListStr, ListCount);
                            SetLength (ListCmdRec, ListCount);
                          end;

                        ctReadTextFile:
                          begin
                            CloseFile (TI);
                            ReadingTextFile := FALSE;
                            InputFileName := '';
                          end;
                        ctReadBinFile:
                          begin
                            CloseFile (FI);
                            ReadingBinFile := FALSE;
                            InputFileName := '';
                          end;
                           
                      end;

                      if CmdList <> '' then
                      begin
                        CurCmd := CmdType (CmdList[1]);
                        Delete (CmdList, 1, 1);
                      end
                      else
                        CurCmd := CmdType (-1);
                    end;
                  end;

                end;
                if not (Pos ('X', Commands[CurCmd].Parameters) > 0) then
                  s := '';
              end;



            if s = 'TILESET' then
            begin
              if TileSetStart = -1 then
                CodeError (LastPos, 'Misplaced #END statement')
              else
              begin
                Inc (itab);
                ShowProgress (0, 100);  // 2.53
                if GetValidTileSet then
                begin
                  if WritingFile or WritingBinFile then
                    WritePos (fmtTSSep);     // 2.0
                  CurPos := TileSetStart;
                  InitTileSetVars;
                end
                else
                begin
                  itab := -1;
                  SetNumVar ('TileSetNumber', itab);
                  TileSetStart := -1;

                  if (ipal <> -1) and (PaletteStart = -1) then   // 2.0
                    ipal := -1;
                end;
              end;
              s := '';
            end;


            if s = 'TSTILEBITMAP' then   // 2.5
            begin
              if itab = -1 then
                CodeError (LastPos, 'Only allowed between #TILESET and #END TILESET')
              else
                if OutputFileName <> '' then
                  with TileTab[itab] do
                  begin
                    if not ((Pos (':', OutputFileName) = 2) or  // 2.54 bug fix
                            (OutputFileName[1] = '\')) then
                    begin
                      OutputFilename := OutputPath + OutputFileName;
                      CreatePath (OutputFilename);
                    end;

                    if itstile >= 0 then  // 2.54
                    begin
                      idat := 0;
                      DataW := TileTab[itab].tbr.W;
                      DataH := TileTab[itab].tbr.H;
                      bmpCurTile.Width := DataW;
                      bmpCurTile.Height := DataH;
                      while idat < DataW * DataH do
                      begin
                        CurTrans := not InitTileDatVars;
                        if CurTrans then
                          bmpCurTile.Canvas.Pixels[idat mod DataW, idat div DataW] := TRANS_COLOR
                        else
                          bmpCurTile.Canvas.Pixels[idat mod DataW, idat div DataW] := CurRGB;
                        Inc (idat);
                      end;
                      idat := -1;
                      bmpCurTile.PixelFormat := pfOutput;

                      while (OutputFilename <> '') and (OutputFilename[Length (OutputFilename)] in [' ', #0]) do
                        Delete (OutputFilename, Length (OutputFilename), 1);
                      if UpperCase (ExtractFileExt (OutputFilename)) = '.PNG' then
                        WriteBitmapToPngFile ({OutputPath +} OutputFilename, bmpCurTile, TRANS_COLOR)
                      else
                      begin
                        bmpCurTile.SaveToFile ({OutputPath +} OutputFileName);
                     {$IFDEF PATCHBMP}
                        PatchBMPFile ({OutputPath +} OutputFileName);
                     {$ENDIF}
                      end;

                    end
                    else

                      WriteTileBitmap ({OutputPath +} OutputFileName,
                          OutputWidth,
                          TRANS_COLOR,
                          0,  { border color }
                          0, 0, 0, 0,  { border w/h / edge w/h }
                          tbr,
                          ProgressBar,
                          FALSE, { bottom right transparent }
                          FALSE, { store bounds }
                          1  { = pf24bit }
                      );

                    OutputFileName := '';




                    with Commands[CurCmd] do
                    begin
                      idx^ := -1;
                      CodeStart := -1;

                      if CmdList <> '' then
                      begin
                        CurCmd := CmdType (CmdList[1]);
                        Delete (CmdList, 1, 1);
                      end
                      else
                        CurCmd := CmdType (-1);
                    end;



                  end;
                s := '';
            end;


            if s = 'TILEBITMAP' then
            begin
              if itab = -1 then  // 2.5
                CodeError (LastPos, 'Only allowed between #TILESET and #END TILESET')
              else

                if OutputFileName <> '' then
                begin

                  if itile >= 0 then  // 2.54
                  begin
                    idat := 0;
                      DataW := TileTab[itab].tbr.W;
                      DataH := TileTab[itab].tbr.H;
                      bmpCurTile.Width := DataW;
                      bmpCurTile.Height := DataH;
                      while idat < DataW * DataH do
                      begin
                        CurTrans := not InitTileDatVars;
                        if CurTrans then
                          bmpCurTile.Canvas.Pixels[idat mod DataW, idat div DataW] := TRANS_COLOR
                        else
                          bmpCurTile.Canvas.Pixels[idat mod DataW, idat div DataW] := CurRGB;
                        Inc (idat);
                      end;
                    idat := -1;


                    if not ((Pos (':', OutputFileName) = 2) or  // 2.54 bug fix
                            (OutputFileName[1] = '\')) then
                    begin
                      OutputFilename := OutputPath + OutputFileName;
                      CreatePath (OutputFilename);
                    end;


                    bmpCurTile.PixelFormat := pfOutput;
                    while (OutputFilename <> '') and (OutputFilename[Length (OutputFilename)] in [' ', #0]) do
                      Delete (OutputFilename, Length (OutputFilename), 1);
                    if UpperCase (ExtractFileExt (OutputFilename)) = '.PNG' then
                      WriteBitmapToPngFile ({OutputPath +} OutputFilename, bmpCurTile, TRANS_COLOR)
                    else
                    begin
                      bmpCurTile.SaveToFile ({OutputPath +} OutputFileName);
                    {$IFDEF PATCHBMP}
                      PatchBMPFile ({OutputPath +} OutputFileName);
                    {$ENDIF}
                    end;
                  end
                  else
                  begin  { itile = 0, write complete bitmap }

                    if not ((Pos (':', OutputFileName) = 2) or  // 2.55 bug fix
                            (OutputFileName[1] = '\')) then
                    begin
                      OutputFilename := OutputPath + OutputFileName;
                      CreatePath (OutputFilename);
                    end;


                    if bmpFinal[itab].Height > 0 then
                    begin
                      CreatePath ({OutputPath +} OutputFileName);
                      bmpFinal[itab].PixelFormat := pfOutput;
                      while (OutputFilename <> '') and (OutputFilename[Length (OutputFilename)] in [' ', #0]) do
                        Delete (OutputFilename, Length (OutputFilename), 1);
                      if UpperCase (ExtractFileExt (OutputFilename)) = '.PNG' then
                        WriteBitmapToPngFile ({OutputPath +} OutputFilename, bmpFinal[itab], TRANS_COLOR)
                      else
                      begin
                        bmpFinal[itab].SaveToFile ({OutputPath +} OutputFileName);
                      {$IFDEF PATCHBMP}
                        PatchBMPFile ({OutputPath +} OutputFileName);
                      {$ENDIF}
                      end;
                    end;

                  end;
                  OutputFileName := '';


                    with Commands[CurCmd] do
                    begin
                      idx^ := -1;
                      CodeStart := -1;

                      if CmdList <> '' then
                      begin
                        CurCmd := CmdType (CmdList[1]);
                        Delete (CmdList, 1, 1);
                      end
                      else
                        CurCmd := CmdType (-1);
                    end;


                end;
                s := '';
              end;



          end;
        end;
        if s <> '' then
          CodeError (LastPos, 'Syntax error');
        s := '';
      end

{ }

      else
        if CurCmd in SupportedCmds then
          with Commands[CurCmd] do
          begin

            repeat
              if WritingFile or WritingBinFile then
                if s <> #0 then
                begin
                  if idx^ = 0 then
                    WritePos (sBegin);

                  if CurTrans and (sTrans <> '') then
                    WritePos (sTrans)
                  else
                    WritePos (s);

                end
                else
                  if not WritingBinFile then
                    if NewLine then
                    begin
                      if not FirstLine then
                        WritePos (#13#10);
                      FirstLine := FALSE;
                    end;

              s := GetTokenSpecial;
              t := LookAheadToken;
              while (s <> #0) and (t <> #0) and (t <> '') do
              begin
                if WritingBinFile then
                begin
                  WritePos (s);
                  s := '';
                end;
                s := s + GetTokenSpecial;
                t := LookAheadToken;
              end;
            until (s = #0) or (s = '') or Done or Error;

          end

{ }

      else
        if WritingSeqData or WritingSeqFrames or WritingPalData then
        begin
          repeat
            if WritingFile or WritingBinFile then
              if s <> #0 then
              begin
                if (WritingSeqData and (iseqdat = 0)) or
                   (WritingSeqFrames and (iseqdat = 0)) or
                   (WritingPalData and (ipaldat = 0)) then
                  WritePos (fmtStart);
                WritePos (s);
                if (WritingSeqData and (iseqdat = SeqLen - 1)) or
                   (WritingSeqFrames and (iseqdat = SeqFrames - 1)) or
                   (WritingPalData and (ipaldat = { Length (aaiPal[ipal]) } aiPalSize[ipal] - 1)) then  // 2.41
                  WritePos (fmtEnd)
                else
                  WritePos (fmtSep);
              end;
            s := GetTokenSpecial;
            t := LookAheadToken;
            while (s <> #0) and (t <> #0) and (t <> '') do
            begin
              s := s + GetTokenSpecial;
              t := LookAheadToken;
            end;
          until (s = #0) or (s = '') or Done or Error;
        end
        else
          if WritingMapData
          or WritingTileData
          or WritingTexTileData
          or WritingCornerData
            { or WritingTinyTileData } then
          begin
            itmpdat := idat;
            if WritingMapData then
            begin
              tmpW := MapWd;
              tmpH := MapHt;
            end;
            if WritingTileData then
              if TinyTiles then
              begin
                tmpW := TinyW;
                tmpH := TinyH;
              end
              else
              begin
                tmpW := TileTab[itab].tbr.W;
                tmpH := TileTab[itab].tbr.H;
              end;
            if WritingTexTileData then
            begin
              tmpW := TileTab[itab].tbr.W + 2;
              tmpH := TileTab[itab].tbr.H + 2;
            end;
            if WritingCornerData then
            begin
              tmpW := 4;
              tmpH := 1;
              itmpdat := icornerdat;
            end;

            repeat
              if WritingFile or WritingBinFile then
                if s <> #0 then
                begin
                  if itmpdat = 0 then
                    WritePos (fmtStart);

                  if WritingTileData or WritingTexTileData or WritingCornerData then
                  begin
                    if TransReplace = '' then
                      WritePos (s)
                    else
                      if TransReplace <> #0 then
                      begin
                        WritePos (TransReplace);
                        TransReplace := #0;
                      end;
                  end
                  else
                    WritePos (s);

                  if itmpdat mod tmpW = tmpW - 1 then
                    if itmpdat = tmpW * tmpH - 1 then
                      WritePos (fmtEnd)
                    else
                      WritePos (fmtSepLine)
                  else
                    if FilePos > LONG_LINE then
                      WritePos (fmtSepOutputLine)
                    else
                      WritePos (fmtSep);

                end;

              s := GetTokenSpecial;
              t := LookAheadToken;
              while (s <> #0) and (t <> #0) and (t <> '') do
              begin
                s := s + GetTokenSpecial;
                t := LookAheadToken;
              end;
            until (s = #0) or (s = '') or Done or Error;
          end
          else
          begin

            repeat
              if WritingFile then
              begin
                if s = #0 then
                begin
                  if not FirstLine then
                    WriteLn (F);
                end
                else
                  Write (F, s);
                FirstLine := FALSE;
              end;

              if WritingBinFile then
                if s <> #0 then
                  WritePos (s);

              s := GetTokenSpecial;
            until (s = #0) or (s = '') or Done or Error;

          end;

    until Done or Error;


    if WritingFile or WritingBinFile then
      CloseFile (F);

   // for itab := 0 to Tab.Tabs.Count - 1 do

    if not Error then
      ErrorMsg := '';

    SetLength (VarList, 0);


    RunCode := ErrorMsg;
  end;


  procedure ReadCodeOptions (lines: TStrings);
    var
      i: Integer;
      s: string;
  begin

    for i := 0 to lines.Count - 1 do
    begin
      s := UpCaseStr (Trim(lines.Strings[i]));
      if (s <> '') then
      begin
        if (s[1] = '!') then
        begin
          Delete (s, 1, 1);



          if (s = 'STARTWITHEMPTYTILE') then
            StartWithEmptyTile := TRUE;


        end;
      end;
    end;

  end;



{ TMainForm.Generate1Click }

  var
    i, j, k: Integer;
    x, y: Integer;
    mcr: MapCellRec;
    m, u, r: Boolean;
    found, diff: Boolean;
    N: Integer;
    rr, gg, bb: Integer;
    tr, tg, tb, ta: Integer;
    ii, jj, kk: Integer;
    ErrMsg: string;
    corner: Integer;

begin
  if CodeGen.LastDef = '' then
  begin
    MessageDlg ('Please select a code generation definition first.',
        mtInformation, [mbOk], 0);
    Exit;
  end;

  CodeGen.ProjectDir := FilePath (FileName);  // 2.5
  code := CodeGen.GetCodeString;


  if code = '' then
  begin
    MessageDlg ('Cannot read code generation definition file (' +
        CodeGen.LastDef + ').', mtError, [mbOk], 0);
    Exit;
  end;


  ReadCodeOptions (CodeGen.Memo.Lines);


  {
    ShowBackLayer.Checked := TRUE;
    ShowMidLayer.Checked := TRUE;
    ShowFrontLayer.Checked := TRUE;
  }

  ProgressPanel.Visible := TRUE;
  with ProgressBar do
  begin
    Min := 0;
    Max := 100 * Tab.Tabs.Count;
    Position := 0;
  end;


  if aaN < 2 then
    aaN := 1;
  aa := (aaN >= 2);
  aaX := aaN;
  aaY := aaN;



  SetLength (aMCR, Tab.Tabs.Count);
  SetLength (aFinalRef, Tab.Tabs.Count);
  SetLength (bmpFinal, Tab.Tabs.Count);
  SetLength (bmpAlpha, Tab.Tabs.Count);
  SetLength (aFinalTileCount, Tab.Tabs.Count);
  SetLength (TransX, Tab.Tabs.Count);
  SetLength (TransY, Tab.Tabs.Count);

  SetLength (aFinalTinyTileCount, Tab.Tabs.Count);
  SetLength (aFinalTinyTiles, Tab.Tabs.Count);
  SetLength (aFinalTinyRef, Tab.Tabs.Count);
  TinyW := -1;
  TinyH := -1;
  TinyFlip := NOFLIP;
  TinyTiles := FALSE;

  // 2.4
  TexTiles := { (Pos (#0'#TEXTILEBITMAP', UpCaseStr (code)) > 0) or }
              (Pos (#0'#TEXTILEDATA', UpCaseStr (code)) > 0) or
              (Pos (#0'#CORNER', UpCaseStr (code)) > 0) or
              (Pos (#0'#HEDGE', UpCaseStr (code)) > 0) or
              (Pos (#0'#VEDGE', UpCaseStr (code)) > 0);
  // 2.5
  UTT := TexTiles and (Pos (#0'#UNIQUETEXTILE', UpCaseStr (code)) > 0);


  SetLength (aTransTile, Tab.Tabs.Count);

  if TexTiles then
  begin
    SetLength (bmpTexTiles, Tab.Tabs.Count);
    SetLength (bmpTexAlpha, Tab.Tabs.Count);
    SetLength (aMCRSur, Tab.Tabs.Count);
    SetLength (aSameAs, Tab.Tabs.Count);
    SetLength (aTrans, Tab.Tabs.Count);
    SetLength (Corners, Tab.Tabs.Count);
    SetLength (HEdges, Tab.Tabs.Count);
    SetLength (VEdges, Tab.Tabs.Count);
    SetLength (aCornerCount, Tab.Tabs.Count);
    SetLength (aHEdgeCount, Tab.Tabs.Count);
    SetLength (aVEdgeCount, Tab.Tabs.Count);

    if UTT then
    begin
      SetLength (aUTTRef, Tab.Tabs.Count);
      SetLength (aUTTIndex, tab.Tabs.Count);
      SetLength (aUTTCount, Tab.Tabs.Count);
    end;
  end;




  for itab := 0 to Tab.Tabs.Count - 1 do
    with TileTab[itab].tbr do
    begin
      LastW := W;
      LastH := H;
    end;


  bmpCurTile := TBitmap.Create;
  SetStretchBltMode(bmpCurTile.Canvas.Handle, HALFTONE);
  bmpCurTile.PixelFormat := pf24bit;
  bmpCurTile.Canvas.Brush.Color := TRANS_COLOR;

  for itab := 0 to Tab.Tabs.Count - 1 do
  begin
    ShowProgress (0, 100);

    with TileTab[itab] do
    begin

      bmp1.Width := tbr.W;
      bmp1.Height := tbr.H;
      ResizeBitmap (bmp1);

      bmp2.Width := tbr.W;
      bmp2.Height := tbr.H;
      ResizeBitmap (bmp2);

      bmpFinal[itab] := TBitmap.Create;
      SetStretchBltMode(bmpFinal[itab].Canvas.Handle, HALFTONE);
      bmpFinal[itab].PixelFormat := pf24bit;
      bmpFinal[itab].Width := tbr.W;
      bmpFinal[itab].Canvas.Brush.Color := TRANS_COLOR;

      SetLength (aMCR[itab], 0);
      N := 0;

      // 2.4
      if TexTiles then
      begin
        bmpTexTiles[itab] := TBitmap.Create;
        SetStretchBltMode(bmpTexTiles[itab].Canvas.Handle, HALFTONE);
        bmpTexTiles[itab].PixelFormat := pf24bit;
        bmpTexTiles[itab].Width := tbr.W + 2;
        bmpTexTiles[itab].Canvas.Brush.Color := TRANS_COLOR;
      end;

      // make a collection of all unique MCR's

      with mcr do
      begin
        Back := -1;
        Mid := -1;
        Front := -1;
      end;
      AddMCR (mcr);

      with tbr.Maps do
        for i := 0 to Length (aMaps) - 1 do
          AddMCRs (aMaps[i].map);

      with tbr.Seq do
        for i := 0 to Length (aMaps) - 1 do
          AddMCRs (aMaps[i].map);

      SetLength (aFinalRef[itab], Length (aMCR[itab]));


      // create tile bitmap with unique tiles

      for i := 0 to Length (aMCR[itab]) - 1 do
      begin
        mcr := aMCR[itab][i];
        FillBitmap (bmp2, TRANS_COLOR);

        with mcr do
        begin
          if mcr.Back <> -1 then
            DrawTile (itab, mcr.Back, bmp1, m, u, r, bmp2);
          if mcr.Mid <> -1 then
            DrawTile (itab, mcr.Mid, bmp1, m, u, r, bmp2);
          if mcr.Front <> -1 then
            DrawTile (itab, mcr.Front, bmp1, m, u, r, bmp2);
        end;

        found := FALSE;
        for j := 0 to N - 1 do
          if not found then
          begin
            diff := FALSE;
            for y := 0 to tbr.H - 1 do
              if not diff then
                for x := 0 to tbr.W - 1 do
                  if not diff then
                    if bmp2.Canvas.Pixels[x, y] <>
                       bmpFinal[itab].Canvas.Pixels[x, y + j * tbr.H] then
                      diff := TRUE;
            if not diff then
            begin
              aFinalRef[itab][i] := j;
              found := TRUE;
            end;
          end;

{$IFNDEF PATCHBMP}
        { work around for SaveToFile BMP header error with pf24bit }
        bmpFinal[itab].PixelFormat := pfFinal;
{$ENDIF}

        if not found then
        begin
          Inc (N);

          bmpFinal[itab].Height := N * tbr.H;
          with tbr do
            bmpFinal[itab].Canvas.CopyRect
                    (MakeRect (0, (N - 1) * H, W, H),
                     bmp2.Picture.Bitmap.Canvas,
                     Rect (0, 0, W, H));
          aFinalRef[itab][i] := N - 1;
        end;
      end;


      // scale down bmpFinal bitmap for anti-aliasing
      if aa then
      begin
        bmpAlpha[itab] := TBitmap.Create;
        bmpAlpha[itab].PixelFormat := pf8bit;
        bmpAlpha[itab].Width := tbr.W div aaX;
        bmpAlpha[itab].Height := N * tbr.H div aaY;

        with tbr, bmpFinal[itab] do
        begin
          for k := 0 to N - 1 do
            for j := 0 to (H {+ aaY - 1}) div aaY - 1 do
              for i := 0 to (W {+ aaX - 1}) div aaX - 1 do
              begin
                tr := 0;  tg := 0;  tb := 0;  ta := 0;

                kk := 0;
                for jj := 0 to aaY - 1 do
                  for ii := 0 to aaX - 1 do
                    if (j * aaY + jj < H) and (i * aaX + ii < W) then
                    begin
                      GetRGB (Canvas.Pixels[i * aaX + ii, k * H + j * aaY + jj], rr, gg, bb);
                      if RGB (rr, gg, bb) <> TRANS_COLOR then
                      begin
                        tr := tr + rr;
                        tg := tg + gg;
                        tb := tb + bb;
                        ta := ta + 255;
                        Inc (kk);
                      end;
                    end;


                if ta = 0 then
                  Canvas.Pixels[i, j + k * ((H {+ aaY - 1}) div aaY)] := TRANS_COLOR
                else
                  Canvas.Pixels[i, j + k * ((H {+ aaY - 1}) div aaY)] :=
                     RGB (tr div kk, tg div kk, tb div kk);

                bmpAlpha[itab].Canvas.Pixels[i, j + k * ((H {+ aaY - 1}) div aaY)] :=
                     ta div (aaX * aaY);
              end;

          W := (W {+ aaX - 1}) div aaX;
          H := (H {+ aaY - 1}) div aaY;

          Width := Width div aaX;
          Height := Height div aaY;
        end;
      end;


      // find a transparent pixel, or add transparent tile to the end
      TransX[itab] := -1;
      TransY[itab] := -1;

      with tbr, bmpFinal[itab] do
        if Height > 0 then
        begin
          if StartWithEmptyTile then
          begin
            TransX[itab] := 0;
            TransY[itab] := 0;
          end
          else
          begin
            for i := 1 to N - 1 do
            begin
              Canvas.CopyRect (MakeRect (0, (i - 1) * H, W, H),
                  Canvas, MakeRect (0, i * H, W, H));
              if aa then
                with bmpAlpha[itab] do
                  Canvas.CopyRect (MakeRect (0, (i - 1) * H, W, H),
                      Canvas, MakeRect (0, i * H, W, H));
            end;
            for j := 0 to Height - 1 do
              for i := 0 to W - 1 do
                if Canvas.Pixels[i, j] = TRANS_COLOR then
                begin
                  TransX[itab] := i;
                  TransY[itab] := j;
                end;
            if TransX[itab] <> -1 then
            begin
              aTransTile[itab] := 0;
              Height := Height - H;
            end
            else
            begin
              for j := 0 to H - 1 do
                for i := 0 to W - 1 do
                  Canvas.Pixels[i, Height - 1 - j] := TRANS_COLOR;
              aTransTile[itab] := 1;
            end;
          end;


         // aFinalTileCount[itab] := N;
          aFinalTileCount[itab] := bmpFinal[itab].Height div H;  // 2.34

          // 2.4
          if TexTiles then
          begin
            i := aFinalTileCount[itab];
            bmpTexTiles[itab].Width := W + 2;
            bmpTexTiles[itab].Height := i * (H + 2);
            for j := 0 to i - 1 do
              bmpTexTiles[itab].Canvas.CopyRect (MakeRect (1, j * (H + 2) + 1, W, H),
                   Canvas, MakeRect (0, j * H, W, H));

            if aa then
            begin
              bmpTexAlpha[itab] := TBitmap.Create;
              bmpTexAlpha[itab].PixelFormat := pf8bit;
              bmpTexAlpha[itab].Width := W + 2;
              bmpTexAlpha[itab].Height := i * (H + 2);
              with bmpAlpha[itab] do
                for j := 0 to i - 1 do
                  bmpTexAlpha[itab].Canvas.CopyRect (MakeRect (1, j * (H + 2) + 1, W, H),
                       Canvas, MakeRect (0, j * H, W, H));
            end;

          end;
        end;


        if TexTiles then
        begin

          SetLength (aMCRSur[itab], Length (aFinalRef[itab]));
          SetLength (aSameAs[itab], Length (aFinalRef[itab]));
          SetLength (aTrans[itab], Length (aFinalRef[itab]));
          SetLength (Corners[itab], 0);
          SetLength (HEdges[itab], 0);
          SetLength (VEdges[itab], 0);

          if UTT then
          begin
            SetLength (aUTTRef[itab], Length (aFinalRef[itab]));
            SetLength (aUTTIndex[itab], Length (aFinalRef[itab]));
          end;

          {  ... edges and corners ...  }

          SetEdgeRects (tbr.W, tbr.H);

          with tbr.Maps do
            for i := 0 to Length (aMaps) - 1 do
              CreateEdgeData (aMaps[i].map, tbr.Seq);

          FindSameEdges;
          GetEdgeColors;

          for j := 0 to Length (aMCRSur[itab]) - 1 do
          begin
            for i := 0 to 7 do
              if EdgeToCorner[i] = -1 then
              begin

                k := GetMostSurTile (itab, j, i);


                if k > -1 then
                  with tbr do
                    bmpTexTiles[itab].Canvas.CopyRect
                       (AddRect (EdgeDst[i], MakeRect (0, (j - 1) * (H + 2), 0, 0)),
                        bmpTexTiles[itab].Canvas,
                        AddRect (EdgeSrc[i], MakeRect (0, (k - 1) * (H + 2), 0, 0)));

              end;

            for i := 0 to 7 do
              if EdgeToCorner[i] <> -1 then
              begin
                corner := 3 - EdgeToCorner[i];
                x := TileCornerX[corner];
                y := TileCornerY[corner] + (j - 1) * (H + 2);
                with bmpTexTiles[itab].Canvas do
                begin
                  TmpCorner[0] := Pixels[x, y];
                  TmpCorner[1] := Pixels[x + 1, y];
                  TmpCorner[2] := Pixels[x, y + 1];
                  TmpCorner[3] := Pixels[x + 1, y + 1];
                end;
                TmpCorner[corner] := -1;

                k := GetBestCorner (j, EdgeToCorner[i], TmpCorner);

                if k <> -1 then
                begin
                  TmpCorner[corner] := Corners[itab][k].Colors[corner];
                  with tbr do
                    bmpTexTiles[itab].Canvas.Pixels[EdgeDst[i].Left,
                                (j - 1) * (H + 2) + EdgeDst[i].Top] :=
                                      TmpCorner[corner];
                end;

                CreateCornerData (j, i, k, TmpCorner);

              end;
          end;

          aCornerCount[itab] := NumberCornerData;
          SortMCRSur;

          CreateHVEdgeData;



          // 2.5 - uniquetextiles
          if UTT then
          begin
            aUTTCount[itab] := aFinalTileCount[itab];

            for i := 0 to aUTTCount[itab] - 1 do
              aUTTIndex[itab][i] := i + 1;

            with tbr.Maps do
              for i := 0 to Length (aMaps) - 1 do
                CreateUTTData (aMaps[i].map, tbr.Seq);
          end;





       //   asm nop end;

        end;


    {
      bmpFinal[itab].PixelFormat := pf24bit;
      if N > 0 then
        bmpFinal[itab].SaveToFile ('test' + IntToStr (itab) + '.bmp');
      if TexTiles then
        if N > 0 then
          bmpTexTiles[itab].SaveToFile ('tex' + IntToStr (itab) + '.bmp');
    }

     //// bmpFinal[itab].SaveToFile('bmpfinal' + chr(ord('1')+itab) + '.bmp');


    end;
  end;


  // generate the code

  ErrMsg := RunCode;


  for itab := 0 to Tab.Tabs.Count - 1 do
    with TileTab[itab].tbr do
    begin
      W := LastW;
      H := LastH;
    end;


  if ErrMsg <> '' then
    ShowMessage (ErrMsg)
  else
  begin
    with ProgressBar do
      Position := Max;
    ShowMessage ('Code generated successfully');
  end;


  // clean up and release memory

  SetLength (aFinalTinyTileCount, 0);
  SetLength (aFinalTileCount, 0);

  for itab := 0 to Tab.Tabs.Count - 1 do
  begin
    SetLength (aFinalTinyTiles[itab][NOFLIP], 0);
    SetLength (aFinalTinyTiles[itab][HFLIP], 0);
    SetLength (aFinalTinyTiles[itab][VFLIP], 0);
    SetLength (aFinalTinyTiles[itab][HVFLIP], 0);

    SetLength (aFinalTinyRef[itab], 0);
    SetLength (aMCR[itab], 0);
    SetLength (aFinalRef[itab], 0);
    bmpFinal[itab].Free;
    if aa then
      bmpAlpha[itab].Free;

    // 2.4
    if TexTiles then
    begin
      if UTT then
        SetLength (aUTTRef[itab], 0);

      SetLength (Corners[itab], 0);
      SetLength (HEdges[itab], 0);
      SetLength (VEdges[itab], 0);
      bmpTexTiles[itab].Free;
      if aa then
        bmpTexAlpha[itab].Free;
    end;
  end;

  bmpCurTile.Free;  // 2.54


  SetLength (aTransTile, 0);

  if TexTiles then
  begin
    if UTT then
    begin
      SetLength (aUTTRef, 0);
      SetLength (aUTTIndex, 0);
      SetLength (aUTTCount, 0);
    end;

    SetLength (aCornerCount, 0);
    SetLength (aHEdgeCount, 0);
    SetLength (aVEdgeCount, 0);
    SetLength (Corners, 0);
    SetLength (HEdges, 0);
    SetLength (VEdges, 0);
    SetLength (aTrans, 0);
    SetLength (aSameAs, 0);
    SetLength (aMCRSur, 0);
    SetLength (bmpTexTiles, 0);
    SetLength (bmpTexAlpha, 0);
  end;

  SetLength (aFinalTinyTiles, 0);
  SetLength (aFinalTinyRef, 0);
  SetLength (aFinalRef, 0);
  SetLength (aMCR, 0 );

  SetLength (bmpFinal, 0);
  SetLength (bmpAlpha, 0);

  SetLength (TransX, 0);
  SetLength (TransY, 0);

  bmp2.Width := W;
  bmp2.Height := H;
  ResizeBitmap (bmp2);
  bmp1.Width := W;
  bmp1.Height := H;
  ResizeBitmap (bmp1);

  ProgressPanel.Visible := FALSE;
  Modified := TRUE;

end;

procedure TMainForm.CodeGenerationSettings1Click(Sender: TObject);
  var
    s: string;
begin
  s := CodeGen.LastDef;
  CodeGen.ProjectDir := FilePath (FileName);
  CodeGen.ShowModal;
  if CodeGen.LastDef <> s then
    Modified := TRUE;
end;


procedure TMainForm.SelectOutputDirectory1Click(Sender: TObject);
  var
    f, s: string;
    rel: Boolean;
begin

  f := FileName;
  if f <> '' then
    while (Pos ('\', f) > 0) and (f[Length (f)] <> '\') do
      Delete (f, Length (f), 1);

  s := OutputPath;
  if (s <> '') and (s[Length (s)] = '\') then
    Delete (s, Length (s), 1);
  Rel := True;
  if s <> '' then
  begin
    s := s + '\';
    if s[1] = '\' then
      Rel := FALSE;
    if (Length (s) >= 3) and (s[2] = ':') then
      Rel := FALSE;
  end;
  if Rel then
    if f <> '' then
      s := f + s;

  try
    OutputDir.DirectoryListBox.Directory := s;
  except
    OutputPath := '';
    OutputDir.DirectoryListBox.Directory := '';
  end;

  OutputDir.ShowModal;
  if OutputDir.Result then
  begin
    s := OutputDir.DirectoryListBox.Directory;

    if Copy (s, 1, Length (f)) = f then
      Delete (s, 1, Length (f));

    OutputPath := s;
    if OutputPath <> '' then
      if OutputPath[Length (OutputPath)] <> '\' then
        OutputPath := OutputPath + '\';
    Modified := TRUE;

    SelectOutputDirectory1.Checked := TRUE;
    OutputtoProjectDirectory1.Checked := FALSE;
  end;
end;

procedure TMainForm.ReplaceColors1Click(Sender: TObject);
  var
    i, j, k, l, m, n, o: Integer;
    r, g, b, rr, gg, bb, r1, g1, b1, r2, g2, b2: Integer;
    c: Integer;

  function verh (m1, m2, m, n1, n2: Integer): Integer;
  begin
    if m1 = m2 then
      verh := n1
    else
      verh := n1 + (n2 - n1) * (m - m1) div (m2 - m1);
  end;

begin
  GetTileArea;

  // 2.54 - update: use current color pattern
  if SplitColorPattern1.Checked then
    with Bmp.Canvas do
    begin
      SaveUndo ('Replace Colors');
      for i := 0 to TileAreaW - 1 do
        for j := 0 to TileAreaH - 1 do
        begin
          c := Pixels[TileAreaX + i, TileAreaY + j];
          if c <> TRANS_COLOR then
          begin

            for k := FromToFirst to FromToLast do
              if c = OtherFromTo.FT[k] then
                c := FromToList[k];
            for k := FromToLast downto FromToFirst do
              if c = OtherFromTo.FT[k] then
                c := FromToList[k];

            c := ColorMatch (c);

            for k := FromToFirst to FromToLast do
              if c = OtherFromTo.FT[k] then
                c := FromToList[k];
            for k := FromToLast downto FromToFirst do
              if c = OtherFromTo.FT[k] then
                c := FromToList[k];

            Pixels[TileAreaX + i, TileAreaY + j] := c;
          end;
        end;

      AddColorPattern1Click(Sender);
      UpdateBmp (TRUE);
      Modified := TRUE;
      Exit;
    end;

  m := -1;
  n := 0;
  for i := 0 to TileAreaW - 1 do
    for j := 0 to TileAreaH - 1 do
      with Bmp.Canvas do
      begin
        o := 0;
        c := Pixels[TileAreaX + i, TileAreaY + j];
        if c <> TRANS_COLOR then
        begin
          c := ColorMatch (c);
          for k := 0 to Length (FromToSave) - 1 do
            for l := 0 to MAX_FROM_TO - 1 do
              if c = FromToSave[k].FT[l] then
              begin
                Inc (o);
                if o > n then
                begin
                  m := k;
                  n := o;
                end;
              end;
        end;
      end;
  if m < 0 then
    Exit;
  SaveUndo ('Replace Colors');
  for i := 0 to TileAreaW - 1 do
    for j := 0 to TileAreaH - 1 do
      with Bmp.Canvas do
      begin
       // o := 0;
        c := Pixels[TileAreaX + i, TileAreaY + j];
        if c <> TRANS_COLOR then
        begin
          {
          c := ColorMatch (c);
          for l := 0 to MAX_FROM_TO - 1 do
            if c = FromToSave[m].FT[l] then
            begin
              Pixels[BORDER_W + i, BORDER_H + j] := FromToList[l];
              Inc (o);
            end;
          if o = 0 then  }
          begin
            GetRGB (c, R, G, B);

            r1 := 0;
            g1 := 0;
            b1 := 0;
            for l := 0 to MAX_FROM_TO - 1 do
            begin
              GetRGB (FromToSave[m].FT[l], rr, gg, bb);
              if rr <= r then
                r1 := l;
              if gg <= g then
                g1 := l;
              if bb <= b then
                b1 := l;
            end;

            r2 := MAX_FROM_TO - 1;
            g2 := MAX_FROM_TO - 1;
            b2 := MAX_FROM_TO - 1;
            for l := MAX_FROM_TO - 1 downto 0 do
            begin
              GetRGB (FromToSave[m].FT[l], rr, gg, bb);
              if rr >= r then
                r2 := l;
              if gg >= g then
                g2 := l;
              if bb >= b then
                b2 := l;
            end;

            r := verh (FromToSave[m].EXFT[r1, 0],
                       FromToSave[m].EXFT[r2, 0],
                       r,
                       ExFromToList[r1, 0],
                       ExFromToList[r2, 0]);
            g := verh (FromToSave[m].EXFT[g1, 1],
                       FromToSave[m].EXFT[g2, 1],
                       g,
                       ExFromToList[g1, 1],
                       ExFromToList[g2, 1]);
            b := verh (FromToSave[m].EXFT[b1, 2],
                       FromToSave[m].EXFT[b2, 2],
                       b,
                       ExFromToList[b1, 2],
                       ExFromToList[b2, 2]);
            r := LimitRGB (r);
            g := LimitRGB (g);
            b := LimitRGB (b);

            r := ColorMatch (r);
            g := ColorMatch (g);
            b := ColorMatch (b);

            Pixels[TileAreaX + i, TileAreaY + j] := ColorMatch (RGB (r, g, b));
          end;
        end;
      end;

  AddColorPattern1Click(Sender);
  UpdateBmp (TRUE);
  Modified := TRUE;
end;

procedure TMainForm.MapScrollFunction1Click(Sender: TObject);
begin
  if MapTab.TabIndex > -1 then
    with TileTab[Tab.TabIndex].tbr.Maps do
    begin
      with aMaps[CurMap] do
      begin
        if fx = '' then
          MapScroll.X.Text := 'x'
        else
          MapScroll.X.Text := fx;
        if fy = '' then
          MapScroll.Y.Text := 'y'
        else
          MapScroll.Y.Text := fy;
      end;
      MapScroll.ShowModal;
      if MapScroll.Result then
      begin
        aMaps[CurMap].fx := MapScroll.X.Text;
        aMaps[CurMap].fy := MapScroll.Y.Text;
        Modified := TRUE;
      end;
    end;
end;

function BlackWhite (rgb: Integer): Integer;
  var
    R, G, B: Integer;
begin
  GetRGB (rgb, R, G, B);
  if R + G + B >= 3 * 128 then
    BlackWhite := clWhite
  else
    BlackWhite := clBlack;
end;

procedure TMainForm.SaveCurrentTile1Click(Sender: TObject);
  var
    bmpTemp: TBitmap;
    i, j, c: Integer;
   { Mono: Boolean; }
begin
  SavePictureDialog.DefaultExt := GraphicExtension(TBitmap);
  if SavePictureDialog.Execute then
  begin
    bmpTemp := TBitmap.Create;
    SetStretchBltMode(bmpTemp.Canvas.Handle, HALFTONE);
//    bmpTemp.PixelFormat := pf16bit;
//    bmpTemp.Canvas.CopyRect (Rect (0, 0, W, H),
//        bmp.Canvas, MakeRect (BORDER_W, BORDER_H, W, H));
   { Mono := FALSE; }
    case SavePictureDialog.FilterIndex of
      1: bmpTemp.PixelFormat := pf24bit;
      2: bmpTemp.PixelFormat := pf16bit;
      3: bmpTemp.PixelFormat := pf15bit;
      4: bmpTemp.PixelFormat := pf8bit;
      5: bmpTemp.PixelFormat := pf4bit;
      6: begin
           bmpTemp.PixelFormat := pf1bit;
        {   Mono := TRUE; }
         end;
      7: bmpTemp.PixelFormat := pf24bit;  // PNG
    end;
    bmpTemp.Width := W;
    bmpTemp.Height := H;
    for j := 0 to H - 1 do
      for i := 0 to W - 1 do
      begin
        c := bmp.Canvas.Pixels[i + BORDER_W, j + BORDER_H];
      {
        if Mono then
          bmpTemp.Canvas.Pixels[i, j] := BlackWhite (c)
        else
      }
          bmpTemp.Canvas.Pixels[i, j] := c;
      end;
    if UpperCase (ExtractFileExt (SavePictureDialog.Filename)) = '.PNG' then
    begin
      bmpTemp.TransparentColor := TRANS_COLOR;
      WriteBitmapToPngFile (SavePictureDialog.Filename, bmpTemp, TRANS_COLOR);
    end
    else
      bmpTemp.SaveToFile (SavePictureDialog.FileName);
    bmpTemp.Free;
  end;
end;

{$IFNDEF IMPORTEDLEV}
procedure TMainForm.ImportEdlevClick(Sender: TObject);
begin
  ShowMessage ('Not implemented in this version.');
end;
{$ELSE}
procedure TMainForm.ImportEdlevClick(Sender: TObject);
  var
    i: Integer;
    dir: string;
begin
{
  SetEditorMode (mTile);
  ImportLevelTiles ('c:\ch2\', 'W1', 20, 14);
  SetEditorMode (mMap);
  ImportLevelMap   ('c:\ch2\', 'TITLE', 'Title');

  ImportLevelMap   ('c:\ch2\', 'P1', 'T1');
  ImportLevelMap   ('c:\ch2\', 'P1B', 'T1B');

  ImportLevelMap   ('c:\ch2\', 'L1', 'L1');
  ImportLevelMap   ('c:\ch2\', 'L1B', 'L1B');
  ImportLevelMap   ('c:\ch2\', 'L2', 'L2');
  ImportLevelMap   ('c:\ch2\', 'L3', 'L3');
  ImportLevelMap   ('c:\ch2\', 'L3B', 'L3B');
  ImportLevelMap   ('c:\ch2\', 'L4', 'L4');

  SetEditorMode (mTile);
  ImportLevelTiles ('c:\ch2\', 'W2', 20, 14);
  SetEditorMode (mMap);
  ImportLevelMap   ('c:\ch2\', 'L5', 'L5');
  ImportLevelMap   ('c:\ch2\', 'L5B', 'L5B');
  ImportLevelMap   ('c:\ch2\', 'L6', 'L6');
  ImportLevelMap   ('c:\ch2\', 'L7', 'L7');
  ImportLevelMap   ('c:\ch2\', 'L7B', 'L7B');
  ImportLevelMap   ('c:\ch2\', 'L8', 'L8');

  SetEditorMode (mTile);
  ImportLevelTiles ('c:\ch2\', 'W3', 20, 14);
  SetEditorMode (mMap);
  ImportLevelMap   ('c:\ch2\', 'L9', 'L9');
  ImportLevelMap   ('c:\ch2\', 'L9B', 'L9B');
  ImportLevelMap   ('c:\ch2\', 'LA', 'LA');
  ImportLevelMap   ('c:\ch2\', 'LB', 'LB');
  ImportLevelMap   ('c:\ch2\', 'LBB', 'LBB');
  ImportLevelMap   ('c:\ch2\', 'LC', 'LC');

  SetEditorMode (mTile);
  ImportLevelTiles ('c:\ch2\', 'W4', 20, 14);
  SetEditorMode (mMap);
  ImportLevelMap   ('c:\ch2\', 'X1', 'X1');
  ImportLevelMap   ('c:\ch2\', 'X1B', 'X1B');
  ImportLevelMap   ('c:\ch2\', 'X2', 'X2');
  ImportLevelMap   ('c:\ch2\', 'X3', 'X3');
  ImportLevelMap   ('c:\ch2\', 'X3B', 'X3B');
  ImportLevelMap   ('c:\ch2\', 'X4', 'X4');

  SetEditorMode (mTile);
  ImportLevelTiles ('c:\ch2\', 'W5', 20, 14);
  SetEditorMode (mMap);
  ImportLevelMap   ('c:\ch2\', 'X5', 'X5');
  ImportLevelMap   ('c:\ch2\', 'X5B', 'X5B');
  ImportLevelMap   ('c:\ch2\', 'X6', 'X6');
  ImportLevelMap   ('c:\ch2\', 'X7', 'X7');
  ImportLevelMap   ('c:\ch2\', 'X7B', 'X7B');
  ImportLevelMap   ('c:\ch2\', 'X8', 'X8');

  SetEditorMode (mTile);
  ImportLevelTiles ('c:\ch2\', 'W6', 20, 14);
  SetEditorMode (mMap);
  ImportLevelMap   ('c:\ch2\', 'X9', 'X9');
  ImportLevelMap   ('c:\ch2\', 'X9B', 'X9B');
  ImportLevelMap   ('c:\ch2\', 'XA', 'XA');
  ImportLevelMap   ('c:\ch2\', 'XB', 'XB');
  ImportLevelMap   ('c:\ch2\', 'XBB', 'XBB');
  ImportLevelMap   ('c:\ch2\', 'XC', 'XC');

  ImportLevelTiles ('c:\ch2\', 'MainChar', 20, 28, 'c');

  ImportLevelTiles ('c:\ch2\', 's20x28', 20, 28, 's');
  ImportLevelTiles ('c:\ch2\', 's20x16', 20, 16, 's');
  ImportLevelTiles ('c:\ch2\', 's24x14', 20, 14, 's');
  ImportLevelTiles ('c:\ch2\', 's24x14', 24, 14, 's');
  ImportLevelTiles ('c:\ch2\', 's8x7', 8, 7, 's');
  ImportLevelTiles ('c:\ch2\', 's8x8', 8, 8, 's');
  ImportLevelTiles ('c:\ch2\', 's40x28', 40, 28, 's');
  ImportLevelTiles ('c:\ch2\', 's40x6', 40, 6, 's');
  ImportLevelTiles ('c:\ch2\', 's20x6', 20, 6, 's');
  ImportLevelTiles ('c:\ch2\', 's32x28', 32, 28, 's');
  ImportLevelTiles ('c:\ch2\', 's10x14', 10, 14, 's');
  ImportLevelTiles ('c:\ch2\', 's20x18', 20, 18, 's');
  ImportLevelTiles ('c:\ch2\', 's40x24', 40, 24, 's');
  ImportLevelTiles ('c:\ch2\', 's32x24', 32, 24, 's');
  ImportLevelTiles ('c:\ch2\', 's20x24', 20, 24, 's');
  ImportLevelTiles ('c:\ch2\', 's12x8', 12, 8, 's');
  ImportLevelTiles ('c:\ch2\', 's12x7', 12, 7, 's');
  ImportLevelTiles ('c:\ch2\', 's26x16', 26, 16, 's');
  ImportLevelTiles ('c:\ch2\', 's32x18', 32, 18, 's');
}

  for i := 0 to Tab.Tabs.Count - 1 do
  begin
    Tab.TabIndex := i;
    TabChange (nil);
    RemoveDuplicateTiles1Click(nil);
  end;
end;

procedure TMainForm.ImportAnySize (dir: string; extc: Char);
  var
    F: file of Byte;
    SR: TSearchRec;
    Wd, Ht: Byte;
    ai: array of Integer;
    i: Integer;
    L: Integer;
    Found: Boolean;
begin
  SetLength (ai, 0);
  if FindFirst (dir + '*.' + extc + '??', faAnyFile, SR) = 0 then
  repeat
    AssignFile (F, dir + SR.Name);
    Reset (F);
    if FileSize (F) <= 64 * 64 then
    begin
      BlockRead (F, Wd, SizeOf (Wd));
      BlockRead (F, Ht, SizeOf (Ht));
      if (Wd <= 64) and (Ht <= 64) and (FileSize (F) = Wd * Ht + 2 * SizeOf (Byte)) then
      begin
        L := Length (ai);
        Found := FALSE;
        for i := 0 to L - 1 do
          if ai[i] = (Ht shl 8) + Wd then
            Found := TRUE;
        if not Found then
        begin
          SetLength (ai, L + 1);
          ai[L] := (Ht shl 8) + Wd;
        end;
      end;
    end;
    CloseFile (F);
  until FindNext (SR) <> 0;
  FindClose (SR);

  for i := 0 to Length (ai) - 1 do
  begin
    Wd := ai[i] and $FF;
    Ht := (ai[i] shr 8) and $FF;
    ImportLevelTiles (dir, 's' + IntToStr (Wd) + 'x' + IntToStr (Ht), Wd, Ht, extc);
  end;

  SetLength (ai, 0);
end;

procedure TMainForm.ImportLevelTiles (dir, name: string; ww, hh: Integer; extc: Char);
  var
    TB: TBitmap;
    FT: TextFile;
    F: file;
    s: string;
    Pal: array[0..255, 0..2] of Byte;
    ai: array of Integer;
    TmpBmpName: string;
    i, j: Integer;
    SR: TSearchRec;

  procedure ReadTile (filename: string);
    var
      i, j, k: Integer;
      Wd, Ht: Byte;
      b: Byte;
  begin
    AssignFile (F, filename);
    Reset (F, 1);
    BlockRead (F, Wd, SizeOf (Wd));
    BlockRead (F, Ht, SizeOf (Ht));
    TB.Height := TB.Height + hh;
    if (Wd = ww) and (Ht = hh) then
    begin
      for j := 0 to Ht - 1 do
        for i := 0 to Wd - 1 do
        begin
          BlockRead (F, b, SizeOf (b));
          if b = 0 then
            k := TRANS_COLOR
          else
            k := RGB (Pal[b, 0], Pal[b, 1], Pal[b, 2]);
          TB.Canvas.Pixels[i, TB.Height - hh + j] := k;
        end;
    end;
    CloseFile (F);
  end;

begin
  TmpBmpName := '$tmp$bmp$.bmp';

  TB := TBitmap.Create;
  SetStretchBltMode(TB.Canvas.Handle, HALFTONE);
  TB.PixelFormat := pf24bit;
  TB.Width := ww;

  SetLength (ai, 2);
  ai[0] := TRANS_COLOR;
  ai[1] := TRANS_COLOR;

  AssignFile (F, dir + 'DEFAULT.PAL');
  Reset (F, 1);
  BlockRead (F, Pal, SizeOf (Pal));
  CloseFile (F);
  for i := 0 to 255 do
    for j := 0 to 2 do
      Pal[i, j] := Pal[i, j] shl 2;

  if (extc = #0) and FileExists (dir + 'NUMBERS.EDL') then
  begin
    AssignFile (FT, dir + 'NUMBERS.EDL');
    Reset (FT);
    repeat
      ReadLn (FT, s);
      if FileExists (dir + s) then
        ReadTile (dir + s);
    until Eof (FT) or (s = '');
    CloseFile (FT);
  end
  else
  begin
    if FindFirst (dir + '*.' + extc + '??', faAnyFile, SR) = 0 then
      repeat
        ReadTile (dir + SR.Name);

      until FindNext (SR) <> 0;
    FindClose (SR);
  end;

  TB.SaveToFile (TmpBmpName);
  TB.Free;

  CreateNewTileCollection (name, ww, hh, TRUE);
  FreeTBR (TileTab[Tab.TabIndex].tbr);
  MainForm.ProgressPanel.Visible := TRUE;
  TileTab[Tab.TabIndex].tbr :=
      ReadTileBitmap (TmpBmpName,
          ww, hh,  0, 0,
          ai,  0, 0,  0, 0,
          ProgressBar, FALSE,
          FALSE, TileTab[Tab.TabIndex].tbr);

  SetLength (ai, 0);
  MainForm.ProgressPanel.Visible := FALSE;

  TabChange (nil);
  Modified := TRUE;
end;

procedure TMainForm.ImportLevelMap (dir, filename, name: string);
  type
    MapDataRec =
      record
        BGNr,
        FGNr: Word;
        BGAdd,
        FGAdd,
        Bound,
        Code: Byte;
      end;
    ReplaceRec =
      record
        OldNr: Word;
        Add: Byte;
        NewNr: Word;
      end;
  var
    F: file;
    sig: array[0..3] of Char;
    HSize, VSize: SmallInt;
    ww, hh: SmallInt;
    mdr: MapDataRec;
    i, j, k, x, y: Integer;
    repl: array of ReplaceRec;
    SeqNr: Integer;

  function GetAddTile (N: Word; Add: Byte): Word;
    var
      F: file;
      FT: TextFile;
      s: string;
      Pal: array[0..255, 0..2] of Byte;
      i, j, k: Integer;
      Wd, Ht: Byte;
      b: Byte;
  begin
    for i := 0 to Length (repl) - 1 do
      if (repl[i].OldNr = N) and (repl[i].Add = Add) then
      begin
        GetAddTile := repl[i].NewNr;
        Exit;
      end;

    CreateNewTile (TileTab[Tab.TabIndex].tbr);

    AssignFile (F, dir + 'DEFAULT.PAL');
    Reset (F, 1);
    BlockRead (F, Pal, SizeOf (Pal));
    CloseFile (F);
    for i := 0 to 255 do
      for j := 0 to 2 do
        Pal[i, j] := Pal[i, j] shl 2;

    AssignFile (FT, dir + 'NUMBERS.EDL');
    Reset (FT);
    for k := 1 to N - 1 do
      ReadLn (FT);
    ReadLn (FT, s);
    if FileExists (dir + s) then
    begin
      AssignFile (F, dir + s);
      Reset (F, 1);
      BlockRead (F, Wd, SizeOf (Wd));
      BlockRead (F, Ht, SizeOf (Ht));
      if (Wd = W) and (Ht = H) then
      begin
        for j := 0 to Ht - 1 do
          for i := 0 to Wd - 1 do
          begin
            BlockRead (F, b, SizeOf (b));
            if b = 0 then
              k := TRANS_COLOR
            else
            begin
              b := (b + Add) mod 256;
              k := RGB (Pal[b, 0], Pal[b, 1], Pal[b, 2]);
            end;
            Bmp.Canvas.Pixels[BORDER_W + i, BORDER_H + j] := k;
          end;
      end;
      CloseFile (F);
    end;
    CloseFile (FT);

    i := Length (repl);
    SetLength (repl, i + 1);
    repl[i].OldNr := N;
    repl[i].Add := Add;
    repl[i].NewNr := TileTab[Tab.TabIndex].tbr.TileCount - 1;

    //UpdateBmp (TRUE);

        with TileTab[Tab.TabIndex] do
          tbr.TileBitmap.Canvas.CopyRect (MakeRect (tbr.Current * W, 0, W, H),
              Bmp.Canvas, MakeRect (BORDER_W, BORDER_H, W, H));


    UpdateTileBitmap;
    GetAddTile := TileTab[Tab.TabIndex].tbr.TileCount - 1;
  end;

  function CmpMCR (mcr1, mcr2: MapCellRec): Boolean;
  begin
    CmpMCR := (mcr1.Back = mcr2.Back) and (mcr1.Mid = mcr2.Mid) and
              (mcr1.Front = mcr2.Front) and (mcr1.Bounds = mcr2.Bounds);
  end;

begin  { ImportLevelMap }
  SetEditorMode (mMap);

  HSize := 0;
  VSize := 0;
  SetLength (repl, 0);
  AssignFile (F, dir + filename);
  Reset (F, 1);

  BlockRead (F, sig, SizeOf (sig));

//  if (sig[0] = 'M') and (sig[1] = 'A') and (sig[2] = 'P') then
  begin
    if (sig[0] = 'M') and (sig[1] = 'A') and (sig[2] = 'P') then
    begin
      BlockRead (F, HSize, SizeOf (HSize));
      BlockRead (F, VSize, SizeOf (VSize));
      BlockRead (F, ww, SizeOf (ww));
      BlockRead (F, hh, SizeOf (hh));
    end
    else
    begin
      CloseFile (F);

      AssignFile (F, dir + filename);
      Reset (F, 1);
      BlockRead (F, HSize, SizeOf (HSize));
      BlockRead (F, VSize, SizeOf (VSize));
      ww := W;
      hh := H;
    end;

    if (ww = W) and (hh = H) then
    begin
      NewMap (TileTab[Tab.TabIndex].tbr, name, HSize, VSize);

      MapTab.TabIndex := MapTab.Tabs.Add (name);
      MapTabChange (nil);

      with TileTab[Tab.TabIndex].tbr.Maps do
        with aMaps[CurMap] do
        begin
          for j := 0 to VSize - 1 do
            for i := 0 to HSize - 1 do
            begin
              BlockRead (F, mdr, SizeOf (mdr));

              with Map[j, i], mdr do
              begin
                if FGNr and $FFF <> 0 then
                begin
                  if FGAdd <> 0 then
                    FGNr := (FGNr and $F000) + (GetAddTile (FGNr and $FFF, FGAdd) + 1);
                  Mid := SmallInt ((FGNr and $CFFF) - 1);
                end;
                if BGNr and $FFF <> 0 then
                begin
                  if BGAdd <> 0 then
                    BGNr := (BGNr and $F000) + (GetAddTile (BGNr and $FFF, BGAdd) + 1);
                  if BGNr and $2000 = $2000 then
                    Front := SmallInt ((BGNr and $CFFF) - 1)
                  else
                    Back := SmallInt ((BGNr and $CFFF) - 1);
                end;

                Bounds := ShortInt (Bound);
                MapCode := Code;
              end;

            end;
        end;

    end;
  end;
  CloseFile (F);
  Modified := TRUE;
  SetLength (repl, 0);

  SetEditorMode (mMap);

  // sequences:
  i := 0;
  SeqNr := SeqTab.Tabs.Count;
  with TileTab[Tab.TabIndex].tbr.Maps do
    with aMaps[CurMap] do
    begin
      while (i < HSize - 1) and (Map[0, i].MapCode = $FF) do
      begin
        j := 0;
        while (j < VSize - 1) and (Map[j, i].MapCode = $FF)
               and (not EmptyMCR (Map[j + 1, i])) do
        begin
          Area.Top := j + 1;
          Area.Left := i;
          Area.Bottom := j + 1;
          Area.Right := i;

          k := j + 1;
          while (k <= VSize - 1) and (Map[k, i].MapCode <> $FF) and
                (not EmptyMCR (Map[k, i])) do
            Inc (k);
          if k <= VSize - 1 then
          begin
            for y := 0 to VSize - 1 do
              for x := i + 1 to HSize - 1 do
                if CmpMCR (Map[y, x], Map[Area.Top, Area.Left]) then
                  with Map[y, x] do
                  begin
                   // Bounds := $FF;
                   // Bounds := ShortInt ($80);
                    Bounds := $40;
                    Back := -1;
                    Mid := -1;
                    Front := -1;
                    MapCode := SeqNr;
                  end;

            Area.Bottom := k - 1;
            Selection := TRUE;
            ConverttoTileSequence1Click (nil);
            Inc (SeqNr);
            Selection := FALSE;
          end;
          j := k;
        end;
        Inc (i);
      end;

      // remove first columns
      if i > 0 then
        for y := 0 to VSize - 1 do
        begin
          for x := i to HSize - 1 do
            Map[y, x - i] := Map[y, x];
          SetLength (Map[y], Length (Map[y]) - i);
        end;
    end;

  SetEditorMode (mTile);
end;
{$ENDIF}

procedure TMainForm.InsertHorizontal1Click(Sender: TObject);
  var
    InsPos, InsCount: Integer;
    MapH, i, j: Integer;
begin
  InsPos := 0;
  InsCount := 1;
  if Selection then
  begin
    InsPos := Area.Left;
    InsCount := Area.Right - Area.Left + 1;
  end;
  with TileTab[Tab.TabIndex].tbr.Maps do
    with aMaps[CurMap] do
    begin
      MapH := Length (Map);
      for j := 0 to MapH - 1 do
      begin
        SetLength (Map[j], Length (Map[j]) + InsCount);
        for i := Length (Map[j]) - 1 downto InsPos + InsCount do
          Map[j, i] := Map[j, i - InsCount];
//        for i := 0 to InsCount - 1 do
//          ClearMCR (Map[j, InsPos + i]);
      end;
    end;
  Area := Rect (InsPos, 0, InsPos + InsCount - 1, MapH - 1);
  UpdateMap;
  Modified := TRUE;
end;

procedure TMainForm.DeleteHorizontal1Click(Sender: TObject);
  var
    DelPos, DelCount: Integer;
    MapH, i, j: Integer;
begin
  DelPos := 0;
  DelCount := 1;
  if Selection then
  begin
    DelPos := Area.Left;
    DelCount := Area.Right - Area.Left + 1;
  end;
  with TileTab[Tab.TabIndex].tbr.Maps do
    with aMaps[CurMap] do
    begin
      MapH := Length (Map);
      for j := 0 to MapH - 1 do
      begin
        for i := DelPos + DelCount to Length (Map[j]) - 1 do
          Map[j, i - DelCount] := Map[j, i];
        i := Length (Map[j]) - DelCount;
        if i < 0 then i := 0;
        SetLength (Map[j], i);
      end;
    end;
  Selection := FALSE;
  UpdateMap;
  Modified := TRUE;
end;

procedure TMainForm.InsertVertical1Click(Sender: TObject);
  var
    InsPos, InsCount: Integer;
    MapW, i, j: Integer;
begin
  InsPos := 0;
  InsCount := 1;
  if Selection then
  begin
    InsPos := Area.Top;
    InsCount := Area.Bottom - Area.Top + 1;
  end;
  with TileTab[Tab.TabIndex].tbr.Maps do
    with aMaps[CurMap] do
    begin
      MapW := 0;
      if Length (Map) > 0 then
        MapW := Length (Map[0]);
      SetLength (Map, Length (Map) + InsCount);
      for j := 0 to InsCount - 1 do
        SetLength (Map[Length (Map) - 1 - j], MapW);
      for j := Length (Map) - 1 downto InsPos + InsCount do
        for i := 0 to MapW - 1 do
          Map[j, i] := Map[j - InsCount, i];
    end;
  { RD: clear selection and redraw map with new dimensions }
  Area := Rect (0, InsPos, MapW - 1, InsPos + InsCount - 1);
  UpdateMap;
  Modified := TRUE;
end;

procedure TMainForm.DeleteVertical1Click(Sender: TObject);
  var
    DelPos, DelCount: Integer;
    MapW, i, j: Integer;
begin
  DelPos := 0;
  DelCount := 1;
  if Selection then
  begin
    DelPos := Area.Top;
    DelCount := Area.Bottom - Area.Top + 1;
  end;
  with TileTab[Tab.TabIndex].tbr.Maps do
    with aMaps[CurMap] do
    begin
      MapW := 0;
      if Length (Map) > 0 then
        MapW := Length (Map[0]);
      for j := DelPos + DelCount to Length (Map) - 1 do
        for i := 0 to MapW - 1 do
          Map[j - DelCount, i] := Map[j, i];
      for j := 0 to DelCount - 1 do
        SetLength (Map[Length (Map) - 1 - j], MapW);
      SetLength (Map, Length (Map) - DelCount);
    end;
  Selection := FALSE;
  UpdateMap;
  Modified := TRUE;
end;

procedure TMainForm.FormShow(Sender: TObject);
begin
  if ReadParamFile then
  begin
    Modified := FALSE;
    Open1Click (nil);
  end;
  ReadParamFile := FALSE;
end;

procedure TMainForm.Tutorial1Click(Sender: TObject);
  var
    Param: string;
begin
  Param := ApplPath + 'Tutorial\tutor.html';
  ShellExecute (0, 'open', PChar (Param), Nil, Nil, SW_SHOWNORMAL);
end;

procedure TMainForm.OutputtoProjectDirectory1Click(Sender: TObject);
begin
  SelectOutputDirectory1.Checked := FALSE;
  OutputtoProjectDirectory1.Checked := TRUE;
  OutputPath := FilePath (FileName);
end;

procedure TMainForm.RecentFileClick (Sender: TObject);
begin
  with Sender as TMenuItem do
  begin
    ReadParamFile := TRUE;
    FileToOpen := RecentFiles.Strings[Tag];
    Open1Click (Nil);
    ReadParamFile := FALSE;
  end;
end;

procedure TMainForm.AddFileToRecentProjects (FileName: string);
  var
    i: Integer;
begin
  RecentFiles.Insert (0, FileName);
  for i := 1 to RecentFiles.Count - 1 do
    if i <= RecentFiles.Count - 1 then
      if UpCaseStr (RecentFiles.Strings[i]) = UpCaseStr (FileName) then
        RecentFiles.Delete (i);
  UpdateRecentFilesMenu;
end;

procedure TMainForm.ReadConfigFile;
  var
    F: TextFile;
    s: string;

  procedure ReadRecentFiles;
    var
      s: string;
  begin
    ReadLn (F, s);
    while (not Eof (F)) and (s <> '') do
    begin
      RecentFiles.Append (s);
      ReadLn (F, s);
    end;
  end;

  procedure ReadWindowState;
    var
      s: string;
      C: Char;
      Error: Boolean;
      V, Code: Integer;
  begin
    Error := FALSE;
    ReadLn (F, s);
    repeat
      if (Length (s) > 2) and (s[2] = '=') then
      begin
        C := s[1];
        Delete (s, 1, 2);
        Val (s, V, Code);
        if Code <> 0 then
          Error := TRUE
        else
          case C of
            'X': WinLeft := V;
            'Y': WinTop := V;
            'W': WinWidth := V;
            'H': WinHeight := V;
          end;
      end;

      if not Error then
        ReadLn (F, s);
    until Eof (F) or (s = '') or Error;
  end;

  procedure ReadSettings;
    var
      s, Name: string;
      Error: Boolean;
      V, Code: Integer;
  begin
    Error := FALSE;
    ReadLn (F, s);
    repeat
      if (Pos ('=', s) > 0) then
      begin
        Name := Copy (s, 1, Pos ('=', s) - 1);
        Delete (s, 1, Pos ('=', s));
        Val (s, V, Code);
        if Code <> 0 then
          Error := TRUE
        else
        begin
          if Name = 'Trans' then TRANS_COLOR := V;
          if Name = 'Replace' then TRANS_COLOR_REPLACEMENT := V;
        end;
      end;

      if not Error then
        ReadLn (F, s);
    until Eof (F) or (s = '') or Error;
  end;

begin  { ReadConfigFile }
  WinWidth := 800;
  WinHeight := 600;

  if FileExists (ApplPath + CONFIG_FILE) then  // bugfix 2.55
  begin
    AssignFile (F, ApplPath + CONFIG_FILE);
    Reset (F);
    ReadLn (F, s);
    if s = UpCaseStr (APPL_NAME) then
    begin

      repeat
        ReadLn (F, s);
        if s = '[Recent Projects]' then
          ReadRecentFiles;
        if s = '[Window]' then
          ReadWindowState;
        if s = '[Settings]' then
          ReadSettings;
      until Eof (F);

    end;
    CloseFile (F);
  end;
end;

procedure TMainForm.WriteConfigFile;
  var
    F: TextFile;
    i: Integer;
    R, G, B: Integer;
begin
  if CDROM then  { bug fix 2.43 }
    Exit;

  AssignFile (F, ApplPath + CONFIG_FILE);
  ReWrite (F);
  WriteLn (F, UpCaseStr (APPL_NAME));
  WriteLn (F);

  WriteLn (F, '[Recent Projects]');
  for i := 0 to RecentFiles.Count - 1 do
    WriteLn (F, RecentFiles.Strings[i]);
  WriteLn (F);

  WriteLn (F, '[Window]');
  WriteLn (F, 'X=', MainForm.Left);
  WriteLn (F, 'Y=', MainForm.Top);
  WriteLn (F, 'W=', MainForm.Width);
  WriteLn (F, 'H=', MainForm.Height);
  WriteLn (F);

  WriteLn (F, '[Settings]');
  GetRGB (TRANS_COLOR, R, G, B);
  WriteLn (F, 'Trans=$', Hex2 (R and $FF), Hex2 (G and $FF), Hex2 (B and $FF));
  GetRGB (TRANS_COLOR_REPLACEMENT, R, G, B);
  WriteLn (F, 'Replace=$', Hex2 (R and $FF), Hex2 (G and $FF), Hex2 (B and $FF));
  WriteLn (F);

  CloseFile (F);
end;

procedure TMainForm.SmoothPalette1Click(Sender: TObject);
begin
  with SmoothPalette1 do
  begin
    Checked := not Checked;
    RearrangePalette1.Enabled := not Checked;
  end;
  Palette.Repaint;
end;

procedure TMainForm.PaletteManager1Click(Sender: TObject);
  var
    i: Integer;

  function FindOrig (n: Integer): Integer;
    var
      j: Integer;
  begin
    FindOrig := -1;
    for j := 0 to Length (aiOrig) - 1 do
      if aiOrig[j] = n then
        FindOrig := j;
  end;

begin
  with TileTab[Tab.TabIndex].tbr do     // bug fix 2.34
    SelectedPalette := PaletteNumber;

  DefaultPaletteChanged := FALSE;
  SelectedPaletteChanged := FALSE;

  // store numbers in case some palettes are deleted
  SetLength (aiOrig, Length (aaiPal));
  for i := 0 to Length (aaiPal) - 1 do
    aiOrig[i] := i;

  SetLength (aiUsedColors, 0);
  if ShowUsedColors1.Checked then
    with UsedColorsImage.Picture.Bitmap do
      if Height - 1 <= 256 then
      begin
        SetLength (aiUsedColors, Height - 1);
        for i := 0 to (Height - 1) - 1 do
          aiUsedColors[i] := Canvas.Pixels[0, i + 1];
      end;

  PaletteManager.ShowModal;

  for i := 0 to Tab.Tabs.Count - 1 do
    with TileTab[i].tbr do
      if PaletteNumber <> -1 then
        PaletteNumber := FindOrig (PaletteNumber);

  if DefaultPaletteChanged then
    if DefaultPalette <> -1 then
    begin
      for i := 0 to Tab.Tabs.Count - 1 do
        with TileTab[i].tbr do
          if PaletteNumber = -1 then
            PaletteNumber := DefaultPalette;
    end;

  if SelectedPaletteChanged then
    with TileTab[Tab.TabIndex].tbr do
      PaletteNumber := SelectedPalette;

  if ShowCurrentPalette1.Checked then
  begin
    ShowCurrentPalette1.Checked := FALSE;
    ShowCurrentPalette1Click (Sender);
  end;
end;


// new 2.0 - move entire animation
procedure TMainForm.ImportPovRayanimation1Click(Sender: TObject);
begin
  if not HasNoTiles (TileTab[Tab.TabIndex].tbr) then
    if MessageDlg ('Current Tile Set will be overwritten by imported tiles.',
            mtWarning, [mbOk, mbCancel], 0) <> mrOk then
      Exit;
  ImpPovAni.CurTileW := W;
  ImpPovAni.CurTileH := H;
  PovAni.ShowModal;
  if ImpPovAni.Done then
  begin
    TabChange (Sender);
    Modified := TRUE;
    UpdateTileBitmap;
  end;
end;

procedure TMainForm.Up2Click(Sender: TObject);
begin
  with TileTab[Tab.TabIndex].tbr do
  begin
    Current := 0;
    repeat
      Up1Click (Sender);
      NextTile1Click (Sender);
    until Current + 1 >= TileCount;
  end;
  StartEdit (FALSE);
end;

procedure TMainForm.Down2Click(Sender: TObject);
begin
  with TileTab[Tab.TabIndex].tbr do
  begin
    Current := 0;
    repeat
      Down1Click (Sender);
      NextTile1Click (Sender);
    until Current + 1 >= TileCount;
  end;
  StartEdit (FALSE);
end;

procedure TMainForm.Left3Click(Sender: TObject);
begin
  with TileTab[Tab.TabIndex].tbr do
  begin
    Current := 0;
    repeat
      Left1Click (Sender);
      NextTile1Click (Sender);
    until Current + 1 >= TileCount;
  end;
  StartEdit (FALSE);
end;

procedure TMainForm.Right3Click(Sender: TObject);
begin
  with TileTab[Tab.TabIndex].tbr do
  begin
    Current := 0;
    repeat
      Right1Click (Sender);
      NextTile1Click (Sender);
    until Current + 1 >= TileCount;
  end;
  StartEdit (FALSE);
end;

procedure TMainForm.NoDelay1Click(Sender: TObject);
begin
  if AnimationTimer.Enabled then
    AnimationTimer.Interval := 1;
end;

procedure TMainForm.ShowCurrentPalette1Click(Sender: TObject);
  var
    bmp: TBitmap;
    i, p: Integer;
begin
  UsedColors.ShowHint := TRUE;
  with TileTab[Tab.TabIndex] do
    p := tbr.PaletteNumber;
  if p = -1 then
    p := DefaultPalette;
  with ShowCurrentPalette1 do
  begin
    Checked := not Checked;
    if Checked then
    begin
      if p = -1 then
        Msg ('No palette selected for this tile set and no default palette available.')
      else
        if aiPreset[p] = 0 then
          Msg ('The selected palette is empty.')
        else
        begin
          bmp := TBitmap.Create;
          SetStretchBltMode(bmp.Canvas.Handle, HALFTONE);
          with bmp do
          begin
            PixelFormat := pf24bit;
            Width := 1;
            Height := aiPreset[p];
            for i := 0 to aiPreset[p] - 1 do
              Canvas.Pixels[0, i] := aaiPal[p, i];
          end;
          UsedColorsImage.Picture.Bitmap := bmp;
          bmp.Free;
          UsedColorsImage.Stretch := TRUE;
          UsedColors.Visible := TRUE;
          MainForm.Resize;
        end;
    end
    else
      HideUsedColors;
  end;
  UsedColorSelect := FALSE;
end;

procedure TMainForm.ImportMap1Click(Sender: TObject);
  var
    F: file of Byte;
    i1: Byte;
    i2: SmallInt;
    i4, L: LongInt;
    b4: array [0..3] of Byte;
    MapX, MapY, MapW, MapH, N: Integer;
begin
  with TileTab[Tab.TabIndex].tbr.Maps do
    with aMaps[CurMap] do
      if ImportMapDialog.Execute then
      begin
        MapX := 0;
        MapY := 0;
        MapW := Length (Map[0]);
        MapH := Length (Map);
        if Selection then
        begin
          MapX := Area.Left;
          MapY := Area.Top;
          MapW := Area.Right - Area.Left + 1;
          MapH := Area.Bottom - Area.Top + 1;
        end;
        if MapW = 0 then
          Exit;
        AssignFile (F, ImportMapDialog.Filename);
        try
          Reset (F);
          N := 0;
          L := 0;
          repeat
            case (ImportMapDialog.FilterIndex - 1) div 2 of
              0: begin
                   Read (F, i1);
                   L := i1;
                 end;
              1: begin
                   Read (F, b4[0]);
                   Read (F, b4[1]);
                   Move (b4, i2, SizeOf (i2));
                   L := i2;
                 end;
              2: begin
                   Read (F, b4[0]);
                   Read (F, b4[1]);
                   Read (F, b4[2]);
                   Read (F, b4[3]);
                   Move (b4, i4, SizeOf (i4));
                   L := i4;
                 end;
            end;
            if (ImportMapDialog.FilterIndex - 1) mod 2 = 1 then
              Dec (L);
            if (L < 0) or (L >= TileTab[Tab.TabIndex].tbr.TileCount) then
              L := -1;

            with Map[MapY + N div MapW,               // y
                     MapX + N mod MapW] do            // x
                case TileTab[Tab.TabIndex].tbr.BackMidFront of
                  -1: back  := L;
                   0: mid   := L;
                   1: front := L;
                end;

            Inc (N);
          until (N >= MapW * MapH) or Eof (f);

        finally
          CloseFile (F);
        end;

        UpdateMap;
        Modified := TRUE;
      end;
end;

procedure TMainForm.ExportMap1Click(Sender: TObject);
  var
    F: file of Byte;
    i1: Byte;
    i2: SmallInt;
    i4, L: LongInt;
    b4: array [0..3] of Byte;
    MapX, MapY, MapW, MapH, N: Integer;
begin
  with TileTab[Tab.TabIndex].tbr.Maps do
    with aMaps[CurMap] do
      if ExportMapDialog.Execute then
      begin
        MapX := 0;
        MapY := 0;
        MapW := Length (Map[0]);
        MapH := Length (Map);
        if Selection then
        begin
          MapX := Area.Left;
          MapY := Area.Top;
          MapW := Area.Right - Area.Left + 1;
          MapH := Area.Bottom - Area.Top + 1;
        end;
        if MapW = 0 then
          Exit;
        AssignFile (F, ExportMapDialog.Filename);
        try
          ReWrite (F);
          N := 0;
          L := 0;
          repeat
            with Map[MapY + N div MapW,               // y
                     MapX + N mod MapW] do            // x
                case TileTab[Tab.TabIndex].tbr.BackMidFront of
                  -1: L := back;
                   0: L := mid;
                   1: L := front;
                end;
            if (ExportMapDialog.FilterIndex - 1) mod 2 = 1 then
              Inc (L);

            case (ExportMapDialog.FilterIndex - 1) div 2 of
              0: begin
                   i1 := Byte (L and $FF);
                   Write (F, i1);
                 end;
              1: begin
                   i2 := SmallInt (L and $FFFF);
                   Move (i2, b4, SizeOf (i2));
                   Write (F, b4[0]);
                   Write (F, b4[1]);
                 end;
              2: begin
                   i4 := L;
                   Move (i4, b4, SizeOf (b4));
                   Write (F, b4[0]);
                   Write (F, b4[1]);
                   Write (F, b4[2]);
                   Write (F, b4[3]);
                 end;
            end;
            Inc (N);
          until (N >= MapW * MapH);

        finally
          CloseFile (F);
        end;

        UpdateMap;
        Modified := TRUE;
      end;
end;

procedure TMainForm.RefreshImportedTiles1Click(Sender: TObject);
  var
    ai: array of Integer;
    s: string;
begin
  SetLength (ai, 0);

  with TileTab[Tab.TabIndex].tbr do
    if RefreshData.OrgFilename = '' then
      ShowMessage ('This tile set was not imported.')
    else
    begin
      if not FileExists (RefreshData.OrgFilename) then  // 2.5 refresh file doesn't exist
      begin
        if OpenPictureDialog.Execute then
        begin
          s := OpenPictureDialog.FileName;
          if FileExists (s) then
            RefreshData.OrgFilename := s;
        end;
      end;

      if FileExists (RefreshData.OrgFilename) then
      begin
        MainForm.ProgressPanel.Visible := TRUE;

        TileTab[Tab.TabIndex].tbr :=
          ReadTileBitmap ('',
                    W, H, 0, 0,
                    ai,
                    0, 0,
                    0, 0,
                    ProgressBar, FALSE,
                    TRUE,
                    TileTab[Tab.TabIndex].tbr);

        TabChange (Sender);
        Modified := TRUE;
        UpdateTileBitmap;
      end;
    end;



          SetLength (ai, 0);

          MainForm.ProgressPanel.Visible := FALSE;

end;

var
  LastTSX, LastTSY: Integer;

procedure TMainForm.TileSelectionMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  GetTileArea;
  TileSelection.Brush.Style := bsClear;
  TileSelOrgX := X + TileSelection.Left;
  TileSelOrgY := Y + TileSelection.Top;
  MovingTileSel := TRUE;
  MovingTileSelPixels := Button = mbLeft;
  LastTSX := 0;
  LastTSY := 0;
  SaveTempBmp;
end;

procedure TMainForm.TileSelectionMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
  var
    i, j: Integer;
begin
  if MovingTileSel then
  begin
    i := ((X + TileSelection.Left) - TileSelOrgX) div Scale;
    j := ((Y + TileSelection.Top) - TileSelOrgY) div Scale;
    TileSelX1 := TileAreaX + i;
    TileSelY1 := TileAreaY + j;
    TileSelX2 := TileSelX1 + TileAreaW;
    TileSelY2 := TileSelY1 + TileAreaH;
    if (i <> LastTSX) or (j <> LastTSY) then
      ShowTileSelection (TRUE);
    LastTSX := i;
    LastTSY := j;
    if MovingTileSelPixels then
    begin

        Bmp.Canvas.CopyRect (Rect (0, 0, W + 2 * BORDER_W, H + 2 * BORDER_H),
               TempBmp.Canvas, Rect (0, 0, W + 2 * BORDER_W, H + 2 * BORDER_H));
        Bmp.Canvas.CopyRect (Rect (TileSelX1, TileSelY1, TileSelX2, TileSelY2),
          TempBmp.Canvas, MakeRect (TileAreaX, TileAreaY, TileAreaW, TileAreaH));
        UpdateBMP (FALSE);

    end;
  end;
end;

procedure TMainForm.TileSelectionMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  TileSelection.Brush.Style := bsBDiagonal;
  TileSelection.Brush.Color := $0080FFFF;

  MovingTileSel := FALSE;

     // SaveUndo ('Drop Selection');
      UpdateBmp (TRUE);
      Modified := TRUE;

{
      SaveUndo ('Paste');
      ClipBmp.Assign(Clipboard);
      ClipBmp.Canvas.Draw(0, 0, ClipBmp);
      with ClipBmp do
        Bmp.Canvas.CopyRect (Rect (X1, Y1, X2, Y2),
          ClipBmp.Canvas, MakeRect (0, 0, ClipBmp.Width, ClipBmp.Height));
      UpdateBmp (TRUE);
      TileSelection.Visible := FALSE;
      Modified := TRUE;
}

end;

procedure TMainForm.Horizontal3Click(Sender: TObject);
begin
  Horizontal3.Checked := not Horizontal3.Checked;
  Vertical3.Checked := FALSE;
  Diagonal1.Checked := FALSE;
  GradientH := Horizontal3.Checked;
  GradientV := FALSE;
  GradientD := FALSE;
  TileMouseMove (Sender, [], LastX, LastY);
end;

procedure TMainForm.Vertical3Click(Sender: TObject);
begin
  Horizontal3.Checked := FALSE;
  Vertical3.Checked := not Vertical3.Checked;
  Diagonal1.Checked := FALSE;
  GradientH := FALSE;
  GradientV := Vertical3.Checked;
  GradientD := FALSE;
  TileMouseMove (Sender, [], LastX, LastY);
end;

procedure TMainForm.Diagonal1Click(Sender: TObject);
begin
  Horizontal3.Checked := FALSE;
  Vertical3.Checked := FALSE;
  Diagonal1.Checked := not Diagonal1.Checked;
  GradientH := FALSE;
  GradientV := FALSE;
  GradientD := Diagonal1.Checked;
  TileMouseMove (Sender, [], LastX, LastY);
end;

procedure TMainForm.ProjectInformation1Click(Sender: TObject);
begin
  Info.Caption := 'Project Information - ' + ProjectName;
  Info.ShowModal;
end;

procedure TMainForm.Fill1Click(Sender: TObject);
  var
    x, y, i, j, k: Integer;
begin
  SaveUndo ('Fill');
  GetTileArea;
  if Erasing then
    k := TRANS_COLOR
  else
    k := Color.Brush.Color;
  with Bmp.Canvas do
  begin
    x := TileAreaX;
    y := TileAreaY;
    for i := 0 to TileAreaW - 1 do
      for j := 0 to TileAreaH - 1 do
        Pixels[x + i, y + j] := k;
  end;
  UpdateBmp (TRUE);
  Modified := TRUE;
end;



procedure TMainForm.Lighten1Click(Sender: TObject);
  var
    x, y, i, j, k: Integer;
    R, G, B, l: Integer;
begin
  if Sender = Lighten1 then
    SaveUndo ('Lighten')
  else
    SaveUndo ('Darken');
  GetTileArea;
  l := 256 div (MaxRGB - 1);
  with Bmp.Canvas do
  begin
    x := TileAreaX;
    y := TileAreaY;
    for i := 0 to TileAreaW - 1 do
      for j := 0 to TileAreaH - 1 do
      begin
        k := Pixels[x + i, y + j];
        if k <> TRANS_COLOR then
        begin
          GetRGB (k, R, G, B);
          if Sender = Lighten1 then
            k := RGB (LimitRGB (R + l), LimitRGB (G + l), LimitRGB (B + l))
          else
            k := RGB (LimitRGB (R - l), LimitRGB (G - l), LimitRGB (B - l));
          Pixels[x + i, y + j] := k;
        end;
      end;
  end;
  UpdateBmp (TRUE);
  Modified := TRUE;
end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  RTTimer.Enabled := FALSE;   // 2.31  bug fix

  if Modified then           // 2.0  bug fix
    if not SaveChanges then
      Action := caNone;

  if Action <> caNone then
  begin
    WriteConfigFile;
    Quitting := TRUE;
   // SetEditorMode (mTile);
    CloseAll;
  end;
end;

procedure TMainForm.RealTimeLightening1Click(Sender: TObject);
begin
  with RealTimeLightening1 do   // 2.0
    Checked := not Checked;
  RTTimer.Enabled := RealTimeLightening1.Checked;
end;

procedure TMainForm.RTTimerTimer(Sender: TObject);
begin
  if RealTimeLightening1.Checked then
    if Drawing then
      if not Busy then
        if DrawingTool in [dtPoint, dtBrush, dtLine] then
        begin
          TileMouseUp (nil, LastButton, LastShift, LastX, LastY);
          TileMouseDown (nil, LastButton, LastShift, LastX, LastY);
        end;
end;

procedure TMainForm.Darker1Click(Sender: TObject);  // 2.2
begin
  if FromToFirst > 0 then
  begin
    Dec (FromToFirst);
    Dec (FromToLast);
    FromToPaint (Sender);
  end;
end;

procedure TMainForm.Lighter1Click(Sender: TObject);
begin
  if FromToLast < MAX_FROM_TO - 1 then
  begin
    Inc (FromToFirst);
    Inc (FromToLast);
    FromToPaint (Sender);
  end;
end;


// 2.4: change tile offset

procedure TMainForm.Up3Click(Sender: TObject);
begin
  with TileTab[Tab.TabIndex].tbr do
    if (Current < Length (OffsetX)) and (Current < Length (OffsetY)) then
      if OffsetY[Current] > - H then
      begin
        Dec (OffsetY[Current]);

        UpdateTileBitmap;
        DrawCursor;
        UpdateBMP (TRUE);
        Modified := TRUE;
        ShowStatusInfo;
      end;
end;

procedure TMainForm.Down3Click(Sender: TObject);
begin
  with TileTab[Tab.TabIndex].tbr do
    if (Current < Length (OffsetX)) and (Current < Length (OffsetY)) then
      if OffsetY[Current] < + H then
      begin
        Inc (OffsetY[Current]);

        UpdateTileBitmap;
        DrawCursor;
        UpdateBMP (TRUE);
        Modified := TRUE;
        ShowStatusInfo;
      end;
end;

procedure TMainForm.Left4Click(Sender: TObject);
begin
  with TileTab[Tab.TabIndex].tbr do
    if (Current < Length (OffsetX)) and (Current < Length (OffsetY)) then
      if OffsetX[Current] > - W then
      begin
        Dec (OffsetX[Current]);

        UpdateTileBitmap;
        DrawCursor;
        UpdateBMP (TRUE);
        Modified := TRUE;
        ShowStatusInfo;
      end;
end;

procedure TMainForm.Right4Click(Sender: TObject);
begin
  with TileTab[Tab.TabIndex].tbr do
    if (Current < Length (OffsetX)) and (Current < Length (OffsetY)) then
      if OffsetX[Current] < + W then
      begin
        Inc (OffsetX[Current]);

        UpdateTileBitmap;
        DrawCursor;
        UpdateBMP (TRUE);
        Modified := TRUE;
        ShowStatusInfo;
      end;
end;

procedure TMainForm.ResetOffset1Click(Sender: TObject);
begin
  with TileTab[Tab.TabIndex].tbr do
    if (Current < Length (OffsetX)) and (Current < Length (OffsetY)) then
    begin
      OffsetX[Current] := 0;
      OffsetY[Current] := 0;

      UpdateTileBitmap;
      DrawCursor;
      UpdateBMP (TRUE);
      Modified := TRUE;
      ShowStatusInfo;
    end;
end;

// 2.42
procedure TMainForm.UpdateMap;
begin
  lmp := nil;
  if MapTab.TabIndex > -1 then
    lmp := SelectMap (TileTab[Tab.TabIndex].tbr, MapTab.Tabs[MapTab.TabIndex]);
  if lmp <> nil then
  begin
    DrawMap(Rect(0, 0, -1, -1), false, false, false);
    MapDisplay.Invalidate;
  end;
end;

procedure TMainForm.UpdateMapRegion(Region: TRect);
begin
  DrawMap(Region, false, false, false);
  MapDisplay.Invalidate;
end;

procedure TMainForm.MapDisplayPaint(Sender: TObject);
var
  r: TRect;
  tw, th: integer;
begin
  // To do:
  //  - Change DrawMap interface to reflect new functionality
  //  - Clean up zoom code

  with TileTab[Tab.TabIndex].tbr do
  begin
    tw := W * ZOOM_FACTOR div Zoom; // Warning: may truncate
    th := (H - Overlap) * ZOOM_FACTOR div Zoom; // Warning: may truncate
  end;

  // 2.5
  with TileTab[Tab.TabIndex].tbr.Maps.aMaps[MapTab.TabIndex] do
  begin
    CurMapH := Length (Map);
    CurMapW := Length (Map[0]);
  end;
  MapDisplay.Width := tw * CurMapW;
  MapDisplay.Height := th * CurMapH;

  with MapDisplay.Canvas.ClipRect do
    r := Rect(Left div tw,
              Top div th,
              min(CurMapW - 1, -(-Right div tw)),
              min(CurMapH - 1, -(-Bottom div th)));
  if (VisibleMapRegion.Left <> r.Left) or (VisibleMapRegion.Top <> r.Top)
    or (VisibleMapRegion.Right <> r.Right)
    or (VisibleMapRegion.Bottom <> r.Bottom) then
  begin
    VisibleMapRegion := r;
    DrawMap(Rect(0, 0, -1, -1), false, false, false);
  end;
  MapDisplay.Canvas.StretchDraw(Rect(r.Left * tw, r.Top * th,
   (r.Right + 1) * tw - 1, (r.Bottom + 1) * th - 1), bmpMap);
end;

procedure TMainForm.HideTileSetPanel1Click(Sender: TObject);
begin
  with HideTileSetPanel1 do
  begin
    Checked := not Checked;
    TilePanel.Visible := not Checked;
    if Checked then
      StatusBar.Parent := MainForm
    else
      StatusBar.Parent := TilePanel;
  end;
end;

procedure TMainForm.UseOldNoiseFunctions1Click(Sender: TObject);
begin
  with UseOldNoiseFunctions1 do
    Checked := not Checked;
end;

procedure TMainForm.FormKeyPress(Sender: TObject; var Key: Char);
  var
    sp: TSpeedButton;
begin
  if Key = '+' then
    ZoomIn1Click(Sender);
  if Key = '-' then
    ZoomOut1Click(Sender);

  sp := nil;
  if Mode = mTile then
  begin
    case Key of
      '1': sp := PencilButton;
      '2': sp := BrushButton;
      '3': sp := LineButton;
      '4': sp := RectButton;
      '5': sp := EllipseButton;
      '7': sp := FillButton;
      '8': sp := FilledRectButton;
      '9': sp := FilledEllipseButton;
      '0': sp := SelectionButton;
    end;
  end;
  if Mode = mMap then
  begin
    case Key of
      '1': sp := MapPointButton;
      '2': sp := BlockButton;
      '3': sp := ZOrderButton;
      '4': sp := MapRectButton;
    end;
  end;
  if sp <> nil then
  begin
    sp.Down := True;
    SetDrawingTool (sp);
  end;
end;

procedure TMainForm.ExportMapasImage1Click(Sender: TObject);
  var
    Scale, WW, HH, x, y, i, j, rgba, RR, GG, BB, R, G, B, C, Total, BGC: Integer;
begin
  lmp := nil;
  if MapTab.TabIndex > -1 then
    lmp := SelectMap (TileTab[Tab.TabIndex].tbr, MapTab.Tabs[MapTab.TabIndex]);
  if lmp <> nil then
  begin
    if SavePictureDialog.Execute then
    begin
      SavePictureDialog.DefaultExt := GraphicExtension (TBitmap);
      bmpMapImage := TBitmap.Create;

      case SavePictureDialog.FilterIndex of
        1: bmpMapImage.PixelFormat := pf24bit;
        2: bmpMapImage.PixelFormat := pf16bit;
        3: bmpMapImage.PixelFormat := pf15bit;
        4: bmpMapImage.PixelFormat := pf8bit;
        5: bmpMapImage.PixelFormat := pf4bit;
        6: bmpMapImage.PixelFormat := pf1bit;
        7: bmpMapImage.PixelFormat := pf24bit;  // PNG
      end;
      if ExtractFileExt (SavePictureDialog.Filename) = '' then
        if SavePictureDialog.FilterIndex = 7 then
          SavePictureDialog.Filename := SavePictureDialog.Filename + '.png'
        else
        SavePictureDialog.Filename := SavePictureDialog.Filename + '.bmp';

      DrawMap (Rect(0, 0, -1, -1), TRUE, FALSE, FALSE);

      Scale := MapExportScaleDownFactor1.Tag;
      if Scale <> 1 then
      begin
        BGC := TileTab[Tab.TabIndex].tbr.BackGr;
        WW := bmpMapImage.Width;
        HH := bmpMapImage.Height;
        with bmpMapImage.Canvas do
        begin
          for y := 0 to HH div Scale - 1 do
            for x := 0 to WW div Scale - 1 do
            begin
              RR := 0;
              GG := 0;
              BB := 0;
              C := 0;
              Total := 0;
              for j := 0 to Scale - 1 do
                for i := 0 to Scale - 1 do
                begin
                if (x * Scale + i < WW) and (y * Scale + j < HH) then
                  begin
                    rgba := Pixels[x * Scale + i, y * Scale + j];
                    if rgba <> BGC then
                    begin
                      GetRGB (rgba, R, G, B);
                      Inc (RR, R);
                      Inc (GG, G);
                      Inc (BB, B);
                      Inc (C);
                    end;
                    Inc (Total);
                  end;
                end;
              if C < Total div 2 then
                Pixels[x, y] := BGC
              else
                Pixels[x, y] := RGB (RR div C, GG div C, BB div C);
            end;
        end;
        bmpMapImage.Width := WW div Scale;
        bmpMapImage.Height := HH div Scale;
      end;

      if UpperCase (ExtractFileExt (SavePictureDialog.Filename)) = '.PNG' then
      begin
        bmpMapImage.TransparentColor := TRANS_COLOR;
        WriteBitmapToPngFile (SavePictureDialog.Filename, bmpMapImage, TRANS_COLOR);
      end
      else
        bmpMapImage.SaveToFile (SavePictureDialog.FileName);
      bmpMapImage.Free;
    end;
  end;
end;

procedure TMainForm.RotateRight1Click(Sender: TObject);
  var
    i, j: Integer;
    ai: array of Integer;
begin
  SaveUndo ('Rotate Right');
  GetTileArea;
  with Bmp.Canvas do
    if TileAreaW <> TileAreaH then
      MessageDlg ('Not (yet) implemented for non-square tiles/areas.', mtError, [mbOk], 0)
    else
    begin
      SetLength (ai, TileAreaW * TileAreaH);
      for j := 0 to TileAreaH - 1 do
        for i := 0 to TileAreaW - 1 do
          ai[i + j * TileAreaW] := Pixels[TileAreaX + i, TileAreaY + j];
      for j := 0 to TileAreaH - 1 do
        for i := 0 to TileAreaW - 1 do
          Pixels[TileAreaX + i, TileAreaY + j] := ai[j + (TileAreaW - 1 - i) * TileAreaW];
      if not TileSelection.Visible then
        RotateBounds (Bounds, -90);
    end;

  UpdateBmp (TRUE);
end;

procedure TMainForm.RotateLeft1Click(Sender: TObject);
  var
    i, j: Integer;
    ai: array of Integer;
begin
  SaveUndo ('Rotate Right');
  GetTileArea;
  with Bmp.Canvas do
    if TileAreaW <> TileAreaH then
      MessageDlg ('Not (yet) implemented for non-square tiles/areas.', mtError, [mbOk], 0)
    else
    begin
      SetLength (ai, TileAreaW * TileAreaH);
      for j := 0 to TileAreaH - 1 do
        for i := 0 to TileAreaW - 1 do
          ai[i + j * TileAreaW] := Pixels[TileAreaX + i, TileAreaY + j];
      for j := 0 to TileAreaH - 1 do
        for i := 0 to TileAreaW - 1 do
          Pixels[TileAreaX + i, TileAreaY + j] := ai[TileAreaH - 1 - j + i * TileAreaW];
      if not TileSelection.Visible then
        RotateBounds (Bounds, +90);
    end;

  UpdateBmp (TRUE);
end;

procedure TMainForm.aaClick(Sender: TObject);
  var
    s: string;
begin
  with Sender as TMenuItem do
  begin
    s := Caption;
    if s[1] = '&' then
      system.Delete (s, 1, 1);
    if Length (s) = 1 then
      aaN := StrToInt (s)
    else
      aaN := 1;  // Off
    AntiAliasing1.Caption := '&Anti-Aliasing (' + s + ')';
    Checked := TRUE;
  end;
end;

procedure TMainForm.ReplaceColors2Click(Sender: TObject);
  var
    FirstTile, LastTile, CurTile, OldCurTile: Integer;
    X, Y, RGB, R, G, B: Integer;
    FR, RR: Boolean;
    FR1, FG1, FB1: Integer;
    FR2, FG2, FB2: Integer;
    RR1, RG1, RB1: Integer;
    RR2, RG2, RB2: Integer;
    tr, tg, tb: Integer;
    ar, ag, ab: Integer;
    DF1R, DF1G, DF1B: Real;
    DF2R, DF2G, DF2B: Real;
    DF1, DF2, DF: Real;
    Avg: Integer;

  function Check (x, P, L, Tol: Integer; var DF1: Real; var DF2: Real): Boolean;
  begin
    Result := FALSE;

    DF1 := -1000;
    DF2 := +1000;

    x := x - P;
    if L > 0 then
    begin
      DF1 := (x - Tol) / L;
      DF2 := (x + Tol) / L;
    end
    else
    if L < 0 then
    begin
      DF1 := (x + Tol) / L;
      DF2 := (x - Tol) / L;
    end
    else   { L = 0 }
    begin
      if Abs (x) <= Abs (Tol) then
      begin
        DF1 := 0;
        DF2 := 1;
      end;
    end;
    if not ( ((DF1 < 0) and (DF2 < 0)) or
             ((DF1 > 1) and (DF2 > 1)) ) then
         Result := TRUE;
  end;

begin
  Replace.CurColor := Color.Brush.Color;
  Replace.ShowModal;

  with Replace, TileTab[Tab.TabIndex].tbr do
    if Result then
    begin
      FR := FindRange.Checked;
      RR := ReplaceRange.Checked;
      GetRGB (FindColor1.Brush.Color, FR1, FG1, FB1);
      if FR then
      begin
        GetRGB (FindColor2.Brush.Color, FR2, FG2, FB2);
        Dec (FR2, FR1);
        Dec (FG2, FG1);
        Dec (FB2, FB1);
      end
      else
      begin
        FR2 := 0;
        FG2 := 0;
        FB2 := 0;
      end;

      GetRGB (ReplaceColor1.Brush.Color, RR1, RG1, RB1);
      if RR then
      begin
        GetRGB (ReplaceColor2.Brush.Color, RR2, RG2, RB2);
        Dec (RR2, RR1);
        Dec (RG2, RG1);
        Dec (RB2, RB1);
      end
      else
      begin
        RR2 := 0;
        RG2 := 0;
        RB2 := 0;
      end;

      tr := TolRed.Value;
      tg := TolGreen.Value;
      tb := TolBlue.Value;
      ar := AddRed.Value;
      ag := AddGreen.Value;
      ab := AddBlue.Value;

      OldCurTile := Current;
      FirstTile := Current;
      LastTile := Current;
      if All then
      begin
        FirstTile := 0;
        LastTile := TileCount - 1;
      end
      else
        SaveUndo ('Replace Colors');

      for CurTile := FirstTile to LastTile do
      begin
        if All then
        begin
          Current := CurTile;
         // StartEdit (FALSE);

          with TileTab[Tab.TabIndex] do   // bug fix 2.55 - replace colors replaced tiles
            Bmp.Canvas.CopyRect (MakeRect (BORDER_W, BORDER_H, W, H),
              tbr.TileBitmap.Canvas, MakeRect (tbr.Current * W, 0, W, H));

        end;
        GetTileArea;

        for Y := TileAreaY to TileAreaY + TileAreaH - 1 do
          for X := TileAreaX to TileAreaX + TileAreaW - 1 do
          begin
            RGB := BMP.Canvas.Pixels[X, Y];
            if RGB <> TRANS_COLOR then
            begin
              GetRGB (RGB, R, G, B);

              if Check (R, FR1, FR2, tr, DF1R, DF2R) and
                 Check (G, FG1, FG2, tg, DF1G, DF2G) and
                 Check (B, FB1, FB2, tb, DF1B, DF2B) then
              begin
                DF1 := Max (Max (DF1R, DF1G), DF1B);
                DF2 := Min (Min (DF2R, DF2G), DF2B);
                if DF2 >= DF1 then
                begin
                  DF := (DF2 + DF1) / 2;

                  R := RR1 + Round (DF * RR2) + ar;
                  G := RG1 + Round (DF * RG2) + ag;
                  B := RB1 + Round (DF * RB2) + ab;

                  BMP.Canvas.Pixels[X, Y] := MakePalRGB (R, G, B, 0);
                end;
              end;

            end;
          end;


        UpdateBMP (TRUE);
        UpdateTileBitmap;
      end;

      Current := OldCurTile;
      DrawCursor;
      Modified := TRUE;
    end;
end;

procedure TMainForm.UpdateTileGrid;  // 2.51
  var
    i, j, w, h: Integer;
    LW, LH: Integer;
    CD, CL: Integer;
begin
  with TileTab[Tab.TabIndex] do
  begin
    Grid.Picture.Bitmap.Transparent := TRUE;
    Grid.Picture.Bitmap.TransparentMode := tmFixed;
    Grid.Picture.Bitmap.TransparentColor := TRANS_COLOR;

    w := tbr.W + 2 * BORDER_W;
    h := tbr.H + 2 * BORDER_H;

    LW := tbr.W div 4;
    if tbr.W mod 4 <> 0 then LW := 2 * tbr.W;
    LH := tbr.H div 4;
    if tbr.H mod 4 <> 0 then LH := 2 * tbr.H;

    Grid.Left := Tile.Left {+ BORDER_W * Scale};
    Grid.Top := Tile.Top {+ BORDER_H * Scale};
    if (w * Scale <> Grid.Width) or
       (h * Scale <> Grid.Height) then
    begin
      Grid.Width := w * Scale;
      Grid.Height := h * Scale;
      with Grid.Picture.Bitmap do
      begin
        Width := w * Scale;
        Height := h * Scale;
        with Canvas do
        begin
          Brush.Style := bsSolid;
          Brush.Color := TRANS_COLOR;
          Pen.Style := psSolid;
          Pen.Color := TRANS_COLOR;
          Rectangle (0, 0, Width, Height);
        end;
        for j := 0 to h - 1 do
          for i := 0 to w - 1 do
          begin
            CD := clBlack;
            CL := clWhite;
            if LW * LH <> 0 then
              if ((i - BORDER_W + LW) mod LW = LW - 1) or
                 ((j - BORDER_H + LH) mod LH = LH - 1) then
                CL := clRed;
            Canvas.Pixels[i * Scale, j * Scale] := CD;
            Canvas.Pixels[i * Scale + Scale - 1, j * Scale + Scale - 1] := CL;
          end;
      end;
    end;

  end;
end;

procedure TMainForm.ShowTileGrid1Click(Sender: TObject);
begin
  with ShowTileGrid1 do
  begin
    Checked := not Checked;
    Grid.Visible := Checked;
  end;
end;

procedure TMainForm.ReplaceSelectedTile1Click(Sender: TObject);
  var
    i, j, x, y, w, h: Integer;

  function CompareMCR (mcr1, mcr2: MapCellRec): Boolean;
  begin
    CompareMCR := (mcr1.Back = mcr2.Back) and (mcr1.Mid = mcr2.Mid) and
                  (mcr1.Front = mcr2.Front);
  end;

begin
  if Mode = mMap then
    if Selection and (ClipTab.TabIndex > -1) and (clip <> nil) then
    begin
      w := Min (Area.Right - Area.Left + 1, Length (clip^.Map[0]));
      h := Min (Area.Bottom - Area.Top + 1, Length (clip^.Map));

      with Area do
      begin
        for y := 0 to Length (lmp^.Map) - 1 do
          for x := 0 to Length (lmp^.Map[y]) - 1 do
            if ((x < Left) or (x > Left + W - 1)) or
               ((y < Top) or (y > Top + H - 1)) then
            begin
              for j := 0 to H - 1 do
                for i := 0 to W - 1 do
                  if CompareMCR (lmp^.Map[y, x], clip^.Map[j, i]) then
                    lmp^.Map[y, x] := lmp^.Map[Top + j, Left + i];
            end;

       // for j := 0 to H - 1 do
       //   for i := 0 to W - 1 do
       //     lmp^.Map[Top + j, Left + i] := clip^.Map[j, i];
      end;

      Selection := FALSE;
      UpdateMap;
    end;
  Modified := TRUE;
end;

procedure TMainForm.MoveMapLeft1Click(Sender: TObject);
  var
    lm: LayerMap;
begin
  with TileTab[Tab.TabIndex].tbr.Maps do
    if CurMap > 0 then
    begin
      lm := aMaps[CurMap];
      aMaps[CurMap] := aMaps[CurMap - 1];
      aMaps[CurMap - 1] := lm;
      MapTab.Tabs.Move(CurMap, CurMap - 1);
      Dec (CurMap);
      MapTab.TabIndex := CurMap;
      Modified := TRUE;
      UpdateMap;
      ShowStatusInfo;
    end;
end;

procedure TMainForm.MoveMapRight1Click(Sender: TObject);
  var
    lm: LayerMap;
begin
  with TileTab[Tab.TabIndex].tbr.Maps do
    if CurMap < Length (aMaps) - 1 then
    begin
      lm := aMaps[CurMap];
      aMaps[CurMap] := aMaps[CurMap + 1];
      aMaps[CurMap + 1] := lm;
      MapTab.Tabs.Move(CurMap, CurMap + 1);
      Inc (CurMap);
      MapTab.TabIndex := CurMap;
      Modified := TRUE;
      UpdateMap;
      ShowStatusInfo;
    end;
end;

procedure TMainForm.NextMap1Click(Sender: TObject);
begin
  with TileTab[Tab.TabIndex].tbr.Maps do
    if Length (aMaps) > 0 then
    begin
      if CurMap < Length (aMaps) - 1 then
        Inc (CurMap)
      else
        CurMap := 0;
      MapTab.TabIndex := CurMap;
      UpdateMap;
      ShowStatusInfo;
    end;
end;

procedure TMainForm.PreviousMap1Click(Sender: TObject);
begin
  with TileTab[Tab.TabIndex].tbr.Maps do
    if Length (aMaps) > 0 then
    begin
      if CurMap > 0 then
        Dec (CurMap)
      else
        CurMap := Length (aMaps) - 1;
      MapTab.TabIndex := CurMap;
      UpdateMap;
      ShowStatusInfo;
    end;
end;

procedure TMainForm.N110Click(Sender: TObject);
begin
  with Sender as TMenuItem do
  begin
    MapExportScaleDownFactor1.Tag := Tag;
    Checked := TRUE;
  end;
end;

procedure TMainForm.SplitColorPattern1Click(Sender: TObject);
begin
  with SplitColorPattern1 do
  begin
    Checked := not Checked;
    if Checked then
      with OtherFromTo do
      begin
        FT := FromToList;
        ExFT := ExFromToList;
        F := FromToFirst;
        L := FromToLast;
      end;
    FromTo.Repaint;
  end;
end;

procedure TMainForm.ShowBackLayerClick(Sender: TObject);
begin
  ShowBackLayer.Checked := not ShowBackLayer.Checked;
  UpdateMap;
end;

procedure TMainForm.ShowMidLayerClick(Sender: TObject);
begin
  ShowMidLayer.Checked := not ShowMidLayer.Checked;
  UpdateMap;
end;

procedure TMainForm.ShowFrontLayerClick(Sender: TObject);
begin
  ShowFrontLayer.Checked := not ShowFrontLayer.Checked;
  UpdateMap;
end;

procedure TMainForm.SetGridGuidelines1Click(Sender: TObject);
begin
  with SettingsForm do
  begin
    X.Value := MapGridX;
    Y.Value := MapGridY;
    Caption := 'Map Guidelines';
    ShowModal;
    if Result then
    begin
      MapGridX := X.Value;
      MapGridY := Y.Value;
      UpdateMap;
    end;
  end;
end;

procedure TMainForm.HalfSize1Click(Sender: TObject);
  var
    i, j, ShiftX, ShiftY: Integer;
    XM, YM: array[0..1] of Integer;
    WW, HH: Integer;
    X1, Y1, X2, Y2: Integer;
begin
  if Mode = mTile then
  begin
    if Clipboard.HasFormat(CF_BITMAP) then
    begin
      X1 := BORDER_W;
      Y1 := BORDER_H;
      X2 := X1 + W - 1;
      Y2 := Y1 + H - 1;

      if TileSelection.Visible and
         (TileSelX2 <> TileSelX1) and
         (TileSelY2 <> TileSelY1) then
      begin
        X1 := TileSelX1;
        Y1 := TileSelY1;
        X2 := TileSelX2;
        Y2 := TileSelY2;
      end;

      SaveUndo ('Scaled Paste');
      ClipBmp.Assign(Clipboard);
      ClipBmp.Canvas.Draw(0, 0, ClipBmp);

      ShiftX := 0;
      ShiftY := 0;
      XM[0] := 0;
      XM[1] := 0;
      YM[0] := 0;
      YM[1] := 0;
      for j := 1 to ClipBmp.Height - 1 - 1 do
        for i := 1 to ClipBmp.Width - 1 - 1 do
          with ClipBmp.Canvas do
          begin
            if Pixels[i, j] = Pixels[i + 1, j] then
              Inc (XM[i mod 2]);
            if Pixels[i, j] = Pixels[i, j + 1] then
              Inc (YM[j mod 2]);
          end;
      if XM[1] > XM[0] then ShiftX := 1;
      if YM[1] > YM[0] then ShiftY := 1;

      WW := X2 - X1 + 1;
      HH := Y2 - Y1 + 1;
      WW := Min (WW, (ClipBmp.Width - ShiftX) div 2);
      HH := Min (HH, (ClipBmp.Height - ShiftY) div 2);

      with ClipBmp do
        Bmp.Canvas.CopyRect (MakeRect (X1, Y1, WW, HH),
          ClipBmp.Canvas, MakeRect (ShiftX, ShiftY, 2 * WW, 2 * HH));
      UpdateBmp (TRUE);
      TileSelection.Visible := FALSE;
      Modified := TRUE;
    end;
  end;

end;

procedure TMainForm.N256ColorPalette1Click(Sender: TObject);
  var
    PalFile: string;
    i: Integer;
begin
  Pal256 := not Pal256;
  N256ColorPalette1.Checked := Pal256;

  if Pal256 then
    with TileTab[Tab.TabIndex].tbr do
      if PaletteNumber = -1 then
      begin
        PalFile := '.\' + DEFAULT_PAL;
        if not FileExists (PalFile) then
          PalFile := ApplPath + DEFAULT_PAL;
        if FileExists (PalFile) then
        begin
          PaletteManager.NewButton.Click ();
          PaletteManager.ImportPalette (PalFile, PaletteManager.PaletteTab.TabIndex, 2);
          PalMan.DefaultPalette := PaletteManager.PaletteTab.TabIndex;

          if PalMan.DefaultPalette <> -1 then
          begin
            for i := 0 to Tab.Tabs.Count - 1 do
              with TileTab[i].tbr do
                if PaletteNumber = -1 then
                  PaletteNumber := PalMan.DefaultPalette;
          end;

        end;
        for i := 0 to 255 do
        begin
          Enable256[i] := True; //(Random (256) < 128); // True;
          LastEnable256[i] := True;
        end;
      end;

  Palette.Repaint;
end;

function TMainForm.CountEnabledColors: Integer;
  var
    i, j: Integer;
begin
  j := 0;
  for i := 0 to 255 do
    if Enable256[i] then Inc (j);
  Result := j;
end;

procedure TMainForm.ReplaceCurrentTileSequence1Click(Sender: TObject);
  var
    i, j, m, n: Integer;
    mcr: MapCellRec;
begin
  if SeqTab.TabIndex > -1 then
  begin
    if not Selection then
      Exit;

    // check if not empty
    n := 0;
    m := 0;  // frame lengths provided as map codes?
    with Area do
      for j := Top to Bottom do
        for i := Left to Right do
        begin
          mcr := lmp^.Map[j, i];
          if mcr.MapCode > m then
            m := mcr.MapCode;
          if not EmptyMCR (mcr) then
            Inc (n);
        end;

    if n < 1 then
      Exit;

    SeqW := n;
    SeqH := 1;


    with TileTab[Tab.TabIndex].tbr do
      with Seq do
        with aMaps[CurMap] do
          SetMapSize (Map, SeqW, SeqH);

    n := 0;
    with Area do
    begin
      for j := Top to Bottom do
        for i := Left to Right do
        begin
          mcr := lmp^.Map[j, i];
          if not EmptyMCR (mcr) then
          begin
//            if m = 0 then
//              mcr.MapCode := 25;
            seq^.Map[0, n] := mcr;
            Inc (n);
          end;
        end;
    end;

    SeqTabChange (Sender);

    { RD: clear selection }
    Selection := FALSE;
    UpdateMapRegion(Area);
    Modified := TRUE;
  end
end;

// 3.00
procedure TMainForm.SaveHistoryCoords (x1, y1, x2, y2: Integer);
begin
  if bHistoryRec.Down then
  begin
    HistoryListBox.Items.Add(Format (' %d,%d, %d,%d', [x1, y1, x2, y2]));
  end;
end;

procedure TMainForm.bHistoryClearClick(Sender: TObject);
  var
    i: Integer;
begin
  HistoryListBox.Items.Clear;
  bHistoryClear.Down := False;
  bHistoryRec.Down := True;
  UpdateBMP (False);
  for i := 0 to UndoCount - 1 do
    Undo[i].HistoryCoords := '';
end;

procedure TMainForm.bHistoryShowClick(Sender: TObject);
begin
  UpdateBMP (False);
end;

procedure TMainForm.HistoryListBoxClick(Sender: TObject);
begin
  UpdateBMP (False);
end;

procedure TMainForm.ProjectLists1Click(Sender: TObject);
begin
  Lists.ShowModal;
end;

procedure TMainForm.bRGBEditClick(Sender: TObject);
  var
    filename: string;
begin
  filename := ApplPath + RGBCONV_FILE;
  RGBConv.lblFilename.Caption := filename;
  if FileExists (filename) then
    RGBConv.Script.Lines.LoadFromFile (filename);
  RGBConv.ShowModal;
  if RGBConv.Result then
  begin
    RGBConv.Script.Lines.SaveToFile (filename);
    LoadRGBConvNames;
  end;
end;

procedure TMainForm.LoadRGBConvNames;
  var
    filename: string;
    lines: TStringList;
    LastSelected: string;
    i, j: Integer;
    s: string;
begin
  filename := ApplPath + RGBCONV_FILE;
  lines := TStringList.Create ();
  lines.Clear;
  if not FileExists (filename) then
  begin
    lines.Add ('[Black & White]');
    lines.Add ('R=(R+G+B)/3');
    lines.Add ('G=(R+G+B)/3');
    lines.Add ('B=(R+G+B)/3');
    lines.Add ('');
    lines.Add ('[Invert]');
    lines.Add ('R=255-R');
    lines.Add ('G=255-G');
    lines.Add ('B=255-B');
    lines.Add ('');
    lines.SaveToFile (filename);
  end;

  for i := 0 to Length (RGBConvScripts) - 1 do
    RGBConvScripts[i].Clear;
  SetLength (RGBConvScripts, 0);

  lines.LoadFromFile (filename);
  LastSelected := '';
  for i := 0 to RGBConvListBox.Items.Count - 1 do
    if RGBConvListBox.Selected[i] then
      LastSelected := RGBConvListBox.Items[i];
  RGBConvListBox.Items.Clear;
  j := -1;
  for i := 0 to lines.Count - 1 do
  begin
    s := lines.strings[i];
    s := trim (s);
    if (s <> '') and (s[1] = '[') and (s[Length (s)] = ']') then
    begin
      Delete (s, 1, 1);
      Delete (s, Length (s), 1);
      RGBConvListBox.Items.Add (s);
      if (s = LastSelected) then
        RGBConvListBox.Selected[RGBConvListBox.Items.Count - 1] := TRUE;

      Inc (j);
      SetLength (RGBConvScripts, j + 1);
      RGBConvScripts[j] := TStringList.Create;
    end
    else
      if (j >= 0) and (s <> '') then
        RGBConvScripts[j].Add (s)
  end;
end;

function TMainForm.ConvertPixel (color: Integer): Integer;
  const
    IdChars: set of Char = ['0'..'9', 'A'..'Z'];
  var
    i, j, k, r, g, b, resultR, resultG, resultB: Integer;
    c: Char;
    s: string;
    N: LongInt;
    p, ErrorPos: Integer;
    F: ShortString;
begin
  GetRGB (color, resultR, resultG, resultB);
  for i := 0 to RGBConvListBox.Items.Count - 1 do
    if RGBConvListBox.Selected[i] then
      if (i < Length (RGBConvScripts)) then
      begin
        for j := 0 to RGBConvScripts[i].Count - 1 do
        begin
          s := trim (RGBConvScripts[i].Strings[j]);
          if (s <> '') then
          begin
            c := UpCase (s[1]);
            if (c = 'R') or (c = 'G') or (c = 'B') then
            begin
              Delete (s, 1, 1);
              s := trim (s);
              if (s <> '') and (s[1] = '=') then
              begin
                Delete (s, 1, 1);
                if (s <> '') then
                begin
                  s := '(' + UpCaseStr (s) + ')';
                  GetRGB (color, r, g, b);
                  for k := Length (s) - 1 downto 1 + 1 do
                    if (not (s[k - 1] in IdChars)) and
                       (not (s[k + 1] in IdChars)) then
                      case s[k] of
                        'R': begin
                               Delete (s, k, 1);
                               Insert (Format ('%d', [R]), s, k);
                             end;
                        'G': begin
                               Delete (s, k, 1);
                               Insert (Format ('%d', [G]), s, k);
                             end;
                        'B': begin
                               Delete (s, k, 1);
                               Insert (Format ('%d', [B]), s, k);
                             end;
                      end;
                  ErrorPos := 0;
                  p := 1;
                  F := s;
                  if Evaluate (N, F, p) then
                  begin
                    case c of
                       'R': resultR := N;
                       'G': resultG := N;
                       'B': resultB := N;
                    end;
                  end;

                end;
              end;
            end;
          end;

        end;
      end;
  ConvertPixel := RGB (LimitRGB (resultR), limitRGB (resultG), limitRGB (resultB));
end;

procedure TMainForm.bRGBRunClick(Sender: TObject);
  var
    x, y, i, j, k: Integer;
begin
  SaveUndo ('RGB Script');
  GetTileArea;
  with Bmp.Canvas do
  begin
    x := TileAreaX;
    y := TileAreaY;
    for i := 0 to TileAreaW - 1 do
      for j := 0 to TileAreaH - 1 do
        if Pixels[x + i, y + j] <> TRANS_COLOR then
          Pixels[x + i, y + j] := ConvertPixel (Pixels[x + i, y + j]);
  end;
  UpdateBmp (TRUE);
  Modified := TRUE;
end;

procedure TMainForm.SelectNextClip1Click(Sender: TObject);
begin
  if ClipTab.Tabs.Count > 0 then
    ClipTab.TabIndex := (ClipTab.TabIndex + 1) mod ClipTab.Tabs.Count;
  ClipTabChange (Sender);
end;

procedure TMainForm.SelectPreviousClip1Click(Sender: TObject);
begin
  if ClipTab.Tabs.Count > 0 then
    ClipTab.TabIndex := (ClipTab.TabIndex - 1 + ClipTab.Tabs.Count) mod ClipTab.Tabs.Count;
  ClipTabChange (Sender);
end;

procedure TMainForm.ReplaceColorUnderCursor1Click(Sender: TObject);
  var
    x, y, i, j: Integer;
begin
  SaveUndo ('Replace Color');
  GetTileArea;
  with Bmp.Canvas do
  begin
    x := TileAreaX;
    y := TileAreaY;
    for i := 0 to TileAreaW - 1 do
      for j := 0 to TileAreaH - 1 do
        if Pixels[x + i, y + j] = ColorUnderMousePointer then
          Pixels[x + i, y + j] := Color.Brush.Color;
  end;
  UpdateBmp (TRUE);
  Modified := TRUE;
end;

procedure TMainForm.Edit1Click(Sender: TObject);
  var
    map: Boolean;
begin
  map := ((Mode = mMap) and (Selection and (ClipTab.TabIndex > -1) and (clip <> nil)));
  Paste1.Enabled := ClipBoard.HasFormat (CF_BITMAP) or map;
  StretchPaste1.Enabled := ClipBoard.HasFormat (CF_BITMAP) or map;
  ScaledPaste1.Enabled := ClipBoard.HasFormat (CF_BITMAP) or map;
end;

procedure TMainForm.UseAsAlphaChannel1Click(Sender: TObject);
begin
  if Mode = mTile then
  begin
    if UseAsAlphaChannel1.Checked then
      UseAsAlphaChannel1.Checked := FALSE
    else
    begin
      UseAsAlphaChannel1.Checked := TRUE;

      AlphaBmp.Width := W;
      AlphaBmp.Height := H;
      AlphaBmp.Canvas.CopyRect (Rect (0, 0, W, H),
                   Bmp.Canvas, MakeRect (BORDER_W, BORDER_H, W, H));
      LastTileEdited := -1;
    end;

    AlphaPanel.Height := 12 + H;
    AlphaPanel.Visible := UseAsAlphaChannel1.Checked;
    AlphaPaintBox.Width := W;
    AlphaPaintBox.Height := H;

  end;
end;

procedure TMainForm.AlphaPaintBoxPaint(Sender: TObject);
  var
    i, j, k: Integer;
    x: Integer;
    rgba: Integer;
    r, g, b: Integer;
begin
  x := (AlphaPaintBox.Width - W) div 2;
  for j := 0 to H - 1 do
    for i := 0 to W - 1 do
    begin
      rgba := AlphaBmp.Canvas.Pixels[i, j];
      if (rgba <> TRANS_COLOR) then
      begin
        GetRGB (rgba, r, g, b);
        k := 255 - (r + g + b) div 3;
        AlphaPaintBox.Canvas.Pixels[x + i, j] := rgb (k, k, k);
      end
      else
        AlphaPaintBox.Canvas.Pixels[x + i, j] := AlphaPanel.Color;
    end;

end;

procedure TMainForm.ShowUsedColorPatterns1Click(Sender: TObject);
begin
  with ShowUsedColorPatterns1 do
    if not Checked then
    begin
      Checked := TRUE;

      ColorPatternsPanel.Visible := TRUE;
      MainForm.Resize;
    end
    else
    begin
      Checked := FALSE;

      ColorPatternsPanel.Visible := FALSE;
      MainForm.Resize;
    end;
  UsedPatternSelect := FALSE;
end;

procedure TMainForm.ColorPatternsImageMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
  var
    j: Integer;
begin
  if UsedPatternSelect then
    if Length (FromToSave) > 0 then
    begin
      j := Y * Length (FromToSave) div ColorPatternsImage.Height;
      FromToSavePos := j;
      SelectSavedFromToList;
      if (FromToSave[j].F = FromToSave[j].L) then
        SetColor (FromToSave[j].FT[FromToSave[j].F], False, False);
    end;
end;

procedure TMainForm.ColorPatternsImageMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if (Button = mbLeft) then
  begin
    UsedPatternSelect := TRUE;
    ColorPatternsImageMouseMove (Sender, Shift, X, Y);
  end;
end;

procedure TMainForm.ColorPatternsImageMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  var
    i, j: Integer;
begin
  if (not UsedPatternSelect) then
    if (Button = mbRight) then
      if Length (FromToSave) > 0 then
      begin
        j := Y * Length (FromToSave) div ColorPatternsImage.Height;

        for i := j + 1 to Length (FromToSave) - 1 do
          FromToSave[i - 1] := FromToSave[i];
        SetLength (FromToSave, Length (FromToSave) - 1);
        if (j >= Length (FromToSave)) then
          j := 0;

        FromToSavePos := j;
        if Length (FromToSave) > 0 then
          SelectSavedFromToList
        else
        begin
          ColorPatternsImage.Picture.Bitmap := TBitmap.Create;
          with ColorPatternsImage.Picture.Bitmap do
          begin
            Width := 1;
            Height := 1;
            Canvas.Pixels[0, 0] := ColorPatternsPanel.Color;
          end;
          ColorPatternsImage.Repaint;
          ColorPatternsImage.Refresh;
        end;
        DrawUsedFromToList;
      end;

  UsedPatternSelect := FALSE;
end;

procedure TMainForm.DoubleSize1Click(Sender: TObject);
  var
    i, j, k: Integer;
    px, py: Integer;
begin
  if Mode = mTile then
  begin
    if Clipboard.HasFormat(CF_BITMAP) then
    begin

      SaveUndo ('Scaled Paste');
      ClipBmp.Assign(Clipboard);
      ClipBmp.Canvas.Draw(0, 0, ClipBmp);

      GetTileArea ();

      for j := 0 to TileAreaH - 1 do
        for i := 0 to TileAreaW - 1 do
        begin
          px := i div 2;
          py := j div 2;
          if (px < ClipBmp.Width) and (py < ClipBmp.Height) then
          begin
            k := ClipBmp.Canvas.Pixels[px, py];
            Bmp.Canvas.Pixels[BORDER_W + i, BORDER_H + j] := k;
          end;
        end;


      UpdateBmp (TRUE);
      TileSelection.Visible := FALSE;
      Modified := TRUE;
    end;
  end;

end;

procedure TMainForm.Edit1DrawItem(Sender: TObject; ACanvas: TCanvas;
  ARect: TRect; Selected: Boolean);
begin
  Paste1.Enabled := ClipBoard.HasFormat (CF_BITMAP);
  StretchPaste1.Enabled := ClipBoard.HasFormat (CF_BITMAP);
  ScaledPaste1.Enabled := ClipBoard.HasFormat (CF_BITMAP);
end;

end.

