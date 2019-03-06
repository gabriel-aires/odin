module Style exposing (stylesheet)

import Html exposing (node, text)
import Html.Attributes exposing (type_)
import String.Format exposing (namedValue)
import PureCss exposing (pure_min_v1_css, pure_grids_custom_css)

main_css =
  """
  html {
    min-height: 100%;
  }

  body {
  	background-color: {{ bg_color }};
  	font-family: sans-serif;
    font-size: 0.8rem;
  	min-width: 160px;
  }

  hr {
    	border: 1px teal solid;
  }

  .center {
  	text-align: center;
  }

  .left {
    text-align: left;
  }

  .right {
    text-align: right;
  }

  /* Sidebar */

  #sidebar {
  	display: block;
  	background-color: {{ menu_color }};
  	color: {{ bg_color }};
  	opacity: 0.9;
  	font-size: 1rem;
  	height: 100%;
  	width: {{ sidebar_width }};
  	padding-top: 1rem;
  	position: fixed;
  	top: 0;
  	z-index: 2;
  	overflow-y: auto;
  	transition: left 0.1s linear;
  }

  #sidebar.menu-hidden {
  	left: -{{ sidebar_width }};
  }

  #sidebar.menu-visible {
  	left: 0;
  }

  #sidebar img {
  	height: 2rem;
  }

  #sidebar li:hover {
  	cursor: pointer;
  }

  #sidebar .pure-menu-item {
  	background-color: whitesmoke;
  }

  #toggle-menu {
  	display: block;
  	z-index: 3;
  	height: 2rem;
  	width: 2rem;
  	background-color: {{ menu_color }};
  	font-weight: 400;
  	font-size: 1rem;
  	padding: 0;
  	margin: 0;
  	color: {{ bg_color }};
  	transition: color 0.2s linear, background-color 0.2s linear, border 0.2s linear, left 0.1s linear, rotate 0.1s linear;
  	position: fixed;
  	top: 0;
  }

  .menu-hidden #toggle-menu {
  	left: 0;
  }

  .menu-visible #toggle-menu{
  	left: {{ sidebar_width }};
  	transform: rotate(180deg)
  }

  #toggle-menu:hover {
  	border: 1px {{ menu_color }} solid;
  	background-color: {{ bg_color }};
  	color: {{ menu_color }};
  }

  #toggle-menu:hover .shape-slash, #toggle-menu:hover .shape-backslash {
  	background-color: {{ menu_color }};
  }

  .shape-slash, .shape-backslash {
  	background-color: {{ bg_color }};
  	width: 1rem;
  	height: 0.2rem;
  }

  .shape-slash {
  	transform: translate(0.5rem, 1rem) rotate(-45deg) 			;
  }

  .shape-backslash {
  	transform: translate(0.5rem, 0.6rem) rotate(45deg) 			;
  }

  /* Content */

  #content {
  	margin-left: 0rem;
    padding: 1rem;
  }

  #page-container {
    border-top: 0.3rem teal dashed;
  }

  #page-footer {
    position: absolute;
    bottom: 0;
    right: 0;
    padding-left: 1rem;
    padding-right: 1rem;
    background-color: teal;
    border-top-left-radius: 1rem;
    color: white;
  }

  /* Responsive Layout */

  /* Tablets */
  @media screen and (min-width: 48em) {

  }

  /* Laptops, Desktops */
  @media screen and (min-width: 80em) {

  	#toggle-menu {
  		display: none;
  	}

  	#sidebar.menu-hidden, #sidebar.menu-visible {
  		opacity: 1;
  		left: 0;
  	}

  	#content {
  		margin-left: {{ sidebar_width }};
  	}
  }

  """
    |> String.Format.namedValue "bg_color"      "ghostwhite"
    |> String.Format.namedValue "menu_color"    "black"
    |> String.Format.namedValue "sidebar_width" "8.5rem"
    |> text

stylesheet =
  node "style" [ type_ "text/css" ]
    [ pure_min_v1_css
    , pure_grids_custom_css
    , main_css
    ]
