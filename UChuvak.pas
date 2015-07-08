unit UChuvak;

interface

uses
  Windows, Messages, SysUtils, Classes, Math;

const
  FieldSize = 30;

type
  // enums for work, for adding an entity - add it here and a bit code for new classes :)
  NMoveKind = (mkFly, mkWalk, mkSwim, mkTeleport, mkDig, mkClimb, mkJump);
  NTerType  = (ttGround, ttWater, ttAir, ttRock);
  NPosition = (poGround, poWater, poAir, poDigged, poClimbed);

  TCell = class;             // forward - decl-s
  TChuvMovement = class;
  TChuvak = class;
  TWalking = class;

TMoving = class(TObject)   // ancestor for abilities or kinds of movement
private
  FMoveKind: NMoveKind;
public
  function CanGo(AChuvMovt: TChuvMovement): Boolean; virtual; abstract;
  constructor Create(AMoveKind: NMoveKind);
  property MoveKind: NMoveKind read FMoveKind;
end;
                           // descendants (according to Nmovekind)
TWalking = class(TMoving)
  function CanGo(AChuvMovt: TChuvMovement): Boolean; override;
end;

TFlying = class(TMoving)
  function CanGo(AChuvMovt: TChuvMovement): Boolean; override;
end;

TSwimming = class(TMoving)
  function CanGo(AChuvMovt: TChuvMovement): Boolean; override;
end;

TDigging = class(TMoving)
  function CanGo(AChuvMovt: TChuvMovement): Boolean; override;
end;

TTeleporting = class(TMoving)
  function CanGo(AChuvMovt: TChuvMovement): Boolean; override;
end;

TClimbing = class(TMoving)
  function CanGo(AChuvMovt: TChuvMovement): Boolean; override;
end;

TJumping = class(TMoving)
  function CanGo(AChuvMovt: TChuvMovement): Boolean; override;
end;    

TPosition = class(TObject)   // ancestor for positions
private
  FPosition: NPosition ;
public                    // the allowchange has curCell, destCell - not used now, but for future
  function AllowChange(CurCell, DestCell: TCell; Dist: Integer; NewPos: TPosition): Boolean; virtual; abstract;
  constructor Create(APosition: NPosition);
  property Position: NPosition  read FPosition ;
end;
                              // position's descendants (according Nposition)
TPosGround = class(TPosition)
  function AllowChange(CurCell, DestCell: TCell; Dist: Integer; NewPos: TPosition): Boolean; override;
end;

TPosWater = class(TPosition)
  function AllowChange(CurCell, DestCell: TCell; Dist: Integer; NewPos: TPosition): Boolean; override;
end;

TPosAir = class(TPosition)
  function AllowChange(CurCell, DestCell: TCell; Dist: Integer;  NewPos: TPosition): Boolean; override;
end;

TPosClimbed = class(TPosition)
  function AllowChange(CurCell, DestCell: TCell; Dist: Integer; NewPos: TPosition): Boolean; override;
end;

TPosDigged = class(TPosition)
  function AllowChange(CurCell, DestCell: TCell; Dist: Integer; NewPos: TPosition): Boolean; override;
end;

TPositionClass = class of TPosition;   // class ref-s

TMovingClass = class of TMoving;

TMovingList = class(TList)            // list for convienience and easy priority - functions
private
  FOwnsObjects: Boolean;
protected
  function Get(Index: Integer): TMoving;
  procedure Put(Index: Integer; const Value: TMoving);
public                                 
  constructor Create(AOwnsObjects: Boolean = False);
  property Items[Index: Integer]: TMoving read Get write Put; default;
  function GetMoving(AMoving: NMoveKind): TMoving;  // searching method
  destructor Destroy; override;
end;

TMovingMgr = class(TObject)    // manager for all class-work to be in 1 place
private
  MovingClasses: array[Low(NMoveKind)..High(NMoveKind)] of TMovingClass;
  Movings: TMovingList;
  PositionClasses: array[Low(NPosition)..High(NPosition)] of TPositionClass;
  Positions: array[Low(NPosition)..High(NPosition)] of TPosition;
  TerTypeToPos: array[Low(NTerType)..High(NTerType)] of NPosition;
public
  constructor Create;
  destructor Destroy; override;
  procedure Add(AMoving: TMoving);
  function GetMoving(AMoving: NMoveKind): TMoving;  // 3 searching methods
  function GetPosByTerType(ATerType: NTerType): TPosition;
  function GetPosition(APos: NPosition): TPosition;
end;

