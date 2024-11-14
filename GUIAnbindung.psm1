#-----------Module-Importieren-----------
$modulePath = Join-Path -Path (Get-Location) -ChildPath "Funktionen.psm1"
Import-Module $modulePath
#----------------------------------------
function datenbank_gui { #datenbank empfängt einen String und gibt eine Liste mit Strings zurück
    param (
        $inhalt,
        $type, #pdf. docx.  ....
        $sort, #a-z / z-a
        $search #semantische Suche true or false
    )
    $liste = abfrage($inhalt)
    return $liste
}
Export-ModuleMember -Function @('datenbank_gui')