 
$MainForm_Load={
#TODO: Initialize Form Controls here
    Import-Module skypeonlineconnector
}
 
$buttonCallChildForm_Click={
    #TODO: Place custom script here
    if((Show-ChildForm_psf) -eq 'OK')
    {
        
    }
}
 
#region Control Helper Functions
function Update-ListViewColumnSort
{
<#
    .SYNOPSIS
        Sort the ListView's item using the specified column.
    
    .DESCRIPTION
        Sort the ListView's item using the specified column.
        This function uses Add-Type to define a class that sort the items.
        The ListView's Tag property is used to keep track of the sorting.
    
    .PARAMETER ListView
        The ListView control to sort.
    
    .PARAMETER ColumnIndex
        The index of the column to use for sorting.
    
    .PARAMETER SortOrder
        The direction to sort the items. If not specified or set to None, it will toggle.
    
    .EXAMPLE
        Update-ListViewColumnSort -ListView $listview1 -ColumnIndex 0
    
    .NOTES
        Additional information about the function.
#>
    
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [System.Windows.Forms.ListView]
        $ListView,
        [Parameter(Mandatory = $true)]
        [int]
        $ColumnIndex,
        [System.Windows.Forms.SortOrder]
        $SortOrder = 'None'
    )
    
    if (($ListView.Items.Count -eq 0) -or ($ColumnIndex -lt 0) -or ($ColumnIndex -ge $ListView.Columns.Count))
    {
        return;
    }
    
    #region Define ListViewItemComparer
    try
    {
        [ListViewItemComparer] | Out-Null
    }
    catch
    {
        Add-Type -ReferencedAssemblies ('System.Windows.Forms') -TypeDefinition  @" 
    using System;
    using System.Windows.Forms;
    using System.Collections;
    public class ListViewItemComparer : IComparer
    {
        public int column;
        public SortOrder sortOrder;
        public ListViewItemComparer()
        {
            column = 0;
            sortOrder = SortOrder.Ascending;
        }
        public ListViewItemComparer(int column, SortOrder sort)
        {
            this.column = column;
            sortOrder = sort;
        }
        public int Compare(object x, object y)
        {
            if(column >= ((ListViewItem)x).SubItems.Count)
                return  sortOrder == SortOrder.Ascending ? -1 : 1;
        
            if(column >= ((ListViewItem)y).SubItems.Count)
                return sortOrder == SortOrder.Ascending ? 1 : -1;
        
            if(sortOrder == SortOrder.Ascending)
                return String.Compare(((ListViewItem)x).SubItems[column].Text, ((ListViewItem)y).SubItems[column].Text);
            else
                return String.Compare(((ListViewItem)y).SubItems[column].Text, ((ListViewItem)x).SubItems[column].Text);
        }
    }
"@ | Out-Null
    }
    #endregion
    
    if ($ListView.Tag -is [ListViewItemComparer])
    {
        #Toggle the Sort Order
        if ($SortOrder -eq [System.Windows.Forms.SortOrder]::None)
        {
            if ($ListView.Tag.column -eq $ColumnIndex -and $ListView.Tag.sortOrder -eq 'Ascending')
            {
                $ListView.Tag.sortOrder = 'Descending'
            }
            else
            {
                $ListView.Tag.sortOrder = 'Ascending'
            }
        }
        else
        {
            $ListView.Tag.sortOrder = $SortOrder
        }
        
        $ListView.Tag.column = $ColumnIndex
        $ListView.Sort() #Sort the items
    }
    else
    {
        if ($SortOrder -eq [System.Windows.Forms.SortOrder]::None)
        {
            $SortOrder = [System.Windows.Forms.SortOrder]::Ascending
        }
        
        #Set to Tag because for some reason in PowerShell ListViewItemSorter prop returns null
        $ListView.Tag = New-Object ListViewItemComparer ($ColumnIndex, $SortOrder)
        $ListView.ListViewItemSorter = $ListView.Tag #Automatically sorts
    }
}
 
 
 
