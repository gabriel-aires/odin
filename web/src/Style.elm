module Style exposing (stylesheet)

import Html exposing (node, text)
import Html.Attributes exposing (type_)
import String.Format exposing (namedValue)
import PureCss exposing (pure_min_v1_css, pure_grids_custom_css)

main_css =
  """
  body {
  	background-color: {{ bgcolor }};
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
  	background: black;
  	color: {{ bgcolor }};
  	opacity: 0.9;
  	font-size: 1rem;
  	height: 100%;
  	width: 8.5rem;
  	padding-top: 1rem;
  	position: fixed;
  	top: 0;
  	z-index: 2;
  	overflow-y: auto;
  	transition: left 0.1s linear;
  }

  #sidebar.menu-hidden {
  	left: -8.5rem;
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
  	background-color: black;
  	font-weight: 400;
  	font-size: 1rem;
  	padding: 0;
  	margin: 0;
  	color: {{ bgcolor }};
  	transition: color 0.2s linear, background-color 0.2s linear, border 0.2s linear;
  	position: fixed;
  	top: 0;
  	transition: left 0.1s linear, rotate 0.1s linear;
  }

  .menu-hidden #toggle-menu {
  	left: 0;
  }

  .menu-visible #toggle-menu{
  	left: 8.5rem;
  	transform: rotate(180deg)
  }

  #toggle-menu:hover {
  	border: 1px black solid;
  	background-color: {{ bgcolor }};
  	color: black;
  }

  #toggle-menu:hover .shape-slash, #toggle-menu:hover .shape-backslash {
  	background-color: black;
  }

  .shape-slash, .shape-backslash {
  	background-color: {{ bgcolor }};
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
  		margin-left: 8.5rem;
  	}
  }

  """
    |> String.Format.namedValue "bgcolor" "ghostwhite"
    |> text

stylesheet =
  node "style" [ type_ "text/css" ]
    [ pure_min_v1_css
    , pure_grids_custom_css
    , main_css
    ]
