########################################################################
# Name: TechNet Gallery to GitHub Migrator
# Version: v1.0.0 (1/5/2020)
# Original Release Date: 1/5/2020
# Created By: James Cussen
# Web Site: http://www.myteamslab.com
# Notes: This is a PowerShell tool. To run the tool, open it from the PowerShell command line.
#		 For more information on the requirements for using this tool please visit http://www.myteamslab.com.
#
# Copyright: Copyright (c) 2020, James Cussen (www.myteamslab.com) All rights reserved.
# Licence: 	Redistribution and use of script, source and binary forms, with or without modification, are permitted provided that the following conditions are met:
#				1) Redistributions of script code must retain the above copyright notice, this list of conditions and the following disclaimer.
#				2) Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
#				3) Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
#				4) This license does not include any resale or commercial use of this software.
#				5) Any portion of this software may not be reproduced, duplicated, copied, sold, resold, or otherwise exploited for any commercial purpose without express written consent of James Cussen.
#			THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; LOSS OF GOODWILL OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# Usage: 
#	Script Flags:
#		-MoveImagesToGitHub (Default TRUE) - When set to $true this flag will change the Image URLs in your TechNet post into GitHub URLs so you can re-host your images for when TechNet Gallery completely goes away.
#		-TechNetURLs - This flag is where you can put in a comma separated list of all the TechNet URLs that you want to download.
#		-GitHubAccount -  This flag is used for updating image URLs with the GitHub account location where it's going to be stored. This will be the account name that you sign into GitHub with.
#		-GitHubRepo (Default TechNet Post Title) - This is the Repo name that the files will be uploaded to. If you don't enter this then the TechNet title will be used. 
#
#	Example: 
#		- .\TechNet-Gallery-to-GitHub-Migrator.ps1 -TechNetURLs "https://gallery.technet.microsoft.com/Lync-Skype-for-Businesss-d422212f", "https://gallery.technet.microsoft.com/Teams-Direct-Routing-Tool-42c0bdef" -GitHubAccount "jamescussen"
#
# Prerequisites:
#	- You need something on TechNet Gallery that you would like to download or migrate to GitHub.
#	- You need to create a GitHub account. The account name will go into forming updated image URLs.
#
# Known Issues: 
#	- Converting HTML to Markdown can result in some extra characters like asterisks where there is HTML tags around no text and weird edge cases like that. You may need to do a basic manual pass of the markdown to correct some of these smaller issues.
#	- Code snippets in the TechNet Gallery text will not be migrated to the GitHub README.md file. I would suggest given that the code file will be on GitHub that this is not necessary in the readme file.
#
# Release Notes:
#	- Initial Release
#
#########################################################################


