#serve elm webapp
proc endpoint-get-index {_} {
	wapp-allow-xorigin-params
	wapp-content-security-policy "off"
	serve $conf::asset_path/index.html
}

#serve static assets
proc endpoint-get-$conf::asset_folder {asset_name} {
	if {$asset_name in $conf::web_assets} {
		serve $conf::asset_path/$asset_name
	} else {
		ERROR 404
	}
}

#download agents
proc endpoint-get-api-agent {agent_platform} {

	set agent $conf::wrap_path/tclkit-$agent_platform

	switch $agent_platform {
		freebsd-x64 -
		linux-x64 -
		linux-x86 { 
			serve $agent
		}
		windows-x64 -
		windows-x86 {
			append agent .exe
			serve $agent
		}
		default {
			ERROR 404
		}
	}
}