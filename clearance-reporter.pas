////////////////////////////////////////////////////////////////////////////////
// Title: TestPoint_MinDist_Check                                             //
// Author: Mario Sbampato                                                     //
// Last Edit: 30/07/2024                                                      //
// Description:                                                               //
//    Check if there are testpoints too close. User defined minimal distance  //
//  User defined Component Comment field (component comment used to define    //
//  which components are considered test points)                              //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////
USES
  SysUtils, Classes, PCB_Types, PCB_Iterator, PCB_Primitives, PCB_Functions,
  PCB_Board, PCB_Net, Dialogs, PCB_Server, PCB_Via;

VAR
//Global variables
    PCBBoard: IPCB_Board;
    ClassT   : TClassMemberKind;



//*********************************************************************************
PROCEDURE FindClasses(PCBDoc: IPCB_Board, ClassType: TClassMemberKind);
VAR
   Iterator  : IPCB_BoardIterator;
   Item      : IPCB_ObjectClass;
BEGIN
  Iterator := PCBDoc.BoardIterator_Create;

  Iterator.SetState_FilterAll;
  Iterator.AddFilter_ObjectSet(MkSet(eClassObject));
  Item := Iterator.FirstPCBObject;

  WHILE (Item <> nil) DO
    BEGIN
      IF (Item.MemberKind = ClassType) THEN
        BEGIN
          MainForm.lbClasses1.Items.AddObject(Item.Name, Item);
          MainForm.lbClasses2.Items.AddObject(Item.Name, Item);
        END;
      Item := Iterator.NextPCBObject;
    END;

  PCBDoc.BoardIterator_Destroy(Iterator);
END;






//*********************************************************************************
PROCEDURE TMainForm.btnStartClick(Sender: TObject);
BEGIN
    //ListNetClasses;
    PCBBoard.ViewManager_FullUpdate;
    Client.SendMessage('PCB:Zoom', 'Action=Redraw', 255, Client.CurrentView);
END;






//*********************************************************************************
PROCEDURE MeasureDist2Class(PCBDoc: IPCB_Board, Entity: IPCB_Primitive, NetClass : IPCB_OBjectClass);
VAR
  Iterator  : IPCB_BoardIterator;
  Item      : IPCB_Primitive;
  ItemNet   : IPCB_Net;
  Track     : IPCB_Track;
  ItemClass : IPCB_ObjectClass;
  NetStr    : String;
  i         : Integer;

BEGIN

    //ShowMessage('starting');
    Iterator := PCBDOc.BoardIterator_Create;

    Iterator.SetState_FilterAll;
    Iterator.AddFilter_ObjectSet(MkSet(eClassObject));
    //Iterator.AddFilter_LayerSet(MkSet(eTopLayer));

    ItemClass := Iterator.FirstPCBObject;

    WHILE (ItemClass <> nil) DO
      BEGIN
        //MainForm.Memo3.Lines.Add(ItemClass);
        IF (ItemClass.Name = NetClass.Name) THEN
          BEGIN
            MainForm.Memo3.Lines.Add(ItemClass.Descriptor);
            MainForm.Memo3.Lines.Add(ItemClass.Handle);
            MainForm.Memo3.Lines.Add(ItemClass.Identifier);
            MainForm.Memo3.Lines.Add(ItemClass.Name);
            MainForm.Memo3.Lines.Add(ItemClass.ObjectIDString);
            MainForm.Memo3.Lines.Add(ItemClass.UniqueId);

            i := 0;
            WHILE (ItemClass.MemberName[i] <> '') DO
              BEGIN
                MainForm.Memo3.Lines.Add(ItemClass.MemberName[i]);
                MainForm.lbNets.Items.AddObject(ItemClass.MemberName[i], ItemClass);
                i := i + 1;
              END;

            MainForm.Memo3.Lines.Add('---------------------');
          END;

        ItemClass := Iterator.NextPCBObject;
      END;

    ResetParameters;
    AddStringParameter('Action', 'All');
    //AddStringParameter('Action',  'Redraw');
    RunProcess('PCB:Zoom');

