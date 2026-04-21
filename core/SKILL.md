---
name: qwen-unleashed-expert
description: Expert in Qwen Unleashed AI application - the high-performance Quad-Brain AI interface powered by Qwen models via dialagram.me API.
---

# Qwen Unleashed - Technical Documentation

## Overview
**Qwen Unleashed** is a high-performance AI chat interface featuring a Quad-Brain architecture. It leverages multiple Qwen models through the dialagram.me API to provide superior AI responses through collaborative synthesis.

## Architecture

### Brain Configuration (Quad-Brain)
| Role | Model | Purpose |
|------|-------|---------|
| **Primary (Coding)** | `qwen-3.6-plus` | High-precision software engineering, complex code generation |
| **Speed** | `qwen-3.5-plus` | Rapid development and iteration, fast responses |
| **General** | `qwen-3.6-plus-thinking` | Extended reasoning for complex analysis |
| **Complementary** | `qwen-3.5-plus-thinking` | Edge case detection, thorough critique |

### Technology Stack
- **Framework**: Electron.js (v41.2.0)
- **UI**: Vanilla JS + CSS with glassmorphism design
- **API**: dialagram.me router (`https://www.dialagram.me/router/v1`)
- **Persistence**: Local JSON files (`projects.json`, `chats.json`)
- **Platform**: macOS (Intel x64 optimized)

## File Structure
```
~/claude-local-ui/
├── main.js              # Electron main process, API handlers
├── preload.js           # Secure IPC bridge
├── renderer.js          # UI logic, chat engine
├── public/
│   ├── index.html       # Main UI with glassmorphism design
│   └── style.css        # Base styles (minimal)
├── package.json         # Dependencies & build config
└── dist/                # Built application
```

## Features
- **Debate Mode**: Enable multi-model debate for complex tasks
- **Web Search**: DuckDuckGo integration for internet research
- **File Upload**: Support for text files (images blocked with warning)
- **Project Management**: Multi-project support with chat history
- **Clipboard Paste**: Smart detection with model capability warnings

## API Integration

### Endpoint
```
POST https://www.dialagram.me/router/v1/chat/completions
Authorization: Bearer {NEXUM_API_KEY}
```

### Request Format
```javascript
{
    model: "qwen-3.6-plus",  // or other configured models
    messages: [
        { role: "user", content: "prompt" }
    ],
    stream: false
}
```

### Response Format
```javascript
{
    primary: "Response from primary model",
    secondary: "Response from speed model", 
    synthesis: "Final synthesized response",
    debateMode: boolean
}
```

## Build & Deployment

### Build Commands
```bash
npm run build:fast        # Fast build (no signing)
npm run build             # Full build with signing
npm run desktop           # Development mode
```

### Environment
```bash
NEXUM_API_KEY=<your-api-key>  # Required in .env
```

## Security
- Context Isolation: Enabled
- Node Integration: Disabled
- Sandbox: Enabled
- CSP: Configured for local + dialagram.me API

## UI/UX Guidelines
- Glassmorphism design with blur effects
- Dark theme with gradient accents
- Micro-interactions on hover/click
- Responsive layout (mobile-friendly)
- Status indicators for Debate/Web Search modes
- Model badge display in input area

---
name: ui-ux-expert
description: Expert in UI/UX design for Qwen Unleashed - glassmorphism, animations, accessibility.
---

# UI/UX Design Guidelines

## Design System
- **Theme**: Dark glassmorphism with vibrant accents
- **Colors**:
  - Primary: `#6366f1` (Indigo)
  - Secondary: `#8b5cf6` (Violet)
  - Accent: `#60a5fa` (Blue), `#a78bfa` (Purple), `#f472b6` (Pink)
  - Background: `rgba(15, 15, 25, 0.85)` with blur
  - Text: White with opacity variations

## Typography
- **Primary**: Inter (sans-serif)
- **Monospace**: JetBrains Mono (code/technical)
- **Sizing**: 0.7rem - 1.5rem scale

## Components
- Status pills with glow effects
- Glassmorphic cards with border highlights
- Smooth transitions (0.2s - 0.3s)
- Typing indicator with bouncing dots
- Avatar badges for User (ME) and AI (Q)

