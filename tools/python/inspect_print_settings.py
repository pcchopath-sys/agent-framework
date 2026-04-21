from openpyxl import load_workbook

src_path = '/Users/pcchopath/Downloads/Form-Penilaian-Kerusakan-Bangunan SDN Banjarsari.xlsx'
wb = load_workbook(src_path)
ws = wb['RUANG KELAS']

print(f"Print Area: {ws.print_area}")
print(f"Orientation: {ws.page_setup.orientation}")
print(f"FitToWidth: {ws.page_setup.fitToWidth}")
print(f"FitToHeight: {ws.page_setup.fitToHeight}")
