# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.0.1] - 2014-05-31

### Added
-Import custom modules
-Set-Location to Script Path
-obscuring and encrypting bios password
-Path parameter for New-ElevatedPrompt Function
-Credential Request to Map Network drive under Primary Level-2 Account, without this the script is not available on the share drive.
-New-PSDrive to map the shared2 network drive "\\corefs.med.umich.edu\shared2"
-Removing bios password from hp computers
-converting bios password to plain text
-Removing plain text bios password variable
-Split computers string by commas or spaces

### Changed
-Variables $Computers, $ScriptPath, $CustomFunctionPath were all changed to args which are being passed in as arguments in the invoke-command in the launcher.  $args[0] holds the command path and name, $args[1] hold the computer names and the scope, $args[2] holds the custom function name and path
### Removed
-Custom Functions, all custom functions were moved to the launcher

### Fixed