# Truth or Dare: Romantic Garden 🌸🎲

Sebuah permainan papan 3D interaktif Ular Tangga Romantis (Truth or Dare) yang dirancang khusus untuk pasangan dengan latar taman bunga pastel yang memikat (*Kawaii Romantic Garden*).

![Romantic Garden 3D](public/models/romantic-garden.glb)

---

## ✨ Fitur Utama

- **Papan 3D 100 Petak Lengkap**:
  - Simulasi ular dan tangga 3D dengan kurva organik dan animasi transisi mulus.
  - Petak spesial Truth (Hati) dan Dare (Permata) dengan koleksi tantangan romantis yang mendalam.
  - Petak 100 Mahkota Kejayaan dengan aturan lemparan dadu pas untuk menang.

- **5 Pilihan Bidak 3D Spesial (Sanrio Characters)**:
  - 🎀 **Kuromi** (`/models/kuromi.glb`)
  - 🌸 **My Melody** (`/models/my_melody.glb`)
  - 🍮 **Pompompurin** (`/models/pom.glb`)
  - 🐸 **Keroppi** (`/models/keroppi.glb`)
  - 🐾 **Pochacco** (`/models/pochacco.glb`)
  - Didukung rigging tulang (*SkinnedMesh*), bayangan dinamis, dan penapakan alas koin emas mawar.

- **Lingkungan 3D Romantic Garden**:
  - Pemandangan taman pastel dengan pepohonan fantasi, gapura pelangi, semak bunga mekar, dan boneka maskot.
  - Pencahayaan hangat dengan bayangan realistis (*Directional & Ambient Light*) serta kabut lembut.

- **Kawaii Music Player & Audio Romantis**:
  - Synth BGM ambient romantis berbasis Web Audio API (tanpa ketergantungan file eksternal).
  - Equalizer visual bar dengan animasi interaktif.
  - Sound Effects (SFX): Lemparan dadu, langkah melompat, kartu Truth, kartu Dare, kartu Kustom, desis ular, tangga emas, dan kemeriahan kemenangan (*Victory Fanfare*).
  - Pengaturan volume, tombol Mute/Unmute instan, dan export musik ke WAV.

- **Kartu Kustom untuk Pasangan**:
  - Buat dan simpan kartu pertanyaan Truth atau tantangan Dare pribadi langsung dari antarmuka permainan.
  - Tersedia filter kategori (Sweet, Playful, Deep, Spicy).

- **Dukungan Multi Pemain Lokal (2 - 4 Pemain)**:
  - Atur nama pemain dan pilih bidak favorit masing-masing di dialog Pengaturan Pemain.
  - Fitur Aksesibilitas: *Reduced Motion* untuk performa perangkat ringan dan fallback 2D otomatis jika WebGL tidak tersedia.

---

## 🛠️ Teknologi yang Digunakan

- **Framework**: [Next.js 14](https://nextjs.org/) (App Router, React 18, TypeScript)
- **3D Engine**: [Three.js](https://threejs.org/) & [@react-three/fiber](https://docs.pmnd.rs/react-three-fiber) / [@react-three/drei](https://github.com/pmndrs/drei)
- **State Management**: [Zustand 5](https://github.com/pmndrs/zustand)
- **Styling**: [Tailwind CSS](https://tailwindcss.com/)
- **Icons**: [Lucide React](https://lucide.dev/)
- **Testing**: [Vitest](https://vitest.dev/) (24 unit tests) & [Playwright](https://playwright.dev/) (E2E)

---

## 🚀 Menjalankan Secara Lokal

1. **Clone repositori**:
   ```bash
   git clone https://github.com/Fadhelnaufal/Truth-or-Dare-Romantic-Garden.git
   cd Truth-or-Dare-Romantic-Garden
   ```

2. **Instal dependensi**:
   ```bash
   npm install
   ```

3. **Jalankan server pengembangan**:
   ```bash
   npm run dev
   ```
   Buka browser di `http://localhost:3000`.

4. **Menjalankan pengujian**:
   ```bash
   npm test        # Menjalankan 24 unit test vitest
   npm run typecheck # Validasi tipe TypeScript
   npm run lint    # ESLint check
   ```

---

## 📜 Lisensi & Atribusi

- Model 3D lingkungan dan karakter bersumber dari aset CC yang dioptimalkan untuk performa web 3D.
- Dibuat untuk menghadirkan momen bermain bersama pasangan yang menyenangkan dan bermakna.
