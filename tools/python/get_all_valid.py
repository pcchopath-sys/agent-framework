from openpyxl import load_workbook

target_path = '/Users/pcchopath/Downloads/Form-Penilaian-Kerusakan-Bangunan SDN KENDALPECABEAN.xlsx'
wb = load_workbook(target_path, data_only=True)
ws = wb['Presentase Acuan']

options = set()
for row in ws.values:
    for cell in row:
        if cell and isinstance(cell, str):
            options.add(cell)

print(sorted(list(options)))
