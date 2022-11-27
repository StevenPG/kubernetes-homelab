# Unifi Controller Caveats

- If you're running this in a volume mount, you'll have to run `sudo chown -R 911:100 .`. The volume mount auto-configured for the nfs nobody user, which didn't allow access for the 911:100 user used by Unifi. Updating the permissions on the host resolved this issue.
