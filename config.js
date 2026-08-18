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
  SUPABASE_URL:      "https://fgxcawfztxoaayeowdbs.supabase.co",
  SUPABASE_ANON_KEY: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZneGNhd2Z6dHhvYWF5ZW93ZGJzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODY5OTg4MzYsImV4cCI6MjEwMjU3NDgzNn0.qfmoWRxU7gX4q56oh3keINKWO2BDF6jKB2yioB82SgY",

  // Nama syarikat yang dipaparkan
  SYARIKAT:  "FINE CABINETRY",
  SUFIKS:    ".CO",
  JABATAN:   "Carpentry Department"
};