param (
[parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
[ValidateNotNullOrEmpty()]
[string[]] $TechNetURLs,

[parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
[ValidateNotNullOrEmpty()]
[bool] $MoveImagesToGitHub = $true,

[parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
[ValidateNotNullOrEmpty()]
[string] $GitHubAccount = "",

[parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
[ValidateNotNullOrEmpty()]
[string] $GitHubRepo  = ""
)

Add-Type -AssemblyName System.Web

Write-Host
[string]$Heading = " _________  _______   ________  ___  ___  ________   _______  _________   &|\___   ___\\  ___ \ |\   ____\|\  \|\  \|\   ___  \|\  ___ \|\___   ___\ &\|___ \  \_\ \   __/|\ \  \___|\ \  \\\  \ \  \\ \  \ \   __/\|___ \  \_| &     \ \  \ \ \  \_|/_\ \  \    \ \   __  \ \  \\ \  \ \  \_|/__  \ \  \  &      \ \  \ \ \  \_|\ \ \  \____\ \  \ \  \ \  \\ \  \ \  \_|\ \  \ \  \ &       \ \__\ \ \_______\ \_______\ \__\ \__\ \__\\ \__\ \_______\  \ \__\&        \|__|  \|_______|\|_______|\|__|\|__|\|__| \|__|\|_______|   \|__|&                          _________  ________                             &                         |\___   ___\\   __  \                            &                         \|___ \  \_\ \  \|\  \                           &                              \ \  \ \ \  \\\  \                          &                               \ \  \ \ \  \\\  \                         &                                \ \__\ \ \_______\                        &                                 \|__|  \|_______|                        &              ________  ___  _________  ___  ___  ___  ___  ________      &             |\   ____\|\  \|\___   ___\\  \|\  \|\  \|\  \|\   __  \     &             \ \  \___|\ \  \|___ \  \_\ \  \\\  \ \  \\\  \ \  \|\ /_    &              \ \  \  __\ \  \   \ \  \ \ \   __  \ \  \\\  \ \   __  \   &               \ \  \|\  \ \  \   \ \  \ \ \  \ \  \ \  \\\  \ \  \|\  \  &                \ \_______\ \__\   \ \__\ \ \__\ \__\ \_______\ \_______\ &                 \|_______|\|__|    \|__|  \|__|\|__|\|_______|\|_______| "
$HeadingPrint = $Heading.Replace('&', "`r`n")
Write-Host $HeadingPrint -foreground "green"
Write-Host
Write-Host

$GitHubRepoSupplied = $false
if($MoveImagesToGitHub -and [string]::IsNullOrEmpty($GitHubAccount) -and [string]::IsNullOrEmpty($GitHubRepo))
{
	Write-Host "Enter the GitHub Account name for image URLs: " -NoNewline -foreground "yellow"
	$GitHubAccount = Read-Host
	
	if([string]::IsNullOrEmpty($GitHubAccount))
	{
		Write-Host "ERROR: You cannot leave the GitHub Account name as blank. Exiting."
		exit
	}
	Write-Host "INFO: Using TechNet Gallery title as repo name" -foreground "yellow"
}
elseif($MoveImagesToGitHub -and [string]::IsNullOrEmpty($GitHubAccount) -and (![string]::IsNullOrEmpty($GitHubRepo)))
{
	Write-Host "Enter the GitHub Account name for image URLs: " -NoNewline -foreground "yellow"
	$GitHubAccount = Read-Host
	if([string]::IsNullOrEmpty($GitHubAccount))
	{
		Write-Host "ERROR: You cannot leave the GitHub Account name as blank. Exiting."
		exit
	}
	$GitHubRepoSupplied = $true
}
elseif($MoveImagesToGitHub -and (![string]::IsNullOrEmpty($GitHubAccount)) -and [string]::IsNullOrEmpty($GitHubRepo))
{
	Write-Host "INFO: Using TechNet Gallery title as repo name" -foreground "yellow"
}

if($TechNetURLs.count -eq 0)
{
	Write-Host "No TechNet URLs provided in TechNetURLs input." -foreground "yellow"
	Write-Host "Enter a TechNet URL to download: " -NoNewline -foreground "yellow"
	$ResponseURL = Read-Host
	if($ResponseURL -imatch "https://")
	{
		$TechNetURLs += $ResponseURL
	}
	else
	{
		Write-Host "ERROR: You have not provided a URL starting with https://" -foreground "red"
	}
	
	if($TechNetURLs.count -eq 0)
	{
		Write-Host "ERROR: You didn't provide a URL." -foreground "red"
		exit
	}
}


[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

add-type @"
        using System.Net;
        using System.Security.Cryptography.X509Certificates;

            public class IDontCarePolicy : ICertificatePolicy {
            public IDontCarePolicy() {}
            public bool CheckValidationResult(
                ServicePoint sPoint, X509Certificate cert,
                WebRequest wRequest, int certProb) {
                return true;
            }
        }
"@
[System.Net.ServicePointManager]::CertificatePolicy = new-object IDontCarePolicy 

#FOLDER WHERE SCRIPT IS RUNNING
$scriptpath = $MyInvocation.MyCommand.Path
$dir = Split-Path $scriptpath
$fso = New-Object -ComObject Scripting.FileSystemObject
$shortname = $fso.GetFolder($dir).Path
Write-host
Write-host "Local script directory: $shortname" -foreground "yellow"
Write-host

[string]$filename = 'README.md'
[string]$folder = 'folder'
[string]$baseURL = "https://gallery.technet.microsoft.com"


foreach($TechNetURL in $TechNetURLs)
{
	Write-Host "-----------------------------------------------------------------------------------------------" -foreground "green"
	Write-Host "PROCESSING URL: $TechNetURL" -foreground "green"
	Write-Host "-----------------------------------------------------------------------------------------------" -foreground "green"
	
	[string]$TechNetURL2 = "${TechNetURL}/description"

	#GET THE TECHNET GALLERY PAGE HTML
	[string]$content = Invoke-RestMethod -Uri $TechNetURL -Method Get

	#PARSE THE TITLE OF THE PAGE
	$title = [regex]::match($content,'<h1 class="projectTitle">(.*?)</h1>').Groups[1].Value
	Write-Host "TITLE: " $title -foreground "green"

	[string]$titleFolder = $title.Split([IO.Path]::GetInvalidFileNameChars()) -join '-'
	Write-Host "Foldername: $titleFolder" -foreground "green"
	
	if([string]::IsNullOrEmpty($GitHubRepo))
	{
		$GitHubRepo = $titleFolder.tolower().replace(" -", "").replace("- ", "").replace("-", "").replace(" ", "-")
		Write-Host "INFO: Auto generated GitHub repo name from post title: $GitHubRepo" -foreground "yellow"
	}
	else
	{
		Write-Host "INFO: Using repo name specified by user: $GitHubRepo" -foreground "yellow"
	}
	
	#CREATE FOLDER TO PUT FILES IN
	$path = "${shortname}\${GitHubRepo}"
	If(!(test-path $path))
	{
		Write-Host "INFO: Creating folder: $path" -foreground "yellow"
		New-Item -ItemType Directory -Force -Path $path
	}

	#GET THE HOSTED FILE FROM TECHNET
	$script = [regex]::match($content,'data-url=\"(.*?)\" class=\"button\">').Groups[1].Value
	Write-Host "SCRIPT URL: " ${baseURL}${script} -foreground "green"

	[string]$outputFileName = [System.IO.Path]::GetFileName("${baseURL}${script}")
	Write-Host "FILE TO DOWNLOAD: $outputFileName" -foreground "green"

	Write-Host "INFO: Downloading File... Please wait..." -foreground "yellow"
	Write-Host "WRITING FILE TO: ${shortname}\${GitHubRepo}\${outputFileName}" -foreground "green"
	Invoke-WebRequest -Uri ${baseURL}${script} -OutFile "${shortname}\${GitHubRepo}\${outputFileName}"
	Write-Host

	[string]$content = Invoke-RestMethod -Uri $TechNetURL2 -Method Get

	#Write-Host "IMPORTED HTML FROM TECHNET GALLERY: " -foreground "yellow" 
	$text = [regex]::match($content,'<div\s*id=\"longDesc\">(.*?)<\/body>',[System.Text.RegularExpressions.RegexOptions]::SingleLine).Groups[1].Value

	#STRIP OUT CODE BLOCKS
	$text = $text -replace '(?ms)<div\s*class=\"scriptcode\">(.*?)<div\s*class=\"endscriptcode\">', ""


	# Convert paragraphs and lists
	$text = $text -replace "\s*<ul>\s*", "`r`n"
	$text = $text -replace "\s*</ul>\s*", "`r`n"
	$text = $text -replace "\s*<ol>\s*", "`r`n"
	$text = $text -replace "\s*</ol>\s*", "`r`n"
	$text = $text -replace "<p>", "`r`n"
	$text = $text -replace "</p>", "`r`n"
	$text = $text -replace "<li>", "`r`n  *  "
	$text = $text -replace "</li>", ""
	# Word/Phrase highlighting    
	$text = $text -replace "<em>", "*"
	$text = $text -replace "</em>", "*"
	$text = $text -replace "<b>", "**"
	$text = $text -replace "</b>", "**"
	$text = $text -replace "<strong[^>]*>", "**"
	$text = $text -replace "</strong>", "**"
	$text = $text -replace "&quot;", "'"
	$text = $text -replace "<!--break-->", ""

	#STRIP ANY RETURN CARRIAGES AND NEWLINES WITHIN A TAGS
	#$text = $text -replace '(<a.*>[^<]*)[\r?\n|\r]([^<]*<\/a>)', '$1$2'
	
	# Convert Links from <a> to Markdown style
	$text = $text -replace '<a\s+href="([^"]+)"[^>]*>([^<]*)<\/a>', '[$2]($1)'


	Write-Host "-----------------------------------------------------------------------------------------------" -foreground "green"
	Write-Host "SEARCHING FOR IMAGES IN PAGE" -foreground "green"
	Write-Host "-----------------------------------------------------------------------------------------------" -foreground "green"
	Write-Host
	
	#DOWNLOAD IMAGES
	$imageArray = [regex]::matches($text,'<img.*src="(.*\.(?:gif|jpg|jpeg|tiff|png))')
	foreach($image in $imageArray)
	{
		$imageFile = $image.Groups[1].Value
		if(!($imageFile -imatch "^https:"))
		{
			Write-Host "INFO: Incomplete URL: $imageFile" -foreground "yellow"
			Write-Host "INFO: Incomplete URL add https://gallery.technet.microsoft.com" -foreground "yellow"
			$imageFile = "https://gallery.technet.microsoft.com${imageFile}"
			Write-Host "IMAGE URL: $imageFile" -foreground "green"
		}
		Write-Host
		[string]$outputFileName = [System.IO.Path]::GetFileName("$imageFile")
		$outputFileName = $outputFileName -replace "%20", "-"
		Write-Host "INFO: Downloading image to file named: $outputFileName" -foreground "yellow"
		
		Write-Host "INFO: Downloading image from URL: $imageFile" -foreground "yellow"
		Write-Host "WRITING FILE TO: ${shortname}\${GitHubRepo}\${outputFileName}" -foreground "green"
		Invoke-WebRequest -Uri ${imageFile} -OutFile "${shortname}\${GitHubRepo}\${outputFileName}"

	}

	
	#<img id="170724" src="https://i1.gallery.technet.s-msft.com/rate-my-call-viewer-tool-13f0c40b/image/file/170724/1/ratemycallviewer1.01_sm.png" alt="" width="600" height="376" style="display:block; margin-left:auto; margin-right:auto">
	#REPLACE IMAGE WITH MARKDOWN IMAGE FORMAT
	if($MoveImagesToGitHub)
	{
		#REMOVE ANY URL ENCODED SPACE CHARS
		$matchArray = ($text | select-string -pattern '<img.*src="(.*)\/(.*\.(?:gif|jpg|jpeg|tiff|png))[^>]*>' -AllMatches).Matches.Value
		foreach($aMatch in $matchArray)
		{
			#Write-Host $aMatch
			$replacedString = $aMatch -replace "%20", "-"
			$text = $text -replace "$aMatch", "$replacedString"
		}

		Write-Host
		Write-Host "INFO: MoveImagesToGitHub flag set changing link to be on GitHub." -foreground "yellow"
		#https://github.com/MyToolLab/testTechNetGallery/raw/master/DirectRoutingTool-1.00-600px.png
		$text = $text -replace '<img.*src="(.*)\/(.*\.(?:gif|jpg|jpeg|tiff|png))[^>]*>', "![Image](https://github.com/${GitHubAccount}/${GitHubRepo}/raw/master/`$2)"
	}
	else
	{
		#REMOVE ANY URL ENCODED SPACE CHARS
		$matchArray = ($text | select-string -pattern '<img.*src="(.*)\/(.*\.(?:gif|jpg|jpeg|tiff|png))[^>]*>' -AllMatches).Matches.Value
		foreach($aMatch in $matchArray)
		{
			Write-Host $aMatch
			$replacedString = $aMatch -replace "%20", "-"
			$text = $text -replace "$aMatch", "$replacedString"
		}
		
		Write-Host
		Write-Host "INFO: MoveImagesToGitHub flag is set to false so retaining the image link from TechNet Gallery. If you would like to move the image to GitHub run the script with the flag `"-MoveImagesToGitHub `$true`"" -foreground "yellow"
		$text = $text -replace '<img.*src="(.*\.(?:gif|jpg|jpeg|tiff|png))[^>]*>', '![Image]($1)'
		
		#https://gallery.technet.microsoft.com/site/view/file/224699/1/TeamsTenantDialPlanEditorv1.00-400px.png
		$text = $text -replace '(!\[Image\]\()(\/[^)]*)', '$1https://gallery.technet.microsoft.com$2'
	}
		
	#STRIP ALL REMAINING HTML TAGS
	$noHTML = $text -replace "<[^>]*>", ""
	$result = [System.Web.HttpUtility]::HtmlDecode($noHTML)
	
	#STRIP ANY RETURN CARRIAGES AND NEWLINES WITHIN A TAGS - I'VE SEEN THIS HAPPEN IN <p> TAGS BEFORE
	$result = $result -replace '(\[[^\]]*)(?:\r\n)([^\]]*)', '$1$2'
	
	#CLEAN UP ANY BOLDING TAGS WITH NOTHING IN THEM
	$result = $result -replace '\*\*\r?\n? ?\*\*', ''
	
	

	Write-Host
	Write-Host "-----------------------------------------------------------------------------------------------" -foreground "green"
	Write-Host "GENERATING README.MD FILE FOR GITHUB" -foreground "green"
	Write-Host "-----------------------------------------------------------------------------------------------" -foreground "green"
	Write-Host
	Write-Host $result -foreground "green"
	
	#ADD THE HEADER TO README AND SAVE TO FOLDER
	$headingUnderscore = "=" * $title.length

	Write-Host "WRITING FILE TO: ${shortname}\${GitHubRepo}\${filename}" -foreground "green"
	"${title}`r`n$headingUnderscore`r`n${result}" | out-file -Encoding UTF8 -FilePath "${shortname}\${GitHubRepo}\${filename}" -Force
	
	Write-Host
	Write-Host
	
	if($GitHubRepoSupplied -eq $false)
	{
		[string]$GitHubRepo = ""
	}
}
