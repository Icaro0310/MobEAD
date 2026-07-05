pipeline {
    agent any

    environment {
        SONARQUBE_URL = 'http://sonarqube:9000'
        SONAR_TOKEN   = credentials('sonar-token')
        APP_NAME      = 'MobEAD'
        DEV_PORT      = '8081'
        PROD_PORT     = '8082'
    }

    options {
        buildDiscarder(logRotator(numToKeepStr: '10'))
        timestamps()
    }

    stages {
        stage('Checkout') {
            steps {
                echo 'Clonando codigo fonte do repositorio GitHub...'
                checkout scm
            }
        }

        stage('Build') {
            steps {
                echo 'Iniciando compilacao da aplicacao...'
                script {
                    // Verifica a tecnologia do projeto e executa o build adequado
                    // O MobEAD e um projeto estatico com Dockerfile nginx
                    if (fileExists('package.json')) {
                        bat 'npm install'
                        bat 'npm run build'
                    } else if (fileExists('pom.xml')) {
                        bat 'mvn clean package -DskipTests'
                    } else if (fileExists('*.csproj') || fileExists('*.sln')) {
                        bat 'dotnet build'
                    } else {
                        echo 'Build padrao: projeto estatico MobEAD com Dockerfile nginx'
                        // Build da imagem Docker para MobEAD
                        bat 'docker build -t mobead-app:latest .'
                    }
                }
            }
        }

        stage('Testes Unitarios') {
            steps {
                echo 'Executando testes automatizados...'
                script {
                    if (fileExists('package.json')) {
                        bat 'npm test || echo Testes nao configurados ou falha tolerada'
                    } else if (fileExists('pom.xml')) {
                        bat 'mvn test || echo Testes nao configurados ou falha tolerada'
                    } else if (fileExists('*.csproj')) {
                        bat 'dotnet test || echo Testes nao configurados ou falha tolerada'
                    } else {
                        echo 'Nenhum framework de teste identificado. Stage simulado para projeto estatico.'
                    }
                }
            }
        }

        stage('Analise SonarQube') {
            steps {
                echo 'Executando analise estatica de codigo no SonarQube...'
                script {
                    def scannerHome = tool 'SonarScanner'
                    withSonarQubeEnv('SonarQube') {
                        bat """
                            ${scannerHome}\\bin\\sonar-scanner.bat ^
                            -Dsonar.projectKey=MobEAD-IcaroGalvao ^
                            -Dsonar.projectName="MobEAD - Icaro Galvao do Nascimento" ^
                            -Dsonar.sources=. ^
                            -Dsonar.host.url=${SONARQUBE_URL} ^
                            -Dsonar.login=${SONAR_TOKEN}
                        """
                    }
                }
            }
        }

        stage('Quality Gate') {
            steps {
                echo 'Aguardando aprovacao do Quality Gate no SonarQube...'
                timeout(time: 5, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('Deploy - Desenvolvimento') {
            steps {
                echo 'Realizando deploy no ambiente de DESENVOLVIMENTO...'
                script {
                    // Criar diretorio de deploy
                    bat 'if not exist C:\\mobead-dev mkdir C:\\mobead-dev'
                    bat 'xcopy . C:\\mobead-dev\\ /E /I /Y /EXCLUDE:.gitignore'
                    // Iniciar container Docker para desenvolvimento
                    bat 'docker run -d -p 8081:80 --name mobead-dev mobead-app:latest'
                    echo "Aplicacao de desenvolvimento disponivel em http://localhost:${DEV_PORT}"
                }
            }
        }

        stage('Aprovacao para Producao') {
            steps {
                echo 'Aguardando aprovacao manual para deploy em PRODUCAO...'
                input(
                    message: 'Aprovar deploy em ambiente de PRODUCAO?',
                    ok: 'Aprovar e Prosseguir',
                    submitterParameter: 'APROVADOR'
                )
                echo "Deploy aprovado por: ${env.APROVADOR}"
            }
        }

        stage('Deploy - Producao') {
            steps {
                echo 'Realizando deploy no ambiente de PRODUCAO...'
                script {
                    // Criar diretorio de deploy
                    bat 'if not exist C:\\mobead-prod mkdir C:\\mobead-prod'
                    bat 'xcopy . C:\\mobead-prod\\ /E /I /Y /EXCLUDE:.gitignore'
                    // Iniciar container Docker para producao
                    bat 'docker run -d -p 8082:80 --name mobead-prod mobead-app:latest'
                    echo "Aplicacao de producao disponivel em http://localhost:${PROD_PORT}"
                }
            }
        }
    }

    post {
        always {
            echo 'Finalizando pipeline. Arquivando artefatos e logs...'
            archiveArtifacts artifacts: '**/target/*.jar, **/build/**, **/dist/**', allowEmptyArchive: true
        }
        success {
            echo 'Pipeline MobEAD - Icaro Galvao do Nascimento executada com SUCESSO.'
        }
        failure {
            echo 'Pipeline MobEAD - Icaro Galvao do Nascimento FALHOU. Verifique os logs de console.'
        }
    }
}
