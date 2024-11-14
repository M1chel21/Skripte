# Funktion zur Rückgabe des API-Schlüssels
function getapikey {
    $apikey = "AIzaSyAv9THaWN1vy6Wvi12WVnbKA2uzgipJpL8"     #MUSS GEÄNDERT WERDEN
    return $apikey
}
function getlocalhostport {
    $localhostport = "1234" #Standardport 5432             #MUSS GEÄNDERT WERDEN
    return $localhostport
}
function getpassword {
    $password = "1896"                           #MUSS GEÄNDERT WERDEN
    return $password
}
function getnugetpath1 {
   $nugetpath1 = "C:\Users\miche\OneDrive\Desktop\npgsql.8.0.5\lib\net6.0\Npgsql.dll"   #MUSS GEÄNDERT WERDEN
   return $nugetpath1
}
function getnugetpath2 {
    $nugetpath2 = "C:\Users\miche\OneDrive\Desktop\microsoft.extensions.logging.abstractions.8.0.2\lib\netstandard2.0\Microsoft.Extensions.Logging.Abstractions.dll" #MUSS GEÄNDERT WERDEN
    # Verbindungszeichenfolge
    return $nugetpath2
}




Export-ModuleMember -Function @('getapikey','getlocalhostport','getpassword','getnugetpath1','getnugetpath2')