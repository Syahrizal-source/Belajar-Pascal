program AplikasiRentalKendaraan;

{$mode objfpc}{$H+}

uses
  SysUtils,
  CRT;

const
  MAX_KENDARAAN = 500;
  MAX_PELANGGAN = 500;
  MAX_TRANSAKSI = 1000;

  FILE_KENDARAAN = 'kendaraan.dat';
  FILE_PELANGGAN = 'pelanggan.dat';
  FILE_TRANSAKSI = 'transaksi.dat';

  TARIF_DASAR_PER_HARI = 100000;
  DENDA_PER_HARI = 50000;

type

  { ====================================================== }
  {                   DATA KENDARAAN                       }
  { ====================================================== }

  TKendaraan = record
    ID: Integer;
    NomorPolisi: string[20];
    Merk: string[50];
    Model: string[50];
    Tahun: Integer;
    TarifPerHari: Currency;
    Tersedia: Boolean;
    Aktif: Boolean;
  end;


  { ====================================================== }
  {                    DATA PELANGGAN                      }
  { ====================================================== }

  TPelanggan = record
    ID: Integer;
    Nama: string[100];
    Alamat: string[150];
    Telepon: string[30];
    NomorIdentitas: string[50];
    Aktif: Boolean;
  end;


  { ====================================================== }
  {                    DATA TRANSAKSI                      }
  { ====================================================== }

  TTransaksi = record
    ID: Integer;
    IDKendaraan: Integer;
    IDPelanggan: Integer;

    TanggalSewa: TDateTime;
    TanggalJatuhTempo: TDateTime;
    TanggalKembali: TDateTime;

    LamaSewa: Integer;

    BiayaSewa: Currency;
    Denda: Currency;
    TotalBayar: Currency;

    SudahKembali: Boolean;
  end;


var
  DaftarKendaraan: array[1..MAX_KENDARAAN] of TKendaraan;
  JumlahKendaraan: Integer;

  DaftarPelanggan: array[1..MAX_PELANGGAN] of TPelanggan;
  JumlahPelanggan: Integer;

  DaftarTransaksi: array[1..MAX_TRANSAKSI] of TTransaksi;
  JumlahTransaksi: Integer;


{ ====================================================== }
{                     UTILITAS                           }
{ ====================================================== }

procedure BersihkanLayar;
begin
  ClrScr;
end;


procedure TekanEnter;
begin
  Writeln;
  Write('Tekan ENTER untuk melanjutkan...');
  Readln;
end;


procedure JudulProgram;
begin
  Writeln('==============================================================');
  Writeln('              SISTEM RENTAL KENDARAAN                        ');
  Writeln('==============================================================');
end;


function Rupiah(Nilai: Currency): string;
begin
  Result := 'Rp ' + FormatFloat('#,##0', Nilai);
end;


function FormatTanggal(Nilai: TDateTime): string;
begin
  Result := FormatDateTime('dd-mm-yyyy', Nilai);
end;


function InputInteger(
  const Prompt: string;
  Minimum: Integer;
  Maksimum: Integer
): Integer;
var
  Teks: string;
  Nilai: Integer;
  Valid: Boolean;
begin
  repeat

    Write(Prompt);
    Readln(Teks);

    Valid :=
      TryStrToInt(
        Trim(Teks),
        Nilai
      );

    if not Valid then
    begin
      Writeln('Input harus berupa angka.');
    end
    else if Nilai < Minimum then
    begin
      Writeln(
        'Nilai minimal adalah ',
        Minimum,
        '.'
      );

      Valid := False;
    end
    else if Nilai > Maksimum then
    begin
      Writeln(
        'Nilai maksimal adalah ',
        Maksimum,
        '.'
      );

      Valid := False;
    end;

  until Valid;

  Result := Nilai;
end;


function InputCurrency(
  const Prompt: string;
  Minimum: Currency
): Currency;
var
  Teks: string;
  Nilai: Currency;
  Valid: Boolean;
begin
  repeat

    Write(Prompt);
    Readln(Teks);

    Teks := StringReplace(
      Trim(Teks),
      ',',
      '',
      [rfReplaceAll]
    );

    Valid :=
      TryStrToCurr(
        Teks,
        Nilai
      );

    if not Valid then
    begin
      Writeln(
        'Input harus berupa angka.'
      );
    end
    else if Nilai < Minimum then
    begin
      Writeln(
        'Nilai minimal adalah ',
        Rupiah(Minimum),
        '.'
      );

      Valid := False;
    end;

  until Valid;

  Result := Nilai;
end;


function InputWajib(
  const Prompt: string
): string;
var
  Teks: string;
begin
  repeat

    Write(Prompt);
    Readln(Teks);

    Teks := Trim(Teks);

    if Teks = '' then
      Writeln(
        'Data tidak boleh kosong.'
      );

  until Teks <> '';

  Result := Teks;
end;


function InputOpsional(
  const Prompt: string;
  NilaiLama: string
): string;
var
  Teks: string;
begin
  Write(Prompt);
  Readln(Teks);

  Teks := Trim(Teks);

  if Teks = '' then
    Result := NilaiLama
  else
    Result := Teks;
end;


{ ====================================================== }
{                 ID OTOMATIS                            }
{ ====================================================== }

function IDKendaraanBerikutnya: Integer;
var
  I: Integer;
  Terbesar: Integer;
begin
  Terbesar := 0;

  for I := 1 to JumlahKendaraan do
  begin
    if DaftarKendaraan[I].ID > Terbesar then
      Terbesar := DaftarKendaraan[I].ID;
  end;

  Result := Terbesar + 1;
end;


function IDPelangganBerikutnya: Integer;
var
  I: Integer;
  Terbesar: Integer;
