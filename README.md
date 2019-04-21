# PEPs in EPUB format

This is a *unofficial* repository where I stock all valid [PEP](https://github.com/python/peps.git)s in the EPUB format.

## Conversion

To convert original files, you will need `pandoc`.

Just execute this script (it will convert or update existant files):

```bash
bash script.sh [--all]
```

If the `--all` argument is passed, all PEPs will be updated, not just only ones updated since the last check.
