oo::class create Theme {
	variable Themes ChosenTheme ChosenFont Banners FontsAvailable FontsCreated

	constructor {dark_logo light_logo} {

		if [! [& [file exists $dark_logo] [file exists $light_logo]]] {
			error "error: theme could not be loaded due to missing image files"
		}
		
		#setup themes and logos
		set dark_img 	[image create photo -file $dark_logo]
		set light_img 	[image create photo -file $light_logo]
		set Banners 	{}
		set ChosenTheme {}
		dict set Themes "Default"	"name" [ttk::style theme use]
		dict set Themes "Default"	"logo" $dark_img
		dict set Themes "Light"		"name" "awlight"
		dict set Themes "Light"		"logo" $dark_img
		dict set Themes "Dark"		"name" "awdark"
		dict set Themes "Dark"		"logo" $light_img
		
		#setup custom fonts
		set ChosenFont		{}
		set FontsAvailable	[font families]
		set FontsCreated	{}
		set regular_fonts 	{
			"droid sans"
			"trebuchet ms"
			"lucida sans unicode"
			"tahoma"
			"verdana"
			"arial"
			"helvetica"
			"liberation sans"
			"sans-serif"
			"dejavu sans"
			"bitstream vera sans"
		}
		set monospace_fonts	{
			"droid sans mono"
			"hack"
			"inconsolata"
			"monospace"
			"liberation mono"
			"dejavu sans mono"
			"bitstream vera sans mono"
			"courier new"
		}
		
		my create_font "monospace_font" 9 $monospace_fonts
		my create_font "regular_font" 9 $regular_fonts
		my font_choose "regular_font"
		
		#set system default theme
		if {$::tcl_platform(platform) eq "unix"} {
			my theme_choose "Light"				
		} else {
			my theme_choose "Default"
		}
	}

	method create_font {name size family_list} {
		puts "searching for installed fonts... (type: $name)"
		foreach family $family_list {
			puts "checking font: $family"
			if [in $family $FontsAvailable] {
				font create $name -family $family -size $size
				lappend FontsCreated $name
				puts "font $name created ($family selected)"
				break
			}
		}
	}
	
	method font_choose {name} {
		if [in $name $FontsCreated] {
			set ChosenFont $name
			my font_update
		}
	}	
	
	method font_update {} {
		option clear
		option add *font $ChosenFont
		foreach class {TButton TCombobox TEntry TNotebook.Tab} {
			::ttk::style configure $class -font $ChosenFont
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
		set banners_found {}
		foreach banner $Banners {
			if [! [catch {$banner configure -image [my theme_logo]}]] {
				lappend banners_found $banner
			}
		}
		set Banners $banners_found
		my font_update
	}

	destructor {
		foreach banner $Banners {
			destroy $banner
		}
		puts "theme object destroyed, ref: [self]"
	}
}