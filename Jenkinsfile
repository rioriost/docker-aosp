// Every jenkins file should start with either a Declarative or Scripted Pipeline entry point.
node {
    //Utilizing a try block so as to make the code cleaner and send slack notification in case of any error
    try {
        //Call function to send a message to Slack
        notifyBuild('STARTED')
        // Global variable declaration
        def project = 'sa-android'
        def appName = 'Sample App'

        // Stage, is to tell the Jenkins that this is the new process/step that needs to be executed
        stage('Checkout') {
            // Pull the code from the repo
            checkout scm
        }

        stage('Build Image') {
            // Build our docker Image
            sh("docker build -t ${project} .")
        }

        stage('Run application test') {
            // If you need environmental variables in your image. Why not load it attach it to the image, and delete it afterward
            sh("env >> .env")
            sh("docker run --env-file .env --rm ${project} ./gradlew test")
            sh("rm -rf .env")
        }

        stage('Deploy application') {
            // This is the cool part where you deploy. Here, you can specify builds you want to deploy
            switch (env.BRANCH_NAME) {
                case "master":
                    sh("env >> .env")
                    sh("docker run --env-file .env --rm ${project} ./gradlew clean build assembleRelease crashlyticsUploadDistributionRelease")
                    sh("rm -rf .env")
                    break
                case "dev":
                    sh("env >> .env")
                    sh("docker run --env-file .env --rm ${project} ./gradlew clean build assembleDebug crashlyticsUploadDistributionDebug")
                    sh("rm -rf .env")
                    break
            }
        }
    } catch (e) {
        currentBuild.result = "FAILED"
        throw e
      } finally {
        notifyBuild(currentBuild.result)
    }
}

def notifyBuild(String buildStatus = 'STARTED') {
  buildStatus =  buildStatus ?: 'SUCCESSFUL'

  def color = 'RED'
  def colorCode = '#FF0000'
  def subject = "${buildStatus}: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'"
  def summary = "${subject} (${env.BUILD_URL})"
  def details = """<p>STARTED: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]':</p>
    <p>Check console output at &QUOT;<a href='${env.BUILD_URL}'>${env.JOB_NAME} [${env.BUILD_NUMBER}]</a>&QUOT;</p>"""

  if (buildStatus == 'STARTED') {
    color = 'YELLOW'
    colorCode = '#FFCC00'
  } else if (buildStatus == 'SUCCESSFUL') {
    color = 'GREEN'
    colorCode = '#228B22'
  } else {
    color = 'RED'
    colorCode = '#FF0000'
  }

  slackSend (color: colorCode, message: summary)
}
