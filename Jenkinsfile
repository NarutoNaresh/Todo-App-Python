pipeline {
    agent any

    environment {
        // Set the image tag to the current build number
        IMG_TAG = "${BUILD_NUMBER}"
    }

    stages {
        stage('Check-out') {
            steps {
                // Check out the code from the main branch of the Todo-App-Python repository
                checkout scmGit(branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[url: 'https://github.com/NarutoNaresh/Todo-App-Python.git']])
            }
        }

        stage('Build & Push Image to Registry') {
            environment {
                // Define the Docker image name with the current image tag
                DOCKER_IMAGE = "narutonaresh/todoappmain:${IMG_TAG}"
            }
            steps {
                script {
                    // Use Docker registry credentials for authentication
                    withDockerRegistry(credentialsId: 'docker-cred') {
                        // Build Docker image from the Dockerfile
                        sh 'docker build -t ${DOCKER_IMAGE} -f Dockermultistage .'
                        // Run the Docker container to test the build
                        sh 'docker run -d -p 8000:8000 --name todoappx$IMG_TAG $DOCKER_IMAGE'
                        // Push the Docker image to the Docker registry
                        sh 'docker push ${DOCKER_IMAGE}'
                    }
                }
            }
        }

        stage('Update Deployment File') {
            environment {
                // Base Docker image name
                NEW_IMG = 'narutonaresh/todoappmain'
            }
            steps {
                // Check out the Project-Manifests repository
                checkout scmGit(branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[url: 'https://github.com/NarutoNaresh/Project-Manifests.git']])
                
                // Ensure the latest code is pulled from the main branch
                sh '''
                git checkout main
                git pull origin main
                '''
                
                // Update the deployment file with the new Docker image tag
                sh 'sed -i "s@narutonaresh/todoappmain:.*\\\$@$NEW_IMG:$IMG_TAG@" Todo-App-Python/Deployapp.yml'

                // Stage and commit the updated deployment file
                sh '''
                git status
                git add .
                git status
                git commit -m "add new tag for new build"
                '''
            }
        }

        stage('Push the Changes to Manifest Repo') {
            steps {
                withCredentials([string(credentialsId: 'github-token', variable: 'GITHUB_TOKEN')]) {
                    script {
                        // Configure Git with user information for commits
                        sh 'git config --global user.name "naresh kumar d"'
                        // Update the remote repository URL to use the GitHub token
                        sh "git remote set-url origin https://x-access-token:${GITHUB_TOKEN}@github.com/NarutoNaresh/Project-Manifests.git"
                        
                        // Push the committed changes to the remote repository
                        sh 'git push origin main'
                    }
                }
            }
        }
        
        stage('Docker Clean') {
            steps {
                echo 'Cleaning up Docker resources...'
                // Stop all running Docker containers
                sh 'docker stop $(docker ps -a -q)'
                // Remove all stopped Docker containers
                sh 'docker rm $(docker ps -a -q)'
                // Optional: Remove all Docker images
                //sh 'docker rmi -f $(docker images -aq)'
            }
        }
    }
}
