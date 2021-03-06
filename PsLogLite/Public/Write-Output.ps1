Function Write-Output {
[CmdletBinding(HelpUri='https://go.microsoft.com/fwlink/?LinkID=113427', RemotingCapability='None')]
param(
    [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true, ValueFromRemainingArguments=$true)]
    [AllowNull()]
    [AllowEmptyCollection()]
    [psobject[]]
    $InputObject,

    [switch]
    $NoEnumerate
)

Begin
{
    $Level = 'Output'
    Try {
        $Function = (Get-PSCallStack)[1].Command
        Write-Log -Message $($InputObject | Out-String) -Function $Function -Level $Level
    } Catch {
        $Prefix = $Script:LogPrefix.$Level
        Write-Log -Message "FAILED TO LOG $Prefix MESSAGE" -Function $('{0}\{1}' -f $Script:ModuleName,$MyInvocation.MyCommand) -Level 'Critical'
    }
    Try {
        $outBuffer = $null
        If ($PSBoundParameters.TryGetValue('OutBuffer', [ref]$outBuffer)) {
            $PSBoundParameters['OutBuffer'] = 1
        }
        $wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand('Microsoft.PowerShell.Utility\Write-Output', [System.Management.Automation.CommandTypes]::Cmdlet)
        $scriptCmd = {& $wrappedCmd @PSBoundParameters }
        $steppablePipeline = $scriptCmd.GetSteppablePipeline($myInvocation.CommandOrigin)
        $steppablePipeline.Begin($PSCmdlet)
    } Catch {
        Throw
    }
}

Process
{
    Try {
        $steppablePipeline.Process($_)
    } Catch {
        Throw
    }
}

End
{
    Try {
        $steppablePipeline.End()
    } Catch {
        Throw
    }
}
<#

.ForwardHelpTargetName Microsoft.PowerShell.Utility\Write-Output
.ForwardHelpCategory Cmdlet

#>

}