unit TestJsonDataObjects;

{$IFDEF NEXTGEN}
  {$IF CompilerVersion >= 31.0} // 10.1 Berlin or newer
    {$DEFINE SUPPORTS_UTF8STRING} // Delphi 10.1 Berlin supports UTF8String for mobile compilers
  {$IFEND}
{$ELSE}
  {$DEFINE SUPPORTS_UTF8STRING}
{$ENDIF}

interface

uses
  System.SysUtils, System.Classes, System.Variants,
  TestFramework, JsonDataObjects;

type
  TestTJsonBaseObject = class(TTestCase)
  private
    FProgressSteps: array of NativeInt;
    procedure LoadFromEmptyStream;
    procedure LoadFromArrayStreamIntoObject;
    procedure ParseUtf8BrokenJSON1;
    procedure ParseUtf8BrokenJSON2;
    procedure ParseUtf8BrokenJSON3;
    procedure ParseUtf8BrokenJSON5;
    procedure ParseUtf8BrokenJSON6;
    procedure ParseUtf8BrokenJSON4;
    procedure ParseUtf8BrokenJSON7;
    procedure ParseBrokenJSON1;
    procedure ParseBrokenJSON2;
    procedure ParseBrokenJSON3;
    procedure ParseBrokenJSON4;
    procedure ParseBrokenJSON5;
    procedure ParseBrokenJSON6;
    procedure ParseBrokenJSON7;
    procedure ObjectToVariantException;
    procedure ArrayToVariantException;
    procedure UnassigendVariantException;
    procedure NoNullConvertToValueTypesException;
    procedure NullObjectToArrayException;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestNewInstance;
    procedure TestParseUtf8Empty;
    procedure TestParseUtf8EmptyObjectArray;
    procedure TestParseUtf8;
    procedure TestParseUtf8BrokenJSON;
    procedure TestParseEmpty;
    procedure TestParseEmptyObjectAndArray;
    procedure TestParse;
    procedure TestParseBrokenJSON;
    procedure TestParseFromStream;
    procedure TestLoadFromStream;
    procedure TestSaveToStream;
    procedure TestSaveToLines;
    procedure TestDoubleDotZeroWrite;
    procedure TestEscapeAllNonASCIIChars;
    procedure TestToJSON;
    procedure TestToString;
    procedure TestDateTimeToJSON;
    procedure TestEmptyString;
    {$IFDEF SUPPORTS_UTF8STRING}
    procedure TestToUTF8JSON;
    {$ENDIF SUPPORTS_UTF8STRING}
    procedure TestInt64MaxIntX2;
    procedure TestVariant;
    procedure TestVariantNull;
    procedure TestUInt64;
    procedure TestProgress;
    procedure TestToJsonSerializationConfig;
    procedure TestSyntaxErrors;
    procedure TestDateTimeToJsonString;
  end;

  TestTJsonArray = class(TTestCase)
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestClear;
    procedure TestDelete;
    procedure TestAssign;
    procedure TestAdd;
    procedure TestInsert;
    procedure TestExtract;
    procedure TestEnumerator;
  end;

  TestTJsonObject = class(TTestCase)
  private
    FJson: TJsonObject;
    procedure TestPathError1;
    procedure TestPathError2;
    procedure TestPathError3;
    procedure TestPathError4;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestAssign;
    procedure TestClear;
    procedure TestRemove;
    procedure TestDelete;
    procedure TestIndexOf;
    procedure TestContains;
    procedure TestAccess;
    procedure TestAutoArrayAndObjectCreationOnAccess;
    procedure TestEasyAccess;
    procedure TestObjectAssign;
    procedure TestToSimpleObject;
    procedure TestFromSimpleObject;
    procedure TestFromSimpleObjectLowerCamelCase;
    procedure TestPathAccess;
    procedure TestExtract;
    procedure TestEnumerator;
  end;

implementation

function CompareFloatRel(Expected, Actual: Extended; RelativeError: Extended = 0.0000001): Boolean;
begin
  Result := (Expected = Actual) or (Abs((Actual - Expected) / Expected) < RelativeError);
end;

{ TestTJsonBaseObject }

procedure TestTJsonBaseObject.SetUp;
begin
end;

procedure TestTJsonBaseObject.TearDown;
begin
end;

procedure TestTJsonBaseObject.TestNewInstance;
var
  O: TJsonObject;
  A: TJsonArray;
begin
  O := TJsonObject.Create;
  try
    CheckEquals(0, O.Count);
    CheckEquals(0, O.Capacity);
  finally
    O.Free;
  end;

  A := TJsonArray.Create;
  try
    CheckEquals(0, A.Count);
    CheckEquals(0, A.Capacity);
  finally
    A.Free;
  end;
end;

