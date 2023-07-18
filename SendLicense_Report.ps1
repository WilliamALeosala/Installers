$MyModulePath = "C:\Program Files\Veeam\Backup and Replication\Console\"
$env:PSModulePath = $env:PSModulePath + "$([System.IO.Path]::PathSeparator)$MyModulePath"
if ($Modules = Get-Module -ListAvailable -Name Veeam.Backup.PowerShell) {
    try {
        $Modules | Import-Module -WarningAction SilentlyContinue
        }
        catch {
            throw "Failed to load Veeam Modules"
            }
}
else{throw "Unable To find Veeam Module"}


#Below code will generate a license usage pdf file in C drive with name VBRLicensingReports
$Date = Get-Date -Format "MM_dd_yyy"
$Path = 'C:\Bluepeak core library\VBRLicensingReports\'
if(!(Test-Path -Path $Path)){New-Item -Path $Path -ItemType Directory}
Generate-VBRLicenseUsageReport -Path $Path'_VBRLicensingReports_'$Date -Type Pdf
$PdfFile = $path+(Get-ChildItem -path $($Path) | sort LastWriteTime | select -last 1).name

$Username = "Alert-smtp@bluepeak.io";
$Password = "939abmwwlfop1@21!00";
$SMTPServer = "smtp.office365.com"
$SMTPPort = "587"
$MessageSubject = "Veeam License Report for $Company $Date"
$MessageBody = "Here is the Veeam License report for $Date, $SizeDescription"
$recipient = "tfarson@bluepeak.io"

function Send-ToEmail([string]$email){
    $message = new-object Net.Mail.MailMessage;
    $message.From = $Username;
    $message.To.Add($email);
    $message.Subject = $MessageSubject;
    $message.Body = $MessageBody;

    write-host "attaching"
    $File = $PdfFile
    $att = new-object Net.Mail.Attachment($file)
    $message.Attachments.Add($att)

   write-host "new smtp"
    $smtp = new-object Net.Mail.SmtpClient($SMTPServer, $SMTPPort); 
    $smtp.EnableSSL = $true;
    $smtp.Credentials = New-Object System.Net.NetworkCredential($Username, $Password);

    write-host "new send"
    $smtp.send($message);
    write-host "pre dispose"
    $att.Dispose()
    write-host "**Mail Sent" ; 
 }
 
Send-ToEmail  -email $recipient