## Animations
- Fade-in on message appear
- Bounce effect on typing dots
- Scale/glow on button hover
- Smooth scroll behavior

## Accessibility
- High contrast text (WCAG compliant)
- Keyboard navigation support
- Focus states with visible indicators
- Semantic HTML structure

---
name: electron-builder-expert
description: Expert in Electron application building, packaging, and distribution for macOS.
---

# Electron Build & Distribution

## Build Configuration
```json
{
  "appId": "com.pcchopath.qwen-unleashed",
  "productName": "Qwen Unleashed",
  "mac": {
    "category": "public.app-category.utilities",
    "target": ["dmg"]
  }
}
```

## Build Variants
| Command | Purpose | Signing |
|---------|---------|---------|
| `npm run build:fast` | Quick local build | No |
| `npm run build` | Production build | Yes (if cert available) |
| `npm run desktop` | Dev mode with hot reload | No |

## Output
- DMG installer: `dist/qwen-unleashed-*.dmg`
- Portable app: `dist/mac/Qwen Unleashed.app`

## Troubleshooting
1. **White screen**: Check DevTools (`Option+Cmd+I`)
2. **IPC errors**: Verify preload.js exports
3. **API failures**: Check NEXUM_API_KEY in .env

---
name: pupr-assessment-expert
description: Expert in PUPR building damage assessment automation, structural logic, and Excel template preservation.
---

# Global Agent Skill: PUPR Assessment Automation

## 1. Global Autonomy & Technical Initiative
Agent bertindak sebagai Technical Architect yang proaktif, tidak hanya menganalisa teks tetapi menggunakan alat bantu untuk eksekusi.
- **Extension First Policy**: Jika tugas melibatkan manipulasi Excel yang kompleks, Agent wajib secara inisiatif menjalankan script (Python/Pandas) untuk memproses data, alih-alih menolak karena alasan kompatibilitas.
- **Self-Healing Workflow**: Jika metode standar gagal, Agent wajib mencari cara alternatif (misal: update library, ganti metode parsing) untuk memastikan hasil akhir sesuai dengan sampel PDF yang diberikan user.
- **Real-time Synchronization**: Agent akan menggunakan data hasil ekstraksi terbaru sebagai referensi utama dalam mengisi kolom input manual agar sinkron dengan template dinamis.

## 2. Intellectual Building Research & Context Awareness
Kemampuan melakukan riset eksternal untuk melengkapi data lapangan yang kosong.
- **Geospatial & Entity Verification**:
    - Agent akan mencari nama sekolah atau gedung di Google Search/Maps untuk memverifikasi eksistensi dan mendapatkan estimasi luas/dimensi bangunan jika data manual tidak tersedia.
    - Jika koordinat diberikan, Agent mengestimasi ukuran bangunan berdasarkan citra satelit untuk mengisi kolom "Volume".
- **Structural Logic Chain**:
    - Agent menerapkan logika sebab-akibat konstruksi. Contoh: Jika User memerintahkan "Atap Rubuh" (Rusak Berat), Agent secara otomatis menyesuaikan nilai kerusakan pada komponen pendukung (Dinding/Kolom) karena secara teknis tidak mungkin atap rubuh tanpa dampak pada struktur di bawahnya.
- **Standard Estimation**: Jika jumlah kolom tidak diketahui, Agent menggunakan standar jarak bentang praktis (3-4 meter) untuk mengisi volume yang logis.

## 3. Reverse Engineering & Target Mapping
Agent bekerja mundur dari hasil yang diinginkan User.
- **Target-to-Input**: Jika User meminta status "Rusak Sedang", Agent menghitung kombinasi nilai pada dropdown dan input manual agar formula IF fasilitator menghasilkan angka di range >30% - 45%.
- **Formula Shielding**: Agent mendeteksi dan mengunci sel yang berisi formula fasilitator (seperti kolom Bobot atau Total Nilai) agar tidak tertimpa input manual.
- **Unit-Value Mapping (Strict Rule)**:
    - **Satuan "unit"**: Isian wajib berupa angka bilangan bulat (1, 2, 3... 100 dst). DILARANG menggunakan presentase.
    - **Satuan "%"**: Isian wajib berupa presentase. Jika harus membagi bobot kerusakan, Agent harus mendistribusikannya secara natural/rasional (tidak mengada-ada) di antara komponen terkait (misal: distribusi antara kategori 1-7).
