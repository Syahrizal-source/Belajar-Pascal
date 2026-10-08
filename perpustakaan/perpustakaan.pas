program AplikasiPerpustakaan;

{$mode objfpc}{$H+}

uses
  SysUtils,
  CRT;

const
  MAX_BUKU = 500;
  MAX_ANGGOTA = 500;
  MAX_PEMINJAMAN = 1000;

  FILE_BUKU = 'buku.dat';
  FILE_ANGGOTA = 'anggota.dat';
  FILE_PEMINJAMAN = 'peminjaman.dat';

  DENDA_PER_HARI = 1000;

type

  { ====================================================== }
  {                       DATA BUKU                        }
  { ====================================================== }

  TBuku = record
    ID: Integer;
    Judul: string[100];
    Penulis: string[60];
    Penerbit: string[60];
    Tahun: Integer;
    Stok: Integer;
    Aktif: Boolean;
  end;


  { ====================================================== }
  {                      DATA ANGGOTA                      }
  { ====================================================== }

  TAnggota = record
    ID: Integer;
    Nama: string[100];
    Alamat: string[150];
    Telepon: string[30];
    Aktif: Boolean;
  end;


  { ====================================================== }
  {                    DATA PEMINJAMAN                     }
  { ====================================================== }

  TPeminjaman = record
    ID: Integer;
    IDBuku: Integer;
    IDAnggota: Integer;
    TanggalPinjam: TDateTime;
    TanggalJatuhTempo: TDateTime;
    TanggalKembali: TDateTime;
    SudahKembali: Boolean;
    Denda: Currency;
  end;


var
  DaftarBuku: array[1..MAX_BUKU] of TBuku;
  JumlahBuku: Integer;

  DaftarAnggota: array[1..MAX_ANGGOTA] of TAnggota;
  JumlahAnggota: Integer;

  DaftarPeminjaman: array[1..MAX_PEMINJAMAN] of TPeminjaman;
  JumlahPeminjaman: Integer;


{ ========================================================== }
{                     UTILITAS DASAR                         }
{ ========================================================== }

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
  Writeln('               SISTEM MANAJEMEN PERPUSTAKAAN                 ');
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


{ ========================================================== }
{                    VALIDASI INPUT ANGKA                     }
{ ========================================================== }

function InputInteger(
  const Prompt: string;
  NilaiMinimum: Integer;
  NilaiMaksimum: Integer
): Integer;
var
  Teks: string;
  Nilai: Integer;
  Berhasil: Boolean;
begin
  repeat

    Write(Prompt);
    Readln(Teks);

    Berhasil :=
      TryStrToInt(
        Trim(Teks),
        Nilai
      );

    if not Berhasil then
    begin
      Writeln('Input harus berupa angka.');
    end
    else
    begin
      if Nilai < NilaiMinimum then
      begin
        Writeln(
          'Nilai minimal adalah ',
          NilaiMinimum,
          '.'
        );

        Berhasil := False;
      end
      else
      begin
        if Nilai > NilaiMaksimum then
        begin
          Writeln(
            'Nilai maksimal adalah ',
            NilaiMaksimum,
            '.'
          );

          Berhasil := False;
        end;
      end;
    end;

  until Berhasil;

  Result := Nilai;
end;


{ ========================================================== }
{                   INPUT TEKS WAJIB                          }
{ ========================================================== }

