def workingDir = new File(".")

def stagingTagCommand = "git describe --abbrev=0 --match staging-*".execute()
stagingTagCommand.waitFor()
stagingTag = stagingTagCommand.text
println "Current staging tag is: "+ stagingTag

String stagingTagCommitCommandString = "git rev-list -n 1 "+ stagingTag
println "Stagin tag commit command: "+ stagingTagCommitCommandString

def stagingTagCommitCommand=stagingTagCommitCommandString.execute()
stagingTagCommitCommand.waitFor()

stagingTagCommit = stagingTagCommitCommand.text

println "Current staging commit is: "+ stagingTagCommit



println stagingTagCommand.exitValue()