- **Cross-Column Consistency (H $\rightarrow$ I)**:
    - Agent wajib memastikan bahwa deskripsi umum di Kolom H (Tahap 1) selaras dengan detail spesifik di Kolom I.
    - *Rule:* Jika H = "Rusak Berat", maka I harus berisi detail kerusakan berat spesifik untuk komponen tersebut (misal: Atap $\rightarrow$ "Rangka atap rubuh dimakan rayap").
    - *Rule:* Jika H = "Tidak ada kerusakan", maka I harus berisi "X diindikasi dalam kondisi baik".
- **Keyword-Based Unit Override**:
    - Agent wajib melakukan pengecekan kata kunci komponen sebelum menentukan satuan.
    - *Example:* Meskipun komponen mengandung kata "Kusen" atau "Pintu", jika terdapat kata kunci **"Finishing"** (misal: "Finishing Kusen & Pintu"), maka satuan wajib mengikuti aturan **"%" (Presentase)** dan bukan "unit".

## 4. Interactive Confirmation Protocol
- **Ambiguity Check**: Jika data hasil riset Google berbeda signifikan dengan data user, atau jika nama gedung tidak ditemukan, Agent wajib meminta konfirmasi: "Saya menemukan data X di Google, namun data Anda Y. Mana yang ingin digunakan?"
- **Scenario Approval**: Sebelum melakukan pengisian massal, Agent memberikan ringkasan: "Saya akan mengatur Atap ke 100% (Rusak Berat) dan Dinding ke 40%. Apakah ini sesuai arahan?"

## 5. Comparison Logic Matrix (Manual vs Dropdown)
Panduan ketat bagi Agent untuk menentukan metode pengisian sel berdasarkan analisis visual sampel PDF/Gambar User.

| Tipe Kolom | Indikator Visual (Sample) | Strategi Eksekusi Agent | Validasi |
|---|---|---|---|
| **Dropdown (List)** | Ikon panah kecil, teks baku/standar (misal: "Ada/Tidak", "Ringan/Berat"). | **Strict Selection**: Cari string dalam list validasi yang paling mendekati maksud User. DILARANG mengetik teks bebas baru. | Exact Match |
| **Input Manual (Data)** | Sel kosong, garis bawah (_), atau angka variabel (Volume/Dimensi). | **Calculated Entry**: Isi dengan angka hasil riset Google, estimasi standar teknik, atau instruksi spesifik User. | Logical Range (0-100) |
| **Formula (Locked)** | Sel berwarna abu-abu, atau berisi angka hasil perhitungan otomatis. | **DO NOT TOUCH**: Biarkan Excel menghitung. Agent hanya mengontrol input yang mempengaruhi sel ini. | Read-Only |
| **Descriptive (Notes)** | Area "Catatan" atau "Keterangan". | **Contextual Generation**: Buat narasi teknis yang mendukung data angka (misal: "Kerusakan struktur akibat beban atap"). | Free Text |

## 6. Logical Sanity Checks & Volume Inference (Anti-Hallucination V2)
Agent wajib memvalidasi logika "Whole vs Part" dengan memprioritaskan Fakta Lapangan (Input User) daripada Data Statis (Excel Lama) yang mungkin kadaluarsa.

- **Contextual Volume Validation**:
    - Agent menggunakan data eksternal (Google/Standar SNI) untuk menilai kewajaran Volume Total.
    - *Rule:* Jika komponen bersifat jamak (Kusen, Jendela, Kloset) pada gedung publik (Sekolah/Pasar) memiliki nilai Volume = 1, Agent wajib menandainya sebagai "Suspect Data".
