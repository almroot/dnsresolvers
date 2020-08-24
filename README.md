# fresh.sh
A bash script that fetches and maintains thousands of DNS resolvers, accessible through a local .txt on disk.

# Setup

Grab the script and setup a cron job like so:
* `wget 'https://raw.githubusercontent.com/almroot/dnsresolvers/master/fresh.sh'`
* `chmod +x fresh.sh`
* `sudo crontab -e`
* `0 2 * * * /home/user/dir/fresh.sh`

Enjoy a daily fresh list of valid DNS resolvers! The content is written to `./resolvers.txt` in the current working directory of the script.
