# Fine Cabinetry.Co — Sistem Projek & Pembayaran

Dashboard hitam & emas untuk top management — semua projek, deposit dan baki dikira automatik.
Tiada server, tiada database. Hos percuma di **GitHub Pages**.

## Fail dalam repo ni

| Fail | Fungsi |
|---|---|
| `index.html` | Seluruh sistem — dashboard, jadual, borang, import Excel |
| `config.js` | **Isi kunci Supabase anda di sini** |
| `supabase.sql` | Skema database — jalankan sekali dalam Supabase SQL Editor |
| `data.json` | Data contoh untuk mod demo (sebelum Supabase disambung) |
| `manifest.json` | Tetapan PWA — nama app, ikon, warna |
| `sw.js` | Service worker — buat sistem boleh guna offline |
| `supabase.min.js`, `xlsx.min.js` | Pustaka (dibundle, tiada CDN luar) |
| `icon-*.png`, `apple-touch-icon.png` | Ikon app |
| `README.md` | Fail ini |

Upload **semua** fail ni ke root repo (bukan dalam folder).

---

## Setup pertama kali (sekali sahaja, ~5 minit)

1. Log masuk GitHub → **New repository**
   - Nama: `sistem-projek`
   - Pilih **Public** (Pages percuma untuk repo public)
   - Tekan **Create repository**

2. Tekan **uploading an existing file** → seret masuk `index.html`, `data.json`, `README.md` → **Commit changes**

3. Pergi ke tab **Settings** → menu kiri **Pages**
   - *Source*: `Deploy from a branch`
   - *Branch*: `main` , folder `/ (root)` → **Save**

4. Tunggu 1–2 minit. Link anda:
   ```
   https://NAMA-GITHUB-ANDA.github.io/sistem-projek/
   ```
   Hantar link ni kepada semua top management. Buka pada telefon pun boleh.

---

## Kemas kini data (setiap kali ada rekod baharu)

1. Buka link sistem → tab **Import Excel**
2. Muat naik fail Excel terkini → semak pratonton → **Import**
3. Tekan **⬇ Muat turun data.json**
4. Di GitHub: buka `data.json` → ikon **pensel (Edit)** → padam semua isi → tampal isi fail baharu → **Commit changes**
5. Siap. Semua orang nampak nombor baharu selepas refresh.

> Tip: langkah 3–4 boleh diganti dengan drag-and-drop `data.json` ke halaman repo GitHub (ia akan tanya nak commit).

---

## Lajur Excel yang dikenali

Sistem padan lajur secara automatik (tak kisah huruf besar/kecil, boleh sebahagian):

| Medan | Nama lajur yang dikenali |
|---|---|
| Kod projek | `Kod`, `Code`, `No`, `Bil`, `ID` |
| Nama projek | `Projek`, `Project`, `Nama`, `Kerja`, `Tajuk` |
| Klien | `Klien`, `Client`, `Pelanggan`, `Customer`, `Syarikat` |
| PIC | `PIC`, `Pegawai`, `In Charge`, `Owner` |
| Status | `Status`, `Keadaan`, `Peringkat` |
| Nilai kontrak | `Nilai`, `Kontrak`, `Harga`, `Jumlah`, `Sebut Harga`, `Amount` |
| Deposit | `Deposit`, `Pendahuluan`, `Advance`, `Bayaran Pertama` |
| Bayaran lain | `Bayaran`, `Diterima`, `Dibayar`, `Paid`, `Kutipan` |
| Tarikh | `Tarikh`, `Date`, `Mula` |

Baris pertama helaian mesti tajuk lajur. Kalau fail ada banyak helaian, sistem akan tanya pilih yang mana.

---

## 8 kotak utama di Dashboard

**Baris PROJEK**

| Kotak | Maksud |
|---|---|
| **Total Project** | Semua projek dalam sistem |
| **Ended Project** | Status Siap / Completed / Selesai / Done |
| **Running Project** | Status Dalam Progres / Ongoing / Running / Aktif |
| **Pending Project** | Baru, Tertunda, atau status lain yang belum bermula |

**Baris PEMBAYARAN**

| Kotak | Maksud |
|---|---|
| **Total Payment** | Nilai penuh semua kontrak — jumlah sepatutnya dikutip |
| **Deposit Payment** | Jumlah semua deposit / pendahuluan yang sudah diterima |
| **Pending Payment** | Belum masuk = Total Payment − Total Received |
| **Total Received Payment** | Semua duit yang sudah masuk (deposit + progres + baki) |

Semak mudah: **Total Payment = Total Received + Pending Payment**.

Setiap kotak boleh **diklik** — terus melompat ke senarai yang berkaitan.

Status bertulis Bahasa Melayu atau Inggeris kedua-duanya dikenali
(`Siap`/`Completed`, `Dalam Progres`/`Ongoing`, dan sebagainya).

## Lain-lain yang dikira automatik

