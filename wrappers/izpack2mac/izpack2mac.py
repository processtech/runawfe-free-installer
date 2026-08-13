#!/usr/bin/env python3
import os
import sys
import argparse
import plistlib
import zipfile
import tarfile

def create_mac_app(jar_path, jre_tar_path, output_zip):
    """
    Создает валидный macOS .app внутри ZIP с явной регистрацией папок.
    """
    app_name = os.path.basename(output_zip).replace(".zip", "")
    app_root = f"{app_name}.app"

    macos_dir = f"{app_root}/Contents/MacOS"
    java_dir = f"{app_root}/Contents/Resources/Java"
    jre_target_prefix = f"{app_root}/Contents/PlugIns/JRE.bundle/Contents/Home/"

    print("Начало сборки...")

    created_dirs = set()

    def ensure_zip_dir(zf, path):
        """Явно добавляет запись папки в ZIP с Unix-правами директории (755)"""
        norm_path = path.replace('\\', '/').strip('/') + '/'
        if norm_path in created_dirs or norm_path == './' or norm_path == '/':
            return
        
        # Рекурсивно создаем родительские папки
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
            
            # Принудительно создаем корень бандла и основные папки в самом начале архива
            ensure_zip_dir(zf, app_root)
            ensure_zip_dir(zf, f"{app_root}/Contents")

            # 1. Извлекаем и упаковываем JRE из tar.gz
            print(f"Извлечение JRE из {os.path.basename(jre_tar_path)}...")
            with tarfile.open(jre_tar_path, "r:gz") as tar:
                members = tar.getmembers()
                if not members:
                    raise Exception("JRE tar.gz пуст")

                # Безопасно определяем имя корневой папки JRE
                common_root = ""
                for m in members:
                    parts = m.name.replace('\\', '/').split('/')
                    if len(parts) > 1 and parts[0]:
                        common_root = parts[0]
                        break
                
                if not common_root:
                    common_root = members[0].name.replace('\\', '/').split('/')[0]

                print(f"Определен корень JRE в архиве: '{common_root}'")

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

                        # Гарантируем создание папки для файла
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

            # 2. Добавляем основной JAR
            print("Добавление инсталлятора JAR...")
            zinfo_jar = zipfile.ZipInfo(f"{java_dir}/install.jar")
            zinfo_jar.compress_type = zipfile.ZIP_DEFLATED
            with open(jar_path, "rb") as f:
                zf.writestr(zinfo_jar, f.read())

            # 3. Добавляем Launcher Script из внешнего файла-шаблона
            print("Добавление Bash-лаунчера...")
            ensure_zip_dir(zf, macos_dir)
            
            # Путь к файлу-шаблону рядом со скриптом автоматизации
            template_path = os.path.join(os.path.dirname(__file__), "launcher.sh.template")
            
            if not os.path.exists(template_path):
                raise FileNotFoundError(f"Шаблон лаунчера не найден по пути: {template_path}")
                
            with open(template_path, "r", encoding="utf-8") as f:
                # Читаем текст, принудительно заменяя Windows-переводы строк на Unix (LF)
                launcher_text = f.read().replace("\r\n", "\n")
                launcher_content = launcher_text.encode("utf-8")

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
