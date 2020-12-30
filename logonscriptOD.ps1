$LoggedOnUser = "$Env:USERNAME@EMAIL"
Start-Process "odopen://sync?useremail=$LoggedOnUser"
