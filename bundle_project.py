import os
import zipfile
import sys

# Directory to package
ROOT_DIR = os.path.dirname(os.path.abspath(__file__))
OUTPUT_ZIP = os.path.join(ROOT_DIR, "SAIOTAF_Project_Clean.zip")

EXCLUDE_DIRS = {
    "node_modules",
    "venv",
    ".venv",
    "__pycache__",
    ".git",
    ".gemini",
    ".vscode",
    ".idea",
    "dist"
}

EXCLUDE_EXTS = {
    ".pyc",
    ".pyo",
    ".log"
}

def should_exclude(rel_path):
    parts = rel_path.replace("\\", "/").split("/")
    for p in parts:
        if p in EXCLUDE_DIRS:
            return True
    _, ext = os.path.splitext(rel_path)
    if ext.lower() in EXCLUDE_EXTS:
        return True
    return False

def make_zip():
    print("================================================================")
    print("   SAIOTAF - Creating Clean Project Zip for Sharing")
    print("================================================================")
    print(f"Source: {ROOT_DIR}")
    print(f"Output: {OUTPUT_ZIP}")
    print("Excluding: node_modules, venv, __pycache__, .git, dist, .pyc")
    print("----------------------------------------------------------------")

    file_count = 0
    with zipfile.ZipFile(OUTPUT_ZIP, "w", zipfile.ZIP_DEFLATED) as zf:
        for root, dirs, files in os.walk(ROOT_DIR):
            # Prune excluded directories in-place so we don't recurse into them
            dirs[:] = [d for d in dirs if d not in EXCLUDE_DIRS]

            for file in files:
                full_path = os.path.join(root, file)
                rel_path = os.path.relpath(full_path, ROOT_DIR)

                # Don't include the output zip itself or other zips
                if file.endswith(".zip") or should_exclude(rel_path):
                    continue

                zf.write(full_path, rel_path)
                file_count += 1
                if file_count % 100 == 0:
                    print(f"  Processed {file_count} files...", end="\r")

    size_mb = os.path.getsize(OUTPUT_ZIP) / (1024 * 1024)
    print(f"\n================================================================")
    print(f"  SUCCESS! Zip created successfully:")
    print(f"  Path: {OUTPUT_ZIP}")
    print(f"  Files: {file_count}")
    print(f"  Size:  {size_mb:.2f} MB (Extremely clean & lightweight!)")
    print("================================================================\n")

if __name__ == "__main__":
    make_zip()
