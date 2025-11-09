ps glazewm -ErrorAction SilentlyContinue | kill -PassThru
ps Yasb -ErrorAction SilentlyContinue | kill -PassThru
ps Flow.Launcher -ErrorAction SilentlyContinue | kill -PassThru
    Sleep 5

$path = "d:\scoop\apps\glazewm\current\glazewm.exe"        
    $list = get-process | where-object {$_.Path -eq $path }     
        if ($list -eq $null) { start-process -filepath $path }

$path = "d:\scoop\apps\yasb\current\yasb.exe"        
    $list = get-process | where-object {$_.Path -eq $path }     
        if ($list -eq $null) { start-process -filepath $path }
		
$path = "d:\scoop\apps\flow-launcher\current\Flow.Launcher.exe"        
    $list = get-process | where-object {$_.Path -eq $path }     
        if ($list -eq $null) { start-process -filepath $path }

