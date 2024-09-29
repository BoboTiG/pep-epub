# PEP in EPUB format

![Update PEPs](https://github.com/BoboTiG/pep-epub/workflows/Update%20PEPs/badge.svg)

This is an *unofficial* repository where you can find all *valid* [PEP](https://github.com/python/peps.git) in the EPUB format.

## Repository Cloning

```bash
git clone --recursive git@github.com:BoboTiG/pep-epub.git
```

## Fetch, and Convert

You will need `pandoc`.

Just execute this script, it will fetch updated PEP, and do the EPUB conversion:

```bash
python3 script.py [--help]
```

If the `--all` argument is passed, all PEP will be updated, not just only ones updated since the last check.