- **The "Field Fact" Priority**:
    - Jika input kerusakan dari User (misal: 4 unit) > Volume Total (1 unit), Agent dilarang melakukan *clamping* (pemotongan nilai) otomatis ke 1.
    - **Protokol**: Agent harus meminta izin untuk merevisi Volume Total agar mengakomodasi jumlah kerusakan tersebut.
    - *Prompt:* "Data lama mencatat hanya 1 unit, namun Anda melapor 4 rusak. Saya mendeteksi data lama tidak akurat. Bolehkah saya update Volume Total menjadi 4?"
- **Mathematical Integrity**:
    - Pastikan total `Sum(Volume Rusak)` pada Tahap 2 tidak pernah melebihi `Volume Total` (setelah revisi).
    - **Final Result Validation**: Pastikan nilai total akhir (Persentase Kerusakan Massa Bangunan) berada pada range yang rasional (misal: 30% - 70% untuk Rusak Berat). Jika total melebihi 100% (1.0), Agent wajib melakukan iterasi penurunan nilai input manual tanpa merubah deskripsi "Berat" agar hasil akhir tetap logis.
    - Pastikan persentase akhir pada kolom Y tidak melebihi 100% kecuali memang diizinkan oleh kolom bobot khusus.

## 7. External Database Synchronization (Dapodik Integration)
Agent wajib melakukan validasi silang (Cross-Referencing) antara input Excel dengan data publik pendidikan nasional (Dapodik) untuk memastikan akurasi volume bangunan.

- **Dapodik Retrieval Protocol**:
    - **Trigger:** Saat nama sekolah teridentifikasi (misal: "SDN 1 Sidoarjo").
    - **Action:** Agent melakukan pencarian spesifik ke domain `dapo.kemdikbud.go.id` atau `sekolah.data.kemdikbud.go.id`.
    - **Data Point:** Mengambil data "Jumlah Ruang Kelas", "Jumlah Ruang Perpustakaan", "Jumlah Toilet/Sanitasi", dan "Luas Tanah".
- **Volume Audit & Correction**:
    - **Comparison Logic:** Bandingkan `Jumlah Ruang` di Dapodik dengan `Volume` di Excel.
    - *Skenario:* Jika Excel mencatat "R. Kelas = 3 Unit" sedangkan Dapodik mencatat "6 Rombel/Ruang", Agent wajib menandai ini sebagai data usang (outdated) dan menyarankan update volume ke 6.
    - **Dimension Extrapolation**: Karena Dapodik tidak memuat ukuran dinding (m2), Agent menggunakan logika: `Total Luas Dinding = (Jumlah Ruang Dapodik) × (Standar Luas Dinding per Kelas)`. Ini lebih akurat daripada menebak-nebak.
- **Facility Check (Toilet/Sanitasi)**:
    - Sangat kritis untuk validasi kerusakan sanitasi. Jika User lapor "4 Toilet Rusak", dan Dapodik konfirmasi ada "4 Toilet" (Sanitasi Layak/Tidak Layak), maka data User valid. Jika Dapodik bilang "0 Toilet", Agent minta konfirmasi keberadaan bangunan baru yang belum terdata.

## 8. Visual Spatial Analysis & Multi-Source Triangulation
Agent memiliki kemampuan untuk mengekstrak data dari gambar denah (JPEG/PNG) dan melakukan triangulasi data dengan sumber eksternal (Dapodik) serta perintah verbal User.

- **Visual Plan Extraction (Denah Reading)**:
    - **Label Recognition**: Agent memindai gambar untuk mencari teks label ruangan (misal: "Kls 1", "R. Guru", "KM/WC").
    - **Unit Counting**: Agent menghitung jumlah visual ruangan pada gambar. Jika User berkata "Kelas 1 & 3 rusak", Agent memverifikasi keberadaan kedua ruangan tersebut pada gambar.
    - **Dimension Inference**: Jika pada denah tertulis dimensi (misal "8x7"), Agent menggunakan angka tersebut untuk menghitung Luas (m²) dan Volume Dinding secara presisi, menggantikan estimasi standar.
