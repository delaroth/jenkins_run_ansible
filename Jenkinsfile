pipeline {
    agent any

    environment {
        INVENTORY_FILE = 'inventory.ini'
        PLAYBOOK_FILE = 'nginx.yml'
        SSH_KEY_PATH = "${env.WORKSPACE}/ansible-ssh-key.pem"
        // Define the Git URL and Branch centrally
        GIT_REPO_URL = 'https://github.com/delaroth/jenkins_run_ansible.git'
        GIT_BRANCH = 'main'
    }

    stages {
        stage('Checkout Code (Initial)') {
            steps {
                // Initial checkout for key preparation etc.
                git url: GIT_REPO_URL, branch: GIT_BRANCH
                echo 'Initial code checkout complete...'
                 sh 'ls -la'
                 // Optional: Verify Dockerfile content here if needed
                 // sh 'echo "Dockerfile content:"; cat Dockerfile || echo "Dockerfile not found"'
            }
        }

        stage('Prepare SSH Key') {
            steps {
                withCredentials([sshUserPrivateKey(credentialsId: 'ansible-ssh-key', keyFileVariable: 'SSH_KEY_FILE')]) {
                    sh """
                        echo "Copying SSH key..."
                        cp \$SSH_KEY_FILE ${SSH_KEY_PATH}
                        chmod 600 ${SSH_KEY_PATH}
                        echo "SSH key ready at ${SSH_KEY_PATH}"
                    """
                }
            }
        }

        stage('Run Ansible Playbook') {
            // Define agent here to ensure checkout happens before agent starts
            agent none // Run the steps on the overall agent first
            steps {
                // Explicitly checkout the correct code INSIDE this stage
                // This ensures the Dockerfile used by 'agent { dockerfile true }' below is the latest
                echo "Checking out code again within Ansible stage..."
                git url: GIT_REPO_URL, branch: GIT_BRANCH

                // Now run the rest of the steps inside the Docker container
                agent {
                    dockerfile {
                        // Explicitly state the Dockerfile name, although 'Dockerfile' is default
                        filename 'Dockerfile'
                        // Force Docker to always pull the base image (optional, helps ensure freshness)
                        // pull true
                    }
                }
                // Steps inside the container
                script {
                    sh "echo 'Checking for required template file...'; ls -l nginx/templates/nginx.conf.j2 || echo 'WARNING: Template file not found!'"
                    echo "Running Ansible playbook: ${PLAYBOOK_FILE}"
                    sh """
                    export ANSIBLE_HOST_KEY_CHECKING=False
                    # Run playbook - no ANSIBLE_LOCAL_TEMP needed with jenkins/jenkins:lts base
                    ansible-playbook --private-key ${SSH_KEY_PATH} -i ${INVENTORY_FILE} ${PLAYBOOK_FILE}
                    """
                }
            }
        }
    }

    post {
        always {
            echo "Cleaning up SSH key..."
            sh "rm -f ${SSH_KEY_PATH}"
        }
    }
}