//below are "game classes", most taken from other projects and cut
//------------------------------------------------------------------------------
TCellInt = Byte; // adapter for making all changes to map-sizing

TCell = class(TObject)   // field-cell class
private
  FX, FY: TCellInt;
  FTerType: NTerType;
public
  constructor Create(AY, AX: TCellInt; ATerType: NTerType);
  function Distance(ACell: TCell): TCellInt;   // just 1 method for distance between cells
  property X: TCellInt read FX;
  property Y: TCellInt read FY;
  property TerType: NTerType read FTerType;
end;

FieldCellar = array of array of TCell;

TField = class(TObject)            // field-class
private
  FHeight, FWidth: TCellInt;
  FField: FieldCellar;
  function GetHeight: TCellInt;
  function GetWidth: TCellInt;
  function GetCell(AY, AX: TCellInt): TCell;
  procedure SetCell(AY, AX: TCellInt; ACell: TCell);
public
  procedure ClearMap;
  property Field [Row: TCellInt; Column: TCellInt]: TCell read GetCell write SetCell; default;
  property Width: TCellInt read GetWidth;
  property Height: TCellInt read GetHeight;
  constructor Create(AHeight, AWidth: TCellInt);
  procedure RandomFill(Factor: Byte = 1);    // 1 method for generating map
  destructor Destroy; override;
  end;

TGame = class;

TChuvMovement = class(TObject)       // all work is almost here
private
  FCurCell, FDestCell: TCell;   //
  FPosition: TPosition;          // just for storing pointers, not owning them
  FChuvak: TChuvak;             //
  FMoveAbility: TMovingList;
  function AllowPosChange(NewPos: NPosition): Boolean; // 2 flexible callers
  function CanGo(ACell: TCell): Boolean;              // they do magic
  function GetPosition: NPosition;
  function IsValidPosition: Boolean; // validator with assert
  procedure AddMoveAbil(const Value: NMoveKind);                 // abilities
  procedure DelMoveAbil(const Value: NMoveKind);                 // jogging
  procedure InsMoveAbil(Priority: Integer; const Value: NMoveKind); // methods
  procedure SetCurCell(const Value: TCell);   // start of all-work
  procedure SetPosition(const Value: NPosition);
public
  constructor Create(AChuvak: TChuvak; ACell: TCell);
  destructor Destroy; override;
  function Game: TGame;  // for calling manager
  function GetMoveAbil(AMoveKind: NMoveKind): TMoving;     // ability-presence
  function GetMoveAbilInd(AMoveKind: NMoveKind): Integer;  // checkers
  function MoveAbilCount: Integer;
  property CurCell: TCell read FCurCell write SetCurCell;
  property DestCell: TCell read FDestCell;
  property Position: NPosition read GetPosition write SetPosition;
end;

TChuvak = class(TObject)
private
  FGame: TGame;
public
  // chuvak uses movement for the task of moving, it has no other tasks in this demo
  Movement: TChuvMovement;
  constructor Create(ACell: TCell; AGame: TGame);
  destructor Destroy; override;
  procedure AddCast(AMoveKind: NMoveKind);                 // adapters for methods of movement
  procedure InsCast(Priority: Byte; AMoveKind: NMoveKind); //
  procedure DelCast(AMoveKind: NMoveKind);                 //
  property Game: TGame read FGame;
end;

TGame = class(TObject)        // just collects all together
  Chuvak: TChuvak;
  Field: tfield;
  MovingMgr: TMovingMgr;
  constructor Create;
  destructor Destroy; override;
end; 

implementation

//------------------------------------------------------------------------------

{ TChuvak }

procedure TChuvak.AddCast(AMoveKind: NMoveKind);
begin
  Movement.AddMoveAbil(AMoveKind);
end;

procedure TChuvak.InsCast(Priority: Byte; AMoveKind: NMoveKind);
begin
  Movement.InsMoveAbil(Priority, AMoveKind);
end;

procedure TChuvak.DelCast(AMoveKind: NMoveKind);
begin
  Movement.DelMoveAbil(AMoveKind);
end;

constructor TChuvak.Create(ACell: TCell; AGame: TGame);
begin
  inherited Create;
  FGame := AGame;
  Movement := TChuvMovement.Create(Self, ACell);
end;

destructor TChuvak.Destroy;
begin
  Movement.Free;
  FGame := nil;
  inherited;
end;

{ TGame }

constructor TGame.Create;
begin
  MovingMgr := TMovingMgr.Create;
  Field := TField.Create(FieldSize, FieldSize);
  Chuvak := TChuvak.Create(Field[15, 15], Self); // create chuvak only after field!
