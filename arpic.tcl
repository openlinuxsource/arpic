#!/usr/bin/tclsh

package require Tk

wm title . "APC Rack PDU Information Collector"
wm resizable . 0 0

if {[catch {exec which snmpget}] == 0 && [catch {exec which snmpwalk}] == 0} {
	set snmpget [exec which snmpget]
	set snmpwalk [exec which snmpwalk]
} else {
	tk_messageBox -title "No snmp utility command(s) found" -type ok -icon error -message "Please install net-snmp-utils package."
	exit
}

#Device List labelframe
labelframe .lf1 -text "Device List" -labelanchor n
listbox .lf1.devlist -background lightblue -height 28 -selectmode browse
scrollbar .lf1.y -orient vertical -command {.lf1.devlist yview}
scrollbar .lf1.x -orient horizontal -command {.lf1.devlist xview}
.lf1.devlist configure -yscrollcommand {.lf1.y set}
.lf1.devlist configure -xscrollcommand {.lf1.x set}

grid .lf1 -row 0 -column 0 -rowspan 3 -columnspan 2 -sticky nsew 
grid .lf1.devlist -row 0 -column 0 -columnspan 2 -sticky nsew
grid .lf1.y -row 0 -column 2 -sticky nsew
grid .lf1.x -row 1 -column 0 -columnspan 2 -sticky nsew
##############################

#Basic Information labelframe
labelframe .lf2 -text "Basic Information" -labelanchor n
set BI_LabelName [list {Device Name} {Model Name} {Hardware Rev} {Firmware Rev} {Date of Manufacture} {Serial Number} \
	{Amps Rating} {No. of Outlets} {No. of Phases} {No. of Banks} {No. of Breakers} {Breakers Amps Rating}]

for {set i 0} {$i <= 11} {incr i 1} {
	label .lf2.l[expr {$i+1}] -text [lindex $BI_LabelName $i] -justify left
	entry .lf2.e[expr {$i+1}] -state readonly -justify left
}

grid .lf2 -row 0 -column 2 -columnspan 3 -sticky nsew

for {set i 1} {$i <= 6} {incr i 1} {
	grid .lf2.l$i -row [expr {$i-1}] -column 0 -sticky w
	grid .lf2.e$i -row [expr {$i-1}] -column 1 -sticky e -padx {0 10}
}

for {set i 7} {$i <= 12} {incr i 1} {
        grid .lf2.l$i -row [expr {$i-7}] -column 2 -sticky w
        grid .lf2.e$i -row [expr {$i-7}] -column 3 -sticky e -padx {0 10}
}
##############################

#Outlets Status labelframe
labelframe .lf3 -text "Outlets Status" -labelanchor n
for {set i 1} {$i <= 42} {incr i 1} {
	label .lf3.l$i -text "Outlet $i" -justify left
	entry .lf3.e$i -width 10 -state readonly -justify left
}

grid .lf3 -row 1 -column 2 -columnspan 3 -sticky nsew

for {set i 1} {$i <= 42} {incr i 1} {
	if {[expr {$i/12.0}] <= 1} {
		grid .lf3.l$i -row [expr {$i-1}] -column 0 -sticky w
		grid .lf3.e$i -row [expr {$i-1}] -column 1 -sticky e -padx {0 10}
	}

	if {[expr {$i/12.0}] > 1 &&  [expr {$i/12.0}] <= 2} {
		grid .lf3.l$i -row [expr {$i-13}] -column 2 -sticky w
		grid .lf3.e$i -row [expr {$i-13}] -column 3 -sticky e -padx {0 10}
	}

	if {[expr {$i/12.0}] > 2 &&  [expr {$i/12.0}] <= 3} {
		grid .lf3.l$i -row [expr {$i-25}] -column 4 -sticky w
		grid .lf3.e$i -row [expr {$i-25}] -column 5 -sticky e -padx {0 10}
	}

	if {[expr {$i/12.0}] > 3 &&  [expr {$i/12.0}] <= 4} {
		grid .lf3.l$i -row [expr {$i-37}] -column 6 -sticky w
		grid .lf3.e$i -row [expr {$i-37}] -column 7 -sticky e -padx {0 10}
	}
}
##############################

#Device Status labelframe
labelframe .lf4 -text "Device Status" -labelanchor n
set DS_LabelName [list {Device Power in Watts} {Device Power in VA} {Phase Load in Amps} {Load Status State}]

