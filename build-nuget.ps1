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

# get-fullpath function needs to be imported
$vstempfolderpath = ((join-path -Path $srcDir Content\.vs)|Get-FullPath)
$outputpath = ((Join-Path $scriptDir nupkg)|Get-FullPath)
Push-Location $srcDir
sayedha removefolders -f bin -f obj
Pop-Location
# [string[]]$foldersToDelete = ($vstempfolderpath,$outputpath)
# [string[]]$binfolders = Get-ChildItem $srcDir bin -Recurse -Directory|get-fullpath
# [string[]]$objfolders = Get-ChildItem $srcDir obj -Recurse -Directory|get-fullpath

#if($binfolders){
#    $foldersToDelete = $foldersToDelete + $binfolders
#}
#if($objfolders){
#    $foldersToDelete =  $foldersToDelete + $objfolders
#}
'Folders to delete: {0}' -f $foldersToDelete | Write-Host
Remove-Folder -path $foldersToDelete

$pathtonuspec = ((Join-Path $srcDir SayedHa.Template.NetCoreTool.nuspec)|get-fullpath)
if(Test-Path $pathtonuspec){
    nuget pack $pathtonuspec -OutputDirectory $outputpath
}
else{
    'nuspec file not found at {0}' -f $pathtonuspec | Write-Error
}

