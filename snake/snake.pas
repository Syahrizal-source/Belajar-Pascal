program GameSnake;

{$mode objfpc}{$H+}

uses
  CRT;

const
  LEBAR_PAPAN = 40;
  TINGGI_PAPAN = 18;
  MAKS_PANJANG = 300;

type
  TPosisi = record
    X: Integer;
    Y: Integer;
  end;

var
  Snake: array[1..MAKS_PANJANG] of TPosisi;

  PanjangSnake: Integer;

  Makanan: TPosisi;

  ArahX: Integer;
  ArahY: Integer;

  Skor: Integer;

  Kecepatan: Integer;

  GameBerjalan: Boolean;


{ ========================================================== }
{                    BERSIHKAN LAYAR                        }
{ ========================================================== }

procedure BersihkanLayar;
begin
  ClrScr;
end;


{ ========================================================== }
{                    TAMPILKAN JUDUL                        }
{ ========================================================== }

procedure TampilkanJudul;
begin
  Writeln('==========================================================');
  Writeln('                    GAME SNAKE PASCAL');
  Writeln('==========================================================');
  Writeln('W = Atas    S = Bawah    A = Kiri    D = Kanan');
  Writeln('Q = Keluar');
  Writeln('==========================================================');
end;


{ ========================================================== }
{                 CEK POSISI SNAKE                          }
{ ========================================================== }

function AdaSnake(
  X: Integer;
  Y: Integer
): Boolean;
var
  I: Integer;
begin
  Result := False;

  for I := 1 to PanjangSnake do
  begin
    if (Snake[I].X = X) and
       (Snake[I].Y = Y) then
    begin
      Result := True;
      Exit;
    end;
  end;
end;


{ ========================================================== }
{                    BUAT MAKANAN                            }
{ ========================================================== }

procedure BuatMakanan;
begin
  repeat

    Makanan.X :=
      Random(LEBAR_PAPAN - 2) + 2;

    Makanan.Y :=
      Random(TINGGI_PAPAN - 2) + 1;

  until not AdaSnake(
    Makanan.X,
    Makanan.Y
  );
end;


{ ========================================================== }
{                  CEK APAKAH MAKANAN                       }
{ ========================================================== }

function AdaMakanan(
  X: Integer;
  Y: Integer
): Boolean;
begin
  Result :=
    (Makanan.X = X) and
    (Makanan.Y = Y);
end;


{ ========================================================== }
{                    GAMBAR PAPAN                            }
{ ========================================================== }

procedure GambarPapan;
var
  X: Integer;
  Y: Integer;
  I: Integer;
  Karakter: Char;
begin
  BersihkanLayar;

  TampilkanJudul;

  for Y := 1 to TINGGI_PAPAN do
  begin

    Write('#');

    for X := 2 to LEBAR_PAPAN do
    begin

      Karakter := ' ';

      if AdaMakanan(X, Y) then
      begin
        Karakter := '*';
      end
      else
      begin

        for I := 1 to PanjangSnake do
        begin

          if (Snake[I].X = X) and
             (Snake[I].Y = Y) then
          begin

            if I = 1 then
              Karakter := '@'
            else
              Karakter := 'O';

            Break;
          end;

        end;

      end;

      Write(Karakter);

    end;

    Write('#');

    Writeln;
  end;

  Writeln(
    '=========================================================='
  );

  Write(
    'Skor: ',
    Skor,
    '    Panjang: ',
    PanjangSnake,
    '    Kecepatan: ',
    Kecepatan
  );

  Writeln;
end;


{ ========================================================== }
{                    MULAI GAME                              }
{ ========================================================== }

procedure MulaiGame;
begin
  PanjangSnake := 5;

  Skor := 0;

  ArahX := 1;
  ArahY := 0;

  Kecepatan := 120;

  GameBerjalan := True;

  Snake[1].X := 20;
  Snake[1].Y := 9;

  Snake[2].X := 19;
  Snake[2].Y := 9;

  Snake[3].X := 18;
  Snake[3].Y := 9;

  Snake[4].X := 17;
  Snake[4].Y := 9;

  Snake[5].X := 16;
  Snake[5].Y := 9;

  BuatMakanan;
end;


{ ========================================================== }
{                   PROSES KEYBOARD                          }
{ ========================================================== }

procedure ProsesKeyboard;
var
  Tombol: Char;
  Kode: Integer;
