#!groovy

node {
    
    def scannerHome = tool name: 'sonar-scanner'
    
    stage('Актуализация проекта GIT') {
        git branch: 'master', credentialsId: '3363631f-fba0-4996-a8fb-b4fadd8dcda1', url: 'https://github.com/otymko/infostart2020-nsk-example.git' 
    }
    
    stage('Подготовка окружения') {
        cmd("@call vrunner init-dev --dt ‪build/dt/base.dt --settings ./vb-params.json")
        cmd("@call vrunner compileext --settings ./vb-params.json --updatedb")
    }
    
    stage('Модульные тесты') {
        cmd("@call vrunner xunit --settings ./vb-params.json")
    }
    
    stage('Статический анализ') {
        withSonarQubeEnv('My SonarQube') {
            cmd("${scannerHome}/bin/sonar-scanner")
        }
    }
    
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
    
    stage('Публикация отчета Allure') {
       allure([
        results: [[path: 'build/allure']]  
       ])
    }

    
}

def cmd(command) {
    bat "chcp 65001\n${command}"
}