begin
  Terbesar := 0;

  for I := 1 to JumlahPelanggan do
  begin
    if DaftarPelanggan[I].ID > Terbesar then
      Terbesar := DaftarPelanggan[I].ID;
  end;

  Result := Terbesar + 1;
end;


function IDTransaksiBerikutnya: Integer;
var
  I: Integer;
  Terbesar: Integer;
begin
  Terbesar := 0;

  for I := 1 to JumlahTransaksi do
  begin
    if DaftarTransaksi[I].ID > Terbesar then
      Terbesar := DaftarTransaksi[I].ID;
  end;

  Result := Terbesar + 1;
end;


{ ====================================================== }
{                 SIMPAN KENDARAAN                       }
{ ====================================================== }

procedure SimpanKendaraan;
var
  FileData: file of TKendaraan;
  I: Integer;
begin
  Assign(
    FileData,
    FILE_KENDARAAN
  );

  Rewrite(FileData);

  for I := 1 to JumlahKendaraan do
  begin
    Write(
      FileData,
      DaftarKendaraan[I]
    );
  end;

  Close(FileData);
end;


{ ====================================================== }
{                  MUAT KENDARAAN                        }
{ ====================================================== }

procedure MuatKendaraan;
var
  FileData: file of TKendaraan;
begin
  JumlahKendaraan := 0;

  if not FileExists(FILE_KENDARAAN) then
    Exit;

  Assign(
    FileData,
    FILE_KENDARAAN
  );

  Reset(FileData);

  while not EOF(FileData) do
  begin
    if JumlahKendaraan >= MAX_KENDARAAN then
      Break;

    Inc(JumlahKendaraan);

    Read(
      FileData,
      DaftarKendaraan[JumlahKendaraan]
    );
  end;

  Close(FileData);
end;


{ ====================================================== }
{                  SIMPAN PELANGGAN                      }
{ ====================================================== }

procedure SimpanPelanggan;
var
  FileData: file of TPelanggan;
  I: Integer;
begin
  Assign(
    FileData,
    FILE_PELANGGAN
  );

  Rewrite(FileData);

  for I := 1 to JumlahPelanggan do
  begin
    Write(
      FileData,
      DaftarPelanggan[I]
    );
  end;

  Close(FileData);
end;


{ ====================================================== }
{                   MUAT PELANGGAN                       }
{ ====================================================== }

procedure MuatPelanggan;
var
  FileData: file of TPelanggan;
begin
  JumlahPelanggan := 0;

  if not FileExists(FILE_PELANGGAN) then
    Exit;

  Assign(
    FileData,
    FILE_PELANGGAN
  );

  Reset(FileData);

  while not EOF(FileData) do
  begin
    if JumlahPelanggan >= MAX_PELANGGAN then
      Break;

    Inc(JumlahPelanggan);

    Read(
      FileData,
      DaftarPelanggan[JumlahPelanggan]
    );
  end;

  Close(FileData);
end;


{ ====================================================== }
{                  SIMPAN TRANSAKSI                      }
{ ====================================================== }

procedure SimpanTransaksi;
var
  FileData: file of TTransaksi;
  I: Integer;
begin
  Assign(
    FileData,
    FILE_TRANSAKSI
  );

  Rewrite(FileData);

  for I := 1 to JumlahTransaksi do
  begin
    Write(
      FileData,
      DaftarTransaksi[I]
    );
  end;

  Close(FileData);
end;


{ ====================================================== }
{                   MUAT TRANSAKSI                       }
{ ====================================================== }

procedure MuatTransaksi;
var
  FileData: file of TTransaksi;
begin
  JumlahTransaksi := 0;

  if not FileExists(FILE_TRANSAKSI) then
    Exit;

  Assign(
    FileData,
    FILE_TRANSAKSI
  );

  Reset(FileData);

  while not EOF(FileData) do
  begin
    if JumlahTransaksi >= MAX_TRANSAKSI then
      Break;

    Inc(JumlahTransaksi);

    Read(
      FileData,
      DaftarTransaksi[JumlahTransaksi]
    );
  end;

  Close(FileData);
end;


{ ====================================================== }
{                  CARI KENDARAAN                        }
{ ====================================================== }

function CariKendaraan(
  ID: Integer
): Integer;
var
  I: Integer;
begin
  Result := 0;

  for I := 1 to JumlahKendaraan do
  begin
    if
      (DaftarKendaraan[I].ID = ID) and
      DaftarKendaraan[I].Aktif
    then
    begin
      Result := I;
      Exit;
    end;
  end;
end;


{ ====================================================== }
{                   CARI PELANGGAN                       }
{ ====================================================== }

function CariPelanggan(
  ID: Integer
): Integer;
var
  I: Integer;
begin
  Result := 0;

  for I := 1 to JumlahPelanggan do
  begin
    if
      (DaftarPelanggan[I].ID = ID) and
      DaftarPelanggan[I].Aktif
    then
    begin
      Result := I;
      Exit;
    end;
  end;
end;


{ ====================================================== }
{                 CARI TRANSAKSI AKTIF                   }
{ ====================================================== }

function CariTransaksiAktif(
  ID: Integer
): Integer;
var
  I: Integer;
begin
  Result := 0;

  for I := 1 to JumlahTransaksi do
  begin
    if
      (DaftarTransaksi[I].ID = ID) and
      (not DaftarTransaksi[I].SudahKembali)
    then
    begin
      Result := I;
      Exit;
    end;
  end;
end;


{ ====================================================== }
{             CEK KENDARAAN SEDANG DISEWA               }
{ ====================================================== }

function KendaraanSedangDisewa(
  IDKendaraan: Integer
): Boolean;
var
  I: Integer;