begin
  if not KeyPressed then
    Exit;

  Tombol := ReadKey;

  if Tombol = #0 then
  begin

    Tombol := ReadKey;

    Kode := Ord(Tombol);

    case Kode of

      72:
        begin
          if ArahY <> 1 then
          begin
            ArahX := 0;
            ArahY := -1;
          end;
        end;

      80:
        begin
          if ArahY <> -1 then
          begin
            ArahX := 0;
            ArahY := 1;
          end;
        end;

      75:
        begin
          if ArahX <> 1 then
          begin
            ArahX := -1;
            ArahY := 0;
          end;
        end;

      77:
        begin
          if ArahX <> -1 then
          begin
            ArahX := 1;
            ArahY := 0;
          end;
        end;

    end;

  end
  else
  begin

    case UpCase(Tombol) of

      'W':
        begin
          if ArahY <> 1 then
          begin
            ArahX := 0;
            ArahY := -1;
          end;
        end;

      'S':
        begin
          if ArahY <> -1 then
          begin
            ArahX := 0;
            ArahY := 1;
          end;
        end;

      'A':
        begin
          if ArahX <> 1 then
          begin
            ArahX := -1;
            ArahY := 0;
          end;
        end;

      'D':
        begin
          if ArahX <> -1 then
          begin
            ArahX := 1;
            ArahY := 0;
          end;
        end;

      'Q':
        begin
          GameBerjalan := False;
        end;

    end;

  end;
end;


{ ========================================================== }
{                  CEK TABRAK DINDING                        }
{ ========================================================== }

function TabrakDinding(
  X: Integer;
  Y: Integer
): Boolean;
begin
  Result := False;

  if X <= 1 then
    Result := True;

  if X >= LEBAR_PAPAN then
    Result := True;

  if Y <= 1 then
    Result := True;

  if Y >= TINGGI_PAPAN then
    Result := True;
end;


{ ========================================================== }
{                   CEK TABRAK BADAN                         }
{ ========================================================== }

function TabrakBadan(
  X: Integer;
  Y: Integer
): Boolean;
var
  I: Integer;
begin
  Result := False;

  for I := 2 to PanjangSnake do
  begin
    if (Snake[I].X = X) and
       (Snake[I].Y = Y) then
    begin
      Result := True;
      Exit;
    end;
  end;
end;


{ ========================================================== }
{                    GERAKKAN SNAKE                          }
{ ========================================================== }

procedure GerakkanSnake;
var
  KepalaBaru: TPosisi;
  I: Integer;
  Makan: Boolean;
begin

  KepalaBaru.X :=
    Snake[1].X + ArahX;

  KepalaBaru.Y :=
    Snake[1].Y + ArahY;

  if TabrakDinding(
       KepalaBaru.X,
       KepalaBaru.Y
     ) then
  begin
    GameBerjalan := False;
    Exit;
  end;

  if TabrakBadan(
       KepalaBaru.X,
       KepalaBaru.Y
     ) then
  begin
    GameBerjalan := False;
    Exit;
  end;

  Makan :=
    AdaMakanan(
      KepalaBaru.X,
      KepalaBaru.Y
    );

  if Makan then
  begin

    if PanjangSnake < MAKS_PANJANG then
      Inc(PanjangSnake);

    Inc(Skor, 10);

    if Kecepatan > 40 then
      Dec(Kecepatan, 5);

  end;

  for I := PanjangSnake downto 2 do
  begin
    Snake[I] :=
      Snake[I - 1];
  end;

  Snake[1] :=
    KepalaBaru;

  if Makan then
    BuatMakanan;
end;


{ ========================================================== }
{                     GAME OVER                              }
{ ========================================================== }

procedure GameOver;
begin
  BersihkanLayar;

  Writeln;
  Writeln;
  Writeln;
  Writeln(
    '                 ====================='
  );

  Writeln(
    '                    GAME OVER'
  );

  Writeln(
    '                 ====================='
  );

  Writeln;

  Writeln(
    '                 Skor       : ',
    Skor
  );

  Writeln(
    '                 Panjang    : ',
    PanjangSnake
  );

  Writeln;

  Writeln(
    '                 Tekan ENTER...'
  );

  Readln;
end;


{ ========================================================== }
{                     JALANKAN GAME                          }
{ ========================================================== }

procedure JalankanGame;
begin
  MulaiGame;

  while GameBerjalan do
  begin

    ProsesKeyboard;

    if not GameBerjalan then
      Break;

    GerakkanSnake;

    GambarPapan;

    Delay(Kecepatan);

  end;

  GameOver;
end;


{ ========================================================== }
{                    PROGRAM UTAMA                           }
{ ========================================================== }

begin

  Randomize;

  TextBackground(Black);

  TextColor(White);

  BersihkanLayar;

  JalankanGame;

  TextColor(White);

  TextBackground(Black);

  BersihkanLayar;

  Writeln(
    'Game Snake selesai.'
  );

  Writeln;

end.