h1.text-center {
  font-size: 500%;
  text-align: center;
}
body {
  position: relative;
  overflow-x: hidden;
  background: linear-gradient(to right, #18e9e9, #6bebfc, #00e1ff);
}
/* sidebar-form */
#wrapper {
  padding-left: 5px;
  transition: all 0.5s ease;
}
#wrapper.toggled {
  padding-left: 220px;
}
#sidebar-form-wrapper {
  z-index: 1000;
  left: 220px;
  width: 0;
  height: 100%;
  margin-left: -215px;
  overflow-y: auto;
  overflow-x: hidden;
  background: #203246; 
  transition: all 0.5s ease;
}
#sidebar-form-wrapper::-webkit-scrollbar {
  display: none;
}
#wrapper.toggled #sidebar-form-wrapper {
  width: 220px;
}
#page-content-wrapper {
  width: 100%;
  padding-top: 70px;
}
#wrapper.toggled #page-content-wrapper {
  position: absolute;
  margin-right: -215px;
}

/* sidebar-form nav styles */
.navbar {
  padding: 0;
}
.sidebar-form-nav {
  position: absolute;
  top: 0;
  width: 220px;
  margin: 0;
  padding: 0;
  list-style: none;
}
.sidebar-form-nav li {
  position: relative;
  line-height: 25px;
  display: inline-block;
  width: 100%;
}
.sidebar-form-nav li:before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  z-index: -1;
  height: 100%;
  width: 3px;
  background-color: #1c1c1c;
  transition: width .2s ease-in;
}
.sidebar-form-nav li:first-child a {
  color: #fff;
  background-color: #1a1a1a;
}
.sidebar-form-nav li:before {
  background-color: #79aefe;
}
.sidebar-form-nav li:hover:before, .sidebar-form-nav li.open:hover:before {
  width: 100%;
  transition: width .2s ease-in;
}
.sidebar-form-nav li a {
  display: block;
  color: #ddd;
  text-decoration: none;
  padding: 10px 15px 10px 30px;
}
.sidebar-form-nav li a:hover, .sidebar-form-nav li a:active, .sidebar-form-nav li a:focus, .sidebar-form-nav li.open a:hover, .sidebar-form-nav li.open a:active, .sidebar-form-nav li.open a:focus {
  color: #000000;
  text-decoration: none;
  background-color: transparent;
}
.sidebar-form-header {
  text-align: center;
  font-size: 24px;
  position: relative;
  width: 100%;
  display: inline-block;
}
.sidebar-form-brand {
  height: 65px;
  position: relative;
  background: #212531;
  background: linear-gradient(to right bottom, #2f3441 50%, #212531 50%);
  padding-top: 1em;
}
.sidebar-form-brand h1 {
  color: #ddd;
}
.sidebar-form-brand h:hover {
  color: #fff;
  text-decoration: none;
}
.sidebar-form-nav .dropdown-menu {
  position: relative;
  width: 100%;
  padding: 0;
  margin: 0;
  border-radius: 0;
  border: none;
  background-color: #c6d8e6;
  box-shadow: none;
}
.dropdown-menu.show {
  top: 0;
}

.dropdown-toggle {
  font-size: 15px;
}

.dropdown-menu li a {
  font-size: 13px; 
}

.hamburger {
  position: fixed;
  top: 20px;
  z-index: 999;
  display: block;
  width: 32px;
  height: 32px;
  margin-left: 28px;
  background: transparent;
  border: none;
}
.hamburger:hover, .hamburger:focus, .hamburger:active {
  outline: none;
}
.hamburger.is-closed:before {
  content: '';
  display: block;
  width: 100px;
  font-size: 14px;
  color: #fff;
  line-height: 32px;
  text-align: center;
  opacity: 0;
  transition: all .35s ease-in-out;
}
.hamburger.is-closed:hover:before {
  opacity: 1;
  display: block;
  transition: all .35s ease-in-out;
}
.hamburger.is-closed .hamb-top, .hamburger.is-closed .hamb-middle, .hamburger.is-closed .hamb-bottom, .hamburger.is-open .hamb-top, .hamburger.is-open .hamb-middle, .hamburger.is-open .hamb-bottom {
  position: absolute;
  left: 0;
  height: 4px;
  width: 100%;
  background-color: #000000;
}
.hamburger.is-closed .hamb-top {
  top: 5px;
  transition: all .35s ease-in-out;
}
.hamburger.is-closed .hamb-middle {
  top: 50%;
  margin-top: -2px;
}
.hamburger.is-closed .hamb-bottom {
  bottom: 5px;
  transition: all .35s ease-in-out;
}
.hamburger.is-closed:hover .hamb-top {
  top: 0;
  transition: all .35s ease-in-out;
}
.hamburger.is-closed:hover .hamb-bottom {
  bottom: 0;
  transition: all .35s ease-in-out;
}
.hamburger.is-open .hamb-top {
  top: 50%;
  margin-top: -2px;
  transform: rotate(45deg);
  transition: transform .2s cubic-bezier(.73,1,.28,.08);
}
.hamburger.is-open .hamb-middle {
  display: none;
}
.hamburger.is-open .hamb-bottom {
  top: 50%;
  margin-top: -2px;
  transform: rotate(-45deg);
  transition: transform .2s cubic-bezier(.73,1,.28,.08);
}
.hamburger.is-open .hamb-bottom, .hamburger.is-open .hamb-top {
  background-color: #1a1a1a;
}
.logout-button-container {
  margin-top: auto; 
  padding: 20px;
  width: 100%;
}

.btn-logout {
  width: 100%;
  padding: 10px 20px;
  background-color: #ffffff; 
  color: rgb(0, 0, 0);
  border: none;
  border-radius: 5px;
  text-align: center;
  font-size: 12px;
}

.btn-logout:hover {
  background-color: #000000; 
  color:  #ffffff; 
}
/* side logo */
.logo{
  width: 30%;
  float: right; /* move element to the right side */
  margin-top: 0.4%;
  margin-right: .4%;
}

/* System login page */

.font11{
  font-size: 12px;
}
.login-container {
  width: 50%;
  min-width: 360px;
  margin: auto;
  padding: 20px;
  background:#000000; 
  border-radius: 10px; 
  display: flex;
  align-items: center;
}
.form-control.username-field {
  flex: 1;
  padding: 10px 10px;
  height: auto;
  border: none;
  border-radius: 25px;
  background: linear-gradient(to right, #ffffff, #ffffff,#ffffff,#ffffff, #0a3035);
  color: #ffffff;
  margin-right: 10px;
  box-sizing: border-box;
}
.login-button {
  padding: 10px 20px;
  border: none;
  height: auto;
  border-radius: 25px;
  background: #ffffff;
  color: #000000;
  text-transform: uppercase;
  cursor: pointer;
  box-sizing: border-box;
  white-space: nowrap; 
  font-size: 12px;
}
.login-button:hover {
  background:  #18e9e9
}
.login-button:hover {
  background: #000000;
  color: #ffffff; 
}
.form-control::placeholder {
  color: #000000;
  font-size: 12px; 
}

.form-control.username-field {
  font-size: 12px; 
}

.errorMessage{
  padding-top: 10px;
  color: red;
  font-size: 15px;
}

/* form component  */

.section {
    position: relative;
    height: 0;
}

.section .section-center {
    position: absolute;
    top: 0%;
    left: 0%;
    right: 0%;
}

#data-form {
    font-family: 'PT Sans', sans-serif;
    background-image: url('../img/background.jpg');
    background-size: cover;
    background-position: center;
}

.data-form-form {
    background: rgba(0, 0, 0, 0.7);
    padding: 40px;
    border-radius: 6px;
    width: 100%;
    margin-top: 100px;
}

.data-form-form .form-group {
    position: relative;
    margin-bottom: 20px;
}

.data-form-form .form-control {
    background-color: #fff;
    height: 50px;
    color: #191a1e;
    border: none;
    font-size: 16px;
    font-weight: 400;
    -webkit-box-shadow: none;
    box-shadow: none;
    border-radius: 40px;
    padding: 0px 25px;
}

.data-form-form .form-control::-webkit-input-placeholder {
    color: rgba(82, 82, 84, 0.4);
}

.data-form-form .form-control:-ms-input-placeholder {
    color: rgba(82, 82, 84, 0.4);
}

.data-form-form .form-control::placeholder {
    color: rgba(82, 82, 84, 0.4);
}

.data-form-form input[type="date"].form-control:invalid {
    color: rgba(82, 82, 84, 0.4);
}

.data-form-form select.form-control {
    -webkit-appearance: none;
    -moz-appearance: none;
    appearance: none;
}

.data-form-form select.form-control+.select-arrow {
    position: absolute;
    right: 10px;
    bottom: 6px;
    width: 32px;
    line-height: 32px;
    height: 32px;
    text-align: center;
    pointer-events: none;
    color: rgba(0, 0, 0, 0.3);
    font-size: 14px;
}

.data-form-form select.form-control+.select-arrow:after {
    content: '\279C';
    display: block;
    -webkit-transform: rotate(90deg);
    transform: rotate(90deg);
}

.data-form-form .form-label {
    display: block;
    margin-left: 20px;
    margin-bottom: 5px;
    font-weight: 400;
    text-transform: uppercase;
    line-height: 24px;
    height: 24px;
    font-size: 12px;
    color: #fff;
}

.data-form-form .form-checkbox input {
    position: absolute !important;
    margin-left: -9999px !important;
    visibility: hidden !important;
}

.data-form-form .form-checkbox label {
    position: relative;
    padding-top: 4px;
    padding-left: 30px;
    font-weight: 400;
    color: #fff;
}

.data-form-form .form-checkbox label+label {
    margin-left: 15px;
}

.data-form-form .form-checkbox input+span {
    position: absolute;
    left: 2px;
    top: 4px;
    width: 20px;
    height: 20px;
    background: #fff;
    border-radius: 50%;
}

.data-form-form .form-checkbox input+span:after {
    content: '';
    position: absolute;
    top: 50%;
    left: 50%;
    width: 0px;
    height: 0px;
    border-radius: 50%;
    background-color: #f23e3e;
    -webkit-transition: 0.2s all;
    transition: 0.2s all;
    -webkit-transform: translate(-50%, -50%);
    transform: translate(-50%, -50%);
}

.data-form-form .form-checkbox input:not(:checked)+span:after {
    opacity: 0;
}

.data-form-form .form-checkbox input:checked+span:after {
    opacity: 1;
    width: 10px;
    height: 10px;
}

.data-form-form .form-btn {
    margin-top: 27px;
}

.data-form-form .submit-btn {
    color: #fff;
    background-color: #f23e3e;
    font-weight: 400;
    height: 50px;
    font-size: 14px;
    border: none;
    width: 100%;
    border-radius: 40px;
    text-transform: uppercase;
    -webkit-transition: 0.2s all;
    transition: 0.2s all;
}

.data-form-form .submit-btn:hover,
.data-form-form .submit-btn:focus {
    opacity: 0.9;
}

#wrapper {
    padding-left: 5px;
    transition: all 0.5s ease;
}

