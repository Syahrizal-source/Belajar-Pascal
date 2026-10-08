program SistemManajemenBengkel;

{$mode objfpc}{$H+}

uses
  SysUtils,
  Classes,
  DateUtils;

const
  FILE_PELANGGAN = 'pelanggan.dat';
  FILE_KENDARAAN = 'kendaraan.dat';
  FILE_SERVICE = 'service.dat';
  FOLDER_BACKUP = 'backup';
  MAX_ITEM_SERVICE = 20;
  MAX_LOGIN = 3;

type
  TPelangganData = record
    ID: Integer;
    Nama: string[100];
    Alamat: string[150];
    Telepon: string[30];
  end;

  TKendaraanData = record
    ID: Integer;
    JenisKendaraan: string[20];
    NomorPolisi: string[30];
    Merk: string[50];
    Model: string[50];
    Tahun: Integer;
    Status: string[20];
    JumlahPintu: Integer;
    JenisMotor: string[50];
  end;

  TItemServiceData = record
    Nama: string[100];
    Harga: Currency;
  end;

  TServiceData = record
    ID: Integer;
    IDPelanggan: Integer;
    IDKendaraan: Integer;
    Tanggal: TDateTime;
    Keluhan: string[200];
    Status: string[20];
    JumlahItem: Integer;
    Items: array[1..MAX_ITEM_SERVICE] of TItemServiceData;
  end;

  TPelanggan = class
  private
    FID: Integer;
    FNama: string;
    FAlamat: string;
    FTelepon: string;
  public
    constructor Create(AID: Integer; const ANama, AAlamat, ATelepon: string);
    function ToData: TPelangganData;
    property ID: Integer read FID;
    property Nama: string read FNama write FNama;
    property Alamat: string read FAlamat write FAlamat;
    property Telepon: string read FTelepon write FTelepon;
  end;

  TKendaraan = class
  private
    FID: Integer;
    FNomorPolisi: string;
    FMerk: string;
    FModel: string;
    FTahun: Integer;
    FStatus: string;
  public
    constructor Create(AID: Integer; const ANomorPolisi, AMerk, AModel: string; ATahun: Integer);
    function Jenis: string; virtual;
    function BiayaAdministrasi: Currency; virtual;
    function ToData: TKendaraanData; virtual;
    property ID: Integer read FID;
    property NomorPolisi: string read FNomorPolisi write FNomorPolisi;
    property Merk: string read FMerk write FMerk;
    property Model: string read FModel write FModel;
    property Tahun: Integer read FTahun write FTahun;
    property Status: string read FStatus write FStatus;
  end;

  TMobil = class(TKendaraan)
  private
    FJumlahPintu: Integer;
  public
    constructor Create(AID: Integer; const ANomorPolisi, AMerk, AModel: string; ATahun, AJumlahPintu: Integer);
    function Jenis: string; override;
    function BiayaAdministrasi: Currency; override;
    function ToData: TKendaraanData; override;
    property JumlahPintu: Integer read FJumlahPintu write FJumlahPintu;
  end;

  TMotor = class(TKendaraan)
  private
    FJenisMotor: string;
  public
    constructor Create(AID: Integer; const ANomorPolisi, AMerk, AModel: string; ATahun: Integer; const AJenisMotor: string);
    function Jenis: string; override;
    function BiayaAdministrasi: Currency; override;
    function ToData: TKendaraanData; override;
    property JenisMotor: string read FJenisMotor write FJenisMotor;
  end;

  TItemService = class
  private
    FNama: string;
    FHarga: Currency;
  public
    constructor Create(const ANama: string; AHarga: Currency);
    function ToData: TItemServiceData;
    property Nama: string read FNama;
    property Harga: Currency read FHarga;
  end;

  TService = class
  private
    FID: Integer;
    FIDPelanggan: Integer;
    FIDKendaraan: Integer;
    FTanggal: TDateTime;
    FKeluhan: string;
    FStatus: string;
    FItems: array of TItemService;
    FJumlahItem: Integer;
  public
    constructor Create(AID, AIDPelanggan, AIDKendaraan: Integer; const AKeluhan: string);
    destructor Destroy; override;
    procedure TambahItem(const ANama: string; AHarga: Currency);
    function TotalItem: Currency;
    function JumlahItem: Integer;
    function ItemNama(Index: Integer): string;
    function ItemHarga(Index: Integer): Currency;
    function ToData: TServiceData;
    property ID: Integer read FID;
    property IDPelanggan: Integer read FIDPelanggan;
    property IDKendaraan: Integer read FIDKendaraan;
    property Tanggal: TDateTime read FTanggal;
    property Keluhan: string read FKeluhan write FKeluhan;
    property Status: string read FStatus write FStatus;
  end;

  TPelangganArray = array of TPelanggan;
  TKendaraanArray = array of TKendaraan;
  TServiceArray = array of TService;

var
  DaftarPelanggan: TPelangganArray;
  DaftarKendaraan: TKendaraanArray;
  DaftarService: TServiceArray;
  JumlahPelanggan, JumlahKendaraan, JumlahService: Integer;
  RoleAktif: string;