END;




//*********************************************************************************
PROCEDURE TMainForm.btnCloseClick(Sender: TObject);
BEGIN
     Close;
     Exit;
END;






//*********************************************************************************
FUNCTION GetPCBDoc(Dummy : Integer = 0): IPCB_Board;
VAR
  PCBDoc : IPCB_Board;
BEGIN
  // Get the current PCB board
  PCBDoc := PCBServer.GetCurrentPCBBoard;

  IF (PCBDoc = nil) THEN
    BEGIN
      ShowMessage('No PCB document is currently open.');
      Exit;
    END;

  Result := PCBDoc;
END;






//*********************************************************************************
function GetNetsFromClass(PCBDoc: IPCB_Board, NetClass : IPCB_OBjectClass, Dummy : Integer = 0): TStringList;
var
  Iterator  : IPCB_BoardIterator;
  Item      : IPCB_Primitive;
  ItemNet   : IPCB_Net;
  Track     : IPCB_Track;
  ItemClass : IPCB_ObjectClass;
  NetStr    : String;
  i         : Integer;

begin
    Iterator := PCBDOc.BoardIterator_Create;

    Iterator.SetState_FilterAll;
    Iterator.AddFilter_ObjectSet(MkSet(eClassObject));

    ItemClass := Iterator.FirstPCBObject;

    Result := TStringList.Create;
    Result.Clear;

    while (ItemClass <> nil) do
      begin

        if (ItemClass.Name = NetClass.Name) then
          begin

            i := 0;

            while (ItemClass.MemberName[i] <> '') do
              begin
               Result.AddObject(ItemClass.MemberName[i], ItemClass);
                i := i + 1;
              end;

          end;

        ItemClass := Iterator.NextPCBObject;
      end;
end;





//*********************************************************************************
function Dist_Via2Via(PCBDoc: IPCB_Board, FirstObjectNet, SecondObjectNet: String, Dummy : Integer = 0): Real;
var
  i, j          : Integer;
  Object1       : IPCB_Via;
  Object2       : IPCB_Via;
  Iterator      : IPCB_BoardIterator;
  Iterator2     : IPCB_BoardIterator;
  v1, v2        : IPCB_Coordinate;
  dx, dy        : IPCB_Coordinate;
  l, lx, ly     : Real;
  Str           : String;
  shortest      : Real;
begin

  Iterator := PCBBoard.BoardIterator_Create;
  Iterator.AddFilter_ObjectSet(MkSet(eViaObject));
  Iterator.AddFilter_LayerSet(AllLayers);

  Object1 := Iterator.FirstPCBObject;

  l := -1;
  shortest := 99999*10000;

  while (Object1 <> nil) do
    begin
      if (Object1.Net <> nil) then
        if (Object1.Net.Name = FirstObjectNet) then
          begin
            Iterator2 :=  PCBBoard.BoardIterator_Create;
            Iterator2.AddFilter_ObjectSet(MkSet(eViaObject));
            Iterator2.AddFilter_LayerSet(AllLayers);

            Object2 := Iterator2.FirstPCBObject;

            while (Object2 <> nil) do
              begin
                if (Object2.Net <> nil) then
                  if (Object2.Net.Name = SecondObjectNet) then
                    begin
                      if (Object1.x >= Object2.x) then
                        dx := Object1.x - Object2.x
                      else
                        dx := Object2.x - Object1.x;

                      if (Object1.y >= Object2.y) then
                        dy := Object1.y - Object2.y
                      else
                        dy := Object2.y - Object1.y;


                      lx := CoordToMMs_FullPrecision(dx);
                      ly := CoordToMMs_FullPrecision(dy);
                      l := sqrt((lx*lx)+(ly*ly));

                      l := l - (CoordToMMs_FullPrecision(Object1.Size)/2);
                      l := l - (CoordToMMs_FullPrecision(Object2.Size)/2);

                      if (l < shortest) then
                       shortest := l;

                      Str := '['+ FirstObjectNet + '];[Via];[' + SecondObjectNet + '];[Via];[';
                      Str := Str + Object2.Descriptor + '];[';
                      Str := Str + Object1.Descriptor + '];[';
                      Str := Str + FormatFloat('0.000', l) + ']';

                      MainForm.Memo3.Lines.Add(Str);
                    end;
                Object2 := Iterator2.NextPCBObject;
              end;
          end;
      Object1 := Iterator.NextPCBObject;
    end;


  PCBBoard.BoardIterator_Destroy(Iterator);
  PCBBoard.BoardIterator_Destroy(Iterator2);

  Result := shortest;
