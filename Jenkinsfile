pipeline {
    agent any 

    environment {
        INVENTORY_FILE = 'inventory.ini'
        PLAYBOOK_FILE = 'nginx.yml'
        SSH_KEY_PATH = "${env.WORKSPACE}/ansible-ssh-key.pem"
    }

    stages {
        stage('Checkout Code') {
            steps {
                git url: 'https://github.com/delaroth/jenkins_run_ansible.git', branch: 'main'
                echo 'Checking out code...'
                sh 'ls -la'
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
    agent {
        dockerfile true
    }
    steps {
        script {
            sh "echo 'Checking for required template file...'; ls -l nginx/templates/nginx.conf.j2 || echo 'WARNING: Template file not found!'"

            echo "Running Ansible playbook: ${PLAYBOOK_FILE}"

           
            sh """
            #!/bin/bash
            export ANSIBLE_HOST_KEY_CHECKING=False

            # Define a writable temp path within the workspace
            export ANSIBLE_LOCAL_TEMP='./ansible-tmp' # Use relative path within workspace

            # Ensure the directory exists (use -p for safety)
            mkdir -p "\$ANSIBLE_LOCAL_TEMP"

            echo "Using Ansible temp path: \$ANSIBLE_LOCAL_TEMP"

            # Run the playbook
            ansible-playbook --private-key ${SSH_KEY_PATH} -i ${INVENTORY_FILE} ${PLAYBOOK_FILE}
            """
            // --- END OF MODIFICATION ---
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
