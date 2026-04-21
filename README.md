# Agent Framework Hub (Architect_Dev_Prime)

Ini adalah pusat komando terintegrasi untuk pengembangan, pemeliharaan, dan deployment Agent AI. Folder ini mengonsolidasikan seluruh "otak", "skill", dan "infrastruktur" yang dibutuhkan untuk produktivitas tinggi.

## 📂 Struktur Folder

### 🧠 `/brain` (The Cognition Layer)
Berisi instruksi tingkat tinggi, identitas, dan protokol perilaku Agent.
- **AGENTS.md**: Definisi identitas `Architect_Dev_Prime`, Persona Mode, dan Guideline Interaksi.
- **SKILLS.md**: Katalog kompetensi teknis (PUPR, Coding, Hardware, dll).

### ⚙️ `/configs` (The Configuration Layer)
Tempat penyimpanan file konfigurasi (`.json`, `.env`, `.yaml`) untuk tuning performa dan koneksi API.

### 🛠️ `/tools` (The Execution Layer)
Kumpulan script otomasi untuk tugas-tugas repetitif.
- **`/python`**: Script pengolahan data, manipulasi Excel (seperti `fix_sheets.py`), dan AI automation.
- **`/bash`**: Script deployment, system maintenance, dan environment setup.

### 💻 `/core` (The Application Layer)
Source code dari interface AI (Claude-Local-UI).
- **Stack**: Node.js, Electron, Vanilla JS/CSS/HTML.
- **Kebutuhan**: Menjalankan `npm install` dan `npm run desktop` untuk meluncurkan interface.

## 🚀 Cara Penggunaan untuk Pengembangan Masa Depan

1. **Update Identitas**: Edit `brain/AGENTS.md` untuk menambah persona atau mengubah objective.
2. **Tambah Skill**: Tambahkan modul baru di `brain/SKILLS.md` agar Agent memiliki kapabilitas teknis baru.
3. **Otomasi Baru**: Simpan script python/bash di folder `tools/` untuk memperluas jangkauan eksekusi Agent.
4. **Update UI**: Modifikasi file di dalam `core/` untuk meningkatkan pengalaman pengguna.

## 🛠 Tech Stack Summary
- **Core**: Node.js / Electron
- **Automation**: Python (Openpyxl, Pandas)
- **Shell**: Zsh / Bash
- **Documentation**: Markdown (GFM)
