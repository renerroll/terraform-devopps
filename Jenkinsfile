pipeline {
  agent {
    kubernetes {
      yaml """
apiVersion: v1
kind: Pod
metadata:
  labels:
    some-label: jenkins-kaniko
spec:
  serviceAccountName: jenkins-sa
  containers:
    - name: kaniko
      image: gcr.io/kaniko-project/executor:v1.16.0-debug
      imagePullPolicy: Always
      command:
        - sleep
      args:
        - 99d
    - name: git
      image: alpine/git
      command:
        - cat
      tty: true
"""
    }
  }

  options {
    disableConcurrentBuilds()
  }

  environment {
    ECR_REGISTRY = "793872273299.dkr.ecr.eu-west-1.amazonaws.com"
    IMAGE_NAME   = "ecr-alx"
    IMAGE_TAG    = "v1.0.${BUILD_NUMBER}"
    COMMIT_EMAIL = "jenkins@localhost"
    COMMIT_NAME  = "jenkins"
    GIT_REPO = "microservice-project"
    GIT_BRANCH = "lesson-8-9"
    CHART_PATH   = "charts/django-app"
  }

  stages {
    stage('Build & Push Docker Image to ECR') {
      when { changeset pattern: 'django/**', comparator: 'ANT' }
      steps {
        container('kaniko') {
          sh '''
            cd django
            /kaniko/executor \\
              --context `pwd` \\
              --dockerfile `pwd`/Dockerfile \\
              --destination=$ECR_REGISTRY/$IMAGE_NAME:$IMAGE_TAG \\
              --cache=true \\
              --insecure \\
              --skip-tls-verify
          '''
        }
      }
    }

  stage('Update Chart Tag in Git') {
      when { changeset pattern: 'django/**', comparator: 'ANT' }
      steps {
        container('git') {
          withCredentials([usernamePassword(credentialsId: 'github-token', usernameVariable: 'GITHUB_USER', passwordVariable: 'GITHUB_PAT')]) {
            sh '''
              set -e
              echo "Cloning repo and updating Helm chart..."
              git clone https://$GITHUB_USER:$GITHUB_PAT@github.com/$GITHUB_USER/${GIT_REPO}.git
              cd ${GIT_REPO}
              git checkout ${GIT_BRANCH} || git checkout -b ${GIT_BRANCH}
              cd ${CHART_PATH}

              # Update values.yaml
              sed -i "s|repository:.*|repository: ${ECR_REGISTRY}/${IMAGE_NAME}|" values.yaml
              sed -i "s|tag:.*|tag: ${IMAGE_TAG}|" values.yaml

              git config user.email "$COMMIT_EMAIL"
              git config user.name "$COMMIT_NAME"

              git add values.yaml
              git commit -m "[skip ci] Update image tag to ${IMAGE_TAG}" || echo "No changes"
              git push origin "${GIT_BRANCH}" || echo "Nothing to push"
            '''
          }
        }
      }
    }

  }
}