function Add-ListViewItem
{
<#
    .SYNOPSIS
        Adds the item(s) to the ListView and stores the object in the ListViewItem's Tag property.
 
    .DESCRIPTION
        Adds the item(s) to the ListView and stores the object in the ListViewItem's Tag property.
 
    .PARAMETER ListView
        The ListView control to add the items to.
 
    .PARAMETER Items
        The object or objects you wish to load into the ListView's Items collection.
        
    .PARAMETER  ImageIndex
        The index of a predefined image in the ListView's ImageList.
    
    .PARAMETER  SubItems
        List of strings to add as Subitems.
    
    .PARAMETER Group
        The group to place the item(s) in.
    
    .PARAMETER Clear
        This switch clears the ListView's Items before adding the new item(s).
    
    .EXAMPLE
        Add-ListViewItem -ListView $listview1 -Items "Test" -Group $listview1.Groups[0] -ImageIndex 0 -SubItems "Installed"
#>
    
    Param( 
    [ValidateNotNull()]
    [Parameter(Mandatory=$true)]
    [System.Windows.Forms.ListView]$ListView,
    [ValidateNotNull()]
    [Parameter(Mandatory=$true)]
    $Items,
    [int]$ImageIndex = -1,
    [string[]]$SubItems,
    $Group,
    [switch]$Clear)
    
    if($Clear)
    {
        $ListView.Items.Clear();
    }
    
    $lvGroup = $null
    if ($Group -is [System.Windows.Forms.ListViewGroup])
    {
        $lvGroup = $Group
    }
    elseif ($Group -is [string])
    {
        #$lvGroup = $ListView.Group[$Group] # Case sensitive
        foreach ($groupItem in $ListView.Groups)
        {
            if ($groupItem.Name -eq $Group)
            {
                $lvGroup = $groupItem
                break
            }
        }
        
        if ($null -eq $lvGroup)
        {
            $lvGroup = $ListView.Groups.Add($Group, $Group)
        }
    }
    
    if($Items -is [Array])
    {
        $ListView.BeginUpdate()
        foreach ($item in $Items)
        {       
            $listitem  = $ListView.Items.Add($item.ToString(), $ImageIndex)
            #Store the object in the Tag
            $listitem.Tag = $item
            
            if($null -ne $SubItems)
            {
                $listitem.SubItems.AddRange($SubItems)
            }
            
            if($null -ne $lvGroup)
            {
                $listitem.Group = $lvGroup
            }
        }
        $ListView.EndUpdate()
    }
    else
    {
        #Add a new item to the ListView
        $listitem  = $ListView.Items.Add($Items.ToString(), $ImageIndex)
        #Store the object in the Tag
        $listitem.Tag = $Items
        
        if($null -ne $SubItems)
        {
            $listitem.SubItems.AddRange($SubItems)
        }
        
        if($null -ne $lvGroup)
        {
            $listitem.Group = $lvGroup
        }
    }
}
 
 
 
function Update-ListBox
{
<#
    .SYNOPSIS
        This functions helps you load items into a ListBox or CheckedListBox.
    
    .DESCRIPTION
        Use this function to dynamically load items into the ListBox control.
    
    .PARAMETER ListBox
        The ListBox control you want to add items to.
    
    .PARAMETER Items
        The object or objects you wish to load into the ListBox's Items collection.
    
    .PARAMETER DisplayMember
        Indicates the property to display for the items in this control.
        
    .PARAMETER ValueMember
        Indicates the property to use for the value of the control.
    
    .PARAMETER Append
        Adds the item(s) to the ListBox without clearing the Items collection.
    
    .EXAMPLE
        Update-ListBox $ListBox1 "Red", "White", "Blue"
    
    .EXAMPLE
        Update-ListBox $listBox1 "Red" -Append
        Update-ListBox $listBox1 "White" -Append
        Update-ListBox $listBox1 "Blue" -Append
    
    .EXAMPLE
        Update-ListBox $listBox1 (Get-Process) "ProcessName"
    
    .NOTES
        Additional information about the function.
#>
    
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [System.Windows.Forms.ListBox]
        $ListBox,
        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        $Items,
        [Parameter(Mandatory = $false)]
        [string]$DisplayMember,
        [Parameter(Mandatory = $false)]
        [string]$ValueMember,
        [switch]
        $Append
    )
    
    if (-not $Append)
    {
        $ListBox.Items.Clear()
    }
    
    if ($Items -is [System.Windows.Forms.ListBox+ObjectCollection] -or $Items -is [System.Collections.ICollection])
    {
        $ListBox.Items.AddRange($Items)
    }
    elseif ($Items -is [System.Collections.IEnumerable])
    {
        $ListBox.BeginUpdate()
        foreach ($obj in $Items)
        {
            $ListBox.Items.Add($obj)
        }
        $ListBox.EndUpdate()
    }
    else
    {
        $ListBox.Items.Add($Items)
    }
    
    if ($DisplayMember)
    {
        $ListBox.DisplayMember = $DisplayMember
    }
    if ($ValueMember)
    {
        $ListBox.ValueMember = $ValueMember
    }
}
 
 
 