procedure BersihkanLayar;
begin
  Write(#27, '[2J');
  Write(#27, '[H');
end;

procedure TungguEnter;
begin
  Writeln;
  Write('Tekan ENTER untuk melanjutkan...');
  Readln;
end;

procedure TampilkanJudul;
begin
  Writeln('==============================================================');
  Writeln('                 SISTEM MANAJEMEN BENGKEL');
  Writeln('==============================================================');
  Writeln('Login: ', RoleAktif);
  Writeln('--------------------------------------------------------------');
end;

function FormatRupiah(Nilai: Currency): string;
begin
  Result := 'Rp ' + FormatFloat('#,##0', Nilai);
end;

function InputString(const Pesan: string): string;
begin
  repeat
    Write(Pesan);
    Readln(Result);
    Result := Trim(Result);
    if Result = '' then Writeln('Input tidak boleh kosong.');
  until Result <> '';
end;

function InputInteger(const Pesan: string; Minimum, Maksimum: Integer): Integer;
var
  Teks: string;
  Nilai: Integer;
  Valid: Boolean;
begin
  repeat
    Write(Pesan);
    Readln(Teks);
    Valid := TryStrToInt(Trim(Teks), Nilai);
    if not Valid then Writeln('Input harus berupa angka.')
    else if Nilai < Minimum then begin Writeln('Nilai minimal adalah ', Minimum, '.'); Valid := False; end
    else if Nilai > Maksimum then begin Writeln('Nilai maksimal adalah ', Maksimum, '.'); Valid := False; end;
  until Valid;
  Result := Nilai;
end;

function InputCurrency(const Pesan: string; Minimum: Currency): Currency;
var
  Teks: string;
  Nilai: Currency;
  Valid: Boolean;
begin
  repeat
    Write(Pesan);
    Readln(Teks);
    Teks := StringReplace(Trim(Teks), ',', '', [rfReplaceAll]);
    Valid := TryStrToCurr(Teks, Nilai);
    if not Valid then Writeln('Input harus berupa angka.')
    else if Nilai < Minimum then begin Writeln('Nilai minimal adalah ', FormatRupiah(Minimum), '.'); Valid := False; end;
  until Valid;
  Result := Nilai;
end;

function Konfirmasi(const Pesan: string): Boolean;
var
  Jawaban: string;
begin
  repeat
    Write(Pesan);
    Readln(Jawaban);
    Jawaban := UpperCase(Trim(Jawaban));
    if Jawaban = 'Y' then begin Result := True; Exit; end;
    if Jawaban = 'N' then begin Result := False; Exit; end;
    Writeln('Masukkan Y atau N.');
  until False;
end;

function ParseTanggal(const Teks: string; out Tanggal: TDateTime): Boolean;
var
  Bagian: TStringList;
  D, M, Y: Integer;
begin
  Result := False;
  Bagian := TStringList.Create;
  try
    Bagian.Delimiter := '-';
    Bagian.StrictDelimiter := True;
    Bagian.DelimitedText := Trim(Teks);
    if Bagian.Count <> 3 then Exit;
    if not TryStrToInt(Bagian[0], D) then Exit;
    if not TryStrToInt(Bagian[1], M) then Exit;
    if not TryStrToInt(Bagian[2], Y) then Exit;
    if (D < 1) or (D > 31) or (M < 1) or (M > 12) or (Y < 1) then Exit;
    try
      Tanggal := EncodeDate(Word(Y), Word(M), Word(D));
      Result := True;
    except
      Result := False;
    end;
  finally
    Bagian.Free;
  end;
end;

function BolehKelolaMaster: Boolean;
begin
  Result := RoleAktif = 'ADMIN';
end;

constructor TPelanggan.Create(AID: Integer; const ANama, AAlamat, ATelepon: string);
begin
  FID := AID; FNama := ANama; FAlamat := AAlamat; FTelepon := ATelepon;
end;

function TPelanggan.ToData: TPelangganData;
begin
  Result.ID := FID; Result.Nama := FNama; Result.Alamat := FAlamat; Result.Telepon := FTelepon;
end;

constructor TKendaraan.Create(AID: Integer; const ANomorPolisi, AMerk, AModel: string; ATahun: Integer);
begin
  FID := AID; FNomorPolisi := ANomorPolisi; FMerk := AMerk; FModel := AModel; FTahun := ATahun; FStatus := 'TERSEDIA';
end;

function TKendaraan.Jenis: string;
begin Result := 'KENDARAAN'; end;

function TKendaraan.BiayaAdministrasi: Currency;
begin Result := 50000; end;

function TKendaraan.ToData: TKendaraanData;
begin
  Result.ID := FID; Result.JenisKendaraan := Jenis; Result.NomorPolisi := FNomorPolisi;
  Result.Merk := FMerk; Result.Model := FModel; Result.Tahun := FTahun; Result.Status := FStatus;
  Result.JumlahPintu := 0; Result.JenisMotor := '';
end;

constructor TMobil.Create(AID: Integer; const ANomorPolisi, AMerk, AModel: string; ATahun, AJumlahPintu: Integer);
begin
  inherited Create(AID, ANomorPolisi, AMerk, AModel, ATahun); FJumlahPintu := AJumlahPintu;
end;

function TMobil.Jenis: string;
begin Result := 'MOBIL'; end;

function TMobil.BiayaAdministrasi: Currency;
begin Result := 75000; end;

function TMobil.ToData: TKendaraanData;
begin Result := inherited ToData; Result.JenisKendaraan := 'MOBIL'; Result.JumlahPintu := FJumlahPintu; end;

constructor TMotor.Create(AID: Integer; const ANomorPolisi, AMerk, AModel: string; ATahun: Integer; const AJenisMotor: string);
begin
  inherited Create(AID, ANomorPolisi, AMerk, AModel, ATahun); FJenisMotor := AJenisMotor;
end;

function TMotor.Jenis: string;
begin Result := 'MOTOR'; end;

function TMotor.BiayaAdministrasi: Currency;
begin Result := 30000; end;

function TMotor.ToData: TKendaraanData;
begin Result := inherited ToData; Result.JenisKendaraan := 'MOTOR'; Result.JenisMotor := FJenisMotor; end;

constructor TItemService.Create(const ANama: string; AHarga: Currency);
begin FNama := ANama; FHarga := AHarga; end;

function TItemService.ToData: TItemServiceData;
begin Result.Nama := FNama; Result.Harga := FHarga; end;

constructor TService.Create(AID, AIDPelanggan, AIDKendaraan: Integer; const AKeluhan: string);
begin
  FID := AID; FIDPelanggan := AIDPelanggan; FIDKendaraan := AIDKendaraan;
  FTanggal := Date; FKeluhan := AKeluhan; FStatus := 'ANTRIAN'; FJumlahItem := 0;
  SetLength(FItems, MAX_ITEM_SERVICE);
end;

destructor TService.Destroy;
var I: Integer;
begin
  for I := 0 to FJumlahItem - 1 do FItems[I].Free;
  SetLength(FItems, 0);
  inherited Destroy;
end;

procedure TService.TambahItem(const ANama: string; AHarga: Currency);
begin
  if FJumlahItem >= MAX_ITEM_SERVICE then Exit;
  FItems[FJumlahItem] := TItemService.Create(ANama, AHarga);
  Inc(FJumlahItem);
end;

function TService.TotalItem: Currency;
var I: Integer;
begin
  Result := 0;
  for I := 0 to FJumlahItem - 1 do Result := Result + FItems[I].Harga;
end;

function TService.JumlahItem: Integer;
begin Result := FJumlahItem; end;

function TService.ItemNama(Index: Integer): string;
begin
  if (Index >= 0) and (Index < FJumlahItem) then Result := FItems[Index].Nama else Result := '';
end;

function TService.ItemHarga(Index: Integer): Currency;
begin
  if (Index >= 0) and (Index < FJumlahItem) then Result := FItems[Index].Harga else Result := 0;
end;

function TService.ToData: TServiceData;
var I: Integer;
begin
  Result.ID := FID; Result.IDPelanggan := FIDPelanggan; Result.IDKendaraan := FIDKendaraan;
  Result.Tanggal := FTanggal; Result.Keluhan := FKeluhan; Result.Status := FStatus; Result.JumlahItem := FJumlahItem;
  for I := 1 to MAX_ITEM_SERVICE do begin Result.Items[I].Nama := ''; Result.Items[I].Harga := 0; end;
  for I := 0 to FJumlahItem - 1 do Result.Items[I + 1] := FItems[I].ToData;
end;

procedure HapusSemuaObject;
var I: Integer;
begin
  for I := 0 to JumlahPelanggan - 1 do DaftarPelanggan[I].Free;
  for I := 0 to JumlahKendaraan - 1 do DaftarKendaraan[I].Free;
  for I := 0 to JumlahService - 1 do DaftarService[I].Free;
  SetLength(DaftarPelanggan, 0); SetLength(DaftarKendaraan, 0); SetLength(DaftarService, 0);
  JumlahPelanggan := 0; JumlahKendaraan := 0; JumlahService := 0;
end;

function IDPelangganBerikutnya: Integer;
var I, Terbesar: Integer;
begin Terbesar := 0; for I := 0 to JumlahPelanggan - 1 do if DaftarPelanggan[I].ID > Terbesar then Terbesar := DaftarPelanggan[I].ID; Result := Terbesar + 1; end;

function IDKendaraanBerikutnya: Integer;
var I, Terbesar: Integer;
begin Terbesar := 0; for I := 0 to JumlahKendaraan - 1 do if DaftarKendaraan[I].ID > Terbesar then Terbesar := DaftarKendaraan[I].ID; Result := Terbesar + 1; end;

function IDServiceBerikutnya: Integer;
var I, Terbesar: Integer;
begin Terbesar := 0; for I := 0 to JumlahService - 1 do if DaftarService[I].ID > Terbesar then Terbesar := DaftarService[I].ID; Result := Terbesar + 1; end;

function CariPelanggan(ID: Integer): Integer;
var I: Integer;
begin Result := -1; for I := 0 to JumlahPelanggan - 1 do if DaftarPelanggan[I].ID = ID then begin Result := I; Exit; end; end;

function CariKendaraan(ID: Integer): Integer;
var I: Integer;
begin Result := -1; for I := 0 to JumlahKendaraan - 1 do if DaftarKendaraan[I].ID = ID then begin Result := I; Exit; end; end;

function CariService(ID: Integer): Integer;
var I: Integer;
begin Result := -1; for I := 0 to JumlahService - 1 do if DaftarService[I].ID = ID then begin Result := I; Exit; end; end;

function CariNomorPolisi(const Nomor: string): Integer;
var I: Integer;
begin
  Result := -1;
  for I := 0 to JumlahKendaraan - 1 do
    if UpperCase(DaftarKendaraan[I].NomorPolisi) = UpperCase(Trim(Nomor)) then begin Result := I; Exit; end;
end;

function AdaServiceUntukPelanggan(ID: Integer): Boolean;
var I: Integer;
begin Result := False; for I := 0 to JumlahService - 1 do if DaftarService[I].IDPelanggan = ID then begin Result := True; Exit; end; end;

function AdaServiceUntukKendaraan(ID: Integer): Boolean;
var I: Integer;
begin Result := False; for I := 0 to JumlahService - 1 do if DaftarService[I].IDKendaraan = ID then begin Result := True; Exit; end; end;

procedure SimpanPelanggan;
var F: file of TPelangganData; I: Integer; Data: TPelangganData;
begin AssignFile(F, FILE_PELANGGAN); Rewrite(F); for I := 0 to JumlahPelanggan - 1 do begin Data := DaftarPelanggan[I].ToData; Write(F, Data); end; CloseFile(F); end;

procedure MuatPelanggan;
var F: file of TPelangganData; Data: TPelangganData;
begin
  if not FileExists(FILE_PELANGGAN) then Exit;
  AssignFile(F, FILE_PELANGGAN); Reset(F);
  while not EOF(F) do begin
    Read(F, Data); SetLength(DaftarPelanggan, JumlahPelanggan + 1);
    DaftarPelanggan[JumlahPelanggan] := TPelanggan.Create(Data.ID, Data.Nama, Data.Alamat, Data.Telepon);
    Inc(JumlahPelanggan);
  end;
  CloseFile(F);
end;

procedure SimpanKendaraan;
var F: file of TKendaraanData; I: Integer; Data: TKendaraanData;
begin AssignFile(F, FILE_KENDARAAN); Rewrite(F); for I := 0 to JumlahKendaraan - 1 do begin Data := DaftarKendaraan[I].ToData; Write(F, Data); end; CloseFile(F); end;

procedure MuatKendaraan;
var F: file of TKendaraanData; Data: TKendaraanData;
begin
  if not FileExists(FILE_KENDARAAN) then Exit;
  AssignFile(F, FILE_KENDARAAN); Reset(F);
  while not EOF(F) do begin
    Read(F, Data); SetLength(DaftarKendaraan, JumlahKendaraan + 1);
    if UpperCase(Data.JenisKendaraan) = 'MOBIL' then
      DaftarKendaraan[JumlahKendaraan] := TMobil.Create(Data.ID, Data.NomorPolisi, Data.Merk, Data.Model, Data.Tahun, Data.JumlahPintu)
    else if UpperCase(Data.JenisKendaraan) = 'MOTOR' then
      DaftarKendaraan[JumlahKendaraan] := TMotor.Create(Data.ID, Data.NomorPolisi, Data.Merk, Data.Model, Data.Tahun, Data.JenisMotor)
    else
      DaftarKendaraan[JumlahKendaraan] := TKendaraan.Create(Data.ID, Data.NomorPolisi, Data.Merk, Data.Model, Data.Tahun);
    DaftarKendaraan[JumlahKendaraan].Status := Data.Status;
    Inc(JumlahKendaraan);
  end;
  CloseFile(F);
end;

procedure SimpanService;
var F: file of TServiceData; I: Integer; Data: TServiceData;
begin AssignFile(F, FILE_SERVICE); Rewrite(F); for I := 0 to JumlahService - 1 do begin Data := DaftarService[I].ToData; Write(F, Data); end; CloseFile(F); end;

procedure MuatService;
var F: file of TServiceData; Data: TServiceData; I: Integer;
begin
  if not FileExists(FILE_SERVICE) then Exit;
  AssignFile(F, FILE_SERVICE); Reset(F);
  while not EOF(F) do begin
    Read(F, Data); SetLength(DaftarService, JumlahService + 1);
    DaftarService[JumlahService] := TService.Create(Data.ID, Data.IDPelanggan, Data.IDKendaraan, Data.Keluhan);
    DaftarService[JumlahService].Status := Data.Status;
    for I := 1 to Data.JumlahItem do begin if I > MAX_ITEM_SERVICE then Break; DaftarService[JumlahService].TambahItem(Data.Items[I].Nama, Data.Items[I].Harga); end;
    Inc(JumlahService);
  end;
  CloseFile(F);
end;

procedure SalinFile(const Sumber, Tujuan: string);
var Src, Dst: TFileStream;
begin
  Src := TFileStream.Create(Sumber, fmOpenRead or fmShareDenyWrite);
  try
    Dst := TFileStream.Create(Tujuan, fmCreate);
    try Dst.CopyFrom(Src, 0); finally Dst.Free; end;
  finally Src.Free; end;
end;

function BackupSemuaData: Boolean;
var
  BackupPelanggan, BackupKendaraan, BackupService: string;
begin
  Result := False;
  if not ForceDirectories(FOLDER_BACKUP) and not DirectoryExists(FOLDER_BACKUP) then Exit;
  BackupPelanggan := IncludeTrailingPathDelimiter(FOLDER_BACKUP) + FILE_PELANGGAN;
  BackupKendaraan := IncludeTrailingPathDelimiter(FOLDER_BACKUP) + FILE_KENDARAAN;
  BackupService := IncludeTrailingPathDelimiter(FOLDER_BACKUP) + FILE_SERVICE;
  SimpanPelanggan; SimpanKendaraan; SimpanService;
  SalinFile(FILE_PELANGGAN, BackupPelanggan);
  SalinFile(FILE_KENDARAAN, BackupKendaraan);
  SalinFile(FILE_SERVICE, BackupService);
  Result := True;
end;

function RestoreSemuaData: Boolean;
var
  BackupPelanggan, BackupKendaraan, BackupService: string;
begin
  Result := False;
  BackupPelanggan := IncludeTrailingPathDelimiter(FOLDER_BACKUP) + FILE_PELANGGAN;
  BackupKendaraan := IncludeTrailingPathDelimiter(FOLDER_BACKUP) + FILE_KENDARAAN;
  BackupService := IncludeTrailingPathDelimiter(FOLDER_BACKUP) + FILE_SERVICE;
  if not FileExists(BackupPelanggan) or not FileExists(BackupKendaraan) or not FileExists(BackupService) then Exit;
  SalinFile(BackupPelanggan, FILE_PELANGGAN);
  SalinFile(BackupKendaraan, FILE_KENDARAAN);
  SalinFile(BackupService, FILE_SERVICE);
  Result := True;
end;

procedure ReloadSemuaData;
begin HapusSemuaObject; MuatPelanggan; MuatKendaraan; MuatService; end;

procedure EditPelanggan;
var ID, I: Integer; Nama, Alamat, Telepon: string;
begin
  if not BolehKelolaMaster then begin Writeln('Hanya ADMIN yang boleh mengedit pelanggan.'); TungguEnter; Exit; end;
  BersihkanLayar; TampilkanJudul; Writeln('================ EDIT PELANGGAN ===================');
  ID := InputInteger('ID Pelanggan: ', 1, 2147483647); I := CariPelanggan(ID);
  if I < 0 then begin Writeln('Pelanggan tidak ditemukan.'); TungguEnter; Exit; end;
  Writeln('Nama lama    : ', DaftarPelanggan[I].Nama);
  Writeln('Alamat lama  : ', DaftarPelanggan[I].Alamat);
  Writeln('Telepon lama : ', DaftarPelanggan[I].Telepon);
  Nama := InputString('Nama baru    : '); Alamat := InputString('Alamat baru  : '); Telepon := InputString('Telepon baru : ');
  if Konfirmasi('Simpan perubahan? (Y/N): ') then begin
    DaftarPelanggan[I].Nama := Nama; DaftarPelanggan[I].Alamat := Alamat; DaftarPelanggan[I].Telepon := Telepon; SimpanPelanggan; Writeln('Pelanggan berhasil diubah.');
  end else Writeln('Perubahan dibatalkan.');
  TungguEnter;
end;

procedure HapusPelanggan;
var ID, I, J: Integer;
begin
  if not BolehKelolaMaster then begin Writeln('Hanya ADMIN yang boleh menghapus pelanggan.'); TungguEnter; Exit; end;
  BersihkanLayar; TampilkanJudul; Writeln('================ HAPUS PELANGGAN ==================');
  ID := InputInteger('ID Pelanggan: ', 1, 2147483647); I := CariPelanggan(ID);
  if I < 0 then begin Writeln('Pelanggan tidak ditemukan.'); TungguEnter; Exit; end;
  Writeln('Nama: ', DaftarPelanggan[I].Nama);
  if AdaServiceUntukPelanggan(ID) then begin Writeln('Tidak dapat dihapus karena sudah memiliki riwayat service.'); TungguEnter; Exit; end;
  if Konfirmasi('Yakin hapus pelanggan? (Y/N): ') then begin
    DaftarPelanggan[I].Free;
    for J := I to JumlahPelanggan - 2 do DaftarPelanggan[J] := DaftarPelanggan[J + 1];
    Dec(JumlahPelanggan); SetLength(DaftarPelanggan, JumlahPelanggan); SimpanPelanggan; Writeln('Pelanggan berhasil dihapus.');
  end else Writeln('Penghapusan dibatalkan.');
  TungguEnter;
end;

procedure EditKendaraan;
var ID, I, Tahun, Pintu: Integer; Nomor, Merk, Model, JenisMotor, Pilihan: string;
begin
  if not BolehKelolaMaster then begin Writeln('Hanya ADMIN yang boleh mengedit kendaraan.'); TungguEnter; Exit; end;
  BersihkanLayar; TampilkanJudul; Writeln('================ EDIT KENDARAAN ===================');
  ID := InputInteger('ID Kendaraan: ', 1, 2147483647); I := CariKendaraan(ID);
  if I < 0 then begin Writeln('Kendaraan tidak ditemukan.'); TungguEnter; Exit; end;
  if DaftarKendaraan[I].Status <> 'TERSEDIA' then begin Writeln('Kendaraan sedang dalam proses service dan tidak boleh diedit.'); TungguEnter; Exit; end;
  Nomor := InputString('Nomor Polisi baru: '); if (CariNomorPolisi(Nomor) >= 0) and (CariNomorPolisi(Nomor) <> I) then begin Writeln('Nomor polisi sudah digunakan.'); TungguEnter; Exit; end;
  Merk := InputString('Merk baru        : '); Model := InputString('Model baru       : '); Tahun := InputInteger('Tahun baru       : ', 1900, 2100);
  if DaftarKendaraan[I] is TMobil then
    Pintu := InputInteger('Jumlah pintu     : ', 2, 10)
  else if DaftarKendaraan[I] is TMotor then
    JenisMotor := InputString('Jenis motor baru : ');
  Pilihan := UpperCase(InputString('Konfirmasi simpan (Y/N): '));
  if Pilihan <> 'Y' then begin Writeln('Perubahan dibatalkan.'); TungguEnter; Exit; end;
  DaftarKendaraan[I].NomorPolisi := Nomor; DaftarKendaraan[I].Merk := Merk; DaftarKendaraan[I].Model := Model; DaftarKendaraan[I].Tahun := Tahun;
  if DaftarKendaraan[I] is TMobil then TMobil(DaftarKendaraan[I]).JumlahPintu := Pintu
  else if DaftarKendaraan[I] is TMotor then TMotor(DaftarKendaraan[I]).JenisMotor := JenisMotor;
  SimpanKendaraan; Writeln('Kendaraan berhasil diubah.'); TungguEnter;
end;

procedure HapusKendaraan;
var ID, I, J: Integer;
begin
  if not BolehKelolaMaster then begin Writeln('Hanya ADMIN yang boleh menghapus kendaraan.'); TungguEnter; Exit; end;
  BersihkanLayar; TampilkanJudul; Writeln('================ HAPUS KENDARAAN ==================');
  ID := InputInteger('ID Kendaraan: ', 1, 2147483647); I := CariKendaraan(ID);
  if I < 0 then begin Writeln('Kendaraan tidak ditemukan.'); TungguEnter; Exit; end;
  Writeln('Kendaraan: ', DaftarKendaraan[I].Merk, ' ', DaftarKendaraan[I].Model, ' / ', DaftarKendaraan[I].NomorPolisi);
  if AdaServiceUntukKendaraan(ID) then begin Writeln('Tidak dapat dihapus karena sudah memiliki riwayat service.'); TungguEnter; Exit; end;
  if Konfirmasi('Yakin hapus kendaraan? (Y/N): ') then begin
    DaftarKendaraan[I].Free;
    for J := I to JumlahKendaraan - 2 do DaftarKendaraan[J] := DaftarKendaraan[J + 1];
    Dec(JumlahKendaraan); SetLength(DaftarKendaraan, JumlahKendaraan); SimpanKendaraan; Writeln('Kendaraan berhasil dihapus.');
  end else Writeln('Penghapusan dibatalkan.');
  TungguEnter;
end;

procedure TambahPelanggan;
var ID: Integer; Nama, Alamat, Telepon: string;
begin
  if not BolehKelolaMaster then begin Writeln('Hanya ADMIN yang boleh menambah pelanggan.'); TungguEnter; Exit; end;
  BersihkanLayar; TampilkanJudul; Writeln('================ TAMBAH PELANGGAN =================');
  ID := IDPelangganBerikutnya; Nama := InputString('Nama    : '); Alamat := InputString('Alamat  : '); Telepon := InputString('Telepon : ');
  SetLength(DaftarPelanggan, JumlahPelanggan + 1); DaftarPelanggan[JumlahPelanggan] := TPelanggan.Create(ID, Nama, Alamat, Telepon); Inc(JumlahPelanggan); SimpanPelanggan;
  Writeln('Pelanggan berhasil ditambahkan dengan ID ', ID, '.'); TungguEnter;
end;

procedure TampilkanPelanggan;
var I: Integer;
begin
  BersihkanLayar; TampilkanJudul; Writeln('================ DAFTAR PELANGGAN =================');
  if JumlahPelanggan = 0 then begin Writeln('Belum ada pelanggan.'); TungguEnter; Exit; end;
  for I := 0 to JumlahPelanggan - 1 do begin
    Writeln('ID      : ', DaftarPelanggan[I].ID); Writeln('Nama    : ', DaftarPelanggan[I].Nama); Writeln('Alamat  : ', DaftarPelanggan[I].Alamat); Writeln('Telepon : ', DaftarPelanggan[I].Telepon); Writeln('------------------------------------------------------');
  end;
  TungguEnter;
end;

procedure CariPelangganNama;
var Kata: string; I: Integer; Ditemukan: Boolean;
begin
  BersihkanLayar; TampilkanJudul; Writeln('=============== CARI PELANGGAN ===================='); Kata := UpperCase(InputString('Nama yang dicari: ')); Ditemukan := False;
  for I := 0 to JumlahPelanggan - 1 do if Pos(Kata, UpperCase(DaftarPelanggan[I].Nama)) > 0 then begin
    Ditemukan := True; Writeln('ID: ', DaftarPelanggan[I].ID, ' | Nama: ', DaftarPelanggan[I].Nama, ' | Telepon: ', DaftarPelanggan[I].Telepon);
  end;
  if not Ditemukan then Writeln('Pelanggan tidak ditemukan.'); TungguEnter;
end;

procedure TambahKendaraan;
var ID, Tahun, JumlahPintu: Integer; Pilihan, Nomor, Merk, Model, JenisMotor: string;
begin
  if not BolehKelolaMaster then begin Writeln('Hanya ADMIN yang boleh menambah kendaraan.'); TungguEnter; Exit; end;
  BersihkanLayar; TampilkanJudul; Writeln('================ TAMBAH KENDARAAN =================');
  ID := IDKendaraanBerikutnya;
  repeat Write('1. Mobil  2. Motor : '); Readln(Pilihan); until (Pilihan = '1') or (Pilihan = '2');
  Nomor := InputString('Nomor Polisi: '); if CariNomorPolisi(Nomor) >= 0 then begin Writeln('Nomor polisi sudah digunakan.'); TungguEnter; Exit; end;
  Merk := InputString('Merk        : '); Model := InputString('Model       : '); Tahun := InputInteger('Tahun       : ', 1900, 2100);
  SetLength(DaftarKendaraan, JumlahKendaraan + 1);
  if Pilihan = '1' then begin JumlahPintu := InputInteger('Jumlah pintu: ', 2, 10); DaftarKendaraan[JumlahKendaraan] := TMobil.Create(ID, Nomor, Merk, Model, Tahun, JumlahPintu); end
  else begin JenisMotor := InputString('Jenis motor : '); DaftarKendaraan[JumlahKendaraan] := TMotor.Create(ID, Nomor, Merk, Model, Tahun, JenisMotor); end;
  Inc(JumlahKendaraan); SimpanKendaraan; Writeln('Kendaraan berhasil ditambahkan dengan ID ', ID, '.'); TungguEnter;
end;

procedure TampilkanKendaraan;
var I: Integer;
begin
  BersihkanLayar; TampilkanJudul; Writeln('================ DAFTAR KENDARAAN =================');
  if JumlahKendaraan = 0 then begin Writeln('Belum ada kendaraan.'); TungguEnter; Exit; end;
  for I := 0 to JumlahKendaraan - 1 do begin
    Writeln('ID           : ', DaftarKendaraan[I].ID); Writeln('Jenis        : ', DaftarKendaraan[I].Jenis); Writeln('Nomor Polisi : ', DaftarKendaraan[I].NomorPolisi); Writeln('Merk         : ', DaftarKendaraan[I].Merk); Writeln('Model        : ', DaftarKendaraan[I].Model); Writeln('Tahun        : ', DaftarKendaraan[I].Tahun); Writeln('Status       : ', DaftarKendaraan[I].Status); Writeln('Administrasi : ', FormatRupiah(DaftarKendaraan[I].BiayaAdministrasi));
    if DaftarKendaraan[I] is TMobil then Writeln('Jumlah Pintu : ', TMobil(DaftarKendaraan[I]).JumlahPintu) else if DaftarKendaraan[I] is TMotor then Writeln('Jenis Motor  : ', TMotor(DaftarKendaraan[I]).JenisMotor);
    Writeln('------------------------------------------------------');
  end;
  TungguEnter;
end;

procedure CariKendaraanNomor;
var Nomor: string; I: Integer;
begin
  BersihkanLayar; TampilkanJudul; Writeln('=============== CARI KENDARAAN ===================='); Nomor := InputString('Nomor Polisi: '); I := CariNomorPolisi(Nomor);
  if I < 0 then Writeln('Kendaraan tidak ditemukan.') else begin Writeln('ID           : ', DaftarKendaraan[I].ID); Writeln('Jenis        : ', DaftarKendaraan[I].Jenis); Writeln('Nomor Polisi : ', DaftarKendaraan[I].NomorPolisi); Writeln('Merk         : ', DaftarKendaraan[I].Merk); Writeln('Model        : ', DaftarKendaraan[I].Model); Writeln('Tahun        : ', DaftarKendaraan[I].Tahun); Writeln('Status       : ', DaftarKendaraan[I].Status); end;
  TungguEnter;
end;

procedure BuatService;
var IDBaru, IDPelanggan, IDKendaraan, IP, IK: Integer; NamaItem, Pilihan: string; HargaItem, TotalAkhir: Currency;
begin
  BersihkanLayar; TampilkanJudul; Writeln('================ BUAT SERVICE =====================');
  if (JumlahPelanggan = 0) or (JumlahKendaraan = 0) then begin Writeln('Pelanggan dan kendaraan harus tersedia.'); TungguEnter; Exit; end;
  IDPelanggan := InputInteger('ID Pelanggan: ', 1, 2147483647); IP := CariPelanggan(IDPelanggan); if IP < 0 then begin Writeln('Pelanggan tidak ditemukan.'); TungguEnter; Exit; end;
  IDKendaraan := InputInteger('ID Kendaraan: ', 1, 2147483647); IK := CariKendaraan(IDKendaraan); if IK < 0 then begin Writeln('Kendaraan tidak ditemukan.'); TungguEnter; Exit; end;
  if DaftarKendaraan[IK].Status <> 'TERSEDIA' then begin Writeln('Kendaraan tidak tersedia.'); TungguEnter; Exit; end;
  IDBaru := IDServiceBerikutnya; SetLength(DaftarService, JumlahService + 1); DaftarService[JumlahService] := TService.Create(IDBaru, IDPelanggan, IDKendaraan, InputString('Keluhan pelanggan: ')); Inc(JumlahService); DaftarKendaraan[IK].Status := 'SERVICE';
  repeat
    Writeln; Writeln('1. Tambah Item Service'); Writeln('2. Selesai Tambah Item'); Write('Pilihan: '); Readln(Pilihan);
    if Pilihan = '1' then begin NamaItem := InputString('Nama pekerjaan/sparepart: '); HargaItem := InputCurrency('Harga item: Rp ', 0); DaftarService[JumlahService - 1].TambahItem(NamaItem, HargaItem); Writeln('Item berhasil ditambahkan.') end
    else if Pilihan = '2' then Break else Writeln('Pilihan tidak tersedia.');
  until False;
  TotalAkhir := DaftarService[JumlahService - 1].TotalItem + DaftarKendaraan[IK].BiayaAdministrasi;
  Writeln('TOTAL: ', FormatRupiah(TotalAkhir));
  if Konfirmasi('Selesaikan service sekarang? (Y/N): ') then begin DaftarService[JumlahService - 1].Status := 'SELESAI'; DaftarKendaraan[IK].Status := 'TERSEDIA'; end else DaftarService[JumlahService - 1].Status := 'ANTRIAN';
  SimpanKendaraan; SimpanService; Writeln('Service tersimpan dengan status ', DaftarService[JumlahService - 1].Status, '.'); TungguEnter;
end;

procedure TampilkanService;
var I, J, IP, IK: Integer; TotalAkhir: Currency;
begin
  BersihkanLayar; TampilkanJudul; Writeln('================ DATA SERVICE =====================');
  if JumlahService = 0 then begin Writeln('Belum ada service.'); TungguEnter; Exit; end;
  for I := 0 to JumlahService - 1 do begin
    IP := CariPelanggan(DaftarService[I].IDPelanggan); IK := CariKendaraan(DaftarService[I].IDKendaraan);
    Writeln; Writeln('ID Service : ', DaftarService[I].ID); Writeln('Tanggal    : ', FormatDateTime('dd-mm-yyyy', DaftarService[I].Tanggal)); if IP >= 0 then Writeln('Pelanggan  : ', DaftarPelanggan[IP].Nama); if IK >= 0 then Writeln('Kendaraan  : ', DaftarKendaraan[IK].Merk, ' ', DaftarKendaraan[IK].Model); Writeln('Keluhan    : ', DaftarService[I].Keluhan); Writeln('Status     : ', DaftarService[I].Status); Writeln('ITEM SERVICE:');
    for J := 0 to DaftarService[I].JumlahItem - 1 do Writeln('  ', J + 1, '. ', DaftarService[I].ItemNama(J), ' - ', FormatRupiah(DaftarService[I].ItemHarga(J)));
    TotalAkhir := DaftarService[I].TotalItem; if IK >= 0 then TotalAkhir := TotalAkhir + DaftarKendaraan[IK].BiayaAdministrasi; Writeln('TOTAL      : ', FormatRupiah(TotalAkhir)); Writeln('------------------------------------------------------');
  end;
  TungguEnter;
end;

procedure SelesaikanService;
var ID, IService, IK: Integer;
begin
  BersihkanLayar; TampilkanJudul; Writeln('=============== SELESAIKAN SERVICE ================='); ID := InputInteger('ID Service: ', 1, 2147483647); IService := CariService(ID); if IService < 0 then begin Writeln('Service tidak ditemukan.'); TungguEnter; Exit; end; if DaftarService[IService].Status = 'SELESAI' then begin Writeln('Service sudah selesai.'); TungguEnter; Exit; end; IK := CariKendaraan(DaftarService[IService].IDKendaraan); DaftarService[IService].Status := 'SELESAI'; if IK >= 0 then DaftarKendaraan[IK].Status := 'TERSEDIA'; SimpanService; SimpanKendaraan; Writeln('Service berhasil diselesaikan.'); TungguEnter;
end;

procedure CetakNotaService;
var ID, I, IP, IK, J: Integer; F: TextFile; NamaFile: string; TotalAkhir: Currency;
begin
  BersihkanLayar; TampilkanJudul; Writeln('================ CETAK NOTA ======================='); ID := InputInteger('ID Service: ', 1, 2147483647); I := CariService(ID); if I < 0 then begin Writeln('Service tidak ditemukan.'); TungguEnter; Exit; end;
  IP := CariPelanggan(DaftarService[I].IDPelanggan); IK := CariKendaraan(DaftarService[I].IDKendaraan); NamaFile := 'nota_service_' + IntToStr(ID) + '.txt'; AssignFile(F, NamaFile); Rewrite(F);
  Writeln(F, '======================================================'); Writeln(F, '                  NOTA SERVICE BENGKEL'); Writeln(F, '======================================================'); Writeln(F, 'ID Service : ', ID); Writeln(F, 'Tanggal    : ', FormatDateTime('dd-mm-yyyy', DaftarService[I].Tanggal)); if IP >= 0 then Writeln(F, 'Pelanggan  : ', DaftarPelanggan[IP].Nama); if IK >= 0 then begin Writeln(F, 'Kendaraan  : ', DaftarKendaraan[IK].Merk, ' ', DaftarKendaraan[IK].Model); Writeln(F, 'No Polisi  : ', DaftarKendaraan[IK].NomorPolisi); end; Writeln(F, 'Keluhan    : ', DaftarService[I].Keluhan); Writeln(F, '------------------------------------------------------');
  TotalAkhir := DaftarService[I].TotalItem; for J := 0 to DaftarService[I].JumlahItem - 1 do Writeln(F, J + 1, '. ', DaftarService[I].ItemNama(J), ' : ', FormatRupiah(DaftarService[I].ItemHarga(J))); if IK >= 0 then begin Writeln(F, 'Administrasi : ', FormatRupiah(DaftarKendaraan[IK].BiayaAdministrasi)); TotalAkhir := TotalAkhir + DaftarKendaraan[IK].BiayaAdministrasi; end; Writeln(F, 'TOTAL       : ', FormatRupiah(TotalAkhir)); Writeln(F, 'Status      : ', DaftarService[I].Status); Writeln(F, '======================================================'); CloseFile(F);
  Writeln('Nota berhasil dibuat: ', NamaFile); TungguEnter;
end;

procedure RiwayatPelanggan;
var ID, I, IP, IK, J: Integer; Ada: Boolean; Total: Currency;
begin
  BersihkanLayar; TampilkanJudul; Writeln('=============== RIWAYAT PELANGGAN ================='); ID := InputInteger('ID Pelanggan: ', 1, 2147483647); IP := CariPelanggan(ID); if IP < 0 then begin Writeln('Pelanggan tidak ditemukan.'); TungguEnter; Exit; end; Ada := False; Total := 0;
  Writeln('Pelanggan: ', DaftarPelanggan[IP].Nama);
  for I := 0 to JumlahService - 1 do if DaftarService[I].IDPelanggan = ID then begin Ada := True; IK := CariKendaraan(DaftarService[I].IDKendaraan); Writeln; Writeln('Service #', DaftarService[I].ID, ' | ', FormatDateTime('dd-mm-yyyy', DaftarService[I].Tanggal), ' | ', DaftarService[I].Status); if IK >= 0 then Writeln('Kendaraan: ', DaftarKendaraan[IK].Merk, ' ', DaftarKendaraan[IK].Model); for J := 0 to DaftarService[I].JumlahItem - 1 do Writeln('  - ', DaftarService[I].ItemNama(J), ': ', FormatRupiah(DaftarService[I].ItemHarga(J))); if DaftarService[I].Status = 'SELESAI' then begin Total := Total + DaftarService[I].TotalItem; if IK >= 0 then Total := Total + DaftarKendaraan[IK].BiayaAdministrasi; end; end;
  if not Ada then Writeln('Belum ada riwayat service.'); Writeln; Writeln('Total transaksi selesai: ', FormatRupiah(Total)); TungguEnter;
end;

procedure UrutkanPelangganNama;
var I, J: Integer; Temp: TPelanggan;
begin
  for I := 0 to JumlahPelanggan - 2 do for J := I + 1 to JumlahPelanggan - 1 do if UpperCase(DaftarPelanggan[I].Nama) > UpperCase(DaftarPelanggan[J].Nama) then begin Temp := DaftarPelanggan[I]; DaftarPelanggan[I] := DaftarPelanggan[J]; DaftarPelanggan[J] := Temp; end;
  SimpanPelanggan;
end;

procedure UrutkanKendaraanNomor;
var I, J: Integer; Temp: TKendaraan;
begin
  for I := 0 to JumlahKendaraan - 2 do for J := I + 1 to JumlahKendaraan - 1 do if UpperCase(DaftarKendaraan[I].NomorPolisi) > UpperCase(DaftarKendaraan[J].NomorPolisi) then begin Temp := DaftarKendaraan[I]; DaftarKendaraan[I] := DaftarKendaraan[J]; DaftarKendaraan[J] := Temp; end;
  SimpanKendaraan;
end;

procedure UrutkanServiceTerbaru;
var I, J: Integer; Temp: TService;
begin
  for I := 0 to JumlahService - 2 do for J := I + 1 to JumlahService - 1 do if DaftarService[I].Tanggal < DaftarService[J].Tanggal then begin Temp := DaftarService[I]; DaftarService[I] := DaftarService[J]; DaftarService[J] := Temp; end;
  SimpanService;
end;

procedure MenuSorting;
var Pilihan: string;
begin
  BersihkanLayar; TampilkanJudul; Writeln('================ SORTING DATA ====================='); Writeln('1. Pelanggan berdasarkan nama'); Writeln('2. Kendaraan berdasarkan nomor polisi'); Writeln('3. Service terbaru'); Writeln('4. Kembali'); Write('Pilihan: '); Readln(Pilihan);
  case Pilihan of '1': UrutkanPelangganNama; '2': UrutkanKendaraanNomor; '3': UrutkanServiceTerbaru; '4': Exit; end;
  if Pilihan <> '4' then begin Writeln('Sorting berhasil.'); TungguEnter; end;
end;

procedure LaporanHarian;
var Teks: string; Tanggal: TDateTime; I, IK: Integer; Total: Currency; Jumlah: Integer;
begin
  BersihkanLayar; TampilkanJudul; Writeln('================ LAPORAN HARIAN ==================='); repeat Teks := InputString('Tanggal (dd-mm-yyyy): '); if not ParseTanggal(Teks, Tanggal) then Writeln('Format tanggal tidak valid.'); until ParseTanggal(Teks, Tanggal); Total := 0; Jumlah := 0;
  for I := 0 to JumlahService - 1 do if (DateOf(DaftarService[I].Tanggal) = DateOf(Tanggal)) and (DaftarService[I].Status = 'SELESAI') then begin Inc(Jumlah); Total := Total + DaftarService[I].TotalItem; IK := CariKendaraan(DaftarService[I].IDKendaraan); if IK >= 0 then Total := Total + DaftarKendaraan[IK].BiayaAdministrasi; end;
  Writeln('Tanggal            : ', FormatDateTime('dd-mm-yyyy', Tanggal)); Writeln('Service selesai    : ', Jumlah); Writeln('Pendapatan         : ', FormatRupiah(Total)); TungguEnter;
end;

procedure LaporanBulanan;
var Bulan, Tahun, I, IK, Jumlah: Integer; Total: Currency;
begin
  BersihkanLayar; TampilkanJudul; Writeln('================ LAPORAN BULANAN =================='); Bulan := InputInteger('Bulan (1-12): ', 1, 12); Tahun := InputInteger('Tahun: ', 1900, 2100); Total := 0; Jumlah := 0;
  for I := 0 to JumlahService - 1 do if (MonthOf(DaftarService[I].Tanggal) = Bulan) and (YearOf(DaftarService[I].Tanggal) = Tahun) and (DaftarService[I].Status = 'SELESAI') then begin Inc(Jumlah); Total := Total + DaftarService[I].TotalItem; IK := CariKendaraan(DaftarService[I].IDKendaraan); if IK >= 0 then Total := Total + DaftarKendaraan[IK].BiayaAdministrasi; end;
  Writeln('Periode            : ', Format('%.2d-%d', [Bulan, Tahun])); Writeln('Service selesai    : ', Jumlah); Writeln('Pendapatan         : ', FormatRupiah(Total)); TungguEnter;
end;

procedure Dashboard;
var I, Mobil, Motor, Tersedia, Aktif, Selesai, IK: Integer; Total, Administrasi: Currency;
begin
  Mobil := 0; Motor := 0; Tersedia := 0; Aktif := 0; Selesai := 0; Total := 0; Administrasi := 0;
  for I := 0 to JumlahKendaraan - 1 do begin if DaftarKendaraan[I] is TMobil then Inc(Mobil); if DaftarKendaraan[I] is TMotor then Inc(Motor); if DaftarKendaraan[I].Status = 'TERSEDIA' then Inc(Tersedia); if DaftarKendaraan[I].Status = 'SERVICE' then Inc(Aktif); end;
  for I := 0 to JumlahService - 1 do if DaftarService[I].Status = 'SELESAI' then begin Inc(Selesai); Total := Total + DaftarService[I].TotalItem; IK := CariKendaraan(DaftarService[I].IDKendaraan); if IK >= 0 then Administrasi := Administrasi + DaftarKendaraan[IK].BiayaAdministrasi; end;
  BersihkanLayar; TampilkanJudul; Writeln('==================== DASHBOARD ===================='); Writeln('Pelanggan            : ', JumlahPelanggan); Writeln('Kendaraan             : ', JumlahKendaraan); Writeln('Mobil                 : ', Mobil); Writeln('Motor                 : ', Motor); Writeln('Tersedia              : ', Tersedia); Writeln('Sedang service        : ', Aktif); Writeln('Total service         : ', JumlahService); Writeln('Service selesai       : ', Selesai); Writeln('Pendapatan pekerjaan  : ', FormatRupiah(Total)); Writeln('Administrasi          : ', FormatRupiah(Administrasi)); Writeln('TOTAL PENDAPATAN      : ', FormatRupiah(Total + Administrasi)); TungguEnter;
end;

procedure BackupMenu;
begin
  if not BolehKelolaMaster then begin Writeln('Hanya ADMIN yang boleh backup.'); TungguEnter; Exit; end;
  BersihkanLayar; TampilkanJudul; Writeln('================ BACKUP DATA ======================'); if BackupSemuaData then Writeln('Backup berhasil ke folder ', FOLDER_BACKUP, '.') else Writeln('Backup gagal.'); TungguEnter;
end;

procedure RestoreMenu;
begin
  if not BolehKelolaMaster then begin Writeln('Hanya ADMIN yang boleh restore.'); TungguEnter; Exit; end;
  BersihkanLayar; TampilkanJudul; Writeln('================ RESTORE DATA ====================='); Writeln('Restore akan mengganti data aktif dengan backup terakhir.'); if not Konfirmasi('Lanjutkan restore? (Y/N): ') then begin Writeln('Restore dibatalkan.'); TungguEnter; Exit; end;
  if RestoreSemuaData then begin ReloadSemuaData; Writeln('Restore berhasil dan data telah dimuat ulang.') end else Writeln('Backup lengkap tidak ditemukan.'); TungguEnter;
end;

procedure MenuPelanggan;
var Pilihan: string;
begin repeat BersihkanLayar; TampilkanJudul; Writeln('1. Tambah pelanggan'); Writeln('2. Lihat pelanggan'); Writeln('3. Edit pelanggan'); Writeln('4. Hapus pelanggan'); Writeln('5. Cari nama pelanggan'); Writeln('6. Riwayat service pelanggan'); Writeln('7. Kembali'); Write('Pilihan: '); Readln(Pilihan); case Pilihan of '1': TambahPelanggan; '2': TampilkanPelanggan; '3': EditPelanggan; '4': HapusPelanggan; '5': CariPelangganNama; '6': RiwayatPelanggan; '7': Exit; else Writeln('Pilihan tidak tersedia.'); TungguEnter; end; until False; end;

procedure MenuKendaraan;
var Pilihan: string;
begin repeat BersihkanLayar; TampilkanJudul; Writeln('1. Tambah kendaraan'); Writeln('2. Lihat kendaraan'); Writeln('3. Edit kendaraan'); Writeln('4. Hapus kendaraan'); Writeln('5. Cari nomor polisi'); Writeln('6. Kembali'); Write('Pilihan: '); Readln(Pilihan); case Pilihan of '1': TambahKendaraan; '2': TampilkanKendaraan; '3': EditKendaraan; '4': HapusKendaraan; '5': CariKendaraanNomor; '6': Exit; else Writeln('Pilihan tidak tersedia.'); TungguEnter; end; until False; end;

procedure MenuService;
var Pilihan: string;
begin repeat BersihkanLayar; TampilkanJudul; Writeln('1. Buat service baru'); Writeln('2. Lihat service + detail item'); Writeln('3. Selesaikan service'); Writeln('4. Cetak nota TXT'); Writeln('5. Kembali'); Write('Pilihan: '); Readln(Pilihan); case Pilihan of '1': BuatService; '2': TampilkanService; '3': SelesaikanService; '4': CetakNotaService; '5': Exit; else Writeln('Pilihan tidak tersedia.'); TungguEnter; end; until False; end;

procedure MenuLaporan;
var Pilihan: string;
begin repeat BersihkanLayar; TampilkanJudul; Writeln('1. Laporan harian'); Writeln('2. Laporan bulanan'); Writeln('3. Sorting data'); Writeln('4. Kembali'); Write('Pilihan: '); Readln(Pilihan); case Pilihan of '1': LaporanHarian; '2': LaporanBulanan; '3': MenuSorting; '4': Exit; else Writeln('Pilihan tidak tersedia.'); TungguEnter; end; until False; end;

function Login: Boolean;
var I: Integer; Username, Password: string;
begin
  Result := False;
  for I := 1 to MAX_LOGIN do begin
    BersihkanLayar; Writeln('=============================================================='); Writeln('                  LOGIN BENGKEL'); Writeln('=============================================================='); Writeln('Akun ADMIN   : admin / admin123'); Writeln('Akun PETUGAS : petugas / petugas123'); Writeln;
    Write('Username: '); Readln(Username); Write('Password: '); Readln(Password);
    if (Username = 'admin') and (Password = 'admin123') then begin RoleAktif := 'ADMIN'; Result := True; Exit; end;
    if (Username = 'petugas') and (Password = 'petugas123') then begin RoleAktif := 'PETUGAS'; Result := True; Exit; end;
    Writeln('Username atau password salah. Percobaan ', I, ' dari ', MAX_LOGIN, '.'); TungguEnter;
  end;
end;

procedure MenuUtama;
var Pilihan: string;
begin
  repeat
    BersihkanLayar; TampilkanJudul; Writeln('1. Dashboard'); Writeln('2. Data pelanggan'); Writeln('3. Data kendaraan'); Writeln('4. Service'); Writeln('5. Laporan & sorting'); if BolehKelolaMaster then begin Writeln('6. Backup data'); Writeln('7. Restore data'); Writeln('8. Keluar'); end else Writeln('6. Keluar'); Write('Pilihan: '); Readln(Pilihan);
    if BolehKelolaMaster then case Pilihan of '1': Dashboard; '2': MenuPelanggan; '3': MenuKendaraan; '4': MenuService; '5': MenuLaporan; '6': BackupMenu; '7': RestoreMenu; '8': Exit; else Writeln('Pilihan tidak tersedia.'); TungguEnter; end
    else case Pilihan of '1': Dashboard; '2': MenuPelanggan; '3': MenuKendaraan; '4': MenuService; '5': MenuLaporan; '6': Exit; else Writeln('Pilihan tidak tersedia.'); TungguEnter; end;
  until False;
end;

begin
  JumlahPelanggan := 0; JumlahKendaraan := 0; JumlahService := 0; RoleAktif := '';
  SetLength(DaftarPelanggan, 0); SetLength(DaftarKendaraan, 0); SetLength(DaftarService, 0);
  MuatPelanggan; MuatKendaraan; MuatService;
  if Login then begin MenuUtama; end else begin BersihkanLayar; Writeln('Terlalu banyak percobaan login. Program ditutup.'); end;
  HapusSemuaObject;
end.
