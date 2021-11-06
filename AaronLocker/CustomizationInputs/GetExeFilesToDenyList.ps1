<#
    .SYNOPSIS
    Script used by Create-Policies.ps1 to identify EXE files that should be disallowed by AppLocker for non-admin use. Can be edited if necessary.

    .DESCRIPTION
    This script outputs a list of file paths under %windir% that need to be specifically disallowed by AllowListing rules.
    The list of files is consumed by Create-Policies.ps1, which builds the necessary AppLocker rules to block them.
    You can edit this file as needed for your environment, although it is recommended that none of the programs
    identified in this script be removed.

    Note: the solution also blocks the loading of PowerShell v2 modules - these blocks are hardcoded into the base XML file. This module
    as currently designed can block only EXE files, not DLLs.
    http://www.leeholmes.com/blog/2017/03/17/detecting-and-preventing-powershell-downgrade-attacks/
#>

# --------------------------------------------------------------------------------
# Files used to bypass AllowListing:

# Find the multiple instances of .NET executables that have been identified as AllowList bypasses.
# Create-Policies.ps1 will remove redundant information.
$dotnetProgramsToDenyList =
"AddInProcess.exe",
"AddInProcess32.exe",
"AddInUtil.exe",
"aspnet_compiler.exe",
"IEExec.exe",
"InstallUtil.exe",
"Microsoft.Build.dll",
"Microsoft.Build.Framework.dll",
"Microsoft.Workflow.Compiler.exe",
"MSBuild.exe",
"RegAsm.exe",
"RegSvcs.exe",
"System.Management.Automation.dll"
$dotnetProgramsToDenyList | ForEach-Object {
    Get-ChildItem -Path "$env:windir\Microsoft.NET" -Recurse -Include $_ | ForEach-Object { $_.FullName }
}

# Additional Microsoft recommended executables to deny
"Microsoft.Build.Framework.dll", "System.Management.Automation.dll" | ForEach-Object {
    Get-ChildItem -Path "$Env:SystemRoot\assembly\GAC_MSIL" -Recurse -Include $_ | ForEach-Object { $_.FullName }
}

# Additional Microsoft recommended executables to deny
"bash.exe", "wsl.exe", "wslconfig.exe", "wslhost.exe", "system.management.automation.dll", "lxssmanager.dll", "cscript.exe", "wscript.exe" | `
    ForEach-Object {
    Get-ChildItem -Path "$Env:SystemRoot\servicing\LCU" -Recurse -Include $_ | ForEach-Object { $_.FullName }
}

"$env:windir\System32\mshta.exe"
"$env:windir\System32\PresentationHost.exe"
"$env:windir\System32\wbem\WMIC.exe"
# Note: also need Code Integrity rules to block other bypasses

# --------------------------------------------------------------------------------
# Files used by ransomware / lolbins
"$env:windir\System32\cipher.exe"
"$env:windir\System32\certreq.exe"
"$env:windir\System32\certutil.exe"
"$env:windir\System32\Cmdl32.exe"

# --------------------------------------------------------------------------------
# Block common credential exposure risk (also need to disable GUI option via registry, and SecondaryLogon service)
"$env:windir\System32\runas.exe"

# Block Scripting host
"$env:windir\System32\cscript.exe"
"$env:windir\System32\wscript.exe"