begin
  Result := False;

  for I := 1 to JumlahTransaksi do
  begin
    if
      (DaftarTransaksi[I].IDKendaraan = IDKendaraan) and
      (not DaftarTransaksi[I].SudahKembali)
    then
    begin
      Result := True;
      Exit;
    end;
  end;
end;


{ ====================================================== }
{                TAMBAH KENDARAAN                        }
{ ====================================================== }

procedure TambahKendaraan;
begin
  BersihkanLayar;
  JudulProgram;

  Writeln;
  Writeln(
    '=============== TAMBAH KENDARAAN ==============='
  );

  if JumlahKendaraan >= MAX_KENDARAAN then
  begin
    Writeln;
    Writeln(
      'Kapasitas kendaraan sudah penuh.'
    );

    TekanEnter;
    Exit;
  end;

  Inc(JumlahKendaraan);

  DaftarKendaraan[JumlahKendaraan].ID :=
    IDKendaraanBerikutnya;

  Writeln;
  Writeln(
    'ID Kendaraan: ',
    DaftarKendaraan[JumlahKendaraan].ID
  );

  DaftarKendaraan[JumlahKendaraan].NomorPolisi :=
    InputWajib(
      'Nomor Polisi : '
    );

  DaftarKendaraan[JumlahKendaraan].Merk :=
    InputWajib(
      'Merk         : '
    );

  DaftarKendaraan[JumlahKendaraan].Model :=
    InputWajib(
      'Model        : '
    );

  DaftarKendaraan[JumlahKendaraan].Tahun :=
    InputInteger(
      'Tahun        : ',
      1900,
      2100
    );

  DaftarKendaraan[JumlahKendaraan].TarifPerHari :=
    InputCurrency(
      'Tarif / hari : Rp ',
      0
    );

  DaftarKendaraan[JumlahKendaraan].Tersedia :=
    True;

  DaftarKendaraan[JumlahKendaraan].Aktif :=
    True;

  SimpanKendaraan;

  Writeln;
  Writeln(
    'Kendaraan berhasil ditambahkan.'
  );

  TekanEnter;
end;


{ ====================================================== }
{              TAMPILKAN KENDARAAN                      }
{ ====================================================== }

procedure TampilkanKendaraan;
var
  I: Integer;
begin
  BersihkanLayar;
  JudulProgram;

  Writeln;
  Writeln(
    '================ DAFTAR KENDARAAN ================'
  );

  if JumlahKendaraan = 0 then
  begin
    Writeln;
    Writeln(
      'Belum ada kendaraan.'
    );

    TekanEnter;
    Exit;
  end;

  Writeln;

  for I := 1 to JumlahKendaraan do
  begin
    if DaftarKendaraan[I].Aktif then
    begin

      Writeln(
        'ID            : ',
        DaftarKendaraan[I].ID
      );

      Writeln(
        'Nomor Polisi  : ',
        DaftarKendaraan[I].NomorPolisi
      );

      Writeln(
        'Merk          : ',
        DaftarKendaraan[I].Merk
      );

      Writeln(
        'Model         : ',
        DaftarKendaraan[I].Model
      );

      Writeln(
        'Tahun         : ',
        DaftarKendaraan[I].Tahun
      );

      Writeln(
        'Tarif / Hari  : ',
        Rupiah(
          DaftarKendaraan[I].TarifPerHari
        )
      );

      if DaftarKendaraan[I].Tersedia then
        Writeln(
          'Status        : TERSEDIA'
        )
      else
        Writeln(
          'Status        : DISEWA'
        );

      Writeln(
        '------------------------------------------------------'
      );
    end;
  end;

  TekanEnter;
end;


{ ====================================================== }
{                   CARI KENDARAAN                       }
{ ====================================================== }

procedure CariKendaraanMenu;
var
  KataKunci: string;
  I: Integer;
  Ditemukan: Boolean;
begin
  BersihkanLayar;
  JudulProgram;

  Writeln;
  Writeln(
    '================ CARI KENDARAAN ================='
  );

  KataKunci :=
    InputWajib(
      'Masukkan merk/model/plat: '
    );

  Ditemukan := False;

  Writeln;

  for I := 1 to JumlahKendaraan do
  begin

    if DaftarKendaraan[I].Aktif and
       (
         (Pos(
           LowerCase(KataKunci),
           LowerCase(
             DaftarKendaraan[I].NomorPolisi
           )
         ) > 0)
         or
         (Pos(
           LowerCase(KataKunci),
           LowerCase(
             DaftarKendaraan[I].Merk
           )
         ) > 0)
         or
         (Pos(
           LowerCase(KataKunci),
           LowerCase(
             DaftarKendaraan[I].Model
           )
         ) > 0)
       )
    then
    begin

      Ditemukan := True;

      Writeln(
        'ID           : ',
        DaftarKendaraan[I].ID
      );

      Writeln(
        'Nomor Polisi : ',
        DaftarKendaraan[I].NomorPolisi
      );

      Writeln(
        'Merk         : ',
        DaftarKendaraan[I].Merk
      );

      Writeln(
        'Model        : ',
        DaftarKendaraan[I].Model
      );

      Writeln(
        'Tarif / Hari : ',
        Rupiah(
          DaftarKendaraan[I].TarifPerHari
        )
      );

      Writeln(
        '------------------------------------------------'
      );

    end;

  end;

  if not Ditemukan then
    Writeln(
      'Kendaraan tidak ditemukan.'
    );

  TekanEnter;
end;


{ ====================================================== }
{                  EDIT KENDARAAN                        }
{ ====================================================== }

procedure EditKendaraan;
var
  ID: Integer;
  Posisi: Integer;
