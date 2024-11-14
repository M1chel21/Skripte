#-----------Module-Importieren-----------
$modulePath = Join-Path -Path (Get-Location) -ChildPath "Funktionen.psm1"
Import-Module $modulePath
#----------------------------------------
$inhalt = "Paul" #Einzige Variable in der Abfrage
abfrage($inhalt)