#wrapper.toggled {
    padding-left: 220px;
}

#sidebar-form-wrapper {
    z-index: 1000;
    left: 220px;
    width: 0;
    height: 100%;
    margin-left: -215px;
    overflow-y: auto;
    overflow-x: hidden;
    background: #203246;
    transition: all 0.5s ease;
}

#sidebar-form-wrapper::-webkit-scrollbar {
    display: none;
}

#wrapper.toggled #sidebar-form-wrapper {
    width: 220px;
}

#page-content-wrapper {
    width: 100%;
    padding-top: 70px;
    transition: all 0.5s ease;
}

#wrapper.toggled #page-content-wrapper {
    position: absolute;
    margin-right: -215px;
    margin-left: 0;
}

.overlay {
    display: none;
    position: fixed;
    width: 100%;
    height: 100%;
    top: 0;
    left: 0;
    background: rgba(0, 0, 0, 0.7);
    z-index: 1;
}

.navbar {
    padding: 0;
}

.sidebar-form-nav {
    position: absolute;
    top: 0;
    width: 220px;
    margin: 0;
    padding: 0;
    list-style: none;
}

.sidebar-form-nav li {
    position: relative;
    line-height: 25px;
    display: inline-block;
    width: 100%;
}

.sidebar-form-nav li:before {
    content: '';
    position: absolute;
    top: 0;
    left: 0;
    z-index: -1;
    height: 100%;
    width: 3px;
    background-color: #1c1c1c;
    transition: width .2s ease-in;
}

