#!/usr/bin/env python

import os
import sys
import subprocess
import shutil
import optparse

def parse_options():
    parser = optparse.OptionParser()
    parser.add_option("--file", action="append", dest="file",
                      help="The installer JAR file / files")
    parser.add_option("--output", action="store", dest="output",
                      default="setup.exe",
                      help="The executable file")
    parser.add_option("--with-jdk", action="store", dest="with_jre", default="",
      help="The bundled JRE to run the exe independently of the system resources. ")
    parser.add_option("--with-7z", action="store", dest="p7z",
                      default="7za",
                      help="Path to the 7-Zip executable")
    parser.add_option("--with-upx", action="store", dest="upx",
                      default="upx",
                      help="Path to the UPX executable")
    parser.add_option("--no-upx", action="store_true", dest="no_upx",
                      default=False,
                      help="Do not use UPX to further compress the output")
    parser.add_option("--launch-file", action="store", dest="launch",
                      default="",
                      help="File to launch after extract")
    parser.add_option("--launch-args", action="store", dest="launchargs",
                      default="",
                      help="Arguments for file to launch after extract")
    parser.add_option("--name", action="store", dest="name",
                      default="IzPack",
                      help="Name of package for title bar and prompts")
    parser.add_option("--prompt", action="store_true", dest="prompt",
                      default=False,
                      help="Prompt the user before extraction?")
    parser.add_option("--jvm-args", action="store", dest="jvm_args",
                  default="-Dfile.encoding=UTF-8",
                  help="JVM arguments (e.g. -Dfile.encoding=UTF-8)")
    (options, args) = parser.parse_args()
    if (options.file is None):
        parser.error("no installer file has been given")
    return options

def create_exe(settings):
    if len(settings.file) > 0:
        filename = os.path.basename(settings.file[0])
    else:
        filename = ''
    
    if len(settings.with_jre) > 0:
        jdk = os.path.basename(settings.with_jre)
        jdk = jdk + "\\bin\\javaw.exe"
        print(f"Using bundled JRE: {jdk}")
        settings.file.append(settings.with_jre)
    else:
        jdk = 'javaw'
    
    current_dir = os.path.dirname(os.path.abspath(__file__))
    if settings.p7z == '7za':
        p7z = os.path.join(current_dir, '7za')
    else:
        p7z = settings.p7z
    
    use_shell = sys.platform != 'win32'
    
    # Нормализуем аргументы
    jvm_args_clean = settings.jvm_args.strip()
    launch_args_clean = settings.launchargs.strip() if settings.launchargs else ""

    # 1. ГЕНЕРИРУЕМ КЛАССИЧЕСКИЙ run.vbs, СОВМЕСТИМЫЙ С WINDOWS 7
    jvm_args_clean = settings.jvm_args.strip()
    launch_args_clean = settings.launchargs.strip() if settings.launchargs else ""

    vbs_content = (
        'Set WshShell = CreateObject("WScript.Shell")\n'
        'Set fso = CreateObject("Scripting.FileSystemObject")\n'
        '\n'
        '\' КЛАССИЧЕСКИЙ СПОСОБ ДЛЯ WINDOWS 7: Получаем путь к папке, где лежит скрипт\n'
        'currentDir = fso.GetParentFolderName(WScript.ScriptFullName)\n'
        '\n'
        'javaPath = currentDir & "\\{jdk}"\n'
        'jarPath = currentDir & "\\{filename}"\n'
        'quote = chr(34)\n'
        'argsJvm = "{jvm_args}"\n'
        'argsLaunch = "{launchargs}"\n'
        '\n'
        '{vbs_logic}'
        '\n'
        'If argsLaunch <> "" Then\n'
        '    cmdLine = cmdLine & " " & argsLaunch\n'
        'End If\n'
        '\n'
        '\' Флаг 1 показывает окно инсталлятора, True — заставляет ждать его закрытия\n'
        'WshShell.Run cmdLine, 1, True\n'
        'WScript.Sleep 2000\n'
        'On Error Resume Next\n'
        'fso.DeleteFolder currentDir, True\n'
    )

    # Развилка логики (Java или сторонний файл)
    if settings.launch == '':
        vbs_logic = 'cmdLine = quote & javaPath & quote & " " & argsJvm & " -jar " & quote & jarPath & quote\n'
    else:
        vbs_logic = 'cmdLine = quote & currentDir & "\\{launch}" & quote\n'.format(launch=settings.launch)

    # Форматируем финальный текст
    vbs_content = vbs_content.format(
        jvm_args=jvm_args_clean,
        launchargs=launch_args_clean,
        vbs_logic=vbs_logic,
        jdk=jdk,
        filename=filename
    )

    with open('run.vbs', 'w', encoding='cp1251') as vbs_file:
        vbs_file.write(vbs_content)


    # 2. УПАКОВЫВАЕМ все файлы в архив installer.7z
    if (os.access('installer.7z', os.F_OK)):
        os.remove('installer.7z')
    
    pack_files = list(settings.file) + ['run.vbs']
    files_str = '" "'.join(pack_files)
    p7zcmd = '"%s" a -mmt -t7z -mx=0 installer.7z "%s"' % (p7z, files_str)
    subprocess.call(p7zcmd, shell=use_shell)
    
    # 3. ГЕНЕРИРУЕМ КОНФИГУРАЦИЮ 7-Zip
    config = open('config.txt', 'w', encoding='utf-8')
    config.write(';!@Install@!UTF-8!\n')
    config.write('Title="%s"\n' % settings.name)
    if settings.prompt:
        config.write('BeginPrompt="Install %s?"\n' % settings.name)
    config.write('Progress="yes"\n')
    
    # Изменено: Используем ExecuteFile и ExecuteParameters строго по документации Игоря Павлова
    config.write('ExecuteFile="wscript.exe"\n')
    config.write('ExecuteParameters="//B run.vbs"\n')
    
    config.write(';!@InstallEnd@!\n')
    config.close()
    
    # 4. СОБИРАЕМ ФИНАЛЬНЫЙ EXE
    sfx = os.path.join(os.path.dirname(p7z), '7zSD.sfx')
    files = [sfx, 'config.txt', 'installer.7z']
    
    output = open(settings.output, 'wb')
    for f in files:
        in_file = open(f, 'rb')
        shutil.copyfileobj(in_file, output, 2048)
        in_file.close()
    output.close()
    
    # 5. СЖАТИЕ ЧЕРЕЗ UPX
    if (not settings.no_upx):
        if settings.upx == 'upx':
            upx = os.path.join(current_dir, 'upx')
        else:
            upx = settings.upx
        upx_cmd = '"%s" --ultra-brute "%s"' % (upx, settings.output)
        subprocess.call(upx_cmd, shell=use_shell)
    
    # Очистка рабочего каталога сборщика
    os.remove('config.txt')
    os.remove('installer.7z')
    os.remove('run.vbs')

def main():
    create_exe(parse_options())

if __name__ == "__main__":
    main()