- **Hierarchy of Truth (Protokol Konflik Data)**:
    Dalam menentukan volume dan identitas ruangan, Agent mengikuti urutan prioritas kebenaran berikut:
    1. **Visual Bukti Lapangan (Denah/Foto)**: "Jika denah menunjukkan 3 pintu, maka ada 3 pintu (meski Dapodik bilang 2)."
    2. **Data Dapodik (Validasi Sekunder)**: Digunakan jika denah tidak jelas atau tidak mencantumkan fungsi ruangan.
    3. **Estimasi Standar**: Opsi terakhir jika tidak ada data visual atau database.
- **Specific Locus Mapping (Pemetaan Lokasi Spesifik)**:
    - **Action**: Saat User menyebut "Kelas 1 & 3 Rusak Berat", Agent tidak memukul rata semua kelas.
    - **Execution**:
        1. Identifikasi "Kelas 1" dan "Kelas 3" pada denah.
        2. Hitung volume spesifik hanya untuk 2 ruangan tersebut (bukan total seluruh kelas).
        3. Input data kerusakan pada baris yang relevan (atau buat catatan spesifik: "Kerusakan fokus pada Ruang 1 & 3").
    - **Validation**: Jika Denah hanya menampilkan "Kelas 1, 2, 3" tapi User lapor "Kelas 4 rusak", Agent wajib bertanya: *"Di denah hanya terlihat sampai Kelas 3. Apakah Kelas 4 bangunan terpisah?"*

## 9. Dynamic Sheet Replication & Realistic Damage Simulation
Agent memiliki kemampuan untuk mengembangkan struktur file Excel dengan membuat sheet baru untuk area spesifik, dan mensimulasikan pola kerusakan yang logis berdasarkan dimensi ruangan.

- **Sheet Cloning Protocol (Revit/Rehab Expansion)**:
    - **Trigger:** User meminta penambahan ruangan spesifik (misal: *"Buatkan juga hitungan untuk Kelas 1 dan Perpustakaan"*).
    - **Action:** Agent menginstruksikan duplikasi (Copy-Paste) sheet template/master yang sudah valid.
    - **Naming Convention:** Sheet baru diberi nama sesuai fungsi ruang (misal: `Kls_1`, `Perpus`) untuk memudahkan navigasi.
    - **Sanitization:** Pada sheet baru, Agent mereset input manual (Volume & Nilai Kerusakan) menjadi 0, namun **mempertahankan semua Formula dan Dropdown** agar siap diisi data baru.
- **Dimension-Driven Damage (Kerusakan Berbasis Dimensi)**:
    - **Concept:** Nilai kerusakan harus proporsional dengan ukuran ruang spesifik, bukan ukuran total sekolah.
    - **Execution**:
        1. *Determine Dimensions:* Tentukan ukuran ruang (misal dari Denah: 8x7m).
        2. *Calculate Surface:* Hitung luas elemen. (Luas Atap = 56 m², Luas Dinding = (keliling x tinggi) - bukaan).
        3. *Input Logic:* Jika "Rusak Berat" pada atap, input volume kerusakan mendekati 56 m² (misal 50 m²), bukan angka acak.
- **Natural Damage Variance (Anti-Flat Pattern)**:
    - **Rule:** Kerusakan alami tidak pernah "rata 100%". Agent dilarang mengisi semua sel dengan angka maksimum kecuali diperintah spesifik "Hancur Total".
    - **Realistic Simulation**:
        - *Primary Impact:* Komponen utama penyebab (misal: Atap Bocor) diisi kerusakan tinggi (80-100%).
        - *Collateral Damage:* Komponen terdampak (misal: Plafon, Lantai, Dinding) diisi kerusakan sedang/ringan (20-40%) dengan variasi acak yang logis.
        - *No "Robot" Numbers:* Hindari angka bulat sempurna terus menerus. Gunakan variasi (misal: 45 m², bukan 50 m²) agar laporan terlihat seperti hasil survei manusia.

## 10. Layout Formatting & Print Readiness (Visual Ergonomics)
Agent bertanggung jawab memastikan output Excel tidak hanya akurat secara data, tetapi juga mudah dibaca (readable) oleh manusia dan siap cetak (print-ready) tanpa perlu pengaturan ulang manual.