function Update-ComboBox
{
<#
    .SYNOPSIS
        This functions helps you load items into a ComboBox.
    
    .DESCRIPTION
        Use this function to dynamically load items into the ComboBox control.
    
    .PARAMETER ComboBox
        The ComboBox control you want to add items to.
    
    .PARAMETER Items
        The object or objects you wish to load into the ComboBox's Items collection.
    
    .PARAMETER DisplayMember
        Indicates the property to display for the items in this control.
        
    .PARAMETER ValueMember
        Indicates the property to use for the value of the control.
    
    .PARAMETER Append
        Adds the item(s) to the ComboBox without clearing the Items collection.
    
    .EXAMPLE
        Update-ComboBox $combobox1 "Red", "White", "Blue"
    
    .EXAMPLE
        Update-ComboBox $combobox1 "Red" -Append
        Update-ComboBox $combobox1 "White" -Append
        Update-ComboBox $combobox1 "Blue" -Append
    
    .EXAMPLE
        Update-ComboBox $combobox1 (Get-Process) "ProcessName"
    
    .NOTES
        Additional information about the function.
#>
    
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [System.Windows.Forms.ComboBox]
        $ComboBox,
        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        $Items,
        [Parameter(Mandatory = $false)]
        [string]$DisplayMember,
        [Parameter(Mandatory = $false)]
        [string]$ValueMember,
        [switch]
        $Append
    )
    
    if (-not $Append)
    {
        $ComboBox.Items.Clear()
    }
    
    if ($Items -is [Object[]])
    {
        $ComboBox.Items.AddRange($Items)
    }
    elseif ($Items -is [System.Collections.IEnumerable])
    {
        $ComboBox.BeginUpdate()
        foreach ($obj in $Items)
        {
            $ComboBox.Items.Add($obj)
        }
        $ComboBox.EndUpdate()
    }
    else
    {
        $ComboBox.Items.Add($Items)
    }
    
    if ($DisplayMember)
    {
        $ComboBox.DisplayMember = $DisplayMember
    }
    
    if ($ValueMember)
    {
        $ComboBox.ValueMember = $ValueMember
    }
}
 
 
 
