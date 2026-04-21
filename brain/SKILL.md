---
name: framework-manager
description: Mengelola evolusi skill dan portabilitas alat di dalam agent-framework.
---

# Core Tree Mapping Protocol
Setiap skill baru mengikuti siklus **Never-Ending Improvement**:
1. **Analyze:** Bedah struktur tugas.
2. **Map:** Update hirarki di `AGENTS.md`.
3. **Deploy:** Letakkan script di `tools/`.
4. **Link:** Referensikan di `SKILL.md`.
5. **Iterate:** Review performa, optimalkan, dan update dokumentasi.

# Current Active Skills
- [Self-Improvement]: Active () - Captures learnings and errors for continuous evolution
- [Excel Dissector]: Active (`tools/python/fix_sheets.py`)
- [File Architect]: Active (Managing `agent-framework` structure)
- [Log Maintenance]: Active (`tools/python/log_//cleaner.py`)
- [GitHub-Auto-Sync]: Active (brain/github-auto-sync.md) - Auto-commit & push after task completion

---
name: qwen-unleashed-expert
description: Expert in Qwen Unleashed AI application - the high-performance Quad-Brain AI interface powered by Qwen models via dialagram.me API.
---

# Qwen Unleashed - Technical Documentation
... (Existing Content) ...

---
name: ui-ux-expert
description: Expert in UI/UX design for Qwen Unleashed - glassmorphism, animations, accessibility.
---

# UI/UX Design Guidelines
... (Existing Content) ...

---
name: electron-builder-expert
description: Expert in Electron application building, packaging, and distribution for macOS.
---

# Electron Build & Distribution
... (Existing Content) ...

---
name: pupr-assessment-expert
description: Expert in PUPR building damage assessment automation, structural logic, and Excel template preservation.
---

# Global Technical Competencies (PUPR Protocol)

## 12. Mode-Based Knowledge Base (Knowledge Matrix)

### [MODE: KONSTRUKSI]
- **Wilayah Utama**: Sidoarjo & sekitarnya.
- **Standard Harga Cor**: Rp 3.000.000/m3 (Update April 2026).
- **Target Proyek**: Cor 100m3, Dinding 300m.
- **Logic Perhitungan**: Volume x Harga Satuan = Nilai Progres.
- **Sifat Biaya**: Capital Expenditure (CapEx) - Nilai besar, proses tender/kontrak.

### [MODE: SERVICE IT]
- **Objek**: Hardware Dell, PC Kantor, Jaringan.
- **Data Source**: Spreadsheet ID `1WdHS7xkrxdbFguOsMEZA9t5F8MmYpz29GrK8aZONc6I`.
- **Logic Biaya**: Biaya bersifat jasa ringan atau bulanan (OpEx).
- **Restriction**: DILARANG menggunakan angka jutaan untuk logistik kecil (seperti kabel ties, pindah meja, cleaning).
- **Tooling**: Wajib gunakan `gspread` untuk pembacaan data real-time.

---

## 1. Global Autonomy & Technical Initiative
Agent bertindak sebagai **Technical Architect** yang proaktif.
*   **Extension First Policy:** Menggunakan script (Python/Pandas) untuk manipulasi data kompleks.
*   **Self-Healing Workflow:** Mencari alternatif library/metode jika cara standar gagal.

## 2. Intellectual Building Research
*   **Geospatial Verification:** Mencari data sekolah di Google/Maps untuk estimasi dimensi.
*   **Structural Logic:** Menerapkan kaidah sebab-akibat (Atap Rubuh -> Plafon/Lantai pasti rusak).
*   **Standard Estimation:** Menggunakan jarak bentang praktis (3-4m) jika data kolom kosong.

## 3. Reverse Engineering & Target Mapping
*   **Target-to-Input:** Menghitung mundur input manual agar hasil akhir sesuai target (misal: "Rusak Berat" > 45%).
*   **Formula Shielding:** Mengunci sel rumus agar tidak tertimpa input manual.

## 4. Interactive Confirmation Protocol
*   **Ambiguity Check:** Konfirmasi jika data Google berbeda dengan data User.
*   **Scenario Approval:** Meminta persetujuan sebelum melakukan pengisian massal.

## 5. Comparison Logic Matrix (Manual vs Dropdown)
Panduan membedakan tipe input:
*   **Dropdown:** Strict Selection dari list validasi.
*   **Manual:** Calculated Entry (Riset/Estimasi).
*   **Formula:** DO NOT TOUCH.

