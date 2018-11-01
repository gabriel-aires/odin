oo::class create Theme {
	variable Themes ChosenTheme Banners

	constructor {dark_logo light_logo} {

		if {[file exists $dark_logo] && [file exists $light_logo]} {

			set dark_img 	[image create photo -file $dark_logo]
			set light_img 	[image create photo -file $light_logo]
			set Banners 	{}
			set ChosenTheme "Default"
			dict set Themes "Default"	"name" [ttk::style theme use]
			dict set Themes "Default"	"logo" $dark_img
			dict set Themes "Light"		"name" "awlight"
			dict set Themes "Light"		"logo" $dark_img
			dict set Themes "Dark"		"name" "awdark"
			dict set Themes "Dark"		"logo" $light_img
		}
	}

	method create_banner {parent} {
		lappend Banners [::ttk::label "$parent.banner" -image [my theme_logo]]
		return [lindex $Banners end]
	}

	method theme_choose {name} {
		if [in $name [my theme_list]] {
			set ChosenTheme $name
			my theme_update
		}
	}

	method theme_list {} {
		return [dict keys $Themes]
	}

	method theme_logo {} {
		return [dict get $Themes $ChosenTheme "logo"]
	}

	method theme_name {} {
		return [dict get $Themes $ChosenTheme "name"]
	}

	method theme_update {} {
		::ttk::style theme use [my theme_name]
		foreach banner $Banners {
			$banner configure -image [my theme_logo]
		}
	}

	destructor {
		foreach banner $Banners {
			destroy $banner
		}
		puts "theme object destroyed, ref: [self]"
	}
}