if ((get-printer).Name -contains "FNOL - Tamworth"){
    Add-PrinterPort -Name "10.157.18.11" -PrinterHostAddress "10.157.18.11"
    set-printer -name "FNOL - Tamworth" -PortName "10.157.18.11"
}

if((get-printer).name -contains "Tamworth CP Room"){
    Add-PrinterPort -Name "10.157.18.12" -PrinterHostAddress "10.157.18.12"
        set-printer -name "Tamworth CP Room" -PortName "10.157.18.12"
}
if((get-printer).name -contains "Tamwork Accounts Room"){
    Add-PrinterPort -Name "10.157.18.13" -PrinterHostAddress "10.157.18.13"
        set-printer -name "Tamwork Accounts Room" -PortName "10.157.18.13"
}
if((get-printer).name -contains "Tamworth Engineers Room"){
    remove-printer -name "DQ Engineer Room Printer"
    set-printer -name "Tamworth Engineers Room" -PortName "10.157.18.10"
}