function Update-DataGridView
{
    <#
    .SYNOPSIS
        This functions helps you load items into a DataGridView.
 
    .DESCRIPTION
        Use this function to dynamically load items into the DataGridView control.
 
    .PARAMETER  DataGridView
        The DataGridView control you want to add items to.
 
    .PARAMETER  Item
        The object or objects you wish to load into the DataGridView's items collection.
    
    .PARAMETER  DataMember
        Sets the name of the list or table in the data source for which the DataGridView is displaying data.
 
    .PARAMETER AutoSizeColumns
        Resizes DataGridView control's columns after loading the items.
    #>
    Param (
        [ValidateNotNull()]
        [Parameter(Mandatory=$true)]
        [System.Windows.Forms.DataGridView]$DataGridView,
        [ValidateNotNull()]
        [Parameter(Mandatory=$true)]
        $Item,
        [Parameter(Mandatory=$false)]
        [string]$DataMember,
        [System.Windows.Forms.DataGridViewAutoSizeColumnsMode]$AutoSizeColumns = 'None'
    )
    $DataGridView.SuspendLayout()
    $DataGridView.DataMember = $DataMember
    
    if ($null -eq $Item)
    {
        $DataGridView.DataSource = $null
    }
    elseif ($Item -is [System.Data.DataSet] -and $Item.Tables.Count -gt 0)
    {
        $DataGridView.DataSource = $Item.Tables[0]
    }
    elseif ($Item -is [System.ComponentModel.IListSource]`
    -or $Item -is [System.ComponentModel.IBindingList] -or $Item -is [System.ComponentModel.IBindingListView] )
    {
        $DataGridView.DataSource = $Item
    }
    else
    {
        $array = New-Object System.Collections.ArrayList
        
        if ($Item -is [System.Collections.IList])
        {
            $array.AddRange($Item)
        }
        else
        {
            $array.Add($Item)
        }
        $DataGridView.DataSource = $array
    }
    
    if ($AutoSizeColumns -ne 'None')
    {
        $DataGridView.AutoResizeColumns($AutoSizeColumns)
    }
    
    $DataGridView.ResumeLayout()
}
 
 
 
function ConvertTo-DataTable
{
    <#
        .SYNOPSIS
            Converts objects into a DataTable.
    
        .DESCRIPTION
            Converts objects into a DataTable, which are used for DataBinding.
    
        .PARAMETER  InputObject
            The input to convert into a DataTable.
    
        .PARAMETER  Table
            The DataTable you wish to load the input into.
    
        .PARAMETER RetainColumns
            This switch tells the function to keep the DataTable's existing columns.
        
        .PARAMETER FilterCIMProperties
            This switch removes CIM properties that start with an underline.
    
        .EXAMPLE
            $DataTable = ConvertTo-DataTable -InputObject (Get-Process)
    #>
    [OutputType([System.Data.DataTable])]
    param(
    $InputObject, 
    [ValidateNotNull()]
    [System.Data.DataTable]$Table,
    [switch]$RetainColumns,
    [switch]$FilterCIMProperties)
    
    if($null -eq $Table)
    {
        $Table = New-Object System.Data.DataTable
    }
    
    if ($null -eq $InputObject)
    {
        $Table.Clear()
        return @( ,$Table)
    }
    
    if ($InputObject -is [System.Data.DataTable])
    {
        $Table = $InputObject
    }
    elseif ($InputObject -is [System.Data.DataSet] -and $InputObject.Tables.Count -gt 0)
    {
        $Table = $InputObject.Tables[0]
    }
    else
    {
        if (-not $RetainColumns -or $Table.Columns.Count -eq 0)
        {
            #Clear out the Table Contents
            $Table.Clear()
            
            if ($null -eq $InputObject) { return } #Empty Data
            
            $object = $null
            #find the first non null value
            foreach ($item in $InputObject)
            {
                if ($null -ne $item)
                {
                    $object = $item
                    break
                }
            }
            
            if ($null -eq $object) { return } #All null then empty
            
            #Get all the properties in order to create the columns
            foreach ($prop in $object.PSObject.Get_Properties())
            {
                if (-not $FilterCIMProperties -or -not $prop.Name.StartsWith('__')) #filter out CIM properties
                {
                    #Get the type from the Definition string
                    $type = $null
                    
                    if ($null -ne $prop.Value)
                    {
                        try { $type = $prop.Value.GetType() }
                        catch { Out-Null }
                    }
                    
                    if ($null -ne $type) # -and [System.Type]::GetTypeCode($type) -ne 'Object')
                    {
                        [void]$table.Columns.Add($prop.Name, $type)
                    }
                    else #Type info not found
                    {
                        [void]$table.Columns.Add($prop.Name)
                    }
                }
            }
            
            if ($object -is [System.Data.DataRow])
            {
                foreach ($item in $InputObject)
                {
                    $Table.Rows.Add($item)
                }
                return @( ,$Table)
            }
        }
        else
        {
            $Table.Rows.Clear()
        }
        
        foreach ($item in $InputObject)
        {
            $row = $table.NewRow()
            
            if ($item)
            {
                foreach ($prop in $item.PSObject.Get_Properties())
                {
                    if ($table.Columns.Contains($prop.Name))
                    {
                        $row.Item($prop.Name) = $prop.Value
                    }
                }
            }
            [void]$table.Rows.Add($row)
        }
    }
    
    return @(,$Table)
}
 
 
#endregion
 

$buttonConnect_Click={
    #TODO: Place custom script here
    $session = new-csonlinesession -Username $textboxAdminEmail.Text
    Import-PSSession $session
    $sessionChk = $session.state
        if ($sessionChk -match "Opened")
        {
            #Add-Type -AssemblyName "System.Windows.Forms, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089"
            [void][System.Windows.Forms.MessageBox]::Show('Connected to office 365 tenant successfully!', 'Connected successfully!') # Casting the method to [void] suppresses the output. 
        $buttonDisconect.Enabled = $true
        $buttonDisconect.Visible = $true
        #$users = Get-CsOnlineUser | Select-Object WindowsEmailAddress | ForEach-Object {}
        Update-ListBox $listboxUsers (Get-CsOnlineUser | ForEach-Object {$_.WindowsEmailAddress})
        }
}
 
$buttonDisconect_Click={
    #TODO: Place custom script here
    Remove-PSSession 1
    $listboxUsers.Items.Clear()
    $buttonDisconect.Enabled = $false
}
 
$labelEnterpriseVoiceEnabl_Click={
    #TODO: Place custom script here
    
}
 
$listboxUsers_SelectedIndexChanged={
    #TODO: Place custom script here
    $EnterpriseVoiceStatus = $listboxUsers.SelectedItem
    $textboxAdminEmail.Text = $EnterpriseVoiceStatus
}
 