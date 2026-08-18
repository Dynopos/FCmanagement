-- =====================================================================
--  FINE CABINETRY.CO — Skema Database Supabase
--  Cara guna: buka Supabase → SQL Editor → New query → tampal SEMUA ini
--             → tekan RUN. Selamat dijalankan berulang kali.
-- =====================================================================

-- ---------- 1. JADUAL PROJEK ----------
create table if not exists public.projek (
  id          uuid primary key default gen_random_uuid(),
  kod         text not null unique,
  nama        text not null,
  klien       text,
  lokasi      text,
  telefon     text,
  inv         text,
  status      text not null default 'Baru',
  nilai       numeric(12,2) not null default 0,
  mula        date,
  nota        text,
  aliran      jsonb not null default '{}'::jsonb,
  dicipta_oleh text,
  diubah_oleh  text,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

-- ---------- 2. JADUAL BAYARAN ----------
create table if not exists public.bayaran (
  id          uuid primary key default gen_random_uuid(),
  projek_id   uuid references public.projek(id) on delete cascade,
  kod         text not null,
  jenis       text not null default 'Deposit',
  amaun       numeric(12,2) not null default 0,
  tarikh      date,
  kaedah      text,
  ruj         text,
  status      text not null default 'Diterima',
  dicipta_oleh text,
  created_at  timestamptz not null default now()
);

-- ---------- 3. LOG AKTIVITI ----------
create table if not exists public.log_aktiviti (
  id         bigserial primary key,
  pengguna   text,
  tindakan   text,
  butiran    text,
  created_at timestamptz not null default now()
);

-- ---------- 4. INDEKS ----------
create index if not exists idx_bayaran_kod    on public.bayaran(kod);
create index if not exists idx_bayaran_projek on public.bayaran(projek_id);
create index if not exists idx_projek_status  on public.projek(status);
create index if not exists idx_log_masa       on public.log_aktiviti(created_at desc);

-- ---------- 5. AUTO updated_at ----------
create or replace function public.sentuh_updated_at()
returns trigger language plpgsql as $$
begin new.updated_at = now(); return new; end $$;

drop trigger if exists trg_projek_updated on public.projek;
create trigger trg_projek_updated before update on public.projek
  for each row execute function public.sentuh_updated_at();

-- ---------- 6. KEAMANAN (RLS) ----------
-- Sesiapa yang BERJAYA LOG MASUK boleh baca & tulis.
-- Orang luar tanpa akaun tak boleh sentuh apa-apa.
alter table public.projek       enable row level security;
alter table public.bayaran      enable row level security;
alter table public.log_aktiviti enable row level security;

drop policy if exists "pengguna sah - projek"  on public.projek;
create policy "pengguna sah - projek"  on public.projek
  for all to authenticated using (true) with check (true);

drop policy if exists "pengguna sah - bayaran" on public.bayaran;
create policy "pengguna sah - bayaran" on public.bayaran
  for all to authenticated using (true) with check (true);

-- Log: semua boleh baca & tambah, TIADA sesiapa boleh padam atau ubah.
drop policy if exists "log - baca"    on public.log_aktiviti;
create policy "log - baca"    on public.log_aktiviti
  for select to authenticated using (true);

drop policy if exists "log - tambah"  on public.log_aktiviti;
create policy "log - tambah"  on public.log_aktiviti
  for insert to authenticated with check (true);

-- ---------- 7. REALTIME (semua nampak perubahan serta-merta) ----------
do $$ begin
  alter publication supabase_realtime add table public.projek;
exception when duplicate_object then null; end $$;
do $$ begin
  alter publication supabase_realtime add table public.bayaran;
exception when duplicate_object then null; end $$;

-- =====================================================================
--  SELESAI.
--
--  LANGKAH SETERUSNYA — cipta akaun untuk pasukan anda:
--  Authentication → Users → "Add user" → "Create new user"
--  Isi emel + kata laluan, TANDA "Auto Confirm User".
--  Ulang untuk setiap staf & top management.
--
--  PENTING: Authentication → Providers → Email →
--           MATIKAN "Enable sign ups"
--           supaya orang luar tak boleh daftar sendiri.
-- =====================================================================
