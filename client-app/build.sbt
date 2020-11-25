ThisBuild / scalaVersion := "2.12.12"

//resolvers += "Local Maven Repository" at "file://"+Path.userHome.absolutePath+"/.m2/repository"
val silencerVersion = "1.7.1"
lazy val demo = (project in file("."))
  .settings(
    name := "demo",
    version := "0.1",
    libraryDependencies += "com.daml" %% "bindings-akka" % "0.0.0",
    libraryDependencies += "org.scalatest" %% "scalatest" % "3.0.5" % Test,
    resolvers += Resolver.mavenLocal,
    mainClass in assembly := Some("app.ClientApp"),
    assemblyMergeStrategy in assembly := {
      case PathList("META-INF", xs @ _*) => MergeStrategy.discard
      case x => MergeStrategy.first
    },
    assemblyJarName in assembly := "client.jar"
  )
