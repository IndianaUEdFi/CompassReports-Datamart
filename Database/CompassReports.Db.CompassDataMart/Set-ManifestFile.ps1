Param(
    [String]$BaseFolder = ".\PostDeployment\ETL"
)

$resolvedBase = Resolve-Path $BaseFolder
push-location $resolvedBase
get-childitem -Path $resolvedBase -Filter *.sql -Recurse -Exclude manifest.sql | resolve-path -relative | %{":r $_"} | out-file .\Manifest.sql -Encoding utf8
pop-location
