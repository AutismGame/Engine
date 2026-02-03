* Implement packets required for:
  * (C->S) Users creating their own Worlds
  * (C->S) Ability for Users to create Entities and Userdata
  * (C->S->C) Script stuff, have to talk about it
  * (C->R->C) Displaying active servers and metadata about the connection
  * (S->R) Allow servers to set the above mentioned data
  * (All) Secure Transfer (like TLS or SSL) for Authentication and sensitive requests
  * (C->R) User Creation, Registration and Log in
  * (C->R->C) Session tokens (*see below*)
* Make render.d extensible and replace all hardcoded stuff with Userdata so clients can act on the renderer
* Configuration files and Dynamic Settings
  * Unhardcoding everything and replacing static properties (ports, ips, render contexts) using configuration files like .ini and replacing dynamic properties (like volume, mouse sensitivity, fov) with Settings or Userdata, respectively
* Session token generation
  * Properties that need to be hashed to generate a asymmetrical, time-based, unique and temporary token
