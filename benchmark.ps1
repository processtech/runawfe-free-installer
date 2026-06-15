param (
    [string]$Service
)

if (-not $Service) {
    Write-Error "Ошибка: Не передана система для отладки!"
    exit 1
}

$totalStart = Get-Date
Write-Host ">>> СТАРТ ОБЩЕГО ЗАМЕРА: $totalStart" -ForegroundColor Cyan

$step1Start = Get-Date
Write-Host "`n[1/3] Включение X11..." -ForegroundColor Gray
wsl xhost +local:docker
$step1End = Get-Date
$step1Elapsed = $step1End - $step1Start

$step2Start = Get-Date
Write-Host "`n[2/3] Подготовка ОС ($Service)..." -ForegroundColor Gray
cmd /c prepare_for_target_os.cmd $Service
$step2End = Get-Date
$step2Elapsed = $step2End - $step2Start

$step3Start = Get-Date
Write-Host "`n[3/3] Запуск сборки Docker ($Service)..." -ForegroundColor Gray
wsl docker-compose -f docker/docker-compose.yml run --rm --build --service-ports $Service
$step3End = Get-Date
$step3Elapsed = $step3End - $step3Start

$totalEnd = Get-Date
$totalElapsed = $totalEnd - $totalStart

# --- ВЫВОД РЕЗУЛЬТАТОВ ---
Write-Host "`n========================================" -ForegroundColor Magenta
Write-Host ">>> РЕЗУЛЬТАТЫ ЗАМЕРА ВРЕМЕНИ ПО СТАДИЯМ:" -ForegroundColor Magenta

Write-Host ("Стадия 1 (Включение X11):        {0:d2}:{1:d2}.{2:d3}" -f $step1Elapsed.Minutes, $step1Elapsed.Seconds, $step1Elapsed.Milliseconds) -ForegroundColor White
Write-Host ("Стадия 2 (Подготовка для ОС):    {0:d2}:{1:d2}.{2:d3}" -f $step2Elapsed.Minutes, $step2Elapsed.Seconds, $step2Elapsed.Milliseconds) -ForegroundColor White
Write-Host ("Стадия 3 (Docker сборка/запуск): {0:d2}:{1:d2}.{2:d3}" -f $step3Elapsed.Minutes, $step3Elapsed.Seconds, $step3Elapsed.Milliseconds) -ForegroundColor White

Write-Host "----------------------------------------" -ForegroundColor Magenta
Write-Host ("ОБЩЕЕ ПОТРАЧЕННОЕ ВРЕМЯ:         {0:d2}:{1:d2}" -f $totalElapsed.Minutes, $totalElapsed.Seconds) -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Magenta
