pragma Singleton
pragma ComponentBehavior: Bound

import qs.modules.common
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
	property double memoryTotal: 1
	property double memoryFree: 1
	property double memoryUsed: memoryTotal - memoryFree
    property double memoryUsedPercentage: memoryUsed / memoryTotal
    property double memoryCached: 0
    property double memoryShared: 0
    property double memoryBuffers: 0
    property string memoryFrequency: ""
    property double swapTotal: 1
	property double swapFree: 1
	property double swapUsed: swapTotal - swapFree
    property double swapUsedPercentage: swapTotal > 0 ? (swapUsed / swapTotal) : 0
    property double swapCached: 0
    property double cpuUsage: 0
    property var previousCpuStats
    property var cpuCoreUsages: []
    property var previousCpuCoreStats: []
    property var cpuCoreFrequencies: []
    property string cpuModel: ""
    property int cpuCoreCount: 0
    property double cpuTemperature: 0
    property double diskUsedPercentage: 0
    property double diskTotal: 0
    property double diskUsed: 0
    property double diskFree: 0
    property string diskDevice: ""
    property string diskFilesystem: ""
    property string diskMountPoint: ""
    property double diskInodesTotal: 0
    property double diskInodesUsed: 0
    property double diskInodesFree: 0
    property double diskInodesUsedPercentage: 0
    property double networkUpSpeed: 0
    property double networkDownSpeed: 0
    property var previousNetworkStats
    property string networkInterface: ""
    property string networkIpAddress: ""
    property string networkMacAddress: ""
    property int networkLinkSpeed: 0
    property string networkLinkState: ""
    property int networkMtu: 0
    property double networkTotalDownloaded: 0
    property double networkTotalUploaded: 0
    property double networkPacketsReceived: 0
    property double networkPacketsSent: 0
    property double networkErrors: 0
    property double networkDropped: 0

    property string maxAvailableMemoryString: kbToGbString(ResourceUsage.memoryTotal)
    property string maxAvailableSwapString: kbToGbString(ResourceUsage.swapTotal)
    property string maxAvailableCpuString: "--"

    readonly property int historyLength: Config?.options.resources.historyLength ?? 60
    property list<real> cpuUsageHistory: []
    property list<real> memoryUsageHistory: []
    property list<real> swapUsageHistory: []

    function kbToGbString(kb) {
        return (kb / (1024 * 1024)).toFixed(1) + " GB";
    }

    function updateMemoryUsageHistory() {
        memoryUsageHistory = [...memoryUsageHistory, memoryUsedPercentage]
        if (memoryUsageHistory.length > historyLength) {
            memoryUsageHistory.shift()
        }
    }
    function updateSwapUsageHistory() {
        swapUsageHistory = [...swapUsageHistory, swapUsedPercentage]
        if (swapUsageHistory.length > historyLength) {
            swapUsageHistory.shift()
        }
    }
    function updateCpuUsageHistory() {
        cpuUsageHistory = [...cpuUsageHistory, cpuUsage]
        if (cpuUsageHistory.length > historyLength) {
            cpuUsageHistory.shift()
        }
    }
    function updateHistories() {
        updateMemoryUsageHistory()
        updateSwapUsageHistory()
        updateCpuUsageHistory()
    }

	Timer {
		interval: 1
        running: true
        repeat: true
		onTriggered: {
            fileMeminfo.reload()
            fileStat.reload()
            fileNetDev.reload()
            fileCpuInfo.reload()

            const textMeminfo = fileMeminfo.text()
            memoryTotal = Number(textMeminfo.match(/MemTotal: *(\d+)/)?.[1] ?? 1)
            memoryFree = Number(textMeminfo.match(/MemAvailable: *(\d+)/)?.[1] ?? 0)
            memoryCached = Number(textMeminfo.match(/^Cached: *(\d+)/m)?.[1] ?? 0)
            memoryShared = Number(textMeminfo.match(/Shmem: *(\d+)/)?.[1] ?? 0)
            memoryBuffers = Number(textMeminfo.match(/Buffers: *(\d+)/)?.[1] ?? 0)
            swapTotal = Number(textMeminfo.match(/SwapTotal: *(\d+)/)?.[1] ?? 1)
            swapFree = Number(textMeminfo.match(/SwapFree: *(\d+)/)?.[1] ?? 0)
            swapCached = Number(textMeminfo.match(/SwapCached: *(\d+)/)?.[1] ?? 0)

            const textStat = fileStat.text()
            const cpuLine = textStat.match(/^cpu\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)/)
            if (cpuLine) {
                const stats = cpuLine.slice(1).map(Number)
                const total = stats.reduce((a, b) => a + b, 0)
                const idle = stats[3]

                if (previousCpuStats) {
                    const totalDiff = total - previousCpuStats.total
                    const idleDiff = idle - previousCpuStats.idle
                    cpuUsage = totalDiff > 0 ? (1 - idleDiff / totalDiff) : 0
                }

                previousCpuStats = { total, idle }
            }

            const coreLines = textStat.match(/^cpu\d+\s+.+/gm)
            if (coreLines) {
                const newCoreUsages = []
                const newCoreStats = []

                for (let i = 0; i < coreLines.length; i++) {
                    const coreLine = coreLines[i].match(/^cpu\d+\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)/)
                    if (coreLine) {
                        const stats = coreLine.slice(1).map(Number)
                        const total = stats.reduce((a, b) => a + b, 0)
                        const idle = stats[3]

                        let usage = 0
                        if (previousCpuCoreStats[i]) {
                            const totalDiff = total - previousCpuCoreStats[i].total
                            const idleDiff = idle - previousCpuCoreStats[i].idle
                            usage = totalDiff > 0 ? (1 - idleDiff / totalDiff) : 0
                        }

                        newCoreUsages.push(usage)
                        newCoreStats.push({ total, idle })
                    }
                }

                cpuCoreUsages = newCoreUsages
                previousCpuCoreStats = newCoreStats
                cpuCoreCount = newCoreUsages.length
            }

            const textCpuInfo = fileCpuInfo.text()
            const modelMatch = textCpuInfo.match(/model name\s*:\s*(.+)/)
            if (modelMatch) {
                cpuModel = modelMatch[1].trim()
            }

            cpuFrequencyProcess.running = true
            cpuTemperatureProcess.running = true
            memoryFrequencyProcess.running = true

            const textNetDev = fileNetDev.text()
            const lines = textNetDev.split('\n')
            let totalRxBytes = 0, totalTxBytes = 0, totalRxPackets = 0, totalTxPackets = 0
            let totalErrors = 0, totalDropped = 0
            let activeInterface = ""

            for (let i = 2; i < lines.length; i++) {
                const line = lines[i].trim()
                if (line && !line.startsWith('lo:') && !line.startsWith('docker')) {
                    const parts = line.split(/\s+/)
                    if (parts.length >= 10) {
                        const rxBytes = Number(parts[1]) || 0
                        const txBytes = Number(parts[9]) || 0

                        if (rxBytes > 0 || txBytes > 0) {
                            if (!activeInterface || rxBytes > totalRxBytes) {
                                activeInterface = parts[0].replace(':', '')
                            }
                            totalRxBytes += rxBytes
                            totalTxBytes += txBytes
                            totalRxPackets += Number(parts[2]) || 0
                            totalTxPackets += Number(parts[10]) || 0
                            totalErrors += (Number(parts[3]) || 0) + (Number(parts[11]) || 0)
                            totalDropped += (Number(parts[4]) || 0) + (Number(parts[12]) || 0)
                        }
                    }
                }
            }

            networkTotalDownloaded = totalRxBytes
            networkTotalUploaded = totalTxBytes
            networkPacketsReceived = totalRxPackets
            networkPacketsSent = totalTxPackets
            networkErrors = totalErrors
            networkDropped = totalDropped
            networkInterface = activeInterface

            if (previousNetworkStats) {
                const timeDiff = (Config.options?.resources?.updateInterval ?? 3000) / 1000
                const rxDiff = totalRxBytes - previousNetworkStats.rx
                const txDiff = totalTxBytes - previousNetworkStats.tx
                networkDownSpeed = Math.max(0, rxDiff / timeDiff)
                networkUpSpeed = Math.max(0, txDiff / timeDiff)
            }

            previousNetworkStats = { rx: totalRxBytes, tx: totalTxBytes }

            if (networkInterface) {
                networkInfoProcess.running = true
            }

            diskUsageProcess.running = true

            root.updateHistories()
            interval = Config.options?.resources?.updateInterval ?? 3000
        }
	}

	FileView { id: fileMeminfo; path: "/proc/meminfo" }
    FileView { id: fileStat; path: "/proc/stat" }
    FileView { id: fileNetDev; path: "/proc/net/dev" }
    FileView { id: fileCpuInfo; path: "/proc/cpuinfo" }

    Process {
        id: diskUsageProcess
        command: ["sh", "-c", "df / --output=source,fstype,target,pcent,size,used,avail -B1 && echo '---' && df -i /"]
        stdout: StdioCollector {
            onStreamFinished: {
                const parts = text.trim().split('---')

                if (parts[0]) {
                    const lines = parts[0].trim().split('\n')
                    if (lines.length >= 2) {
                        const fields = lines[1].trim().split(/\s+/)
                        if (fields.length >= 7) {
                            diskDevice = fields[0] || ""
                            diskFilesystem = fields[1] || ""
                            diskMountPoint = fields[2] || ""
                            const percentStr = fields[3].replace('%', '').trim()
                            diskUsedPercentage = Number(percentStr) / 100 || 0
                            diskTotal = Number(fields[4]) || 0
                            diskUsed = Number(fields[5]) || 0
                            diskFree = Number(fields[6]) || 0
                        }
                    }
                }

                if (parts[1]) {
                    const lines = parts[1].trim().split('\n')
                    if (lines.length >= 2) {
                        const fields = lines[1].trim().split(/\s+/)
                        if (fields.length >= 5) {
                            diskInodesTotal = Number(fields[1]) || 0
                            diskInodesUsed = Number(fields[2]) || 0
                            diskInodesFree = Number(fields[3]) || 0
                            const percentStr = fields[4].replace('%', '').trim()
                            diskInodesUsedPercentage = Number(percentStr) / 100 || 0
                        }
                    }
                }
            }
        }
    }

    Process {
        id: cpuFrequencyProcess
        command: ["sh", "-c", "cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_cur_freq 2>/dev/null || echo ''"]
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.trim().split('\n').filter(line => line.length > 0)
                cpuCoreFrequencies = lines.map(freq => Number(freq))
            }
        }
    }

    Process {
        id: cpuTemperatureProcess
        command: ["sh", "-c", "sensors 2>/dev/null | grep -i 'Tctl\\|Tdie' | head -1 | grep -oP '\\+?\\d+\\.\\d+' | head -1 || echo '0'"]
        stdout: StdioCollector {
            onStreamFinished: {
                const temp = Number(text.trim())
                cpuTemperature = temp
            }
        }
    }

    Process {
        id: memoryFrequencyProcess
        command: ["sh", "-c", "dmidecode -t memory 2>/dev/null | grep -i 'Speed:' | grep -v 'Configured' | head -1 | grep -oP '\\d+' | head -1 || echo ''"]
        stdout: StdioCollector {
            onStreamFinished: {
                const freq = text.trim()
                if (freq && freq !== '') {
                    memoryFrequency = freq + " MHz"
                }
            }
        }
    }

    Process {
        id: networkInfoProcess
        property string iface: root.networkInterface
        command: ["sh", "-c", `ip -4 addr show ${iface} 2>/dev/null | grep -oP 'inet \\K[\\d.]+' && cat /sys/class/net/${iface}/address 2>/dev/null && cat /sys/class/net/${iface}/speed 2>/dev/null && cat /sys/class/net/${iface}/operstate 2>/dev/null && cat /sys/class/net/${iface}/mtu 2>/dev/null`]
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.trim().split('\n')
                if (lines.length >= 5) {
                    networkIpAddress = lines[0] || ""
                    networkMacAddress = lines[1] || ""
                    networkLinkSpeed = Number(lines[2]) || 0
                    networkLinkState = lines[3] || ""
                    networkMtu = Number(lines[4]) || 0
                }
            }
        }
    }

    Process {
        id: findCpuMaxFreqProc
        environment: ({
            LANG: "C",
            LC_ALL: "C"
        })
        command: ["bash", "-c", "lscpu | grep 'CPU max MHz' | awk '{print $4}'"]
        running: true
        stdout: StdioCollector {
            id: cpuMaxFreqCollector
            onStreamFinished: {
                root.maxAvailableCpuString = (parseFloat(cpuMaxFreqCollector.text) / 1000).toFixed(0) + " GHz"
            }
        }
    }
}
