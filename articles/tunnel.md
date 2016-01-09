---
layout: post
title: Reverse SSH Tunnel on NixOS
---

Like many SSH users, I often find myself stuck behind some firewall or NAT that can't be reasoned with. Starting a reverse SSH tunnel with the -R flag is not difficult, but it's tedious to do more than once, and easy to forget to do beforehand. Plus, I'm pretty lazy. Wouldn't it be nice if we could set that up automatically?

## One Google Search Later

Fortunately, I'm not the only lazy person who uses Linux; some clever people are already leveraging systemd to do the legwork work for them. I came across an <a href="http://blog.kylemanna.com/linux/2014/02/20/ssh-reverse-tunnel-on-linux-with-systemd/">excellent post by Kyle Manna</a> that explains how to acomplish reverse SSH forwarding on Arch Linux with systemd. And since I'm lazy, rather than trying to figure out everything myself I just took his systemd unit file and ran with it.

### Setting It Up

If you just want to try out reverse SSH tunneling on NixOS yourself, the code for the NixOS module is <a href="https://github.com/auntieNeo/nixrc/blob/master/services/ssh-phone-home.nix">here in my nixrc repository</a>. To add it to your NixOS configuration, download <a href="https://raw.githubusercontent.com/auntieNeo/nixrc/master/services/ssh-phone-home.nix">ssh-phone-home.nix</a>, place it in the `/etc/nixos` directory, and add the following snippet to your `configuration.nix` file after making the appropriate modifications:

{% highlight nix %}
  imports =
    [
      ./ssh-phone-home.nix
    ];

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Enable the "SSH phone home" service for SSH reverse tunneling
  services.ssh-phone-home = {
    enable = true;
    localUser = "username";
    remoteHostname = "ssh.example.net";
    remotePort = 22;
    remoteUser = "username";
    bindPort = 2222;
  };
{% endhighlight %}

Once you rebuild your system with `nixos-rebuild switch` or equivalent, you should have an `ssh-phone-home` systemd service running. Check if it's working with the following command:

{% highlight text %}
root@localhost# systemctl status ssh-phone-home.service
{% endhighlight %}

You should see an `active (running)` message along with the exact command that the `ssh-phone-home.nix` module generated.

### Trying It Out

To SSH into your NixOS computer from a third host (`laptop` in this case), first make sure you have all of your SSH keys set up. Then issue the following commands:

{% highlight text %}
username@laptop$ ssh -l username -p 22 ssh.example.net
username@ssh$ ssh -l username -p 2222 localhost
username@nixoshost$ 
{% endhighlight %}

This is still rather tedious, but we can eliminate that extra command (and actually make things more secure) by using the ProxyCommand option. See <a href="http://backdrift.org/transparent-proxy-with-ssh">this article</a> for more information. As a quick example, my `$HOME/.ssh/config` file looks like this:

{% highlight text %}
Host nixoshost
  ProxyCommand ssh -q ssh.example.net nc localhost 2222
  User username
{% endhighlight %}

And I can connect to `nixoshost` like this:

{% highlight text %}
username@laptop$ ssh nixoshost
username@nixoshost$ 
{% endhighlight %}

Which brings about half-a-dozen commands needed to reverse SSH tunnel down to a single command!

That's it for the practical application. For those of you interested in writing a simple systemd service for NixOS, read on.

## From systemd Unit File to NixOS Module

My first instinct when starting to write the NixOS module was to dig around in nixpkgs for a similar NixOS service module. A quick peek under `nixpkgs/nixos/modules/services/networking` and I found a relatively simple module for `lshd`, which is the GNU implementation of an SSH 2 daemon.

### The Wrong Way
Here is the relevant code from the `lshd` module, heavily redacted from <a href="https://github.com/NixOS/nixpkgs/blob/4668f374448dce5ed92707eb2d20d77bf7380b47/nixos/modules/services/networking/ssh/lshd.nix">the original</a> for brevity:

{% highlight nix %}
{ config, lib, pkgs, ... }:
with lib;
let
  inherit (pkgs) lsh;
  cfg = config.services.lshd;
in
{
  options = {
    # options REDACTED
  };
  config = mkIf cfg.enable {
    jobs.lshd =
      { description = "GNU lshd SSH2 daemon";

        startOn = "started network-interfaces";
        stopOn = "stopping network-interfaces";

        exec = with cfg;
          ''
            # shell script REDACTED
          '';
      };
  };
}
{% endhighlight %}

This basic structure has everything I need to manage a simple SSH reverse forwarding service. It starts and stops with the network, and it executes a shell script.

