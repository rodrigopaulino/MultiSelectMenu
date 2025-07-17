function New-MultiSelectMenu {
    <##>
    [alias("nm")]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [alias("i")]
        [object[]]$MenuItems,
        [alias("t")]
        [string]$Title,
        [alias("h")]
        [string]$Hint = "Use arrows. 'Enter' - Return selection. 'Spacebar' - Select, 'Esc' - Exit.",
        [alias("c")]
        [ConsoleColor]$TitleColor = [ConsoleColor]::Green,
        [alias("m")]
        [int]$MaxHeight = $Host.UI.RawUI.WindowSize.Height
    )

    $SelectedItems = @($false) * $MenuItems.Count
    $SelectedIndex = 0
    $HeaderLines = 2 + ($(if ($Title) { 2 } else { 0 }))
    $VisibleItems = [Math]::Min($MaxHeight - $HeaderLines, $MenuItems.Count)
    $CursorTopOffset = $HeaderLines + $VisibleItems

    [Console]::CursorVisible = $False

    do {
        # Calculate the window of items to display
        $startIndex = [Math]::Max(0, $SelectedIndex - [Math]::Floor($VisibleItems / 2))
        if ($startIndex + $VisibleItems - 1 -ge $MenuItems.Count) {
            $startIndex = $MenuItems.Count - $VisibleItems
        }
        $startIndex = [Math]::Max(0, $startIndex)
        $endIndex = $startIndex + $VisibleItems - 1

        # Move cursor to top of menu
        [Console]::SetCursorPosition(0, [Console]::CursorTop - $CursorTopOffset)

        if ($Title) {
            Write-Host $Title -ForegroundColor $TitleColor
            Write-Host " "
        }

        Write-Host $Hint
        Write-Host " "

        for ($i = $startIndex; $i -le $endIndex; $i++) {
            Write-Host "[$(if ($SelectedItems[$i]) { $([char]0x2022) } else { ' ' })] " -NoNewline

            if ($i -eq $SelectedIndex) {
                Write-Host $MenuItems[$i] -BackgroundColor Gray -ForegroundColor Black
            } else {
                Write-Host $MenuItems[$i]
            }
        }

        # Fill remaining lines if at end of list (for smooth redraw)
        for ($j = ($endIndex + 1); $j -lt ($startIndex + $VisibleItems); $j++) {
            Write-Host ""
        }

        [Console]::SetCursorPosition(0, [Console]::CursorTop - $CursorTopOffset)

        $InputChar = [Console]::ReadKey($True)

        switch ($InputChar.Key) {
            'UpArrow'   { if ($SelectedIndex -gt 0) { $SelectedIndex-- } }
            'DownArrow' { if ($SelectedIndex -lt $MenuItems.Count - 1) { $SelectedIndex++ } }
            'Spacebar'  { $SelectedItems[$SelectedIndex] = -not $SelectedItems[$SelectedIndex] }
        }
    } while ($InputChar.Key -ne 'Enter' -and $InputChar.Key -ne 'Escape')

    [Console]::SetCursorPosition(0, [Console]::CursorTop + $CursorTopOffset)
    [Console]::CursorVisible = $True

    if ($InputChar.Key -eq 'Enter') {
        $Result = @{}
        for ($i = 0; $i -lt $MenuItems.Count; $i++) {
            $Result[$MenuItems[$i]] = $SelectedItems[$i]
        }
        return $Result
    }
}

Export-ModuleMember -Function New-MultiSelectMenu