begin
  BersihkanLayar;
  JudulProgram;

  Writeln;
  Writeln(
    '================ EDIT KENDARAAN ================='
  );

  ID :=
    InputInteger(
      'ID Kendaraan: ',
      1,
      2147483647
    );

  Posisi :=
    CariKendaraan(ID);

  if Posisi = 0 then
  begin
    Writeln;
    Writeln(
      'Kendaraan tidak ditemukan.'
    );

    TekanEnter;
    Exit;
  end;

  Writeln;
  Writeln(
    'Kosongkan teks jika tidak ingin mengubahnya.'
  );

  DaftarKendaraan[Posisi].NomorPolisi :=
    InputOpsional(
      'Nomor Polisi baru: ',
      DaftarKendaraan[Posisi].NomorPolisi
    );

  DaftarKendaraan[Posisi].Merk :=
    InputOpsional(
      'Merk baru        : ',
      DaftarKendaraan[Posisi].Merk
    );

  DaftarKendaraan[Posisi].Model :=
    InputOpsional(
      'Model baru       : ',
      DaftarKendaraan[Posisi].Model
    );

  DaftarKendaraan[Posisi].Tahun :=
    InputInteger(
      'Tahun baru       : ',
      1900,
      2100
    );

  DaftarKendaraan[Posisi].TarifPerHari :=
    InputCurrency(
      'Tarif baru / hari: Rp ',
      0
    );

  SimpanKendaraan;

  Writeln;
  Writeln(
    'Kendaraan berhasil diperbarui.'
  );

  TekanEnter;
end;


{ ====================================================== }
{                HAPUS KENDARAAN AMAN                    }
{ ====================================================== }

procedure HapusKendaraan;
var
  ID: Integer;
  Posisi: Integer;
  Konfirmasi: string;
begin
  BersihkanLayar;
  JudulProgram;

  Writeln;
  Writeln(
    '================ HAPUS KENDARAAN ================='
  );

  ID :=
    InputInteger(
      'ID Kendaraan: ',
      1,
      2147483647
    );

  Posisi :=
    CariKendaraan(ID);

  if Posisi = 0 then
  begin
    Writeln;
    Writeln(
      'Kendaraan tidak ditemukan.'
    );

    TekanEnter;
    Exit;
  end;

  if KendaraanSedangDisewa(ID) then
  begin
    Writeln;
    Writeln(
      'KENDARAAN TIDAK BOLEH DIHAPUS.'
    );

    Writeln(
      'Kendaraan masih sedang disewa.'
    );

    TekanEnter;
    Exit;
  end;

  Writeln;
  Writeln(
    'Kendaraan: ',
    DaftarKendaraan[Posisi].Merk,
    ' ',
    DaftarKendaraan[Posisi].Model
  );

  Write(
    'Ketik Y untuk menghapus: '
  );

  Readln(Konfirmasi);

  if UpperCase(
       Trim(Konfirmasi)
     ) = 'Y'
  then
  begin

    DaftarKendaraan[Posisi].Aktif :=
      False;

    DaftarKendaraan[Posisi].Tersedia :=
      False;

    SimpanKendaraan;

    Writeln;
    Writeln(
      'Kendaraan berhasil dihapus.'
    );

  end
  else
  begin
    Writeln;
    Writeln(
      'Penghapusan dibatalkan.'
    );
  end;

  TekanEnter;
end;


{ ====================================================== }
{                SORTING KENDARAAN                       }
{ ====================================================== }

procedure SortingKendaraan;
var
  I: Integer;
  J: Integer;
  Temp: TKendaraan;
begin
  if JumlahKendaraan <= 1 then
    Exit;

  for I := 1 to JumlahKendaraan - 1 do
  begin

    for J := I + 1 to JumlahKendaraan do
    begin

      if CompareText(
           DaftarKendaraan[I].Merk,
           DaftarKendaraan[J].Merk
         ) > 0
      then
      begin

        Temp :=
          DaftarKendaraan[I];

        DaftarKendaraan[I] :=
          DaftarKendaraan[J];

        DaftarKendaraan[J] :=
          Temp;

      end;

    end;

  end;

  SimpanKendaraan;
end;


{ ====================================================== }
{                 TAMBAH PELANGGAN                       }
{ ====================================================== }

procedure TambahPelanggan;
begin
  BersihkanLayar;
  JudulProgram;

  Writeln;
  Writeln(
    '================ TAMBAH PELANGGAN ================='
  );

  if JumlahPelanggan >= MAX_PELANGGAN then
  begin
    Writeln;
    Writeln(
      'Kapasitas pelanggan sudah penuh.'
    );

    TekanEnter;
    Exit;
  end;

  Inc(JumlahPelanggan);

  DaftarPelanggan[JumlahPelanggan].ID :=
    IDPelangganBerikutnya;

  Writeln;
  Writeln(
    'ID Pelanggan: ',
    DaftarPelanggan[JumlahPelanggan].ID
  );

  DaftarPelanggan[JumlahPelanggan].Nama :=
    InputWajib(
      'Nama            : '
    );

  DaftarPelanggan[JumlahPelanggan].Alamat :=
    InputWajib(
      'Alamat          : '
    );

  DaftarPelanggan[JumlahPelanggan].Telepon :=
    InputWajib(
      'Telepon         : '
    );

  DaftarPelanggan[JumlahPelanggan].NomorIdentitas :=
    InputWajib(
      'Nomor Identitas : '
    );

  DaftarPelanggan[JumlahPelanggan].Aktif :=
    True;

  SimpanPelanggan;

  Writeln;
  Writeln(
    'Pelanggan berhasil ditambahkan.'
  );

  TekanEnter;
end;


{ ====================================================== }
{                TAMPILKAN PELANGGAN                     }
{ ====================================================== }

procedure TampilkanPelanggan;
var
  I: Integer;
