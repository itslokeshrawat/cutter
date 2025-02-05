$dist = $args[0]
$cmake_opts = $args[1]
$python = Split-Path((Get-Command python.exe).Path)

if (-not (Test-Path -Path 'rz_libyara' -PathType Container)) {
    git clone https://github.com/rizinorg/rz-libyara.git --depth 1 rz_libyara
    git -C rz_libyara submodule init
    git -C rz_libyara submodule update
}
cd rz_libyara
& meson.exe --buildtype=release --prefix=$dist build
ninja -C build install
$pathdll = "$dist/lib/plugins/rz_yara.dll"
if(![System.IO.File]::Exists($pathdll)) {
    type build/meson-logs/meson-log.txt
    ls "$dist/lib/plugins/"
    throw (New-Object System.IO.FileNotFoundException("File not found: $pathdll", $pathdll))
}
Remove-Item -Recurse -Force $dist/lib/plugins/rz_yara.lib

cd cutter-plugin
mkdir build
cd build
cmake -G Ninja -DCMAKE_BUILD_TYPE=Release -DRIZIN_INSTALL_PLUGDIR="../build" -DCMAKE_INSTALL_PREFIX="$dist" $cmake_opts ..
ninja
ninja install
