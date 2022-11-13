# Errors and Issues

## No SSHD Hostkeys Available after Fresh Installation

So! While writing the steps for Part_3_Configuring_Our_Nodes, I ran into an issue I hadn't seen before where sshd wouldn't start up on one of my machines.

So I grabbed my trusty energy drink and wandered down to the basement, plugged in a keyboard and monitor, and went through the following steps.

The error was as follows:

    sshd: no hostkeys available -- exiting

Through a little bit of searching and trial and error, I realized that in the /etc/ssh folder, there were no configured keys for the server to actually use.

I executed `ssh-keygen -A` to generate these keys, and then I restarted the SSH Daemon using `service sshd restart`

And that was it! SSHD came up, and I went back to treating the system like the others.