.sidebar-form-nav li:first-child a {
    color: #fff;
    background-color: #1a1a1a;
}

.sidebar-form-nav li:before {
    background-color: #79aefe;
}

.sidebar-form-nav li:hover:before,
.sidebar-form-nav li.open:hover:before {
    width: 100%;
    transition: width .2s ease-in;
}

.sidebar-form-nav li a {
    display: block;
    color: #ddd;
    text-decoration: none;
    padding: 10px 15px 10px 30px;
}


.sidebar-form-nav li a:hover, 
.sidebar-form-nav li a:active, 
.sidebar-form-nav li a:focus, 
.sidebar-form-nav li.open a:hover, 
.sidebar-form-nav li.open a:active, 
.sidebar-form-nav li.open a:focus {
    color: #000000;
    text-decoration: none;
    background-color: transparent;
}

.sidebar-form-header {
    text-align: center;
    font-size: 24px;
    position: relative;
    width: 100%;
    display: inline-block;
}

.sidebar-form-brand {
    height: 65px;
    position: relative;
    background: #212531;
    background: linear-gradient(to right bottom, #2f3441 50%, #212531 50%);
    padding-top: 1em;
}

.sidebar-form-brand h1 {
    color: #ddd;
}

.sidebar-form-brand h:hover {
    color: #fff;
    text-decoration: none;
}

.sidebar-form-nav .dropdown-menu {
    position: relative;
    width: 100%;
    padding: 0;
    margin: 0;
    border-radius: 0;
    border: none;
    background-color: #c6d8e6;
    box-shadow: none;
}

.dropdown-menu.show {
    top: 0;
}

.dropdown-toggle {
    font-size: 15px;
}

.dropdown-menu li a {
    font-size: 13px; 
}

.hamburger {
    position: fixed;
    top: 20px;
    z-index: 999;
    display: block;
    width: 32px;
    height: 32px;
    margin-left: 28px;
    background: transparent;
    border: none;
}

.hamburger:hover, 
.hamburger:focus, 
.hamburger:active {
    outline: none;
}

.hamburger.is-closed:before {
    content: '';
    display: block;
    width: 100px;
    font-size: 14px;
    color: #fff;
    line-height: 32px;
    text-align: center;
    opacity: 0;
    transition: all .35s ease-in-out;
}

.hamburger.is-closed:hover:before {
    opacity: 1;
    display: block;
    transition: all .35s ease-in-out;
}

.hamburger.is-closed .hamb-top, 
.hamburger.is-closed .hamb-middle, 
.hamburger.is-closed .hamb-bottom, 
.hamburger.is-open .hamb-top, 
.hamburger.is-open .hamb-middle, 
.hamburger.is-open .hamb-bottom {
    position: absolute;
    left: 0;
    height: 4px;
    width: 100%;
    background-color: #000000;
}

.hamburger.is-closed .hamb-top {
    top: 5px;
    transition: all .35s ease-in-out;
}

.hamburger.is-closed .hamb-middle {
    top: 50%;
    margin-top: -2px;
}

.hamburger.is-closed .hamb-bottom {
    bottom: 5px;
    transition: all .35s ease-in-out;
}

.hamburger.is-closed:hover .hamb-top {
    top: 0;
    transition: all .35s ease-in-out;
}

.hamburger.is-closed:hover .hamb-bottom {
    bottom: 0;
    transition: all .35s ease-in-out;
}

.hamburger.is-open .hamb-top {
    top: 50%;
    margin-top: -2px;
    transform: rotate(45deg);
    transition: transform .2s cubic-bezier(.73,1,.28,.08);
}

.hamburger.is-open .hamb-middle {
    display: none;
}

.hamburger.is-open .hamb-bottom {
    top: 50%;
    margin-top: -2px;
    transform: rotate(-45deg);
    transition: transform .2s cubic-bezier(.73,1,.28,.08);
}

.hamburger.is-open .hamb-bottom, 
.hamburger.is-open .hamb-top {
    background-color: #1a1a1a;
}

.logout-button-container {
    margin-top: auto; 
    padding: 20px;
    width: 100%;
}

.btn-logout {
    width: 100%;
    padding: 10px 20px;
    background-color: #ffffff; 
    color: rgb(0, 0, 0);
    border: none;
    border-radius: 5px;
    text-align: center;
    font-size: 12px;
}

.btn-logout:hover {
    background-color: #000000; 
    color:  #ffffff; 
}



