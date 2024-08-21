function Install-LanguagePacks {
  param (
    [Parameter(Mandatory)]
    [string]$Language,
    [Parameter(Mandatory)]
    [string]$LanguageTag
  )
  Write-Host "Installing $Language Language Packs..."

  $LanguagePacks = [System.Collections.ArrayList]::new((Get-WindowsCapability -Online | Where-Object Name -like "Language*~$LanguageTag*").name)
  Foreach ($LanguagePack in $LanguagePacks){
      Write-Host "Installing $LanguagePack..."
      Add-WindowsCapability -Online -Name $LanguagePack
      Write-Host "Installing $LanguagePack... complete"
    }

  Get-WindowsCapability -Online | Where-Object State -eq "Installed"
  Where-Object Name -like "Language*~$LanguageTag*"
  Write-Host "Installing $Language Language Packs...Complete"

  Write-Host "Getting current users language preferences..."
  # Get current user language list
  $UserLanguageList = Get-WinUserLanguageList
  Write-Host "Adding $Language to current users language preferences..."
  # Add target language to user language list
  $UserLanguageList.Add($LanguageTag)
  # Set user language list
  Write-Host "Setting current users language preferences..."
  Set-WinUserLanguageList -Force -LanguageList $UserLanguageList
  Write-Host "Setting current users language preferences...Complete"
  Write-Host "Press any key to continue..."
}

$Language = (Read-Host -Prompt "What language would you like to install").ToLower();

Switch ($Language)
{
  "spanish"{
    $LanguageTag = "es-MX"

    Install-LanguagePacks -Language $Language -LanguageTag $LanguageTag
    break
  }
  "french" {
    $LanguageTag = "fr-FR"

    Install-LanguagePacks -Language $Language -LanguageTag $LanguageTag
    break
  }
  "german" {
    $LanguageTag = "de-DE"
    Install-LanguagePacks -Language $Language -LanguageTag $LanguageTag
    break
  }
  "italian" {
    $LanguageTag = "it-IT"
    Install-LanguagePacks -Language $Language -LanguageTag $LanguageTag
    break
  }
  "portuguese" {
    $LanguageTag = "pt-PT"

    Install-LanguagePacks -Language $Language -LanguageTag $LanguageTag
    break
  }
  "russian" {
    $LanguageTag = "ru-RU"

    Install-LanguagePacks -Language $Language -LanguageTag $LanguageTag
    break
  }
  "chinese" {
    $LanguageTag = "zh-CN"

    Install-LanguagePacks -Language $Language -LanguageTag $LanguageTag
    break
  }
  "japanese" {
    $LanguageTag = "ja-JP"

    Install-LanguagePacks -Language $Language -LanguageTag $LanguageTag
    break
  }
  "korean" {
    $LanguageTag = "ko-KR"

    Install-LanguagePacks -Language $Language -LanguageTag $LanguageTag
    break
  }
  "english" {
    $LanguageTag = "en-US"

    Install-LanguagePacks -Language $Language -LanguageTag $LanguageTag
    break
  }
  default {
    Write-Host "Invalid Language Selection"
    break
  }
}

