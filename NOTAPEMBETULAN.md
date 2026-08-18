# Pembetulan selepas semakan kod — 18 Ogos 2026

Semakan oleh Claude Code, disahkan dan dibaiki. `sw.js` VERSI dinaikkan ke `fc-v9`.

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
