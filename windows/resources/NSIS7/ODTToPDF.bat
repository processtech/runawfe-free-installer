echo off
for /R %%X in (*.odt) do echo %%X && "__OpenOffice__" -headless "__NSISSRC__/ODTToPDF.odt" "macro://./Standard.Converter.SaveAsPDF(%%X)"

