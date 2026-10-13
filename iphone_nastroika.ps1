# Nastraivaet web-versiyu ZholTap dlya iPhone: nazvanie pod ikonkoj i cvet.
# Zapuskaetsya iz zapustit_iphone.bat, otdelno zapuskat ne nuzhno.
$name = -join ([char]0x0416, [char]0x043E, [char]0x043B, [char]0x0422, [char]0x0430, [char]0x043F)  # ZholTap kirillicej
$web = Join-Path $PSScriptRoot 'zholtap_web\web'
$utf8 = New-Object System.Text.UTF8Encoding($false)

$f = Join-Path $web 'index.html'
$s = [IO.File]::ReadAllText($f, $utf8)
$s = $s.Replace('content="zholtap"', 'content="' + $name + '"')
$s = $s.Replace('<title>zholtap</title>', '<title>' + $name + '</title>')
if ($s -notmatch 'theme-color') {
  $s = $s.Replace('</head>', '  <meta name="theme-color" content="#009688">' + "`n" + '</head>')
}
[IO.File]::WriteAllText($f, $s, $utf8)

$f = Join-Path $web 'manifest.json'
$s = [IO.File]::ReadAllText($f, $utf8)
$s = $s.Replace('"zholtap"', '"' + $name + '"').Replace('#0175C2', '#009688')
[IO.File]::WriteAllText($f, $s, $utf8)
