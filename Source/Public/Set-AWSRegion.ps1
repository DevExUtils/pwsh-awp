Function Set-AWSRegion {
    <#
    .SYNOPSIS
        Set default region to use for current shell session.
    .DESCRIPTION
        Get a list of allowed AWS Regions for your account through the AWS CLI.
        Select a region from the list using FZF and finally export that profile to the $env:AWS_REGION environment variable.

    .EXAMPLE
        PS C:\> awr
        List all allowed regions in your AWS account for interactive selection.
        Selected region is exported to $env:AWS_REGION environment variable for default region.

    .EXAMPLE
        PS C:\> awp eu-central-1
        Pre-sort the allowed regions list with the entered keyword.
        If multiple regions matches the keyword, user is prompted to select profile from a list.
        If only a single match is found that region is directly selected without further user prompts.
        Selected region exported to $env:AWS_REGION environment variable
    .INPUTS
        None
        or
        ProfileName
    .OUTPUTS
        $env:AWS_REGION
    #>
    [CmdletBinding()]
    [Alias("awr")]

    Param(

        [Parameter(
            Position = 0,
            Mandatory = $false,
            ValueFromPipeline = $True
        )]
        [AllowEmptyString()]
        [Alias('Region')]
        [string[]]$RegionName
    )
    begin {
        if (!$env:AWP_FZF_OPTS)  {
            $AWP_FZF_OPTS = '--ansi', '--layout=reverse', '--border', '--height', '60%'
        }
        else {
            $AWP_FZF_OPTS = $env:AWP_FZF_OPTS
        } 
    }
    process {
        if ($PSBoundParameters.ContainsKey('RegionName')) {
            $selectedRegion = (aws ec2 describe-regions | ConvertFrom-Json).Regions.RegionName | fzf -q $RegionName --select-1 --exit-0 $AWP_FZF_OPTS
        }
        else {
            $selectedRegion = (aws ec2 describe-regions | ConvertFrom-Json).Regions.RegionName | fzf $AWP_FZF_OPTS
        }
        
        If ($selectedRegion) {

            $env:AWS_REGION = $selectedRegion
        }
        else {
            Write-Output "No Region found / No Region selected."
        }
    }
}