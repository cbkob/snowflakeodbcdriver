$ErrorActionPreference = 'Stop';
$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$additionalArgs = ''
$CommonLogPath = $true
$packageParameters = Get-PackageParameters
# see if any parameters were passed
if ($packageParameters['CommonLogPath']) { $CommonLogPath = $packageParameters['CommonLogPath'] }


$packageArgs = @{
	packageName='snowflakeodbcdriver'
	fileType='MSI'
	url='https://sfc-repo.snowflakecomputing.com/odbc/win32/latest/snowflake32_odbc-3.4.0.msi'
	url64='https://sfc-repo.snowflakecomputing.com/odbc/win64/latest/snowflake64_odbc-3.4.0.msi' 
	checksum='de36944bc8bafa8af423f6314ae84abab7511a9b2c65ca7509d54eed30be49ff'
	checksum64='fc71cbe2b9d9ad6485203045ebbdcd34a1db0bcf58f683372d7085febf6750d9'
	checksumType32='sha256'
	checksumType64='sha256'
	silentArgs="/qn /l*v `"$($env:TEMP)\snowflakeodbcdriver.$($env:chocolateyPackageVersion).MsiInstall.log`""
	validExitCodes=@(0, 3010, 1641)
	softwareName='snowflakeodbcdriver*'
}

Install-ChocolateyPackage @packageArgs

try {
	if($CommonLogPath -eq $true) {
		# Define the log directory path
		$logDirPath = "$env:SystemDrive\Program Files\Snowflake ODBC Driver\log"
		# Create the directory if it does not exist
		if(-NOT (Test-Path $logDirPath)) {
			New-Item -ItemType directory -Path $logDirPath
		}

		# Retrieve the ACL for the directory
		$acl = Get-Acl $logDirPath
		# Define the access rule
		$AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("BUILTIN\Users","FullControl, Synchronize","ContainerInherit,ObjectInherit", "None","Allow")
		# Set the access rule to the ACL
		$acl.SetAccessRule($AccessRule)
		# Update the ACL for the directory
		$acl | Set-Acl $logDirPath

		# Set registry properties for the Snowflake Driver
		$regPath = "HKLM:\Software\Snowflake\Driver"
		Set-ItemProperty -Path $regPath -Name "LogPath" -Value $logDirPath
		Set-ItemProperty -Path $regPath -Name "EnablePidLogFileNames" -Value "true"
	}
} catch {
    Write-Output "An error occurred: $_"
}

