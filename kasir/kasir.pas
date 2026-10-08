program AplikasiKasir;

{$mode objfpc}{$H+}

uses
  SysUtils,
  CRT;

const
  MAX_BARANG = 100;
  NAMA_FILE = 'transaksi.txt';

type
  TBarang = record
    Nama: string;
    Harga: Currency;
    Jumlah: Integer;
    Subtotal: Currency;
  end;

var
  DaftarBarang: array[1..MAX_BARANG] of TBarang;
  JumlahBarang: Integer;
  TotalBelanja: Currency;
  UangBayar: Currency;
  Kembalian: Currency;


{ ========================================================= }
{                     FORMAT RUPIAH                         }
{ ========================================================= }

function Rupiah(Nilai: Currency): string;
begin
  Result := 'Rp ' + FormatFloat('#,##0', Nilai);
end;


{ ========================================================= }
{                     BERSIHKAN LAYAR                      }
{ ========================================================= }

procedure BersihkanLayar;
begin
  ClrScr;
end;


{ ========================================================= }
{                     TEKAN ENTER                          }
{ ========================================================= }

procedure TekanEnter;
begin
  Writeln;
  Write('Tekan ENTER untuk melanjutkan...');
  Readln;
end;


{ ========================================================= }
{                     JUDUL PROGRAM                        }
{ ========================================================= }

procedure TampilkanJudul;
begin
  Writeln('======================================================');
  Writeln('                  APLIKASI KASIR                     ');
  Writeln('======================================================');
end;


{ ========================================================= }
{                     HITUNG TOTAL                         }
{ ========================================================= }

procedure HitungTotal;
var
  I: Integer;
begin
  TotalBelanja := 0;

  for I := 1 to JumlahBarang do
  begin
    TotalBelanja :=
      TotalBelanja + DaftarBarang[I].Subtotal;
  end;
end;


{ ========================================================= }
{                     TAMBAH BARANG                         }
{ ========================================================= }

procedure TambahBarang;
var
  HargaInput: Currency;
  JumlahInput: Integer;
begin
  if JumlahBarang >= MAX_BARANG then
  begin
    Writeln;
    Writeln('Jumlah barang sudah mencapai batas maksimum.');
    TekanEnter;
    Exit;
  end;

  Inc(JumlahBarang);

  Writeln;
  Writeln('---------------- TAMBAH BARANG ----------------');

  Write('Nama barang : ');
  Readln(DaftarBarang[JumlahBarang].Nama);

  repeat
    Write('Harga       : Rp ');
    Readln(HargaInput);

    if HargaInput < 0 then
    begin
      Writeln('Harga tidak boleh negatif.');
    end;

  until HargaInput >= 0;

  repeat
    Write('Jumlah      : ');
    Readln(JumlahInput);

    if JumlahInput <= 0 then
    begin
      Writeln('Jumlah harus lebih dari 0.');
    end;

  until JumlahInput > 0;

  DaftarBarang[JumlahBarang].Harga := HargaInput;

  DaftarBarang[JumlahBarang].Jumlah := JumlahInput;

  DaftarBarang[JumlahBarang].Subtotal :=
    HargaInput * JumlahInput;

  TotalBelanja :=
    TotalBelanja +
    DaftarBarang[JumlahBarang].Subtotal;

  Writeln;
  Writeln('Barang berhasil ditambahkan.');

  Writeln(
    'Subtotal: ',
    Rupiah(DaftarBarang[JumlahBarang].Subtotal)
  );
end;


{ ========================================================= }
{                  TAMPILKAN DAFTAR BARANG                 }
{ ========================================================= }

procedure TampilkanDaftarBarang;
var
  I: Integer;
begin
  Writeln;
  Writeln('================ DAFTAR BARANG ================');

  if JumlahBarang = 0 then
  begin
    Writeln('Belum ada barang.');
    Exit;
  end;

  Writeln;
  Writeln(
    'No  ',
    'Nama Barang':20,
    'Harga':15,
    'Qty':8,
    'Subtotal':18
  );

  Writeln(
    '--------------------------------------------------------------'
  );

  for I := 1 to JumlahBarang do
  begin
    Writeln(
      I:2,
      '  ',
      DaftarBarang[I].Nama:20,
      Rupiah(DaftarBarang[I].Harga):15,
      DaftarBarang[I].Jumlah:8,
      Rupiah(DaftarBarang[I].Subtotal):18
    );
  end;

  Writeln(
    '--------------------------------------------------------------'
  );

  Writeln(
    'TOTAL: ',
    Rupiah(TotalBelanja)
  );
