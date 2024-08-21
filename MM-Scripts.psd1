@{
    ModuleVersion = '1.0.0'
    GUID = '08cb5fbe-8480-43b0-ac5a-7355f226f772'
    Author = 'Jonathon Sissom'
    Description = 'A module that loads custom modules from a specific directory.'

    # # List of nested modules
    # NestedModules = @(
    #     "$PSScriptRoot\CustomModules\Get-WindowsVersion\Get-WindowsVersion.psm1"
    #     # Add more modules as needed
    # )

    ModuleList = @(
        "Get-WindowsVersion"
    )
}
