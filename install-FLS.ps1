# Snooping around? That's a good thing!
# This script just changes a bunch of "d" file directories to "de-index" some files as the game uses said d files as a lookup of sorts.
# Redistributing the d files was becoming problematic, so this script was made to make things easier to maintain.

$dlist = @{
    "lzwp1onbeaejbkCh" = @("gauge_00.dds","gauge_01.dds","gauge_02.dds","demo_logo00.dds","sys_combo00.pat")
    "oMtaqooqotvvonnpwmq" = @("mainmenu_bg00.pat","BtlCharaTbl_str.ini","network00.pat","csel00.pat","cmddef_name.ini")
    "rcwWiiqjmxpmojs" = @("stringfile.csv")
    "fmjisrkojmp" = @("BgList.txt","BgList_str.txt")
    "hexeojmpimrjs" = @("effect.txt")
}

foreach ($entry in $dlist.GetEnumerator()) {
    $dFile = [System.IO.Path]::Combine((Get-Location).Path, "d", $entry.Key)
    if (-not (Test-Path $dFile)) {
        Write-Warning "$dFile missing, is your game install OK?"
        continue
    }
    try {
        $bytes = [System.IO.File]::ReadAllBytes($dFile)
        $changesMade = $false
        foreach ($str in $entry.Value) {
            $oldBytes = [Text.Encoding]::ASCII.GetBytes($str)
            $flsStr   = [IO.Path]::GetFileNameWithoutExtension($str) + ".FLS"
            $newBytes = [Text.Encoding]::ASCII.GetBytes($flsStr)
            for ($i = 0; $i -le $bytes.Length - $oldBytes.Length; $i++) {
                $match = $true
                for ($j = 0; $j -lt $oldBytes.Length; $j++) {
                    if ($bytes[$i + $j] -ne $oldBytes[$j]) {
                        $match = $false
                        break
                    }
                }
                if ($match) {
                    for ($j = 0; $j -lt $newBytes.Length; $j++) {
                        $bytes[$i + $j] = $newBytes[$j]
                    }
                    $changesMade = $true
                }
            }
        }
        if ($changesMade) {
            [System.IO.File]::WriteAllBytes($dFile, $bytes)
            Write-Host "Done: $dFile" -ForegroundColor Cyan
        } else {
            Write-Host "Found nothing to do in $dFile"
        }
    }
    catch {
        Write-Error "Issue with $dFile : $($_.Exception.Message)"
    }
}

Write-Host "If there are no errors, you're ready to play! Use Steam's Verify Integrity feature to return to vanilla."
pause
