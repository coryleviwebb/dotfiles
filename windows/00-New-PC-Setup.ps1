#Requires -RunAsAdministrator

Set-ExecutionPolicy -ExecutionPolicy RemoteSigned

# Verify we have admin rights
$user = [Security.Principal.WindowsIdentity]::GetCurrent();
$isAdmin = (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)

if(-not $isAdmin){
    throw "Run this script as administrator so you do not get UAC prompts"
}

$hasWinget = Get-AppPackage -name 'Microsoft.DesktopAppInstaller'

if (-not $hasWinget) {
    throw "Winget not installed.  Download App Installer from the Microsoft Store (https://www.microsoft.com/en-us/p/app-installer/9nblggh4nns1#activetab=pivot:overviewtab)"
}

# Install winget if not installed
#Based on this gist: https://gist.github.com/crutkas/6c2096eae387e544bd05cde246f23901
# $hasPackageManager = Get-AppPackage -name 'Microsoft.DesktopAppInstaller'
# if (!$hasPackageManager -or [version]$hasPackageManager.Version -lt [version]"1.10.0.0") {
#     "Installing winget Dependencies"
#     Add-AppxPackage -Path 'https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx'

#     $releases_url = 'https://api.github.com/repos/microsoft/winget-cli/releases/latest'

#     [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
#     $releases = Invoke-RestMethod -uri $releases_url
#     $latestRelease = $releases.assets | Where-Object { $_.browser_download_url.EndsWith('msixbundle') } | Select-Object -First 1

#     Write-Output -InputObject "Installing winget from $($latestRelease.browser_download_url)"
#     Write-Output -InputObject "Computer might need to be restarted after installation"

#     Add-AppxPackage -Path $latestRelease.browser_download_url
# }
# else {
#     Write-Output -InputObject
# }



# Configure WinGet
Write-Output "Altering winget settings to allow installation from app store"

# winget config path from: https://github.com/microsoft/winget-cli/blob/master/doc/Settings.md#file-location
$settingsPath = "$env:LOCALAPPDATA\Packages\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe\LocalState\settings.json";
$settingsJson = 
@"
    {
        // For documentation on these settings, see: https://aka.ms/winget-settings
        "experimentalFeatures": {
          "experimentalMSStore": true,
        }
    }
"@;
$settingsJson | Out-File $settingsPath -Encoding utf8

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
    @{name = "LINQPad.LINQPad.6" },
    @{name = "Microsoft.AzureStorageExplorer" },
    # MS Office 365
    @{name = "Microsoft.MicrosoftOfficeHub_8wekyb3d8bbwe"; source = "msstore" },
    @{name = "Microsoft.PowerShell" },
    @{name = "Microsoft.PowerToys" },
    @{name = "Microsoft.VisualStudioCode" },
    @{name = "Microsoft.WindowsTerminal"; source = "msstore" }, 
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
        Write-host "Installing: $($app.name)" 
        if ($null -ne $app.source) {
            winget install --exact --silent "$($app.name)" --source $app.source --accept-package-agreements --accept-source-agreements
        }
        else {
            winget install --exact --silent "$($app.name)" --accept-package-agreements --accept-source-agreements
        }
    }
    else {
        Write-host "Skipping Install of $($app.name)" 
    }
}


# Get rid of crap
$appsToUninstall = @(
        @{name = "Microsoft.BingNews_8wekyb3d8bbwe"},
        @{name = "Microsoft.BingWeather_8wekyb3d8bbwe"},
        @{name = "Microsoft.Getstarted_8wekyb3d8bbwe"},
        @{name = "Microsoft.MicrosoftSolitaireCollection_8wekyb3d8bbwe"},
        @{name = "Microsoft.Todos_8wekyb3d8bbwe"},
        @{name = "Microsoft.WindowsSoundRecorder_8wekyb3d8bbwe"},
        @{name = "Microsoft.YourPhone_8wekyb3d8bbwe"},
        @{name = "Microsoft.ZuneMusic_8wekyb3d8bbwe"},
        @{name = "Microsoft.ZuneVideo_8wekyb3d8bbwe"}
);

# Uninstall crap
foreach ($app in $appsToUninstall) {
    $listApp = winget list --exact -q "$($app.name)"

    if ($listApp -like "*$($app.name)*"){
        Write-Output "winget uninstall `"$($app.name)`" --exact --accept-source-agreements"
        winget uninstall "$($app.name)" --exact --accept-source-agreements
    }
    else{
        Write-Output "Skipping removal of $($app.name) because it isn't installed"
    }
}

# Enable Windows Sandbox
Enable-WindowsOptionalFeature -FeatureName "Containers-DisposableClientVM" -All -Online -NoRestart