function InputTextRequired(
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
      Writeln('Data tidak boleh kosong.');

  until Teks <> '';

  Result := Teks;
end;


{ ========================================================== }
{                INPUT TEKS BOLEH KOSONG                      }
{ ========================================================== }

function InputTextOptional(
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


{ ========================================================== }
{                  HITUNG DATA AKTIF                          }
{ ========================================================== }

function HitungBukuAktif: Integer;
var
  I: Integer;
begin
  Result := 0;

  for I := 1 to JumlahBuku do
  begin
    if DaftarBuku[I].Aktif then
      Inc(Result);
  end;
end;


function HitungAnggotaAktif: Integer;
var
  I: Integer;
begin
  Result := 0;

  for I := 1 to JumlahAnggota do
  begin
    if DaftarAnggota[I].Aktif then
      Inc(Result);
  end;
end;


function HitungPeminjamanAktif: Integer;
var
  I: Integer;
begin
  Result := 0;

  for I := 1 to JumlahPeminjaman do
  begin
    if not DaftarPeminjaman[I].SudahKembali then
      Inc(Result);
  end;
end;


{ ========================================================== }
{                 ID BUKU BERIKUTNYA                         }
{ ========================================================== }

function IDBukuBerikutnya: Integer;
var
  I: Integer;
  NilaiTerbesar: Integer;
begin
  NilaiTerbesar := 0;

  for I := 1 to JumlahBuku do
  begin
    if DaftarBuku[I].ID > NilaiTerbesar then
      NilaiTerbesar := DaftarBuku[I].ID;
  end;

  Result := NilaiTerbesar + 1;
end;


{ ========================================================== }
{               ID ANGGOTA BERIKUTNYA                        }
{ ========================================================== }

function IDAnggotaBerikutnya: Integer;
var
  I: Integer;
  NilaiTerbesar: Integer;
begin
  NilaiTerbesar := 0;

  for I := 1 to JumlahAnggota do
  begin
    if DaftarAnggota[I].ID > NilaiTerbesar then
      NilaiTerbesar := DaftarAnggota[I].ID;
  end;

  Result := NilaiTerbesar + 1;
end;


{ ========================================================== }
{              ID PEMINJAMAN BERIKUTNYA                      }
{ ========================================================== }

function IDPeminjamanBerikutnya: Integer;
var
  I: Integer;
  NilaiTerbesar: Integer;
begin
  NilaiTerbesar := 0;

  for I := 1 to JumlahPeminjaman do
  begin
    if DaftarPeminjaman[I].ID > NilaiTerbesar then
      NilaiTerbesar := DaftarPeminjaman[I].ID;
  end;

  Result := NilaiTerbesar + 1;
end;


{ ========================================================== }
{                  SLOT BUKU YANG KOSONG                      }
{ ========================================================== }

function CariSlotBukuKosong: Integer;
var
  I: Integer;
begin
  Result := 0;

  for I := 1 to JumlahBuku do
  begin
    if not DaftarBuku[I].Aktif then
    begin
      Result := I;
      Exit;
    end;
  end;
end;


{ ========================================================== }
{                SLOT ANGGOTA YANG KOSONG                     }
{ ========================================================== }

function CariSlotAnggotaKosong: Integer;
var
  I: Integer;
begin
  Result := 0;

  for I := 1 to JumlahAnggota do
  begin
    if not DaftarAnggota[I].Aktif then
    begin
      Result := I;
      Exit;
    end;
  end;
end;


{ ========================================================== }
{                       SIMPAN BUKU                           }
{ ========================================================== }

procedure SimpanBuku;
var
  FileBuku: file of TBuku;
  I: Integer;
begin
  Assign(FileBuku, FILE_BUKU);
  Rewrite(FileBuku);

  for I := 1 to JumlahBuku do
  begin
    Write(
      FileBuku,
      DaftarBuku[I]
    );
  end;

  Close(FileBuku);
end;


{ ========================================================== }
{                        MUAT BUKU                            }
{ ========================================================== }

procedure MuatBuku;
var
  FileBuku: file of TBuku;
begin
  JumlahBuku := 0;

  if not FileExists(FILE_BUKU) then
    Exit;

  Assign(FileBuku, FILE_BUKU);
  Reset(FileBuku);

  while not EOF(FileBuku) do
  begin
    if JumlahBuku >= MAX_BUKU then
      Break;

    Inc(JumlahBuku);

    Read(
      FileBuku,
      DaftarBuku[JumlahBuku]
    );
  end;

  Close(FileBuku);
end;


{ ========================================================== }
{                     SIMPAN ANGGOTA                         }
{ ========================================================== }

procedure SimpanAnggota;
var
  FileAnggota: file of TAnggota;
  I: Integer;
begin
  Assign(FileAnggota, FILE_ANGGOTA);
  Rewrite(FileAnggota);

  for I := 1 to JumlahAnggota do
  begin
    Write(
      FileAnggota,
      DaftarAnggota[I]
    );
  end;

  Close(FileAnggota);
end;


{ ========================================================== }
{                      MUAT ANGGOTA                           }
{ ========================================================== }

procedure MuatAnggota;
var
  FileAnggota: file of TAnggota;
begin
  JumlahAnggota := 0;

  if not FileExists(FILE_ANGGOTA) then
    Exit;

  Assign(FileAnggota, FILE_ANGGOTA);
  Reset(FileAnggota);

  while not EOF(FileAnggota) do
  begin
    if JumlahAnggota >= MAX_ANGGOTA then
      Break;

    Inc(JumlahAnggota);

    Read(
      FileAnggota,
      DaftarAnggota[JumlahAnggota]
    );
  end;

  Close(FileAnggota);
end;


{ ========================================================== }
{                   SIMPAN PEMINJAMAN                         }
{ ========================================================== }

procedure SimpanPeminjaman;
var
  FilePeminjaman: file of TPeminjaman;
  I: Integer;
begin
  Assign(
    FilePeminjaman,
    FILE_PEMINJAMAN
  );

  Rewrite(FilePeminjaman);

  for I := 1 to JumlahPeminjaman do
  begin
    Write(
      FilePeminjaman,
      DaftarPeminjaman[I]
    );
  end;

  Close(FilePeminjaman);
end;


{ ========================================================== }
{                    MUAT PEMINJAMAN                          }
{ ========================================================== }

procedure MuatPeminjaman;
var
  FilePeminjaman: file of TPeminjaman;
begin
  JumlahPeminjaman := 0;

  if not FileExists(FILE_PEMINJAMAN) then
    Exit;

  Assign(
    FilePeminjaman,
    FILE_PEMINJAMAN
  );

  Reset(FilePeminjaman);

  while not EOF(FilePeminjaman) do
  begin
    if JumlahPeminjaman >= MAX_PEMINJAMAN then
      Break;

    Inc(JumlahPeminjaman);

    Read(
      FilePeminjaman,
      DaftarPeminjaman[JumlahPeminjaman]
    );
  end;

  Close(FilePeminjaman);
end;


{ ========================================================== }
{                       CARI BUKU                             }
{ ========================================================== }

function CariBuku(ID: Integer): Integer;
var
  I: Integer;
begin
  Result := 0;

  for I := 1 to JumlahBuku do
  begin
    if (DaftarBuku[I].ID = ID) and
       DaftarBuku[I].Aktif then
    begin
      Result := I;
      Exit;
    end;
  end;
end;


{ ========================================================== }
{                      CARI ANGGOTA                           }
{ ========================================================== }

function CariAnggota(ID: Integer): Integer;
var
  I: Integer;
begin
  Result := 0;

  for I := 1 to JumlahAnggota do
  begin
    if (DaftarAnggota[I].ID = ID) and
       DaftarAnggota[I].Aktif then
    begin
      Result := I;
      Exit;
    end;
  end;
end;


{ ========================================================== }
{                CARI PEMINJAMAN AKTIF                        }
{ ========================================================== }

function CariPeminjamanAktif(
  ID: Integer
): Integer;
var
  I: Integer;
begin
  Result := 0;

  for I := 1 to JumlahPeminjaman do
  begin
    if (DaftarPeminjaman[I].ID = ID) and
       (not DaftarPeminjaman[I].SudahKembali) then
    begin
      Result := I;
      Exit;
    end;
  end;
end;


{ ========================================================== }
{             CEK BUKU MASIH DIPINJAM                        }
{ ========================================================== }

function BukuMasihDipinjam(
  IDBuku: Integer
): Boolean;
var
  I: Integer;
begin
  Result := False;

  for I := 1 to JumlahPeminjaman do
  begin
    if (DaftarPeminjaman[I].IDBuku = IDBuku) and
       (not DaftarPeminjaman[I].SudahKembali) then
    begin
      Result := True;
      Exit;
    end;
  end;
end;


{ ========================================================== }
{           CEK ANGGOTA MASIH MEMINJAM                       }
{ ========================================================== }

function AnggotaMasihMeminjam(
  IDAnggota: Integer
): Boolean;
var
  I: Integer;
begin
  Result := False;

  for I := 1 to JumlahPeminjaman do
  begin
    if (DaftarPeminjaman[I].IDAnggota = IDAnggota) and
       (not DaftarPeminjaman[I].SudahKembali) then
    begin
      Result := True;
      Exit;
    end;
  end;
end;


{ ========================================================== }
{                     TAMBAH BUKU                            }
{ ========================================================== }

procedure TambahBuku;
var
  Posisi: Integer;
begin
  BersihkanLayar;
  JudulProgram;

  Posisi := CariSlotBukuKosong;

  if Posisi = 0 then
  begin
    if JumlahBuku >= MAX_BUKU then
    begin
      Writeln;
      Writeln('Kapasitas buku sudah penuh.');
      TekanEnter;
      Exit;
    end;

    Inc(JumlahBuku);
    Posisi := JumlahBuku;
  end;

  DaftarBuku[Posisi].ID :=
    IDBukuBerikutnya;

  Writeln;
  Writeln('================ TAMBAH BUKU ================');

  Writeln(
    'ID Buku: ',
    DaftarBuku[Posisi].ID
  );

  DaftarBuku[Posisi].Judul :=
    InputTextRequired(
      'Judul buku  : '
    );

  DaftarBuku[Posisi].Penulis :=
    InputTextRequired(
      'Penulis     : '
    );

  DaftarBuku[Posisi].Penerbit :=
    InputTextRequired(
      'Penerbit    : '
    );

  DaftarBuku[Posisi].Tahun :=
    InputInteger(
      'Tahun       : ',
      1000,
      2100
    );

  DaftarBuku[Posisi].Stok :=
    InputInteger(
      'Stok        : ',
      0,
      100000
    );

  DaftarBuku[Posisi].Aktif := True;

  SimpanBuku;

  Writeln;
  Writeln('Buku berhasil ditambahkan.');

  TekanEnter;
end;


{ ========================================================== }
{                    TAMPILKAN BUKU                          }
{ ========================================================== }

procedure TampilkanBuku;
var
  I: Integer;
  TotalAktif: Integer;
begin
  BersihkanLayar;
  JudulProgram;

  Writeln;
  Writeln('================ DAFTAR BUKU ================');

  TotalAktif := HitungBukuAktif;

  if TotalAktif = 0 then
  begin
    Writeln;
    Writeln('Belum ada data buku.');
    TekanEnter;
    Exit;
  end;

  Writeln;

  Writeln(
    'ID',
    '  Judul':25,
    ' Penulis':20,
    ' Tahun':8,
    ' Stok':7
  );

  Writeln(
    '--------------------------------------------------------------'
  );

  for I := 1 to JumlahBuku do
  begin
    if DaftarBuku[I].Aktif then
    begin
      Writeln(
        DaftarBuku[I].ID:2,
        '  ',
        DaftarBuku[I].Judul:25,
        DaftarBuku[I].Penulis:20,
        DaftarBuku[I].Tahun:8,
        DaftarBuku[I].Stok:7
      );
    end;
  end;

  Writeln(
    '--------------------------------------------------------------'
  );

  Writeln(
    'Jumlah buku aktif: ',
    TotalAktif
  );

  TekanEnter;
end;


{ ========================================================== }
{                       CARI BUKU                             }
{ ========================================================== }

procedure CariBukuMenu;
var
  KataKunci: string;
  I: Integer;
  Ditemukan: Boolean;
begin
  BersihkanLayar;
  JudulProgram;

  Writeln;
  Writeln('================ CARI BUKU ==================');

  KataKunci :=
    InputTextRequired(
      'Masukkan judul/penulis: '
    );

  Ditemukan := False;

  Writeln;

  for I := 1 to JumlahBuku do
  begin
    if DaftarBuku[I].Aktif and
       (
         (Pos(
           LowerCase(KataKunci),
           LowerCase(DaftarBuku[I].Judul)
         ) > 0)
         or
         (Pos(
           LowerCase(KataKunci),
           LowerCase(DaftarBuku[I].Penulis)
         ) > 0)
       ) then
    begin
      Ditemukan := True;

      Writeln(
        'ID       : ',
        DaftarBuku[I].ID
      );

      Writeln(
        'Judul    : ',
        DaftarBuku[I].Judul
      );

      Writeln(
        'Penulis  : ',
        DaftarBuku[I].Penulis
      );

      Writeln(
        'Penerbit : ',
        DaftarBuku[I].Penerbit
      );

      Writeln(
        'Tahun    : ',
        DaftarBuku[I].Tahun
      );

      Writeln(
        'Stok     : ',
        DaftarBuku[I].Stok
      );

      Writeln(
        '--------------------------------------------'
      );
    end;
  end;

  if not Ditemukan then
    Writeln('Buku tidak ditemukan.');

  TekanEnter;
end;


{ ========================================================== }
{                       EDIT BUKU                             }
{ ========================================================== }

procedure EditBuku;
var
  ID: Integer;
  Posisi: Integer;
  StokBaru: Integer;
  TahunBaru: Integer;
begin
  BersihkanLayar;
  JudulProgram;

  Writeln;
  Writeln('================ EDIT BUKU ==================');

  ID :=
    InputInteger(
      'ID Buku: ',
      1,
      2147483647
    );

  Posisi := CariBuku(ID);

  if Posisi = 0 then
  begin
    Writeln;
    Writeln('Buku tidak ditemukan.');
    TekanEnter;
    Exit;
  end;

  Writeln;
  Writeln(
    'Data sekarang:'
  );

  Writeln(
    'Judul    : ',
    DaftarBuku[Posisi].Judul
  );

  Writeln(
    'Penulis  : ',
    DaftarBuku[Posisi].Penulis
  );

  Writeln(
    'Penerbit : ',
    DaftarBuku[Posisi].Penerbit
  );

  Writeln(
    'Tahun    : ',
    DaftarBuku[Posisi].Tahun
  );

  Writeln(
    'Stok     : ',
    DaftarBuku[Posisi].Stok
  );

  Writeln;
  Writeln(
    'Kosongkan input teks untuk mempertahankan data lama.'
  );

  DaftarBuku[Posisi].Judul :=
    InputTextOptional(
      'Judul baru    : ',
      DaftarBuku[Posisi].Judul
    );

  DaftarBuku[Posisi].Penulis :=
    InputTextOptional(
      'Penulis baru  : ',
      DaftarBuku[Posisi].Penulis
    );

  DaftarBuku[Posisi].Penerbit :=
    InputTextOptional(
      'Penerbit baru : ',
      DaftarBuku[Posisi].Penerbit
    );

  TahunBaru :=
    InputInteger(
      'Tahun baru    : ',
      1000,
      2100
    );

  DaftarBuku[Posisi].Tahun := TahunBaru;

  if not BukuMasihDipinjam(ID) then
  begin
    StokBaru :=
      InputInteger(
        'Stok baru     : ',
        0,
        100000
      );

    DaftarBuku[Posisi].Stok :=
      StokBaru;
  end
  else
  begin
    Writeln;
    Writeln(
      'Buku sedang dipinjam.'
    );

    Writeln(
      'Stok tidak diubah untuk menjaga konsistensi data.'
    );
  end;

  SimpanBuku;

  Writeln;
  Writeln('Data buku berhasil diperbarui.');

  TekanEnter;
end;


{ ========================================================== }
{                    HAPUS BUKU AMAN                         }
{ ========================================================== }

procedure HapusBuku;
var
  ID: Integer;
  Posisi: Integer;
  Konfirmasi: string;
begin
  BersihkanLayar;
  JudulProgram;

  Writeln;
  Writeln('================ HAPUS BUKU =================');

  ID :=
    InputInteger(
      'ID Buku: ',
      1,
      2147483647
    );

  Posisi := CariBuku(ID);

  if Posisi = 0 then
  begin
    Writeln;
    Writeln('Buku tidak ditemukan.');
    TekanEnter;
    Exit;
  end;

  if BukuMasihDipinjam(ID) then
  begin
    Writeln;
    Writeln(
      'BUKU TIDAK BOLEH DIHAPUS.'
    );

    Writeln(
      'Buku masih tercatat sedang dipinjam.'
    );

    Writeln(
      'Kembalikan buku terlebih dahulu.'
    );

    TekanEnter;
    Exit;
  end;

  Writeln;
  Writeln(
    'Buku: ',
    DaftarBuku[Posisi].Judul
  );

  Write(
    'Ketik Y untuk menghapus: '
  );

  Readln(Konfirmasi);

  if UpperCase(Trim(Konfirmasi)) = 'Y' then
  begin
    DaftarBuku[Posisi].Aktif := False;

    SimpanBuku;

    Writeln;
    Writeln(
      'Buku berhasil dihapus.'
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


{ ========================================================== }
{                    SORTING BUKU                            }
{ ========================================================== }

procedure SortingBuku;
var
  I: Integer;
  J: Integer;
  Temp: TBuku;
begin
  if JumlahBuku <= 1 then
    Exit;

  for I := 1 to JumlahBuku - 1 do
  begin
    for J := I + 1 to JumlahBuku do
    begin
      if CompareText(
           DaftarBuku[I].Judul,
           DaftarBuku[J].Judul
         ) > 0 then
      begin
        Temp := DaftarBuku[I];
        DaftarBuku[I] := DaftarBuku[J];
        DaftarBuku[J] := Temp;
      end;
    end;
  end;

  SimpanBuku;
end;


{ ========================================================== }
{                    TAMBAH ANGGOTA                          }
{ ========================================================== }

procedure TambahAnggota;
var
  Posisi: Integer;
begin
  BersihkanLayar;
  JudulProgram;

  Posisi := CariSlotAnggotaKosong;

  if Posisi = 0 then
  begin
    if JumlahAnggota >= MAX_ANGGOTA then
    begin
      Writeln;
      Writeln('Kapasitas anggota sudah penuh.');
      TekanEnter;
      Exit;
    end;

    Inc(JumlahAnggota);
    Posisi := JumlahAnggota;
  end;

  DaftarAnggota[Posisi].ID :=
    IDAnggotaBerikutnya;

  Writeln;
  Writeln('============== TAMBAH ANGGOTA ===============');

  Writeln(
    'ID Anggota: ',
    DaftarAnggota[Posisi].ID
  );

  DaftarAnggota[Posisi].Nama :=
    InputTextRequired(
      'Nama       : '
    );

  DaftarAnggota[Posisi].Alamat :=
    InputTextRequired(
      'Alamat     : '
    );

  DaftarAnggota[Posisi].Telepon :=
    InputTextRequired(
      'Telepon    : '
    );

  DaftarAnggota[Posisi].Aktif := True;

  SimpanAnggota;

  Writeln;
  Writeln(
    'Anggota berhasil ditambahkan.'
  );

  TekanEnter;
end;


{ ========================================================== }
{                   TAMPILKAN ANGGOTA                        }
{ ========================================================== }

procedure TampilkanAnggota;
var
  I: Integer;
  TotalAktif: Integer;
begin
  BersihkanLayar;
  JudulProgram;

  Writeln;
  Writeln(
    '=============== DAFTAR ANGGOTA =============='
  );

  TotalAktif := HitungAnggotaAktif;

  if TotalAktif = 0 then
  begin
    Writeln;
    Writeln('Belum ada data anggota.');
    TekanEnter;
    Exit;
  end;

  Writeln;

  Writeln(
    'ID',
    '  Nama':25,
    ' Telepon':20
  );

  Writeln(
    '--------------------------------------------------------------'
  );

  for I := 1 to JumlahAnggota do
  begin
    if DaftarAnggota[I].Aktif then
    begin
      Writeln(
        DaftarAnggota[I].ID:2,
        '  ',
        DaftarAnggota[I].Nama:25,
        DaftarAnggota[I].Telepon:20
      );
    end;
  end;

  Writeln(
    '--------------------------------------------------------------'
  );

  Writeln(
    'Jumlah anggota aktif: ',
    TotalAktif
  );

  TekanEnter;
end;


{ ========================================================== }
{                    CARI ANGGOTA                            }
{ ========================================================== }

procedure CariAnggotaMenu;
var
  KataKunci: string;
  I: Integer;
  Ditemukan: Boolean;
begin
  BersihkanLayar;
  JudulProgram;

  Writeln;
  Writeln(
    '=============== CARI ANGGOTA ================'
  );

  KataKunci :=
    InputTextRequired(
      'Masukkan nama/telepon: '
    );

  Ditemukan := False;

  Writeln;

  for I := 1 to JumlahAnggota do
  begin
    if DaftarAnggota[I].Aktif and
       (
         (Pos(
           LowerCase(KataKunci),
           LowerCase(DaftarAnggota[I].Nama)
         ) > 0)
         or
         (Pos(
           LowerCase(KataKunci),
           LowerCase(DaftarAnggota[I].Telepon)
         ) > 0)
       ) then
    begin
      Ditemukan := True;

      Writeln(
        'ID      : ',
        DaftarAnggota[I].ID
      );

      Writeln(
        'Nama    : ',
        DaftarAnggota[I].Nama
      );

      Writeln(
        'Alamat  : ',
        DaftarAnggota[I].Alamat
      );

      Writeln(
        'Telepon : ',
        DaftarAnggota[I].Telepon
      );

      Writeln(
        '--------------------------------------------'
      );
    end;
  end;

  if not Ditemukan then
    Writeln(
      'Anggota tidak ditemukan.'
    );

  TekanEnter;
end;


{ ========================================================== }
{                    EDIT ANGGOTA                            }
{ ========================================================== }

procedure EditAnggota;
var
  ID: Integer;
  Posisi: Integer;
begin
  BersihkanLayar;
  JudulProgram;

  Writeln;
  Writeln(
    '=============== EDIT ANGGOTA ================'
  );

  ID :=
    InputInteger(
      'ID Anggota: ',
      1,
      2147483647
    );

  Posisi := CariAnggota(ID);

  if Posisi = 0 then
  begin
    Writeln;
    Writeln(
      'Anggota tidak ditemukan.'
    );

    TekanEnter;
    Exit;
  end;

  Writeln;
  Writeln(
    'Data sekarang:'
  );

  Writeln(
    'Nama    : ',
    DaftarAnggota[Posisi].Nama
  );

  Writeln(
    'Alamat  : ',
    DaftarAnggota[Posisi].Alamat
  );

  Writeln(
    'Telepon : ',
    DaftarAnggota[Posisi].Telepon
  );

  Writeln;
  Writeln(
    'Kosongkan input untuk mempertahankan data lama.'
  );

  DaftarAnggota[Posisi].Nama :=
    InputTextOptional(
      'Nama baru    : ',
      DaftarAnggota[Posisi].Nama
    );

  DaftarAnggota[Posisi].Alamat :=
    InputTextOptional(
      'Alamat baru  : ',
      DaftarAnggota[Posisi].Alamat
    );

  DaftarAnggota[Posisi].Telepon :=
    InputTextOptional(
      'Telepon baru : ',
      DaftarAnggota[Posisi].Telepon
    );

  SimpanAnggota;

  Writeln;
  Writeln(
    'Data anggota berhasil diperbarui.'
  );

  TekanEnter;
end;


{ ========================================================== }
{                  HAPUS ANGGOTA AMAN                        }
{ ========================================================== }

procedure HapusAnggota;
var
  ID: Integer;
  Posisi: Integer;
  Konfirmasi: string;
begin
  BersihkanLayar;
  JudulProgram;

  Writeln;
  Writeln(
    '============== HAPUS ANGGOTA ================'
  );

  ID :=
    InputInteger(
      'ID Anggota: ',
      1,
      2147483647
    );

  Posisi := CariAnggota(ID);

  if Posisi = 0 then
  begin
    Writeln;
    Writeln(
      'Anggota tidak ditemukan.'
    );

    TekanEnter;
    Exit;
  end;

  if AnggotaMasihMeminjam(ID) then
  begin
    Writeln;
    Writeln(
      'ANGGOTA TIDAK BOLEH DIHAPUS.'
    );

    Writeln(
      'Anggota masih memiliki buku yang sedang dipinjam.'
    );

    Writeln(
      'Kembalikan buku terlebih dahulu.'
    );

    TekanEnter;
    Exit;
  end;

  Writeln;
  Writeln(
    'Anggota: ',
    DaftarAnggota[Posisi].Nama
  );

  Write(
    'Ketik Y untuk menghapus: '
  );

  Readln(Konfirmasi);

  if UpperCase(Trim(Konfirmasi)) = 'Y' then
  begin
    DaftarAnggota[Posisi].Aktif := False;

    SimpanAnggota;

    Writeln;
    Writeln(
      'Anggota berhasil dihapus.'
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


{ ========================================================== }
{                  SORTING ANGGOTA                           }
{ ========================================================== }

procedure SortingAnggota;
var
  I: Integer;
  J: Integer;
  Temp: TAnggota;
begin
  if JumlahAnggota <= 1 then
    Exit;

  for I := 1 to JumlahAnggota - 1 do
  begin
    for J := I + 1 to JumlahAnggota do
    begin
      if CompareText(
           DaftarAnggota[I].Nama,
           DaftarAnggota[J].Nama
         ) > 0 then
      begin
        Temp := DaftarAnggota[I];
        DaftarAnggota[I] := DaftarAnggota[J];
        DaftarAnggota[J] := Temp;
      end;
    end;
  end;

  SimpanAnggota;
end;


{ ========================================================== }
{                    PEMINJAMAN                              }
{ ========================================================== }

procedure ProsesPeminjaman;
var
  IDBukuInput: Integer;
  IDAnggotaInput: Integer;
  IndexBuku: Integer;
  IndexAnggota: Integer;
begin
  BersihkanLayar;
  JudulProgram;

  Writeln;
  Writeln(
    '=============== PEMINJAMAN =================='
  );

  if HitungBukuAktif = 0 then
  begin
    Writeln;
    Writeln(
      'Belum ada buku aktif.'
    );

    TekanEnter;
    Exit;
  end;

  if HitungAnggotaAktif = 0 then
  begin
    Writeln;
    Writeln(
      'Belum ada anggota aktif.'
    );

    TekanEnter;
    Exit;
  end;

  IDBukuInput :=
    InputInteger(
      'ID Buku    : ',
      1,
      2147483647
    );

  IndexBuku :=
    CariBuku(IDBukuInput);

  if IndexBuku = 0 then
  begin
    Writeln;
    Writeln(
      'Buku tidak ditemukan.'
    );

    TekanEnter;
    Exit;
  end;

  if DaftarBuku[IndexBuku].Stok <= 0 then
  begin
    Writeln;
    Writeln(
      'Stok buku sedang habis.'
    );

    TekanEnter;
    Exit;
  end;

  IDAnggotaInput :=
    InputInteger(
      'ID Anggota : ',
      1,
      2147483647
    );

  IndexAnggota :=
    CariAnggota(IDAnggotaInput);

  if IndexAnggota = 0 then
  begin
    Writeln;
    Writeln(
      'Anggota tidak ditemukan.'
    );

    TekanEnter;
    Exit;
  end;

  if JumlahPeminjaman >= MAX_PEMINJAMAN then
  begin
    Writeln;
    Writeln(
      'Kapasitas peminjaman sudah penuh.'
    );

    TekanEnter;
    Exit;
  end;

  Inc(JumlahPeminjaman);

  DaftarPeminjaman[JumlahPeminjaman].ID :=
    IDPeminjamanBerikutnya;

  DaftarPeminjaman[JumlahPeminjaman].IDBuku :=
    IDBukuInput;

  DaftarPeminjaman[JumlahPeminjaman].IDAnggota :=
    IDAnggotaInput;

  DaftarPeminjaman[JumlahPeminjaman].TanggalPinjam :=
    Date;

  DaftarPeminjaman[JumlahPeminjaman].TanggalJatuhTempo :=
    Date + 7;

  DaftarPeminjaman[JumlahPeminjaman].TanggalKembali :=
    0;

  DaftarPeminjaman[JumlahPeminjaman].SudahKembali :=
    False;

  DaftarPeminjaman[JumlahPeminjaman].Denda :=
    0;

  Dec(
    DaftarBuku[IndexBuku].Stok
  );

  SimpanBuku;
  SimpanPeminjaman;

  Writeln;
  Writeln(
    'Peminjaman berhasil.'
  );

  Writeln(
    'ID Peminjaman : ',
    DaftarPeminjaman[JumlahPeminjaman].ID
  );

  Writeln(
    'Buku          : ',
    DaftarBuku[IndexBuku].Judul
  );

  Writeln(
    'Anggota       : ',
    DaftarAnggota[IndexAnggota].Nama
  );

  Writeln(
    'Tanggal Pinjam: ',
    FormatTanggal(
      DaftarPeminjaman[JumlahPeminjaman].TanggalPinjam
    )
  );

  Writeln(
    'Jatuh Tempo   : ',
    FormatTanggal(
      DaftarPeminjaman[JumlahPeminjaman].TanggalJatuhTempo
    )
  );

  TekanEnter;
end;


{ ========================================================== }
{                   PENGEMBALIAN                             }
{ ========================================================== }

procedure ProsesPengembalian;
var
  IDPeminjamanInput: Integer;
  IndexPeminjaman: Integer;
  IndexBuku: Integer;
  Terlambat: Integer;
begin
  BersihkanLayar;
  JudulProgram;

  Writeln;
  Writeln(
    '=============== PENGEMBALIAN ================'
  );

  if JumlahPeminjaman = 0 then
  begin
    Writeln;
    Writeln(
      'Belum ada transaksi peminjaman.'
    );

    TekanEnter;
    Exit;
  end;

  IDPeminjamanInput :=
    InputInteger(
      'ID Peminjaman: ',
      1,
      2147483647
    );

  IndexPeminjaman :=
    CariPeminjamanAktif(
      IDPeminjamanInput
    );

  if IndexPeminjaman = 0 then
  begin
    Writeln;
    Writeln(
      'Peminjaman tidak ditemukan atau sudah dikembalikan.'
    );

    TekanEnter;
    Exit;
  end;

  IndexBuku :=
    CariBuku(
      DaftarPeminjaman[IndexPeminjaman].IDBuku
    );

  DaftarPeminjaman[IndexPeminjaman].TanggalKembali :=
    Date;

  DaftarPeminjaman[IndexPeminjaman].SudahKembali :=
    True;

  Terlambat :=
    Trunc(
      Date -
      DaftarPeminjaman[IndexPeminjaman].TanggalJatuhTempo
    );

  if Terlambat > 0 then
  begin
    DaftarPeminjaman[IndexPeminjaman].Denda :=
      Terlambat * DENDA_PER_HARI;
  end
  else
  begin
    DaftarPeminjaman[IndexPeminjaman].Denda :=
      0;
  end;

  if IndexBuku > 0 then
  begin
    Inc(
      DaftarBuku[IndexBuku].Stok
    );
  end;

  SimpanBuku;
  SimpanPeminjaman;

  Writeln;
  Writeln(
    'Buku berhasil dikembalikan.'
  );

  Writeln(
    'Tanggal kembali: ',
    FormatTanggal(Date)
  );

  Writeln(
    'Keterlambatan  : ',
    Terlambat,
    ' hari'
  );

  Writeln(
    'Denda          : ',
    Rupiah(
      DaftarPeminjaman[IndexPeminjaman].Denda
    )
  );

  TekanEnter;
end;


{ ========================================================== }
{                  DATA PEMINJAMAN                           }
{ ========================================================== }

procedure TampilkanPeminjaman;
var
  I: Integer;
  IndexBuku: Integer;
  IndexAnggota: Integer;
  Status: string;
begin
  BersihkanLayar;
  JudulProgram;

  Writeln;
  Writeln(
    '============= DATA PEMINJAMAN ==============='
  );

  if JumlahPeminjaman = 0 then
  begin
    Writeln;
    Writeln(
      'Belum ada transaksi.'
    );

    TekanEnter;
    Exit;
  end;

  Writeln;

  for I := 1 to JumlahPeminjaman do
  begin

    IndexBuku :=
      CariBuku(
        DaftarPeminjaman[I].IDBuku
      );

    IndexAnggota :=
      CariAnggota(
        DaftarPeminjaman[I].IDAnggota
      );

    if DaftarPeminjaman[I].SudahKembali then
      Status := 'SUDAH KEMBALI'
    else
      Status := 'DIPINJAM';

    Writeln(
      'ID Peminjaman : ',
      DaftarPeminjaman[I].ID
    );

    if IndexBuku > 0 then
      Writeln(
        'Buku          : ',
        DaftarBuku[IndexBuku].Judul
      )
    else
      Writeln(
        'Buku          : ID ',
        DaftarPeminjaman[I].IDBuku
      );

    if IndexAnggota > 0 then
      Writeln(
        'Anggota       : ',
        DaftarAnggota[IndexAnggota].Nama
      )
    else
      Writeln(
        'Anggota       : ID ',
        DaftarPeminjaman[I].IDAnggota
      );

    Writeln(
      'Tanggal Pinjam: ',
      FormatTanggal(
        DaftarPeminjaman[I].TanggalPinjam
      )
    );

    Writeln(
      'Jatuh Tempo   : ',
      FormatTanggal(
        DaftarPeminjaman[I].TanggalJatuhTempo
      )
    );

    if DaftarPeminjaman[I].SudahKembali then
    begin
      Writeln(
        'Tanggal Kembali: ',
        FormatTanggal(
          DaftarPeminjaman[I].TanggalKembali
        )
      );
    end;

    Writeln(
      'Status         : ',
      Status
    );

    Writeln(
      'Denda          : ',
      Rupiah(
        DaftarPeminjaman[I].Denda
      )
    );

    Writeln(
      '------------------------------------------------------'
    );
  end;

  TekanEnter;
end;


{ ========================================================== }
{                LAPORAN BUKU                                }
{ ========================================================== }

procedure LaporanBuku;
var
  I: Integer;
  TotalJudul: Integer;
  TotalStok: Integer;
begin
  BersihkanLayar;
  JudulProgram;

  TotalJudul := 0;
  TotalStok := 0;

  Writeln;
  Writeln(
    '================ LAPORAN BUKU ================='
  );

  Writeln;

  for I := 1 to JumlahBuku do
  begin
    if DaftarBuku[I].Aktif then
    begin
      Inc(TotalJudul);

      TotalStok :=
        TotalStok +
        DaftarBuku[I].Stok;

      Writeln(
        'ID       : ',
        DaftarBuku[I].ID
      );

      Writeln(
        'Judul    : ',
        DaftarBuku[I].Judul
      );

      Writeln(
        'Penulis  : ',
        DaftarBuku[I].Penulis
      );

      Writeln(
        'Penerbit : ',
        DaftarBuku[I].Penerbit
      );

      Writeln(
        'Tahun    : ',
        DaftarBuku[I].Tahun
      );

      Writeln(
        'Stok     : ',
        DaftarBuku[I].Stok
      );

      Writeln(
        '------------------------------------------------------'
      );
    end;
  end;

  Writeln;
  Writeln(
    'Total jenis buku : ',
    TotalJudul
  );

  Writeln(
    'Total stok       : ',
    TotalStok
  );

  TekanEnter;
end;


{ ========================================================== }
{                  LAPORAN ANGGOTA                           }
{ ========================================================== }

procedure LaporanAnggota;
var
  I: Integer;
  TotalAnggota: Integer;
begin
  BersihkanLayar;
  JudulProgram;

  TotalAnggota := 0;

  Writeln;
  Writeln(
    '=============== LAPORAN ANGGOTA ==============='
  );

  Writeln;

  for I := 1 to JumlahAnggota do
  begin
    if DaftarAnggota[I].Aktif then
    begin
      Inc(TotalAnggota);

      Writeln(
        'ID      : ',
        DaftarAnggota[I].ID
      );

      Writeln(
        'Nama    : ',
        DaftarAnggota[I].Nama
      );

      Writeln(
        'Alamat  : ',
        DaftarAnggota[I].Alamat
      );

      Writeln(
        'Telepon : ',
        DaftarAnggota[I].Telepon
      );

      Writeln(
        '------------------------------------------------------'
      );
    end;
  end;

  Writeln;
  Writeln(
    'Total anggota aktif: ',
    TotalAnggota
  );

  TekanEnter;
end;


{ ========================================================== }
{             LAPORAN BUKU YANG SEDANG DIPINJAM              }
{ ========================================================== }

procedure LaporanSedangDipinjam;
var
  I: Integer;
  IndexBuku: Integer;
  IndexAnggota: Integer;
  JumlahAktif: Integer;
begin
  BersihkanLayar;
  JudulProgram;

  JumlahAktif := 0;

  Writeln;
  Writeln(
    '=========== BUKU SEDANG DIPINJAM ============='
  );

  Writeln;

  for I := 1 to JumlahPeminjaman do
  begin
    if not DaftarPeminjaman[I].SudahKembali then
    begin
      Inc(JumlahAktif);

      IndexBuku :=
        CariBuku(
          DaftarPeminjaman[I].IDBuku
        );

      IndexAnggota :=
        CariAnggota(
          DaftarPeminjaman[I].IDAnggota
        );

      Writeln(
        'ID Peminjaman : ',
        DaftarPeminjaman[I].ID
      );

      if IndexBuku > 0 then
        Writeln(
          'Buku          : ',
          DaftarBuku[IndexBuku].Judul
        )
      else
        Writeln(
          'Buku          : ID ',
          DaftarPeminjaman[I].IDBuku
        );

      if IndexAnggota > 0 then
        Writeln(
          'Anggota       : ',
          DaftarAnggota[IndexAnggota].Nama
        )
      else
        Writeln(
          'Anggota       : ID ',
          DaftarPeminjaman[I].IDAnggota
        );

      Writeln(
        'Pinjam        : ',
        FormatTanggal(
          DaftarPeminjaman[I].TanggalPinjam
        )
      );

      Writeln(
        'Jatuh Tempo   : ',
        FormatTanggal(
          DaftarPeminjaman[I].TanggalJatuhTempo
        )
      );

      Writeln(
        '------------------------------------------------------'
      );
    end;
  end;

  if JumlahAktif = 0 then
  begin
    Writeln(
      'Tidak ada buku yang sedang dipinjam.'
    );
  end;

  Writeln;
  Writeln(
    'Total sedang dipinjam: ',
    JumlahAktif
  );

  TekanEnter;
end;


{ ========================================================== }
{                  LAPORAN KETERLAMBATAN                     }
{ ========================================================== }

procedure LaporanKeterlambatan;
var
  I: Integer;
  IndexBuku: Integer;
  IndexAnggota: Integer;
  HariTerlambat: Integer;
  JumlahTerlambat: Integer;
  TotalDenda: Currency;
begin
  BersihkanLayar;
  JudulProgram;

  JumlahTerlambat := 0;
  TotalDenda := 0;

  Writeln;
  Writeln(
    '============= LAPORAN KETERLAMBATAN ==========='
  );

  Writeln;

  for I := 1 to JumlahPeminjaman do
  begin

    if not DaftarPeminjaman[I].SudahKembali then
    begin

      HariTerlambat :=
        Trunc(
          Date -
          DaftarPeminjaman[I].TanggalJatuhTempo
        );

      if HariTerlambat > 0 then
      begin

        Inc(JumlahTerlambat);

        IndexBuku :=
          CariBuku(
            DaftarPeminjaman[I].IDBuku
          );

        IndexAnggota :=
          CariAnggota(
            DaftarPeminjaman[I].IDAnggota
          );

        TotalDenda :=
          TotalDenda +
          (HariTerlambat * DENDA_PER_HARI);

        Writeln(
          'ID Peminjaman : ',
          DaftarPeminjaman[I].ID
        );

        if IndexBuku > 0 then
          Writeln(
            'Buku          : ',
            DaftarBuku[IndexBuku].Judul
          );

        if IndexAnggota > 0 then
          Writeln(
            'Anggota       : ',
            DaftarAnggota[IndexAnggota].Nama
          );

        Writeln(
          'Jatuh Tempo   : ',
          FormatTanggal(
            DaftarPeminjaman[I].TanggalJatuhTempo
          )
        );

        Writeln(
          'Terlambat     : ',
          HariTerlambat,
          ' hari'
        );

        Writeln(
          'Estimasi Denda: ',
          Rupiah(
            HariTerlambat * DENDA_PER_HARI
          )
        );

        Writeln(
          '------------------------------------------------------'
        );
      end;
    end;

  end;

  if JumlahTerlambat = 0 then
  begin
    Writeln(
      'Tidak ada peminjaman yang terlambat.'
    );
  end;

  Writeln;
  Writeln(
    'Jumlah terlambat : ',
    JumlahTerlambat
  );

  Writeln(
    'Total estimasi denda: ',
    Rupiah(TotalDenda)
  );

  TekanEnter;
end;


{ ========================================================== }
{                    LAPORAN TRANSAKSI                       }
{ ========================================================== }

procedure LaporanTransaksi;
var
  I: Integer;
  JumlahSelesai: Integer;
  JumlahAktif: Integer;
  TotalDenda: Currency;
begin
  BersihkanLayar;
  JudulProgram;

  JumlahSelesai := 0;
  JumlahAktif := 0;
  TotalDenda := 0;

  Writeln;
  Writeln(
    '=============== LAPORAN TRANSAKSI ============='
  );

  Writeln;

  for I := 1 to JumlahPeminjaman do
  begin

    if DaftarPeminjaman[I].SudahKembali then
      Inc(JumlahSelesai)
    else
      Inc(JumlahAktif);

    TotalDenda :=
      TotalDenda +
      DaftarPeminjaman[I].Denda;

  end;

  Writeln(
    'Total transaksi        : ',
    JumlahPeminjaman
  );

  Writeln(
    'Masih dipinjam         : ',
    JumlahAktif
  );

  Writeln(
    'Sudah dikembalikan     : ',
    JumlahSelesai
  );

  Writeln(
    'Total denda tercatat   : ',
    Rupiah(TotalDenda)
  );

  Writeln;

  TekanEnter;
end;


{ ========================================================== }
{                       DASHBOARD                            }
{ ========================================================== }

procedure Dashboard;
var
  I: Integer;
  BukuTersedia: Integer;
  BukuDipinjam: Integer;
  TotalDenda: Currency;
  Terlambat: Integer;
begin
  BukuTersedia := 0;
  BukuDipinjam := 0;
  TotalDenda := 0;
  Terlambat := 0;

  for I := 1 to JumlahBuku do
  begin
    if DaftarBuku[I].Aktif then
    begin
      BukuTersedia :=
        BukuTersedia +
        DaftarBuku[I].Stok;
    end;
  end;

  for I := 1 to JumlahPeminjaman do
  begin

    if not DaftarPeminjaman[I].SudahKembali then
      Inc(BukuDipinjam);

    TotalDenda :=
      TotalDenda +
      DaftarPeminjaman[I].Denda;

    if not DaftarPeminjaman[I].SudahKembali then
    begin
      if Date >
         DaftarPeminjaman[I].TanggalJatuhTempo then
      begin
        Inc(Terlambat);
      end;
    end;

  end;

  BersihkanLayar;
  JudulProgram;

  Writeln;
  Writeln(
    '================ DASHBOARD =================='
  );

  Writeln;

  Writeln(
    'Buku aktif             : ',
    HitungBukuAktif
  );

  Writeln(
    'Anggota aktif          : ',
    HitungAnggotaAktif
  );

  Writeln(
    'Stok tersedia          : ',
    BukuTersedia
  );

  Writeln(
    'Sedang dipinjam        : ',
    BukuDipinjam
  );

  Writeln(
    'Sudah dikembalikan     : ',
    JumlahPeminjaman -
    BukuDipinjam
  );

  Writeln(
    'Terlambat              : ',
    Terlambat
  );

  Writeln(
    'Total transaksi        : ',
    JumlahPeminjaman
  );

  Writeln(
    'Denda tercatat         : ',
    Rupiah(TotalDenda)
  );

  Writeln;
  Writeln(
    'Tanggal sistem: ',
    FormatTanggal(Date)
  );

  TekanEnter;
end;


{ ========================================================== }
{                       MENU BUKU                            }
{ ========================================================== }

procedure MenuBuku;
var
  Pilihan: Char;
begin
  repeat

    BersihkanLayar;
    JudulProgram;

    Writeln;
    Writeln(
      '================ MENU BUKU =================='
    );

    Writeln;
    Writeln('1. Tambah Buku');
    Writeln('2. Lihat Semua Buku');
    Writeln('3. Cari Buku');
    Writeln('4. Edit Buku');
    Writeln('5. Hapus Buku Aman');
    Writeln('6. Urutkan Buku Berdasarkan Judul');
    Writeln('7. Kembali');

    Writeln;

    Write('Pilihan: ');
    Readln(Pilihan);

    case Pilihan of

      '1':
        TambahBuku;

      '2':
        TampilkanBuku;

      '3':
        CariBukuMenu;

      '4':
        EditBuku;

      '5':
        HapusBuku;

      '6':
        begin
          SortingBuku;

          Writeln;
          Writeln(
            'Data buku berhasil diurutkan berdasarkan judul.'
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


{ ========================================================== }
{                    MENU ANGGOTA                            }
{ ========================================================== }

procedure MenuAnggota;
var
  Pilihan: Char;
begin
  repeat

    BersihkanLayar;
    JudulProgram;

    Writeln;
    Writeln(
      '============== MENU ANGGOTA ================='
    );

    Writeln;
    Writeln('1. Tambah Anggota');
    Writeln('2. Lihat Semua Anggota');
    Writeln('3. Cari Anggota');
    Writeln('4. Edit Anggota');
    Writeln('5. Hapus Anggota Aman');
    Writeln('6. Urutkan Anggota Berdasarkan Nama');
    Writeln('7. Kembali');

    Writeln;

    Write('Pilihan: ');
    Readln(Pilihan);

    case Pilihan of

      '1':
        TambahAnggota;

      '2':
        TampilkanAnggota;

      '3':
        CariAnggotaMenu;

      '4':
        EditAnggota;

      '5':
        HapusAnggota;

      '6':
        begin
          SortingAnggota;

          Writeln;
          Writeln(
            'Data anggota berhasil diurutkan berdasarkan nama.'
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


{ ========================================================== }
{                    MENU TRANSAKSI                          }
{ ========================================================== }

procedure MenuTransaksi;
var
  Pilihan: Char;
begin
  repeat

    BersihkanLayar;
    JudulProgram;

    Writeln;
    Writeln(
      '============= MENU TRANSAKSI ================'
    );

    Writeln;
    Writeln('1. Peminjaman Buku');
    Writeln('2. Pengembalian Buku');
    Writeln('3. Lihat Semua Peminjaman');
    Writeln('4. Lihat Buku Sedang Dipinjam');
    Writeln('5. Laporan Keterlambatan');
    Writeln('6. Kembali');

    Writeln;

    Write('Pilihan: ');
    Readln(Pilihan);

    case Pilihan of

      '1':
        ProsesPeminjaman;

      '2':
        ProsesPengembalian;

      '3':
        TampilkanPeminjaman;

      '4':
        LaporanSedangDipinjam;

      '5':
        LaporanKeterlambatan;

      '6':
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


{ ========================================================== }
{                     MENU LAPORAN                           }
{ ========================================================== }

procedure MenuLaporan;
var
  Pilihan: Char;
begin
  repeat

    BersihkanLayar;
    JudulProgram;

    Writeln;
    Writeln(
      '================ MENU LAPORAN ==============='
    );

    Writeln;
    Writeln('1. Laporan Buku');
    Writeln('2. Laporan Anggota');
    Writeln('3. Laporan Transaksi');
    Writeln('4. Buku Sedang Dipinjam');
    Writeln('5. Laporan Keterlambatan');
    Writeln('6. Kembali');

    Writeln;

    Write('Pilihan: ');
    Readln(Pilihan);

    case Pilihan of

      '1':
        LaporanBuku;

      '2':
        LaporanAnggota;

      '3':
        LaporanTransaksi;

      '4':
        LaporanSedangDipinjam;

      '5':
        LaporanKeterlambatan;

      '6':
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


{ ========================================================== }
{                     MENU UTAMA                             }
{ ========================================================== }

procedure MenuUtama;
var
  Pilihan: Char;
begin
  repeat

    BersihkanLayar;
    JudulProgram;

    Writeln;
    Writeln('1. Dashboard');
    Writeln('2. Data Buku');
    Writeln('3. Data Anggota');
    Writeln('4. Transaksi Perpustakaan');
    Writeln('5. Laporan');
    Writeln('6. Keluar');

    Writeln;

    Write('Pilihan: ');
    Readln(Pilihan);

    case Pilihan of

      '1':
        Dashboard;

      '2':
        MenuBuku;

      '3':
        MenuAnggota;

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


{ ========================================================== }
{                     PROGRAM UTAMA                          }
{ ========================================================== }

begin

  JumlahBuku := 0;
  JumlahAnggota := 0;
  JumlahPeminjaman := 0;

  MuatBuku;
  MuatAnggota;
  MuatPeminjaman;

  MenuUtama;

end.