I started writing an `ssh-phone-home.nix` module using this `lshd` module file as a template, and I made it pretty far before I noticed the following in the NixOS documentation for the `jobs` option:

> This option is a legacy method to define system services, dating from the era where NixOS used Upstart instead of systemd. You should use `systemd.services` instead.

Well great. I guess I should have read that earlier. Oh well; I had to start somewhere, and the conversion to the newer `systemd.services` method is actually rather straightforward.

### The Right Way

The following shows the basic structure of <a href="https://github.com/auntieNeo/nixrc/blob/master/services/ssh-phone-home.nix">ssh-phone-home.nix</a>, once again heavily redacted:

{% highlight nix %}
{ config, lib, pkgs, ... }:
with lib;
let
  inherit (pkgs) openssh;
  cfg = config.services.ssh-phone-home;
in
{
  options = {
    # options REDACTED
  };
  config = mkIf cfg.enable {
    systemd.services.ssh-phone-home =
    { description = "Reverse SSH tunnel as a service.";
      bindsTo = [ "network.target" ];
      serviceConfig = with cfg; {
        User = cfg.localUser;
        RestartSec = 10;  # restart every 10 seconds on failure
        Restart = "on-failure";
      };
      script = with cfg;  ''
        # shell script REDACTED
      '';
    };
  };
}
{% endhighlight %}

Notice the relatively straightforward differences. The most important difference is that I use `jobs.<name>` instead of `systemd.services.<name>`.

I also replaced the `jobs.<name>.startOn` and `jobs.<name>.stopOn` options with `systemd.services.<name>.bindsTo` which, <a href="http://nixos.org/nixos/manual/#opt-systemd.services._name_.bindsTo">according to the NixOS manual</a>, effectively performs both of those functions.

Finally, I use the `systemd.services.<name>.serviceConfig` option to run the service as a non-privileged user, as well as to set a service restart policy. This is important because I shouldn't run an SSH client as `root`. These lines were taken straight out of <a href="http://blog.kylemanna.com/linux/2014/02/20/ssh-reverse-tunnel-on-linux-with-systemd/">Kyle's script</a>. I just converted them to Nix <a href="http://nixos.org/nixos/manual/#opt-systemd.services._name_.serviceConfig">according to the manual</a>.

## Liberties Taken

I made a few changes to the SSH one-liner from <a href="http://blog.kylemanna.com/linux/2014/02/20/ssh-reverse-tunnel-on-linux-with-systemd/">Kyle's blog post</a>. Here is the shell script that was redacted from the code above:
{% highlight bash %}
${openssh}/bin/ssh -NTC \
    -o ServerAliveInterval=60 -o ExitOnForwardFailure=yes \
    -R ${toString bindPort}:localhost:22 \
    -l ${remoteUser} -p ${toString remotePort} ${remoteHostname}
{% endhighlight %}

In particular, I removed the `-o StrictHostKeyChecking=no` option that he used because it seems a bit dangerous to automatically trust any host keys. Personal experience backs up this kind of thinking, which leads me to my little anecdote on SSH security...

One year I attended the <a href="https://www.defcon.org/">DEFCON</a> security convention. I specifically remember making sure my `~/.ssh/known_hosts` file had my SSH server's host key in it, thinking I would be safe at the convention as long as I had that. Well, it actually did keep me safe, because every time I tried to connect to my server from the convention hall I would be greeted with `WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED`. Someone was performing man in the middle attacks on SSH users, and their passwords were showing up on the <a href="http://www.wallofsheep.com/pages/wall-of-sheep">Wall of Sheep</a>.

I'll leave `StrictHostKeyChecking` on just in case I ever go back to DEFCON. The only drawback is the service might fail if I don't have the host key, but it's easy enough to add host keys to `known_hosts`.

I also removed the `-i` option to specify the identity file, but not for any security reasons. The OpenSSH client can usually figure out which identity file to use automatically without the `-i` option.

## Conclusion
I learned my lesson when I didn't check the NixOS manual as soon as I started writing things, but I still feel like `nixpkgs` is a veritable minefield of quirky and deprecated structures. I hope that, in the long run, the older modules get updated to be more consistent with the newer modules. I might even submit a patch for `lshd`, since the transition looks pretty simple.

This post got a bit lengthy, and I probably could have finished this project in a third of the time if I didn't blog about it. On the other hand, I'll probably forget how to do this in the near future, and it's good to have this as a reference. In the off chance that this someone else finds this post informative, that would be nice too.