begin
  BersihkanLayar;
  JudulProgram;

  Writeln;
  Writeln(
    '================ DAFTAR PELANGGAN ================='
  );

  if JumlahPelanggan = 0 then
  begin
    Writeln;
    Writeln(
      'Belum ada pelanggan.'
    );

    TekanEnter;
    Exit;
  end;

  Writeln;

  for I := 1 to JumlahPelanggan do
  begin

    if DaftarPelanggan[I].Aktif then
    begin

      Writeln(
        'ID       : ',
        DaftarPelanggan[I].ID
      );

      Writeln(
        'Nama     : ',
        DaftarPelanggan[I].Nama
      );

      Writeln(
        'Alamat   : ',
        DaftarPelanggan[I].Alamat
      );

      Writeln(
        'Telepon  : ',
        DaftarPelanggan[I].Telepon
      );

      Writeln(
        'Identitas: ',
        DaftarPelanggan[I].NomorIdentitas
      );

      Writeln(
        '------------------------------------------------'
      );

    end;

  end;

  TekanEnter;
end;


{ ====================================================== }
{                   CARI PELANGGAN                       }
{ ====================================================== }

procedure CariPelangganMenu;
var
  KataKunci: string;
  I: Integer;
  Ditemukan: Boolean;
begin
  BersihkanLayar;
  JudulProgram;

  Writeln;
  Writeln(
    '================ CARI PELANGGAN ================='
  );

  KataKunci :=
    InputWajib(
      'Masukkan nama/telepon/identitas: '
    );

  Ditemukan := False;

  Writeln;

  for I := 1 to JumlahPelanggan do
  begin

    if DaftarPelanggan[I].Aktif and
       (
         (Pos(
           LowerCase(KataKunci),
           LowerCase(
             DaftarPelanggan[I].Nama
           )
         ) > 0)
         or
         (Pos(
           LowerCase(KataKunci),
           LowerCase(
             DaftarPelanggan[I].Telepon
           )
         ) > 0)
         or
         (Pos(
           LowerCase(KataKunci),
           LowerCase(
             DaftarPelanggan[I].NomorIdentitas
           )
         ) > 0)
       )
    then
    begin

      Ditemukan := True;

      Writeln(
        'ID       : ',
        DaftarPelanggan[I].ID
      );

      Writeln(
        'Nama     : ',
        DaftarPelanggan[I].Nama
      );

      Writeln(
        'Alamat   : ',
        DaftarPelanggan[I].Alamat
      );

      Writeln(
        'Telepon  : ',
        DaftarPelanggan[I].Telepon
      );

      Writeln(
        'Identitas: ',
        DaftarPelanggan[I].NomorIdentitas
      );

      Writeln(
        '------------------------------------------------'
      );

    end;

  end;

  if not Ditemukan then
    Writeln(
      'Pelanggan tidak ditemukan.'
    );

  TekanEnter;
end;


{ ====================================================== }
{                  EDIT PELANGGAN                        }
{ ====================================================== }

procedure EditPelanggan;
var
  ID: Integer;
  Posisi: Integer;
begin
  BersihkanLayar;
  JudulProgram;

  Writeln;
  Writeln(
    '================ EDIT PELANGGAN ================='
  );

  ID :=
    InputInteger(
      'ID Pelanggan: ',
      1,
      2147483647
    );

  Posisi :=
    CariPelanggan(ID);

  if Posisi = 0 then
  begin
    Writeln;
    Writeln(
      'Pelanggan tidak ditemukan.'
    );

    TekanEnter;
    Exit;
  end;

  Writeln;
  Writeln(
    'Kosongkan input untuk mempertahankan data lama.'
  );

  DaftarPelanggan[Posisi].Nama :=
    InputOpsional(
      'Nama baru            : ',
      DaftarPelanggan[Posisi].Nama
    );

  DaftarPelanggan[Posisi].Alamat :=
    InputOpsional(
      'Alamat baru          : ',
      DaftarPelanggan[Posisi].Alamat
    );

  DaftarPelanggan[Posisi].Telepon :=
    InputOpsional(
      'Telepon baru         : ',
      DaftarPelanggan[Posisi].Telepon
    );

  DaftarPelanggan[Posisi].NomorIdentitas :=
    InputOpsional(
      'Nomor Identitas baru: ',
      DaftarPelanggan[Posisi].NomorIdentitas
    );

  SimpanPelanggan;

  Writeln;
  Writeln(
    'Data pelanggan berhasil diperbarui.'
  );

  TekanEnter;
end;


{ ====================================================== }
{                 SEWA KENDARAAN                         }
{ ====================================================== }

procedure ProsesSewa;
var
  IDKendaraan: Integer;
  IDPelanggan: Integer;

  IndexKendaraan: Integer;
  IndexPelanggan: Integer;

  LamaSewa: Integer;
