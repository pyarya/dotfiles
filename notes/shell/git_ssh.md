# Git + SSH = :rocket:
Most git remotes, codeberg and github for example, encourage the use of SSH
keys. These are extra-secure ways to manage your project. There are generally
three types of keys

 1. Account keys: Have the same read/write access as your account
 2. Deployment: An ssh key attached to a single repository providing read access
 3. Deployment (write): Same as above with write privileges. Not the default

## Generating ssh keys for git remotes
In general, it's recommended to have a unique ssh key for every device, for
every remote. That means if I access codeberg and github on 2 computers, I
should have 4 keys in total

```bash
ssh-keygen -t ed25519 -f ~/.ssh/codeberg_key
# Hit enter twice to make it password-less
```

This will create a pair of keys, one private and one public. They'll be named
almost the same way. Feel free to upload and share the `.pub` version. Don't
ever compromise the private key, which is the one without the `.pub`

```
~/.ssh/codeberg_key
~/.ssh/codeberg_key.pub
```

You can test your keys at any time with the `-T` flag. The `-i` option here
should be unnecessary once a proper `~/.ssh/config` is setup

```bash
ssh -i ~/.ssh/codeberg_key -T git@codeberg.org
```

## User keys
User keys are used globally, so we'll configure them in `~/.ssh/config`. We do
this by aliasing against the hostname, which means ssh will expand the standard
call to codeberg.org with your alias!

```sshconfig
Host codeberg.org
    Hostname codeberg.org
    Port 22
    IdentityFile ~/.ssh/codeberg_waybook_main

Host github.com
    Hostname github.com
    Port 22
    IdentityFile ~/.ssh/github_waybook_main
```

In other words, when we do `ssh git@codeberg.org`, ssh will immediately expand
that alias into `ssh git@codeberg.org -p 22 -f ~/.ssh/codeberg_waybook_main`.
To us it simply works without any further setup per-repository

## Deployment keys
These keys are attached to a repository. For read keys, you can share one
between multiple people. For write keys, take the same precautions as user keys

Once you've generated your key, run the following in your repository:

```bash
git config core.sshCommand "ssh -i ~/.ssh/codeberg_project1_key -F /dev/null"
```

This'll add an entry to `.git/config` to override the ssh command on that
specific repository. That last `-F` tells us to ignore the global
`~/.ssh/config`, since it might have conflicting settings

## Managing multiple remotes
Using multiple remotes is no harder than one... unless you use them in
conjunction with deployment keys. It's far easier to use the same deployment key
across multiple remotes of the same repository

You can list your remotes and add new ones

```bash
git remote -v
git remote add berg ssh://codeberg.org:22/akemi/dotfiles.git
git remote rename berg ice
```

Now when using `push`, `fetch`, `pull` and other remote-dependent commands, add
the remote name followed by the branch. For example, to interact with the
`noway` branch on a remote aliased as `ice` we use

```bash
git push ice noway
git fetch ice noway
git pull ice noway
```

## Further reading
[Codeberg](https://docs.codeberg.org/security/ssh-key) provides the easiest
introduction. Note the use of ed25519, don't use RSA

[Github](https://docs.github.com/en/developers/overview/managing-deploy-keys)
has an article on deployment keys. Again, don't use RSA

[Stack
Overflow](https://superuser.com/questions/232373/how-to-tell-git-which-private-key-to-use/912281#912281)
details how to configure deployment keys per-repository
