# CLAUDE.md — Konteks Projek

Fail ini untuk Claude Code. Baca dahulu sebelum ubah apa-apa.

---

## Apa ini

Sistem projek & pembayaran untuk **Fine Cabinetry.Co** (Carpentry Department, Malaysia).
Menggantikan fail Excel yang dikongsi antara top management.

**Stack:** satu fail HTML statik + Supabase (Postgres) + GitHub Pages + PWA.
Tiada build step. Tiada npm. Tiada framework. Vanilla JS sahaja.

**Bahasa antara muka: Bahasa Melayu.** Semua teks UI, nama pembolehubah dan
nama fungsi dalam BM (`projek`, `bayaran`, `muatData`, `jadualProjek`).
Kekalkan konvensyen ini.

---

## Susunan fail

```
index.html          ← SELURUH aplikasi (HTML + CSS + JS dalam satu fail)
config.js           ← kunci Supabase (pengguna isi sendiri; kosong = mod demo)
supabase.sql        ← skema DB, dijalankan sekali dalam Supabase SQL Editor
data.json           ← data sandaran untuk mod demo
manifest.json       ← PWA
sw.js               ← service worker (naikkan VERSI bila index.html berubah!)
supabase.min.js     ← @supabase/supabase-js v2 UMD (vendored, jangan edit)
xlsx.min.js         ← SheetJS 0.18.5 (vendored, jangan edit)
icon-*.png          ← ikon PWA
README.md           ← panduan pengguna (BM)
```

**Tiada CDN luar.** Semua pustaka dibundle supaya PWA berfungsi offline.

---

## Dua mod operasi

`index.html` menyemak `window.TETAPAN` dari `config.js`:

| Keadaan | Mod | Kelakuan |
|---|---|---|
| `SUPABASE_URL` + `SUPABASE_ANON_KEY` diisi | **Supabase** | Skrin log masuk, CRUD penuh, realtime, log aktiviti |
| Kedua-duanya kosong | **Demo** | Baca `data.json`, butang tambah/edit disembunyikan |

Pemeriksa: `ADA_SB`, `bolehTulis()`. Sentiasa kekalkan mod demo berfungsi —
ia digunakan untuk demo kepada management sebelum Supabase disiapkan.

---

## Model data

### `projek`
`id` (uuid) · `kod` (unik, cth `FC-01`) · `nama` · `klien` · `lokasi` · `telefon` ·
`inv` · `status` · `nilai` (numeric — nilai kontrak) · `mula` (date) · `nota` ·
`aliran` (jsonb) · `dicipta_oleh` · `diubah_oleh` · `created_at` · `updated_at`

### `bayaran`
`id` (uuid) · `projek_id` (FK cascade) · `kod` (FK ke `projek.kod`,
`on update cascade` + `on delete cascade`) · `jenis` · `amaun` · `tarikh` ·
`kaedah` · `ruj` · `status` (`Diterima` / `Menunggu`) · `dicipta_oleh`

**`kod` ialah rujukan sebenar.** `terima(kod)` memadan bayaran dengan projek
melalui medan teks ini, bukan `projek_id`. Sebab itu `kod` diikat sebagai FK dan
medan `mp-kod` dikunci (`readOnly`) semasa mengedit projek sedia ada — kalau kod
boleh berubah bebas, semua bayaran projek itu jadi yatim dan projek nampak macam
belum dibayar langsung.

### `log_aktiviti`
`id` · `pengguna` · `tindakan` · `butiran` · `created_at` — **insert & select sahaja**,
tiada update/delete (dikuatkuasakan oleh RLS).

### `aliran` (jsonb)
Peringkat kerja dari helaian Excel asal:
`deposit`, `lukisan`, `gambarSblm`, `pasang`, `baki`, `gambarSlps`, `maklumBalas`, `socmed`
— semua boolean. Dipapar sebagai carta "Aliran kerja projek" di Dashboard.

---

## Peraturan pengiraan (JANGAN ubah tanpa sebab kukuh)

