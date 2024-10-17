import re
from argparse import ArgumentParser
from datetime import datetime
from pathlib import Path
from subprocess import DEVNULL, check_call, check_output

ROOT = Path(__file__).parent
INPUT_DIR = ROOT / "peps" / "peps"
OUTPUT_DIR = ROOT / "peps_epub"
COVER = ROOT / "cover.jpg"


def convert(file: Path) -> None:
    content = file.read_text()

    if get_value("Status", content) not in {"Accepted", "Active", "Final"}:
        return

    authors = get_value("Author", content)
    date = datetime.strptime(get_value("Created", content), "%d-%b-%Y").isoformat()
    pep = get_value("PEP", content, with_key=True)
    title = get_value("Title", content)

    args = [
        "--ascii",
        "--table-of-contents",
        *["--from", "rst"],
        *["--to", "epub3"],
        *["--indented-code-classes", "python"],
        *["--epub-cover-image", COVER],
        *["--metadata", "creator:Python Software Foundation"],
        *["--metadata", f"date:{date[:10]}"],
        *["--metadata", "language:en"],
        *["--metadata", "subject:Python Enhancement Proposal"],
        *["--metadata", f"title:{pep} ({title})"],
        *["--output", output(file)],
    ]
    for author in authors.split(","):
        args.extend(["--metadata", f"contributor:{author.split('<')[0].strip()}"])

    print(f">>> Processing {pep} ({title}) …", flush=True)
    check_call(["pandoc", *args, file])


def create_parser() -> ArgumentParser:
    """Create the arguments parser."""
    parser = ArgumentParser(
        prog="python script.py",
        description="PEP EPUB • https://github.com/BoboTiG/pep-epub",
    )
    parser.add_argument("--all", "-a", action="store_true", help="convert all PEP files")
    parser.add_argument("--missing", "-m", action="store_true", help="convert missed PEP files")

    return parser


def get_value(key: str, content: str, /, with_key: bool = False) -> str:
    value = next(re.finditer(rf"{key}\s*:(.+)", content))[1].strip()
    return f"{key}: {value}" if with_key else value


def output(file: Path) -> Path:
    return OUTPUT_DIR / file.with_suffix(".epub").name


def update() -> None:
    def call(*cmd: str) -> None:
        check_call(cmd, cwd=INPUT_DIR.parent, stderr=DEVNULL, stdout=DEVNULL)

    def get(*cmd: str) -> str:
        return check_output(cmd, cwd=INPUT_DIR.parent, text=True)

    current_rev = get("git", "log", "--oneline", "--max-count=1", "--abbrev")[:7]
    print(f">>> Updating from revision {current_rev} …", flush=True)
    call("git", "checkout", "main")
    call("git", "pull", "--ff-only", "origin", "main")
    new_rev = get("git", "log", "--oneline", "--max-count=1", "--abbrev")[:7]
    call("git", "checkout", new_rev)

    changes = get("git", "diff", "--name-only", "--diff-filter=AM", current_rev, new_rev, "peps/pep-*.rst")
    for change in changes.splitlines():
        convert(INPUT_DIR.parent / change)


def main() -> int:
    ret = 0
    args = create_parser().parse_args()

    if args.all or args.missing:
        for file in INPUT_DIR.glob("pep-*.rst"):
            if args.missing and output(file).is_file():
                continue
            try:
                convert(file)
            except StopIteration:
                print(f"!! Error with {file}", flush=True)
                ret += 1
    else:
        update()

    return ret


if __name__ == "__main__":
    import sys

    sys.exit(main())
