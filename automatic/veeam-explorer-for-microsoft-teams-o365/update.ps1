Import-Module au

$releases = 'https://forums.veeam.com/veeam-backup-for-microsoft-office-365-f47/current-version-t39185.html'

function global:au_SearchReplace {
  @{
    'tools\chocolateyInstall.ps1' = @{
      "(^[$]url\s*=\s*)('.*')"          = "`$1'$($Latest.URL32)'"
      "(^[$]checksum\s*=\s*)('.*')"     = "`$1'$($Latest.Checksum32)'"
      "(^[$]checksumType\s*=\s*)('.*')" = "`$1'$($Latest.ChecksumType32)'"
      "(^[$]version\s*=\s*)('.*')"      = "`$1'$($Latest.version)'"

    }
    "$($Latest.PackageName).nuspec" = @{
      "(^.+version=`")(\[.*\])(`".+$)"                   = "`$1[$($Latest.Version)]`$3"
      "(?i)(^\s*\<releaseNotes\>).*(\<\/releaseNotes\>)" = "`${1}$($Latest.ReleaseNotes)`${2}"
    }
  }
}

function global:au_GetLatest {
    $download_page = Invoke-WebRequest -Uri $releases -UseBasicParsing -DisableKeepAlive

    $reLatestbuild = "Current version is ([0-9]+\.[0-9]+\.[0-9]+(?:\.[0-9]+)(?:\.[0-9]+)?)( \((Update.*)\))?"
    $download_page.RawContent -imatch $reLatestbuild
    $version = $Matches[1]

    $isoVersion = $version

    if($Matches.ContainsKey(3)) {
        $updateVersion = $Matches[3] -replace " "
        $isoVersion = "$($isoVersion).$updateVersion"
    }

    $filename = "VeeamBackupOffice365_$($isoVersion).zip"
    $url = "https://download2.veeam.com/$($filename)"
    # -Replace ".iso", "_.iso"

    if($isoVersion -match '5.0.0.1063') {
      $url = "https://download2.veeam.com/VBO/v5/GA/VeeamBackupOffice365_5.0.0.1063.zip"
    }

    $ReleaseNotes = $download_page.Links | Where-Object href -match "release_notes" | Select-Object -First 1 -ExpandProperty href

    return @{
        Filename = $filename
        URL32 = $url
        Version = $version
        ReleaseNotes = $ReleaseNotes
    }
}

if ($MyInvocation.InvocationName -ne '.') {
    update -ChecksumFor 32
}
