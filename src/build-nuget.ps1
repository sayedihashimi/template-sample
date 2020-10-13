$scriptDir = split-path -parent $MyInvocation.MyCommand.Definition

# nuget.exe needs to be on the path or aliased
function Remove-Folder{
    [cmdletbinding()]
    param(
        [Parameter(ValueFromPipeline=$true)]
        [string[]]$path
    )
    process{
        if(-not $path){
            return
        }
        foreach ($p in $path) {
            if(test-path $p){
                'Deleting folder "{0}"' -f $p | Write-Host
                Remove-Item -Path $p -recurse -Force
            }
        }
    }
}

# get-fullpath function needs to be imported
$vstempfolderpath = (join-path -Path $scriptDir Content\.vs)|Get-FullPath
$outputpath = ((Join-Path $scriptDir nupkg)|Get-FullPath)

[string[]]$foldersToDelete = ($vstempfolderpath,$outputpath)
#$binfolders = Get-ChildItem $scriptDir bin -Recurse -Directory|get-fullpath
#$objfolders = Get-ChildItem $scriptDir obj -Recurse -Directory|get-fullpath

if($binfolders){
    $foldersToDelete = $foldersToDelete + $binfolders
}
if($objfolders){
    $foldersToDelete =  $foldersToDelete + $objfolders
}
'Folders to delete: {0}' -f $foldersToDelete | Write-Host
Remove-Folder -path $foldersToDelete

$pathtonuspec = ((Join-Path $scriptDir SayedHa.Template.NetCoreTool.nuspec)|get-fullpath)
if(Test-Path $pathtonuspec){
    nuget pack $pathtonuspec -OutputDirectory $outputpath
}
else{
    'nuspec file not found at {0}' -f $pathtonuspec | Write-Error
}

