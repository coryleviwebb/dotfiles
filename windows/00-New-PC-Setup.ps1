#Requires -RunAsAdministrator

Set-ExecutionPolicy -ExecutionPolicy RemoteSigned
$InformationPreference = "Continue"
$VerbosePreference = "Continue"

$apps = @(
    @{name = "Adobe.Acrobat.Reader.64-bit" },
    @{name = "AgileBits.1Password" },
    @{name = "Amazon.Kindle" },
    @{name = "Anki.Anki" },
    @{name = "Apple.iTunes" },
    @{name = "Axosoft.GitKraken" },
    @{name = "CodecGuide.K-LiteCodecPack.Full" },
    @{name = "CrystalRich.LockHunter" },
    @{name = "Discord.Discord" },
    @{name = "Docker.DockerDesktop" },
    # Removing Git for the moment because there are custom settings I check off in the installer
    # @{name = "Git.Git" },
    @{name = "Google.Chrome" },
    @{name = "GPSoftware.DirectoryOpus" },
    @{name = "HandBrake.HandBrake" },
    @{name = "Implbits.HashTab" },
    @{name = "LINQPad.LINQPad.7" },
    @{name = "Microsoft.AzureStorageExplorer" },
    # MS Office 365
    @{name = "Microsoft.Office" },
    # @{name = "Microsoft.PowerShell" },
    @{name = "Microsoft.PowerToys" },
    # @{name = "Microsoft.VisualStudioCode" },
    # @{name = "Microsoft.WindowsTerminal"; source = "msstore" }, 
    @{name = "Microsoft.SQLServerManagementStudio" },    
    @{name = "Netflix"; source = "msstore" }, 
    @{name = "Notion.Notion" },
    @{name = "Plex.Plex" },
    @{name = "PointPlanck.FileBot" },
    @{name = "PrivateInternetAccess.PrivateInternetAccess" },
    @{name = "qBittorrent.qBittorrent" },
    @{name = "Sysinternals Suite"; source = "msstore" }, 
    @{name = "Telerik.Fiddler" },
    @{name = "TeamViewer.TeamViewer" },
    @{name = "Toggl.TogglDesktop" },
    @{name = "Valve.Steam" },
    @{name = "VMware.WorkstationPro" },
    @{name = "WinDirStat.WinDirStat" },
    @{name = "WinMerge.WinMerge" },
    @{name = "Zoom.Zoom" }
);

# Install all apps
foreach ($app in $apps) {
    $listApp = winget list --exact -q $app.name
    
    if (![String]::Join("", $listApp).Contains($app.name)) {
        Write-Verbose -MessageData "Installing: $($app.name)" 
        if ($null -ne $app.source) {
            winget install --exact --silent "$($app.name)" --source $app.source --accept-package-agreements --accept-source-agreements
        }
        else {
            winget install --exact --silent "$($app.name)" --accept-package-agreements --accept-source-agreements
        }
    }
    else {
        Write-Verbose "Skipping Install of $($app.name) because it is already installed" 
    }
}


# Get rid of crap
$appsToUninstall = @(
    @{name = "Microsoft.BingNews_8wekyb3d8bbwe"},
    @{name = "Microsoft.BingWeather_8wekyb3d8bbwe"},
    @{name = "Microsoft.GamingApp_8wekyb3d8bbwe"},
    @{name = "Microsoft.Getstarted_8wekyb3d8bbwe"},
    @{name = "Microsoft.MicrosoftSolitaireCollection_8wekyb3d8bbwe"},
    @{name = "Microsoft.Todos_8wekyb3d8bbwe"},
    @{name = "Microsoft.WindowsSoundRecorder_8wekyb3d8bbwe"},
    @{name = "Microsoft.Xbox.TCUI_8wekyb3d8bbwe"},
    @{name = "Microsoft.XboxGameOverlay_8wekyb3d8bbwe"},
    @{name = "Microsoft.XboxGamingOverlay_8wekyb3d8bbwe"},
    @{name = "Microsoft.XboxIdentityProvider_8wekyb3d8bbwe"},
    @{name = "Microsoft.XboxSpeechToTextOverlay_8wekyb3d8bbwe"},
    @{name = "Microsoft.YourPhone_8wekyb3d8bbwe"},
    @{name = "Microsoft.ZuneMusic_8wekyb3d8bbwe"},
    @{name = "Microsoft.ZuneVideo_8wekyb3d8bbwe"},
    @{name = "SpotifyAB.SpotifyMusic_zpdnekdrzrea0"}
);

# Uninstall crap
foreach ($app in $appsToUninstall) {
    $listApp = winget list --exact -q "$($app.name)"

    if ($listApp -like "*$($app.name)*"){
        Write-Output "winget uninstall `"$($app.name)`" --exact --accept-source-agreements"
        winget uninstall "$($app.name)" --exact --accept-source-agreements
    }
    else{
        Write-Information "Skipping removal of $($app.name) because it isn't installed"
    }
}

# Enable Windows Sandbox
Write-Verbose -Message "Enabling: Windows Sandbox"
Enable-WindowsOptionalFeature -FeatureName "Containers-DisposableClientVM" -All -Online -NoRestart

# Explorer: Show file extensions by default: Hide: 1, Show: 0
Write-Verbose -Message "Enabling: Show file extensions by default"
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "HideFileExt" 0

# Opt-In to Microsoft Update
Write-Verbose -Message "Enabling: Opt-In to Microsoft Update"
$MU = New-Object -ComObject Microsoft.Update.ServiceManager -Strict
$MU.AddService2("7971f918-a847-4430-9279-4a52d1efe18d",7,"") | Out-Null
Remove-Variable MU
