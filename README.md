TechNet Gallery to GitHub Migrator
==================================

            

![Image](https://github.com/jamescussen/TechNet-Gallery-to-GitHub-Migrator/raw/master/TechNetToGitHub.png)


This tool is a Powershell script that runs allows you to easily migrate content off Microsoft's TechNet Gallery to GitHub.

**Script Flags:**

 * MoveImagesToGitHub (Default TRUE) - When set to $true this flag will change the Image URLs in your TechNet post into GitHub URLs so you can re-host your images for when TechNet Gallery completely goes away.
 * TechNetURLs - This flag is where you can put in a comma separated list of all the TechNet URLs that you want to download.
 * GitHubAccount -  This flag is used for updating image URLs with the GitHub account location where it's going to be stored. This will be the account name that you sign into GitHub with.
 * GitHubRepo (Default TechNet Post Title) - This is the Repo name that the files will be uploaded to. If you don't enter this then the TechNet title will be used. 

**Example:** 
.\TechNet-Gallery-to-GitHub-Migrator.ps1 -TechNetURLs "https://gallery.technet.microsoft.com/Lync-Skype-for-Businesss-d422212f", "https://gallery.technet.microsoft.com/Teams-Direct-Routing-Tool-42c0bdef" -GitHubAccount "jamescussen"

**Prerequisites:**
 * You need something on TechNet Gallery that you would like to download or migrate to GitHub.
 * You need to create a GitHub account. The account name will go into forming updated image URLs.

**Known Issues:** 
 * Converting HTML to Markdown can result in some extra characters like asterisks where there is HTML tags around no text and weird edge cases like that. You may need to do a basic manual pass of the markdown to correct some of these smaller issues.
 * Code snippets in the TechNet Gallery text will not be migrated to the GitHub README.md file. I would suggest given that the code file will be on GitHub that this is not necessary in the readme file.

**Release Notes:**
 * Initial Release

 
**All information on this tool can be found here:** [https://www.myteamslab.com/2020/05/technet-gallery-to-github-migration-tool.html](https://www.myteamslab.com/2020/05/technet-gallery-to-github-migration-tool.html)


        
    
