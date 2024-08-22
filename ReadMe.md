# MM-Scripts

## Installation

Ensure that git is installed on your system.  If you need help installing you can reference git's [documentation](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git).  If you clone this repository to a location that is in your [PSModulePath](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_psmodulepath?view=powershell-7.4) variable all Modules will be available for [Auto Loading](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_modules?view=powershell-7.4#module-autoloading).

1. Navigate to your desired directory

    ```powershell
    Set-Location -Path 'C:\path\to\your\directory'
    ```

2. Clone the respository

    ```powershell
    git clone https://github.com/Elkhunder/MM-Scripts.git
    ```

3. Clone repository to a location in the PSModulePath

    ```powershell
    $psModulePath = $env:PsModulePath.split(';')[0]
    Set-Location -Path $psModulePath
    git clone https://github.com/Elkhunder/MM-Scripts.git
    ```

## Update

1. Navigate to directory

    ```powershell
    Set-Location -Path 'C:\path\to\your\directory'`
    ```

2. Fetch the updates

    ```powershell
    git fetch
    git pull
    ```

## Usage

- **Get-WindowsVersion**

    _This function gathers information about the Windows operating system and build versions from specified computers. It allows users to provide a list of computer names directly, or through a file. The function handles local and remote computer queries, supports secondary credentials for remote access, and offers options to output results either to a file or the console._

  **Parameters**
  - ComputerName
    - Description: Specifies a list of computer names that the script will operate on. This parameter accepts an array of strings, allowing you to provide multiple computer names to be processed.
    - Type: [string[]](https://learn.microsoft.com/en-us/powershell/scripting/lang-spec/chapter-04?view=powershell-7.4#431-strings): An array of string objects
  - Credential
    - Description: Provides the credentials used for authentication when connecting to remote computers. This parameter accepts a PSCredential object, which typically includes a username and password.  See Microsoft's docs for [Get-Credential](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.security/get-credential?view=powershell-7.4) for more info.  If you attempt to access a remote device without providing a credential, you will be prompted to enter one.
    - Type: [PSCredential](https://learn.microsoft.com/en-us/dotnet/api/system.management.automation.pscredential?view=powershellsdk-7.4.0): Securely stores a username and password
  - UseInFile
    - Description: Indicates that a file containing the list of computer names should be used instead of specifying them directly. Prompts the user to select a file if this switch is used.
    - Type: [Switch](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_functions_advanced_parameters?view=powershell-7.4#switch-parameters): Boolean flag that is either true when specified or false when omitted
  - UseOutFile
    - Type: [Switch](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_functions_advanced_parameters?view=powershell-7.4#switch-parameters): Boolean flag that is either true when specified or false when omitted

  **Examples**
  - Specify Computer Names

    ```powershell
    Get-WindowsVersion -ComputerName 'Computer1','Computer2','Computer3'
    ```

  - Use a File for Computer Names

    ```powershell
    Get-WindowsVersion -UseInFile
    ```

  - Save the Results to a File

    ```powershell
    Get-WindowsVersion -ComputerName 'Computer1' -UseOutFile
    ```

  - Use a File for Computer Names and Save the Output

    ```powershell
    Get-WindowsVersion -UseInFile -UseOutFile
    ```

  - Get information for localhost

    ```powershell
    Get-WindowsVersion -ComputerName 'localhost'
    ```
