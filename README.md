# PEPs in EPUB format

![Update PEPs](https://github.com/BoboTiG/pep-epub/workflows/Update%20PEPs/badge.svg)

This is a *unofficial* repository where I stock all valid [PEP](https://github.com/python/peps.git)s in the EPUB format.

## Repository Cloning

```bash
git clone --recursive git@github.com:BoboTiG/pep-epub.git
```

## Conversion

To convert original files, you will need `pandoc`.

Just execute this script (it will convert or update existant files):

```bash
bash script.sh [--all]
```

If the `--all` argument is passed, all PEPs will be updated, not just only ones updated since the last check.
