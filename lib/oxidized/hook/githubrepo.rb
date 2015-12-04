class GithubRepo < Oxidized::Hook
  def validate_cfg!
    cfg.has_key?('remote_repo') or raise KeyError, 'remote_repo is required'
  end

  def run_hook(ctx)
    credentials = Rugged::Credentials::UserPassword.new(username: cfg.username, password: cfg.password)
    repo = Rugged::Repository.new(Oxidized.config.output.git.repo)
    log "Pushing local repository(#{repo.path})..."
    remote = repo.remotes['origin'] || repo.remotes.create('origin', cfg.remote_repo)
    log "to remote: #{remote.url}"

    fetch_remote

    remote.push(['refs/heads/master'], credentials: credentials)
  end

  def fetch_remote
    repo.fetch('origin', [repo.head.name], credentials: credentials)
    merge_index = repo.merge_commits(repo.head.target, repo.branches['origin/master'].target)
    Rugged::Commit.create(repo, {
      parents: [repo.head.target, repo.branches['origin/master'].target],
      tree: merge_index.write_tree(repo),
      message: "Merge remote-tracking branch 'origin/master'",
      update_ref: repo.head.name
    })
    repo.checkout_head(strategy: :force)
  end
end
