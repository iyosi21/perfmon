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
    $datetime = $dataproc.Timestamp.ToString('yyyy/mm/dd HH:mm:ss')

    #アウトプット
    Write-Output(@($item,  #CPUのトータルのみ出力`
                   $datamem.FreePhysicalMemory, $datamem.TotalVisibleMemorySize, #物理メモリの空き容量と全体容量`
                   $datamem.FreeVirtualMemory, $datamem.TotalVirtualMemorySize, #仮想メモリの空き容量と全体容量`
                   $datedisk, $dateidle, #DiskTimeとIdleTime`
                   $datetime) -join "`t") | out-file -Append "perflog_$filename.csv"   
    #30秒待機
    Start-Sleep -Seconds 1
}


