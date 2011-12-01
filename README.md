# C&C for FIDIUS

C&C provides a webinterface for controlling FIDIUS-Core.

## Setup

For detailed setup instructions please refer to: [https://github.com/fidius/fidius-core](https://github.com/fidius/fidius-core)

You need at least FIDIUS-Core to run this. Optional Components are:

* FIDIUS-EvasionDB
* FIDIUS-CVEDB

It is a Rails 3.0.x project. C&C uses the database from FIDIUS-Core.
Please edit your database.yml properly.

    $ cd /path/to/candc/config
    $ cp database.yml.example database.yml
    $ cd /path/to/candc
    $ rails server
    $ browse to http://localhost:3000

## Authors and Contact

* FIDIUS Intrusion Detection with Intelligent User Support
  <grp-fidius@tzi.de>, <http://fidius.me>

If you have any questions, remarks, suggestion, improvements, etc. feel free to drop a line at the
addresses given above. You might also join `#fidius` on Freenode or use the contact form on our
[website](http://fidius.me/en/contact).


## License

Simplified BSD License and GNU GPLv2. See also the file LICENSE.
