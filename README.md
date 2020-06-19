# infostart2020-nsk-example

## Подготовка окружения

**Важно:** Требуется как минимум 8GB ОЗУ на машине.

* Jenkins (https://www.jenkins.io/download/).Как установить (https://dzone.com/articles/how-to-install-jenkins-on-windows)
* Плагины для Jenkins:
    * HTML publisher (https://www.jenkins.io/doc/pipeline/steps/htmlpublisher/)
    * Allure (https://plugins.jenkins.io/allure-jenkins-plugin/)
    * SonarQube Scanner (https://plugins.jenkins.io/sonar/)
* SonarQube (https://www.sonarqube.org/downloads/).Как установить (https://infostart.ru/public/1089670/)
* OneScript (https://oscript.io/downloads).
* Библиотеки OneScript:
    * Vanessa runner (https://github.com/vanessa-opensource/vanessa-runner) 
        * Выполнить команду в консоли: ```opm install vanessa-runner```
    * Vanessa ADD (https://github.com/vanessa-opensource/add)
        * Выполнить команду в консоли: ```opm install add```
    * AutodocGen (https://github.com/bia-tech/autodocgen)
        * Выполнить команду в консоли: ```opm install add```
    * Swagger (https://github.com/botokash/swagger)
        * Выполнить команду в консоли: ```opm install swagger```
* NodeJS (https://nodejs.org/en/download/)
* Пакет bootprint-openapi (https://github.com/bootprint/bootprint-openapi)
    * Выполнить команду в консоли: ```npm install -g bootprint``` и ```npm install -g bootprint-openapi```

## Создание Pipeline в Jenkins

1. Добавляем новый item c видом `Pipeline`
2. В настройках заполняем поле с Pipeline с примером ниже (Jenkinsfile) или выбираем взять из SCM. Если выбрано втрое указываем адрес текущего репозитория.
3. Если какие то действия не нужны - комментируем.
4. Перед запуском проверяем что все установлено из раздела "Подготовка окружения" выше.

Можно почитать следующие статьи:
* [Конвейер проверки качества кода](https://infostart.ru/public/1117485/)
* [Переводим рутину ручного тестирования 1C на рельсы Jenkins-а и ADD](https://infostart.ru/public/1070720/)
* [Пайплайны Jenkins - программирование и настройка. Загружаемые модули. Цикл "Многопоточный CI для 1С", часть 5](https://infostart.ru/public/1210995/)

## Jenkinsfile
```
#!groovy

node {
    
    def scannerHome = tool name: 'sonar-scanner'
    
    stage('Актуализация проекта GIT') {
        git branch: 'master', url: 'https://github.com/otymko/infostart2020-nsk-example.git' 
    }
    
    // Комментируем если тестирование не нужно
    stage('Подготовка окружения') {
        cmd("@call vrunner init-dev --dt ‪build/dt/base.dt --settings ./vb-params.json")
        cmd("@call vrunner compileext --settings ./vb-params.json --updatedb")
    }
    
    // Комментируем если тестирование не нужно
    stage('Модульные тесты') {
        cmd("@call vrunner xunit --settings ./vb-params.json")
    }
    
    // Комментируем если стат. анализ не нужен
    stage('Статический анализ') {
        withSonarQubeEnv('My SonarQube') {
            cmd("${scannerHome}/bin/sonar-scanner")
        }
    }
    
    // Комментируем если документация Swagger не нужна
    stage('Генерация Swagger API') {
        cmd('@call swagger generate --src-path src --out build/swagger --format json')
        cmd('@call bootprint openapi build/swagger/Пример_Заказы.json build/swagger')
        publishHTML (target : [allowMissing: false,
             alwaysLinkToLastBuild: true,
             keepAll: true,
             reportDir: 'build/swagger',
             reportFiles: 'index.html',
             reportName: 'Swagger API',
             reportTitles: 'API HTTP-сервиса'])
    }
    
    // Комментируем если документация Autodocgen не нужна
    stage('Генерация AutodocGen') {
        cmd('@call autodocgen generate -c autodocgen-properties.json -f html src')
        publishHTML (target : [allowMissing: false,
             alwaysLinkToLastBuild: true,
             keepAll: true,
             reportDir: 'build/autodoc',
             reportFiles: '**/*.html',
             reportName: 'AutodocGen API',
             reportTitles: 'Документация методов'])
    }
    
    // Комментируем если тестирование не нужно
    stage('Публикация отчета Allure') {
       allure([
        results: [[path: 'build/allure']]  
       ])
    }

    
}

def cmd(command) {
    bat "chcp 65001\n${command}"
}

```

