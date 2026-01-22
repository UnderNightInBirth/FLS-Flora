# This is for WINE/Proton users running Linux-based systems.
# You're probably a power user at this point so you could try to manually make links to these files,
# but if you want this script to be automated for you, you need to get PowerShell for Linux.
# https://learn.microsoft.com/en-us/powershell/scripting/install/install-powershell-on-linux

$dlist = @{
	"lzwp1onbeaejbkCh" = @("gauge_00.dds","gauge_01.dds","gauge_02.dds","demo_logo00.dds","sys_combo00.pat","gauge_chr019.dds")
	"oMtaqooqotvvonnpwmq" = @("mainmenu_bg00.pat","BtlCharaTbl_str.ini","network00.pat","csel00.pat","cmddef_name.ini")
	"rcwWiiqjmxpmojs" = @("stringfile.csv")
	"fmjisrkojmp" = @("BgList.txt","BgList_str.txt")
	"hexeojmpimrjs" = @("effect.txt")
}

# Additionally, we're gonna make symlinks/junctions for Network characters to display.
function datajunc {
	param (
		[string]$Jpath,
		[string]$Target
	)

	if (Test-Path $Jpath) {
		Write-Host "link already exists: $Jpath"
		return
	}

	Write-Host "linking: $Jpath -> $Target"
	New-Item -Path $Jpath -ItemType SymbolicLink -Value $Target
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

$chrdata = Join-Path (Get-Location) "data"
$chr = @{
	"chr027" = "Ries"
	"chr028" = "Ingrid"
	"chr029" = "Ryu"
	"chr030" = "Dantes"
	"chr031" = "Ako"
	"chr032" = "Hammer"
	"chr039" = "HydEX"
}

foreach ($junc in $chr.GetEnumerator()) {
	$Jpath  = Join-Path $chrdata $junc.Key
	$Target = Join-Path $chrdata $junc.Value
	datajunc -Jpath $Jpath -Target $Target
}

$avater    = Join-Path (Get-Location) "grpdat\Network\new\avater"
$avadata   = Join-Path $avater "data"
$gamedata  = Join-Path (Get-Location) "data"

datajunc -Jpath $avadata -Target $gamedata

Write-Host "If there are no errors, you're ready to play! Use Steam's Verify Integrity feature to return to vanilla."
pause