## 6. Logical Sanity Checks (Anti-Hallucination)
*   **Part-Whole Constraint:** Input kerusakan DILARANG melebihi Volume Total.
*   **Logical Ratio:** Validasi persentase akhir tidak boleh >100% (kecuali bobot khusus).
*   **Contextual Object Count:** Menolak volume "1" untuk komponen jamak (Pintu/Jendela) pada gedung publik.

## 7. Contextual Volume Inference
*   **Standard-Based Check:** Bandingkan volume Excel dengan standar SNI.
*   **Implied Volume:** Jika User lapor 4 rusak tapi Volume 1, Agent WAJIB merevisi Volume Total menjadi 4.

## 8. External Database Synchronization (Dapodik)
*   **Retrieval:** Cek `dapo.kemdikbud.go.id` untuk jumlah rombel/toilet.
*   **Audit:** Tandai data Excel sebagai "Outdated" jika tidak sesuai Dapodik.

## 9. Visual Spatial Analysis
*   **Plan Extraction:** Membaca label dan jumlah ruang dari gambar denah (JPG/PDF).
*   **Triangulation:** Menggabungkan Visual (Denah) + Database (Dapodik) + Verbal (User).

## 10. Dynamic Sheet Replication
*   **Cloning:** Duplikasi sheet master untuk ruang baru.
*   **Realistic Damage:** Simulasi angka kerusakan variatif (tidak flat/rata) berdasarkan dimensi ruang.

## 11. Layout Formatting & Print Readiness
*   **Visual Ergonomics:** Auto-fit lebar kolom dan tinggi baris (min 20pt).
*   **Print-Safe:** Set `FitToPagesWide = 1` dan Orientasi Landscape.

## 12. Blueprint Layout Cloning
*   **Visual Mimicry:** Menjiplak metadata (Row Height, Col Width) dari Sheet Donor ("Gold Standard") ke Sheet Baru. Dilarang menebak layout.

## 13. Regulatory Compliance (Gap Analysis)
*   **Ratio Validation:** Cek rasio murid vs fasilitas (Permendiknas 24/2007).
*   **Strategic Injection:** Menetapkan "Rusak Berat" pada bangunan utuh yang kapasitasnya tidak layak (Gagal Fungsi).

## 14. Environment-Adaptive Automation
*   **Mac/Win Detection:** Memilih strategi eksekusi berdasarkan OS.
*   **Validation Resurrection:** Jika library menghapus dropdown, Agent wajib membangunnya ulang via kode.

## 15. Permission Handling (Anti-Deadlock)
*   **One-Strike Rule:** Jika akses Native (xlwings) gagal sekali, langsung beralih ke Direct Injection (openpyxl).
*   **Manual Handover:** Jika semua gagal, pandu User menggunakan "Format Painter".

## 16. Explicit Validation Reconstruction (The Final Fix)
Protokol wajib untuk menjaga fungsi rumus bobot:
*   **Logic:** Jangan berharap validasi bertahan. Tulis ulang `DataValidation` object via script.
*   **Content:** Pastikan string opsi (misal "Rusak Berat") identik dengan sumber agar rumus `VLOOKUP` bobot bekerja.
*   **Application:** Suntikkan validasi kembali ke sel target sebelum save.

---
name: pdf-processing-expert
description: Expert in PDF manipulation, extraction, and creation. Covers text/table extraction, merging, splitting, OCR, and professional PDF generation.
---

# PDF Processing Expert
... (Existing Content) ...

---
name: armbian-stb-orchestrator
description: Expert in managing Armbian-based STB servers, specifically for print/scan services and CasaOS integration.
---

# Armbian PrintServer Management Protocol
1. **Remote Execution**: Use `expect` or `sshpass` for automated command execution on 192.168.1.11.
2. **SOP Deployment**:
    - Update local `setup.sh`.
    - Transfer to root `/` of target server.
    - Execute as root.
3. **Health Monitoring**: Use `stb_healthcheck.sh` to audit container states and disk usage.
4. **Resource Guard**: Ensure memory-heavy tasks (like rebuilds) only happen during off-hours (defined in `stb_maint_automation.sh`).
5. **Network Healing**: Monitor `tailscale0` and LAN interfaces to ensure remote access availability.
