Mechanize script for updating the userscripts.org
=======================================================

Using the Perl's WWW::Mechanize I update the script in the userscripts.org. There is possibility for the client changing in future. This is the current state:

```bash
post-userscripts-org.pl <SCRIPT ID> <FILE NAME OF THE SCRIPT>
```

It may be set as `post-commit` hook of Git.

What you need
-------------

  - WWW::Mechanize
  - JSON::Syck

Preliminary preparation
-----------------------

Create the file `accounts.json` in the home directory. Please describe the information of account in form of JSON as below:

```json
{
  "userscripts.org" : {
    "<your email address>" : {
      "password" : "<your password>"
    }
  }
}
```

If the permissions for this file are set `0600` then it will not be seen easily.

This approach with JSON may be helpful in various scenarios.