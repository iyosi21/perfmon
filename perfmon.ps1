$filename = Get-Date -Format "yyyy-MMdd"

while(1){
    
    #CPUのProcessorTime取得
    $dataproc = Get-Counter -Counter "\Processor Information(_Total)\% Processor Time"
    $item = $dataproc.CounterSamples.CookedValue

    #Diskデータ取得
    $diskidle = Get-Counter -Counter "\PhysicalDisk(_Total)\% Idle Time"
    $disktime = Get-Counter -Counter "\PhysicalDisk(_Total)\% Disk Time"
    $dateidle = $diskidle.CounterSamples.CookedValue
    $datedisk = $disktime.CounterSamples.CookedValue

    #メモリデータ取得
    $datamem  = Get-WmiObject Win32_OperatingSystem
    $diskinfo = Get-WmiObject Win32_PerfRawData_PerfDisk_PhysicalDisk
    
    #タイムスタンプ取得
    $datetime = Get-Date -UFormat "%H:%M:%S"

    #アウトプット
    Write-Output(@($item,  #CPUのトータルのみ出力`
                   ($datamem.TotalVisibleMemorySize - $datamem.FreePhysicalMemory), #物理メモリの使用容量`
                   (($datamem.TotalVisibleMemorySize - $datamem.FreePhysicalMemory) / $datamem.TotalVisibleMemorySize), #物理メモリ使用のパーセンテージ`
                   ($datamem.TotalVirtualMemorySize - $datamem.FreeVirtualMemory), #仮想メモリの使用容量`
                   (($datamem.TotalVirtualMemorySize - $datamem.FreeVirtualMemory) / $datamem.TotalVirtualMemorySize), #仮想メモリの空き容量と全体容量`
                   $datedisk, $dateidle, #DiskTimeとIdleTime`
                   $datetime) -join "`t") | out-file -Append "perflog_$filename.csv"   
    #30秒待機
    Start-Sleep -Seconds 1
}