end;


{ ========================================================= }
{                    SIMPAN TRANSAKSI                       }
{ ========================================================= }

procedure SimpanTransaksi;
var
  FileTransaksi: TextFile;
  I: Integer;
begin
  Assign(
    FileTransaksi,
    NAMA_FILE
  );

  {$I-}
  Append(FileTransaksi);
  {$I+}

  if IOResult <> 0 then
  begin
    Rewrite(FileTransaksi);
  end;

  Writeln(
    FileTransaksi
  );

  Writeln(
    FileTransaksi,
    '======================================================'
  );

  Writeln(
    FileTransaksi,
    '                 TRANSAKSI KASIR'
  );

  Writeln(
    FileTransaksi,
    'Tanggal : ',
    FormatDateTime(
      'dd-mm-yyyy hh:nn:ss',
      Now
    )
  );

  Writeln(
    FileTransaksi,
    '======================================================'
  );

  for I := 1 to JumlahBarang do
  begin
    Writeln(
      FileTransaksi,
      I,
      '. ',
      DaftarBarang[I].Nama,
      ' | Harga: ',
      Rupiah(DaftarBarang[I].Harga),
      ' | Qty: ',
      DaftarBarang[I].Jumlah,
      ' | Subtotal: ',
      Rupiah(DaftarBarang[I].Subtotal)
    );
  end;

  Writeln(
    FileTransaksi,
    '------------------------------------------------------'
  );

  Writeln(
    FileTransaksi,
    'TOTAL     : ',
    Rupiah(TotalBelanja)
  );

  Writeln(
    FileTransaksi,
    'PEMBAYARAN: ',
    Rupiah(UangBayar)
  );

  Writeln(
    FileTransaksi,
    'KEMBALIAN : ',
    Rupiah(Kembalian)
  );

  Writeln(
    FileTransaksi,
    '======================================================'
  );

  Close(FileTransaksi);
end;


{ ========================================================= }
{                       CETAK STRUK                         }
{ ========================================================= }

procedure CetakStruk;
var
  I: Integer;
begin
  BersihkanLayar;

  TampilkanJudul;

  Writeln(
    'Tanggal : ',
    FormatDateTime(
      'dd-mm-yyyy hh:nn:ss',
      Now
    )
  );

  Writeln;

  Writeln(
    'No  ',
    'Barang':20,
    'Harga':15,
    'Qty':8,
    'Subtotal':18
  );

  Writeln(
    '--------------------------------------------------------------'
  );

  for I := 1 to JumlahBarang do
  begin
    Writeln(
      I:2,
      '  ',
      DaftarBarang[I].Nama:20,
      Rupiah(DaftarBarang[I].Harga):15,
      DaftarBarang[I].Jumlah:8,
      Rupiah(DaftarBarang[I].Subtotal):18
    );
  end;

  Writeln(
    '--------------------------------------------------------------'
  );

  Writeln(
    'TOTAL     : ',
    Rupiah(TotalBelanja)
  );

  Writeln(
    'BAYAR     : ',
    Rupiah(UangBayar)
  );

  Writeln(
    'KEMBALIAN : ',
    Rupiah(Kembalian)
  );

  Writeln(
    '=============================================================='
  );

  Writeln(
    '             TERIMA KASIH TELAH BERBELANJA'
  );

  Writeln(
    '=============================================================='
  );
end;


{ ========================================================= }
{                    PROSES PEMBAYARAN                     }
{ ========================================================= }