- Baki belum dikutip setiap projek = nilai kontrak − diterima
- % kutipan setiap projek, setiap klien, setiap PIC
- Kutipan mengikut bulan
- Amaun menunggu pengesahan (status `Menunggu` tidak dikira sebagai diterima)

## Tema

Lalai **gelap (hitam & emas)** mengikut identiti jenama. Tekan ikon bulan di
bahagian atas kanan untuk tukar ke tema cerah.

---


---

## Sambung ke Supabase (staf key-in terus)

Selepas langkah ni, staf key-in dalam sistem dan **semua orang nampak dalam beberapa saat**.
Tiada lagi upload Excel, tiada lagi commit `data.json`. Percuma.

### 1. Cipta projek Supabase (~3 minit)

1. Daftar percuma di **supabase.com** → **New project**
2. Beri nama (cth. `fine-cabinetry`), pilih region **Southeast Asia (Singapore)**
3. Simpan kata laluan database yang dijana — anda mungkin perlukannya nanti

### 2. Bina jadual (~1 minit)

1. Menu kiri → **SQL Editor** → **New query**
2. Buka fail `supabase.sql`, salin **semua** isinya, tampal
3. Tekan **Run**. Patut keluar "Success".

### 3. Sambung sistem (~2 minit)

1. **Project Settings → API**
2. Salin **Project URL** dan kunci **anon public**
3. Buka `config.js`, tampal ke dalam:

   ```js
   SUPABASE_URL:      "https://xxxxx.supabase.co",
   SUPABASE_ANON_KEY: "eyJhbGciOi...",
   ```

4. Commit `config.js` ke GitHub. Siap.

> **Kunci `anon` selamat didedahkan dalam repo public.** Ia direka untuk browser dan
> tak beri akses apa-apa tanpa log masuk, kerana RLS dalam `supabase.sql` hanya
> benarkan pengguna yang sah. **Jangan sesekali** letak kunci `service_role` di sini.

### 4. Cipta akaun staf (~1 minit setiap orang)

1. **Authentication → Users → Add user → Create new user**
2. Isi e-mel + kata laluan, **tanda "Auto Confirm User"**
3. Hantar e-mel & kata laluan kepada staf

**Wajib:** **Authentication → Providers → Email** → matikan **Enable sign ups**,
supaya orang luar tak boleh daftar sendiri.

### 5. Masukkan data sedia ada

Buka sistem → log masuk → **Import Excel** → muat naik fail anda → **Import**.
Data terus masuk database. Buat sekali sahaja.

---

## Cara guna harian

**Staf:**

- **+ Projek** — tambah projek baharu (kod dijana automatik)
- **+ Rekod Bayaran** — atau tekan ikon **+** pada baris projek
- Ikon **pensel** pada mana-mana baris untuk kemas kini
- Tanda kotak **aliran kerja** bila setiap peringkat siap

**Top management:** buka link, semua nombor dah dikira.

Setiap perubahan direkod dalam **Log Aktiviti** — siapa, bila, apa. Log tak boleh dipadam.

---

## Projek siap tak berselerak

Projek berstatus **Siap** keluar automatik dari senarai utama dan masuk tab
**Projek Siap**. Senarai utama kekal pendek walaupun dah ratusan projek.

Dashboard tetap kira semua — tekan kotak **Ended Project** untuk terus ke arkib.

---

## Import Excel — masih ada, sebagai pilihan

Import kekal berguna untuk:

- Masukkan data lama (sekali sahaja, masa setup)
- Masukkan banyak projek serentak
- Pulihkan data dari backup

Sistem kenal **format PROJECT FLOW Fine Cabinetry anda** secara automatik —
termasuk baris butiran di bawah setiap projek yang mengandungi telefon dan amaun.
Jumlah dibandingkan dengan baris TOTAL dalam fail anda.

Kod projek yang sudah wujud akan **digantikan**, bukan diduplikasi.

---

## PWA — pasang sebagai app di telefon

GitHub Pages sesuai untuk PWA kerana ia disajikan melalui HTTPS.

**Android / Chrome / Edge:** butang **⤓ Pasang App** muncul sendiri di bar atas.
**iPhone / iPad:** Safari → ikon Kongsi ⬆️ → **Add to Home Screen**.
**Desktop:** ikon pasang di hujung bar alamat.

Selepas dipasang: ikon FC emas di skrin utama, buka tanpa bar browser,
dan boleh baca data terakhir walaupun tiada internet.

> **Ingat:** setiap kali `index.html` diubah, naikkan `VERSI` dalam `sw.js`
> (`fc-v7` → `fc-v8`) supaya semua orang dapat versi baharu.

---

## Mod demo

Kalau `config.js` masih kosong, sistem jalan dalam **mod demo** — baca `data.json`
sahaja, butang tambah/edit disembunyikan. Berguna untuk tunjuk pada management
sebelum Supabase disiapkan.

---

## Backup

**Terbitkan → Simpan salinan (data.json)** memuat turun keseluruhan data.
Supabase juga buat backup automatik harian pada plan percuma.