begin
  BersihkanLayar;
  JudulProgram;

  Writeln;
  Writeln(
    '================ TRANSAKSI SEWA ================='
  );

  if JumlahKendaraan = 0 then
  begin
    Writeln;
    Writeln(
      'Belum ada kendaraan.'
    );

    TekanEnter;
    Exit;
  end;

  if JumlahPelanggan = 0 then
  begin
    Writeln;
    Writeln(
      'Belum ada pelanggan.'
    );

    TekanEnter;
    Exit;
  end;

  IDKendaraan :=
    InputInteger(
      'ID Kendaraan: ',
      1,
      2147483647
    );

  IndexKendaraan :=
    CariKendaraan(IDKendaraan);

  if IndexKendaraan = 0 then
  begin
    Writeln;
    Writeln(
      'Kendaraan tidak ditemukan.'
    );

    TekanEnter;
    Exit;
  end;

  if not DaftarKendaraan[IndexKendaraan].Tersedia then
  begin
    Writeln;
    Writeln(
      'Kendaraan sedang disewa.'
    );

    TekanEnter;
    Exit;
  end;

  IDPelanggan :=
    InputInteger(
      'ID Pelanggan: ',
      1,
      2147483647
    );

  IndexPelanggan :=
    CariPelanggan(IDPelanggan);

  if IndexPelanggan = 0 then
  begin
    Writeln;
    Writeln(
      'Pelanggan tidak ditemukan.'
    );

    TekanEnter;
    Exit;
  end;

  if JumlahTransaksi >= MAX_TRANSAKSI then
  begin
    Writeln;
    Writeln(
      'Kapasitas transaksi sudah penuh.'
    );

    TekanEnter;
    Exit;
  end;

  LamaSewa :=
    InputInteger(
      'Lama sewa (hari): ',
      1,
      365
    );

  Inc(JumlahTransaksi);

  DaftarTransaksi[JumlahTransaksi].ID :=
    IDTransaksiBerikutnya;

  DaftarTransaksi[JumlahTransaksi].IDKendaraan :=
    IDKendaraan;

  DaftarTransaksi[JumlahTransaksi].IDPelanggan :=
    IDPelanggan;

  DaftarTransaksi[JumlahTransaksi].TanggalSewa :=
    Date;

  DaftarTransaksi[JumlahTransaksi].TanggalJatuhTempo :=
    Date + LamaSewa;

  DaftarTransaksi[JumlahTransaksi].TanggalKembali :=
    0;

  DaftarTransaksi[JumlahTransaksi].LamaSewa :=
    LamaSewa;

  DaftarTransaksi[JumlahTransaksi].BiayaSewa :=
    DaftarKendaraan[IndexKendaraan].TarifPerHari *
    LamaSewa;

  DaftarTransaksi[JumlahTransaksi].Denda :=
    0;

  DaftarTransaksi[JumlahTransaksi].TotalBayar :=
    DaftarTransaksi[JumlahTransaksi].BiayaSewa;

  DaftarTransaksi[JumlahTransaksi].SudahKembali :=
    False;

  DaftarKendaraan[IndexKendaraan].Tersedia :=
    False;

  SimpanKendaraan;
  SimpanTransaksi;

  Writeln;
  Writeln(
    '================ SEWA BERHASIL ================='
  );

  Writeln(
    'ID Transaksi : ',
    DaftarTransaksi[JumlahTransaksi].ID
  );

  Writeln(
    'Kendaraan    : ',
    DaftarKendaraan[IndexKendaraan].Merk,
    ' ',
    DaftarKendaraan[IndexKendaraan].Model
  );

  Writeln(
    'Pelanggan    : ',
    DaftarPelanggan[IndexPelanggan].Nama
  );

  Writeln(
    'Tanggal Sewa : ',
    FormatTanggal(
      DaftarTransaksi[JumlahTransaksi].TanggalSewa
    )
  );

  Writeln(
    'Jatuh Tempo  : ',
    FormatTanggal(
      DaftarTransaksi[JumlahTransaksi].TanggalJatuhTempo
    )
  );

  Writeln(
    'Lama Sewa    : ',
    LamaSewa,
    ' hari'
  );

  Writeln(
    'Biaya Sewa   : ',
    Rupiah(
      DaftarTransaksi[JumlahTransaksi].BiayaSewa
    )
  );

  TekanEnter;
end;


{ ====================================================== }
{                PENGEMBALIAN KENDARAAN                  }
{ ====================================================== }

procedure ProsesPengembalian;
var
  IDTransaksi: Integer;

  IndexTransaksi: Integer;
  IndexKendaraan: Integer;

  Terlambat: Integer;
  Denda: Currency;
begin
  BersihkanLayar;
  JudulProgram;

  Writeln;
  Writeln(
    '============= PENGEMBALIAN KENDARAAN ============='
  );

  if JumlahTransaksi = 0 then
  begin
    Writeln;
    Writeln(
      'Belum ada transaksi.'
    );

    TekanEnter;
    Exit;
  end;

  IDTransaksi :=
    InputInteger(
      'ID Transaksi: ',
      1,
      2147483647
    );

  IndexTransaksi :=
    CariTransaksiAktif(
      IDTransaksi
    );

  if IndexTransaksi = 0 then
  begin
    Writeln;
    Writeln(
      'Transaksi tidak ditemukan atau sudah selesai.'
    );

    TekanEnter;
    Exit;
  end;

  IndexKendaraan :=
    CariKendaraan(
      DaftarTransaksi[IndexTransaksi].IDKendaraan
    );

  DaftarTransaksi[IndexTransaksi].TanggalKembali :=
    Date;

  Terlambat :=
    Trunc(
      Date -
      DaftarTransaksi[IndexTransaksi].TanggalJatuhTempo
    );

  if Terlambat > 0 then
  begin
    Denda :=
      Terlambat *
      DENDA_PER_HARI;
  end
  else
  begin
    Denda := 0;
  end;

  DaftarTransaksi[IndexTransaksi].Denda :=
    Denda;

  DaftarTransaksi[IndexTransaksi].TotalBayar :=
    DaftarTransaksi[IndexTransaksi].BiayaSewa +
    Denda;

  DaftarTransaksi[IndexTransaksi].SudahKembali :=
    True;

  if IndexKendaraan > 0 then
  begin
    DaftarKendaraan[IndexKendaraan].Tersedia :=
      True;
  end;

  SimpanKendaraan;
  SimpanTransaksi;

  Writeln;
  Writeln(
    '============== PENGEMBALIAN BERHASIL =============='
  );

  Writeln(
    'Tanggal Kembali : ',
    FormatTanggal(Date)
  );

  Writeln(
    'Terlambat       : ',
    Terlambat,
    ' hari'
  );

  Writeln(
    'Biaya Sewa      : ',
    Rupiah(
      DaftarTransaksi[IndexTransaksi].BiayaSewa
    )
  );

  Writeln(
    'Denda           : ',
    Rupiah(Denda)
  );

  Writeln(
    'TOTAL BAYAR     : ',
    Rupiah(
      DaftarTransaksi[IndexTransaksi].TotalBayar
    )
  );

  TekanEnter;