end;

destructor TGame.Destroy;
begin
  FreeAndNil(Chuvak);
  FreeAndNil(Field);
  FreeAndNil(MovingMgr);
  inherited;
end;

//------------------------------------------------------------------------------   movings

{ TMoving }

constructor TMoving.Create(AMoveKind: NMoveKind);
begin
  FMoveKind := AMoveKind;
end;

{ Twalking }       // 7 cango functions for real flexible calc of "going possibility"

function TWalking.CanGo(AChuvMovt: TChuvMovement): Boolean;
begin
  Result := (AChuvMovt.DestCell.TerType = ttGround) and AChuvMovt.AllowPosChange(poGround);
end;

{ Tflying }

function TFlying.CanGo(AChuvMovt: TChuvMovement): Boolean;
begin
  Result := AChuvMovt.AllowPosChange(poAir);
end;

{ Tswiming }

function TSwimming.CanGo(AChuvMovt: TChuvMovement): Boolean;
begin
  Result := (AChuvMovt.DestCell.TerType = ttWater) and AChuvMovt.AllowPosChange(poWater);
end;

{ Tdigging }

function TDigging.CanGo(AChuvMovt: TChuvMovement): Boolean;
begin
  Result := (AChuvMovt.DestCell.TerType = ttGround) and AChuvMovt.AllowPosChange(poDigged);
end;

{ Tteleporting }

function TTeleporting.CanGo(AChuvMovt: TChuvMovement): Boolean;
begin
  Result := AChuvMovt.CurCell.Distance(AChuvMovt.DestCell) > 0;   // can teleport everywhere wihout changing Position
end;

{ Tclimbing }

function TClimbing.CanGo(AChuvMovt: TChuvMovement): Boolean;
begin
  Result := (AChuvMovt.DestCell.TerType = ttRock) and AChuvMovt.AllowPosChange(poClimbed);
end;

{ Tjumping }

function TJumping.CanGo(AChuvMovt: TChuvMovement): Boolean;
begin
  Result := not (AChuvMovt.CurCell.TerType in [ttAir, ttwater])   // can jump over 1 cell
    and (AChuvMovt.CurCell.Distance(AChuvMovt.DestCell) = 2)      // on the same terrain
    and (AChuvMovt.CurCell.TerType = AChuvMovt.DestCell.TerType); // which is now on, except air, water
end;

//------------------------------------------------------------------------------  positions

{ TPosition }

constructor TPosition.Create(APosition: NPosition);
begin
  inherited Create;
  FPosition := APosition;
end;


{ TPosGround }        // 5 "allowchange position" methods for exact rules of demo

function TPosGround.AllowChange(CurCell, DestCell: TCell; Dist: Integer; NewPos: TPosition): Boolean;
begin
  Result := ((NewPos.FPosition in [poGround, poClimbed, poWater]) and (Dist in [1])) or
            ((NewPos.FPosition in [poAir, poDigged]) and (Dist in [0, 1]));
end;

{ TPosWater }

function TPosWater.AllowChange(CurCell, DestCell: TCell; Dist: Integer; NewPos: TPosition): Boolean;
begin
  Result := ((NewPos.FPosition in [poGround, poClimbed, poWater, poDigged]) and (Dist in [1])) or
            ((NewPos.FPosition in [poAir]) and (Dist in [0, 1]));
end;

{ TPosAir }

function TPosAir.AllowChange(CurCell, DestCell: TCell; Dist: Integer; NewPos: TPosition): Boolean;
begin
  Result := ((NewPos.FPosition in [poGround, poClimbed, poWater]) and (Dist in [0, 1])) or
        ((NewPos.FPosition in [poAir]) and (Dist in [1]));
end;
{ TPosClimbed }

function TPosClimbed.AllowChange(CurCell, DestCell: TCell; Dist: Integer; NewPos: TPosition): Boolean;
begin
  Result := ((NewPos.FPosition in [poGround, poClimbed, poWater]) and (Dist in [1])) or
            ((NewPos.FPosition in [poAir]) and (Dist in [0, 1]));
end;

{ TPosDigged }

function TPosDigged.AllowChange(CurCell, DestCell: TCell; Dist: Integer; NewPos: TPosition): Boolean;
begin
  Result := ((NewPos.FPosition in [poGround]) and (Dist in [0, 1])) or
            ((NewPos.FPosition in [poWater, poDigged]) and (Dist in [1]));
end;

//------------------------------------------------------------------------------    field-specific

{ tCell }

