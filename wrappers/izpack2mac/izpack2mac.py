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
    required_vars = ["WFE_APPNAME", "WFE_EDITION", "WFE_VERSION"]
    missing_vars = [var for var in required_vars if var not in os.environ]

    if missing_vars:
        print("\n[ОШИБКА УПАКОВКИ]: Отсутствуют обязательные переменные окружения:", file=sys.stderr)
        for var in missing_vars:
            print(f"  - Переменная {var} не задана", file=sys.stderr)
        print("Сборка дистрибутива прервана.", file=sys.stderr)
        sys.exit(1)

    app_name_val = os.environ["WFE_APPNAME"]
    edition_val = os.environ["WFE_EDITION"]
    version_val = os.environ["WFE_VERSION"]

    display_name = f"{app_name_val} {edition_val}".strip()
    
    app_filename = f"{app_name_val} {edition_val} {version_val}".strip()
    app_root = f"{app_filename}.app"

    macos_dir = f"{app_root}/Contents/MacOS"
    java_dir = f"{app_root}/Contents/Resources/Java"
    jre_target_prefix = f"{app_root}/Contents/PlugIns/JRE.bundle/Contents/Home/"

    print(f"Начало сборки {display_name} v{version_val}...")

    created_dirs = set()

    def ensure_zip_dir(zf, path):
        norm_path = path.replace('\\', '/').strip('/') + '/'
        if norm_path in created_dirs or norm_path == './' or norm_path == '/':
            return
        parts = norm_path.split('/')[:-1]
        if len(parts) > 1:
            parent = '/'.join(parts[:-1])
            if parent:
                ensure_zip_dir(zf, parent)
        zinfo = zipfile.ZipInfo(norm_path)
        zinfo.external_attr = 0o40755 << 16  # drwxr-xr-x
        zf.writestr(zinfo, '')
        created_dirs.add(norm_path)

    try:
        with zipfile.ZipFile(output_zip, "w", zipfile.ZIP_DEFLATED, compresslevel=0) as zf:
            ensure_zip_dir(zf, app_root)
            ensure_zip_dir(zf, f"{app_root}/Contents")

            print(f"Извлечение JRE ...")
            with tarfile.open(jre_tar_path, "r:gz") as tar:
                members = tar.getmembers()
                if not members:
                    raise Exception("JRE tar.gz пуст")

                common_root = ""
                for m in members:
                    parts = m.name.replace('\\', '/').split('/')
                    if len(parts) > 1 and parts:
                        common_root = parts[0]
                        break
                if not common_root:
                    common_root = members[0].name.replace('\\', '/').split('/')[0]

                for member in members:
                    if member.isfile():
                        if "__MACOSX" in member.name or "._" in os.path.basename(member.name):
                            continue

                        f_data = tar.extractfile(member).read()
                        norm_name = member.name.replace('\\', '/')
                        
                        if norm_name.startswith(common_root + "/"):
                            rel_path = norm_name[len(common_root) + 1:]
                        else:
                            rel_path = norm_name.lstrip("/")

                        if rel_path.startswith("Contents/Home/"):
                            rel_path = rel_path[len("Contents/Home/"):]
                        
                        arcname = jre_target_prefix + rel_path

                        file_dir = '/'.join(arcname.split('/')[:-1])
                        ensure_zip_dir(zf, file_dir)

                        zinfo = zipfile.ZipInfo(arcname)
                        zinfo.compress_type = zipfile.ZIP_DEFLATED
                        zinfo.file_size = len(f_data)
                        zinfo.external_attr = (member.mode | 0o100000) << 16
                        
                        try:
                            zinfo.date_time = member.mtime_to_tuple()[:6]
                        except Exception:
                            pass

                        zf.writestr(zinfo, f_data)

            print("Добавление инсталлятора JAR...")
            zinfo_jar = zipfile.ZipInfo(f"{java_dir}/install.jar")
            zinfo_jar.compress_type = zipfile.ZIP_DEFLATED
            with open(jar_path, "rb") as f:
                jar_data = f.read()
                zinfo_jar.file_size = len(jar_data)
                zf.writestr(zinfo_jar, jar_data)

            print("Добавление Bash-лаунчера...")
            ensure_zip_dir(zf, macos_dir)
            template_path = os.path.join(os.path.dirname(__file__), "launcher.sh.template")
            
            if not os.path.exists(template_path):
                raise FileNotFoundError(f"Шаблон лаунчера не найден по пути: {template_path}")
                
            with open(template_path, "r", encoding="utf-8") as f:
                launcher_text = f.read().replace("\r\n", "\n")
                launcher_content = launcher_text.encode("utf-8")

            zinfo_launcher = zipfile.ZipInfo(f"{macos_dir}/{app_filename}")
            zinfo_launcher.compress_type = zipfile.ZIP_DEFLATED
            zinfo_launcher.file_size = len(launcher_content)
            zinfo_launcher.external_attr = 0o100755 << 16
            zf.writestr(zinfo_launcher, launcher_content)

            print("Создание Info.plist...")
            plist_data = {
                "CFBundleName": display_name,
                "CFBundleDisplayName": display_name,
                "CFBundleExecutable": app_filename,
                "CFBundleIdentifier": f"ru.{app_name_val.lower()}.installer",
                "CFBundlePackageType": "APPL",
                "CFBundleInfoDictionaryVersion": "6.0",
                "CFBundleShortVersionString": version_val,
                "CFBundleVersion": version_val,
                "CFBundleIconFile": "icon.icns",
                "LSMinimumSystemVersion": "10.10",
                "NSHumanReadableCopyright": f"Copyright © 2026 Процессные технологии. All rights reserved."
            }
            zinfo_plist = zipfile.ZipInfo(f"{app_root}/Contents/Info.plist")
            zinfo_plist.compress_type = zipfile.ZIP_DEFLATED
            plist_bytes = plistlib.dumps(plist_data)
            zinfo_plist.file_size = len(plist_bytes)
            zf.writestr(zinfo_plist, plist_bytes)

            zinfo_pkg = zipfile.ZipInfo(f"{app_root}/Contents/PkgInfo")
            zinfo_pkg.compress_type = zipfile.ZIP_DEFLATED
            zinfo_pkg.file_size = 8
            zf.writestr(zinfo_pkg, b"APPL????")

            project_root = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
            icon_path = os.path.join(project_root, "resources", "images", "macos", "icon.icns")
            print("Добавление иконки приложения...")
            zinfo_icon = zipfile.ZipInfo(f"{app_root}/Contents/Resources/icon.icns")
            zinfo_icon.compress_type = zipfile.ZIP_DEFLATED
            with open(icon_path, "rb") as f:
                icon_data = f.read()
                zinfo_icon.file_size = len(icon_data)
                zf.writestr(zinfo_icon, icon_data)

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