end;





//*********************************************************************************
function Dist_Via2Track(Via: IPCB_Via, Track: IPCB_Track, Dummy : Integer = 0): Real;
var
  x1, x2, y1, y2, px, py,
  dx, dy, ix, iy, SqLineMag,
  u             : Real;
  temp          : Real;
begin

  px := CoordToMMs_FullPrecision(Via.x);
  py := CoordToMMs_FullPrecision(Via.y);

  x1 := CoordToMMs_FullPrecision(Track.x1);
  y1 := CoordToMMs_FullPrecision(Track.y1);

  x2 := CoordToMMs_FullPrecision(Track.x2);
  y2 := CoordToMMs_FullPrecision(Track.y2);

  SqLineMag := 0;

  SqLineMag := (x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1);

  if (SqLineMag < (0.0001*0.0001)) then
  begin
    temp := -1.0;
    exit;
  end;

  u := ( (px - x1)*(x2 - x1) + (py - y1)*(y2 - y1) ) / SqLineMag;

  if (u < (0.0001)) or (u > 1) then
  begin
 //  Closest point does not fall within the line segment,
 //    take the shorter distance to an endpoint
    ix := (x1 - px) * (x1 - px) + (y1 - py) * (y1 - py);
    iy := (x2 - px) * (x2 - px) + (y2 - py) * (y2 - py);
    if (ix <= iy) then
      temp := ix
    else
      temp := iy;
  end //  if (u < EPS) or (u > 1)
  else
  begin
 //  Intersecting point is on the line, use the formula
    ix := x1 + u * (x2 - x1);
    iy := y1 + u * (y2 - y1);
    temp := (ix - px) * (ix - px) + (iy - py) * (iy - py);
  end; //  else NOT (u < EPS) or (u > 1)

 // finally convert to actual distance not its square
  temp := sqrt(temp);
  temp := temp - (CoordToMMs_FullPrecision(Via.Size)/2);
  temp := temp - (CoordToMMs_FullPrecision(Track.Width)/2);
  result := temp;
end;




//*********************************************************************************
function Dist_Point2Track(px: Real, py: Real, x1, y1: Real, x2, y2: Real, Dummy : Integer = 0): Real;
var
  dx, dy, ix, iy, SqLineMag,
  u             : Real;
  temp          : Real;
begin

  SqLineMag := 0;

  SqLineMag := (x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1);

  if (SqLineMag < (0.0001*0.0001)) then
  begin
    temp := -1.0;
    exit;
  end;

  u := ( (px - x1)*(x2 - x1) + (py - y1)*(y2 - y1) ) / SqLineMag;

  if (u < (0.0001)) or (u > 1) then
  begin
 //  Closest point does not fall within the line segment,
 //    take the shorter distance to an endpoint
    ix := (x1 - px) * (x1 - px) + (y1 - py) * (y1 - py);
    iy := (x2 - px) * (x2 - px) + (y2 - py) * (y2 - py);
    if (ix <= iy) then
      temp := ix
    else
      temp := iy;
  end //  if (u < EPS) or (u > 1)
  else
  begin
 //  Intersecting point is on the line, use the formula
    ix := x1 + u * (x2 - x1);
    iy := y1 + u * (y2 - y1);
    temp := (ix - px) * (ix - px) + (iy - py) * (iy - py);
  end; //  else NOT (u < EPS) or (u > 1)

 // finally convert to actual distance not its square
  temp := sqrt(temp);
  result := temp;
