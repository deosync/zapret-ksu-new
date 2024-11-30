v 12.1:
- **service script updated:** removed lock file because script is not starting, new mechanism to check zapret started
- **uninstall & install scripts updated:** add process killing when cleaning directory, execute chmod command when service starts
- **zapret binary updated:** changed tcp 80-443 to 80,443 , add 80 to udp, removed first not needed lines

v 12.2:
- **zapret binary updated:** using config for 80-443 from original repository

v 12.3:
- **zapret binary updated:** updated bypass config for 80,443
