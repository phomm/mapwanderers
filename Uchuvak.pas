unit Uchuvak;

interface

uses
  Windows, Messages, SysUtils, Classes, math;

const
  fieldsize = 30;

type
  // enums for work, for adding an entity - add it here and a bit code for new classes :)
  NMoveKind = (mkFly, mkWalk, mkSwim, mkTeleport, mkDig, mkclimb, mkjump);
  NTerType  = (ttGround, ttWater, ttAir, ttrock);
  NPosition = (poGround, powater, poair, podigged, poclimbed);

  tCell = class;             // forward - decl-s
  tChuvmovement = class;
  tChuvak = class;
  Twalking = class;

TMoving = class (TObject)   // ancestor for abilities or kinds of movement
private
  fMoveKind : NMoveKind;
public
  function CanGo(aChuvmovt : tChuvmovement): Boolean; virtual; abstract;
  constructor Create(aMoveKind: NMoveKind);
  property Movekind : NMovekind read fMoveKind;
end;
                           // descendants (according to Nmovekind)
Twalking = class (TMoving)
  function CanGo(aChuvmovt : tChuvmovement): Boolean;  override;
end;

Tflying = class (TMoving)
  function CanGo(aChuvmovt : tChuvmovement): Boolean;  override;
end;

Tswimming = class (TMoving)
  function CanGo(aChuvmovt : tChuvmovement): Boolean;  override;
end;

Tdigging = class (TMoving)
  function CanGo(aChuvmovt : tChuvmovement): Boolean;  override;
end;

Tteleporting = class (TMoving)
  function CanGo(aChuvmovt : tChuvmovement): Boolean;  override;
end;

Tclimbing = class (TMoving)
  function CanGo(aChuvmovt : tChuvmovement): Boolean;  override;
end;

Tjumping = class (TMoving)
  function CanGo(aChuvmovt : tChuvmovement): Boolean;  override;
end;


TPosition = class (TObject)   // ancestor for positions
private
  fPosition : NPosition ;
public                    // the allowchange has curCell, destCell - not used now, but for future
  function allowchange(curCell, destCell: tCell; dist : Integer; newPos : TPosition): Boolean; virtual; abstract;
  constructor Create(aPosition: NPosition);
  property Position : NPosition  read FPosition ;
end;
                              // position's descendants (according Nposition)
TPosGround = class (TPosition)
  function allowchange(curCell, destCell: tCell; dist : Integer; newPos : TPosition): Boolean; override;
end;

TPosWater = class (TPosition)
  function allowchange(curCell, destCell: tCell; dist : Integer; newPos : TPosition): Boolean; override;
end;

TPosAir = class (TPosition)
  function allowchange(curCell, destCell: tCell; dist : Integer;  newPos : TPosition): Boolean; override;
end;

TPosClimbed = class (TPosition)
  function allowchange(curCell, destCell: tCell; dist : Integer; newPos : TPosition): Boolean; override;
end;

TPosDigged = class (TPosition)
  function allowchange(curCell, destCell: tCell; dist : Integer; newPos : TPosition): Boolean; override;
end;

tPositionclass = class of TPosition;   // class ref-s

tMovingclass = class of tMoving;

TMovingList = class (TList)            // list for convienience and easy priority - functions
private
  fownsobbjects: Boolean;
protected
  function Get(index: integer): tMoving;
  procedure put(index: integer; const Value: tMoving);
public                                 // 2 constructors
  constructor create (); overload;     // for NOT owning objects
  constructor create (aownsobbjects: Boolean); overload; // for owning
  property items[index: integer] : tMoving  read Get write put; default;
  function getMoving(aMoving : nMovekind): TMoving;  // searching method
  destructor destroy(); override;
end;

TMovingMgr = class (TObject)    // manager for all class-work to be in 1 place
private
  Movingclsar : array[Low(nMovekind) .. High(nMovekind)] of tMovingclass ;
  Movings : TMovingList ;
  Positionclsar : array[Low(nPosition) .. High(nPosition)] of tPositionclass ;
  Positionar : array[Low(nPosition) .. High(nPosition)] of tPosition ;
  tertypetoPos : array[Low(NTerType) .. High(NTerType)] of nPosition;
public
  constructor create ();
  destructor destroy (); override;
  procedure add (aMoving : tMoving);
  function getMoving(aMoving : nMovekind): TMoving;  // 3 searching methods
  function getPosbytertype (att: Ntertype): TPosition;
  function getPosition (apos: NPosition): TPosition;
