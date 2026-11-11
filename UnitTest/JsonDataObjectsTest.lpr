program JsonDataObjectsTest;

uses
  simpletestrunner, TestJsonDataObjects, JsonDataObjects;

var
  Runner: TTestRunner;
begin
  Runner := TTestRunner.Create(nil);
  try
    Runner.Initialize;
    Runner.Run;
  finally
    Runner.Free;
  end;
end.

