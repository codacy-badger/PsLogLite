Function Write-Error {
[CmdletBinding(DefaultParameterSetName='NoException', HelpUri='https://go.microsoft.com/fwlink/?LinkID=113425', RemotingCapability='None')]
param(
    [Parameter(ParameterSetName='WithException', Mandatory=$true)]
    [System.Exception]
    $Exception,

    [Parameter(ParameterSetName='WithException')]
    [Parameter(ParameterSetName='NoException', Mandatory=$true, Position=0, ValueFromPipeline=$true)]
    [Alias('Msg')]
    [AllowNull()]
    [AllowEmptyString()]
    [string]
    $Message,

    [Parameter(ParameterSetName='ErrorRecord', Mandatory=$true)]
    [System.Management.Automation.ErrorRecord]
    $ErrorRecord,

    [Parameter(ParameterSetName='NoException')]
    [Parameter(ParameterSetName='WithException')]
    [System.Management.Automation.ErrorCategory]
    $Category,

    [Parameter(ParameterSetName='NoException')]
    [Parameter(ParameterSetName='WithException')]
    [string]
    $ErrorId,

    [Parameter(ParameterSetName='NoException')]
    [Parameter(ParameterSetName='WithException')]
    [System.Object]
    $TargetObject,

    [string]
    $RecommendedAction,

    [Alias('Activity')]
    [string]
    $CategoryActivity,

    [Alias('Reason')]
    [string]
    $CategoryReason,

    [Alias('TargetName')]
    [string]
    $CategoryTargetName,

    [Alias('TargetType')]
    [string]
    $CategoryTargetType
) # param

Begin
{
    $Level = 'Error'
    Try {
        $Function = (Get-PSCallStack)[1].Command
        Switch($PSCmdlet.ParameterSetName) {
            "WithException" {
                $Output = $Exception.Message
            }
            "ErrorRecord" {
                $Output = $ErrorRecord.Exception.Message
            }
            Default {
                $Output = $Message
            }
        }
        Write-Log -Message $Output -Function $Function -Level $Level
    } Catch {
        $Prefix = $Script:LogPrefix.$Level
        Write-Log -Message "FAILED TO LOG $Prefix MESSAGE" -Function $('{0}\{1}' -f $Script:ModuleName,$MyInvocation.MyCommand) -Level 'Critical'
    }

    Try {
        $outBuffer = $null
        If ($PSBoundParameters.TryGetValue('OutBuffer', [ref]$outBuffer)) {
            $PSBoundParameters['OutBuffer'] = 1
        }
        $wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand('Microsoft.PowerShell.Utility\Write-Error', [System.Management.Automation.CommandTypes]::Cmdlet)
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

.ForwardHelpTargetName Microsoft.PowerShell.Utility\Write-Error
.ForwardHelpCategory Cmdlet

#>

}