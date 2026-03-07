#!/usr/bin/env python3
"""
IzPack2Run - Create a self-extracting Linux .run installer with bundled JRE.
Usage: python izpack2run.py --jar <install.jar> --jre <jre_dir> --output <output.run> [--arch x64|aarch64]
"""
import os
import sys
import argparse
import tempfile
import shutil
import subprocess
import tarfile

def create_run(jar_path, jre_path, output_path, arch='x64'):
    """
    Create a self-extracting .run file containing JRE and install.jar.
    """
    # Validate inputs
    if not os.path.isfile(jar_path):
        raise FileNotFoundError(f"JAR file not found: {jar_path}")
    if not os.path.isdir(jre_path):
        raise FileNotFoundError(f"JRE directory not found: {jre_path}")
    
    # Create temporary working directory
    with tempfile.TemporaryDirectory() as tmpdir:
        # Copy JRE and JAR into a subdirectory structure
        # The installer expects JRE at 'jre' relative to extraction directory
        target_dir = os.path.join(tmpdir, 'bundle')
        os.makedirs(target_dir, exist_ok=True)
        
        # Copy JRE
        jre_dest = os.path.join(target_dir, 'jre')
        shutil.copytree(jre_path, jre_dest, symlinks=True, dirs_exist_ok=True)
        
        # Copy JAR
        jar_dest = os.path.join(target_dir, 'install.jar')
        shutil.copy2(jar_path, jar_dest)
        
        # Create a launch script that will run the installer with bundled JRE
        launch_script = os.path.join(target_dir, 'launch.sh')
        with open(launch_script, 'w', encoding='utf-8', newline='\n') as f:
            f.write("""#!/bin/sh
# Launch script for IzPack installer with bundled JRE
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
JAVA_EXEC="$SCRIPT_DIR/jre/bin/java"
# Ensure executable permissions (in case they were lost on Windows)
chmod +x "$JAVA_EXEC" 2>/dev/null || true
if [ ! -x "$JAVA_EXEC" ]; then
    echo "Error: Bundled JRE not found or not executable." >&2
    exit 1
fi
"$JAVA_EXEC" -Dfile.encoding=UTF-8 -jar "$SCRIPT_DIR/install.jar" "$@"
""")
        os.chmod(launch_script, 0o755)
        
        # Create tar.gz of the bundle
        tar_path = os.path.join(tmpdir, 'bundle.tar.gz')
        with tarfile.open(tar_path, 'w:gz') as tar:
            tar.add(target_dir, arcname='.')
        
        # Create self-extracting shell script
        # The script will extract the tar.gz appended after __ARCHIVE__
        with open(output_path, 'wb') as out:
            # Write header script
            header = f"""#!/bin/sh
# Self-extracting IzPack installer with JRE ({arch})
# This script will extract bundled files and run the installer.
set -e
TMPDIR="$(mktemp -d /tmp/izpack.XXXXXX)"
ARCHIVE_START=$(awk 'NR<=30 && /^__ARCHIVE__$/ {{print NR; exit}}' "$0")
tail -n +$((ARCHIVE_START + 1)) "$0" | tar -xz -C "$TMPDIR"
cd "$TMPDIR"
chmod +x ./launch.sh
exec ./launch.sh "$@"
# Exit before archive
exit 0
__ARCHIVE__
"""
            out.write(header.encode('utf-8'))
            # Append tar.gz
            with open(tar_path, 'rb') as tar:
                shutil.copyfileobj(tar, out)
        
        # Make the .run file executable (chmod +x)
        os.chmod(output_path, 0o755)
    
    print(f"Created self-extracting .run installer: {output_path}")

def main():
    parser = argparse.ArgumentParser(description='Create Linux .run installer with bundled JRE')
    parser.add_argument('--jar', required=True, help='Path to install.jar')
    parser.add_argument('--jre', required=True, help='Path to JRE directory')
    parser.add_argument('--output', required=True, help='Output .run file path')
    parser.add_argument('--arch', default='x64', choices=['x64', 'aarch64'], help='Target architecture')
    args = parser.parse_args()
    
    try:
        create_run(args.jar, args.jre, args.output, args.arch)
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == '__main__':
    main()