```
diterima(kod)   = jumlah bayaran WHERE kod = ? AND status != 'Menunggu'
baki            = nilai − diterima
Total Payment   = Σ nilai (semua projek)
Total Received  = Σ diterima
Pending Payment = Total Payment − Total Received
Deposit Payment = Σ bayaran WHERE jenis ~ /deposit|pendahuluan|advance/i AND status != 'Menunggu'
```

Invarian: **Total Payment = Total Received + Pending Payment**.

### Kategori status — `jenisStatus(s)`
Padanan regex, terima BM **dan** Inggeris:

- `siap` ← `siap|selesai|complete|completed|ended|done|closed|delivered|handover`
- `jalan` ← `progres|progress|ongoing|running|berjalan|jalan|aktif|active|wip|dalam`
- `pending` ← selebihnya

Digunakan oleh kotak Dashboard (Ended / Running / Pending Project) **dan** logik arkib.

---

## Arkib

Projek dengan `jenisStatus(status) === "siap"` **dikecualikan** dari `jadualProjek()`
dan dipaparkan dalam `jadualArkib()` (tab "Projek Siap").
Sebab: senarai utama kekal pendek bila projek dah beratus.

Lencana sidebar: `bg-projek` = kiraan aktif, `bg-arkib` = kiraan siap.
Kotak Dashboard "Ended Project" melompat ke `pergi('arkib')`.

---

## Import Excel — `huraiFlow()`

Fail sebenar pelanggan: `PROJECT LISTING 2026 FCI.xls`, helaian `PROJECT FLOW 2026`.
**Format ini bukan satu-baris-satu-rekod.** Setiap projek memakan 2–3 baris:

```
Baris A: No | Nama Klien | Alamat | Tarikh Inv | Inv No | DONE… | Total Project(RM)
Baris B:    |            | Telefon|            | RM2,000| RM1,500 …amaun bertaburan…
Baris C:    |            |        |            |        | 10/08/26  ← tarikh bayaran
Baris D: (kosong, pemisah)
```

Peraturan penting:

1. **Lajur "Total Payment By Client(RM)" ialah rujukan muktamad** untuk jumlah diterima.
   Amaun individu dikutip dari baris butiran, kemudian **direkonsiliasi** dengan lajur ini.
2. Amaun **pendua** berlaku (nilai sama muncul dalam dua lajur). Dinyahduplikasi
   dengan membundarkan ke RM terdekat.
3. Tarikh dalam fail ialah **M/D/YY (locale US)**, bukan D/M/Y. Lihat `tkhFC()`.
4. Sel tarikh boleh berada dalam lajur wang — `wangFC()` menolak apa-apa yang
   sepadan corak tarikh.
5. **No. invois berulang** dalam fail pelanggan (`INV09004/2026` dipakai 2 kali).
   Sebab itu `kod` dijana `FC-01…FC-NN`, dan `inv` disimpan berasingan.

### Ujian regresi — WAJIB lulus

Terhadap fail sebenar pelanggan:

```
Jumlah nilai kontrak  = RM184,193.00
Jumlah diterima       = RM 83,861.00
Projek                = 10
Bayaran               = 16
```

Kedua-dua jumlah **padan tepat** dengan baris TOTAL dalam Excel pelanggan.
Kalau anda ubah `huraiFlow()`, `wangFC()` atau `tkhFC()`, sahkan semula angka ini.

`importSekarang()` ialah penghurai generik (padanan lajur) untuk fail lain —
`huraiFlow()` dicuba **dahulu**, generik jadi sandaran.

Bila bersambung ke Supabase, kedua-dua laluan import memanggil `keSupabase()`
yang buat `upsert` pada `kod` (ganti, bukan duplikasi).

---

## Reka bentuk

Jenama: **hitam & emas**, ikut kad nama pelanggan (bingkai emas, serif).

Warna ditakrif sebagai pembolehubah CSS pada `:root` (gelap, lalai) dan
`:root[data-t="light"]`. **Jangan tulis hex terus dalam CSS atau JS carta** —
gunakan `cv("--nama")` dalam JS SVG.

Warna carta disahkan terhadap semakan kontras/CVD:

- Gelap: `--brand: #b58c24` di atas permukaan `#141310`
- Cerah: `--brand: #9a7213` di atas `#ffffff`

