unit Noise;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

  {$G+}
  {$N+}

  { based on C code by Ken Perlin }

  const
    DEFAULT_NOISE_SIZE = $10000;

  var
    NoiseSizeX: Integer;
    NoiseSizeY: Integer;
    NoiseSizeZ: Integer;

  function Noise1 (x: Real): Real;
  function Noise2 (x, y: Real): Real;
  function Noise3 (x, y, z: Real): Real;

implementation

  const
    B = $100;
    BM = $FF;

    N = $1000;
    NP = 12;  { 2^N }
    NM = $FFF;

  var
    p: array[0 .. B + B + 1] of Integer;
    g3: array[0 .. B + B + 1, 0..2] of Real;
    g2: array[0 .. B + B + 1, 0..1] of Real;
    g1: array[0 .. B + B + 1] of Real;

  function s_curve (t: Real): Real;
  begin
    s_curve := t * t * (3.0 - 2.0 * t);
  end;

  function lerp (t, a, b: Real): Real;
  begin
    lerp := a + t * (b - a);
  end;

  function Noise1 (x: Real): Real;
    var
      bx0, bx1: Integer;
      rx0, rx1, sx, t, u, v, c: Real;
  begin
    t := x + N;
    bx0 := (Round (Int (t)) mod NoiseSizeX) and BM;
    bx1 := ((bx0 + 1) mod NoiseSizeX) and BM;
    rx0 := t - (Int (t));
    rx1 := rx0 - 1.0;

    sx := s_curve (rx0);

    u := rx0 * g1[p[bx0]];
    v := rx1 * g1[p[bx1]];

    c := 0.5 + lerp (sx, u, v);

    if c < 0 then
      c := 0;
    if c > 0.99999999 then
      c := 0.99999999;

    Noise1 := c;
  end;

  function Noise2 (x, y: Real): Real;
    type
      RealArrayPtr = ^RealArray;
      RealArray = array[0..1] of Real;
    var
      bx0, bx1, by0, by1, b00, b10, b01, b11: Integer;
      rx0, rx1, ry0, ry1, sx, sy, a, b, c, t, u, v: Real;
      q: RealArrayPtr;
      i, j: Integer;
  begin
    t := x + N;
    bx0 := (Round (Int (t)) mod NoiseSizeX) and BM;
    bx1 := ((bx0 + 1) mod NoiseSizeX) and BM;
    rx0 := t - (Int (t));
    rx1 := rx0 - 1.0;

    t := y + N;
    by0 := (Round (Int (t)) mod NoiseSizeY) and BM;
    by1 := ((by0 + 1) mod NoiseSizeY) and BM;
    ry0 := t - (Int (t));
    ry1 := ry0 - 1.0;

    i := p[bx0];
    j := p[bx1];

    b00 := p[i + by0];
    b10 := p[j + by0];
    b01 := p[i + by1];
    b11 := p[j + by1];

    sx := s_curve (rx0);
    sy := s_curve (ry0);

    q := @g2[b00];
    u := rx0 * q^[0] + ry0 * q^[1];
    q := @g2[b10];
    v := rx1 * q^[0] + ry0 * q^[1];
    a := lerp (sx, u, v);

    q := @g2[b01];
    u := rx0 * q^[0] + ry1 * q^[1];
    q := @g2[b11];
    v := rx1 * q^[0] + ry1 * q^[1];
    b := lerp (sx, u, v);

    c := 0.5 + lerp (sy, a, b);

    if c < 0 then
      c := 0;
    if c > 0.99999999 then
      c := 0.99999999;

    Noise2 := c;
  end;

  function Noise3 (x, y, z: Real): Real;
    type
      RealArrayPtr = ^RealArray;
      RealArray = array[0..2] of Real;
    var
      bx0, bx1, by0, by1, bz0, bz1, b00, b10, b01, b11: Integer;
      rx0, rx1, ry0, ry1, rz0, rz1, sy, sz, a, b, c, d, e, t, u, v: Real;
      q: RealArrayPtr;
      i, j: Integer;
  begin
    t := x + N;
    bx0 := (Round (Int (t)) mod NoiseSizeX) and BM;
    bx1 := ((bx0 + 1) mod NoiseSizeX) and BM;
    rx0 := t - (Int (t));
    rx1 := rx0 - 1.0;

    t := y + N;
    by0 := (Round (Int (t)) mod NoiseSizeY) and BM;
    by1 := ((by0 + 1) mod NoiseSizeY) and BM;
    ry0 := t - (Int (t));
    ry1 := ry0 - 1.0;

    t := z + N;
    bz0 := (Round (Int (t)) mod NoiseSizeZ) and BM;
    bz1 := ((bz0 + 1) mod NoiseSizeZ) and BM;
    rz0 := t - (Int (t));
    rz1 := rz0 - 1.0;

    i := p[bx0];
    j := p[bx1];

    b00 := p[i + by0];
    b10 := p[j + by0];
    b01 := p[i + by1];
    b11 := p[j + by1];

    t  := s_curve (rx0);
    sy := s_curve (ry0);
    sz := s_curve (rz0);

    q := @g3[b00 + bz0];
    u := rx0 * q^[0] + ry0 * q^[1] + rz0 * q^[2];
    q := @g3[b10 + bz0];
    v := rx1 * q^[0] + ry0 * q^[1] + rz0 * q^[2];
    a := lerp (t, u, v);

    q := @g3[b01 + bz0];
    u := rx0 * q^[0] + ry1 * q^[1] + rz0 * q^[2];
    q := @g3[b11 + bz0];
    v := rx1 * q^[0] + ry1 * q^[1] + rz0 * q^[2];
    b := lerp (t, u, v);

    c := lerp(sy, a, b);

    q := @g3[b00 + bz1];
    u := rx0 * q^[0] + ry0 * q^[1] + rz1 * q^[2];
    q := @g3[b10 + bz1];
    v := rx1 * q^[0] + ry0 * q^[1] + rz1 * q^[2];
    a := lerp (t, u, v);

    q := @g3[b01 + bz1];
    u := rx0 * q^[0] + ry1 * q^[1] + rz1 * q^[2];
    q := @g3[b11 + bz1];
    v := rx1 * q^[0] + ry1 * q^[1] + rz1 * q^[2];
    b := lerp (t, u, v);

    d := lerp(sy, a, b);

    e := 0.5 + lerp (sz, c, d);

    if e < 0 then
      e := 0;
    if e > 0.99999999 then
      e := 0.99999999;

    Noise3 := e;
  end;

  procedure Normalize2 (v: array of Real);
    var
      s: Real;
  begin
    s := Sqrt (v[0] * v[0] + v[1] * v[1]);
    v[0] := v[0] / s;
    v[1] := v[1] / s;
  end;

  var
    i, j, k: Integer;
begin
  NoiseSizeX := DEFAULT_NOISE_SIZE;
  NoiseSizeY := DEFAULT_NOISE_SIZE;
  NoiseSizeZ := DEFAULT_NOISE_SIZE;

  for i := 0 to B - 1 do
  begin
    p[i] := i;
    g1[i] := Integer (Random (B + B) - B) / B;
    for j := 0 to 1 do
      g2[i, j] := Integer (Random (B + B) - B) / B;
    Normalize2 (g2[i]);
    for j := 0 to 2 do
      g3[i, j] := Integer (Random (B + B) - B) / B;
   { normalize3 (g3[i]; }
  end;

  for i := B - 1 downto 0 do
  begin
    k := p[i];
    j := Integer (Random (B));
    p[i] := p[j];
    p[j] := k;
  end;

  for i := 0 to B + 1 do
  begin
    p[B + i] := p[i];
    g1[B + i] := g1[i];
    for j := 0 to 1 do
      g2[B + i, j] := g2[i, j];
    for j := 0 to 2 do
      g3[B + i, j] := g3[i, j];
  end;
end.
