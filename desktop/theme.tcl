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
		dict set Themes "Default"		"name" [ttk::style theme use]
		dict set Themes "Default"		"logo" $dark_img
		dict set Themes "Arc"			"name" "Arc"
		dict set Themes "Arc"			"logo" $dark_img
		dict set Themes "Awdark"		"name" "awdark"
		dict set Themes "Awdark"		"logo" $light_img		
		dict set Themes "Awlight"		"name" "awlight"
		dict set Themes "Awlight"		"logo" $dark_img
		dict set Themes "Black"			"name" "black"
		dict set Themes "Black"			"logo" $light_img
		dict set Themes "Clearlooks"	"name" "clearlooks"
		dict set Themes "Clearlooks"	"logo" $dark_img
		dict set Themes "Waldorf"		"name" "waldorf"
		dict set Themes "Waldorf"		"logo" $dark_img
		
		#setup custom fonts
		set ChosenFont		{}
		set FontsAvailable	[font families]
		set FontsCreated	{}
		set regular_fonts	{}
		set monospace_fonts	{}
		
		foreach font {
			"Droid Sans"
			"Segoe UI"
            "Bitstream Charter"
			"Lucida Sans Unicode"
			"Calibri"
			"Trebuchet MS"
			"Century Gothic"
			"Tahoma"
			"Verdana"
			"Arial"
			"Georgia"
			"Helvetica"
			"Liberation Sans"
			"DejaVu Sans"
			"Bitstream Vera Sans"		
		} {
			lappend regular_fonts $font [string tolower $font]
		}
		
		foreach font {
			"Droid Sans Mono"
			"Consolas"
			"Hack"
            "Courier 10 Pitch"
			"Inconsolata"
			"Lucida Console"
			"Liberation Mono"
			"DejaVu Sans Mono"
			"Bitstream Vera Sans Mono"
			"Courier New"
			"System"
			"Terminal"
		} {
			lappend monospace_fonts $font [string tolower $font]
		}
		
		my create_font "monospace_font" 9 $monospace_fonts
		my create_font "regular_font" 9 $regular_fonts
		my font_choose "regular_font"
		
		#set system default theme
		if {$::tcl_platform(platform) eq "unix"} {
			my theme_choose "Arc"				
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

