# Игра "Змейка"
## Требования
* qemu
* nasm
* make
## Использование
Получить бинарный файл boot.bin:\
`make flp`\
\
Запустить qemu:\
`make qemu`\
\
Создать загрузочную флешку (на примере /dev/sda):\
`make flush DISK=sda`\
\
Удалить сгенерированные файлы:\
`make clean`