end;

//below are "game classes", most taken from other projects and cut
//------------------------------------------------------------------------------
tCellint = Byte; // adapter for making all changes to map-sizing

tCell = class (TObject)   // field-cell class
private
  fx, fy : tCellint;
  ftertype: NTerType;
public
  constructor create (ay, ax : tCellint; atertype : NTerType);
  function distance (aCell : tCell) : tCellint;   // just 1 method for distance between cells
  property x : tCellint read fx;
  property y : tCellint read fy;
  property tertype : Ntertype read fTertype;
end;

fieldCellar = array of array of TCell;

TField = class            // field-class
private
  fheight, fwidth : tCellint;
  ffield : fieldCellar;
  function getheight: tCellint;
  function getwidth: tCellint;
  function getCell(ay, ax : tCellint): tCell;
  procedure setCell(ay, ax : tCellint; aCell : tCell);
public
  procedure clearmap;
  property Field [row : tCellint ; column : tCellint] : tCell read getCell write setCell ; default ;
  property width : tCellint read getwidth ;
  property height : tCellint read getheight ;
  constructor create (aheight, awidth : tCellint);
  procedure randomfill(fact: byte = 1);    // 1 method for generating map
  destructor destroy () ; override;
  end;


Tgame = class;

TChuvMovement = class       // all work is almost here
private
  fcurCell, fdestcell : tCell;   //
  FPosition: TPosition;          // just for storing pointers, not owning them
  fChuvak : tChuvak;             //
  fMoveability : TMovingList;
  function allowposchange(newpos: NPosition) : Boolean; // 2 flexible callers
  function cango(aCell : tCell) : Boolean;              // they do magic
  function GetPosition: NPosition;
  function isValidPosition(): Boolean; // validator with assert
  procedure addmoveabil(const Value: NMoveKind);                 // abilities
  procedure delmoveabil(const Value: NMoveKind);                 // jogging
  procedure insmoveabil(prio : Integer; const Value: NMoveKind); // methods
  procedure SetcurCell(const Value: tCell);   // start of all-work
  procedure SetPosition(const Value: NPosition);
public
  constructor create (aChuv : tChuvak; aCell : tCell);
  destructor destroy (); override;
  function game : tgame;  // for calling manager
  function getmoveabil(aMoveKind: NMoveKind): TMoving;     // ability-presence
  function getmoveabilind(aMoveKind: NMoveKind): integer;  // checkers
  function MoveabilCount : Integer ;
  property curCell : tCell read FcurCell write SetcurCell;
  property destCell : tCell read FdestCell;
  property Position : NPosition read GetPosition write SetPosition;
end;

tChuvak = class (TObject)
private
  fgame : Tgame;
public
  // chuvak uses movement for the task of moving, it has no other tasks in this demo
  Movement : TChuvMovement;    
  constructor create (aCell : tCell; agame : tgame);
  destructor destroy (); override;
  procedure AddCast (aMovekind : NMoveKind);              // adapters for methods of movement
  procedure insCast (prio : Byte; aMovekind : NMoveKind); //
  procedure delCast (aMovekind : NMoveKind);              //
  property game : tgame read fgame;
end;

tgame = class (TObject)        // just collects all together
  Chu : tChuvak;
  field : tfield;
  MovingMgr : TMovingMgr;
  constructor create ();
  destructor destroy (); override;
end;


implementation

//------------------------------------------------------------------------------

{ tChuvak }


procedure tChuvak.AddCast(aMovekind: NMoveKind);
begin
  Movement.addmoveabil(aMovekind)
end;

procedure tChuvak.insCast(prio: Byte; aMovekind: NMoveKind);
begin
  Movement.insmoveabil(prio, aMovekind)
end;

procedure tChuvak.DelCast(aMovekind: NMoveKind);
begin
  Movement.DelMoveabil(aMovekind)
end;

constructor tChuvak.create(aCell : tCell; agame : tgame);
begin
  inherited create;
  fgame := agame;
  Movement := TChuvMovement.create(Self, aCell);
end;

destructor tChuvak.destroy;
begin
  Movement.Free;
  fgame := nil;
    inherited;
end;


{ tgame }

