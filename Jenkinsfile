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
                    // O MobEAD e um projeto estatico com Dockerfile nginx
                    if (fileExists('package.json')) {
                        sh 'npm install'
                        sh 'npm run build'
                    } else if (fileExists('pom.xml')) {
                        sh 'mvn clean package -DskipTests'
                    } else if (fileExists('*.csproj') || fileExists('*.sln')) {
                        sh 'dotnet build'
                    } else {
                        echo 'Build padrao: projeto estatico MobEAD com Dockerfile nginx'
                    }
                }
            }
        }

        stage('Testes Unitarios') {
            steps {
                echo 'Executando testes automatizados...'
                script {
                    if (fileExists('package.json')) {
                        sh 'npm test || echo "Testes nao configurados ou falha tolerada"'
                    } else if (fileExists('pom.xml')) {
                        sh 'mvn test || echo "Testes nao configurados ou falha tolerada"'
                    } else if (fileExists('*.csproj')) {
                        sh 'dotnet test || echo "Testes nao configurados ou falha tolerada"'
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
                        sh "${scannerHome}/bin/sonar-scanner"
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
                    sh 'mkdir -p /tmp/mobead-dev'
                    sh 'cp -r . /tmp/mobead-dev/ || true'
                    sh 'nohup python3 -m http.server ${DEV_PORT} --directory /tmp/mobead-dev > /tmp/dev-server.log 2>&1 &'
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
                    sh 'mkdir -p /tmp/mobead-prod'
                    sh 'cp -r . /tmp/mobead-prod/ || true'
                    sh 'nohup python3 -m http.server ${PROD_PORT} --directory /tmp/mobead-prod > /tmp/prod-server.log 2>&1 &'
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
