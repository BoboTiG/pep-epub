# PEPs in EPUB format

![Update PEPs](https://github.com/BoboTiG/pep-epub/workflows/Update%20PEPs/badge.svg)

This is a *unofficial* repository where you can find all *valid* [PEP](https://github.com/python/peps.git)s in the EPUB format.

## Repository Cloning

```bash
git clone --recursive git@github.com:BoboTiG/pep-epub.git
```

## Fetch, and Convert

You will need `pandoc`.

Just execute this script, it will fetch updated PEPs, and do the EPUB conversion:

```bash
bash script.sh [--all]
```

If the `--all` argument is passed, all PEPs will be updated, not just only ones updated since the last check.
