# MCIR - MineCraftInitRuby ehhh... thingy :)

MCIR is a little CLI framework to make the administration of one or multiple Minecraft servers easier.
There are some build-in tasks to get you started (and to legitimate the "init" part of the name) but it isn't that hard to build your own especially if you're familiar with the Ruby programming language ;)

Just take a look at the examples, they should give you a little insight of what is possible (look at the restart task).
There isn't that much documentation yet, sorry *._.*

## Requirements
  - Ruby >= 1.9
  - git
  - Unixoid OS (such as Ubuntu/Debian, OS X, maybe others)
  - screen command installed
  - local minecraft server(s) (minecraft, bukkit, whatever)

## Setup
  0. Do everything as the user which runs the servers except maybe the symlink in step 2.
  1. Download or clone the whole thing to where you're servers are:
      <pre>
        cd ~
        git clone https://github.com/2called-chaos/MCIR.git</pre>
  2. Optional but recommended: Add the bin directory to your $PATH variable or create a symlink to the executable:
      <pre>
        echo 'export PATH="$HOME/MCIR/bin:$PATH"' >> ~/.profile && source ~/.profile
        OR
        ln -s /home/minecraft_server/MCIR/bin/mcir /usr/local/bin/mcir</pre>
  3. Install the bundle
      <pre>
        cd ~/MCIR && bundle install --without test --deployment</pre>
  4. Copy and edit the example configuration to fit your needs and server settings.
     Please note that there is currently no user support which means all servers need to run under the same user as MCIR does.
      <pre>
        cd ~/MCIR
        cp config.example.yml config.yml
        nano config.yml</pre>
  5. Dig right into it! Run `mcir --help` to get a list of default options and available actions.
     Run `mcir <action> --help` to get a list of all the action specific options.

## Actions
<pre>     kick … kick specific or all players from the server (sample task)
    start … starts a server
     stop … stops a server
  restart … restarts a server
   status … shows the status of a server
  console … attaches the screen with the console
  inspect … shows information about a server
     rcon … provides rcon accessors
    shell … gives you an interactive shell
     tail … tails the server log
</pre>

#### kick
<pre>  -a, --all                        kick all PLAYERs from the server
  -p, --players PLAYER,2nd,3rd     kicks PLAYERs from the server
  -r, --reason MSG                 specify a kick reason (def: Good bye!)
</pre>

#### start / restart
<pre>    -a, --attach                     Attach session after creation (def: false)
    -i, --inplace                    Start server without screen (def: false)
</pre>

#### stop / restart
<pre>    -f, --force                      Kill the screen immediately, ignores all following options (def: false)
    -e, --ensure                     Kill the screen if the server didn't stop after timeout is reached (def: false)
    -t, --timeout N                  Wait N seconds for the server to stop (def: 10)
    -d, --delay N                    Wait N seconds before stopping the server if --message is given) (def: 15)
    -m, --message MSG                Send message to server before waiting --delay (def: 10)
    -k, --kick [MSG]                 Kick all players before the server will shutdown (def: false)
</pre>

#### status
<pre>    -a, --all                        Check with every method
    -l, --[no-]lock                  Check lockfile (def: true)
    -s, --[no-]screen                Check screen (def: true)
    -r, --[no-]rcon                  Check rcon (def: false)
    -q, --[no-]query                 Check query (def: false)
</pre>

#### console
<pre>    -f, --fast                       Attach a screen much faster (def: false)
</pre>

#### inspect
<pre>    -a, --all                        Show everything
    -n, --none                       Show nothing
    -m, --[no-]mcir                  Show the MCIR instance config (def: true)
    -p, --[no-]plist                 Show the server's property list (def: false)
</pre>

#### rcon
<pre>    -c, --command CMD                executes the given command and return the result
    -q, --query [simple|full]        returns the result of an query (def: simple)
</pre>

#### shell
<pre>    -e, --exec CMD                   Executes the command non-interactively
</pre>

#### tail
<pre>    -b, --backlog N                  shows the last N lines of the log
    -f, --follow                     follow the file, wait for new contents
    -i, --interval                   tail interval in seconds (def: 1)
    -t, --timeout N                  wait for N seconds, then abort (def: 30)
    -w, --wait MSG                   follow file until MSG is found (incl. backlog!)
                                     MSGs starting with a slash are evaluated as regex
</pre>


## Add custom action
To add your own custom action you have two options.

If you just need a quick and simple command open the file `/home/minecraft_server/MCIR/mcir.rb` and take a look at the examples.
Otherwise take a look into the directory `/home/minecraft_server/MCIR/actions`. All default actions are there so you should have some examples to work with. All .rb files in this directory and it's subdirectories are automatically loaded.
