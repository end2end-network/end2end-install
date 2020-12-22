Deploy with
`bash -c "$(wget end2end.network/install/install.sh -q -O -)" install [OPTIONS]`
as root

Options are:
```
-f -- install folder
-q -- quiet, doesn't install docker or systemctl service
-i -- install docker, don't ask
-s -- install systemctl service file
-a -- add systemctl service to autostart 

# These options set container environment
--ban_attempts      -- Failet ssh login attempts before ban
--ban_time          -- For how long to ban, fail2ban format
--ban_find_interval -- How colse one to another should be failed attempts, fail2ban format