- **Row & Column Breathing Room (Ergonomi Visual)**:
    - **Anti-Cramping:** Agent dilarang membiarkan tinggi baris (Row Height) pada ukuran default (15 poin) jika sel berisi teks panjang atau *Wrapped Text*.
    - **Auto-Adjustment:** Setelah input data, Agent wajib melakukan *Auto-Fit Column Width* pada kolom deskripsi agar teks tidak terpotong.
    - **Standard Height:** Set tinggi baris isian manual minimal **20-25 poin** untuk memberikan kesan rapi dan mudah ditulis tangan jika perlu.
- **Print-Safe Constraints (Anti-Potong)**:
    - **Scale to Fit:** Agent wajib mengaktifkan fitur *"Fit Sheet on One Page"* (Scale to Width = 1 page) pada pengaturan cetak. Ini mencegah kolom paling kanan (biasanya Nilai Akhir) "lari" ke halaman kedua.
    - **Print Area Definition:** Agent harus mendefinisikan ulang `PrintArea` dinamis yang mencakup baris terakhir data. Jangan biarkan printer mencetak 100 halaman kosong di bawah tabel.
    - **Orientation Lock:** Untuk tabel form PUPR yang lebar (banyak kolom klasifikasi), Agent wajib mengunci orientasi ke **Portrait** agar sesuai dengan template fasilitator.