constructor TCell.Create(AY, AX: TCellInt; ATerType: NTerType);
begin
  FX := AX;
  FY := AY;
  FTerType := ATerType;
end;

function TCell.Distance(ACell: TCell): TCellInt;
begin
  Result := Max(Max(X, ACell.X) - Min(X, ACell.X), Max(Y, ACell.Y) - Min(Y, ACell.Y));
end;

{ TField }

procedure Tfield.ClearMap;
var
  I, J: Word;
begin
  I := 0;
  while I < Height do
  begin
    J := 0;
    while J < Width do
    begin
      FreeAndNil(FField[I, J]);
      Inc(J);
    end;
    Inc(I);
  end;
end;

constructor TField.Create(AHeight, AWidth: TCellInt);
begin
  Assert((AHeight <> 0) and (AWidth <> 0), 'Creating empty field!');
  SetLength(FField, AHeight, AWidth);
  FHeight := AHeight;
  FWidth := AWidth;
  RandomFill(5);
end;

destructor TField.Destroy;
begin
  ClearMap;
  inherited;
end;

function TField.GetCell(AY, AX: TCellInt): TCell;
begin
  if (AY < Height) and (AX < Width)then
    Result := FField[AY, AX]
  else Result := nil;
  Assert(Result <> nil, 'out of the field');
end;

function TField.GetHeight: TCellInt;
begin
  Result := FHeight;
end;      

function Tfield.GetWidth: TCellInt;
begin
  Result := FWidth;
end;

procedure TField.RandomFill(Factor: Byte);
var
  wd, hg: Cardinal;
  ter, old: NTerType;
begin
  old := ttGround;
  for wd := 0 to Width -1 do
    for hg := 0 to Height -1 do
    begin
      ter := NTerType(Random(Factor + Ord(High(NTerType)))); // a trick to imitate generating
      if ter > High(NTerType) then                           // a map instead of randomizing
        ter := old;                                            //
      old := ter;                                              //
      FField[hg, wd] := TCell.Create(hg, wd, ter);
    end;
end;

procedure TField.SetCell(AY, AX: TCellInt; ACell: TCell);
begin
  FField[AY,AX].Free;
  FField[AY,AX] := ACell;
end;
//------------------------------------------------------------------------------

{ TMovingMgr }

procedure TMovingMgr.Add(AMoving: TMoving);
begin
  Movings.Add(AMoving);
end;

function TMovingMgr.GetPosByTerType(ATerType: NTerType): TPosition;
begin
  Result := Positions[TerTypeToPos[ATerType]];
end;

constructor TMovingMgr.Create;
var
  I: NMoveKind;
  J: NPosition;
begin
  inherited;
  TerTypeToPos[ttGround]    := poGround;    // just kind of translating
  TerTypeToPos[ttWater]     := poWater;
  TerTypeToPos[ttAir]       := poAir;
  TerTypeToPos[ttRock]      := poClimbed;

  MovingClasses[mkWalk]     := TWalking;      // assigning class references
  MovingClasses[mkFly]      := TFlying;
  MovingClasses[mkSwim]     := TSwimming;
  MovingClasses[mkDig]      := TDigging;
  MovingClasses[mkTeleport] := TTeleporting;
  MovingClasses[mkClimb]    := TClimbing;
  MovingClasses[mkJump]     := TJumping;

  Movings := TMovingList.Create(True);
  for I := Low(NMoveKind) to High(NMoveKind) do
    if MovingClasses[I] = nil then
      raise EInvalidOperation.Create('Not all MovingClasses assigned')
    else
      Add(MovingClasses[I].Create(I)); // creating a list of abilities
                                        // the only instance of them in demo is here
  PositionClasses[poGround]  := TPosGround;   // same for positions
  PositionClasses[poWater]   := TPosWater;
  PositionClasses[poAir]     := TPosAir;
  PositionClasses[poDigged]  := TPosDigged;
  PositionClasses[poClimbed] := TPosClimbed;

  for J := Low(NPosition) to High(NPosition) do
    if PositionClasses[J] = nil then
      raise EInvalidOperation.Create('Not all PositionClasses assigned')
    else
      Positions[J]:= PositionClasses[J].Create(J);
end;

destructor TMovingMgr.Destroy;
var
  I: NPosition;
begin
  for I := Low(NPosition) to High(NPosition) do
    Positions[I].Free;
  Movings.Free;
  inherited;
end;     

function TMovingMgr.GetMoving(AMoving: NMoveKind): TMoving;
begin
  Result := Movings.GetMoving(AMoving);
end;

function TMovingMgr.GetPosition(APos: NPosition): TPosition;
begin
  Result := Positions[APos];
