Import-Module -Name ActiveDirectory
$FileName = "C:\powershell\test1.csv"; 
$username = "students\scott.mullen"; 
$password = cat C:\powershell\securestringTeachers.txt | convertto-securestring; 
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $username, $password; 
#Gets and stores computer objects from specified OU
$Domain = "students.rpsdistrict.local"
$OU = "OU=BM-CompLab,OU=BirchMeadowStudentComputers,OU=ElementaryStudentComputers,DC=students,DC=RPSDistrict,DC=local"
$a = (get-adcomputer -searchbase $OU -searchscope 1 -server $Domain -filter *).DNSHostName;

#Empty array to store 
$list = @()
#Parse through the list of AD computer objects 
foreach ($i in $a) {
    #Defines data object $computer with the values DNSName, BIOSModel, and BIOSSerial.  Than adds these objects to $list
	if(Test-Connection -Cn $i -BufferSize 16 -Count 1 -ea 0 -quiet){
		$list += [pscustomobject]@{
		DNSName = $i
		BIOSModel = Get-WMIObject -Class Win32_ComputerSystem -Credential $cred -ComputerName $i | Select-Object -ExpandProperty Model
		BIOSSerial = Get-WMIObject -Class Win32_BIOS -Credential $cred -ComputerName $i | Select-Object -ExpandProperty SerialNumber
		}
    } # end if
    ELSE {
        $list += [pscustomobject]@{
		DNSName = $i
		BIOSModel = ""
		BIOSSerial = ""
        }
    } #end if

	

}

#Prints the data stored in list.  
$list | get-member -type NoteProperty | foreach-object {
  $value=$list."$($_.Name)"
  write-host "$value"
}

#Exports data to CSV
$list | Export-Csv $FileName -Append -Encoding ASCII -NoTypeInformation
pause 