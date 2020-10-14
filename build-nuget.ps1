$scriptDir = split-path -parent $MyInvocation.MyCommand.Definition
$srcDir = ((Join-Path -path $scriptDir src)|get-fullpath)
# nuget.exe needs to be on the path or aliased
function Remove-Folder{
    [cmdletbinding()]
    param(
        [Parameter(ValueFromPipeline=$true)]
        [string[]]$path
    )
    process{
        if(-not $path -or ($path.Length -le 0)){
            return
        }
        foreach ($p in $path) {
            if((test-path $p) -and -not ([string]::IsNullOrEmpty($p))){
                'Deleting folder "{0}"' -f $p | Write-Host
                Remove-Item -Path $p -recurse -Force
            }
        }
    }
}
function Reset-Templates{
    [cmdletbinding()]
    param()
    process{
        'resetting dotnet new templates' | Write-host
        push-location C:\Users\sayedha\.templateengine
        get-childitem -path C:\Users\sayedha\.templateengine -directory | remove-item -recurse
        &dotnet new --debug:reinit
        pop-location
    }
}
# get-fullpath function needs to be imported
$vstempfolderpath = ((join-path -Path $srcDir Content\.vs)|Get-FullPath)
$outputpath = ((Join-Path $scriptDir nupkg)|Get-FullPath)
Push-Location $srcDir
sayedha removefolders -f bin -f obj
Pop-Location

'Folders to delete: {0}' -f $foldersToDelete | Write-Host
Remove-Folder -path $foldersToDelete

$pathtonuspec = ((Join-Path $srcDir SayedHa.Template.NetCoreTool.nuspec)|get-fullpath)
if(Test-Path $pathtonuspec){
    nuget pack $pathtonuspec -OutputDirectory $outputpath
}
else{
    'nuspec file not found at {0}' -f $pathtonuspec | Write-Error
}

$pathtonupkg = ((join-path $scriptDir nupkg/SayedHa.Template.NetCoreTool.nuspec.1.0.0.nupkg)|get-fullpath)

Reset-Templates
if(test-path $pathtonupkg){
    'installing template "{0}"' -f $pathtonupkg | write-host
    &dotnet new --install $pathtonupkg
}