end;





//*********************************************************************************
procedure TMainForm.XPButtonEx4Click(Sender: TObject);
var
   i, j : Integer;
   Class2Check, Class2bChecked : TStringList;
   calc_dist : Real;
   shortest: Real;
   ClassStr1, ClassStr2: String;


  k, l          : Integer;
  Object1       : IPCB_Via;
  Object2       : IPCB_Via;
  Iterator      : IPCB_BoardIterator;
  Iterator2     : IPCB_BoardIterator;
  Str           : String;
  shortesti     : Real;

  d1, d2, d3, d4,
  d5, d6, d7, d8 : Real;
begin

  Class2Check := TStringList.Create;
  Class2bChecked := TStringList.Create;

  Class2Check.Clear;
  Class2bChecked.Clear;


  for i:= 0 to (MainForm.lbClasses1.Items.Count - 1) do
    if (MainForm.lbClasses1.Selected[i]) then
      begin
        Class2Check.AddStrings(GetNetsFromClass(PCBBoard, MainForm.lbClasses1.Items.Objects[i]));
        ClassStr1 := MainForm.lbClasses1.Items.Strings[i];
      end;

  for i:= 0 to (MainForm.lbClasses2.Items.Count - 1) do
    if (MainForm.lbClasses2.Selected[i]) then
      begin
        Class2bChecked.AddStrings(GetNetsFromClass(PCBBoard, MainForm.lbClasses2.Items.Objects[i]));
        ClassStr2 := MainForm.lbClasses2.Items.Strings[i];
      end;

  // Aqui tenho 2 StringLists com os nomes das NETs que preciso verificar
  // Devo implementar agora o efetivo check de todos os primitives de uma netlist contra a segunda netlist
  // Tipo iterar a primeira Netlist do inicio ao fim, dentro desta, iterar todos as VIAS com o mesmo netname contra todos os da outra lista

  //Debbuging part - Remove before flight  *************************************************

  MainForm.Memo3.Lines.Add('Class2Check:');
  for i:=0 to (Class2Check.GetCount - 1) do
   MainForm.Memo3.Lines.Add(Class2Check.Strings[i]);

  MainForm.Memo3.Lines.Add('');
  MainForm.Memo3.Lines.Add('Class2bChecked:');
  for i:=0 to (Class2bChecked.GetCount - 1) do
   MainForm.Memo3.Lines.Add(Class2bChecked.Strings[i]);

  MainForm.Memo3.Lines.Add('');
  MainForm.Memo3.Lines.Add('');
  MainForm.Memo3.Lines.Add('NETS to be checked');
  //Debbuging part - Remove before flight  *************************************************

  for i:=0 to (Class2Check.GetCount - 1) do
    begin
      for j:=0 to (Class2bChecked.GetCount - 1) do
        begin
          MainForm.Memo3.Lines.Add('Needs to be checked: ' + Class2Check.Strings[i] +
          ' against ' + Class2bChecked.Strings[j] + '.');
        end;
    end;

  MainForm.Memo3.Lines.Add('');
  MainForm.Memo3.Lines.Add('');

  shortest := 999990000;

  // Inicio a checkar todos os primitives. Partindo do Via2Via
  for i:=0 to (Class2Check.GetCount - 1) do
    begin
      for j:=0 to (Class2bChecked.GetCount - 1) do
        begin
          calc_dist := Dist_Via2Via(PCBBoard, Class2Check.Strings[i], Class2bChecked.Strings[j]);

          if ((calc_dist >= 0) and (calc_dist < 999990000)) then
            begin
             // MainForm.Memo3.Lines.Add('[' + Class2Check.Strings[i]
             // + '];[' + Class2bChecked.Strings[j] + '];['
             // + FormatFloat('0.000', calc_dist) + ' mm]');

              if (calc_dist < shortest) then
                begin
                  shortest := calc_dist;
                end;

            end;
        end;
    end;

  // Inicio a checkar todos os primitives. Continuando com check Via-Tracks
  for i:=0 to (Class2Check.GetCount - 1) do
    begin
      for j:=0 to (Class2bChecked.GetCount - 1) do
        begin

          Iterator := PCBBoard.BoardIterator_Create;
          Iterator.AddFilter_ObjectSet(MkSet(eViaObject));
          Iterator.AddFilter_LayerSet(AllLayers);

          Object1 := Iterator.FirstPCBObject;

          shortesti := 99999*10000;

          while (Object1 <> nil) do
            begin
              if (Object1.Net <> nil) then
                if (Object1.Net.Name = Class2Check.Strings[i]) then
                  begin
                    Iterator2 :=  PCBBoard.BoardIterator_Create;
                    Iterator2.AddFilter_ObjectSet(MkSet(eTrackObject));
                    Iterator2.AddFilter_LayerSet(AllLayers);

                    Object2 := Iterator2.FirstPCBObject;

                    while (Object2 <> nil) do
                      begin
                        if (Object2.Net <> nil) then
                          if (Object2.Net.Name = Class2bChecked.Strings[j]) then
                            begin

                              calc_dist := Dist_Via2Track(Object1, Object2);


                              if (calc_dist < shortesti) then
                               shortesti := calc_dist;

                              Str := '['+ Class2Check.Strings[i] + '];[Via];[' + Class2bChecked.Strings[j] + '];[Track];[';
                              Str := Str + Object2.Descriptor + '];[';
                              Str := Str + Object1.Descriptor + '];[';
                              Str := Str + FormatFloat('0.000', calc_dist) + ']';

                              //MainForm.Memo3.Lines.Add(Str);
                            end;
                        Object2 := Iterator2.NextPCBObject;
                      end;
                  end;
              Object1 := Iterator.NextPCBObject;
            end;


          PCBBoard.BoardIterator_Destroy(Iterator);
          PCBBoard.BoardIterator_Destroy(Iterator2);

          if ((calc_dist >= 0) and (calc_dist < 999990000)) then
            begin
             // MainForm.Memo3.Lines.Add('[' + Class2Check.Strings[i]
             // + '];[' + Class2bChecked.Strings[j] + '];['
             // + FormatFloat('0.000', calc_dist) + ' mm]');

              if (calc_dist < shortest) then
                begin
                  shortest := calc_dist;
                end;

            end;
        end;
    end;





  // Inicio a checkar todos os primitives. Continuando com check Tracks-Tracks
  for i:=0 to (Class2Check.GetCount - 1) do
    begin
      for j:=0 to (Class2bChecked.GetCount - 1) do
        begin

          Iterator := PCBBoard.BoardIterator_Create;
          Iterator.AddFilter_ObjectSet(MkSet(eTrackObject));
          Iterator.AddFilter_LayerSet(AllLayers);

          Object1 := Iterator.FirstPCBObject;

          shortesti := 99999*10000;

          while (Object1 <> nil) do
            begin
              if (Object1.Net <> nil) then
                if (Object1.Net.Name = Class2Check.Strings[i]) then
                  begin
                    Iterator2 :=  PCBBoard.BoardIterator_Create;
                    Iterator2.AddFilter_ObjectSet(MkSet(eTrackObject));
                    Iterator2.AddFilter_LayerSet(AllLayers);

                    Object2 := Iterator2.FirstPCBObject;

                    while (Object2 <> nil) do
                      begin
                        if (Object2.Net <> nil) then
                          if (Object2.Net.Name = Class2bChecked.Strings[j]) then
                            begin

                              d1 := Dist_Point2Track(CoordToMMs_FullPrecision(Object1.x1), CoordToMMs_FullPrecision(Object1.y1),
                                 CoordToMMs_FullPrecision(Object2.x1), CoordToMMs_FullPrecision(Object2.y1),
                                 CoordToMMs_FullPrecision(Object2.x2), CoordToMMs_FullPrecision(Object2.y2));
                              d2 := Dist_Point2Track(CoordToMMs_FullPrecision(Object1.x2), CoordToMMs_FullPrecision(Object1.y2),
                                 CoordToMMs_FullPrecision(Object2.x1), CoordToMMs_FullPrecision(Object2.y1),
                                 CoordToMMs_FullPrecision(Object2.x2), CoordToMMs_FullPrecision(Object2.y2));
                              d3 := Dist_Point2Track(CoordToMMs_FullPrecision(Object2.x1), CoordToMMs_FullPrecision(Object2.y1),
                                 CoordToMMs_FullPrecision(Object1.x1), CoordToMMs_FullPrecision(Object1.y1),
                                 CoordToMMs_FullPrecision(Object1.x2), CoordToMMs_FullPrecision(Object1.y2));
                              d4 := Dist_Point2Track(CoordToMMs_FullPrecision(Object2.x2), CoordToMMs_FullPrecision(Object2.y2),
                                 CoordToMMs_FullPrecision(Object1.x1), CoordToMMs_FullPrecision(Object1.y1),
                                 CoordToMMs_FullPrecision(Object1.x2), CoordToMMs_FullPrecision(Object1.y2));

                              calc_dist := d1;
                              if (d2 < calc_dist) then
                                calc_dist := d2;
                              if (d3 < calc_dist) then
                                calc_dist := d3;
                              if (d4 < calc_dist) then
                                calc_dist := d4;

                              calc_dist := calc_dist - (CoordToMMs_FullPrecision(Object1.width) / 2);
                              calc_dist := calc_dist - (CoordToMMs_FullPrecision(Object2.width) / 2);

                              if (calc_dist < shortesti) then
                               shortesti := calc_dist;

                              Str := '['+ Class2Check.Strings[i] + '];[Track];[' + Class2bChecked.Strings[j] + '];[Track];[';
                              Str := Str + Object2.Descriptor + '];[';
                              Str := Str + Object1.Descriptor + '];[';
                              Str := Str + FormatFloat('0.000', calc_dist) + ']';

                              MainForm.Memo3.Lines.Add(Str);
                            end;
                        Object2 := Iterator2.NextPCBObject;
                      end;
                  end;
              Object1 := Iterator.NextPCBObject;
            end;


          PCBBoard.BoardIterator_Destroy(Iterator);
          PCBBoard.BoardIterator_Destroy(Iterator2);

          if ((calc_dist >= 0) and (calc_dist < 999990000)) then
            begin
              MainForm.Memo3.Lines.Add('[' + Class2Check.Strings[i]
              + '];[' + Class2bChecked.Strings[j] + '];['
              + FormatFloat('0.000', calc_dist) + ' mm]');

              if (calc_dist < shortest) then
                begin
                  shortest := calc_dist;
                end;

            end;
        end;
    end;



  MainForm.Memo3.Lines.Add('[' + ClassStr1 + '];[' + ClassStr2 + '];[' + FormatFloat('0.000', shortest) + ']');

  Class2Check.Free;
  Class2bChecked.Free;
end;






//************************   MAIN   ***********************************************
BEGIN
    PCBBoard := GetPCBDoc;

    ClassT := eClassMemberKind_Net;
    //ClassT := eClassMemberKind_Component;
    //ClassT := eClassMemberKind_FromTo;
    //ClassT := eClassMemberKind_Pad;
    //ClassT := eClassMemberKind_Layer;

    FindClasses(PCBBoard, ClassT);
END;



