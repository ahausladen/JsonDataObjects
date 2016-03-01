Json Data Objects
=================

This Delphi unit contains a JSON parser that supports Delphi 2009-10Seattle and the platforms
Win32, Win64 and ARM Android (MacOS and iOS may work).

Clone with GIT
--------------
```
> git clone git@github.com:ahausladen/JsonDataObjects.git
```
or
```
> git clone https://github.com/ahausladen/JsonDataObjects.git
```

This will get you the Json Data Objects repository.

How to install
--------------
1. Clone the JsonDataObjects repository
2. Add the JsonDataObjects.pas unit to your project.

Features
--------
* Fast dual JSON parser for parsing UTF8 and UTF16 without conversion
* Automatic creation of arrays and objects
* Easy access mode with implicit operators
* Compact and formatted output modes
* Variants support
* Null can be auto-typecasted to a value type if JsonSerializationConfig.NullConvertsToValueTypes is set to True
* Progress callback support for loading large JSON strings
* Win32, Win64 and ARM Android support (MacOS and iOS may work)

Usage
-----
Simple example
```Delphi
var
  Obj: TJsonObject;
begin
  Obj := TJsonObject.Parse('{ "foo": "bar", "array": [ 10, 20 ] }') as TJsonObject;
  try
    ShowMessage(Obj['foo']);
    ShowMessage(IntToStr(Obj['array'].Count));
    ShowMessage(IntToStr(Obj['array'].Items[0]));
    ShowMessage(IntToStr(Obj['array'].Items[1]));
  finally
    Obj.Free;
  end;
end;
```

Filling and serializing JSON objects
```Delphi
var
  Obj, ChildObj: TJsonObject;
begin
  Obj := TJsonObject.Create;
  try
    // easy access
    Obj['foo'] := 'bar';
    // normal (and faster) access
    Obj.S['bar'] := 'foo';
    // automatic array creation, Obj is the owner of 'array'
    Obj.A['array'].Add(10);
    Obj.A['array'].Add(20);
    // automatic object creation, 'array' is the owner of ChildObj
    ChildObj := Obj.A['array'].AddObject;
    ChildObj['value'] := 12.3;
    // automatic array creation, ChildObj is the owner of 'subarray'
    ChildObj.A['subarray'].Add(100);
    ChildObj.A['subarray'].Add(200);

    ShowMessage(Obj.ToJSON({Compact:=}False));
  finally
    Obj.Free;
  end;
```
```JSON
{
	"foo": "bar",
	"bar": "foo",
	"array": [
		10,
		20,
		{
			"value": 12.3,
			"subarray": [
				100,
				200
			]
		}
	]
}
```

Copying JSON objects with `Assign`
```Delphi
var
  Obj, ClonedObj: TJsonObject;
begin
  Obj := TJsonObject.ParseUtf8('{ "foo": [ "bar", {}, null, true, false, { "key": "value" } ] }') as TJsonObject;
  try
    ClonedObj := TJsonObject.Create;
    try
      // Make a copy of Obj
      ClonedObj.Assign(Obj);
      ShowMessage(ClonedObj.ToJSON(False));
    finally
      ClonedObj.Free;
    end;
  finally
    Obj.Free;
  end;
end;
```
```JSON
{
	"foo": [
		"bar",
		{},
		null,
		true,
		false,
		{
			"key": "value"
		}
	]
}
```