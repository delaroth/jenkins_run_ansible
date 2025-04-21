pipeline {
    // Use a general agent for checkout and key preparation stages
    agent any // Or specify a specific agent label if needed

    environment {
        // Define paths relative to the workspace root
        INVENTORY_FILE = 'inventory.ini'
        PLAYBOOK_FILE = 'nginx.yml'
        // Define the path where the SSH key will be temporarily stored within the workspace
        SSH_KEY_PATH = "${env.WORKSPACE}/ansible-ssh-key.pem"
    }

    stages {
        stage('Checkout Code') {
            steps {
                // Checkout your code repository containing the ansible_nginx_deployment folder
                // Example for Git:
                git url: 'https://github.com/delaroth/jenkins_run_ansible.git', branch: 'main' // Ensure this matches your repo
                echo 'Checking out code...'
                 sh 'ls -la' // Verify files exist at root
            }
        }

        stage('Prepare SSH Key') {
            // This stage runs on the agent specified at the top level (agent any)
            steps {
                // Use Jenkins Credentials Binding to securely access the SSH private key
                // Ensure you have a 'SSH Username with private key' credential with ID 'ansible-ssh-key'
                withCredentials([sshUserPrivateKey(credentialsId: 'ansible-ssh-key', keyFileVariable: 'SSH_KEY_FILE')]) {
                    // Copy the key to a known location within the workspace
                    // and set correct permissions
                    sh '''
                        echo "Copying SSH key..."
                        cp $SSH_KEY_FILE ${SSH_KEY_PATH}
                        chmod 600 ${SSH_KEY_PATH}
                        echo "SSH key ready at ${SSH_KEY_PATH}"
                    '''
                }
            }
        }

        stage('Run Ansible Playbook') {
            steps {
                script {
                    // NOTE: This playbook uses the 'nginx_port' variable defined in
                    // nginx/vars/main.yml (value: 6789)
                    // It does NOT fetch the port from Consul.

                    // NOTE: This playbook requires the template file:
                    // nginx/templates/nginx.conf.j2
                    // Ensure this file exists in your repository.
                    // Paths here are relative to the workspace root inside the container
                    sh "echo 'Checking for required template file...'; ls -l nginx/templates/nginx.conf.j2 || echo 'WARNING: Template file not found!'"


                    // Execute the ansible-playbook command inside the container
                    echo "Running Ansible playbook: ${PLAYBOOK_FILE}"
                    // The SSH_KEY_PATH is relative to the workspace which should be mounted
                    sh """
                    export ANSIBLE_HOST_KEY_CHECKING=False 
                    ansible-playbook --private-key ${SSH_KEY_PATH} -i ${INVENTORY_FILE} ${PLAYBOOK_FILE}
                    """
                }
            }
        }
    }

    post {
        always {
            // This runs on the top-level agent again
            echo "Cleaning up SSH key..."
            sh "rm -f ${SSH_KEY_PATH}"
        }
    }
}
