unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls;

type
  TForm1 = class(TForm)
    edt1: TEdit;
    lv1: TListView;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure lv1Data(Sender: TObject; Item: TListItem);
    procedure FormDestroy(Sender: TObject);
    procedure edt1Change(Sender: TObject);
  private
    { Private declarations }
    FLall, FLdata, FL, FLtmp: TList;
    Finited: Boolean;
    FoldKey: string;
    procedure doShowData(Sender: TObject);
    procedure doQueryDataThr(skey: string; inLst, outLst: TList);
  public
    { Public declarations }
  end;

  PmyGuidStr = ^TmyGuidStr;
  TmyGuidStr = record
     sGuid: string;
  end;

  TThrInitData=class(TThread)
    private
      Flst: TList;
      fcb: TNotifyEvent;
    protected
      procedure Execute; override;
    public
      constructor Create(aList: TList);
      property OnAfterInitdata:TNotifyEvent  read fcb write fcb;
  end;

  TThrQueryData=class(TThread)
    private
      Flin, Flout: TList;
      FKeyWord: string;
      fcb: TNotifyEvent;
    protected
      procedure Execute; override;
    public
      constructor Create(sKEY:string; inLst, outLst: TList);
      property OnAfterQueryData:TNotifyEvent  read fcb write fcb;
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

function NewObjStr(): PmyGuidStr;
var
  gi: TGUID;
begin
  New(Result);
  CreateGUID(gi);
  Result^.sGuid:= GUIDToString(gi);
end;

procedure FreeObjStr(pt: Pointer);
begin
  Dispose(PmyGuidStr(pt));
end;

procedure TForm1.doQueryDataThr(skey: string; inLst, outLst: TList);
begin
  with TThrQueryData.Create(skey, inLst, outLst) do
  begin
    OnAfterQueryData:=doShowData;
    Resume;
  end;
end;

procedure TForm1.doShowData(Sender: TObject);
begin
  lv1.Items.BeginUpdate;
  try
    //触发消息
    FL:=nil;
    lv1.Items.Clear;
    //
    FL:= Sender as TList;
    lv1.Items.Count:=FL.Count;
    Caption:=IntToStr(FL.Count);
  finally
    lv1.Items.EndUpdate;
  end;
  Finited:=True;
end;

procedure TForm1.edt1Change(Sender: TObject);
begin
  if Trim(edt1.Text)='' then
     doShowData(FLall)
  else
  begin
    //回退关键词，及第一次过滤
    if (FoldKey='') or (Pos(Trim(edt1.Text), FoldKey)=1) then
      doQueryDataThr(Trim(edt1.Text), FLall, FLtmp)
    else
      doQueryDataThr(Trim(edt1.Text), FLtmp, FLdata);
  end;
  FoldKey:=Trim(edt1.Text);
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  FLall:= TList.Create;
  FLdata:= TList.Create;
  FLtmp:= TList.Create;
  //
  Finited:=False;
  FoldKey:='';
end;

procedure TForm1.FormDestroy(Sender: TObject);
var
  i: Integer;
begin
  for i := FLall.Count - 1 downto 0 do
    FreeObjStr(FLall.Items[i]);
  FreeAndNil(FLall);
  FreeAndNil(FLdata);
  FreeAndNil(FLtmp);
end;

procedure TForm1.FormShow(Sender: TObject);
begin
  if not Finited then
  begin
    with TThrInitData.Create(FLall) do
    begin
      OnAfterInitdata:=doShowData;
      Resume;
    end;
  end;
end;

procedure TForm1.lv1Data(Sender: TObject; Item: TListItem);
begin
  if Assigned(FL) then  
   Item.Caption:= PmyGuidStr(FL.Items[Item.Index])^.sGuid;
end;

{ TThrInitData }

constructor TThrInitData.Create(aList: TList);
begin
  inherited Create(True);
  Assert(aList<>nil);
  Flst:=aList;
  FreeOnTerminate:=True;
end;

procedure TThrInitData.Execute;
var
  i: Integer;
  pt: PmyGuidStr;
begin
  //inherited;
  for i := 0 to 100000 - 1 do
  begin
   pt:=NewObjStr();
   Flst.Add(pt);
  end;
  if Assigned(fcb) then
   fcb(Flst);
end;

{ TThrQueryData }

constructor TThrQueryData.Create(sKEY: string; inLst, outLst: TList);
begin
  inherited Create(True);
  Assert(inLst<>nil);
  Assert(outLst<>nil);
  FKeyWord:=sKEY;
  Flin:=inLst;
  Flout:=outLst;
  FreeOnTerminate:=True;
end;

procedure TThrQueryData.Execute;
var
   i: Integer;
begin
  //inherited;
  Flout.Clear;
  for i := 0 to Flin.Count - 1 do
   if Pos(FKeyWord, PmyGuidStr(Flin.Items[i])^.sGuid)>0 then
     Flout.Add(Flin.Items[i]);
  //
  if Assigned(fcb) then
     fcb(Flout);
end;

end.
