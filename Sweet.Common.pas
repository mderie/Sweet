
unit Sweet.Common;

interface

type TSweet = class
  type RMessage = record
    Id : integer;
    Sender : integer;
    Key : integer;
    Value : integer;
  end;

  type TEventHandler = function(const msg : RMessage) : integer;

  const Message_Id_Close = 1;
  // const Message_Id_...

  const Event_Id_Click = 1;
  // const Event_Id_...
end;

implementation

end.

