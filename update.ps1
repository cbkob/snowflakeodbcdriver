import-module au

$32releases = "https://sfc-repo.snowflakecomputing.com/odbc/win32/latest/index.html"
$64releases = "https://sfc-repo.snowflakecomputing.com/odbc/win64/latest/index.html"

function global:au_SearchReplace {
    @{
        ".\tools\chocolateyInstall.ps1" = @{
            "(?i)(^\s*url64\s*=\s*)('.*')"      = "`$1'$($Latest.URL64)'"
            "(?i)(^\s*url\s*=\s*)('.*')"        = "`$1'$($Latest.URL32)'"
            "(?i)(^\s*checksum\s*=\s*)('.*')"   = "`$1'$($Latest.Checksum32)'"
            "(?i)(^\s*checksum64\s*=\s*)('.*')" = "`$1'$($Latest.Checksum64)'"
        }
     }
}

function global:au_GetLatest {
	$re = '\.msi$'
	##Get 32 Bit Release
		
		$32downloaded_page = Invoke-WebRequest -Uri $32releases
		$32urlfile = $32downloaded_page.links | ? href -match $re |select -First 1 -expand href
		$32url = 'https://sfc-repo.snowflakecomputing.com/odbc/win32/latest/' + $32urlfile
	##Get 64 Bit Release
		$64downloaded_page = Invoke-WebRequest -Uri $64releases
		$64urlfile = $64downloaded_page.links | ? href -match $re |select -First 1 -expand href
		$64url = 'https://sfc-repo.snowflakecomputing.com/odbc/win64/latest/' + $64urlfile
	##Get Version
	$version = $64urlfile -split '[_-]|.msi' | Select -Last 1 -Skip 1
	
	@{ URL32 = $32url; URL64 = $64url; Version = $version}
}

update