constructor tgame.create;
begin
  MovingMgr := TMovingMgr.create;
  field := tfield.create(fieldsize, fieldsize);
  Chu := tChuvak.create(field[15,15], self); // create chuvak only after field!
end;

destructor tgame.destroy;
begin
  FreeAndNil(Chu);
  FreeAndNil(field);
  FreeAndNil(MovingMgr);
  inherited;
end;

//------------------------------------------------------------------------------   movings

{ TMoving }


constructor TMoving.create(aMoveKind: NMoveKind);
begin
  fMoveKind := aMoveKind
end;

{ Twalking }       // 7 cango functions for real flexible calc of "going possibility"

function Twalking.CanGo(aChuvmovt : tChuvmovement): Boolean;
begin
  result := (aChuvmovt.destCell.TerType = ttGround) and aChuvmovt.allowposchange(poGround);
end;

{ Tflying }

function Tflying.CanGo(aChuvmovt : tChuvmovement): Boolean;
begin
  result := aChuvmovt.allowposchange(poair);
end;

{ Tswiming }

function Tswimming.CanGo(aChuvmovt : tChuvmovement): Boolean;
begin
result := (aChuvmovt.destCell.TerType = ttwater)and aChuvmovt.allowposchange(powater);
end;

{ Tdigging }

function Tdigging.CanGo(aChuvmovt : tChuvmovement): Boolean;
begin
result := (aChuvmovt.destCell.TerType = ttGround) and aChuvmovt.allowposchange(podigged);
end;


{ Tteleporting }

function Tteleporting.CanGo(aChuvmovt : tChuvmovement): Boolean;
begin
result := (aChuvmovt.curCell.distance(aChuvmovt.destCell) > 0);   // can teleport everywhere wihout changing Position
end;


{ Tclimbing }

function Tclimbing.CanGo(aChuvmovt : tChuvmovement): Boolean;
begin
result := (aChuvmovt.destCell.TerType = ttrock) and aChuvmovt.allowposchange(poclimbed);
end;


{ Tjumping }

function Tjumping.CanGo(aChuvmovt: tChuvmovement): Boolean;
begin
  result := not (aChuvmovt.curCell.tertype in [ttAir, ttwater])   // can jump over 1 cell
    and (aChuvmovt.curCell.distance(aChuvmovt.destCell) = 2)      // on the same terrain
    and (aChuvmovt.curCell.tertype = aChuvmovt.destCell.tertype); // which is now on, except air, water
end;


//------------------------------------------------------------------------------  positions


{ TPosition }

constructor TPosition.Create(aPosition: NPosition);
begin
inherited create;
fPosition := aPosition;
end;


{ TPosGround }        // 5 "allowchange position" methods for exact rules of demo

function TPosGround.allowchange(curCell, destCell: tCell;dist : Integer;  newPos : TPosition): Boolean;
begin
  result := ((newPos.fPosition in [poGround, poclimbed, powater]) and (dist in [1])) or
            ((newPos.fPosition in [poair, podigged]) and (dist in [0])) ;
end;

{ TPosWater }

function TPosWater.allowchange(curCell, destCell: tCell; dist : Integer; newPos : TPosition): Boolean;
begin
  result := ((newPos.fPosition in [poGround, poclimbed, powater, podigged]) and (dist in [1])) or
            ((newPos.fPosition in [poair]) and (dist in [0])) ;
end;

{ TPosAir }

function TPosAir.allowchange(curCell, destCell: tCell; dist : Integer; newPos : TPosition): Boolean;
begin
  result := ((newPos.fPosition in [poGround, poclimbed, powater]) and (dist in [0,1])) or
        ((newPos.fPosition in [poair]) and (dist in [1])) ;
end;
{ TPosClimbed }

function TPosClimbed.allowchange(curCell, destCell: tCell; dist : Integer; newPos : TPosition): Boolean;
begin
  result := ((newPos.fPosition in [poGround, poclimbed, powater]) and (dist in [1])) or
            ((newPos.fPosition in [poair]) and (dist in [0])) ;
end;

{ TPosDigged }

function TPosDigged.allowchange(curCell, destCell: tCell; dist : Integer; newPos : TPosition): Boolean;
begin
  result := ((newPos.fPosition in [poGround]) and (dist in [0,1])) or
            ((newPos.fPosition in [powater, podigged]) and (dist in [1])) ;
end;

//------------------------------------------------------------------------------    field-specific

{ tCell }

