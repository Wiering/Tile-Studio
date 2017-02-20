unit Calc;

  { derived from PCALC.PAS, found at Pedt Scragg's site:
    http://www.pedt.demon.co.uk/usenet/ }

  {$I SETTINGS.INC}

interface

  function Evaluate (var Res: LongInt;
                     var Str: ShortString;
                     var Pos: Integer): Boolean;

implementation

  function Evaluate (var Res: LongInt;
                     var Str: ShortString;
                     var Pos: Integer): Boolean;

    var
      error: Boolean;

    procedure Eval (var formula: ShortString;
                    var value: LongInt;
                    var breakpoint: Integer);
      const
        numbers: set of char = ['0'..'9'];
      var
        p, i: Integer;
        ch: char;

        procedure NextP;
        begin
          repeat
            inc (p);
            if p <= length (formula) then
              ch := formula[p]
            else
              ch := #13;
          until (ch <> ' ');
          breakpoint := p;
        end;

        function expr: LongInt;
          var
            e: LongInt;
            e1, e2: LongInt;
            operator: char;

          function smplexpr: LongInt;
            var
              s: LongInt;
              operator: char;

            function term: LongInt;
              var t: LongInt;

              function s_fact: LongInt;

                function fct: LongInt;
                  var
                    start: Integer;
                    f: LongInt;

                  procedure Process_as_number;
                    var
                      code: Integer;
                  begin
                    start := p;
                    repeat
                      nextp;
                    until not (ch in numbers);
                    Val(Copy (formula,start,p-start),f,code);
                  end;

                  procedure Process_as_new_expr;
                  begin
                    nextp;
                    f := expr;
                    if ch = ')' then
                      nextp
                    else
                      breakpoint := p;
                  end;

                  procedure Process_as_standard_function;
                  begin
                    breakpoint := p;
                  end;

                begin  { fct }
                  if ch in numbers then
                    Process_as_number
                  else
                    if ch = '(' then
                      Process_as_new_expr
                    else
                      Process_as_Standard_function;
                  fct := f;
                end;

              begin  { s_fact }
                if Copy (formula,p,3) = 'NOT' then
                begin
                  Inc (p,2);
                  nextp;
                  if fct = 0 then s_fact := 1 else s_fact := 0;
                end
                else
                  if ch = '!' then
                  begin
                    nextp;
                    s_fact := not fct;
                  end
                  else
                    if ch = '-' then
                    begin
                      nextp;
                      s_fact := -fct;
                    end
                    else
                      s_fact := fct;
              end;

            begin  { term }
              t := s_fact;
              term := t;
            end;

          begin  { smplexpr }
            s := term;
            while ch in ['*', '/', '%'] do
            begin
              operator := ch;
              nextp;
              case operator of
                '*': s := s * term;
                '/': s := s div term;
                '%': s := s mod term;
              end;
            end;
            smplexpr := s;
          end;

        begin  { expr }

          if Copy (formula,p,2) = 'IF' then
          begin
            Inc (p, 1);
            nextp;

            e := smplexpr;

            if Copy (formula,p,4) = 'THEN' then
            begin
              Inc (p, 3);
              nextp;

              e1 := smplexpr;

              if Copy (formula,p,4) = 'ELSE' then
              begin
                Inc (p, 3);
                nextp;

                e2 := smplexpr;

                if e <> 0 then e := e1 else e := e2;
              end;
            end;
          end
          else
          begin
            e := smplexpr;

            if Copy (formula,p,3) = 'AND' then
            begin
              Inc (p,2);
              nextp;
              e := byte ((e <> 0) and (smplexpr <> 0));
            end
            else
            if Copy (formula,p,2) = 'OR' then
            begin
              Inc (p);
              nextp;
              e := byte ((e <> 0) or (smplexpr <> 0));
            end
            else
            if Copy (formula,p,3) = 'SHL' then
            begin
              Inc (p,2);
              nextp;
              e := e shl smplexpr;
            end
            else
            if Copy (formula,p,3) = 'SHR' then
            begin
              Inc (p,2);
              nextp;
              e := e shr smplexpr;
            end
            else
            if Copy (formula,p,6) = 'EQUALS' then
            begin
              Inc (p, 5);
              nextp;
              e := Byte (e = smplexpr);
            end
            else
            if Copy (formula,p,5) = 'ABOVE' then
            begin
              Inc (p, 4);
              nextp;
              e := Byte (e > smplexpr);
            end
            else
            if Copy (formula,p,5) = 'BELOW' then
            begin
              Inc (p, 4);
              nextp;
              e := Byte (e < smplexpr);
            end
            else
            if Copy (formula,p,2) = '!=' then
            begin
              Inc (p);
              nextp;
              e := Byte (e <> smplexpr);
            end
            else
              while ch in ['+', '-', '&', '|' {, '?', '<', '=', '>' }] do
              begin
                operator := ch;
                nextp;
                case operator of
                  '+': e := e + smplexpr;
                  '-': e := e - smplexpr;
                  '&': e := e and smplexpr;
                  '|': e := e or smplexpr;
                {
                  '<': e := Byte (e < smplexpr);
                  '=': e := Byte (e = smplexpr);
                  '>': e := Byte (e > smplexpr);
                }
                end;
              end;
          end;

          expr := e;
        end;

    begin {eval}
      for i := 1 to Length (formula) do
        formula[i] := UpCase (formula[i]);

      if formula[1] = '+' then
        Delete (formula,1,1);

      p := 0;
      nextp;
      value := expr;
      error := (ch <> #13);
      breakpoint := p;
    end;

  begin  { Evaluate }
    Eval (Str, Res, Pos);
    Evaluate := not error;
    dec (Pos);
    if Pos < 1 then
      Pos := 1;
  end;

end.

