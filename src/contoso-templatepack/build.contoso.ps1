$scriptDir = split-path -parent $MyInvocation.MyCommand.Definition
$srcDir = (Join-Path -path $scriptDir src)
$contentFolder = Join-Path $srcDir Content

$templateProjFile = Join-Path $scriptDir ContosoWebTemplates.csproj
$outputpath = Join-Path $scriptDir nupkg\
$intoutputpath = join-path $outputpath bin\

function Reset-Tempaltes(){
    dotnet new --uninstall $contentFolder
    dotnet new --uninstall sayedha.templates
    dotnet new --debug:reinit
    dotnet new --debug:rebuildcache
}

function Clean(){
    [cmdletbinding()]
    param(
        [string]$rootFolder = $scriptDir
    )
    process{
        'clean started, rootFolder "{0}"' -f $rootFolder | write-host
        # delete folders that should not be included in the nuget package
        Get-ChildItem -path $scriptDir -include bin,obj,nupkg,.vs -Recurse -Directory | Select-Object -ExpandProperty FullName | Remove-item -recurse
        if(Test-Path $outputpath){
            Remove-Item -LiteralPath $outputpath -Recurse -Force
        }
    }
}

function Install-Template(){
    [cmdletbinding()]
    param()
    process{
        # build the package
        dotnet pack $templateProjFile -p:OutputPath=$outputpath -p:BaseIntermediateOutputPath=$intoutputpath
        [string[]]$nupkgPath = Get-ChildItem -Path $outputpath *.nupkg
        if(-not ($nupkgPath) -or $nupkgPath.Count -lt 1 || -not ($nupkgPath[0])){
            'No .nupkg file found in folder "$outputpath"' | Write-Error
            return
        }
        elseif ($nupkgPath.Count -gt 1){
            'More than one .nupkg file found in folder "$outputpath"' | Write-Error
            return
        }

        dotnet new install ('{0}' -f (Get-Item $nupkgPath[0]|Select-Object -ExpandProperty FullName))
    }
}

if(-not (test-path $templateProjFile)){
    throw 'Template proj file not found at "' + $templateProjFile + '"'
}

Reset-Templates
Clean

Install-Template