for {set i 0} {$i <= 3} {incr i 1} {
	label .lf4.l[expr {$i+1}] -text [lindex $DS_LabelName $i] -justify left
	entry .lf4.e[expr {$i+1}] -state readonly -justify left
}

grid .lf4 -row 2 -column 2 -columnspan 3 -sticky nsew
grid .lf4.l1 -row 0 -column 0 -sticky w
grid .lf4.e1 -row 0 -column 1 -sticky e -padx {0 10}
grid .lf4.l2 -row 1 -column 0 -sticky w
grid .lf4.e2 -row 1 -column 1 -sticky e -padx {0 10}
grid .lf4.l3 -row 0 -column 2 -sticky w
grid .lf4.e3 -row 0 -column 3 -sticky e -padx {0 10}
grid .lf4.l4 -row 1 -column 2 -sticky w
grid .lf4.e4 -row 1 -column 3 -sticky e -padx {0 10}
##############################

#Buttons
button .go -text "Go" -state disabled -background green
button .clear -text "Clear All" -background orange
button .about -text "About"
button .exit -text "Exit" -background red -command {exit}

grid .go -row 3 -column 0 -columnspan 2 -sticky nsew
grid .clear -row 3 -column 2 -sticky nsew
grid .about -row 3 -column 3 -sticky nsew
grid .exit -row 3 -column 4 -sticky nsew
##############################

#Menubar
option add *Menu.tearOff 0
menu .mbar -type menubar
. configure -menu .mbar

.mbar add cascade -label "File" -menu .mbar.file
menu .mbar.file
.mbar.file add command -label "Open..." -command {
	set DevFile [tk_getOpenFile -title "Open a device list"]
	if {$DevFile == ""} {
		return
	} else {
		.lf1.devlist delete 0 end
		set FileId [open $DevFile r]
		while {[gets $FileId dev] >= 0} {
			if {$dev != ""} {	
				.lf1.devlist insert end $dev
			}
		}
		close $FileId
		.go configure -state disabled
		ClearContents
	}
}
.mbar.file add command -label "Exit" -command {exit}
##############################

#Global Procs
proc EntryInsert {entry_name value} {
	$entry_name configure -state normal
	$entry_name delete 0 end
	$entry_name insert end $value
	$entry_name configure -state readonly
}

proc ClearContents {} {
	for {set i 1} {$i <= 12} {incr i 1} {
		.lf2.e$i configure -state normal
		.lf2.e$i delete 0 end
		.lf2.e$i configure -state readonly
	}
	for {set i 1} {$i <= 42} {incr i 1} {
		.lf3.l$i configure -state normal
		.lf3.e$i configure -state normal
		.lf3.e$i delete 0 end
		.lf3.e$i configure -state readonly
	}
	for {set i 1} {$i <= 4} {incr i 1} {
		.lf4.e$i configure -state normal
		.lf4.e$i delete 0 end
		.lf4.e$i configure -state readonly
	}
}
##############################

