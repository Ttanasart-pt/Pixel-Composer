import argparse
import os
from pathlib import Path
import zipfile

ROOT = Path(__file__).resolve().parent
PACKS_DIR = ROOT.parent / "datafiles" / "packs"
LEGACY_DATA_DIR = ROOT.parent / "datafiles" / "data"
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


def legacy_zip_file_list(zip_path: Path, root_name: str) -> tuple[set[str], bool, bool]:
    had_backslashes = False
    had_root = False
    names: set[str] = set()
    with zipfile.ZipFile(zip_path, "r") as zf:
        for name in zf.namelist():
            if name.endswith("/"):
                continue
            normalized = name
            if "\\" in normalized:
                normalized = normalized.replace("\\", "/")
                had_backslashes = True
            parts = normalized.split("/", 1)
            if len(parts) > 1 and parts[0].lower() == root_name.lower():
                normalized = parts[1]
                had_root = True
            if normalized:
                names.add(normalized)
    return names, had_backslashes, had_root


def find_zip_map(root: Path) -> dict[str, list[Path]]:
    zips: dict[str, list[Path]] = {}
    if not root.exists():
        return zips
    for path in root.rglob("*.zip"):
        key = path.name.lower()
        zips.setdefault(key, []).append(path)
    return zips


# Todo: remove this fn after using it to verify legacy zips conformity.
def run_check_legacy() -> None:
    packs_map = find_zip_map(PACKS_DIR)
    legacy_map = find_zip_map(LEGACY_DATA_DIR)

    if not packs_map:
        print(f"No packs zips found in {PACKS_DIR}")
        return

    for zip_name, pack_paths in sorted(packs_map.items()):
        for pack_zip in sorted(pack_paths):
            legacy_paths = legacy_map.get(zip_name)
            print(f"\n== {pack_zip} ==")
            if not legacy_paths:
                print("No matching legacy zip found")
                continue

            legacy_zip = sorted(legacy_paths)[0]
            if len(legacy_paths) > 1:
                print(f"Multiple legacy matches, using {legacy_zip}")

            pack_files = zip_file_list(pack_zip)
            legacy_files, had_backslashes, had_root = legacy_zip_file_list(
                legacy_zip, pack_zip.stem
            )

            only_in_pack = sorted(pack_files - legacy_files)
            only_in_legacy = sorted(legacy_files - pack_files)

            print(f"Legacy: {legacy_zip}")
            if had_backslashes:
                print("legacy contained \\ path separators")
            if had_root:
                print("legacy had a root directory embedded")
            if not only_in_pack and not only_in_legacy:
                print("File lists match")
                continue

            if only_in_pack:
                print("Only in packs zip:")
                for name in only_in_pack:
                    print(f"  + {name}")
            if only_in_legacy:
                print("Only in legacy zip:")
                for name in only_in_legacy:
                    print(f"  - {name}")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--force-update",
        action="store_true",
        help="Ignore stamps and rebuild all packs",
    )

    # Todo: remove this flag after using it to verify legacy zips conformity.
    parser.add_argument("--check-legacy", action="store_true", help="Diff packs zips vs legacy data zips")

    args = parser.parse_args()

    # Todo: remove this clause after using it to verify legacy zips conformity.
    if args.check_legacy:
        run_check_legacy()
        return

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
