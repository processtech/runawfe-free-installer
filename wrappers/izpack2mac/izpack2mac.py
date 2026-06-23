#!/usr/bin/env python3
import os
import sys
import argparse
import plistlib
import zipfile
import tarfile

def create_mac_app(jar_path, jre_tar_path, output_zip):
    """
    Создает macOS .app внутри ZIP.
    """
    app_name = os.path.basename(output_zip).replace(".zip", "")
    app_root = f"{app_name}.app"

    macos_dir = f"{app_root}/Contents/MacOS"
    java_dir = f"{app_root}/Contents/Resources/Java"
    jre_target_prefix = f"{app_root}/Contents/PlugIns/JRE.bundle/Contents/Home/"

    print(f"Начало сборки...")

    try:
        with zipfile.ZipFile(
            output_zip, "w", zipfile.ZIP_DEFLATED, compresslevel=9
        ) as zf:

            # 1. Копируем JRE из tar.gz в ZIP
            print(f"Извлечение JRE из {os.path.basename(jre_tar_path)}...")
            with tarfile.open(jre_tar_path, "r:gz") as tar:
                members = tar.getmembers()
                if not members:
                    raise Exception("JRE tar.gz пуст")

                # Ищем корень (обычно это первая папка в списке)
                common_root = members[0].name.split("/")[0]

                for member in members:
                    if member.isfile():
                        f_data = tar.extractfile(member).read()

                        # Убираем оригинальный корень из tar (напр. jdk-11.0.x+y-jre/)
                        rel_path = member.name[len(common_root) :].lstrip("/")

                        # Если внутри архива путь уже начинается с Contents/Home,
                        # то копируем содержимое ВНУТРЬ JRE.bundle напрямую
                        if rel_path.startswith("Contents/Home/"):
                            # Убираем лишние Contents/Home/ из начала rel_path
                            rel_path = rel_path[len("Contents/Home/") :]
                            # Целевой префикс теперь просто до JRE.bundle/Contents/Home/
                            arcname = jre_target_prefix + rel_path
                        else:
                            # Если структура иная, оставляем как было
                            arcname = jre_target_prefix + rel_path

                        zinfo = zipfile.ZipInfo(arcname)
                        zinfo.compress_type = zipfile.ZIP_DEFLATED
                        # ПЕРЕНОС ПРАВ: сохраняем оригинальные Unix-права (вкл. бит исполнения)
                        zinfo.external_attr = (member.mode | 0o100000) << 16
                        zf.writestr(zinfo, f_data)

            # 2. Добавляем основной JAR
            print("Добавление инсталлятора JAR...")
            zinfo_jar = zipfile.ZipInfo(f"{java_dir}/install.jar")
            zinfo_jar.compress_type = zipfile.ZIP_DEFLATED
            with open(jar_path, "rb") as f:
                zf.writestr(zinfo_jar, f.read())

            # 3. Создаем Launcher Script
            print("Создание Bash-лаунчера...")
            launcher_content = (
                "#!/bin/bash\n"
                "set -e\n"
                "\n"
                '# Если не root, перезапускаем с правами администратора через AppleScript\n'
                'if [ "$(id -u)" != "0" ]; then\n'
                '    SCRIPT_PATH="$(cd "$(dirname "$0")" && pwd)/$(basename "$0")"\n'
                '    exec osascript -e "do shell script \\"bash \\\\\\"$SCRIPT_PATH\\\\\\"\\" with administrator privileges"\n'
                '    exit 1\n'
                'fi\n'
                "\n"
                'DIR="$(cd "$(dirname "$0")" && pwd)"\n'
                'export JAVA_HOME="$DIR/../PlugIns/JRE.bundle/Contents/Home"\n'
                'exec "$JAVA_HOME/bin/java" -Dfile.encoding=UTF-8 -jar "$DIR/../Resources/Java/install.jar" "$@"\n'
            ).encode("utf-8")

            zinfo_launcher = zipfile.ZipInfo(f"{macos_dir}/{app_name}")
            zinfo_launcher.compress_type = zipfile.ZIP_DEFLATED
            zinfo_launcher.external_attr = 0o100755 << 16
            zf.writestr(zinfo_launcher, launcher_content)

            # 4. Создаем Info.plist
            print("Создание Info.plist...")
            plist_data = {
                "CFBundleName": app_name,
                "CFBundleDisplayName": app_name,
                "CFBundleExecutable": app_name,
                "CFBundleIdentifier": "ru.runawfe.installer",
                "CFBundlePackageType": "APPL",
                "CFBundleInfoDictionaryVersion": "6.0",
                "CFBundleShortVersionString": "1.0",
                "LSMinimumSystemVersion": "10.10",
            }
            zinfo_plist = zipfile.ZipInfo(f"{app_root}/Contents/Info.plist")
            zinfo_plist.compress_type = zipfile.ZIP_DEFLATED
            zf.writestr(zinfo_plist, plistlib.dumps(plist_data))

            # 5. PkgInfo
            zinfo_pkg = zipfile.ZipInfo(f"{app_root}/Contents/PkgInfo")
            zinfo_pkg.compress_type = zipfile.ZIP_DEFLATED
            zf.writestr(zinfo_pkg, b"APPL????")

        print(f"\nФайл создан -> {output_zip}")

    except Exception as e:
        if os.path.exists(output_zip):
            os.remove(output_zip)
        raise e


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--jar", required=True)
    parser.add_argument("--jre", required=True)
    parser.add_argument("--output", required=True)
    args = parser.parse_args()

    out = args.output
    if not out.endswith(".zip"):
        out += ".zip"

    try:
        create_mac_app(args.jar, args.jre, out)
    except Exception as e:
        print(f"\nОШИБКА: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
