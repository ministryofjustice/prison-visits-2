# Welsh translation

NOMS Wales manages translations via Transifex. This means that we:

* Write English translations in the YAML files as usual.
* Push the English up to Transifex.
* Pull down Welsh from Transifex.

In order to use Transifex, you need the client and an account.

The Transifex client is written in Python and can be installed via

```sh
$ pip install transifex-client
```

You will also need to [configure the user account for the
client](http://docs.transifex.com/client/config/#transifexrc).

To push the English translations to Transifex, use

```sh
tx push -s
```

To pull Welsh, use

```sh
tx pull -l cy
```

Then commit as usual
