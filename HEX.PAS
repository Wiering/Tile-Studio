unit Hex;

  { 
      Tile Studio

      Copyright (c) 2000-2017, Mike Wiering, Wiering Software

      Permission is hereby granted, free of charge, to any person obtaining a copy
      of this software and associated documentation files (the "Software"), to deal
      in the Software without restriction, including without limitation the rights
      to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
      copies of the Software, and to permit persons to whom the Software is
      furnished to do so, subject to the following conditions:

      The above copyright notice and this permission notice shall be included in all
      copies or substantial portions of the Software.

      THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
      IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
      FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
      AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
      LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
      OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
      SOFTWARE.
  }


interface

  const
    HexChars: array[0..$F] of Char =
      ('0', '1', '2', '3', '4', '5', '6', '7',
       '8', '9', 'A', 'B', 'C', 'D', 'E', 'F');

  function Hex2 (b: Byte): string;
  function Hex4 (w: Word): string;
  function Hex8 (l: LongInt): string;

implementation

  function Hex2 (b: Byte): string;
  begin
    Hex2 := HexChars[b shr 4] + HexChars[b and $0F];
  end;

  function Hex4 (w: Word): string;
  begin
    Hex4 := Hex2 (Hi (w)) + Hex2 (Lo (w));
  end;

  function Hex8 (l: LongInt): string;
    var
      W: array[0..1] of Word absolute l;
  begin
    Hex8 := Hex4 (W[1]) + Hex4 (W[0]);
  end;

end.
