# Check current keyboard and language
$currentKeyboard = (Get-WinUserLanguageList).InputMethodTips[0].KeyboardLayoutId
$currentLanguage = (Get-WinUserLanguageList).LanguageTag

# Check if en-GB keyboard and language are installed
$installedLanguages = (Get-WinUserLanguageList).LanguageTag
$installedKeyboards = (Get-WinUserLanguageList).InputMethodTips.KeyboardLayoutId

if (!($installedLanguages -contains "en-GB")) {
  Add-WinUserLanguageList -Language "en-GB" -Force
  Write-Output "en-GB language installed."
} else {
  Write-Output "en-GB language already installed."
}

if (!($installedKeyboards -contains 826)) {
  Write-Output "en-GB keyboard is not installed."
  Write-Output "Please install the en-GB keyboard and run the script again."
  break
} else {
  Write-Output "en-GB keyboard already installed."
}

# Remove all languages except en-GB
$languages = (Get-WinUserLanguageList).Where({ $_.LanguageTag -ne "en-GB" }).LanguageTag
foreach ($language in $languages) {
  Remove-WinUserLanguageList -LanguageList $language
}

# Change the keyboard to en-GB
if ($currentKeyboard -ne 826) {
  Set-WinUserLanguageList -LanguageList en-GB -Force
  Set-WinDefaultInputMethod -DefaultInputMethod "en-GB"
  Write-Output "Keyboard changed to en-GB."
} else {
  Write-Output "Keyboard already set to en-GB."
}

# Change the language to en-GB
if ($currentLanguage -ne "en-GB") {
  Set-WinUserLanguageList -LanguageList en-GB -Force
  Write-Output "Language changed to en-GB."
} else {
  Write-Output "Language already set to en-GB."
}
