# Jupyter
Despite being one of the most prolific modern languages, python suffers from a
dangerous amount of not-invented-here syndrome. Prepare to fight on all fronts
while python reinvents the wheels, though makes it square, just since a
text-based terminal is too intimidating for new cs students

Firstly you'll want to install python and all the other required packages:

```
# pacman -S python python-pip
# pacman -S jupyter_console python-qtconsole python-ipython-genutils
# pacman -S python-pynvim  # For neovim only
```

Next you'll want to generate the configs required for Vim to connect with
Jupyter. Follow this section of the
[readme](https://github.com/jupyter-vim/jupyter-vim#jupyter-configuration).
Jupyter does not come with manpages, though it does give useful support by using
`-h` for any of its subcommands

Now we need to make a virtual environment, otherwise pip will pollute package
dependencies all over the system. Create a new environment directory:

```
$ python3 -m venv new_env_dir
$ cd new_env_dir
$ . bin/activate
```

Now you can install packages with pip, so long as the prompt stays "activated".
If you aren't sure, open another pane and reactivate from there

```
$ python -m pip install ipykernel
$ python -m pip install numpy matplotlib networkx
```

Trying to use Jupyter now still won't work. Since virtual environments are very
thin layer that just modifies some environment variables, Jupyter will still run
as if it's being run from a normal shell. We'll need to attach this venv as a
separate kernel on the system Jupyter installation. For example:

```
$ python3 -m ipykernel install --user --name=my_kernel_name
```

Now Jupyter should see it. You can use any shell from here on, not just the
venv-activated one

```
$ jupyter kernelspec list
```

We can connect to this kernel with an option

```
$ jupyter console --kernel=my_kernel_name
```

Removing the kernel later is easy too

```
$ jupyter kernelspec remove my_kernel_name
```
