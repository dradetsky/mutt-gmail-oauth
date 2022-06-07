mutt-gmail-oauth
================

Set up mutt (or technically neomutt) email for gmail, without having to do any
of that "enable less-secure apps" nonsense. Instead, different nonsense!

Usage
-----

TLDR: [Handy clone-n-run
example](https://github.com/dradetsky/ez-mutt-gmail-oauth-setup-example)

Run it from ansible. I've been doing something like this:

```
- name: role test book
  hosts: all
  roles:
    - role: /home/dmr/code/task/arch-setup/roles/mutt-gmail-oauth
      vars:
        mgo_user: dradetsky.test.account.other
        mgo_domain: gmail.com
```

Of course `mgo_domain` isn't strictly required (it defaults to gmail.com), but
it comes in handy if you want to use this for your work email.

Other notable options:

- `mgo_custom_rc_file`: The name of a muttrc file you can add which will be
  sourced afer the default setup, so you can override anything you don't like.

- `mgo_fullname`: Your display name for email.

Connecting
----------

We auto-create an OAuth wrapper script at
`~/.mutt/${mgo_domain}/${mgo_user}/oauth-wrap.sh`. Run this and it will print a
URL. Paste this URL into your browser and you will be directed to sign in to
gmail. You will then be asked to authorize Mozilla Thunderbird to access your
email, which may seem a bit odd but is expected behavior (OAuth experts can
probably guess what's going on here). Once you authorize "Thunderbird", you are
done. Receiving and sending mail should now work.

Key Features
------------

### Designed for multiple independent accounts

You should be able to invoke this role 3 times to set up 3 separate gmail
accounts, switch between them (or maybe use multiple independent mutts), and
have mail fetch running for all accounts simultaneously.

### Offline mail fetching

We auto-configure `offlineimap` to fetch mail, so you don't need to be online to
read mail.

### External SMTP

We use `msmtp` to actually send mail.

Limitations
-----------

### Linux bias

Automatically setting up a systemd service to run `offlineimap` obviously only
works on linux, and I don't really know how launchd works. Interested MacOS or
Windows users can consult `templates/offlineimap-user.service` and in particular
the `ExecStart` line. You can use this to figure out how to port the systemd
service to launchd (I can't really be bothered at the moment).

Alternatively, we also generate the script `1-time-imap.sh` inside the mutt user
dir, so you can just run that to get mail.

### Account switching is slightly awkward

Basically, the root muttrc (probably `~/.mutt/muttrc`) just sources an account
muttrc (at e.g. `~/.mutt/gmail.com/dradetsky.test.acct.other/muttrc`) at
startup. So if you want to use a different account you have to change the
default account you source in the root muttrc, or run e.g.

```
neomutt -F ~/.mutt/gmail.com/dradetsky.test.acct.other/muttrc
```

to choose an account directly. Hopefully I'll work out something better for this
soon.

### The OAuth tooling is still a bit of a mess

There isn't exactly a good unified little tool for getting OAuth done in a CLI
tool environment. I was forced to pick a really ugly script `mutt_oauth2.py`
(and then hack it up a bit) in order to get it to work. There's nothing wrong
with it, but its ugliness makes it a little hard to add features, like the
just-launch-a-browser-dont-make-me-copy-paste feature I'd like.

In defense of the author, it actually works, which is more than can be said for
the CLI OAuth script I wrote last time I tried to do this.

### OAuth tokens are not encrypted

This is intentional; the tight coupling of encryption to the OAuth tool that was
present in the original OAuth flow script was in my opinion a misfeature. Also
it makes it a lot harder to get started if you have to get gpg and a bunch of
other things set up and then worry about whether it's gpg or something else
that's broken. Also your threat model may not call for encrypting the OAuth
tokens that live on your laptop.

Long-term I may attempt to remedy this with various configurable wrappers which
allow the user to insert some optional (en/de)cryption step into the process.
The OAuth flow script will still continue to read a plaintext token (which may
have been decrypted by some other process) and will still emit a plaintext token
(which may then be encrypted by some other process)

Miscellaneous
-------------

### Fetch mail for an account right now

Just run the `1-time-imap.sh` script. You could also bind a key/macro to invoke
this from inside mutt.

This should be safe to run even if you have another instance of `offlineimap`
running at the moment, such as via the systemd service, since `offlineimap`
provides its own account-level locks. See their
[FAQ](https://www.offlineimap.org/doc/FAQ.html#can-i-run-multiple-instances).

### Customize an account further

There are two basic ways to customize further

#### Supply your own custom rc file

Pass the file name to `mgo_custom_rc_file`. This will be sourced after the
default rc files.

#### Edit the `editme` rc file

This file is initially blank and will not be overwritten even if you rerun the
role. It is also sourced after the default rc files.
