#-----------Module-Importieren-----------
$modulePath = Join-Path -Path (Get-Location) -ChildPath "Funktionen.psm1"
Import-Module $modulePath
#----------------------------------------
function datenbank_crawler {
    param (
        [hashtable]$MetadataAndContent
    )
    SaveAllContent($MetadataAndContent)
}
Export-ModuleMember -Function @('datenbank_crawler')