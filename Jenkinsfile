pipeline {
    agent any

    environment {
        TRIES = 3 // Default value for the number of tries
    }

    parameters {
        string(name: 'TRIES', defaultValue: '3', description: 'Number of attempts allowed')
    }

    stages {
        stage('Initialize') {
            steps {
                script {
                    TRIES = params.TRIES.toInteger()
                    echo "Number of tries set to: ${TRIES}"
                }
            }
        }

        stage('Check PRs') {
            steps {
                script {
                    def available_prs = sh(script: "python -c 'import run_process as rp; print(rp.check_pr())'", returnStdout: true).trim()
                    if (!available_prs || available_prs == "None") {
                        echo "No PRs found... sleeping"
                        sleep(time: 1, unit: 'MINUTES')
                        error("No PRs found")
                    } else {
                        currentBuild.description = "PR: ${available_prs}"
                        env.PRS = available_prs
                    }
                }
            }
        }

        stage('Pull Latest Changes') {
            steps {
                sh 'git pull'
            }
        }

        stage('Run PR') {
            steps {
                script {
                    def PR = env.PRS.split()[0]
                    echo "Running PR: ${PR}"
                    def cmd = "python run_process.py ${PR} --auto --onlynew"
                    def success = false

                    for (int count = 0; count <= TRIES; count++) {
                        if (count == TRIES) {
                            sh "python -c \"import slack; slack.main('--prmilestone ${PR} --fail'.split())\""
                            error("Failed to run PR after ${TRIES} attempts")
                        }

                        try {
                            sh cmd
                            success = true
                            break
                        } catch (Exception e) {
                            echo "Attempt ${count + 1} failed. Retrying..."
                            cmd = "sleep 10 && echo 'y' | python run_process.py ${PR} --auto"
                            sleep(time: 10, unit: 'SECONDS')
                        }
                    }

                    if (!success) {
                        error("All attempts to run PR failed")
                    }
                }
            }
        }
    }

    post {
        always {
            echo "Job completed"
        }
        failure {
            echo "Job failed"
        }
        success {
            echo "Job succeeded"
        }
    }
}
Jenkinsfile