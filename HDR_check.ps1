# Script modeled after:
# https://video.stackexchange.com/questions/22059/how-to-identify-hdr-video?newreg=b440570910994b4189e61beed6f5a4ac

Set-Location -Path $PSScriptRoot -PassThru
$SourceVideosFolder = ".\source_videos"
$Videos = Get-ChildItem $SourceVideosFolder

$out_file = New-Item -Path ".\" -Name "hdr_check_output.txt" -ItemType File -Force

foreach ($video in $Videos) {
    $ffprobe_output = & ffprobe -show_streams -v error $video.FullName
    
    if($LASTEXITCODE -ne 0){
        # Write-Output $ffprobe_res
        Add-Content $out_file $ffprobe_res
        Continue
    }

    # Write-Output ($video.Name + " :")
    Add-Content $out_file ($video.Name + " :")
    $colorspace = ""
    $colortransfer = ""
    $colorprimaries = ""
    foreach ($line in $ffprobe_output){
        if(!$line.StartsWith("color_")){Continue}

        if($line.StartsWith("color_space")){
            $colorspace = $line.Substring($line.IndexOf("=")+1)
            # Write-Output ("CSPACE: " + $colorspace)
            Add-Content $out_file ("CSPACE: " + $colorspace)
        }
        if($line.StartsWith("color_transfer")){
            $colortransfer = $line.Substring($line.IndexOf("=")+1)
            # Write-Output ("CTRANSFER: " + $colortransfer)
            Add-Content $out_file ("CTRANSFER: " + $colortransfer)
        }
        if($line.StartsWith("color_primaries")){
            $colorprimaries = $line.Substring($line.IndexOf("=")+1)
            # Write-Output ("CPRIMARIES: " + $colorprimaries)
            Add-Content $out_file ("CPRIMARIES: " + $colorprimaries)
        }
    }
    # Write-Output ""
    Add-Content $out_file ""

    $cspacematch = $colorspace -match "bt2020nc"
    $ctransfermatch = ($colortransfer -match "arib-std-b67") -or ($colortransfer -match "smpte2084")
    $cprimariesmatch = $colorprimaries -match "bt2020"
    if($cspacematch -and $ctransfermatch -and $cprimariesmatch){
        Write-Host ($video.Name + ": HDR") -ForegroundColor Green
    } else {
        Write-Host ($video.Name + ": SDR") -ForegroundColor Red
    }

    # TODO: get color_space, color_transfer, color_primaries from ffprobe output
}