end;


{ ====================================================== }
{              TAMPILKAN TRANSAKSI                       }
{ ====================================================== }

procedure TampilkanTransaksi;
var
  I: Integer;
  IndexKendaraan: Integer;
  IndexPelanggan: Integer;
begin
  BersihkanLayar;
  JudulProgram;

  Writeln;
  Writeln(
    '================ DATA TRANSAKSI ================='
  );

  if JumlahTransaksi = 0 then
  begin
    Writeln;
    Writeln(
      'Belum ada transaksi.'
    );

    TekanEnter;
    Exit;
  end;

  Writeln;

  for I := 1 to JumlahTransaksi do
  begin

    IndexKendaraan :=
      CariKendaraan(
        DaftarTransaksi[I].IDKendaraan
      );

    IndexPelanggan :=
      CariPelanggan(
        DaftarTransaksi[I].IDPelanggan
      );

    Writeln(
      'ID Transaksi : ',
      DaftarTransaksi[I].ID
    );

    if IndexKendaraan > 0 then
      Writeln(
        'Kendaraan    : ',
        DaftarKendaraan[IndexKendaraan].Merk,
        ' ',
        DaftarKendaraan[IndexKendaraan].Model
      )
    else
      Writeln(
        'Kendaraan ID : ',
        DaftarTransaksi[I].IDKendaraan
      );

    if IndexPelanggan > 0 then
      Writeln(
        'Pelanggan    : ',
        DaftarPelanggan[IndexPelanggan].Nama
      )
    else
      Writeln(
        'Pelanggan ID : ',
        DaftarTransaksi[I].IDPelanggan
      );

    Writeln(
      'Tanggal Sewa : ',
      FormatTanggal(
        DaftarTransaksi[I].TanggalSewa
      )
    );

    Writeln(
      'Jatuh Tempo  : ',
      FormatTanggal(
        DaftarTransaksi[I].TanggalJatuhTempo
      )
    );

    if DaftarTransaksi[I].SudahKembali then
    begin
      Writeln(
        'Kembali      : ',
        FormatTanggal(
          DaftarTransaksi[I].TanggalKembali
        )
      );

      Writeln(
        'Status       : SELESAI'
      );
    end
    else
    begin
      Writeln(
        'Status       : MASIH DISEWA'
      );
    end;

    Writeln(
      'Biaya Sewa   : ',
      Rupiah(
        DaftarTransaksi[I].BiayaSewa
      )
    );

    Writeln(
      'Denda        : ',
      Rupiah(
        DaftarTransaksi[I].Denda
      )
    );

    Writeln(
      'Total Bayar  : ',
      Rupiah(
        DaftarTransaksi[I].TotalBayar
      )
    );

    Writeln(
      '------------------------------------------------------'
    );

  end;

  TekanEnter;
end;


{ ====================================================== }
{                    DASHBOARD                           }
{ ====================================================== }

procedure Dashboard;
var
  I: Integer;

  KendaraanTersedia: Integer;
  KendaraanDisewa: Integer;

  TransaksiAktif: Integer;
  TransaksiSelesai: Integer;

  TotalPendapatan: Currency;
  TotalDenda: Currency;
begin
  KendaraanTersedia := 0;
  KendaraanDisewa := 0;

  TransaksiAktif := 0;
  TransaksiSelesai := 0;

  TotalPendapatan := 0;
  TotalDenda := 0;

  for I := 1 to JumlahKendaraan do
  begin

    if DaftarKendaraan[I].Aktif then
    begin

      if DaftarKendaraan[I].Tersedia then
        Inc(KendaraanTersedia)
      else
        Inc(KendaraanDisewa);

    end;

  end;


  for I := 1 to JumlahTransaksi do
  begin

    if DaftarTransaksi[I].SudahKembali then
    begin
      Inc(TransaksiSelesai);

      TotalPendapatan :=
        TotalPendapatan +
        DaftarTransaksi[I].TotalBayar;

      TotalDenda :=
        TotalDenda +
        DaftarTransaksi[I].Denda;
    end
    else
    begin
      Inc(TransaksiAktif);
    end;

  end;


  BersihkanLayar;
  JudulProgram;

  Writeln;
  Writeln(
    '================ DASHBOARD ================='
  );

  Writeln;

  Writeln(
    'Kendaraan aktif       : ',
    JumlahKendaraan
  );

  Writeln(
    'Kendaraan tersedia    : ',
    KendaraanTersedia
  );

  Writeln(
    'Kendaraan sedang sewa : ',
    KendaraanDisewa
  );

  Writeln(
    'Jumlah pelanggan      : ',
    JumlahPelanggan
  );

  Writeln(
    'Transaksi aktif       : ',
    TransaksiAktif
  );

  Writeln(
    'Transaksi selesai     : ',
    TransaksiSelesai
  );

  Writeln(
    'Total transaksi       : ',
    JumlahTransaksi
  );

  Writeln(
    'Total pendapatan      : ',
    Rupiah(TotalPendapatan)
  );

  Writeln(
    'Total denda           : ',
    Rupiah(TotalDenda)
  );

  Writeln;

  Writeln(
    'Tanggal sistem        : ',
    FormatTanggal(Date)
  );

  TekanEnter;
end;


