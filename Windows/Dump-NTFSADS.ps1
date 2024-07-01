` List NTFS ADS data recursively

Get-ChildItem -Recurse | Get-Item -Stream * | ? {$_.Stream -ne ':$DATA'} | % {
  Write-Host "`n`n$($_.FileName):$($_.Stream)" -NoNewline
  Get-Content -LiteralPath $_.FileName -Stream $_.Stream -Raw | Format-Hex
}
