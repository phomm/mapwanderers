unit UfrmMain;

interface

uses
  Windows, Messages, SysUtils,  Classes,  Controls, Forms,
  Dialogs, Grids, StdCtrls, typinfo, graphics, Uchuvak;

type
  TFrmMain = class(TForm)
    SG: TStringGrid;
    LPosition: TLabel;
    SGabil: TStringGrid;
    procedure FormCreate(Sender: TObject);
    procedure SGDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect;
      State: TGridDrawState);
    procedure SGMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure drawCell(ACol, ARow: Integer;  Rect: TRect);
    procedure FormDestroy(Sender: TObject);
    procedure SGabilMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    game : tgame;
  end;

var
  FrmMain: TFrmMain;

//------------------------------------------------------------------------------

implementation

{$R *.dfm}

procedure TFrmMain.FormCreate(Sender: TObject);
var
  i : byte;
begin                                                          // here some init
  caption := application.title;
  Randomize;
  SG.FixedCols := 0;
  SG.FixedRows := 0;
  SG.DefaultColWidth := SG.DefaultRowHeight;
  SG.ColCount := fieldsize;
  SG.RowCount := fieldsize;
  SGabil.FixedCols := 0;
  SGabil.FixedRows := 1;
  SGabil.DefaultColWidth := SGabil.DefaultRowHeight;
  sgabil.ColWidths[0] := 70;
  SGabil.ColCount := 2+ Ord(High(nMovekind));
  SGabil.RowCount := 2+ Ord(High(nMovekind));
  SGabil.cells[0,0] := 'Priority';
  for i := Ord(Low(nMovekind)) to Ord(High(nMovekind)) do
    begin
    SGabil.cells[0,i+1] := getenumname(TypeInfo(nMovekind), i);
    SGabil.cells[i+1,0] := IntToStr(i+1)
    end;                                                       //-----

  game := tgame.create;                    // main game obj
  LPosition.Caption := 'Position : ' +     // write position
    GetEnumName(TypeInfo(nPosition), Ord(game.Chu.Movement.Position));
end;


procedure TFrmMain.SGDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
begin
  drawCell(ACol, ARow,  Rect)
end;


procedure TFrmMain.SGMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  c,r : Integer;
begin
  sg.MouseToCell(x,y,c,r);           // get the field-coords
  if not ((c in [0..SG.ColCount-1]) and (r in [0..SG.RowCount-1])) then
    exit;
  x := game.Chu.Movement.curCell.x;  // store for redraw
  y := game.Chu.Movement.curCell.y;
  game.Chu.Movement.curCell := game.field[r,c];  // make movement, all magic is here
  drawCell(x, y, SG.CellRect(x,y));  // redraw old and new cell
  drawCell(c, r, SG.CellRect(c,r));
  LPosition.Caption := 'Position : ' +
    GetEnumName(TypeInfo(nPosition), Ord(game.Chu.Movement.Position));
end;


procedure TFrmMain.drawCell(ACol, ARow: Integer; Rect: TRect);
begin
  with game, SG.Canvas do                    // just draw each cell
  begin                                      // filling with color of terrain
    case field[ARow, ACol].tertype of
      ttGround : Brush.Color := clOlive;
      ttrock : Brush.Color := clGray;
      ttair : Brush.Color := clSkyBlue;
      ttwater : Brush.Color := clBlue;
      end;
    FillRect(rect);
    InflateRect(Rect, -2,-2);
    Brush.Color := clMaroon;
    if (Chu.Movement.curCell = field[ARow, ACol]) then  // and draw chuvak if he is on this cell
      sg.Canvas.Ellipse(rect);
  end;
end;


procedure TFrmMain.SGabilMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  c, r : integer;
begin                              // here the jogging with priorities of abilities
  SGabil.MouseToCell(x,y,c,r);     // using insCast, delCast, addCast
  if (c in [1..sgabil.ColCount]) and (r in [1..sgabil.RowCount]) then
    if game.Chu.Movement.getmoveabil(nmovekind(r-1)) = nil then
      game.Chu.insCast(c-1, nmovekind(r-1))
    else game.Chu.delCast(nmovekind(r-1));
  if (c in [0]) and (r in [1..sgabil.RowCount]) then
    if game.Chu.Movement.getmoveabil(nmovekind(r-1)) = nil then
      game.Chu.AddCast(nmovekind(r-1))
    else game.Chu.delCast(nmovekind(r-1));
  for x := 1 to sgabil.ColCount do
    for y := 1 to sgabil.rowCount do
      if game.Chu.Movement.getmoveabilind(nmovekind(y-1)) = x-1 then
        SGabil.Cells[x,y] := IntToStr(x)
      else SGabil.Cells[x,y] := '';
end;


procedure TFrmMain.FormDestroy(Sender: TObject);
begin
  game.Free;
end;

end.

