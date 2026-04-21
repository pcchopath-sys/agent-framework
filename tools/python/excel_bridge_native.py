import xlwings as xw
import os

def main():
    gold_path = '/Users/pcchopath/Downloads/Form-Penilaian-Kerusakan-Bangunan SDN Banjarsari.xlsx'
    target_path = '/Users/pcchopath/Downloads/Form-Penilaian-Kerusakan-Bangunan SDN KENDALPECABEAN.xlsx'
    
    # 1. Start Excel invisibly
    app = xw.App(visible=False)
    try:
        print("[*] Opening Golden Template...")
        wb_gold = app.books.open(gold_path)
        
        # 2. SAVE AS Target Path immediately to preserve all native metadata/dropdowns
        # This ensures we are working on a perfect copy of the Gold Template
        wb_gold.save(target_path)
        wb = app.books.open(target_path)
        
        # Mapping: Target Sheet Name -> Base Gold Sheet Name
        mapping = {
            'R. KELAS 1 & 2': 'RUANG KELAS',
            'R. KELAS 3 & 5B': 'RUANG KELAS',
            'R. KELAS 4': 'RUANG KELAS',
            'R. KM SISWI': 'KAMAR MANDI SISWI',
            'RUANG GURU ': 'KAMAR MANDI GURU',
        }
        
        # Mapping: Target Sheet Name -> Specific Building Name for cell E7
        b_names = {
            'R. KELAS 1 & 2': 'RUANG KELAS 1 DAN 2',
            'R. KELAS 3 & 5B': 'RUANG KELAS 3 DAN 5B',
            'R. KELAS 4': 'RUANG KELAS 4',
            'R. KM SISWI': 'KAMAR MANDI SISWI',
            'RUANG GURU ': 'RUANG GURU',
        }

        # Damage Configuration
        damage_config = {
            20: {'H': "Ada kerusakan, namun diindikasi tidak membahayakan keselamatan pemanfaatan ruang/bangunan", 'I': 4},
            21: {'H': "Ada kerusakan, namun diindikasi tidak membahayakan keselamatan pemanfaatan ruang/bangunan", 'I': 2, 'K': 4},
            22: {'H': "Ada kerusakan yang diindikasi membahayakan keselamatan pemanfaatan ruang/bangunan", 'O': 1.0},
            23: {'H': "Ada kerusakan yang diindikasi membahayakan keselamatan pemanfaatan ruang/bangunan", 'M': 0.7, 'K': 0.3},
            24: {'H': "Ada kerusakan yang diindikasi membahayakan keselamatan pemanfaatan ruang/bangunan", 'K': 0.4, 'M': 0.6},
            25: {'H': "Ada kerusakan yang diindikasi membahayakan keselamatan pemanfaatan ruang/bangunan", 'O': 1.0},
            26: {'H': "Ada kerusakan, namun diindikasi tidak membahayakan keselamatan pemanfaatan ruang/bangunan", 'I': 1},
            27: {'H': "Ada kerusakan, namun diindikasi tidak membahayakan keselamatan pemanfaatan ruang/bangunan", 'I': 1},
            28: {'H': "Ada kerusakan, namun diindikasi tidak membahayakan keselamatan pemanfaatan ruang/bangunan", 'I': 1},
            29: {'H': "Ada kerusakan yang diindikasi membahayakan keselamatan pemanfaatan ruang/bangunan", 'K': 0.6, 'M': 0.4},
            30: {'H': "Ada kerusakan yang diindikasi membahayakan keselamatan pemanfaatan ruang/bangunan", 'M': 0.8, 'K': 0.2},
            31: {'H': "Ada kerusakan, namun diindikasi tidak membahayakan keselamatan pemanfaatan ruang/bangunan", 'I': 1},
            34: {'H': "Ada kerusakan, namun diindikasi tidak membahayakan keselamatan pemanfaatan ruang/bangunan", 'I': 1},
        }
        
        # Exact lookup strings for "Tidak Rusak" rows
        lookup_strings = {
            19: "Pondasi diindikasi dalam kondisi baik",
            32: "Jaringan listrik dalam kondisi baik",
            33: "Sistem penyediaan air dalam kondisi baik"
        }

        # 3. Generate Target Sheets via Native Duplication
        for target_name, gold_name in mapping.items():
            print(f"[*] Creating {target_name} from {gold_name}...")
            
            # Copy the gold sheet
            gold_sh = wb.sheets[gold_name]
            gold_sh.copy(after=wb.sheets[-1])
            
            # The copied sheet becomes the active sheet
            new_sh = wb.sheets[-1]
            new_sh.name = target_name
            
            # Injection: Building Name
            new_sh.range('E7').value = b_names.get(target_name, "")
            
            # Injection: Damage Data
            for r in range(19, 35):
                if r in lookup_strings:
                    # Set "Tidak ada kerusakan" and exact lookup string
                    new_sh.range(f'H{r}').value = "Tidak ada kerusakan"
                    new_sh.range(f'I{r}').value = lookup_strings[r]
                    continue
                
                # Get unit from column F
                unit = new_sh.range(f'F{r}').value
                if r in damage_config:
                    cfg = damage_config[r]
                    new_sh.range(f'H{r}').value = cfg['H']
                    
                    # Clear numeric cols
                    for col in ['I', 'K', 'M', 'O']:
                        new_sh.range(f'{col}{r}').value = None
                    
                    # Fill values based on unit
                    for col, val in cfg.items():
                        if col == 'H': continue
                        if unit == '%':
                            new_sh.range(f'{col}{r}').value = val if val <= 1.0 else val / 100.0
                        else:
                            new_sh.range(f'{col}{r}').value = int(val)
                else:
                    new_sh.range(f'H{r}').value = "Tidak ada kerusakan"
                    new_sh.range(f'I{r}').value = "Diindikasi dalam kondisi baik"

        # 4. Final Cleanup: Remove original gold sheets to leave only targets
        for gold_sh_name in mapping.values():
            # Use a set to avoid duplicate deletions
            pass
        
        # Delete original gold source sheets
        for sh_name in set(mapping.values()):
            try:
                wb.sheets[sh_name].delete()
            except:
                pass
        
        # Save and Close
        wb.save()
        print("SUCCESS: Absolute Parity achieved via Save-As & Surgical Edit!")

    finally:
        wb_gold.close()
        wb.close()
        app.quit()

if __name__ == "__main__":
    main()
