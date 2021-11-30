# nix_config
basic nix config to bring it in line with my Arch configuration

## using

``` bash
git clone git@github.com:mcgillij/nix_config.git
cd nix_config
```
Create a symlink to `configuration.nix` and `hardware-configuration.nix` and `configs` to `/etc/nixos`

And then run `sudo nixos-rebuild switch`
