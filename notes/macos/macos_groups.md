# Groups in macos

```bash
sudo dscl . -create /groups/newgroupname
sudo dscl . -append /groups/newgroupname gid 4200
```

Creates a new group. Alternatively use System Preferences -> Users and Groups

```bash
id -Gn emiliko
```

List all the groups `emiliko` belongs to

```bash
sudo chmod -R g=u .
```

Set the group privileges of the file hierarchy rooted at `.` to be the same as
the user. Very nice to convert a directory to be editable by ssh users
