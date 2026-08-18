# Pembetulan selepas semakan kod — 18 Ogos 2026

Semakan oleh Claude Code, disahkan dan dibaiki. `sw.js` VERSI kini `fc-v11`.

> Lihat **Susulan** di bawah — dua item dalam jadual ini tidak lulus pengesahan
> browser dan telah dibetulkan kemudian, dan satu regresi ditemui.

| # | Isu | Status | Tindakan |
|---|---|---|---|
| a | `bayaran.kod` tak terikat pada `projek.kod` — edit kod = bayaran jadi yatim | ✅ Dibaiki | Tukar kod kini mencetuskan pengesahan + cascade `update bayaran set kod` melalui `projek_id`. Gagal cascade = amaran jelas, bukan senyap. |
| b | Import padam semua bayaran tanpa amaran & tanpa semak ralat | ✅ Dibaiki | Amaran kini nyatakan **bilangan sebenar** bayaran yang akan dipadam, dan berapa daripadanya **dimasukkan manual oleh staf**. Tambah butang **"Hanya projek baharu"** yang langsung tak sentuh rekod sedia ada. Setiap langkah semak ralat dan berhenti dengan mesej pemulihan. |
| c | Log aktiviti boleh dipalsukan dari konsol browser | ✅ Dibaiki | `log_aktiviti.pengguna` kini `default auth.email()` dan polisi RLS `with check (pengguna = auth.email())`. Klien tak lagi hantar medan itu. **Perlu jalankan semula `supabase.sql`.** |
| d | Lencana "Dalam Progres" tiada warna (`slug()` → `t-dalamprogres`, CSS ada `.t-progres`) | ✅ Dibaiki | Semua varian BM/Inggeris ditambah pada pemilih CSS. Disahkan: kini `rgb(224,180,92)`. |
| e | `esc()` tak escape petik tunggal — butang edit pecah pada kod seperti `FC-1'` | ✅ Dibaiki | `'` → `&#39;` ditambah. |
| f | Carian atas tak jumpa projek arkib + merampas navigasi setiap ketukan | ✅ Dibaiki | `cariGlobal()` mencari merentas aktif **dan** arkib, melompat ke tab yang ada padanan, dan papar "Tiada padanan" bila kosong. |
| g | `config.js` di-cache *cache-first* — setup Supabase takkan berkesan untuk pengguna PWA sedia ada | ✅ Dibaiki | `config.js` kini *network-first*, sama seperti `data.json`. **Ini yang paling kritikal** — tanpa pembetulan ni, langkah setup dalam README memang takkan menjadi. |
| h | Tarikh M/D/YY boleh jadi tarikh masa depan (RM3,000 FC-05 tersalah ke Oktober) | ⚠️ Diberi amaran | Pratonton import kini menandakan setiap tarikh selepas hari ini dan terangkan sebabnya. Tidak diteka automatik — hanya anda tahu tarikh sebenar. **Semak FC-05 selepas import.** |
| i | Klik "Deposit Payment" beri senarai tak sepadan dengan angkanya | ✅ Dibaiki | Penapis kini tetapkan status `Diterima`, sama seperti kiraan kotak. |
| j | `simpanProjek()` menimpa medan `klien` dengan `nama` | ✅ Dibaiki | Borang ada medan Klien berasingan; kosong = ikut nama. |
| k | `terima()` O(projek² × bayaran) — akan tersekat bila projek beratus | ✅ Dibaiki | `Map` kod→jumlah dibina sekali setiap `render()`. |
| — | Mesej ralat `muatData()` sentiasa salahkan `supabase.sql` | ✅ Dibaiki | Kini bezakan sesi tamat, internet putus, jadual tiada, dan masalah RLS. |
| — | `jadualBayaran()` susun `String(null)` → `"null"` | ✅ Dibaiki | Guna `(b.tarikh \|\| "")`. |
| — | `aktif` tak digunakan; parameter `sel` dalam `hov()` tak digunakan | ✅ Dibersihkan | |

## Belum dibuat (sengaja)

**Peranan staf vs management.** Anda pilih "staf tambah & edit bebas", jadi RLS
sekarang benarkan semua pengguna sah. Kalau nak ketatkan, itu kerja seterusnya —
mesti dikuatkuasakan melalui RLS, bukan sekadar sembunyi butang.

