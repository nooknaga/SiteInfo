# When user and pass are not both provided:
# 		-Jenkins job: throw exception
# 		-Non-jenkins job: prompt for credentials
function connectss([string]$url, [string]$domain,[string]$ssuser,[string]$sspass)
{
    [hashtable]$Returnvals = @{}
	
	# User and pass were both sent in
	if( $ssuser -And $sspass ){
	
		# username needs to change to a role based account
		$username = $ssuser
		$password = $sspass | ConvertTo-SecureString -AsPlainText -Force
		$creds = New-Object System.Management.Automation.PSCredential($username,$password)
	}
	# Jenkins job, and user and/or pass were not sent in, throw ex (JOB_NAME env variable is defined for jenkins jobs)
	elseif( $env:JOB_NAME ){
		throw "Secret server username and/or password was not provided for this Jenkins job."	
	}
	# No user and/or pass sent in, and not a jenkins job -- prompt for credentials
	else{
		Write-Host "No credentials received.  Prompting for Secret Server credentials. . ."
		$username = $env:username
		$domain = $env:userdomain		
		$creds = Get-Credential -Username $domain\$username -Message "Connect to Secret Server"
		$password = $creds.Password
	}
	
	try{
		$proxy = New-WebServiceProxy -uri $url -Credential $creds -EA Stop
		if( !$proxy ){
			throw "New-WebServiceProxy: The web service proxy object is empty or null."	
		}
		
		$result1 = $proxy.Authenticate($username, [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($password)), '', $domain)	
		CheckSsReturnObject $result1 "proxy.Authenticate" 
	}
	catch{
		throw "$($_.ToString()) `n`t url: $url `n`t domain: $domain `n`t user: $username"	
	}

    $token = $result1.Token
	Write-Host "Token retrieved successfully"
    $Returnvals.tokenid = $token
    $Returnvals.proxyid = $proxy
    
    Return $Returnvals
}


function getsspassword($tokenid, $proxyid, [string]$ssSearchString)
{
	try{
		if( !$ssSearchString ) { throw "'getsspassword' received an empty or null ssSearchString."}
	
		# Even when no results are found, this still returns an object
		# Must inspect both $searchresult.Errors and array $searchresult.SecretSummaries
		$searchresult = $proxyid.SearchSecrets($tokenid,$ssSearchString,$null,$null)
		CheckSsReturnObject $searchresult "proxyid.SearchSecrets"
		if($searchresult.SecretSummaries.Length -lt 1){
			throw "searchresult.SecretSummaries: search returned no results."
		}
		
		$secretsearchresult = $proxyid.GetSecret($tokenid,$searchresult.SecretSummaries.SecretId,$null,$null)
		CheckSsReturnObject $secretsearchresult "proxyid.GetSecret"
		
		# Password is not always .Items[2]; for svcdeployvm@cloud.advent, it is .Items[1]
		#$secretpassword = $secretsearchresult.Secret.Items[2].Value
				
		# iterate Items, find the one with the FieldName 'Password'
		$secretpassword = $null				
		foreach($s in $secretsearchresult.Secret.Items){
			if($s.FieldName -eq "Password"){
				$secretpassword = $s.Value
				break
			}
		}
		
		if( $secretpassword -eq $null ){
			throw "secretsearchresult.Secret.Items: no password found in the items array."
		}
		
		Return $secretpassword
	}
	catch{
		throw "$($_.ToString()) `n`t TokenId null: $(!$tokenId) `n`t ProxyId null: $(!$proxyId) `n`t ssSearchString: $ssSearchString"				
	}
}

# Secret server returns objects containing an array 'Errors'
# Private, not exported  
function CheckSsReturnObject($ssObject, $strDescription){

	if( !$ssObject ){
		throw "$($strDescription):  The returned object is empty or null."
	}
	elseif( $ssObject.Errors.Length -gt 0 ){
		throw "$($strDescription): $($ssObject.Errors)"		
	}

}

Export-ModuleMember -Function 'connectss'
Export-ModuleMember -Function 'getsspassword'