Emas terang (`#d4a437`) hanya untuk **krom UI** (logo, butang, sempadan),
bukan untuk tanda carta — ia gagal jalur kecerahan mod gelap.

Carta ialah SVG buatan tangan (`cartaBar`, `cartaBaris`, `gauge`) —
satu siri, satu warna, corak *hatch* untuk "tiada data". Tiada pustaka carta.

---

## Perkara mudah tersalah

- **Naikkan `VERSI` dalam `sw.js`** setiap kali `index.html` diubah, jika tidak
  pengguna sedia ada terus dapat versi cache lama.
- Semua laluan **relatif** (`./sw.js`, `./manifest.json`) — GitHub Pages
  menghidangkan dari sub-laluan `/nama-repo/`.
- `sw.js` **mesti** langkau hos `*.supabase.co` (jangan cache panggilan API).
- `data.json` **dan `config.js`** guna *network-first*; aset lain *cache-first*.
  `config.js` mesti network-first kerana kunci Supabase diisi selepas deploy —
  kalau di-precache, pengguna sedia ada terperangkap dalam mod demo.
- Lencana status projek dapat **dua** kelas: `t-${jenisStatus(s)}` (umum) diikuti
  `t-${slug(s)}` (tepat). Yang umum menjamin status bebas seperti `Ongoing` atau
  `WIP` tetap berwarna; yang tepat diisytihar kemudian dalam CSS supaya ia menang
  bila padan (contoh `Tertunda` kekal merah). Status **bayaran** kekal `slug()`
  sahaja.
- Import (`keSupabase()`) memadam **semua** bayaran bagi kod yang terlibat sebelum
  memasukkan yang baharu — termasuk yang di-key-in manual. Kotak `confirm()` mesti
  menyebut bilangan rekod yang akan hilang.
- Sandaran offline hanya untuk permintaan `navigate` — jika tidak, permintaan
  skrip dapat HTML dan meletup dengan `SyntaxError: Unexpected token '<'`.
- RLS: hanya peranan `authenticated`. Kunci `anon` selamat dalam repo public.
  **Jangan sesekali** commit kunci `service_role`.
- Elakkan menambah kebergantungan npm — projek ini sengaja tiada build step.

---

## Keadaan semasa

Siap dan diuji:

- [x] Dashboard — 8 kotak (Total/Ended/Running/Pending Project · Total/Deposit/Pending/Received Payment), boleh klik
- [x] Carta — kutipan bulanan, tolok kemajuan, baki tertinggi, status, aliran kerja
- [x] Projek (aktif) · Projek Siap (arkib) · Pembayaran · Klien
- [x] CRUD penuh + pengesahan padam + cascade
- [x] Log aktiviti tak boleh dipadam
- [x] Realtime — semua klien segar semula bila data berubah
- [x] Import Excel (format pelanggan + generik) → Supabase
- [x] Eksport CSV (projek, arkib, klien)
- [x] PWA — boleh pasang, offline, pintasan
- [x] Tema gelap/cerah
- [x] Mod demo bila Supabase belum disambung

Belum dibuat / idea seterusnya:

- [ ] Peranan (staf vs management) — sekarang semua pengguna sah boleh edit
- [ ] Jana invois PDF
- [ ] Notifikasi WhatsApp bila deposit masuk
- [ ] Muat naik gambar sebelum/selepas (Supabase Storage)
- [ ] Laporan bulanan / eksport untuk cukai
- [ ] Ringkasan jualan bulanan (helaian Excel asal ada blok `SALES JANUARY =>` yang belum digunakan)

---

## Ujian

Tiada rangka kerja ujian. Pengesahan dibuat dengan Playwright secara ad-hoc.
Bila mengubah logik pengiraan atau import, sekurang-kurangnya sahkan:

1. Import fail pelanggan → jumlah masih RM184,193 / RM83,861
2. Tambah projek → kod auto bertambah, deposit awal terhasil sebagai rekod bayaran
3. Tukar status ke Siap → projek berpindah dari senarai utama ke arkib
4. Padam projek → bayaran berkaitan turut dipadam
5. Mod demo (config kosong) → tiada ralat konsol, butang tulis tersembunyi
