Function Write-Debug {
[CmdletBinding(HelpUri='https://go.microsoft.com/fwlink/?LinkID=113424', RemotingCapability='None')]
param(
    [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true)]
    [Alias('Msg')]
    [AllowEmptyString()]
    [string]
    $Message
) # param

Begin
{
    $Level = 'Debug'
    Try {
        $Function = (Get-PSCallStack)[1].Command
        Write-Log -Message $Message -Function $Function -Level $Level
    } Catch {
        $Prefix = $Script:LogPrefix.$Level
        Write-Log -Message "FAILED TO LOG $Prefix MESSAGE" -Function $('{0}\{1}' -f $Script:ModuleName,$MyInvocation.MyCommand) -Level 'Critical'
    }

    Try {
        $outBuffer = $null
        If ($PSBoundParameters.TryGetValue('OutBuffer', [ref]$outBuffer)) {
            $PSBoundParameters['OutBuffer'] = 1
        }
        $wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand('Microsoft.PowerShell.Utility\Write-Debug', [System.Management.Automation.CommandTypes]::Cmdlet)
        $scriptCmd = {& $wrappedCmd @PSBoundParameters }
        $steppablePipeline = $scriptCmd.GetSteppablePipeline($myInvocation.CommandOrigin)
        $steppablePipeline.Begin($PSCmdlet)
    } Catch {
        Throw
    }
} # Begin

Process
{
    Try {
        $steppablePipeline.Process($_)
    } Catch {
        Throw
    }
} # Process

End
{
    Try {
        $steppablePipeline.End()
    } Catch {
        Throw
    }
} # End
<#

.ForwardHelpTargetName Microsoft.PowerShell.Utility\Write-Debug
.ForwardHelpCategory Cmdlet

#>

}