## Ujian regresi — semua lulus

```
Import fail sebenar   → 10 projek · 16 bayaran · RM184,193.00 · RM83,861.00  ✓
Tambah projek         → kod auto FC-11, deposit awal jadi rekod bayaran      ✓
Rekod bayaran         → jumlah projek jadi penuh                             ✓
Tukar status ke Siap  → berpindah ke arkib, lencana sidebar 7 / 4            ✓
Padam projek          → 1 bayaran berkaitan turut dipadam                    ✓
Mod demo              → butang tulis tersembunyi, tiada ralat konsol         ✓
Lencana Dalam Progres → rgb(224,180,92) ✓ (sebelum ni tiada warna)
Cari projek arkib     → melompat ke tab arkib, jumpa                         ✓
```

---

## Susulan — pengesahan browser

Setiap tuntutan di atas diuji dengan Playwright terhadap fail sebenar. Kebanyakannya
lulus. Tiga perkara tidak.

### e — escape petik tunggal TIDAK menjadi

`esc()` menukar `'` kepada `&#39;`, tetapi nilai itu diletakkan dalam rentetan JS
di dalam atribut HTML. Parser HTML menyahkod entiti **sebelum** JS diparse, jadi
`&#39;` kembali menjadi `'` dan tetap menamatkan rentetan.

```
kod FC-04'X  →  onclick="bukaProjek('FC-04'X')"
                PAGEERROR: missing ) after argument list — butang edit mati
```

Dibaiki dengan `escJS()`: escape backslash dan petik pada peringkat JS dahulu,
barulah `esc()` untuk konteks HTML. Kini menghasilkan `bukaProjek('FC-04\'X')`
dan nilai pulang tepat sebagai `FC-04'X`.

### d — senarai slug tidak meliputi semua status

Senarai `.t-*` dalam CSS ialah senarai putih. `Aktif`, `WIP` dan `Active` —
kesemuanya dikenali `jenisStatus()` sebagai berjalan — masih keluar tanpa warna.
Ditambah kelas kategori `k-siap` / `k-jalan` / `k-pending` dari `jenisStatus()`,
diisytihar **sebelum** `.t-*` supaya padanan tepat kekal menang dan `Tertunda`
kekal merah.

### REGRESI — import Excel generik mati

`baca()` memanggil `pilihSheet(0)` sebagai sandaran apabila `huraiFlow()` tak
mengenali fail, tetapi `pilihSheet()` dan `importSekarang()` **hilang** semasa
pusingan a–k. Pemanggil kekal, fungsinya tiada.

Kesan: format PROJECT FLOW Fine Cabinetry masih berfungsi, tetapi **mana-mana
Excel lain** mati dengan `pilihSheet is not defined` dan pengguna nampak skrin
kosong tanpa sebarang mesej. Isu ini terlindung sebelum ini kerana `xlsx.min.js`
belum ada dalam repo — laluan itu tak pernah sampai.

Kedua-dua fungsi dipulihkan dari baseline. Disahkan hujung-ke-hujung dengan fail
`.xlsx` sebenar: 2 projek RM80,000 → RM45,000 diterima, RM35,000 baki,
1 aktif / 1 arkib, tiada ralat konsol.

### a — lapisan kedua ditambah semula

Cascade JS dikekalkan. Constraint FK `bayaran.kod → projek.kod`
(`on update/delete cascade`) ditambah dalam `supabase.sql` bahagian **6c**,
selepas pembaikan data 6b. Ia **tidak memadam apa-apa** — kalau masih ada
bayaran tanpa projek sepadan, constraint dilangkau dan skrip memberitahu.

### Ujian regresi selepas semua di atas

```
Mod demo            → RM184,193.00 · RM83,861.00 · RM100,332.00 · 7/3/16   ✓
Import generik      → RM80,000.00 = RM45,000.00 + RM35,000.00              ✓
Lencana status      → Dalam Progres/WIP/Aktif/Active amber, Tertunda merah ✓
Kod dengan petik    → butang edit buka, nilai pulang tepat                 ✓
Pustaka             → SheetJS 0.18.5, supabase-js dimuat                   ✓
Ralat konsol        → tiada                                                ✓
```
