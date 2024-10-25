# clip2nc - Remote Neovim Clipboard Syncing

A Neovim plugin for seamless clipboard syncing between local and remote machines (Mac or Linux) over SSH.

## Table of Contents

<!--toc:start-->
- [clip2nc](#clip2nc)
  - [Overview](#overview)
  - [Features](#features)
  - [Prerequisites](#prerequisites)
    - [On the local machine:](#on-the-local-machine)
    - [On the remote machine:](#on-the-remote-machine)
    - [Establish the SSH connection:](#establish-the-ssh-connection)
  - [Installation](#installation)
    - [Using [lazy.nvim](https://github.com/folke/lazy.nvim)](#using-lazynvimhttpsgithubcomfolkelazynvim)
    - [Manual Installation](#manual-installation)
  - [Usage](#usage)
  - [Configuration](#configuration)
  - [Troubleshooting](#troubleshooting)
  - [Contributing](#contributing)
  - [License](#license)
  - [Additional Setup Instructions](#additional-setup-instructions)
    - [Setting up clipboard daemons](#setting-up-clipboard-daemons)
      - [On macOS (both local and remote if applicable):](#on-macos-both-local-and-remote-if-applicable)
      - [On Linux (both local and remote if applicable):](#on-linux-both-local-and-remote-if-applicable)
<!--toc:end-->

## Overview

`clip2nc` automates the process of syncing your Neovim clipboard between a local machine and a remote machine using the `nc` (netcat) command. This plugin is designed to work in conjunction with an SSH tunnel setup, allowing you to copy text in Neovim on one machine and paste it on another without manual intervention. It supports both macOS and Linux environments.

## Features

- Automatically syncs yanked text to the remote machine's clipboard
- Syncs clipboard content when exiting Neovim
- Works seamlessly with your existing Neovim workflow
- Supports both macOS and Linux

## Prerequisites

Before using this plugin, ensure you have set up clipboard syncing between your local and remote machines:

1. Set up SSH tunneling between the two machines
2. Create launch agents (macOS) or systemd services (Linux) for clipboard daemons
3. Establish an SSH connection with port forwarding

For detailed instructions on setting up the prerequisite clipboard syncing, follow these steps:

### On the local machine

1. Add to `~/.ssh/config`:

   ```
   Host remote-machine
     HostName [IP_ADDRESS_OF_REMOTE_MACHINE]
     User [YOUR_USERNAME]
     RemoteForward 2224 127.0.0.1:2224
     RemoteForward 2225 127.0.0.1:2225
   ```

2. Set up clipboard daemons:

   For macOS:
   Create launch agents for `pbcopy` and `pbpaste` (see the Installation section for details)

   For Linux:
   Install `xclip` and create a systemd service to run `xclip` as a daemon

### On the remote machine

1. Set up clipboard daemons (same as local machine, based on OS)
2. Ensure `nc` (netcat) is installed and available in the PATH

### Establish the SSH connection

From the local machine, connect to the remote machine:

```bash
ssh remote-machine
```

## Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

Add the following to your `lua/plugins/clip2nc.lua` file:

```lua
return {
  "transcendr/clip2nc",
  event = "VeryLazy",
  opts = {},
  config = function(_, opts)
    require("clip2nc").setup(opts)
  end,
}
```

### Manual Installation

1. Clone this repository into your Neovim plugins directory:

   ```
   git clone https://github.com/transcendr/clip2nc.git ~/.local/share/nvim/site/pack/plugins/start/clip2nc
   ```

2. Add the following to your `init.lua`:

   ```lua
   require("clip2nc").setup()
   ```

## Usage

Once installed and configured, `clip2nc` works automatically. Any text you yank in Neovim will be synced to the remote machine's clipboard. The clipboard content will also be synced when you exit Neovim.

## Configuration

`clip2nc` works out of the box with default settings. However, you can customize its behavior by passing options to the `setup` function:

```lua
require("clip2nc").setup({
  -- Options here (if any)
})
```

## Troubleshooting

If you encounter issues:

1. Ensure the SSH tunnel is properly set up and active
2. Check that the `nc` command is available on both machines
3. Verify that the clipboard daemons are running on both machines:
   - For macOS: Check launch agents for `pbcopy` and `pbpaste`
   - For Linux: Check systemd service for `xclip`

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License.

## Additional Setup Instructions

### Setting up clipboard daemons

#### On macOS (both local and remote if applicable)

Create two launch agent files:

1. `~/Library/LaunchAgents/com.user.pbcopy.plist`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.user.pbcopy</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/bin/pbcopy</string>
    </array>
    <key>inetdCompatibility</key>
    <dict>
        <key>Wait</key>
        <false/>
    </dict>
    <key>Sockets</key>
    <dict>
        <key>Listeners</key>
        <dict>
            <key>SockServiceName</key>
            <string>2224</string>
        </dict>
    </dict>
</dict>
</plist>
```

2. `~/Library/LaunchAgents/com.user.pbpaste.plist`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.user.pbpaste</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/bin/pbpaste</string>
    </array>
    <key>inetdCompatibility</key>
    <dict>
        <key>Wait</key>
        <false/>
    </dict>
    <key>Sockets</key>
    <dict>
        <key>Listeners</key>
        <dict>
            <key>SockServiceName</key>
            <string>2225</string>
        </dict>
    </dict>
</dict>
</plist>
```

Load and start the launch agents:

```bash
launchctl load ~/Library/LaunchAgents/com.user.pbcopy.plist
launchctl load ~/Library/LaunchAgents/com.user.pbpaste.plist
launchctl start com.user.pbcopy
launchctl start com.user.pbpaste
```

#### On Linux (both local and remote if applicable)

1. Install xclip:

```bash
sudo apt-get install xclip  # For Debian/Ubuntu
# or
sudo yum install xclip  # For CentOS/RHEL
```

2. Create a systemd service file `/etc/systemd/system/xclip-daemon.service`:

```
[Unit]
Description=XClip Daemon
After=network.target

[Service]
ExecStart=/usr/bin/xclip -sel clip
Restart=always

[Install]
WantedBy=multi-user.target
```

3. Enable and start the service:

```bash
sudo systemctl enable xclip-daemon
sudo systemctl start xclip-daemon
```

With these setups, `clip2nc` should work seamlessly across both macOS and Linux environments.

## Further Reading

This plugin was written by AI, see the conversation [here](https://www.perplexity.ai/search/what-s-the-easiest-way-to-sync-NRcHJko2RsGc14Ko1qIIxw).
