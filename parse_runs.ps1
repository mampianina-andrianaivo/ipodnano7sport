# parse_runs.ps1 (Version data.js pour HUD)
# -------------------------------------------------------------------------
$outputFile = "data.js" # Changement ici pour le HUD
$targetPath = "iPod_Control\Device\Trainer\Workouts\Empeds\nikeinternal\latest"
$allWorkouts = @()

function Convert-PaceToDecimal($paceStr) {
    if ($paceStr -match "(\d+)'(\d+)") {
        return [double]$Matches[1] + ([double]$Matches[2] / 60)
    }
    return 0
}

Write-Host "Recherche de l'iPod sur les lecteurs disponibles..." -ForegroundColor Cyan

# Scanner tous les lecteurs de A: à Z:
$drives = Get-PSDrive -PSProvider FileSystem
foreach ($drive in $drives) {
    # On utilise Join-Path pour la robustesse
    $fullPath = Join-Path -Path $drive.Root -ChildPath $targetPath
    
    # On utilise [System.IO.Directory]::Exists pour bypasser les restrictions de dossiers cachés
    if ([System.IO.Directory]::Exists($fullPath)) {
        Write-Host "iPod detecte sur $($drive.Name):" -ForegroundColor Green
        
        # -Force est crucial car les XML sont souvent cachés sur iPod
        $files = Get-ChildItem -Path $fullPath -Filter *.xml -Force

        foreach ($file in $files) {
            try {
                [xml]$xml = Get-Content $file.FullName -Raw -ErrorAction Stop
                $summary = $xml.sportsData.runSummary
                
                # 1. Extraction Extended Data (Vitesse)
                $extDataNode = $xml.sportsData.extendedDataList.extendedData | Where-Object { $_.dataType -eq "distance" }
                $extDistArray = @()
                if ($extDataNode) {
                    $extDistArray = $extDataNode.InnerText.Split(',') | ForEach-Object { [double]$_.Trim() }
                }

                # 2. Extraction des Splits (KM)
                $prevDur = 0
                $kmSplits = @()
                $snapList = $xml.sportsData.snapShotList | Where-Object { $_.snapShotType -eq "kmSplit" }
                
                if ($snapList) {
                    foreach ($snap in $snapList.snapShot) {
                        $currDur = [double]$snap.duration / 1000
                        $splitDur = $currDur - $prevDur
                        $kmSplits += [PSCustomObject]@{
                            num    = [int]$snap.distance
                            pace   = if ($splitDur -gt 0) { ($splitDur / 60) } else { 0 }
                            durSec = $splitDur
                        }
                        $prevDur = $currDur
                    }
                }

                # 3. Dernier split partiel
                $totalDist = [double]$summary.distance.InnerText
                $lastSplitNum = if ($kmSplits) { $kmSplits[-1].num } else { 0 }
                if ($totalDist -gt $lastSplitNum) {
                    $remainDist = $totalDist - $lastSplitNum
                    $totalDur = [double]$summary.duration / 1000
                    $remainDur = $totalDur - $prevDur
                    $kmSplits += [PSCustomObject]@{
                        num           = $lastSplitNum + 1
                        pace          = if ($remainDist -gt 0) { ($remainDur / 60) / $remainDist } else { 0 }
                        durSec        = $remainDur
                        partial       = $true
                        partialMeters = [math]::Round($remainDist * 1000)
                    }
                }

                # 4. Objet Final
                $workoutObj = [PSCustomObject]@{
                    date        = $summary.time
                    duration    = [double]$summary.duration / 1000
                    durationStr = $summary.durationString
                    distance    = $totalDist
                    pace        = Convert-PaceToDecimal $summary.pace
                    calories    = [int]$summary.calories
                    steps       = [int]$summary.stepCounts.runEnd
                    extDist     = $extDistArray
                    kmSplits    = $kmSplits
                }
                $allWorkouts += $workoutObj
            } catch {
                Write-Warning "Erreur fichier : $($file.Name)"
            }
        }
    }
}

if ($allWorkouts.Count -gt 0) {
    # On transforme l'objet en JSON puis on l'encapsule dans une variable JS
    $json = $allWorkouts | ConvertTo-Json -Depth 10
    $finalContent = "const runsData = $json;"
    
    # Sortie en UTF8 sans BOM pour une lecture propre par le navigateur
    $finalContent | Out-File $outputFile -Encoding utf8
    Write-Host "Termine : $outputFile genere ($($allWorkouts.Count) runs)." -ForegroundColor Green
} else {
    Write-Host "ERREUR : Aucun iPod ou fichier XML trouve." -ForegroundColor Red
}