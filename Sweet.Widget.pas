
unit Sweet.Widget;

interface

type
  TSweetLayout = class;

  TSweetWidget = class
  private
    FLayout : TSweetLayout;
    FLeft : integer;
    FTop : integer;
    FWidth : integer;
    FHeight : integer;
    procedure SetLeft(const value : integer);
    function GetLeft() : integer;
    procedure SetTop(const value : integer);
    function GetTop() : integer;
    procedure SetWidth(const value : integer);
    function GetWidth() : integer;
    procedure SetHeight(const value : integer);
    function GetHeight() : integer;
  public
    constructor Create(const layout : TSweetLayout);
    procedure paint(); virtual; abstract; // Still need a canvas etc...
  published
    property Left : integer read GetLeft write SetLeft;
    property Top : integer read GetTop write SetTop;
    property Width : integer read GetWidth write SetWidth;
    property Height : integer read GetHeight write SetHeight;
  end;

  // A window doesn't have a "parent" layout
  TSweetWindow = class(TSweetWidget)
    //
  end;

  // Nor does the top level layout !
  TSweetLayout = class(TSweetWidget)
    //
  end;

  TSweetButton = class(TSweetWidget)
    //
  end;

  // For classes that are not builtin !
  TSweetCustomWidget = class(TSweetWidget)
    //
  end;

implementation

uses
  System.Rtti; // To find back the widget class based on the value of its class property :)

type
  TWidgetFactory = class
    // ...
  end;

constructor TSweetWidget.Create(const layout : TSweetLayout);
begin
  FLayout := layout;
end;

procedure TSweetWidget.SetLeft(const value : integer);
begin
  FLeft := value;
  paint();
end;

function TSweetWidget.GetLeft() : integer;
begin
  result := FLeft;
end;

procedure TSweetWidget.SetTop(const value : integer);
begin
  FTop := value;
  paint();
end;

function TSweetWidget.GetTop() : integer;
begin
  result := FTop;
end;

procedure TSweetWidget.SetWidth(const value : integer);
begin
  FWidth := value;
  paint();
end;

function TSweetWidget.GetWidth() : integer;
begin
  result := FWidth;
end;

procedure TSweetWidget.SetHeight(const value : integer);
begin
  FHeight := value;
  paint();
end;

function TSweetWidget.GetHeight() : integer;
begin
  result := FHeight;
end;

end.

