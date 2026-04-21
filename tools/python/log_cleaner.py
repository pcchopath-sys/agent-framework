import os
import time
from pathlib import Path

def clean_old_logs(days_to_keep=7):
    # Menggunakan Path relatif terhadap file ini agar portable
    # Lokasi: agent-framework/tools/python/log_cleaner.py
    # Target: agent-framework/logs/
    base_dir = Path(__file__).resolve().parent.parent.parent
    log_dir = base_dir / "logs"

    print(f"[*] Memulai pembersihan log di: {log_dir}")

    if not log_dir.exists():
        print(f"[!] Folder logs tidak ditemukan. Membuat folder baru...")
        log_dir.mkdir(parents=True, exist_ok=True)
        return

    now = time.time()
    cutoff = now - (days_to_keep * 86400)
    count = 0

    for log_file in log_dir.glob("*.log"):
        if log_file.is_file():
            # Cek waktu modifikasi terakhir
            file_mtime = log_file.stat().st_mtime
            if file_mtime < cutoff:
                try:
                    log_file.unlink()
                    print(f"[✓] Dihapus: {log_file.name}")
                    count += 1
                except Exception as e:
                    print(f"[x] Gagal menghapus {log_file.name}: {e}")

    print(f"[*] Selesai. Total {count} file log lama dibersihkan.")

if __name__ == "__main__":
    # Kamu bisa menyesuaikan jumlah hari yang ingin disimpan di sini
    clean_old_logs(days_to_keep=7)
