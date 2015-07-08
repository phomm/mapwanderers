unit UFrmMain;

interface

uses
  Windows, Messages, SysUtils,  Classes, Controls, Forms,
  Dialogs, Grids, StdCtrls, TypInfo, Graphics, UChuvak;

type
  TFrmMain = class(TForm)
    SG: TStringGrid;
    LPosition: TLabel;
    SGAbil: TStringGrid;
    procedure FormCreate(Sender: TObject);
    procedure SGDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect;
      State: TGridDrawState);
    procedure SGMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure DrawCell(ACol, ARow: Integer;  Rect: TRect);
    procedure FormDestroy(Sender: TObject);
    procedure SGAbilMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    Game: TGame;
  end;

var
  FrmMain: TFrmMain;

//------------------------------------------------------------------------------

implementation

{$R *.dfm}

procedure TFrmMain.FormCreate(Sender: TObject);
var
  I: Byte;
begin                             // here some init
  Caption := Application.Title;
  Randomize;
  SG.FixedCols := 0;
  SG.FixedRows := 0;
  SG.DefaultColWidth := SG.DefaultRowHeight;
  SG.ColCount := FieldSize;
  SG.RowCount := FieldSize;
  SGAbil.FixedCols := 0;
  SGAbil.FixedRows := 1;
  SGAbil.DefaultColWidth := SGAbil.DefaultRowHeight;
  SGAbil.ColWidths[0] := 70;
  SGAbil.ColCount := 2 + Ord(High(NMoveKind));
  SGAbil.RowCount := 2 + Ord(High(NMoveKind));
  SGAbil.Cells[0,0] := 'Priority';
  for I := Ord(Low(NMoveKind)) to Ord(High(NMoveKind)) do
    begin
      SGAbil.Cells[0, I + 1] := GetEnumName(TypeInfo(NMoveKind), I);
      SGAbil.Cells[I + 1, 0] := IntToStr(I + 1);
    end;                                                       //-----

  Game := TGame.create;                    // main game obj
  LPosition.Caption := 'Position : ' +     // write position
    GetEnumName(TypeInfo(NPosition), Ord(Game.Chuvak.Movement.Position));
end;


procedure TFrmMain.SGDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
begin
  DrawCell(ACol, ARow, Rect);
end;


procedure TFrmMain.SGMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  C, R: Integer;
begin
  SG.MouseToCell(X, Y, C, R);           // get the field-coords
  if not ((C in [0..SG.ColCount - 1]) and (R in [0..SG.RowCount - 1])) then
    Exit;
  X := Game.Chuvak.Movement.CurCell.X;  // store for redraw
  Y := Game.Chuvak.Movement.CurCell.Y;
  Game.Chuvak.Movement.CurCell := Game.Field[R, C];  // make movement, all magic is here
  DrawCell(X, Y, SG.CellRect(X, Y));  // redraw old and new cell
  DrawCell(C, R, SG.CellRect(C, R));
  LPosition.Caption := 'Position : ' +
    GetEnumName(TypeInfo(NPosition), Ord(Game.Chuvak.Movement.Position));
end;


procedure TFrmMain.DrawCell(ACol, ARow: Integer; Rect: TRect);
begin
  with Game, SG.Canvas do                    // just draw each cell
  begin                                      // filling with color of terrain
    case Field[ARow, ACol].TerType of
      ttGround: Brush.Color := clOlive;
      ttRock: Brush.Color := clGray;
      ttAir: Brush.Color := clSkyBlue;
      ttWater: Brush.Color := clBlue;
    end;
    FillRect(Rect);
    InflateRect(Rect, -2, -2);
    Brush.Color := clMaroon;
    if Chuvak.Movement.CurCell = Field[ARow, ACol] then  // and draw chuvak if he is on this cell
      SG.Canvas.Ellipse(Rect);
  end;
end;


procedure TFrmMain.SGAbilMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  C, R: Integer;
begin                              // here the jogging with priorities of abilities
  SGAbil.MouseToCell(X, Y, C, R);     // using insCast, delCast, addCast
  if (C in [1..SGAbil.ColCount]) and (R in [1..SGAbil.RowCount]) then
    if Game.Chuvak.Movement.GetMoveAbil(NMoveKind(R - 1)) = nil then
      Game.Chuvak.InsCast(C - 1, NMoveKind(R - 1))
    else
      Game.Chuvak.DelCast(NMoveKind(R - 1));
  if (C in [0]) and (R in [1..SGAbil.RowCount]) then
    if Game.Chuvak.Movement.GetMoveAbil(NMoveKind(R - 1)) = nil then
      Game.Chuvak.AddCast(NMoveKind(R - 1))
    else
      Game.Chuvak.DelCast(NMoveKind(R - 1));
  for X := 1 to SGAbil.ColCount do
    for Y := 1 to SGAbil.RowCount do
      if Game.Chuvak.Movement.GetMoveAbilInd(NMoveKind(Y - 1)) = X - 1 then
        SGAbil.Cells[X, Y] := IntToStr(X)
      else
        SGAbil.Cells[X, Y] := '';
end;


procedure TFrmMain.FormDestroy(Sender: TObject);
begin
  Game.Free;
end;

end.

