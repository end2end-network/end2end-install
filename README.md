Deploy with
`bash -c "$(wget end2end.network/install/install.sh -q -O -)" install [OPTIONS]`
as root

Options are:
```
-f -- install folder
-h -- this message
-q -- quiet, doesn't install docker or systemctl service
-i -- install docker, don't ask
-s -- install systemctl service file
-a -- add systemctl service to autostart 
