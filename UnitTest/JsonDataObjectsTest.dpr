program JsonDataObjectsTest;

{$IFDEF CONSOLE_TESTRUNNER}
{$APPTYPE CONSOLE}
{$ENDIF}

uses
  DUnitTestRunner,
  JsonDataObjects in '..\Source\JsonDataObjects.pas',
  TestJsonDataObjects in 'TestJsonDataObjects.pas';

{$R *.RES}

begin
  ReportMemoryLeaksOnShutdown := True;
  DUnitTestRunner.RunRegisteredTests;
end.

