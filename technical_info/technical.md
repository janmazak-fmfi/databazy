# How to setup a database

## Server cvika

You can connect via ssh to `cvika.dcs.fmph.uniba.sk`, with username and password as for the Comenius University account (e.g. AIS).
General instructions: [Linux (ssh)](https://www.ssh.com/ssh/command/#using-the-linux-client), [Windows (putty)](https://www.ssh.com/ssh/putty/windows/).


There should be SQLite and PostgreSQL available.

To download files from the web to the server cvika, use [wget](https://www.gnu.org/software/wget/manual/wget.html). Be careful when downloading from github, you want the link for the ["raw" version of the file](https://docs.github.com/en/enterprise-cloud@latest/repositories/working-with-files/using-files/viewing-a-file#viewing-or-copying-the-raw-file-content).
You might want to get some experience with efficient file transfer by using [scp](https://linuxize.com/post/how-to-use-scp-command-to-securely-transfer-files/) and [rsync](https://linuxtechlab.com/files-transfer-scp-rsync-commands/) too (it's not needed for this course).

*Warning*: the server `cvika` is not a safe storage space. While your data are likely to survive the whole semester there, no one does regular (let alone timely) backups of your data. Use the above-mentioned tools to transfer valuable files into a more secure location. Alternatively, create a git repository.

*Warning*: the server `cvika` has limited disk space and you are not supposed to install any big third-party packages (e.g. vscode-server). You can connect to the database remotely, though (see [Remote database connection](#remote-database-connection)).

If you have never tried it, we strongly encourage you to try setting up [ssh key authentication](https://www.ssh.com/ssh/key/) instead of using a password.

For viewing the contents of a file `abc.xyz`, use `cat abc.xyz` or `less abc.xyz`. For editing it, choose your favourite command-line editor --- but we suggest you at least learn the very basics of [vim](https://opensource.com/article/19/3/getting-started-vim). You might be interested in [Midnight Commander](https://midnight-commander.org/) too.

The work on a remote server is more comfortable if you open several terminals. For simple database work, you might use three windows: one terminal for general operating system commands, one to view the database, and one to write your queries.

### Remote database connection

PostgreSQL on `cvika` only accepts local connections, so to connect from your own computer (e.g. `psql`, DBeaver, or your own program in Python/Java) use an SSH tunnel (port forwarding):

1. Connect via ssh to `cvika.dcs.fmph.uniba.sk` and run `psql` (see [sql.md](./sql.md)).
2. Set a database password (needed for TCP/IP connections; your university password will not work here):
```
ALTER USER your_login WITH PASSWORD 'your_new_password';
```
You can test it on `cvika` with (the database name is usually identical with your username):
```
psql -h 127.0.0.1 your_login your_login
```
3. Create the SSH tunnel (keep it running while you work):
   * Linux: `ssh -L5433:127.0.0.1:5432 your_login@cvika.dcs.fmph.uniba.sk` (we use local port 5433 rather than the default PostgreSQL port 5432, because 5432 is often already taken on your computer by a local PostgreSQL; if you get an error like `bind: Address already in use`, the local port is taken — just pick another free one, e.g. 5444, and use it instead of 5433 everywhere below)
   * Windows: in PuTTY set up "local port forwarding" from port 5433 to `127.0.0.1:5432` (same reason: 5432 is often taken locally; if it fails, pick another free local port).

4. Connect to the forwarded port, e.g. `psql -h localhost -p 5433 -U your_login -d your_login`, or in a graphical client with host `localhost`, port `5433`. For Java, download the [PostgreSQL JDBC driver](https://jdbc.postgresql.org/download.html) and connect to `jdbc:postgresql://localhost:5433/your_login`. For Python, use e.g. `psycopg2.connect(database='your_login', user='your_login', password='your_new_password', host='localhost', port=5433)`.

## Datalog

See [datalog.md](./datalog.md).

## SQL

See [sql.md](./sql.md).

