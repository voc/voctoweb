

#### Setup Vagrant Development Server

```
$ sudo apt-get install vagrant virtualbox

# or add media.ccc.vm to /etc/hosts instead
$ vagrant plugin install vagrant-hostsupdater
```

Start VM and download live data

```
$ vagrant up
$ vagrant ssh -c 'cd /vagrant && ./bin/update-data'
```

* http://media.ccc.vm:3000/ <- Frontend
* http://media.ccc.vm:3000/admin/ <- Backend
  Username: admin@example.org
  Password: media123

Running tests:
```
$ vagrant ssh
$ rails test
```