end;

{ TMovingList }

function TMovingList.Get(Index: Integer): TMoving;
begin
  Result := TMoving(inherited Get(Index));
end;

procedure TMovingList.Put(Index: Integer; const Value: TMoving);
begin
  inherited Put(Index,Value);
end;

function TMovinglist.GetMoving(AMoving: NMoveKind): TMoving;
var
  I: Integer;
begin
  Result := nil;
  I := 0;
  try
    while I < Count do
    if Items[I].MoveKind = AMoving then
    begin
      Result := Items[I];
      Break;
    end
    else
      Inc(I);
  except
  end;
end;     

destructor TMovingList.Destroy;
var
  I: Integer;
begin
  if Count <> 0  then
    for I := Count - 1 downto 0 do
    begin
      if FOwnsObjects then
        Items[I].Free;
      Delete(I);
    end;
  inherited;
end;

constructor TMovingList.Create(AOwnsObjects: Boolean = False);
begin
  inherited Create;
  FOwnsObjects := AOwnsObjects;
end;

{ TChuvMovement }

constructor TChuvMovement.Create(AChuvak: TChuvak; ACell: TCell);
begin
  FCurCell := ACell;
  FChuvak := AChuvak;
  FPosition := Game.MovingMgr.GetPosByTerType(ACell.TerType);
  FMoveAbility := TMovingList.Create;
end;

function TChuvMovement.Game: TGame;
begin
  Result := FChuvak.Game;
end;

function TChuvMovement.CanGo(ACell: TCell): Boolean;
var
  I: Integer;
begin
  Result := False;
  I := 0;
  while I < MoveAbilCount do
  begin
    Result := FMoveAbility[I].CanGo(Self);
    if Result then
      Exit;
    Inc(I);
  end;
end;

function TChuvMovement.GetPosition: NPosition;
begin
  IsValidPosition;
  Result := FPosition.Position;
end;

procedure TChuvMovement.SetCurCell(const Value: TCell);
begin
  FDestCell := Value;
  if CanGo(Value) then
    FCurCell := Value;
end;      

procedure TChuvMovement.SetPosition(const Value: NPosition);
begin
  FPosition := Game.MovingMgr.Positions[Value];
end;

function TChuvMovement.IsValidPosition: Boolean;
begin
  Result := FPosition <> nil;
  Assert(Result, 'We missed Position of Chuvak');
end;


function TChuvMovement.AllowPosChange(NewPos: NPosition): Boolean;
begin
  Result := FPosition.AllowChange(CurCell, DestCell, CurCell.Distance(DestCell),
    Game.MovingMgr.GetPosition(NewPos));
  if Result then
    Position := NewPos;
end;

function TChuvMovement.GetMoveAbil(AMoveKind: NMoveKind): TMoving;
begin
  Result := FMoveAbility.GetMoving(AMoveKind);
end;

procedure TChuvMovement.AddMoveAbil(const Value: NMoveKind);
begin
  if GetMoveAbil(Value) = nil then
    FMoveAbility.Add(Game.MovingMgr.GetMoving(Value));
end;

function TChuvMovement.MoveAbilCount: Integer;
begin
  Result := FMoveAbility.Count;
end;

destructor TChuvMovement.Destroy;
begin
  FreeAndNil(FMoveAbility); // we own it, so freeing
  FCurCell := nil;          // we don't own, so just clear
  FDestCell := nil;         //
  FChuvak := nil;           //
  FPosition := nil;         //
  inherited;
end;

procedure TChuvMovement.DelMoveAbil(const Value: NMoveKind);
var
  I: Integer;
begin
  I := 0;
  while I < MoveAbilCount do
    if FMoveAbility[I].FMoveKind = Value then
    begin
      FMoveAbility.Delete(I);
      Break;
    end
    else
      Inc(I);
end;

procedure TChuvMovement.InsMoveAbil(Priority: Integer; const Value: NMoveKind);
begin
  if (MoveAbilCount = 0) or not (Priority in [0..MoveAbilCount - 1]) then
    Exit;
  DelMoveAbil(Value);
  FMoveAbility.Insert(Priority, Game.MovingMgr.GetMoving(Value));
end;

function TChuvMovement.GetMoveAbilInd(AMoveKind: NMoveKind): Integer;
var
  I: Integer;
begin
  Result := -1;
  I := 0;
  while I < MoveAbilCount do
    if FMoveAbility[I].FMoveKind = AMoveKind then
    begin
      Result := I;
      Break;
    end
    else
      Inc(I);
end;

end.
