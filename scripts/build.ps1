param(
    [Parameter(Mandatory=$true)][string]$year,
    [Parameter(Mandatory=$true)][string]$day,
    [Parameter(Mandatory=$true)][string]$part,
    [switch]$force=$False
)
$path="$year\day-$day\part-$part"
$srcPath="$path\src"
$buildPath="$path\build"

[bool]$changed=$False

echo "Build:"

# Create build folder
if (-not(Test-Path $buildPath)) {
    echo "mkdir build"
    mkdir $buildPath | Out-Null
}

# Create folders in build dir
$srcFolders = Get-ChildItem -Path $srcPath -Recurse -Directory
foreach ($srcFolder in $srcFolders) {
    $buildFolder=($srcFolder.fullname).Replace($srcPath, $buildPath)
    if (-not(Test-Path $buildFolder)) {
        echo "mkdir: srcFolder.name"
        mkdir $buildFolder | Out-Null
    }
}

# Keep track of object files
$objFiles = @()

# Compile .c files into .o files
$srcFiles = Get-ChildItem -Path $srcPath *.c -Recurse
foreach ($srcFile in $srcFiles) {
    $buildFile=($srcFile.fullname).Replace($srcPath, $buildPath).Replace(".c",".o")
    $srcFileLastWriteTime=[datetime]$srcFile.LastWriteTime
    $buildFileLastWriteTime=$Null

    if (Test-Path $buildFile) {
        $buildFileLastWriteTime=[datetime]((Get-Item $buildFile).LastWriteTime)
    }

    if (($Null -eq $buildFileLastWriteTime) -or ($srcFileLastWriteTime -gt $buildFileLastWriteTime) -or $force) {
        $changed=$true
        echo ("compile: {0}" -f $srcFile.name)
        gcc -c $srcFile.fullname -o $buildFile
    }
    $objFiles += $buildFile
}

# Link object files into executable
if ($changed) {
    echo "link: out.exe"
    gcc $objFiles -o "$buildPath/out.exe"
} else {
    echo "Up to date (nothing to compile)"
}
echo ""