- **Style Preservation on Cloning**:
    - Saat menduplikasi sheet (Skill #9), Agent dilarang hanya menyalin *Values*. Agent wajib menyalin **Source Formatting** (termasuk lebar kolom, merge cells, dan border).
    - **Surgical Layout Mirroring:** Jika library teknis membatasi copy-style, Agent wajib melakukan replikasi properti numerik (Column Width, Row Height, Merged Cell Ranges) secara eksplisit dari sheet donor.
    - Jika limitasi sistem tetap tinggi, Agent wajib melakukan *re-formatting* manual segera setelah data diisi (misal: menebalkan border tabel kembali).

## 11. Absolute Parity Audit (1:1 Verification)
Agent wajib melakukan verifikasi akhir dengan membandingkan target sheet terhadap Gold Standard sheet secara sel-per-sel untuk memastikan tidak ada anomali.

- **Surgical Comparison Protocol**:
    - Agent tidak boleh berasumsi bahwa "script sudah berjalan benar". Agent wajib menjalankan script audit yang membandingkan `Column Width`, `Row Height`, `Merged Cells`, dan `Formula Structure` antara Sheet Target dan Sheet Donor.
    - *Strict Rule:* Jika ditemukan satu saja perbedaan numerik pada layout (misal: Lebar Kolom B di Donor = 50, di Target = 48), Agent wajib menganggap proses gagal dan melakukan perbaikan hingga mencapai parity 100%.
- **Consistency Loop**:
    - Setiap kali melakukan perubahan data (seperti update volume atau nilai kerusakan), Agent wajib melakukan re-audit terhadap layout untuk memastikan aktivitas pengisian data tidak merusak format visual (misal: tidak sengaja mengubah tinggi baris).
- **Final Sign-off**: Agent hanya boleh melaporkan tugas "Selesai" setelah hasil audit menunjukkan status `Layout OK=True` dan `Logic OK=True`.

## 12. Cell-Type Structural Analysis (Merge & Input Identification)
Agent wajib melakukan analisis struktural mendalam terhadap setiap sel sebelum melakukan modifikasi untuk menghindari kerusakan template.

- **Cell Identity Mapping**:
    - Agent wajib membedakan antara:
        1. **Merged Cells**: Sel yang tergabung. Modifikasi hanya boleh dilakukan pada sel utama (top-left) dari range yang digabung.
        2. **Dropdowns (Data Validation)**: Sel dengan daftar pilihan. Agent dilarang mengetik teks bebas jika validasi aktif; harus menggunakan string yang ada dalam list.
        3. **Locked Formulas**: Sel yang berisi rumus. DILARANG menimpa rumus dengan nilai statis.
        4. **Manual Input**: Sel yang memang disediakan untuk diisi data.
- **Structural Impact Analysis**:
    - Sebelum menulis data, Agent harus bertanya: "Apakah penulisan nilai di sel ini akan merusak merge-cells di sekitarnya atau memutus rantai formula?"
- **Layout-Aware Writing**: Jika sebuah kolom adalah hasil merge dari beberapa kolom kecil, Agent wajib mengidentifikasi koordinat sel utama agar data terinput di posisi yang benar dan tidak menggeser layout.

## 13. Regulatory Compliance & Strategic Gap Analysis (Standar Sarpras/Dapodik)
Agent memiliki kemampuan untuk menilai kelayakan bangunan berdasarkan Standar Nasional Pendidikan (Permendiknas No. 24/2007) dan melakukan "Strategic Assessment" untuk memaksimalkan peluang perbaikan.

- **Ratio & Capacity Validation (The "Headcount" Logic)**:
    - **Trigger:** Saat User menyebut "Toilet", "Kelas", atau "Fasilitas Siswa".
    - **Action:** Agent menarik data **Jumlah Murid** (Laki-laki/Perempuan) dari Dapodik atau meminta estimasi User.
    - **Calculation:** Hitung kebutuhan ideal.
        - *Rumus SD (Contoh):* 1 Toilet / 40 Siswa Laki-laki, 1 Toilet / 30 Siswi Perempuan.
    - **Gap Check:** Jika `Jumlah Existing < Kebutuhan Standar`, aktifkan mode "Strategic Rehab".
- **Strategic Damage Injection (Functional Failure = Physical Failure)**:
    - **Logic:** Jika bangunan fisik masih berdiri tapi tidak memenuhi standar rasio (under-capacity), bangunan tersebut dianggap "Gagal Fungsi".
    - **Execution:** Agent diizinkan (atas perintah User) untuk **mengisi status Rusak Berat** (>45%) pada form, meskipun kerusakan fisik visual mungkin hanya sedang.
    - **Justification:** Pada kolom "Catatan/Keterangan", Agent **WAJIB** menulis argumen regulasi:
        - *"Kondisi fisik Sedang, namun kapasitas TIDAK MEMENUHI Standar Permendiknas 24/2007 (Existing: 3, Butuh: 6). Disarankan Rehab Total/Perluasan."*
- **Dimensional Logic (Dimension Sanity)**:
    - **Verification:** Cek input dimensi User (misal 7x35m).
    - *Case:* 7x35m = 245m². Untuk 3 bilik toilet, ini terlalu besar (tidak wajar).
    - *Correction:* Agent akan bertanya: *"Ukuran 7x35m (245m²) terlalu besar untuk 3 bilik. Apakah maksud Anda 7x3.5m, atau ini adalah satu blok bangunan toilet massal?"*
- **Telegram/Short-Message Parsing**:
    - Mampu menerjemahkan perintah singkatan khas chat (misal: "Kondisi existing 3 bilik, user minta sesuai standar").
description: Technical implementation guide for high-precision Excel manipulation.
---

# XLSX Technical Implementation

## Requirements for Outputs
- **Professional Font**: Use Arial/Times New Roman unless specified.
- **Zero Formula Errors**: Deliverables must have ZERO formula errors (#REF!, #DIV/0!, etc.).
- **Preserve Templates**: EXACTLY match existing format, style, and conventions.

## Technical Workflow
### Data Analysis with Pandas
```python
import pandas as pd
df = pd.read_excel('file.xlsx') 
# Use sheet_name=None to read all sheets as a dict
```

### High-Precision Editing with Openpyxl
- Use `load_workbook` for formatting and formulas.
- Use `data_only=True` only for reading calculated values (WARNING: saving with this replaces formulas with values).
- Use `Surgical Edits`: modify specific cells instead of overwriting the whole sheet.

### Formula Recalculation
Since openpyxl doesn't evaluate formulas, use `scripts/recalc.py` (powered by LibreOffice) to update values and scan for errors before delivery.

## Formula Verification Checklist
- [ ] **Test sample references**: Verify 2-3 cells.
- [ ] **Column mapping**: Confirm exact column index (e.g., Column X = 24).
- [ ] **Row offset**: Excel is 1-indexed.
- [ ] **Cross-sheet references**: Verify `SheetName!Cell` format.


