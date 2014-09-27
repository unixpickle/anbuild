part of anbuild;

/**
 * A shortcut for creating a new [GitDependencyFetcher] and using it to fetch a
 * repository.
 */
Future fetchGitDependency(String name, String url, {String directory: null,
                          String gitCommand: 'git', String branch: null}) {
  return new GitDependencyFetcher(name, url, directory: directory,
      gitCommand: gitCommand, branch: branch).fetch();
}

/**
 * An error which occurs when a `git` command terminates with an exit value
 * other than 0.
 */
class GitCommandError extends Error {
  final String message;
  
  GitCommandError(this.message);
  
  String toString() {
    return 'GitCommandError: $message';
  }
}

/**
 * A [DependencyFetcher] that can download Git repositories.
 */
class GitDependencyFetcher extends DependencyFetcher {
  /**
   * The git repository URL.
   */
  final String gitUrl;
  
  /**
   * The git command path.
   * 
   * In some cases, this can simply be "git". In other situations, a full path
   * might be necessary.
   */
  final String gitCommand;
  
  /**
   * The branch of the remote repository to fetch. If this is `null`, the
   * default branch is fetched.
   */
  final String branch;
  
  /**
   * Create a new [GitDependencyFetcher] with a [gitUrl] and a dependency
   * [name].
   * 
   * The [directory] argument is passed directly to [DependencyFetcher].
   * 
   * The [gitCommand] and [branch] are directly assigned to their
   * corresponding instance fields.
   */
  GitDependencyFetcher(String name, this.gitUrl, {this.gitCommand: 'git',
                       this.branch: null, String directory: null})
      : super(name, directory: directory);
  
  /**
   * Asynchronously runs a `git clone` command.
   */
  Future downloadDependency() {
    var cloneArgs = ['clone'];
    if (branch != null) {
      cloneArgs.addAll(['--branch', branch]);
    }
    cloneArgs.addAll([gitUrl, dependencyPath]);
    return Process.run(gitCommand, cloneArgs).then((result) {
      if (result.exitCode != 0) {
        throw new GitCommandError('clone failed: $gitUrl');
      }
    });
  }
}