#Basic Information Proc
proc get_basicinfo_value {DevHost} {
	EntryInsert .lf2.e1 [lindex [split [exec snmpget -v2c -c public $DevHost .1.3.6.1.4.1.318.1.1.12.1.1.0] \"] 1]
	EntryInsert .lf2.e2 [lindex [split [exec snmpget -v2c -c public $DevHost .1.3.6.1.4.1.318.1.1.12.1.5.0] \"] 1]
	EntryInsert .lf2.e3 [lindex [split [exec snmpget -v2c -c public $DevHost .1.3.6.1.4.1.318.1.1.12.1.2.0] \"] 1]
	EntryInsert .lf2.e4 [lindex [split [exec snmpget -v2c -c public $DevHost .1.3.6.1.4.1.318.1.1.12.1.3.0] \"] 1]
	EntryInsert .lf2.e5 [lindex [split [exec snmpget -v2c -c public $DevHost .1.3.6.1.4.1.318.1.1.12.1.4.0] \"] 1]
	EntryInsert .lf2.e6 [lindex [split [exec snmpget -v2c -c public $DevHost .1.3.6.1.4.1.318.1.1.12.1.6.0] \"] 1]
	EntryInsert .lf2.e7 [lindex [split [exec snmpget -v2c -c public $DevHost .1.3.6.1.4.1.318.1.1.12.1.7.0] { }] 3]
	EntryInsert .lf2.e8 [lindex [split [exec snmpget -v2c -c public $DevHost .1.3.6.1.4.1.318.1.1.12.1.8.0] { }] 3]
	EntryInsert .lf2.e9 [lindex [split [exec snmpget -v2c -c public $DevHost .1.3.6.1.4.1.318.1.1.12.1.9.0] { }] 3]
	EntryInsert .lf2.e10 [lindex [split [exec snmpget -v2c -c public $DevHost .1.3.6.1.4.1.318.1.1.12.2.1.4.0] { }] 3]
	EntryInsert .lf2.e11 [lindex [split [exec snmpget -v2c -c public $DevHost .1.3.6.1.4.1.318.1.1.12.1.10.0] { }] 3]
	EntryInsert .lf2.e12 [lindex [split [exec snmpget -v2c -c public $DevHost .1.3.6.1.4.1.318.1.1.12.1.11.0] { }] 3]
}
##############################

#Outlets Status Proc
proc get_outletstatus_value {DevHost} {
	set NumOutlets [lindex [split [exec snmpget -v2c -c public $DevHost .1.3.6.1.4.1.318.1.1.12.1.8.0] { }] 3]
	if {$NumOutlets < 42} {
		for {set i [expr {$NumOutlets+1}]} {$i <= 42 } {incr i 1} {
			.lf3.l$i configure -state disabled
		}
	}
	for {set i 1} {$i <= $NumOutlets} {incr i 1} {
		if {[lindex [split [exec snmpget -v2c -c public $DevHost .1.3.6.1.4.1.318.1.1.12.3.5.1.1.4.$i] { }] 3] == 1} {
			set state On
			.lf3.e$i configure -foreground darkgreen
		} else {
			set state Off
			.lf3.e$i configure -foreground red
		}
		EntryInsert .lf3.e$i $state
	}
}
##############################

#Status Information Proc
proc get_statusinfo_value {DevHost} {
	EntryInsert .lf4.e1 [lindex [split [exec snmpget -v2c -c public $DevHost .1.3.6.1.4.1.318.1.1.12.1.16.0] { }] 3]
	EntryInsert .lf4.e2 [lindex [split [exec snmpget -v2c -c public $DevHost .1.3.6.1.4.1.318.1.1.12.1.18.0] { }] 3]
	EntryInsert .lf4.e3 [expr {([lindex [split [exec snmpget -v2c -c public $DevHost .1.3.6.1.4.1.318.1.1.12.2.3.1.1.2.1] { }] 3]+0.0)/10}]
	set LoadState [lindex [split [exec snmpget -v2c -c public $DevHost .1.3.6.1.4.1.318.1.1.12.2.3.1.1.3.1] { }] 3]
	switch $LoadState {
		1 {
			set state Normal
			.lf4.e4 configure -foreground darkgreen
		}
		2 {
			set state {Low Load}
			.lf4.e4 configure -foreground blue
		}
		3 {
			set state {Near Over Load}
			.lf4.e4 configure -foreground darkorange
		}
		4 {
			set state {Over Load}
			.lf4.e4 configure -foreground red
		}
	}
	EntryInsert .lf4.e4 $state
}
##############################

#Bind Events
bind .lf1.devlist <<ListboxSelect>> {
	if {[.lf1.devlist curselection] != "" } {
		set dev [%W get [%W curselection]]
		.go configure -state normal
	}
}

bind .clear <ButtonRelease> {
	.lf1.devlist delete 0 end
	.go configure -state disabled
	ClearContents
	if {[info exists dev] == 1} {
		unset dev
	}
}

bind .go <ButtonRelease> {
	if {[.lf1.devlist curselection] != "" && [info exists dev] == 1} {
		if {[catch {exec snmpget -v2c -c public $dev .1.3.6.1.4.1.318.1.1.12.1.5.0}] == 0} {
			.lf1.devlist itemconfigure [.lf1.devlist curselection] -foreground darkgreen
			ClearContents
			get_basicinfo_value $dev
			get_outletstatus_value $dev
			get_statusinfo_value $dev
		} else {
			.lf1.devlist itemconfigure [.lf1.devlist curselection] -foreground red
			ClearContents
			unset dev
		}
	}
}

bind .about <ButtonRelease> {
	tk_messageBox -title "About" -type ok -icon info -message "APC Rack PDU Information Collector\nVersion 0.1.1\nAuthor: Eric Lee\nherdingcat.lee@gmail.com"
}
##############################