{ ====================================================== }
{                  MENU KENDARAAN                        }
{ ====================================================== }

procedure MenuKendaraan;
var
  Pilihan: Char;
begin
  repeat

    BersihkanLayar;
    JudulProgram;

    Writeln;
    Writeln(
      '================ MENU KENDARAAN ================='
    );

    Writeln;
    Writeln('1. Tambah Kendaraan');
    Writeln('2. Lihat Kendaraan');
    Writeln('3. Cari Kendaraan');
    Writeln('4. Edit Kendaraan');
    Writeln('5. Hapus Kendaraan Aman');
    Writeln('6. Urutkan Berdasarkan Merk');
    Writeln('7. Kembali');

    Writeln;

    Write('Pilihan: ');
    Readln(Pilihan);

    case Pilihan of

      '1':
        TambahKendaraan;

      '2':
        TampilkanKendaraan;

      '3':
        CariKendaraanMenu;

      '4':
        EditKendaraan;

      '5':
        HapusKendaraan;

      '6':
        begin

          SortingKendaraan;

          Writeln;
          Writeln(
            'Data kendaraan berhasil diurutkan.'
          );

          TekanEnter;
        end;

      '7':
        Exit;

      else
        begin
          Writeln;
          Writeln(
            'Pilihan tidak tersedia.'
          );

          TekanEnter;
        end;

    end;

  until False;
end;


{ ====================================================== }
{                   MENU PELANGGAN                       }
{ ====================================================== }

procedure MenuPelanggan;
var
  Pilihan: Char;
begin
  repeat

    BersihkanLayar;
    JudulProgram;

    Writeln;
    Writeln(
      '================ MENU PELANGGAN ================='
    );

    Writeln;
    Writeln('1. Tambah Pelanggan');
    Writeln('2. Lihat Pelanggan');
    Writeln('3. Cari Pelanggan');
    Writeln('4. Edit Pelanggan');
    Writeln('5. Kembali');

    Writeln;

    Write('Pilihan: ');
    Readln(Pilihan);

    case Pilihan of

      '1':
        TambahPelanggan;

      '2':
        TampilkanPelanggan;

      '3':
        CariPelangganMenu;

      '4':
        EditPelanggan;

      '5':
        Exit;

      else
        begin
          Writeln;
          Writeln(
            'Pilihan tidak tersedia.'
          );

          TekanEnter;
        end;

    end;

  until False;
end;


{ ====================================================== }
{                   MENU TRANSAKSI                       }
{ ====================================================== }

procedure MenuTransaksi;
var
  Pilihan: Char;
begin
  repeat

    BersihkanLayar;
    JudulProgram;

    Writeln;
    Writeln(
      '================ MENU TRANSAKSI ================='
    );

    Writeln;
    Writeln('1. Sewa Kendaraan');
    Writeln('2. Pengembalian Kendaraan');
    Writeln('3. Lihat Semua Transaksi');
    Writeln('4. Kembali');

    Writeln;

    Write('Pilihan: ');
    Readln(Pilihan);

    case Pilihan of

      '1':
        ProsesSewa;

      '2':
        ProsesPengembalian;

      '3':
        TampilkanTransaksi;

      '4':
        Exit;

      else
        begin
          Writeln;
          Writeln(
            'Pilihan tidak tersedia.'
          );

          TekanEnter;
        end;

    end;

  until False;
end;


{ ====================================================== }
{                    MENU LAPORAN                        }
{ ====================================================== }

procedure MenuLaporan;
var
  Pilihan: Char;
begin
  repeat

    BersihkanLayar;
    JudulProgram;

    Writeln;
    Writeln(
      '================ MENU LAPORAN ================='
    );

    Writeln;
    Writeln('1. Dashboard');
    Writeln('2. Semua Transaksi');
    Writeln('3. Kembali');

    Writeln;

    Write('Pilihan: ');
    Readln(Pilihan);

    case Pilihan of

      '1':
        Dashboard;

      '2':
        TampilkanTransaksi;

      '3':
        Exit;

      else
        begin
          Writeln;
          Writeln(
            'Pilihan tidak tersedia.'
          );

          TekanEnter;
        end;

    end;

  until False;
end;


{ ====================================================== }
{                    MENU UTAMA                          }
{ ====================================================== }

procedure MenuUtama;
var
  Pilihan: Char;
begin
  repeat

    BersihkanLayar;
    JudulProgram;

    Writeln;
    Writeln('1. Dashboard');
    Writeln('2. Data Kendaraan');
    Writeln('3. Data Pelanggan');
    Writeln('4. Transaksi Rental');
    Writeln('5. Laporan');
    Writeln('6. Keluar');

    Writeln;

    Write('Pilihan: ');
    Readln(Pilihan);

    case Pilihan of

      '1':
        Dashboard;

      '2':
        MenuKendaraan;

      '3':
        MenuPelanggan;

      '4':
        MenuTransaksi;

      '5':
        MenuLaporan;

      '6':
        begin

          BersihkanLayar;

          Writeln(
            '=============================================================='
          );

          Writeln(
            '       TERIMA KASIH TELAH MENGGUNAKAN APLIKASI'
          );

          Writeln(
            '=============================================================='
          );

          Writeln;

        end;

      else
        begin

          Writeln;
          Writeln(
            'Pilihan tidak tersedia.'
          );

          TekanEnter;

        end;

    end;

  until Pilihan = '6';
end;


{ ====================================================== }
{                  PROGRAM UTAMA                         }
{ ====================================================== }

begin

  JumlahKendaraan := 0;
  JumlahPelanggan := 0;
  JumlahTransaksi := 0;

  MuatKendaraan;
  MuatPelanggan;
  MuatTransaksi;

  MenuUtama;

end.