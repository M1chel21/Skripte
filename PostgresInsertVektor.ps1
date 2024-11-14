#-----------Module-Importieren-----------
$modulePath = Join-Path -Path (Get-Location) -ChildPath "Funktionen.psm1"
Import-Module $modulePath
#----------------------------------------
$inhalt = "Paul Theska guckt gerne Netflix auf der Zugfahrt" #Einzige Variable in dem Insert
connection_insert($inhalt)






