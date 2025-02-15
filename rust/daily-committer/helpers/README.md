## Install the service

Replace the temporary variables inside the service file then move this file in `/etc/systemd/system` directory.
The next steps would be to reload systemd using `systemd daemon-reload` and start the service `systemd enable --now daily-committer.service`.
