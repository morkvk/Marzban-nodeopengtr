# Указывает базовый образ для создания нового образа. 
# В данном случае используется "slim" версия Python 3.10, 
# которая является легковесной и содержит минимальный набор пакетов.
FROM python:3.10-slim

# Устанавливает переменную окружения PYTHONUNBUFFERED в значение 1. 
# Это означает, что вывод Python будет немедленно отображаться в stdout, а не буферизоваться. 
# Это полезно для получения логов в реальном времени.
ENV PYTHONUNBUFFERED 1

# Устанавливает рабочую директорию для последующих команд. 
# Все команды RUN, CMD, ENTRYPOINT, COPY, и т.д. будут выполняться из этой директории.
WORKDIR /code


# Обновляет список доступных пакетов и устанавливает необходимые утилиты 
# curl и unzip. После установки он очищает кэш, чтобы уменьшить размер конечного образа.

RUN apt-get update \
    && apt-get install -y curl unzip \
    && rm -rf /var/lib/apt/lists/*

# Загружает и выполняет скрипт установки install_latest_xray.sh из указанного URL. 
RUN bash -c "$(curl -L https://github.com/Gozargah/Marzban-scripts/raw/master/install_latest_xray.sh)"

# Копируем все файлы из текущей директории (где находится Dockerfile) в директорию /code внутри образа.
COPY . /code

#  Устанавливает все зависимости Python, указанные в файле requirements.txt, 
# с помощью pip. Параметр --no-cache-dir уменьшает размер образа, не сохраняя кэш пакетов.
RUN pip install --no-cache-dir --upgrade -r /code/requirements.txt

# Создание файла ssl_client_cert.pem и добавление содержимого из addsert.txt
RUN mkdir -p /var/lib/marzban-node && \
    cp addsert.txt /var/lib/marzban-node/ssl_client_cert.pem

RUN apt-get remove -y curl unzip

# Указывает команду, которая будет выполнена при запуске контейнера. 
# В данном случае это будет запуск Python-скрипта main.py с помощью bash.
CMD ["bash", "-c", "python main.py"]
