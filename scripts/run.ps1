param(
    [Parameter(Mandatory=$true)][string]$year,
    [Parameter(Mandatory=$true)][string]$day,
    [Parameter(Mandatory=$true)][string]$part
)
$path="$year\day-$day\part-$part"
$buildPath="$path\build"

&"./scripts/build.ps1" $year $day $part

echo "Run:"
&"$buildPath\out.exe"