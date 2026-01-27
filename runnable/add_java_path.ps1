$JavaBinPath = "%{appdata.install.path}\%{java.subpath}\bin"

$currentPath = [Environment]::GetEnvironmentVariable('PATH', 'User')
$updatedPath = $currentPath

# Если PATH пустой
if ([string]::IsNullOrEmpty($currentPath)) {
    $updatedPath = $JavaBinPath
}
else {
    $updatedPath = "$JavaBinPath;$updatedPath"
}

[Environment]::SetEnvironmentVariable('PATH', $updatedPath, 'User')