procedure TestTJsonBaseObject.TestParseUtf8Empty;
begin
  Check(TJsonBaseObject.ParseUtf8('') = nil, '1: nil expected');
  Check(TJsonBaseObject.ParseUtf8('', 0) = nil, '2: nil expected');
  Check(TJsonBaseObject.ParseUtf8('', -1) = nil, '3: nil expected');
  Check(TJsonBaseObject.ParseUtf8(' ') = nil, '4: nil expected');
  Check(TJsonBaseObject.ParseUtf8(' ', 0) = nil, '5: nil expected');
  Check(TJsonBaseObject.ParseUtf8(' ', 1) = nil, '6: nil expected');
  Check(TJsonBaseObject.ParseUtf8(nil, -1) = nil, '7: nil expected');
  Check(TJsonBaseObject.ParseUtf8(nil, 0) = nil, '8: nil expected');
  Check(TJsonBaseObject.ParseUtf8(#0#1#2#3#4#5#6#7#8#9#10#11#12#13#14#15#16#17#18#19#20#21#22#23#24#25#26#27#28#29#31#32, -1) = nil, '9: nil expected');
  Check(TJsonBaseObject.ParseUtf8(#0#1#2#3#4#5#6#7#8#9#10#11#12#13#14#15#16#17#18#19#20#21#22#23#24#25#26#27#28#29#31#32, 32) = nil, '10: nil expected');
end;

procedure TestTJsonBaseObject.TestParseUtf8EmptyObjectArray;
var
  B: TJsonBaseObject;
  O: TJsonObject;
  A: TJsonArray;
begin
  B := TJsonBaseObject.ParseUtf8('{}');
  try
    Check(B <> nil, 'B <> nil');
    CheckIs(B, TJsonObject);
    O := B as TJsonObject;
    CheckEquals(0, O.Count);
    CheckEquals(0, O.Capacity);
  finally
    B.Free;
  end;

  B := TJsonBaseObject.ParseUtf8('   {}   ');
  try
    Check(B <> nil, 'B <> nil');
    CheckIs(B, TJsonObject);
    O := B as TJsonObject;
    CheckEquals(0, O.Count);
    CheckEquals(0, O.Capacity);
  finally
    B.Free;
  end;

  B := TJsonBaseObject.ParseUtf8('[]');
  try
    Check(B <> nil, 'B <> nil');
    CheckIs(B, TJsonArray);
    A := B as TJsonArray;
    CheckEquals(0, A.Count);
    CheckEquals(0, A.Capacity);
  finally
    B.Free;
  end;

  B := TJsonBaseObject.ParseUtf8('    []   ');
  try
    Check(B <> nil, 'B <> nil');
    CheckIs(B, TJsonArray);
    A := B as TJsonArray;
    CheckEquals(0, A.Count);
    CheckEquals(0, A.Capacity);
  finally
    B.Free;
  end;
end;

procedure TestTJsonBaseObject.TestParseUtf8;
var
  B: TJsonBaseObject;
  O: TJsonObject;
  A: TJsonArray;
begin
  B := TJsonBaseObject.ParseUtf8('{ "Key": "Value" }');
  try
    CheckNotNull(B, 'B <> nil');
    CheckIs(B, TJsonObject);
    O := B as TJsonObject;
    CheckEquals(1, O.Count);
    Check(O.Capacity >= O.Count, 'O.Capacity >= O.Count');
    CheckTrue(O.Contains('Key'));
    Check(O.Types['Key'] = jdtString, 'jdtString expected');
    CheckEquals('Value', O.S['Key']);
  finally
    B.Free;
  end;

  B := TJsonBaseObject.ParseUtf8('{ "Key": "Value", "SecondKey": "SecondValue" }');
  try
    CheckNotNull(B, 'B <> nil');
    CheckIs(B, TJsonObject);
    O := B as TJsonObject;
    CheckEquals(2, O.Count);
    Check(O.Capacity >= O.Count, 'O.Capacity >= O.Count');

    CheckTrue(O.Contains('Key'));
    Check(O.Types['Key'] = jdtString, 'jdtString expected');
    CheckEquals('Value', O.S['Key']);

    CheckTrue(O.Contains('SecondKey'));
    Check(O.Types['SecondKey'] = jdtString, 'jdtString expected');
    CheckEquals('SecondValue', O.S['SecondKey']);
  finally
    B.Free;
  end;

  B := TJsonBaseObject.ParseUtf8('{ "Key": "Value", "SecondKey": "SecondValue", "Array": [ "Item1", "Item2" ] }');
  try
    CheckNotNull(B, 'B <> nil');
    CheckIs(B, TJsonObject);
    O := B as TJsonObject;
    CheckEquals(3, O.Count);
    Check(O.Capacity >= O.Count, 'O.Capacity >= O.Count');

    CheckTrue(O.Contains('Key'));
    Check(O.Types['Key'] = jdtString, 'jdtString expected');
    CheckEquals('Value', O.S['Key']);

    CheckTrue(O.Contains('SecondKey'));
    Check(O.Types['SecondKey'] = jdtString, 'jdtString expected');
    CheckEquals('SecondValue', O.S['SecondKey']);

    CheckTrue(O.Contains('Array'));
    Check(O.Types['Array'] = jdtArray, 'jdtString expected');
    CheckEquals(2, O.A['Array'].Count);
    Check(O.A['Array'].Types[0] = jdtString, 'jdtString expected');
    CheckEquals('Item1', O.A['Array'].S[0]);
    Check(O.A['Array'].Types[1] = jdtString, 'jdtString expected');
    CheckEquals('Item2', O.A['Array'].S[1]);
  finally
    B.Free;
  end;

  B := TJsonBaseObject.ParseUtf8('{ "Key": [] }');
  try
    CheckNotNull(B, 'B <> nil');
    CheckIs(B, TJsonObject);
    O := B as TJsonObject;
    CheckEquals(1, O.Count);
    Check(O.Capacity >= O.Count, 'O.Capacity >= O.Count');
    CheckTrue(O.Contains('Key'));
    Check(O.Types['Key'] = jdtArray, 'jdtArray expected');
    CheckEquals(0, O.A['Key'].Count);
  finally
    B.Free;
  end;

  B := TJsonBaseObject.ParseUtf8('{ "Key": [ { "Key": 123, "Bool": true, "Bool2": false, "Null": null, "Float": -1.234567890E10, "Int64": 1234567890123456789 } ] }');
  try
    CheckNotNull(B, 'B <> nil');
    CheckIs(B, TJsonObject);
    O := B as TJsonObject;
    CheckEquals(1, O.Count);
    Check(O.Capacity >= O.Count, 'O.Capacity >= O.Count');
    CheckTrue(O.Contains('Key'));
    Check(O.Types['Key'] = jdtArray, 'jdtArray expected');
    A := O.A['Key'];
    CheckEquals(1, A.Count);

    Check(A.Types[0] = jdtObject, 'jdtObject expected');
    CheckEquals(6, A.O[0].Count);

    CheckTrue(A.O[0].Contains('Key'));
    Check(A.O[0].Types['Key'] = jdtInt, 'jdtInt expected');
    CheckEquals(123, A.O[0].I['Key']);

    CheckTrue(A.O[0].Contains('Bool'));
    Check(A.O[0].Types['Bool'] = jdtBool, 'jdtBool expected');
    CheckEquals(True, A.O[0].B['Bool']);

    CheckTrue(A.O[0].Contains('Bool2'));
    Check(A.O[0].Types['Bool2'] = jdtBool, 'jdtBool expected');
    CheckEquals(False, A.O[0].B['Bool2']);

    CheckTrue(A.O[0].Contains('Null'));
    Check(A.O[0].Types['Null'] = jdtObject, 'jdtObject expected');
    Check(A.O[0].O['Null'] = nil);

    CheckTrue(A.O[0].Contains('Float'));
    Check(A.O[0].Types['Float'] = jdtFloat, 'jdtFloat expected');
    CheckEquals(-1.234567890E10, A.O[0].F['Float'], 0.00001);

    CheckTrue(A.O[0].Contains('Int64'));
    Check(A.O[0].Types['Int64'] = jdtLong);
    CheckEquals(1234567890123456789, A.O[0].L['Int64'], 'jdtInt64 expected');
  finally
    B.Free;
  end;

  B := TJsonBaseObject.ParseUtf8('{ "key": "\u0000" }');
  try
    CheckIs(B, TJsonObject);
    O := B as TJsonObject;
    CheckEquals(1, O.Count);
    CheckEqualsString(#0, O.S['key']);
  finally
    B.Free;
  end;

  B := TJsonBaseObject.ParseUtf8('{ "key": "X\u0000X" }');
  try
    CheckIs(B, TJsonObject);
    O := B as TJsonObject;
    CheckEquals(1, O.Count);
    CheckTrue(O.Contains('key'));
    CheckFalse(O.Contains('Key'));
    CheckFalse(O.Contains('KEY'));
    CheckFalse(O.Contains('kEy'));
    CheckFalse(O.Contains('kEY'));
    CheckFalse(O.Contains('keY'));
    CheckFalse(O.Contains('KeY'));
    CheckEqualsString('X'#0'X', O.S['key']);
  finally
    B.Free;
  end;

  // Array

  B := TJsonBaseObject.ParseUtf8('[ "Item1" ]');
  try
    CheckNotNull(B, 'B <> nil');
    CheckIs(B, TJsonArray);
    A := B as TJsonArray;
    CheckEquals(1, A.Count);
    Check(A.Capacity >= A.Count, 'A.Capacity >= A.Count');
    Check(A.Types[0] = jdtString);
    CheckEquals('Item1', A.S[0]);
  finally
    B.Free;
  end;

  B := TJsonBaseObject.ParseUtf8('[ "Item1", "Item2"] ]');
  try
    CheckNotNull(B, 'B <> nil');
    CheckIs(B, TJsonArray);
    A := B as TJsonArray;
    CheckEquals(2, A.Count);
    Check(A.Capacity >= A.Count, 'A.Capacity >= A.Count');

    Check(A.Types[0] = jdtString);
    CheckEquals('Item1', A.S[0]);

    Check(A.Types[1] = jdtString);
    CheckEquals('Item2', A.S[1]);
  finally
    B.Free;
  end;

  B := TJsonBaseObject.ParseUtf8('[ "Item1", "Item2", {} ] ]');
  try
    CheckNotNull(B, 'B <> nil');
    CheckIs(B, TJsonArray);
    A := B as TJsonArray;
    CheckEquals(3, A.Count);
    Check(A.Capacity >= A.Count, 'A.Capacity >= A.Count');

    Check(A.Types[0] = jdtString);
    CheckEquals('Item1', A.S[0]);

    Check(A.Types[1] = jdtString);
    CheckEquals('Item2', A.S[1]);

    Check(A.Types[2] = jdtObject);
    CheckEquals(0, A.O[2].Count);
  finally
    B.Free;
  end;

  B := TJsonBaseObject.ParseUtf8('[ "\u0000" ]');
  try
    CheckIs(B, TJsonArray);
    A := B as TJsonArray;
    CheckEquals(1, A.Count);
    CheckEqualsString(#0, A.S[0]);
  finally
    B.Free;
  end;

  B := TJsonBaseObject.ParseUtf8('[ "X\u0000X" ]');
  try
    CheckIs(B, TJsonArray);
    A := B as TJsonArray;
    CheckEquals(1, A.Count);
    CheckEqualsString('X'#0'X', A.S[0]);
  finally
    B.Free;
  end;

  B := TJsonBaseObject.ParseUtf8('[ "\t", "\r\n", "X\r\n", "\r\nX", "Xx\r\n\xX" ]');
  try
    CheckIs(B, TJsonArray);
    A := B as TJsonArray;
    CheckEquals(5, A.Count);
    CheckEqualsString(#9, A.S[0]);
    CheckEqualsString(#13#10, A.S[1]);
    CheckEqualsString('X'#13#10, A.S[2]);
    CheckEqualsString(#13#10'X', A.S[3]);
    CheckEqualsString('Xx'#13#10'xX', A.S[4]);
  finally
    B.Free;
  end;
end;

procedure TestTJsonBaseObject.TestParseEmpty;
begin
  Check(TJsonBaseObject.Parse('') = nil, '1: nil expected');
  Check(TJsonBaseObject.Parse('', 0) = nil, '2: nil expected');
  Check(TJsonBaseObject.Parse('', -1) = nil, '3: nil expected');
  Check(TJsonBaseObject.Parse(' ') = nil, '4: nil expected');
  Check(TJsonBaseObject.Parse(' ', 0) = nil, '5: nil expected');
  Check(TJsonBaseObject.Parse(' ', 1) = nil, '6: nil expected');
  Check(TJsonBaseObject.Parse(nil, -1) = nil, '7: nil expected');
  Check(TJsonBaseObject.Parse(nil, 0) = nil, '8: nil expected');
  Check(TJsonBaseObject.Parse(#0#1#2#3#4#5#6#7#8#9#10#11#12#13#14#15#16#17#18#19#20#21#22#23#24#25#26#27#28#29#31#32, -1) = nil, '9: nil expected');
  Check(TJsonBaseObject.Parse(#0#1#2#3#4#5#6#7#8#9#10#11#12#13#14#15#16#17#18#19#20#21#22#23#24#25#26#27#28#29#31#32, 32) = nil, '10: nil expected');
end;

procedure TestTJsonBaseObject.TestParseEmptyObjectAndArray;
var
  B: TJsonBaseObject;
  O: TJsonObject;
  A: TJsonArray;
begin
  B := TJsonBaseObject.Parse('{}');
  try
    Check(B <> nil, 'B <> nil');
    CheckIs(B, TJsonObject);
    O := B as TJsonObject;
    CheckEquals(0, O.Count);
    CheckEquals(0, O.Capacity);
  finally
    B.Free;
  end;

  B := TJsonBaseObject.Parse('   {}   ');
  try
    Check(B <> nil, 'B <> nil');
    CheckIs(B, TJsonObject);
    O := B as TJsonObject;
    CheckEquals(0, O.Count);
    CheckEquals(0, O.Capacity);
  finally
    B.Free;
  end;

  B := TJsonBaseObject.Parse('[]');
  try
    Check(B <> nil, 'B <> nil');
    CheckIs(B, TJsonArray);
    A := B as TJsonArray;
    CheckEquals(0, A.Count);
    CheckEquals(0, A.Capacity);
  finally
    B.Free;
  end;

  B := TJsonBaseObject.Parse('    []   ');
  try
    Check(B <> nil, 'B <> nil');
    CheckIs(B, TJsonArray);
    A := B as TJsonArray;
    CheckEquals(0, A.Count);
    CheckEquals(0, A.Capacity);
  finally
    B.Free;
  end;
end;

procedure TestTJsonBaseObject.TestParse;
var
  B: TJsonBaseObject;
  O: TJsonObject;
  A: TJsonArray;
begin
  B := TJsonBaseObject.Parse('{ "Key": "Value" }');
  try
    CheckNotNull(B, 'B <> nil');
    CheckIs(B, TJsonObject);
    O := B as TJsonObject;
    CheckEquals(1, O.Count);
    Check(O.Capacity >= O.Count, 'O.Capacity >= O.Count');
    CheckTrue(O.Contains('Key'));
    Check(O.Types['Key'] = jdtString, 'jdtString expected');
    CheckEquals('Value', O.S['Key']);
  finally
    B.Free;
  end;

  B := TJsonBaseObject.Parse('{ "Key": "Value", "SecondKey": "SecondValue" }');
  try
    CheckNotNull(B, 'B <> nil');
    CheckIs(B, TJsonObject);
    O := B as TJsonObject;
    CheckEquals(2, O.Count);
    Check(O.Capacity >= O.Count, 'O.Capacity >= O.Count');

    CheckTrue(O.Contains('Key'));
    Check(O.Types['Key'] = jdtString, 'jdtString expected');
    CheckEquals('Value', O.S['Key']);

    CheckTrue(O.Contains('SecondKey'));
    Check(O.Types['SecondKey'] = jdtString, 'jdtString expected');
    CheckEquals('SecondValue', O.S['SecondKey']);
  finally
    B.Free;
  end;

  B := TJsonBaseObject.Parse('{ "Key": "Value", "SecondKey": "SecondValue", "Array": [ "Item1", "Item2" ] }');
  try
    CheckNotNull(B, 'B <> nil');
    CheckIs(B, TJsonObject);
    O := B as TJsonObject;
    CheckEquals(3, O.Count);
    Check(O.Capacity >= O.Count, 'O.Capacity >= O.Count');

    CheckTrue(O.Contains('Key'));
    Check(O.Types['Key'] = jdtString, 'jdtString expected');
    CheckEquals('Value', O.S['Key']);

    CheckTrue(O.Contains('SecondKey'));
    Check(O.Types['SecondKey'] = jdtString, 'jdtString expected');
    CheckEquals('SecondValue', O.S['SecondKey']);

    CheckTrue(O.Contains('Array'));
    Check(O.Types['Array'] = jdtArray, 'jdtString expected');
    CheckEquals(2, O.A['Array'].Count);
    Check(O.A['Array'].Types[0] = jdtString, 'jdtString expected');
    CheckEquals('Item1', O.A['Array'].S[0]);
    Check(O.A['Array'].Types[1] = jdtString, 'jdtString expected');
    CheckEquals('Item2', O.A['Array'].S[1]);
  finally
    B.Free;
  end;

  B := TJsonBaseObject.Parse('{ "Key": [] }');
  try
    CheckNotNull(B, 'B <> nil');
    CheckIs(B, TJsonObject);
    O := B as TJsonObject;
    CheckEquals(1, O.Count);
    Check(O.Capacity >= O.Count, 'O.Capacity >= O.Count');
    CheckTrue(O.Contains('Key'));
    Check(O.Types['Key'] = jdtArray, 'jdtArray expected');
    CheckEquals(0, O.A['Key'].Count);
  finally
    B.Free;
  end;

  B := TJsonBaseObject.Parse('{ "Key": [ { "Key": 123, "Bool": true, "Bool2": false, "Null": null, "Float": -1.234567890E10, "Int64": 1234567890123456789 } ] }');
  try
    CheckNotNull(B, 'B <> nil');
    CheckIs(B, TJsonObject);
    O := B as TJsonObject;
    CheckEquals(1, O.Count);
    Check(O.Capacity >= O.Count, 'O.Capacity >= O.Count');
    CheckTrue(O.Contains('Key'));
    Check(O.Types['Key'] = jdtArray, 'jdtArray expected');
    A := O.A['Key'];
    CheckEquals(1, A.Count);

    Check(A.Types[0] = jdtObject, 'jdtObject expected');
    CheckEquals(6, A.O[0].Count);

    CheckTrue(A.O[0].Contains('Key'));
    Check(A.O[0].Types['Key'] = jdtInt, 'jdtInt expected');
    CheckEquals(123, A.O[0].I['Key']);

    CheckTrue(A.O[0].Contains('Bool'));
    Check(A.O[0].Types['Bool'] = jdtBool, 'jdtBool expected');
    CheckEquals(True, A.O[0].B['Bool']);

    CheckTrue(A.O[0].Contains('Bool2'));
    Check(A.O[0].Types['Bool2'] = jdtBool, 'jdtBool expected');
    CheckEquals(False, A.O[0].B['Bool2']);

    CheckTrue(A.O[0].Contains('Null'));
    Check(A.O[0].Types['Null'] = jdtObject, 'jdtObject expected');
    Check(A.O[0].O['Null'] = nil);

    CheckTrue(A.O[0].Contains('Float'));
    Check(A.O[0].Types['Float'] = jdtFloat, 'jdtFloat expected');
    CheckEquals(-1.234567890E10, A.O[0].F['Float'], 0.00001);

    CheckTrue(A.O[0].Contains('Int64'));
    Check(A.O[0].Types['Int64'] = jdtLong);
    CheckEquals(1234567890123456789, A.O[0].L['Int64'], 'jdtInt64 expected');
  finally
    B.Free;
  end;

  // Array

  B := TJsonBaseObject.Parse('[ "Item1" ]');
  try
    CheckNotNull(B, 'B <> nil');
    CheckIs(B, TJsonArray);
    A := B as TJsonArray;
    CheckEquals(1, A.Count);
    Check(A.Capacity >= A.Count, 'A.Capacity >= A.Count');
    Check(A.Types[0] = jdtString);
    CheckEquals('Item1', A.S[0]);
  finally
    B.Free;
  end;

  B := TJsonBaseObject.Parse('[ "Item1", "Item2"] ]');
  try
    CheckNotNull(B, 'B <> nil');
    CheckIs(B, TJsonArray);
    A := B as TJsonArray;
    CheckEquals(2, A.Count);
    Check(A.Capacity >= A.Count, 'A.Capacity >= A.Count');

    Check(A.Types[0] = jdtString);
    CheckEquals('Item1', A.S[0]);

    Check(A.Types[1] = jdtString);
    CheckEquals('Item2', A.S[1]);
  finally
    B.Free;
  end;

  B := TJsonBaseObject.Parse('[ "Item1", "Item2", {} ] ]');
  try
    CheckNotNull(B, 'B <> nil');
    CheckIs(B, TJsonArray);
    A := B as TJsonArray;
    CheckEquals(3, A.Count);
    Check(A.Capacity >= A.Count, 'A.Capacity >= A.Count');

    Check(A.Types[0] = jdtString);
    CheckEquals('Item1', A.S[0]);

    Check(A.Types[1] = jdtString);
    CheckEquals('Item2', A.S[1]);

    Check(A.Types[2] = jdtObject);
    CheckEquals(0, A.O[2].Count);
  finally
    B.Free;
  end;

  B := TJsonBaseObject.Parse('[ [1, 2, 3], [4, 5, 6] ]');
  try
    CheckNotNull(B, 'B <> nil');
    CheckIs(B, TJsonArray);
    A := B as TJsonArray;
    CheckEquals(2, A.Count);
    Check(A.Types[0] = jdtArray);
    Check(A.Types[1] = jdtArray);
    CheckEquals(3, A.A[0].Count);
    CheckEquals(3, A.A[1].Count);

    CheckEquals(1, A.A[0].I[0]);
    CheckEquals(2, A.A[0].I[1]);
    CheckEquals(3, A.A[0].I[2]);
    CheckEquals(4, A.A[1].I[0]);
    CheckEquals(5, A.A[1].I[1]);
    CheckEquals(6, A.A[1].I[2]);

    CheckEqualsString('[[1,2,3],[4,5,6]]', A.ToJSON);
  finally
    B.Free;
  end;
end;

procedure TestTJsonBaseObject.TestParseFromStream;
var
  Stream: TStringStream;
  B: TJsonBaseObject;
begin
  Stream := TStringStream.Create('', TEncoding.UTF8, False);
  try
    B := TJsonBaseObject.ParseFromStream(Stream);
    try
      CheckNull(B, 'B = nil');
      CheckEquals(Stream.Size, Stream.Position);
    finally
      B.Free;
    end;
  finally
    Stream.Free;
  end;

  Stream := TStringStream.Create('{}', TEncoding.UTF8, False);
  try
    B := TJsonBaseObject.ParseFromStream(Stream);
    try
      CheckNotNull(B, 'B <> nil');
      CheckEquals(Stream.Size, Stream.Position);
      CheckIs(B, TJsonObject);
      CheckEquals(0, TJsonObject(B).Count);
    finally
      B.Free;
    end;
  finally
    Stream.Free;
  end;

  Stream := TStringStream.Create('{}', TEncoding.Unicode, False);
  try
    B := TJsonBaseObject.ParseFromStream(Stream, TEncoding.Unicode);
    try
      CheckNotNull(B, 'B <> nil');
      CheckEquals(Stream.Size, Stream.Position);
      CheckIs(B, TJsonObject);
      CheckEquals(0, TJsonObject(B).Count);
    finally
      B.Free;
    end;
  finally
    Stream.Free;
  end;

  Stream := TStringStream.Create(' [ "Item" ] ', TEncoding.Unicode, False);
  try
    B := TJsonBaseObject.ParseFromStream(Stream, TEncoding.Unicode);
    try
      CheckNotNull(B, 'B <> nil');
      CheckEquals(Stream.Size, Stream.Position);
      CheckIs(B, TJsonArray);
      CheckEquals(1, TJsonArray(B).Count);
    finally
      B.Free;
    end;
  finally
    Stream.Free;
  end;

  Stream := TStringStream.Create(' [ "Item" ] ', TEncoding.Default, False);
  try
    B := TJsonBaseObject.ParseFromStream(Stream, TEncoding.Default);
    try
      CheckNotNull(B, 'B <> nil');
      CheckEquals(Stream.Size, Stream.Position);
      CheckIs(B, TJsonArray);
      CheckEquals(1, TJsonArray(B).Count);
    finally
      B.Free;
    end;
  finally
    Stream.Free;
  end;
end;

procedure TestTJsonBaseObject.LoadFromEmptyStream;
var
  Stream: TStringStream;
  B: TJsonBaseObject;
begin
  Stream := TStringStream.Create('', TEncoding.UTF8, False);
  try
    B := TJsonBaseObject.Parse('{ "Key": "Value" }');
    try
      CheckIs(B, TJsonObject);
      CheckEquals(1, TJsonObject(B).Count);
      B.LoadFromStream(Stream);
    finally
      B.Free;
    end;
  finally
    Stream.Free;
  end;
end;

procedure TestTJsonBaseObject.LoadFromArrayStreamIntoObject;
var
  Stream: TStringStream;
  B: TJsonBaseObject;
begin
  Stream := TStringStream.Create('[]', TEncoding.UTF8, False);
  try
    B := TJsonBaseObject.Parse('{}');
    try
      CheckIs(B, TJsonObject);
      B.LoadFromStream(Stream);
    finally
      B.Free;
    end;
  finally
    Stream.Free;
  end;
end;

procedure TestTJsonBaseObject.TestLoadFromStream;
var
  Stream: TStringStream;
  B: TJsonBaseObject;
begin
  CheckException(LoadFromEmptyStream, EJsonParserException);
  CheckException(LoadFromArrayStreamIntoObject, EJsonParserException);

  Stream := TStringStream.Create('{}', TEncoding.UTF8, False);
  try
    B := TJsonBaseObject.Parse('{ "Key": "Value" }');
    try
      CheckIs(B, TJsonObject);
      CheckEquals(1, TJsonObject(B).Count);
      B.LoadFromStream(Stream);
      CheckEquals(Stream.Size, Stream.Position);
      CheckEquals(0, TJsonObject(B).Count);
    finally
      B.Free;
    end;
  finally
    Stream.Free;
  end;

  Stream := TStringStream.Create('{ }', TEncoding.UTF8, False);
  try
    B := TJsonBaseObject.Parse('{ "Key": "Value" }');
    try
      CheckIs(B, TJsonObject);
      CheckEquals(1, TJsonObject(B).Count);
      B.LoadFromStream(Stream);
      CheckEquals(Stream.Size, Stream.Position);
      CheckEquals(0, TJsonObject(B).Count);
    finally
      B.Free;
    end;
  finally
    Stream.Free;
  end;

  Stream := TStringStream.Create(' [ "Item" ] ', TEncoding.Unicode, False);
  try
    B := TJsonBaseObject.ParseFromStream(Stream, TEncoding.Unicode);
    try
      CheckNotNull(B, 'B <> nil');
      CheckEquals(Stream.Size, Stream.Position);
      CheckIs(B, TJsonArray);
      CheckEquals(1, TJsonArray(B).Count);
    finally
      B.Free;
    end;
  finally
    Stream.Free;
  end;
end;

procedure TestTJsonBaseObject.TestSaveToStream;
var
  Stream: TStringStream;
  B: TJsonBaseObject;
begin
  Stream := TStringStream.Create('', TEncoding.UTF8, False);
  try
    B := TJsonBaseObject.Parse('{ "Entry1": "Value1" }');
    try
      CheckNotNull(B, 'B <> nil');
      CheckIs(B, TJsonObject);
      CheckEquals(1, TJsonObject(B).Count);
      CheckEquals('Value1', TJsonObject(B).S['Entry1']);

      B.SaveToStream(Stream);
      Check(Stream.Position > 0, 'Stream.Position > 0');
      Check(Stream.Size > 0, 'Stream.Size > 0');
      CheckEquals('{"Entry1":"Value1"}', Stream.DataString);
    finally
      B.Free;
    end;
  finally
    Stream.Free;
  end;

  Stream := TStringStream.Create('', TEncoding.UTF8, False);
  try
    B := TJsonBaseObject.Parse('{ "Entry1": "Value1" }');
    try
      CheckNotNull(B, 'B <> nil');
      CheckIs(B, TJsonObject);
      CheckEquals(1, TJsonObject(B).Count);
      CheckEquals('Value1', TJsonObject(B).S['Entry1']);

      B.SaveToStream(Stream, False);
      Check(Stream.Position > 0, 'Stream.Position > 0');
      Check(Stream.Size > 0, 'Stream.Size > 0');
      CheckEquals('{' + JsonSerializationConfig.LineBreak +
                  JsonSerializationConfig.IndentChar + '"Entry1": "Value1"' + JsonSerializationConfig.LineBreak +
                  '}' + JsonSerializationConfig.LineBreak, Stream.DataString);
    finally
      B.Free;
    end;
  finally
    Stream.Free;
  end;
end;

procedure TestTJsonBaseObject.TestSaveToLines;
var
  Lines: TStrings;
  B: TJsonBaseObject;
  S: string;
begin
  Lines := TStringList.Create;
  try
    CheckEquals(#9, JsonSerializationConfig.IndentChar);

    S :=
      '{' + #13#10 +
      #9'"Entry1": "Value1",' + #13#10 +
      #9'"Entry2": "Value2",' + #13#10 +
      #9'"Entry3": true,' + #13#10 +
      #9'"Entry3": false,' + #13#10 +
      #9'"Entry4": null,' + #13#10 +
      #9'"Entry5": 1234567890123456789,' + #13#10 +
//      #9'"Entry6": 1.12233445E5,' + #13#10 +
      #9'"Entry6": 112233.445,' + #13#10 +
      #9'"Entry7": {' + #13#10 +
      #9#9'"Array": [' + #13#10 +
      #9#9#9'"Item1",' + #13#10 +
      #9#9#9'"Item2"' + #13#10 +
      #9#9']' + #13#10 +
      #9'},' + #13#10 +
      #9'"Entry8": {},' + #13#10 +
      #9'"Entry9": []' + #13#10 +
      '}' + #13#10;

    B := TJsonBaseObject.Parse(S);
    try
      CheckNotNull(B, 'B <> nil');
      CheckIs(B, TJsonObject);

      Lines.LineBreak := #13#10;
      B.SaveToLines(Lines);
      CheckEqualsString(S, Lines.Text);
    finally
      B.Free;
    end;
  finally
    Lines.Free;
  end;
end;

procedure TestTJsonBaseObject.TestToJSON;
var
  B: TJsonBaseObject;
  S, CompactS: string;
begin
  B := TJsonBaseObject.Parse('{}');
  try
    CheckEquals('{}', B.ToJSON);
    CheckEquals('{}', B.ToJSON(True));
    CheckEquals('{}'+JsonSerializationConfig.LineBreak, B.ToJSON(False));
  finally
    B.Free;
  end;

  B := TJsonBaseObject.Parse('{ "Key": "Value" }');
  try
    CheckEquals('{"Key":"Value"}', B.ToJSON);
    CheckEquals('{"Key":"Value"}', B.ToJSON(True));
    CheckEquals('{' + JsonSerializationConfig.LineBreak +
                JsonSerializationConfig.IndentChar + '"Key": "Value"' + JsonSerializationConfig.LineBreak +
                '}'+JsonSerializationConfig.LineBreak, B.ToJSON(False));
  finally
    B.Free;
  end;

  CheckEquals(#9, JsonSerializationConfig.IndentChar);
  S :=
    '{' + JsonSerializationConfig.LineBreak +
    #9'"Entry1": "Value1",' + JsonSerializationConfig.LineBreak +
    #9'"Entry2": "Value2",' + JsonSerializationConfig.LineBreak +
    #9'"Entry3": true,' + JsonSerializationConfig.LineBreak +
    #9'"Entry3": false,' + JsonSerializationConfig.LineBreak +
    #9'"Entry4": null,' + JsonSerializationConfig.LineBreak +
    #9'"Entry5": 1234567890123456789,' + JsonSerializationConfig.LineBreak +
    #9'"Entry6": 112233.445,' + JsonSerializationConfig.LineBreak +
    #9'"Entry7": {' + JsonSerializationConfig.LineBreak +
    #9#9'"Array": [' + JsonSerializationConfig.LineBreak +
    #9#9#9'"Item1",' + JsonSerializationConfig.LineBreak +
    #9#9#9'"Item2"' + JsonSerializationConfig.LineBreak +
    #9#9']' + JsonSerializationConfig.LineBreak +
    #9'},' + JsonSerializationConfig.LineBreak +
    #9'"Entry8": {},' + JsonSerializationConfig.LineBreak +
    #9'"Entry9": []' + JsonSerializationConfig.LineBreak +
    '}' + JsonSerializationConfig.LineBreak;

  CompactS :=
    '{' +
    '"Entry1":"Value1",' +
    '"Entry2":"Value2",' +
    '"Entry3":true,' +
    '"Entry3":false,' +
    '"Entry4":null,' +
    '"Entry5":1234567890123456789,' +
    '"Entry6":112233.445,' +
    '"Entry7":{"Array":["Item1","Item2"]},' +
    '"Entry8":{},' +
    '"Entry9":[]' +
    '}';
  B := TJsonBaseObject.Parse(S);
  try
    CheckEquals(CompactS, B.ToJSON);
    CheckEquals(S, B.ToJSON(False));
  finally
    B.Free;
  end;
end;

procedure TestTJsonBaseObject.TestToString;
var
  B: TJsonBaseObject;
  S: string;
begin
  S :=
    '{' +
    '"Entry1":"Value1",' +
    '"Entry2":"Value2",' +
    '"Entry3":true,' +
    '"Entry3":false,' +
    '"Entry4":null,' +
    '"Entry5":1234567890123456789,' +
    '"Entry6":112233.445,' +
    '"Entry7":{"Array":["Item1","Item2"]},' +
    '"Entry8":{},' +
    '"Entry9":[]' +
    '}';
  B := TJsonBaseObject.Parse(S);
  try
    CheckEquals(B.ToJSON, B.ToString);
  finally
    B.Free;
  end;
end;

procedure TestTJsonBaseObject.ParseUtf8BrokenJSON1;
begin
  TJsonBaseObject.ParseUtf8('{').Free;
end;

procedure TestTJsonBaseObject.ParseUtf8BrokenJSON2;
begin
  TJsonBaseObject.ParseUtf8('{ "foo" }').Free;
end;

procedure TestTJsonBaseObject.ParseUtf8BrokenJSON3;
begin
  TJsonBaseObject.ParseUtf8('{ "foo", "bar" }').Free;
end;

procedure TestTJsonBaseObject.ParseUtf8BrokenJSON4;
begin
  TJsonBaseObject.ParseUtf8('{ "foo": "bar" "foo" }').Free;
end;

procedure TestTJsonBaseObject.ParseUtf8BrokenJSON5;
begin
  TJsonBaseObject.ParseUtf8('[ 1 ').Free;
end;

procedure TestTJsonBaseObject.ParseUtf8BrokenJSON6;
begin
  TJsonBaseObject.ParseUtf8('[ "abc\').Free;
end;

procedure TestTJsonBaseObject.ParseUtf8BrokenJSON7;
begin
  TJsonBaseObject.ParseUtf8('[ "abc\n\').Free;
end;

procedure TestTJsonBaseObject.TestParseUtf8BrokenJSON;
begin
  CheckException(ParseUtf8BrokenJSON1, EJsonParserException);
  CheckException(ParseUtf8BrokenJSON2, EJsonParserException);
  CheckException(ParseUtf8BrokenJSON3, EJsonParserException);
  CheckException(ParseUtf8BrokenJSON4, EJsonParserException);
  CheckException(ParseUtf8BrokenJSON5, EJsonParserException);
  CheckException(ParseUtf8BrokenJSON6, EJsonParserException);
  CheckException(ParseUtf8BrokenJSON7, EJsonParserException);
end;

procedure TestTJsonBaseObject.ParseBrokenJSON1;
begin
  TJsonBaseObject.Parse('{').Free;
end;

procedure TestTJsonBaseObject.ParseBrokenJSON2;
begin
  TJsonBaseObject.Parse('{ "foo" }').Free;
end;

procedure TestTJsonBaseObject.ParseBrokenJSON3;
begin
  TJsonBaseObject.Parse('{ "foo", "bar" }').Free;
end;

procedure TestTJsonBaseObject.ParseBrokenJSON4;
begin
  TJsonBaseObject.Parse('{ "foo": "bar" "foo" }').Free;
end;

procedure TestTJsonBaseObject.ParseBrokenJSON5;
begin
  TJsonBaseObject.Parse('[ 1 ').Free;
end;

procedure TestTJsonBaseObject.ParseBrokenJSON6;
begin
  TJsonBaseObject.Parse('[ "abc\').Free;
end;

procedure TestTJsonBaseObject.ParseBrokenJSON7;
begin
  TJsonBaseObject.Parse('[ "abc\n\').Free;
end;

procedure TestTJsonBaseObject.TestParseBrokenJSON;
begin
  CheckException(ParseBrokenJSON1, EJsonParserException);
  CheckException(ParseBrokenJSON2, EJsonParserException);
  CheckException(ParseBrokenJSON3, EJsonParserException);
  CheckException(ParseBrokenJSON4, EJsonParserException);
  CheckException(ParseBrokenJSON5, EJsonParserException);
  CheckException(ParseBrokenJSON6, EJsonParserException);
  CheckException(ParseBrokenJSON7, EJsonParserException);
end;

procedure TestTJsonBaseObject.TestDateTimeToJSON;
var
  S: string;
  ExpectDt, dt: TDateTime;
begin
  ExpectDt := EncodeDate(2015, 2, 14);
    S := TJsonBaseObject.DateTimeToJSON(ExpectDt, True);
    Dt := TJsonBaseObject.JSONToDateTime(S);
    CheckEquals(ExpectDt, Dt, 'expected datetime: ' + DateTimeToStr(ExpectDt) + ', returned: ' + DateTimeToStr(Dt));

    S := TJsonBaseObject.DateTimeToJSON(ExpectDt, False);
    Dt := TJsonBaseObject.JSONToDateTime(S);
    CheckEquals(ExpectDt, Dt, 'expected datetime: ' + DateTimeToStr(ExpectDt) + ', returned: ' + DateTimeToStr(Dt));

  ExpectDt := EncodeDate(2000, 2, 29);
    S := TJsonBaseObject.DateTimeToJSON(ExpectDt, False);
    Dt := TJsonBaseObject.JSONToDateTime(S);
    CheckEquals(ExpectDt, Dt, 'expected datetime: ' + DateTimeToStr(ExpectDt) + ', returned: ' + DateTimeToStr(Dt));

    S := TJsonBaseObject.DateTimeToJSON(ExpectDt, True);
    Dt := TJsonBaseObject.JSONToDateTime(S);
    CheckEquals(ExpectDt, Dt, 'expected datetime: ' + DateTimeToStr(ExpectDt) + ', returned: ' + DateTimeToStr(Dt));

  ExpectDt := EncodeDate(2000, 2, 29) + EncodeTime(1, 2, 3, 4);
    S := TJsonBaseObject.DateTimeToJSON(ExpectDt, False);
    Dt := TJsonBaseObject.JSONToDateTime(S);
    CheckEquals(ExpectDt, Dt, 'expected datetime: ' + DateTimeToStr(ExpectDt) + ', returned: ' + DateTimeToStr(Dt));

    S := TJsonBaseObject.DateTimeToJSON(ExpectDt, True);
    Dt := TJsonBaseObject.JSONToDateTime(S);
    CheckEquals(ExpectDt, Dt, 'expected datetime: ' + DateTimeToStr(ExpectDt) + ', returned: ' + DateTimeToStr(Dt));

  ExpectDt := EncodeDate(2014, 1, 1) + EncodeTime(5, 4, 2, 1);
    S := TJsonBaseObject.DateTimeToJSON(ExpectDt, False);
    Dt := TJsonBaseObject.JSONToDateTime(S);
    CheckEquals(ExpectDt, Dt, 'expected datetime: ' + DateTimeToStr(ExpectDt) + ', returned: ' + DateTimeToStr(Dt));

    S := TJsonBaseObject.DateTimeToJSON(ExpectDt, True);
    Dt := TJsonBaseObject.JSONToDateTime(S);
    CheckEquals(ExpectDt, Dt, 'expected datetime: ' + DateTimeToStr(ExpectDt) + ', returned: ' + DateTimeToStr(Dt));

  ExpectDt := EncodeDate(2016, 9, 29);
    S := TJsonBaseObject.DateTimeToJSON(ExpectDt, False);
    Dt := TJsonBaseObject.JSONToDateTime(S);
    CheckEquals(ExpectDt, Dt, 'expected datetime: ' + DateTimeToStr(ExpectDt) + ', returned: ' + DateTimeToStr(Dt));

    S := TJsonBaseObject.DateTimeToJSON(ExpectDt, True);
    Dt := TJsonBaseObject.JSONToDateTime(S);
    CheckEquals(ExpectDt, Dt, 'expected datetime: ' + DateTimeToStr(ExpectDt) + ', returned: ' + DateTimeToStr(Dt));

  TJsonBaseObject.JSONToDateTime('2009-01-01T12:00:00+01:00');
  TJsonBaseObject.JSONToDateTime('2009-01-01T12:00:00+0100');
  TJsonBaseObject.JSONToDateTime('2015-02-14T22:58+01:00');
  TJsonBaseObject.JSONToDateTime('2015-02-14T22:58+0100');
  CheckNotEquals(0, TJsonBaseObject.JSONToDateTime('2015-02-14T22:58'));
end;

procedure TestTJsonBaseObject.TestEmptyString;
var
  Json: TJsonObject;
begin
  Json := TJsonObject.Create;
  try
    Json.S['Name'] := '';
    CheckEqualsString('{"Name":""}', Json.ToJSON);
  finally
    Json.Free;
  end;
end;

{$IFDEF SUPPORTS_UTF8STRING}
procedure TestTJsonBaseObject.TestToUTF8JSON;
var
  B: TJsonBaseObject;
  U: UTF8String;
  Bytes: TBytes;
  ExpectedBytes: TBytes;
  CompactS, S: string;
  I: Integer;
begin
  B := TJsonBaseObject.ParseUtf8('{ "Key": "Value" }');
  try
    // Compact=True
    U := B.ToUtf8JSON;
    B.ToUtf8JSON(Bytes);
    ExpectedBytes := TEncoding.UTF8.GetBytes('{"Key":"Value"}');

    Check(Length(U) > 0);
    Check(Length(Bytes) > 0);
    CheckEquals(Length(ExpectedBytes), Length(U));
    CheckEquals(Length(ExpectedBytes), Length(Bytes));
    CheckEqualsMem(@ExpectedBytes[0], Pointer(U), Length(U));
    CheckEqualsMem(@ExpectedBytes[0], @Bytes[0], Length(Bytes));

    // Compact=False
    U := B.ToUtf8JSON(False);
    B.ToUtf8JSON(Bytes, False);
    ExpectedBytes := TEncoding.UTF8.GetBytes(
      '{' + JsonSerializationConfig.LineBreak +
      JsonSerializationConfig.IndentChar + '"Key": "Value"' + JsonSerializationConfig.LineBreak +
      '}' + JsonSerializationConfig.LineBreak
    );
    Check(Length(U) > 0);
    Check(Length(Bytes) > 0);
    CheckEquals(Length(ExpectedBytes), Length(U));
    CheckEquals(Length(ExpectedBytes), Length(Bytes));
    CheckEqualsMem(@ExpectedBytes[0], Pointer(U), Length(U));
    CheckEqualsMem(@ExpectedBytes[0], @Bytes[0], Length(Bytes));
  finally
    B.Free;
  end;

  // Test flush buffer
  CompactS := '{';
  for I := 0 to 100000 do
    CompactS := CompactS + '"Key' + IntToStr(I) + '":"Value",';
  CompactS := CompactS + '"Key":"Value"}';

  S := '{' + JsonSerializationConfig.LineBreak;
  for I := 0 to 100000 do
    S := S + JsonSerializationConfig.IndentChar + '"Key' + IntToStr(I) + '": "Value",' + JsonSerializationConfig.LineBreak;
  S := S + JsonSerializationConfig.IndentChar + '"Key": "Value"' + JsonSerializationConfig.LineBreak +
       '}' + JsonSerializationConfig.LineBreak;

  B := TJsonBaseObject.Parse(CompactS);
  try
    U := B.ToUtf8JSON;
    B.ToUtf8JSON(Bytes);
    ExpectedBytes := TEncoding.UTF8.GetBytes(CompactS);

    Check(Length(U) > 0);
    Check(Length(Bytes) > 0);
    CheckEquals(Length(ExpectedBytes), Length(U));
    CheckEquals(Length(ExpectedBytes), Length(Bytes));
    CheckEqualsMem(@ExpectedBytes[0], Pointer(U), Length(U));
    CheckEqualsMem(@ExpectedBytes[0], @Bytes[0], Length(Bytes));

    U := B.ToUtf8JSON(False);
    B.ToUtf8JSON(Bytes, False);
    ExpectedBytes := TEncoding.UTF8.GetBytes(S);

    Check(Length(U) > 0);
    Check(Length(Bytes) > 0);
    CheckEquals(Length(ExpectedBytes), Length(U));
    CheckEquals(Length(ExpectedBytes), Length(Bytes));
    CheckEqualsMem(@ExpectedBytes[0], Pointer(U), Length(U));
    CheckEqualsMem(@ExpectedBytes[0], @Bytes[0], Length(Bytes));
  finally
    B.Free;
  end;
end;
{$ENDIF SUPPORTS_UTF8STRING}

procedure TestTJsonBaseObject.TestInt64MaxIntX2;
var
  S: String;
  Value: Int64;
  JsonObject: TJsonObject;
begin
  Value := 2 * Int64(MaxInt); // 4294967294
  S := Format('{ "num": %d }', [Value]);

  JsonObject := TJsonObject.Parse(S) as TJsonObject;
  try
    CheckEquals(Value, JsonObject.L['num']);
  finally
    JsonObject.Free;
  end;

  S := '{"no":-1}';
  JsonObject := TJsonObject.Parse(S) as TJSONObject;
  try
    Value := JsonObject.L['no']; // <===== error : n is not -1
    CheckEquals(-1, Value);
  finally
    JsonObject.Free;
  end;
end;

procedure TestTJsonBaseObject.ObjectToVariantException;
var
  B: TJsonBaseObject;
  O: TJsonObject;
  V: Variant;
begin
  B := TJsonObject.Parse('{ "Object": {} }');
  try
    O := B as TJsonObject;
    V := O['Object'].VariantValue;
  finally
    B.Free;
  end;
end;

procedure TestTJsonBaseObject.ArrayToVariantException;
var
  B: TJsonBaseObject;
  O: TJsonObject;
  V: Variant;
begin
  B := TJsonObject.Parse('{ "Array": [] }');
  try
    O := B as TJsonObject;
    V := O['Array'].VariantValue;
  finally
    B.Free;
  end;
end;

procedure TestTJsonBaseObject.UnassigendVariantException;
var
  O: TJsonObject;
begin
  O := TJsonObject.Create;
  try
    O['Key'].VariantValue := Unassigned;
  finally
    O.Free;
  end;
end;

procedure TestTJsonBaseObject.TestVariant;
var
  B: TJsonBaseObject;
  O: TJsonObject;
  V: Variant;
begin
  B := TJsonObject.Parse('{ "Key": 123, "Bool": true, "Bool2": false, "Null": null, "Float": -1.234567890E10, "Int64": 1234567890123456789, "Object": {}, "Array": [1, 2] }');
  try
    O := B as TJsonObject;

    // did this here because right now we can't auto parse datetime values
    O.D['DateTime'] := TJsonBaseObject.JSONToDateTime('2014-12-31T23:59:59.999Z');
    O.DUtc['UtcDateTime'] := TJsonBaseObject.JSONToDateTime('2014-12-31T23:59:59.999Z', False);

    Check(O['Key'].VariantValue = 123, 'Int to Variant');
    Check(O['Bool'].VariantValue = True, 'Boolean to Variant');
    Check(O['Null'].VariantValue = Null, 'null to Variant');
    Check(CompareFloatRel(O['Float'].VariantValue, -1.234567890E10), 'Float to Variant');
    Check(CompareFloatRel(O['DateTime'].VariantValue, TJsonBaseObject.JSONToDateTime('2014-12-31T23:59:59.999Z')), 'DateTime to Variant');
    Check(CompareFloatRel(O['UtcDateTime'].VariantValue, TJsonBaseObject.JSONToDateTime('2014-12-31T23:59:59.999Z')), 'UtcDateTime to Variant (local time)');
    Check(O['Int64'].VariantValue = 1234567890123456789, 'Int64 to Variant');

    CheckException(ObjectToVariantException, EJsonCastException, 'Object to Variant exception');
    CheckException(ArrayToVariantException, EJsonCastException, 'Array to Variant exception');
    CheckException(UnassigendVariantException, EJsonCastException, 'VariantValue := Unassigend; exception');

    V := 'Hello';
    O['Key'] := V;
    Check(O['Key'].Typ = jdtString);
    CheckEquals('Hello', O['Key'], 'Variant to String');

    V := 1234567890;
    O['Key'] := V;
    Check(O['Key'].Typ = jdtInt);
    CheckEquals(1234567890, O['Key'], 'Variant to Integer');

    V := 1234567890123456;
    O['Key'] := V;
    Check(O['Key'].Typ = jdtLong);
    CheckEquals(1234567890123456, O['Key'], 'Variant to Int64');

    V := -1.2;
    O['Key'] := V;
    Check(O['Key'].Typ = jdtFloat);
    Check(CompareFloatRel(-1.2, O['Key']), 'Variant to Float');

    V := TJsonBaseObject.JSONToDateTime('2014-12-31T23:59:59.999Z');
    O['Key'] := V;
    Check(O['Key'].Typ = jdtDateTime);
    Check(CompareFloatRel(TJsonBaseObject.JSONToDateTime('2014-12-31T23:59:59.999Z'), O['Key']), 'Variant to DateTime');

    V := True;
    O['Key'] := V;
    Check(O['Key'].Typ = jdtBool);
    CheckTrue(O['Key'], 'Variant to Boolean');

    V := Null;
    O['Key'] := V;
    Check(O['Key'].Typ = jdtObject);
    Check(O['Key'].ObjectValue = nil);

    V := O['NotSet'];
    Check(O['NotSet'].Typ = jdtNone);
    Check(VarIsEmpty(V), 'Variant unassigned');

  finally
    B.Free;
  end;
end;

procedure TestTJsonBaseObject.NoNullConvertToValueTypesException;
var
  O: TJsonObject;
begin
  JsonSerializationConfig.NullConvertsToValueTypes := False;
  O := TJsonObject.Create;
  try
    O['Null'] := Null;
    O.S['Null'];
  finally
    O.Free;
  end;
end;

procedure TestTJsonBaseObject.NullObjectToArrayException;
var
  O: TJsonObject;
begin
  O := TJsonObject.Create;
  try
    O['Null'] := Null;

    JsonSerializationConfig.NullConvertsToValueTypes := True;
    O.A['Null'];
    JsonSerializationConfig.NullConvertsToValueTypes := False;
    O.A['Null'];
  finally
    O.Free;
  end;
end;

procedure TestTJsonBaseObject.TestVariantNull;
var
  O: TJsonObject;
  DefaultValue: Boolean;
begin
  DefaultValue := JsonSerializationConfig.NullConvertsToValueTypes;
  try
    CheckFalse(JsonSerializationConfig.NullConvertsToValueTypes, 'NullConvertsToValueTypes default is not False');

    CheckException(NoNullConvertToValueTypesException, EJsonCastException, 'Null to value types');

    O := TJsonObject.Create;
    try
      O['Null'] := Null;

      JsonSerializationConfig.NullConvertsToValueTypes := True;
      CheckEqualsString('', O.S['Null']);
      CheckEquals(0, O.I['Null']);
      CheckEquals(0, O.L['Null']);
      CheckEquals(0.0, O.F['Null']);
      CheckEquals(0.0, O.F['Null']);
      CheckEquals(False, O.B['Null']);
      CheckSame(nil, O.O['Null']);

      CheckException(NullObjectToArrayException, EJsonCastException, 'Null object to array');
    finally
      O.Free;
    end;
  finally
    JsonSerializationConfig.NullConvertsToValueTypes := DefaultValue;
  end;
end;

procedure TestTJsonBaseObject.TestUInt64;
var
  S1, S2: string;
  Json: TJsonObject;
begin
  S1 := '{"long_val":15744383709429629494,"long_str":"15744383709429629494"}';
  Json := TJsonObject.Parse(S1) as TJsonObject;
  try
    S2 := Json.ToJSON;
    CheckEquals(S1, S2, 'UInt64 mismatch');
  finally
    Json.Free;
  end;
end;

procedure JsonProgress(Data: Pointer; Percentage: Integer; Position, Size: NativeInt);
var
  Test: TestTJsonBaseObject;
  Index: Integer;
begin
  Test := TestTJsonBaseObject(Data);
  Index := Length(Test.FProgressSteps);
  SetLength(Test.FProgressSteps, Index + 1);
  Test.FProgressSteps[Index] := Position;
end;

procedure TestTJsonBaseObject.TestProgress;
const
  S = '{"fieldname":"abcdefghijklmnopqrstuvwxyz","next":{"test":"test", "data":1234}}';
var
  Json: TJsonObject;
  Progress: TJsonReaderProgressRec;
  I: Integer;
  LargeJson: {$IFDEF SUPPORTS_UTF8STRING}UTF8String{$ELSE}TBytes{$ENDIF};
begin
  // Call Progress if byte position changed
  FProgressSteps := nil;
  {$IFDEF SUPPORTS_UTF8STRING}
  Json := TJDOJsonArray.ParseUtf8(S, Progress.Init(JsonProgress, Self, 1)) as TJsonObject;
  {$ELSE}
  Json := TJDOJsonArray.Parse(S, Progress.Init(JsonProgress, Self, 1)) as TJsonObject;
  {$ENDIF SUPPORTS_UTF8STRING}
  try
    CheckTrue(Length(FProgressSteps) > 2);

    CheckEquals(0, FProgressSteps[0]);
    CheckEquals(Length(S) * SizeOf(Byte), FProgressSteps[Length(FProgressSteps) - 1]);

    // values must be monotonically increasing
    I := 1;
    while I < Length(FProgressSteps) do
    begin
      CheckTrue(FProgressSteps[I - 1] < FProgressSteps[I], 'monotonically increasing');
      Inc(I);
    end;

    for I := 0 to 100000 do
      Json.A['MyArray'].Add('Index: ' + IntToStr(I));
    {$IFDEF SUPPORTS_UTF8STRING}
    LargeJson := Json.ToUtf8JSON();
    {$ELSE}
    Json.ToUtf8JSON(LargeJson);
    {$ENDIF SUPPORTS_UTF8STRING}
  finally
    Json.Free;
  end;

  // Call Progress only if percentage changed
  FProgressSteps := nil;
  {$IFDEF SUPPORTS_UTF8STRING}
  Json := TJDOJsonArray.ParseUtf8(LargeJson, Progress.Init(JsonProgress, Self)) as TJsonObject;
  {$ELSE}
  Json := TJDOJsonArray.Parse(LargeJson, TEncoding.UTF8, 0, -1, Progress.Init(JsonProgress, Self)) as TJsonObject;
  {$ENDIF SUPPORTS_UTF8STRING}
  try
    CheckTrue(Length(FProgressSteps) > 2);
    CheckEquals(100 + 1, Length(FProgressSteps)); // 0, 1, 2, ..., 99, 100

    CheckEquals(0, FProgressSteps[0]);
    CheckEquals(Length(LargeJson) * SizeOf(Byte), FProgressSteps[Length(FProgressSteps) - 1]);

    // values must be monotonically increasing
    I := 1;
    while I < Length(FProgressSteps) do
    begin
      CheckTrue(FProgressSteps[I - 1] < FProgressSteps[I], 'monotonically increasing');
      Inc(I);
    end;
  finally
    Json.Free;
  end;
end;

procedure TestTJsonBaseObject.TestSyntaxErrors;
begin
  try
    TJsonBaseObject.ParseUtf8('{ "abc": '#13#10'"val'#10'ue", . }').Free;
    CheckTrue(False, 'EJsonParserSyntaxException was not raised');
  except
    on E: EJsonParserException do
    begin
      CheckEquals(2, E.LineNum, 'LineNum');
      CheckEquals(5, E.Column, 'Column');
      CheckEquals(15, E.Position, 'Position');
    end
    else
      CheckTrue(False, 'EJsonParserSyntaxException was not raised');
  end;

  try
    TJsonBaseObject.ParseUtf8('{ "abc": '#13#10'"value');
    CheckTrue(False, 'EJsonParserSyntaxException was not raised');
  except
    on E: EJsonParserException do
    begin
      CheckEquals(2, E.LineNum, 'LineNum');
      CheckEquals(1, E.Column, 'Column');
      CheckEquals(11, E.Position, 'Position');
    end
    else
      CheckTrue(False, 'EJsonParserSyntaxException was not raised');
  end;

  try
    TJsonBaseObject.ParseUtf8('{ "abc": '#13#10'"value", . }').Free;
    CheckTrue(False, 'EJsonParserSyntaxException was not raised');
  except
    on E: EJsonParserException do
    begin
      CheckEquals(2, E.LineNum, 'LineNum');
      CheckEquals(11, E.Column, 'Column');
      CheckEquals(21, E.Position, 'Position');
    end
    else
      CheckTrue(False, 'EJsonParserSyntaxException was not raised');
  end;
end;

procedure TestTJsonBaseObject.TestDateTimeToJsonString;
var
  O: TJsonObject;
  S: string;
  dt: TDateTime;
begin
  dt := EncodeDate(2018, 08, 13) {+ EncodeTime(0, 0, 0, 0)};
  O := TJsonObject.Create;
  try
    O.D['DateTime'] := dt;
    O.DUtc['UtcDateTime'] := dt;
    S := O.ToJSON;

    CheckEquals('{"DateTime":"' + TJsonBaseObject.DateTimeToJSON(dt, True) + '","UtcDateTime":"2018-08-13T00:00:00.0Z"}', S, 'DateTime/UtcDateTime as string');
  finally
    O.Free;
  end;

  O := TJsonBaseObject.Parse(S) as TJsonObject;
  try
    CheckEquals(dt, O.D['DateTime']);
    CheckEquals(dt, O.DUtc['UtcDateTime']);
  finally
    O.Free;
  end;
end;

procedure TestTJsonBaseObject.TestDoubleDotZeroWrite;
var
  O: TJsonObject;
begin
  O := TJsonObject.Create;
  try
    O.FromUtf8JSON('{ "data": 1.0 }');
    CheckEquals('{"data":1.0}', O.ToJSON(True));

    O.FromUtf8JSON('{ "data": 1 }');
    CheckEquals('{"data":1}', O.ToJSON(True));

    O.FromUtf8JSON('{ "data": 1.123 }');
    CheckEquals('{"data":1.123}', O.ToJSON(True));
  finally
    O.Free;
  end;
end;

procedure TestTJsonBaseObject.TestEscapeAllNonASCIIChars;
var
  O: TJsonObject;
begin
  O := TJsonObject.Create;
  try
    O.FromUtf8JSON('{ "data": "\u0080\u1234" }');
    CheckEquals('{"data":"'#$0080#$1234'"}', O.ToJSON(True));

    JsonSerializationConfig.EscapeAllNonASCIIChars := True;
    CheckEquals('{"data":"\u0080\u1234"}', O.ToJSON(True));
  finally
    JsonSerializationConfig.EscapeAllNonASCIIChars := False;
    O.Free;
  end;
end;

procedure TestTJsonBaseObject.TestToJsonSerializationConfig;
var
  O: TJsonObject;
  Config: TJsonSerializationConfig;
begin
  O := TJsonObject.Create;
  try
    Config.InitDefaults;
    Config.IndentChar := '  ';
    Config.EscapeAllNonASCIIChars := True;

    O.FromUtf8JSON('{ "data": "\u0080\u1234" }');
    CheckEquals('{'#10'  "data": "\u0080\u1234"'#10'}'#10, O.ToJSON(Config, False));
  finally
    O.Free;
  end;
end;

{ TestTJsonArray }

procedure TestTJsonArray.SetUp;
begin
end;

procedure TestTJsonArray.TearDown;
begin
end;

procedure TestTJsonArray.TestClear;
var
  A: TJsonArray;
begin
  A := TJsonArray.Create;
  try
    A.FromUtf8JSON('[ 1, 2, { "Key": { "Key": [] } }, true, false, null, 1234, 1234567890123456789, 1.12 ]');
    CheckEquals(9, A.Count);
    A.Clear;
    CheckEquals(0, A.Count);
    A.Add('Hello');
    CheckEquals(1, A.Count);
    A.Clear;
    CheckEquals(0, A.Count);
  finally
    A.Free;
  end;
end;

procedure TestTJsonArray.TestDelete;
var
  A: TJsonArray;
begin
  A := TJsonArray.Create;
  try
    A.FromUtf8JSON('[ 1, 2, { "Key": { "Key": [] } }, true, false, null, 1234, 1234567890123456789, 1.12 ]');
    CheckEquals(9, A.Count);
    CheckEquals(1, A.I[0]);
    A.Delete(0);
    CheckEquals(8, A.Count);
    CheckEquals(2, A.I[0]);

    CheckEquals(1234567890123456789, A.L[6]);
    CheckEqualsString('1.12', A.S[7]);
    A.Delete(7);
    CheckEquals(7, A.Count);
    CheckEquals(1234567890123456789, A.L[6]);
  finally
    A.Free;
  end;
end;

procedure TestTJsonArray.TestAssign;
var
  A, A2: TJsonArray;
begin
  A := TJsonArray.Create;
  try
    A.FromUtf8JSON('[ 1, 2, { "Key": { "Key": [ 123, 2.4, "Hello" ] } }, true, false, null, 1234, 1234567890123456789, 1.12 ]');
    CheckEquals(9, A.Count);

    A2 := TJsonArray.Create;
    try
      A2.Assign(A);
      CheckEqualsString(A.ToJSON, A2.ToJSON);
    finally
      A2.Free;
    end;
  finally
    A.Free;
  end;
end;

procedure TestTJsonArray.TestAdd;
var
  A: TJsonArray;
begin
  A := TJsonArray.Create;
  try
    A.FromUtf8JSON('[ 1, 2, { "Key": { "Key": [] } }, true, false, null, 1234, 1234567890123456789, 1.12 ]');
    CheckEquals(9, A.Count);

    A.FromJSON('[ 1, 2, { "Key": { "Key": [] } }, true, false, null, 1234, 1234567890123456789, 1.12 ]');
    CheckEquals(9, A.Count);
    A.Add('Value9');
    CheckEquals(10, A.Count);
    Check(A.Types[9] = jdtString, 'jdtString');
    CheckEqualsString('Value9', A.S[9]);

    A.Add(10);
    CheckEquals(11, A.Count);
    Check(A.Types[10] = jdtInt, 'jdtInt');
    CheckEquals(10, A.I[10]);

    A.Add(1234567890123456789);
    CheckEquals(12, A.Count);
    Check(A.Types[11] = jdtLong, 'jdtLong');
    CheckEquals(1234567890123456789, A.L[11]);

    A.Add(1.12E5);
    CheckEquals(13, A.Count);
    Check(A.Types[12] = jdtFloat, 'jdtFloat');
    CheckEquals(1.12E5, A.F[12]);

    A.Add(TJsonBaseObject.JSONToDateTime('2014-12-31T23:59:59.999Z'));
    CheckEquals(14, A.Count);
    Check(A.Types[13] = jdtDateTime, 'jdtDateTime');
    CheckEquals(TJsonBaseObject.JSONToDateTime('2014-12-31T23:59:59.999Z'), A.F[13]);

    A.Add(False);
    CheckEquals(15, A.Count);
    Check(A.Types[14] = jdtBool, 'jdtBool');
    CheckEquals(False, A.B[14]);

    A.Add(TJsonObject(nil));
    CheckEquals(16, A.Count);
    Check(A.Types[15] = jdtObject, 'jdtObject');
    CheckNull(A.O[15]);

    A.Add(TJsonArray.Create);
    CheckEquals(17, A.Count);
    Check(A.Types[16] = jdtArray, 'jdtArray');
    CheckNotNull(A.A[16]);

    A.AddObject;
    CheckEquals(18, A.Count);
    Check(A.Types[17] = jdtObject, 'jdtObject');
    CheckNotNull(A.O[17]);

    A.AddArray;
    CheckEquals(19, A.Count);
    Check(A.Types[18] = jdtArray, 'jdtArray');
    CheckNotNull(A.A[18]);

    A.AddObject(nil);
    CheckEquals(20, A.Count);
    Check(A.Types[19] = jdtObject, 'jdtObject');
    CheckNull(A.O[19]);

    A.Add(12345678901234567890);
    CheckEquals(21, A.Count);
    Check(A.Types[20] = jdtULong, 'jdtULong');
    CheckEquals(12345678901234567890, A.U[20]);

    A.AddUtcDateTime(TJsonBaseObject.JSONToDateTime('2014-12-31T23:59:59.999Z', False));
    CheckEquals(22, A.Count);
    Check(A.Types[21] = jdtUtcDateTime, 'jdtUtcDateTime');
    CheckEquals(TJsonBaseObject.JSONToDateTime('2014-12-31T23:59:59.999Z', False), A.F[21]); // Float is the native Utc-DateTime value
    CheckEquals(TJsonBaseObject.JSONToDateTime('2014-12-31T23:59:59.999Z'), A.D[21]); // converted to local time
    CheckEquals(TJsonBaseObject.JSONToDateTime('2014-12-31T23:59:59.999Z', False), A.DUtc[21]);

  finally
    A.Free;
  end;
end;

procedure TestTJsonArray.TestInsert;
var
  A: TJsonArray;
begin
  A := TJsonArray.Create;
  try
    A.FromJSON('[ 1, 2 ]');
    CheckEquals(2, A.Count);

    A.Insert(1, 'Key');
    CheckEquals(3, A.Count);
    CheckEqualsString('Key', A.S[1]);

    A.Insert(0, 'AAA');
    CheckEquals(4, A.Count);
    CheckEqualsString('AAA', A.S[0]);

    A.Insert(4, 'ZZZ');
    CheckEquals(5, A.Count);
    CheckEqualsString('ZZZ', A.S[4]);

    A.Insert(0, 12345678901234567890);
    CheckEquals(6, A.Count);
    Check(A.Types[0] = jdtULong, 'jdtULong');
    CheckEquals(12345678901234567890, A.U[0]);

    A.Insert(0, -1234567890123456789);
    CheckEquals(7, A.Count);
    Check(A.Types[0] = jdtLong, 'jdtLong');
    CheckEquals(-1234567890123456789, A.L[0]);

    CheckEquals('[-1234567890123456789,12345678901234567890,"AAA",1,"Key",2,"ZZZ"]', A.ToJSON);
  finally
    A.Free;
  end;
end;

procedure TestTJsonArray.TestExtract;
var
  A, HelloA: TJsonArray;
  Foo: TJsonObject;
begin
  Foo := nil;
  HelloA := nil;
  try
    A := TJsonArray.Create;
    try
      A.AddObject.S['foo'] := 'bar';
      A.AddArray.Add('Hello World!');
      CheckEquals(2, A.Count);

      Foo :=  A.ExtractObject(0);
      CheckNotNull(Foo);
      CheckEquals(1, A.Count);
      HelloA := A.ExtractArray(0);
      CheckNotNull(HelloA);
      CheckEquals(0, A.Count);

    finally
      A.Free;
    end;
    CheckEquals(TJsonObject.ClassName, Foo.ClassName);
    CheckEquals(TJsonArray.ClassName, HelloA.ClassName);
  finally
    Foo.Free;
    HelloA.Free;
  end;
end;

procedure TestTJsonArray.TestEnumerator;
var
  A: TJsonArray;
  Value: TJsonDataValueHelper;
  Typ: TJsonDataType;
  FoundTypes: array[TJsonDataType] of Boolean;
begin
  A := TJsonArray.Create;
  try
    for Typ in [Low(TJsonDataType)..High(TJsonDataType)] do
      FoundTypes[Typ] := False;

    A.FromJSON('[ 42, { "Key": "Value" }, true, null, 1234567890123456789, 12345678901234567890, 1.12, "String", [ 1, 2, 3 ] ]');

    // did this here because right now we can't auto parse datetime values
    A.Add(TJsonBaseObject.JSONToDateTime('2014-12-31T23:59:59.999Z'));
    A.AddUtcDateTime(TJsonBaseObject.JSONToDateTime('2014-12-31T23:59:59.999Z', False));

    for Value in A do
    begin
      Typ := Value.Typ;
      if (Value.Typ = jdtObject) and (Value.ObjectValue = nil) then
        Typ := jdtNone;

      FoundTypes[Typ] := True;

      case Typ of
        jdtString:  CheckEquals('String', Value, 'String value');
        jdtInt:     CheckEquals(42, Value, 'Int value');
        jdtLong:    CheckEquals(1234567890123456789, Value, 'Long value');
        jdtULong:   CheckEquals(12345678901234567890, Value.ULongValue, 'ULong value');
        jdtFloat:   CheckEquals(1.12, Value, 0.001, 'Float value');
        jdtDateTime: CheckEquals(TJsonBaseObject.JSONToDateTime('2014-12-31T23:59:59.999Z'), TDateTime(Value), 0.001, 'DateTime value');        // may be we need to add extended vartype overload?
        jdtUtcDateTime: CheckEquals(TJsonBaseObject.JSONToDateTime('2014-12-31T23:59:59.999Z', False), Value.UtcDateTimeValue, 0.001, 'UtcDateTime value');        // may be we need to add extended vartype overload?
        jdtBool:    CheckEquals(True, Value, 'Boolean value');
        jdtArray:   CheckEquals(3, Value.Count, 'Array count');
        jdtObject:  CheckEquals('Value', Value.S['Key'], 'Object value');
      end;
    end;

    for Typ in [Low(TJsonDataType)..High(TJsonDataType)] do
      CheckTrue(FoundTypes[Typ], TJsonBaseObject.DataTypeNames[Typ]);
  finally
    A.Free;
  end;
end;


{ TestTJsonObject }

procedure TestTJsonObject.SetUp;
begin
end;

procedure TestTJsonObject.TearDown;
begin
end;

procedure TestTJsonObject.TestAssign;
var
  O, O2: TJsonObject;
begin
  O := TJsonObject.Create;
  try
    O.FromJSON('{ "Key": "Value", "Array": [ 123, "Abc", true, null, 12.3, 98765432109876, { "Msg": "Exception\tClass\n" } ] }');
    O2 := TJsonObject.Create;
    try
      O2.Assign(O);
      CheckEqualsString(O.ToJSON, O2.ToJSON);
    finally
      O2.Free;
    end;
  finally
    O.Free;
  end;
end;

procedure TestTJsonObject.TestClear;
var
  O: TJsonObject;
begin
  O := TJsonObject.Create;
  try
    O.FromJSON('{ "Key": { "Key": [] }, "Delphi": "XE7" }');
    CheckEquals(2, O.Count);
    O.Clear;
    CheckEquals(0, O.Count);
    O.S['Data'] := 'Hello';
    CheckEquals(1, O.Count);
    O.Clear;
    CheckEquals(0, O.Count);
  finally
    O.Free;
  end;
end;

procedure TestTJsonObject.TestRemove;
var
  O: TJsonObject;
begin
  O := TJsonObject.Create;
  try
    O.FromJSON('{ "Key": { "Key": [] }, "Delphi": "XE7" }');
    CheckEquals(2, O.Count);
    O.Remove('Key');
    CheckEquals(1, O.Count);
    CheckFalse(O.Contains('Key'));
    CheckTrue(O.Contains('Delphi'));
    CheckEqualsString('XE7', O.S['Delphi']);
    CheckFalse(O.Contains('delphi'));
    O.Remove('delphi');
    CheckTrue(O.Contains('Delphi'));
    CheckEquals(1, O.Count);
    O.Remove('Delphi');
    CheckEquals(0, O.Count);
  finally
    O.Free;
  end;
end;

procedure TestTJsonObject.TestDelete;
var
  O: TJsonObject;
begin
  O := TJsonObject.Create;
  try
    O.FromJSON('{ "Key": { "Key": [] }, "Delphi": "XE7" }');
    CheckEquals(2, O.Count);
    O.Delete(0);
    CheckEquals(1, O.Count);
    CheckFalse(O.Contains('Key'));
    CheckTrue(O.Contains('Delphi'));
    CheckEqualsString('XE7', O.S['Delphi']);
    O.Delete(0);
    CheckEquals(0, O.Count);
  finally
    O.Free;
  end;
end;

procedure TestTJsonObject.TestIndexOf;
var
  O: TJsonObject;
begin
  O := TJsonObject.Create;
  try
    O.FromJSON('{ "Key": { "Key": [] }, "Delphi": "XE7" }');
    CheckEquals(2, O.Count);
    CheckEquals(1, O.IndexOf('Delphi'));
    CheckEquals(-1, O.IndexOf('delphi'));
    CheckEquals(0, O.IndexOf('Key'));
    CheckEquals(-1, O.IndexOf('key'));
  finally
    O.Free;
  end;
end;

procedure TestTJsonObject.TestContains;
var
  O: TJsonObject;
begin
  O := TJsonObject.Create;
  try
    O.FromJSON('{ "Key": { "Key": [] }, "Delphi": "XE7" }');
    CheckEquals(2, O.Count);
    CheckTrue(O.Contains('Delphi'));
    CheckFalse(O.Contains('delphi'));
    CheckTrue(O.Contains('Key'));
    CheckFalse(O.Contains('key'));
  finally
    O.Free;
  end;
end;

procedure TestTJsonObject.TestAccess;
var
  O: TJsonObject;
  dt: TDateTime;
  JsonUtcTime: string;
begin
  dt := EncodeDate(2015, 12, 31) + EncodeTime(23, 59, 59, 999);
  JsonUtcTime := TJsonBaseObject.DateTimeToJSON(dt, True); // make the unit test region independent

  CheckTrue(JsonSerializationConfig.UseUtcTime);

  O := TJsonObject.Create;
  try
    CheckEquals(0, O.Count);

    O.S['Key'] := 'Value';
    CheckTrue(O.Contains('Key'));
    CheckFalse(O.Contains('key'));
    CheckEquals(0, O.IndexOf('Key'));
    O.O['MyObject'].S['Str'] := 'World';
    O.O['MyObject'].I['Int'] := -123;
    O.O['MyObject'].L['Int64'] := -1234567890123456789;
    O.O['MyObject'].F['Float'] := -12.3456789;
    O.O['MyObject'].D['DateTime'] := dt;
    O.O['MyObject'].B['Bool'] := True;
    O.O['MyObject'].O['Null'] := nil;
    O.A['MyArray'].Add('Hello');

    CheckEquals('{"Key":"Value","MyObject":{"Str":"World","Int":-123,"Int64":-1234567890123456789,"Float":-12.3456789,"DateTime":"' + JsonUtcTime + '","Bool":true,"Null":null},"MyArray":["Hello"]}', O.ToJSON);

    CheckEqualsString('Value', O.S['Key']);
    CheckEqualsString('World', O.O['MyObject'].S['Str']);
    CheckEquals(-123, O.O['MyObject'].I['Int']);
    CheckEquals(-1234567890123456789, O.O['MyObject'].L['Int64']);
    CheckEquals(-12.3456789, O.O['MyObject'].F['Float'], 0.0000000001);
    CheckEquals(dt, O.O['MyObject'].F['DateTime'], 0.0000000001);
    CheckEquals(True, O.O['MyObject'].B['Bool']);
    CheckNull(O.O['MyObject'].O['Null']);
    CheckEquals('Hello', O.A['MyArray'].S[0]);

    // implicit type casts
    O.S['LongStr'] := '-123456789012345';
    O.S['IntStr'] := '123456';
    O.S['FloatStr'] := '12.345';
    O.S['BoolStr'] := 'true';

    CheckEquals(-123456789012345, O.L['LongStr']);
    CheckEquals(-123456789012345, O.F['LongStr']);
    CheckEquals(False, O.B['LongStr']);

    CheckEquals(123456, O.I['IntStr']);
    CheckEquals(123456, O.L['IntStr']);
    CheckEquals(123456, O.F['IntStr'], 0.0000000001);
    CheckEquals(False, O.B['IntStr']);

    CheckEquals(12, O.I['FloatStr']);
    CheckEquals(12, O.L['FloatStr']);
    CheckEquals(12.345, O.F['FloatStr'], 0.0000000001);
    CheckEquals(False, O.B['FloatStr']);

    CheckEquals(True, O.B['BoolStr']);

    CheckEqualsString('-123', O.O['MyObject'].S['Int']);
    CheckEquals(-123, O.O['MyObject'].I['Int']);
    CheckEquals(-123, O.O['MyObject'].L['Int']);
    CheckEquals(-123, O.O['MyObject'].F['Int'], 0.0000000001);
    CheckEquals(True, O.O['MyObject'].B['Int']);

    CheckEqualsString('-1234567890123456789', O.O['MyObject'].S['Int64']);
    //CheckEquals(-1234567890123456789, O.O['MyObject'].I['Int64']);
    CheckEquals(-1234567890123456789, O.O['MyObject'].L['Int64']);
    CheckEquals(FloatToStr(-1234567890123456789), FloatToStr(O.O['MyObject'].F['Int64']));
    CheckEquals(True, O.O['MyObject'].B['Int64']);

    CheckEqualsString('-12.3456789', O.O['MyObject'].S['Float']);
    CheckEquals(-12, O.O['MyObject'].I['Float']);
    CheckEquals(-12, O.O['MyObject'].L['Float']);
    CheckEquals(FloatToStr(-12.3456789), FloatToStr(O.O['MyObject'].F['Float']));
    CheckEquals(True, O.O['MyObject'].B['Float']);

    CheckEqualsString('true', O.O['MyObject'].S['Bool']);
    CheckEquals(1, O.O['MyObject'].I['Bool']);
    CheckEquals(1, O.O['MyObject'].L['Bool']);
    CheckEquals(1, O.O['MyObject'].F['Bool']);
    CheckEquals(True, O.O['MyObject'].B['Bool']);

  finally
    O.Free;
  end;
end;

procedure TestTJsonObject.TestAutoArrayAndObjectCreationOnAccess;
var
  O: TJsonObject;
begin
  O := TJsonObject.Create;
  try
    CheckEqualsString('', O.S['NewString']); // default ''
    CheckEquals(0, O.I['NewInt']);           // default 0
    CheckEquals(0, O.L['NewInt64']);         // default 0
    CheckEquals(0, O.F['NewFloat']);         // default 0
    CheckEquals(False, O.B['NewBool']);      // default false
    CheckNotNull(O.O['NewObject']);          // auto creation
    CheckNotNull(O.A['NewArray']);           // auto creation

    CheckEquals('{"NewObject":{},"NewArray":[]}', O.ToJSON);
  finally
    O.Free;
  end;
end;

procedure TestTJsonObject.TestEasyAccess;
var
  O: TJsonObject;
  S: string;
  I: Integer;
  L: Int64;
  F: Double;
  B: Boolean;
  Obj: TJsonObject;
  Arr: TJsonArray;
begin
  O := TJsonObject.Create;
  try
    S := O['NewString'];   // default ''
    I := O['NewInt'];      // default 0
    L := O['NewInt64'];    // default 0
    F := O['NewFloat'];    // default 0
    B := O['NewBool'];     // default false
    Arr := O['NewArray'];  // auto creation
    Obj := O['NewObject']; // auto creation

    CheckEqualsString('', S);
    CheckEquals(0, I);
    CheckEquals(0, L);
    CheckEquals(0, F);
    CheckEquals(False, B);
    CheckNotNull(Arr);
    CheckNotNull(Obj);

    O['NewObject']['Value'] := 'Hello';
    S := O['NewObject']['Value'];
    CheckEquals('Hello', S);

    O['NewObject']['IntValue'] := 10;
    I := O['NewObject']['IntValue'];
    CheckEquals(10, I);

    O['NewObject']['FloatValue'] := -55.1;
    F := O['NewObject']['FloatValue'];
    CheckEquals(-55.1, F, 0.000000001);

    O['NewObject']['Array'] := TJsonArray.Create;
    O['NewObject']['Array'].ArrayValue.Add(1);
    I := O['NewObject']['Array'].Items[0];
    CheckEquals(1, I);

    CheckEquals('{"NewArray":[],"NewObject":{"Value":"Hello","IntValue":10,"FloatValue":-55.1,"Array":[1]}}', O.ToJSON);
  finally
    O.Free;
  end;
end;

type
  {$M+}
  TMyObject = class(TObject)
  private
    FMyString: string;
    FMyInt: Integer;
    FMyInt64: Int64;
    FMyDouble: Double;
    FMyBool: Boolean;
    FMyDateTime: TDateTime;
    FMyExtraDateTime: TDateTime;
    FMyVariant: Variant;
    FNotStored: string;
  published
    property MyString: string read FMyString write FMyString;
    property MyInt: Integer read FMyInt write FMyInt;
    property MyInt64: Int64 read FMyInt64 write FMyInt64;
    property MyDouble: Double read FMyDouble write FMyDouble;
    property MyBool: Boolean read FMyBool write FMyBool;
    property MyDateTime: TDateTime read FMyDateTime write FMyDateTime;
    property MyExtraDateTime: TDateTime read FMyExtraDateTime write FMyExtraDateTime;
    property MyVariant: Variant read FMyVariant write FMyVariant;
    property NotStored: string read FNotStored write FNotStored stored False;
  end;

procedure TestTJsonObject.TestToSimpleObject;
var
  O: TJsonObject;
  Obj: TMyObject;
  dt: TDateTime;
begin
  dt := EncodeDate(2014, 12, 31) + EncodeTime(23, 59, 59, 999);

  // Case Sensitive
  O := TJsonObject.Create;
  try
    O['MyString'] := 'Hello World!';
    O['MyInt'] := 135711;
    O['MyInt64'] := 135711131719232931;
    O['MyDouble'] := 3.14159265359;
    O['MyBool'] := True;
    O['MyDateTime'] := TJsonBaseObject.DateTimeToJSON(dt, True);
    O['MyExtraDateTime'] := dt;
    O['MyVariant'] := 'Variant String';
    O['NotStored'] := 'xxxxxx';

    Obj := TMyObject.Create;
    try
      Obj.NotStored := 'aaa';
      O.ToSimpleObject(Obj);
      CheckEqualsString('Hello World!', Obj.MyString);
      CheckEquals(135711, Obj.MyInt);
      CheckEquals(135711131719232931, Obj.MyInt64);
      CheckEquals(3.14159265359, Obj.MyDouble, 0.000000000001);
      CheckEquals(True, Obj.MyBool);
      CheckEquals(dt, Obj.MyDateTime);
      CheckEquals(dt, Obj.MyExtraDateTime);
      Check(Obj.MyVariant = 'Variant String', 'Obj.MyVariant = ''Variant String''');
      CheckEquals('aaa', Obj.NotStored);

      O['MyVariant'] := 123;
      O.ToSimpleObject(Obj);
      Check(Obj.MyVariant = 123, 'Obj.MyVariant = 123');
    finally
      Obj.Free;
    end;
  finally
    O.Free;
  end;

  // Case-Insensitive
  O := TJsonObject.Create;
  try
    O['mystring'] := 'Hello World!';
    O['myint'] := 135711;
    O['myint64'] := 135711131719232931;
    O['mydouble'] := 3.14159265359;
    O['mybool'] := True;
    O['mydatetime'] := TJsonBaseObject.DateTimeToJSON(dt, True);
    O['myextradatetime'] := dt;
    O['myvariant'] := 'Variant String';
    O['NotStored'] := 'xxxxxx';

    Obj := TMyObject.Create;
    try
      Obj.NotStored := 'aaa';
      O.ToSimpleObject(Obj, False);
      CheckEqualsString('Hello World!', Obj.MyString);
      CheckEquals(135711, Obj.MyInt);
      CheckEquals(135711131719232931, Obj.MyInt64);
      CheckEquals(3.14159265359, Obj.MyDouble, 0.000000000001);
      CheckEquals(True, Obj.MyBool);
      CheckEquals(dt, Obj.MyDateTime);
      CheckEquals(dt, Obj.MyExtraDateTime);
      Check(Obj.MyVariant = 'Variant String', 'Obj.MyVariant = ''Variant String''');
      CheckEquals('aaa', Obj.NotStored);
    finally
      Obj.Free;
    end;
  finally
    O.Free;
  end;
end;

procedure TestTJsonObject.TestFromSimpleObject;
var
  O: TJsonObject;
  Obj: TMyObject;
  dt: TDateTime;
begin
  dt := EncodeDate(2014, 12, 31) + EncodeTime(23, 59, 59, 999);

  // Case Sensitive
  O := TJsonObject.Create;
  try

    Obj := TMyObject.Create;
    try
      Obj.MyString := 'Hello World!';
      Obj.MyInt := 135711;
      Obj.MyInt64 := 135711131719232931;
      Obj.MyDouble := 3.14159265359;
      Obj.MyBool := False;
      Obj.MyDateTime := dt;
      Obj.MyExtraDateTime := dt;
      Obj.MyVariant := 12.2;
      Obj.NotStored := 'abc';

      O.FromSimpleObject(Obj);
      CheckEquals(8, O.Count);

      CheckEqualsString('Hello World!', O.S['MyString']);
      CheckEquals(135711, O.I['MyInt']);
      CheckEquals(135711131719232931, O.L['MyInt64']);
      CheckEquals(3.14159265359, O.F['MyDouble'], 0.000000000001);
      CheckEquals(False, O.B['MyBool']);
      CheckEquals(dt, O.D['MyDateTime']);
      CheckEquals(dt, O.D['MyExtraDateTime']);
      CheckEquals('12.2', O.S['MyVariant']);
      CheckFalse(O.Contains('NotStored'), 'Contains(''NonStrored''');
    finally
      Obj.Free;
    end;
  finally
    O.Free;
  end;
end;

type
  TMyLowerCamelCaseObject = class(TPersistent)
  private
    FLowerCase: string;
    FAenderung: string;
    FNoCase: Boolean;
  published
    property _NoCase: Boolean read FNoCase write FNoCase;
    property LowerCase: string read FLowerCase write FLowerCase;
    {$IFDEF UNICODE} // Delphi 2005+ compilers allow unicode identifiers, even if that is a very bad idea
    property Änderung: string read FAenderung write FAenderung;
    {$ENDIF UNICODE}
  end;

procedure TestTJsonObject.TestFromSimpleObjectLowerCamelCase;
var
  O: TJsonObject;
  Obj: TMyLowerCamelCaseObject;
begin
  O := TJsonObject.Create;
  try

    Obj := TMyLowerCamelCaseObject.Create;
    try
      Obj._NoCase := True;
      Obj.LowerCase := 'LowerCase';
      {$IFDEF UNICODE} // Delphi 2005+ compilers allow unicode identifiers, even if that is a very bad idea
      Obj.Änderung := 'Änderung';
      {$ENDIF UNICODE}

      O.FromSimpleObject(Obj, True);

      {$IFDEF UNICODE}
      CheckEquals(3, O.Count);
      {$ELSE}
      CheckEquals(2, O.Count);
      {$ENDIF UNICODE}

      CheckEqualsString('_NoCase', O.Names[0]);
      CheckEqualsString('lowerCase', O.Names[1]);
      {$IFDEF UNICODE}
      CheckEqualsString('änderung', O.Names[2]);
      {$ENDIF UNICODE}
    finally
      Obj.Free;
    end;
  finally
    O.Free;
  end;
end;

procedure TestTJsonObject.TestObjectAssign;
var
  O: TJsonObject;
begin
  O := TJsonObject.Create;
  try
    O['MyObject']['Data'] := 'Hello';
    O['MySecondObject'] := O['MyObject']; // creates a copy of MyObject
    O['MySecondObject']['SecondData'] := 12;

    Check(O.O['MyObject'] <> O.O['MySecondObject']); // different instances
    CheckEquals('{"MyObject":{"Data":"Hello"},"MySecondObject":{"Data":"Hello","SecondData":12}}', O.ToJSON);
  finally
    O.Free;
  end;
end;

procedure TestTJsonObject.TestPathError1;
begin
  FJson.FromJSON('{"First":{"Second":{"Third":{"Value":"Hello"}}}}');
  FJson.Path['First[0].'];
end;

procedure TestTJsonObject.TestPathError2;
begin
  FJson.FromJSON('{"First":{"Second":{"Third":{"Value":"Hello"}}}}');
  FJson.Path['First[0].Second[0]'];
end;

procedure TestTJsonObject.TestPathError3;
begin
  FJson.FromJSON('{"First":{"Second":{"Third":{"Value":"Hello"}}}}');
  FJson.Path['First..Second'];
end;

procedure TestTJsonObject.TestPathError4;
begin
  FJson.FromJSON('{"First":{"Second":{"Third":{"Value":"Hello"}}}}');
  FJson.Path['.Second'];
end;

procedure TestTJsonObject.TestPathAccess;
var
  Json: TJsonObject;
begin
  Json := TJsonObject.Parse('{ "First" : { "Second" : { "Third" : { "Fourth" : { "Fifth" : { "Sixth" : "Hello World!" } } } } } }') as TJsonObject;
  try
    CheckEqualsString('Hello World!', Json.Path['First.Second.Third.Fourth.Fifth'].S['Sixth']);


    Json.FromJSON(' { "First" : [ { "Second": { "Third": "Hello World!" } }, { "Fourth": "Nothing to see" }, "String" ] }');

    CheckEqualsString('Hello World!', Json.Path['First'].Items[0].Path['Second.Third']);
    CheckEqualsString('Nothing to see', Json.Path['First[1].Fourth']);
    Check(Json.Path['First'].Typ = jdtArray);
    Check(Json.Path['First[0]'].Typ = jdtObject);
    Check(Json.Path['First[2]'].Typ = jdtString);
    CheckEquals('String', Json.Path['First[2]']);

    Check(Json.Path[''].ObjectValue = Json);
    CheckFalse(Json.Contains(''));
    Check(Json.Path['  '].ObjectValue <> Json);
    CheckTrue(Json.Contains('  '));

    Json.Clear;
    Json.Path['First.Second.Third.Value'] := 'Hello';
    CheckEquals('{"First":{"Second":{"Third":{"Value":"Hello"}}}}', Json.ToJSON());

    Json.Clear;
    Json.Path['ferrcod'] := 2;
    Json.Path['ferrmsg'] := 'Test';
    CheckEquals('{"ferrcod":2,"ferrmsg":"Test"}', Json.ToJSON(True));

    Json.FromJSON(' { "First" : [ { "Second": { "Third": { Value: "Hello World!" } } }, { "Fourth": "Nothing to see" }, "String" ] }');
    CheckEqualsString('Hello World!', Json.Path['First'].Items[0].Path['Second.Third.Value']);
    CheckEqualsString('Nothing to see', Json.Path['First[1].Fourth']);
    Check(Json.Path['First'].Typ = jdtArray);
    Check(Json.Path['First[0]'].Typ = jdtObject);
    Check(Json.Path['First[0].Second'].Typ = jdtObject);
    Check(Json.Path['First[0].Second.Third'].Typ = jdtObject);
    CheckEquals('Hello World!', Json.Path['First[0].Second.Third'].S['Value']);
    Check(Json.Path['First[0].Second.Third.Value'].Typ = jdtString);
    CheckEquals('Hello World!', Json.Path['First[0].Second.Third.Value']);

    Json.FromJSON('{"menu": { "header": "SVG Viewer", "items": [ {"id": "Open"}, {"id": "OpenNew", "label": "Open New"}, null, {"id": "Help"}, {"id": "About", "label": "About Adobe CVG Viewer..."} ] }}');
    CheckEquals('Help', Json.Path['menu.items[3].id']);

    FJson := Json;
    CheckException(TestPathError1, EJsonCastException);
    CheckException(TestPathError2, EJsonCastException);
    CheckException(TestPathError3, EJsonPathException);
    CheckException(TestPathError4, EJsonPathException);
  finally
    FJson := nil;
    Json.Free;
  end;
end;

procedure TestTJsonObject.TestExtract;
var
  HelloA: TJsonArray;
  Obj, Foo: TJsonObject;
begin
  Foo := nil;
  HelloA := nil;
  try
    Obj := TJsonObject.Create;
    try
      Obj.O['foo'].S['value'] := 'bar';
      Obj.A['bar'].Add('Hello World!');
      CheckEquals(2, Obj.Count);

      Foo :=  Obj.ExtractObject('foo');
      CheckNotNull(Foo);
      CheckEquals(1, Obj.Count);
      HelloA := Obj.ExtractArray('bar');
      CheckNotNull(HelloA);
      CheckEquals(0, Obj.Count);

    finally
      Obj.Free;
    end;
    CheckEquals(TJsonObject.ClassName, Foo.ClassName);
    CheckEquals(TJsonArray.ClassName, HelloA.ClassName);
  finally
    Foo.Free;
    HelloA.Free;
  end;
end;

procedure TestTJsonObject.TestEnumerator;
var
  Obj: TJsonObject;
  Pair: TJsonNameValuePair;
  Typ: TJsonDataType;
  FoundTypes: array[TJsonDataType] of Boolean;
begin
  Obj := TJsonObject.Create;
  try
    for Typ in [Low(TJsonDataType)..High(TJsonDataType)] do
      FoundTypes[Typ] := False;

    FoundTypes[jdtDateTime] := True;
    FoundTypes[jdtUtcDateTime] := True;

    Obj.FromJSON('{ "Int": 42, "Object": { "Key": "Value" }, "Bool": true, "Null": null, ' +
                   '"Long": 1234567890123456789, "ULong": 12345678901234567890, "Float": 1.12, ' +
                   '"String": "Hello world!", "Array": [ 1, 2, 3 ] }');

    // did this here because right now we can't auto parse datetime values
    Obj.D['DateTime'] := TJsonBaseObject.JSONToDateTime('2014-12-31T23:59:59.999Z');
    Obj.DUtc['UtcDateTime'] := TJsonBaseObject.JSONToDateTime('2014-12-31T23:59:59.999Z', False);

    for Pair in Obj do
    begin
      Typ := Pair.Value.Typ;
      if (Pair.Value.Typ = jdtObject) and (Pair.Value.ObjectValue = nil) then
        Typ := jdtNone;

      FoundTypes[Typ] := True;

      case Typ of
        jdtString:
          begin
            CheckEquals('String', Pair.Name, 'String name');
            CheckEquals('Hello world!', Pair.Value, 'String value');
          end;

        jdtInt:
          begin
            CheckEquals('Int', Pair.Name, 'Int name');
            CheckEquals(42, Pair.Value, 'Int value');
          end;

        jdtLong:
          begin
            CheckEquals('Long', Pair.Name, 'Long name');
            CheckEquals(1234567890123456789, Pair.Value, 'Long value');
          end;

        jdtULong:
          begin
            CheckEquals('ULong', Pair.Name, 'ULong name');
            CheckEquals(12345678901234567890, Pair.Value.ULongValue, 'ULong value');
          end;

        jdtFloat:
          begin
            CheckEquals('Float', Pair.Name, 'Float name');
            CheckEquals(1.12, Pair.Value, 0.001, 'Float value');
          end;

        jdtDateTime:
          begin
            CheckEquals('DateTime', Pair.Name, 'DateTime name');
            CheckEquals(TJsonBaseObject.JSONToDateTime('2014-12-31T23:59:59.999Z'), Pair.Value, 0.001, 'DateTime value');
          end;

        jdtUtcDateTime:
          begin
            CheckEquals('UtcDateTime', Pair.Name, 'UtcDateTime name');
            CheckEquals(TJsonBaseObject.JSONToDateTime('2014-12-31T23:59:59.999Z', False), Pair.Value, 0.001, 'UtcDateTime value');
          end;

        jdtBool:
          begin
            CheckEquals('Bool', Pair.Name, 'Boolean name');
            CheckEquals(True, Pair.Value, 'Boolean value');
          end;

        jdtArray:
          begin
            CheckEquals('Array', Pair.Name, 'Array count');
            CheckEquals(3, Pair.Value.Count, 'Array count');
          end;

        jdtObject:
          begin
            CheckEquals('Object', Pair.Name, 'Object name');
            CheckEquals('Value', Pair.Value.S['Key'], 'Object value');
          end;
      end;
    end;

    for Typ in [Low(TJsonDataType)..High(TJsonDataType)] do
      CheckTrue(FoundTypes[Typ], TJsonBaseObject.DataTypeNames[Typ]);
  finally
    Obj.Free;
  end;
end;

initialization
  RegisterTest(TestTJsonBaseObject.Suite);
  RegisterTest(TestTJsonArray.Suite);
  RegisterTest(TestTJsonObject.Suite);

end.

