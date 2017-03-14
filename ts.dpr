program TS;

  { TILE STUDIO

    Web site:    http://tilestudio.sourceforge.net/

    Written by:  Mike Wiering, University of Nijmegen
    E-mail:      mike@wieringsoftware.nl

    This program is free software; you can redistribute it and/or
    modify it under the terms of the GNU General Public License as
    published by the Free Software Foundation; either version 2 of the
    License, or (at your option) any later version.  See the file
    COPYING included with this distribution for more information.
  }

uses
  Forms,
  Main in 'Main.pas' {MainForm},
  Tiles in 'Tiles.pas',
  Import in 'Import.pas' {ImportTiles},
  About in 'About.pas' {AboutForm},
  Create in 'Create.pas' {NewForm},
  TileCopy in 'TileCopy.pas' {CopyTilesForm},
  MCEdit in 'MCEdit.pas' {MapCode},
  CGSettings in 'CGSettings.pas' {CodeGen},
  SelectDir in 'SelectDir.pas' {OutputDir},
  Export in 'Export.pas' {ExportTiles},
  Scroll in 'Scroll.pas' {MapScroll},
  Calc in 'Calc.pas',
  PalMan in 'PalMan.pas' {PaletteManager},
  ImpPovAni in 'ImpPovAni.pas' {PovAni},
  InfoForm in 'InfoForm.pas' {Lists},
  ListsForm in 'ListsForm.pas' {Lists},
  ReplaceColors in 'ReplaceColors.pas' {Replace},
  Settings in 'Settings.pas' {SettingsForm},
  RGBConvForm in 'RGBConvForm.pas' {RGBConv};

{$R *.RES}

begin
  Application.Initialize;
  Application.Title := 'Tile Studio';
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TOutputDir, OutputDir);
  Application.CreateForm(TExportTiles, ExportTiles);
  Application.CreateForm(TMapScroll, MapScroll);
  Application.CreateForm(TPaletteManager, PaletteManager);
  Application.CreateForm(TPovAni, PovAni);
  Application.CreateForm(TInfo, Info);
  Application.CreateForm(TLists, Lists);
  Application.CreateForm(TReplace, Replace);
  Application.CreateForm(TSettingsForm, SettingsForm);
  Application.CreateForm(TRGBConv, RGBConv);
  Application.Icon := MainForm.Icon;
  Application.CreateForm(TImportTiles, ImportTiles);
  Application.CreateForm(TAboutForm, AboutForm);
  Application.CreateForm(TNewForm, NewForm);
  Application.CreateForm(TCopyTilesForm, CopyTilesForm);
  Application.CreateForm(TMapCode, MapCode);
  Application.CreateForm(TCodeGen, CodeGen);
  Application.Run;
end.
