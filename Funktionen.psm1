#--------Import-von-Konstanten-Modul-------------
$modulePath = Join-Path -Path (Get-Location) -ChildPath "Konstanten.psm1"
Import-Module $modulePath
function abfrage {
    param (
        $inhalt
        )
        $liste = connection_request($inhalt)
        return $liste
}
function textembedding {
    param (
        [string]$inhalt  # Übergabeparameter für den Textinhalt
    )

    # Abrufen des API-Schlüssels
    $apikey = getapikey

    # URL für die API-Anfrage
    $url = "https://generativelanguage.googleapis.com/v1beta/models/text-embedding-004:embedContent?key=$apikey"

    # Header für den REST-API-Request
    $headers = @{
        'Content-Type' = 'application/json'
    }

    # Daten, die gesendet werden sollen
    $body = @{
        model   = "models/text-embedding-004"
        content = @{
            parts = @(
                @{
                    text = $inhalt  # Übergabe des Inhalts als Text
                }
            )
        }
    } | ConvertTo-Json -Depth 4

    # Sende die API-Anfrage
    $response = Invoke-RestMethod -Uri $url -Method Post -Headers $headers -Body $body

    # Verarbeiten und Ausgeben der Antwort
    $response.embedding.values = $response.embedding.values | ForEach-Object { $_ -replace ",", "." }
    $embeddingValuesString = -join ($response.embedding.values -join ",")
    return $embeddingValuesString
}
#--------------------------------REQUEST----------------------------------
function connection_request {
    param(
        $inhalt
    )
    $localhostport = getlocalhostport
    $password = getpassword
    #$nugetpath1 = Join-Path -Path (Get-Location) -ChildPath "Npgsql.ddl"
    #Write-Output $nugetpath1
    $nugetpath1= getnugetpath1
    $nuegtpath2 =getnugetpath2
     Add-Type -Path $nugetpath1
     Add-Type -Path $nuegtpath2
    # Verbindungszeichenfolge
    
    
 $embeddingValuesString = textembedding("$inhalt")
$connectionString = "Host=localhost:$localhostport;Username=postgres;Password=$password;Database=Suchmaschine"
# Verbindung erstellen
$connection = New-Object Npgsql.NpgsqlConnection($connectionString)

try {
    # Verbindung öffnen
    $connection.Open()
    Write-Output "Erfolgreich verbunden!"
    # Beispielabfrage
    $query = "SELECT Distinct path, metadata FROM dokumente join chunks on chunks.path = Dokumente.path ORDER BY chunks.embedding <-> '[$embeddingValuesString]' Limit 20"
    $command = New-Object Npgsql.NpgsqlCommand($query, $connection)
    $reader = $command.ExecuteReader()

    # Daten abrufen und ausgeben
    while ($reader.Read()) {
        Write-Output $reader[0]
        $liste += $reader[0]
    }
    return $liste
}
catch {
    Write-Error "Fehler beim Verbinden: $_"
}
finally {
    # Verbindung schließen
    $connection.Close()
}
}
#-------------------------------------------INSERT-DES-PATHS-UND-HASHTABLE-IN-DOKUMENTE------------------------------------
function dokumente_insert {
   param(
       $Path,
       $JsonContent
   )
  # Write-Output $Path
$JsonContent1 = $JsonContent | ConvertTo-Json -Depth 1
$localhostport = getlocalhostport
$password = getpassword
  
$nugetpath1= getnugetpath1
$nuegtpath2 =getnugetpath2
Add-Type -Path $nugetpath1
Add-Type -Path $nuegtpath2

# Verbindungszeichenfolge
##########$embeddingValuesString = textembedding("$inhalt")
$connectionString = "Host=localhost:$localhostport;Username=postgres;Password=$password;Database=Suchmaschine"
# Verbindung erstellen
$connection = New-Object Npgsql.NpgsqlConnection($connectionString)

try {
   # Verbindung öffnen
   $connection.Open()
   Write-Output "Erfolgreich verbunden!"
      # Beispielabfrage für eingabe
     
      $query = "INSERT INTO dokumente (path, metadata) VALUES ('$Path', '$JsonContent1')"
      
      $command = New-Object Npgsql.NpgsqlCommand($query, $connection)
      $command.ExecuteNonQuery()
      # Write-Output "$Path"
     #  Write-Output "Erfolgreich eingetragen"
}
catch {
   Write-Error "Fehler beim Verbinden: $_"
}
finally {
   # Verbindung schließen
   $connection.Close()
}
}
#-------------------INSERT-DES-PATHS-/-INHALTS-/-VECTOR-IN-DEN-INHALT----------------
function chunk_insert {
    param(
        $Path,
        $chunk
        )
 $localhostport = getlocalhostport
 $password = getpassword
   
 $nugetpath1= getnugetpath1
 $nuegtpath2 =getnugetpath2
 Add-Type -Path $nugetpath1
 Add-Type -Path $nuegtpath2
 
 # Verbindungszeichenfolge
 ##########$embeddingValuesString = textembedding("$inhalt")
 $connectionString = "Host=localhost:$localhostport;Username=postgres;Password=$password;Database=Suchmaschine"
 # Verbindung erstellen
 $connection = New-Object Npgsql.NpgsqlConnection($connectionString)
 $Vector = textembedding($chunk)
 try {
    # Verbindung öffnen
    $connection.Open()
    Write-Output "Erfolgreich verbunden!"
       # Beispielabfrage für eingabe
       $query = "INSERT INTO chunks (path,embedding,chunk) VALUES ('$Path', '[$Vector]', '$chunk')"
       $command = New-Object Npgsql.NpgsqlCommand($query, $connection)
       $command.ExecuteNonQuery()
     #   Write-Output "$Path"
    #    Write-Output "Erfolgreich eingetragen"
 }
 catch {
    Write-Error "Fehler beim Verbinden: $_"
 }
 finally {
    # Verbindung schließen
    $connection.Close()
 }
 }
 #------------BEKOMMT HASTABLE VON CRAWLER--------------------
 function SaveAllContent {
    param (
        [hashtable]$MetadataAndContent
    )
 
    $Inhaltsstring = $MetadataAndContent["Body"] #Platzhalter Variablen
    $Path = $MetadataAndContent["Path"]
    
    
 
    #Inhaltsstring an chunking geben und das ruft an die api und chunking schreibt blöcke in inhalt
   
    # Wandeln der Daten in JSON um
    $JsonContent = $MetadataAndContent 
    #Write-Output $Path
    dokumente_insert -Path $Path -JsonContent $JsonContent
   # Write-Output "Wurde erfolgreich übergeben an dokumente_insert"
    Chunking -Inhaltsstring $Inhaltsstring -Path $Path
    Write-Output "ALLES WURDE ERFOLGREICH AUS DER HASHTABLE EINGETRAGEN"
    
}
#----------------------------------------------------
function Chunking {
    param (
        $Inhaltsstring, 
        $Path
    )
    
    $chunkSize = 6000
    $gesamtlänge = $Inhaltsstring.Length
    $Chunkliste = @()
 
    for ($I = 0; $I -lt $gesamtlänge; $I += $chunkSize) {
        $chunk = $Inhaltsstring.Substring($I, [Math]::Min($chunkSize, $gesamtlänge - $i))
        $Chunkliste += $chunk
        
    }

    foreach($chunk in $Chunkliste) {

        chunk_insert -Path $Path -chunk $chunk
 
    }
}
Export-ModuleMember -Function @( 'textembedding','dokumente_insert','connection_request','abfrage','chunk_insert','SaveAllContent','Chunking')