procedure ProsesPembayaran;
begin
  if JumlahBarang = 0 then
  begin
    Writeln;
    Writeln('Belum ada barang dalam transaksi.');

    TekanEnter;

    Exit;
  end;

  HitungTotal;

  BersihkanLayar;

  TampilkanJudul;

  TampilkanDaftarBarang;

  Writeln;

  Writeln(
    'Total yang harus dibayar: ',
    Rupiah(TotalBelanja)
  );

  repeat

    Write('Uang pembayaran        : Rp ');
    Readln(UangBayar);

    if UangBayar < TotalBelanja then
    begin
      Writeln;

      Writeln(
        'Uang pembayaran kurang.'
      );

      Writeln(
        'Masih kurang: ',
        Rupiah(
          TotalBelanja - UangBayar
        )
      );
    end;

  until UangBayar >= TotalBelanja;

  Kembalian :=
    UangBayar - TotalBelanja;

  Writeln;

  Writeln(
    'Pembayaran berhasil.'
  );

  Writeln(
    'Total     : ',
    Rupiah(TotalBelanja)
  );

  Writeln(
    'Bayar     : ',
    Rupiah(UangBayar)
  );

  Writeln(
    'Kembalian : ',
    Rupiah(Kembalian)
  );

  SimpanTransaksi;

  Writeln;

  Writeln(
    'Transaksi berhasil disimpan ke file: ',
    NAMA_FILE
  );

  Writeln;

  Write('Tampilkan struk? (Y/T): ');

  Readln;

  CetakStruk;

  TekanEnter;
end;


{ ========================================================= }
{                     TRANSAKSI BARU                        }
{ ========================================================= }

procedure TransaksiBaru;
var
  Pilihan: Char;
begin
  JumlahBarang := 0;

  TotalBelanja := 0;

  UangBayar := 0;

  Kembalian := 0;

  repeat

    BersihkanLayar;

    TampilkanJudul;

    Writeln;

    Writeln(
      '                 TRANSAKSI BARU'
    );

    Writeln;

    TampilkanDaftarBarang;

    Writeln;

    Writeln('1. Tambah Barang');

    Writeln('2. Selesaikan Transaksi');

    Writeln('3. Batalkan Transaksi');

    Writeln;

    Write('Pilihan: ');

    Readln(Pilihan);

    case Pilihan of

      '1':
        begin
          TambahBarang;

          TekanEnter;
        end;

      '2':
        begin

          if JumlahBarang = 0 then
          begin
            Writeln;

            Writeln(
              'Belum ada barang.'
            );

            TekanEnter;
          end
          else
          begin
            ProsesPembayaran;

            Exit;
          end;

        end;

      '3':
        begin

          Writeln;

          Writeln(
            'Transaksi dibatalkan.'
          );

          TekanEnter;

          Exit;
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

  until False;
end;


{ ========================================================= }
{                  LIHAT RIWAYAT TRANSAKSI                 }
{ ========================================================= }

procedure LihatRiwayat;
var
  FileTransaksi: TextFile;
  Baris: string;
begin
  BersihkanLayar;

  TampilkanJudul;

  Writeln;

  Writeln(
    '                 RIWAYAT TRANSAKSI'
  );

  Writeln;

  if not FileExists(NAMA_FILE) then
  begin
    Writeln(
      'Belum ada riwayat transaksi.'
    );

    TekanEnter;

    Exit;
  end;

  Assign(
    FileTransaksi,
    NAMA_FILE
  );

  Reset(FileTransaksi);

  while not EOF(FileTransaksi) do
  begin

    Readln(
      FileTransaksi,
      Baris
    );

    Writeln(Baris);

  end;

  Close(FileTransaksi);

  TekanEnter;
end;


{ ========================================================= }
{                       MENU UTAMA                          }
{ ========================================================= }

procedure MenuUtama;
var
  Pilihan: Char;
begin

  repeat

    BersihkanLayar;

    TampilkanJudul;

    Writeln;

    Writeln('1. Transaksi Baru');

    Writeln('2. Lihat Riwayat Transaksi');

    Writeln('3. Keluar');

    Writeln;

    Write('Pilihan: ');

    Readln(Pilihan);

    case Pilihan of

      '1':
        begin
          TransaksiBaru;
        end;

      '2':
        begin
          LihatRiwayat;
        end;

      '3':
        begin

          BersihkanLayar;

          Writeln(
            '======================================================'
          );

          Writeln(
            '       Terima kasih telah menggunakan aplikasi'
          );

          Writeln(
            '======================================================'
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

  until Pilihan = '3';

end;


{ ========================================================= }
{                     PROGRAM UTAMA                         }
{ ========================================================= }

begin

  JumlahBarang := 0;

  TotalBelanja := 0;

  UangBayar := 0;

  Kembalian := 0;

  MenuUtama;

end.