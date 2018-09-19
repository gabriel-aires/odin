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

#test api
proc endpoint-get-api-user {user} {
	wapp-trim "<h1>Hello, $user!</h1>"
}