constructor tCell.create(ay, ax: tCellint ; atertype : NTerType);
begin
  fx := ax;
  fy := ay;
  ftertype := atertype;
end;

function tCell.distance(aCell: tCell): tCellint;
begin
  Result :=  Max(Max(x, aCell.x)- Min(x, aCell.x), Max(y, aCell.y)- Min(y, aCell.y))
end;

{ TField }

procedure Tfield.clearmap;
var
  i, j : word ;
begin
  i := 0;
  j := 0;
  while i < height do
  begin
    while j < width do
    begin
      freeandnil(ffield[i,j]);
      Inc(j);
    end;
    inc(i);
  end;
end;

constructor TField.create(aheight, awidth: tCellint);
begin
  Assert((aheight <> 0) and (awidth <> 0), 'Creating empty field!');
  setlength (ffield, aheight, awidth);
  fheight := aheight ;
  fwidth := awidth ;
  randomfill(5);
end;

destructor TField.destroy;
begin
  clearmap;
  inherited;
end;

function TField.getCell(ay, ax: tCellint): tCell;
begin
  if (ay < height) and (ax < width)then
    result := ffield[ay,ax]
  else result := nil;
  Assert(Result <> nil, 'out of the field');
end;

function TField.getheight: tCellint;
begin
  Result := fheight
end;


function Tfield.getwidth: tCellint;
begin
  Result := fwidth
end;

procedure TField.randomfill(fact: byte);
var
  w, h : cardinal;
  t, o : NTerType;
begin
  o := ttGround;
for w := 0 to width -1 do
  for h := 0 to height -1 do
  begin                                            
  t := ntertype(Random(fact+ord(High(ntertype)))); // a trick to imitate generating
  if T > High(ntertype)                            // a map instead of randomizing
    then t := o;                                   //
  o := t;                                          //
  ffield[h,w] := tCell.create(h, w, t);
  end;
end;

procedure TField.setCell(ay, ax: tCellint; aCell: tCell);
begin
ffield[ay,ax].Free;
ffield[ay,ax] := aCell;
end;
                           // Manager
//------------------------------------------------------------------------------

{ TMovingMgr }

procedure TMovingMgr.add(aMoving: tMoving);
begin
Movings.Add(aMoving);
end;


function TMovingMgr.getPosbytertype(att: Ntertype): TPosition;
begin
result := Positionar[tertypetoPos[att]];
end;


constructor TMovingMgr.create;
var
  i : NMoveKind;
  j : NPosition;
begin
  inherited;
tertypetoPos[ttground]    := poGround;    // just kind of translating
tertypetoPos[ttWater]     := poWater;
tertypetoPos[ttair]       := poAir;
tertypetoPos[ttrock]      := poclimbed;

Movingclsar [mkwalk]     := Twalking ;      // assigning class references
Movingclsar [mkfly]      := Tflying ;
Movingclsar [mkswim]     := Tswimming ;
Movingclsar [mkdig]      := Tdigging ;
Movingclsar [mkteleport] := Tteleporting ;
Movingclsar [mkclimb]    := Tclimbing ;
Movingclsar [mkjump]     := Tjumping ;

Movings := TMovingList.create(True);
for i := Low(nMovekind) to High(nMovekind) do
  if Movingclsar[i] = nil then
    raise EInvalidOperation.Create('Not all Movingclasses assigned')
  else Add(Movingclsar[i].Create(i)); // creating a list of abilities
                                      // the only instance of them in demo is here
Positionclsar [poground]  := TPosGround ;   // same for positions
Positionclsar [powater]   := TPosWater ;
Positionclsar [poair]     := TPosAir ;
Positionclsar [podigged]  := TPosDigged ;
Positionclsar [poclimbed] := TPosClimbed ;

for j := Low(nPosition) to High(nPosition) do
  if Positionclsar[j] = nil then
    raise EInvalidOperation.Create('Not all Positionclasses assigned')
  else Positionar[j]:= Positionclsar[j].Create(j);
end;

destructor TMovingMgr.destroy;
var
  i : NPosition;
begin
  for i := Low(nPosition) to High(nPosition) do
    Positionar[i].free;
  Movings.free;
  inherited;
end;


function TMovingMgr.getMoving(aMoving: nMovekind): TMoving;
begin
  result := Movings.getMoving(aMoving)
end;


