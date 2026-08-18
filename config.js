/* =====================================================================
   FINE CABINETRY.CO — Tetapan sambungan Supabase
   ---------------------------------------------------------------------
   Isi DUA nilai di bawah, kemudian simpan & commit ke GitHub.

   Cara dapat nilai ni:
     Supabase  →  Project Settings  →  API
       · "Project URL"          →  salin ke SUPABASE_URL
       · "anon" "public" key    →  salin ke SUPABASE_ANON_KEY

   Selamat ke letak kunci ni dalam repo public?
     YA. Kunci "anon" memang direka untuk didedahkan dalam browser.
     Ia tak beri akses apa-apa tanpa log masuk, kerana RLS (Row Level
     Security) dalam supabase.sql hanya benarkan pengguna yang sah.
     JANGAN sesekali letak kunci "service_role" di sini.

   Biarkan kosong ("") kalau nak guna MOD DEMO (baca data.json sahaja).
   ===================================================================== */

window.TETAPAN = {
  SUPABASE_URL:      "",
  SUPABASE_ANON_KEY: "",

  // Nama syarikat yang dipaparkan
  SYARIKAT:  "FINE CABINETRY",
  SUFIKS:    ".CO",
  JABATAN:   "Carpentry Department"
};
