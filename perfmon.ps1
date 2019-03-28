$filename = Get-Date -Format "yyyy-MMdd"
$beforetotalR = 0
$beforetotalW = 0

while(1){
    
    #CPUのProcessorTime取得
    $dataproc = Get-Counter -Counter "\Processor Information(_Total)\% Processor Time"
    $datatest1 = Get-Counter -Counter "\PhysicalDisk(_Total)\% Idle Time"
    $datatest1 = Get-Counter -Counter "\PhysicalDisk(_Total)\% Disk Time"

    #メモリデータ取得
    $datamem  = Get-WmiObject Win32_OperatingSystem
    $diskinfo = Get-WmiObject Win32_PerfRawData_PerfDisk_PhysicalDisk
    $datedisk = $diskinfo | ?{$_.Name -eq "_Total"}
    
    #タイムスタンプ取得
    $datetime = $dataproc.Timestamp.ToString('yyyy/mm/dd HH:mm:ss')
    $i = 1
    foreach($item in $dataproc.CounterSamples) {
        if($i -eq 1){
            if($beforetotalR -eq 0 -And $beforetotalW -eq 0){
                $beforetotalR = $datedisk.PercentDiskReadTime
                $beforetotalW = $datedisk.PercentDiskWriteTime
                $aftertotalR = $beforetotalR
                $aftertotalW = $beforetotalW
            }else{
                $beforetotalR = $datedisk.PercentDiskReadTime
                $beforetotalW = $datedisk.PercentDiskWriteTime
                if($aftertotalR -ne $beforetotalR){
                    $execR = $beforetotalR - $aftertotalR
                    $aftertotalR = $beforetotalR
                }
                if($aftertotalW -ne $beforetotalW){
                    $execW = $beforetotalW - $aftertotalW
                    $aftertotalW = $beforetotalW
                }
            }
            Write-Output(@($item.CookedValue,  #CPUのトータルのみ出力`
                            $datamem.FreePhysicalMemory, $datamem.TotalVisibleMemorySize, #物理メモリの空き容量と全体容量`
                            $datamem.FreeVirtualMemory, $datamem.TotalVirtualMemorySize, #仮想メモリの空き容量と全体容量`
                            $execR, $execW,  #DiskのReadとWrite`
                            $datetime) -join "`t") | out-file -Append "perflog_$filename.csv"
            $i = $i + 1
        }else{
            break
        }
    }
    #30秒待機
    Start-Sleep -Seconds 1
}