function TMovingMgr.getPosition(apos: NPosition): TPosition;
begin
  result := positionar[apos];
end;

{ TMovingList }


function TMovingList.Get(index: integer): tMoving;
begin
  Result := TMoving(inherited Get(index));
end;

procedure TMovingList.put(index: integer; const Value: tMoving);
begin
  inherited put(index,Value);
end;

function TMovinglist.getMoving(aMoving : nMovekind): TMoving;
var
  i : integer;
begin
  Result := nil;
  i := 0;
  try
    while i < Count do
    if items[i].Movekind = aMoving then
    begin
      Result := items[i];
      Break;
    end
    else Inc(i);
  except
  end;
end;


destructor TMovingList.destroy;
var
  i : integer;
begin
  if Count = 0  then
    Exit;
  for i := Count-1 downto 0 do
  begin
    if fownsobbjects then
      items[i].free;
    Delete(i);
  end;
  inherited;
end;

constructor TMovingList.create;
begin
  inherited;
end;

constructor TMovingList.create(aownsobbjects: Boolean);
begin
  inherited create;
  fownsobbjects := aownsobbjects;
end;

{ TChuvMovement }


constructor TChuvMovement.create(aChuv : tChuvak; aCell: tCell);
begin
  fcurCell := aCell;
  fChuvak := aChuv;
  FPosition  := game.MovingMgr.getPosbytertype(aCell.tertype);
  fMoveability := TMovingList.Create;
end;

function TChuvMovement.game: tgame;
begin
  result := fChuvak.game;
end;

function TChuvMovement.cango(aCell : tCell): Boolean;
VAR
  i :integer;
begin
  result := False;
  i := 0;
  while i < MoveabilCount do
  begin
  result := fMoveability[i].CanGo(self);
  if Result then
    Exit;
  inc(i);
  end;
end;

function TChuvMovement.GetPosition: NPosition;
begin
  isValidPosition;
  Result := FPosition.Position;
end;

procedure TChuvMovement.SetcurCell(const Value: tCell);
begin
  fdestcell := Value;
  if cango(value) then
    FcurCell := Value;
end;



procedure TChuvMovement.SetPosition(const Value: NPosition);
begin
  fPosition := game.MovingMgr.Positionar[value];
end;

function TChuvMovement.isValidPosition: Boolean;
begin
  Result := FPosition <> nil ;
  Assert(Result , 'We missed Position of Chuvak');
end;


function TChuvMovement.allowposchange(newpos : NPosition) : Boolean;
begin
  Result := FPosition.allowchange(curCell, destCell, curCell.distance(destCell),
    game.MovingMgr.getPosition(newpos));
  if result then
    Position := newpos;
end;

function TChuvMovement.getmoveabil(aMoveKind: NMoveKind): TMoving;
begin
  result := fMoveability.getMoving(aMovekind)
end;

procedure TChuvMovement.addmoveabil(const Value: NMoveKind);
begin
  if getmoveabil(value) = nil then
    fMoveability.Add(game.MovingMgr.getMoving(value))
end;

function TChuvMovement.MoveAbilCount: Integer;
begin
  Result := fMoveability.Count;
end;

destructor TChuvMovement.destroy;
begin
  FreeAndNil(fMoveability);   // we own it, so freeing
  fcurCell := nil;          // we don't own, so just clear
  fdestCell := nil;         //
  fChuvak := nil;           //
  FPosition  := nil;        //
  inherited;
end;

procedure TChuvMovement.delmoveabil(const Value: NMoveKind);
var
  i : integer;
begin
  i := 0;
  while i < MoveabilCount do
    if fMoveability[i].fMoveKind = value then
    begin
      fMoveability.Delete(i);
      Break;
    end
    else inc(i);
end;

procedure TChuvMovement.insmoveabil(prio : Integer; const Value: NMoveKind);
begin
  if (MoveabilCount = 0 ) or not (prio in [0..MoveabilCount-1]) then
    Exit;
  delmoveabil(Value);
  fMoveability.Insert(prio, game.MovingMgr.getMoving(value))
end;

function TChuvMovement.getmoveabilind(aMoveKind: NMoveKind): integer;
var
  i : integer;
begin
  result := -1;
  i := 0;
  while i < MoveabilCount do
    if fMoveability[i].fMoveKind = aMoveKind then
    begin
      Result := i;
      Break;
    end
    else inc(i);
end;

end.
