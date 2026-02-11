import argparse
import os
from pathlib import Path
import zipfile

ROOT = Path(__file__).resolve().parent
PACKS_DIR = ROOT.parent / "datafiles" / "packs"
ZIP_IGNORE = {
    ".DS_Store", # macOS metadata files
}  # exact filename matches only

TARGETS = [
    ROOT / "Addons",
    ROOT / "Assets",
    ROOT / "Collections",
    ROOT / "Curves",
    ROOT / "Layouts",
    ROOT / "Locale" / "en",
    ROOT / "Nodes" / "Actions",
    ROOT / "Nodes" / "Internal",
    ROOT / "Theme",
    ROOT / "Welcome files",
]


def latest_mtime(path: Path) -> float:
    latest = 0.0
    for r, _, files in os.walk(path):
        for name in files:
            latest = max(latest, os.path.getmtime(Path(r) / name))
    return latest


def write_zip(src: Path, zip_path: Path) -> None:
    with zipfile.ZipFile(zip_path, "w", compression=zipfile.ZIP_DEFLATED) as zf:
        for r, _, files in os.walk(src):
            rpath = Path(r)
            for name in files:
                if name in ZIP_IGNORE:
                    continue
                full_path = rpath / name
                rel_path = full_path.relative_to(src)
                zf.write(full_path, rel_path.as_posix())


def zip_file_list(zip_path: Path) -> set[str]:
    with zipfile.ZipFile(zip_path, "r") as zf:
        return {name for name in zf.namelist() if not name.endswith("/")}

def find_zip_map(root: Path) -> dict[str, list[Path]]:
    zips: dict[str, list[Path]] = {}
    if not root.exists():
        return zips
    for path in root.rglob("*.zip"):
        key = path.name.lower()
        zips.setdefault(key, []).append(path)
    return zips

def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--force-update",
        action="store_true",
        help="Ignore stamps and rebuild all packs",
    )

    args = parser.parse_args()

    for src in TARGETS:
        zip_name = f"{src.name}.zip"
        rel_parent = src.parent.relative_to(ROOT)
        packs_parent = PACKS_DIR / rel_parent
        zip_path = packs_parent / zip_name
        stamp_path = packs_parent / f".latest_{src.name.lower()}_zip_time.txt"
        last_time = 0.0
        if stamp_path.exists():
            with stamp_path.open("r", encoding="utf-8") as f:
                last_time = float(f.read())

        current_time = latest_mtime(src)
        if args.force_update or current_time > last_time:
            print(f"Update {zip_name}...")
            packs_parent.mkdir(parents=True, exist_ok=True)
            write_zip(src, zip_path)
            with stamp_path.open("w", encoding="utf-8") as f:
                f.write(str(current_time))
        else:
            print(f"{zip_name} up to date")


if __name__ == "__main__":
    main()
