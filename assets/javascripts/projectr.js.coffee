#= require vendor/jquery-2.0.2.min
#= require vendor/underscore-min.js
#= require vendor/marked.js

Projectr = {
  languageSelector: '#language'
  issueSelector: '#issue'
  buttonSelector: '#buttons'
  apiBaseUrl: "https://api.github.com"

  updateIssue: ->
    @_startLoading()
    @_updateRepo() unless @_language() == ''

  _repoUrl: ->
    "#{@apiBaseUrl}/legacy/repos/search/#{@_randomLetter()}?language=#{encodeURIComponent(@_language())}"

  _updateRepo: ->
    cachedRepo = RepoCache.get(@_language())
    if cachedRepo?
      @_updateIssueForRepo(cachedRepo)
    else
      @_updateCachedRepos()

  _randomLetter: ->
    letters = "abcdefghijklmnopqrstuvwxyz"
    letters[Math.floor(Math.random() * (letters.length + 1))]

  _updateIssueForRepo: (repo) ->
    $.ajax(
      url: @_issueURL(repo)
      dataType: 'jsonp'
    ).done (response) =>
      if response.meta['X-RateLimit-Remaining'] is '0'
        @_limitExceeded()
      else
        issue = _.find response.data, (issue) ->
          issue.pull_request.html_url is null and issue.body isnt '' and issue.body isnt null

        if issue
          @_displayIssue(issue)
        else
          @_updateRepo()

  _updateCachedRepos: ->
    $.ajax(
      url: @_repoUrl()
      dataType: 'jsonp'
    ).done (response) =>
     if response.meta['X-RateLimit-Remaining'] is '0'
       @_limitExceeded()
     else
      RepoCache.set(@_language(), response.data.repositories)
      @_updateRepo()

  _randomLetter: ->
    letters = "abcdefghijklmnopqrstuvwxyz"
    letters[Math.floor(Math.random() * (letters.length + 1))]

  _displayIssue: (issue) ->
    $(@issueSelector).html(_.template($('#issue_template').html(), { issue: issue }))
    @_finishedLoading()

  _issueURL: (repo) ->
    "#{@apiBaseUrl}/repos/#{repo.owner}/#{repo.name}/issues"

  _language: ->
    $(@languageSelector).val()

  _startLoading: ->
    $('.content').addClass('loading')

  _finishedLoading: ->
    $('.content').removeClass('loading')

  _limitExceeded: ->
    @_finishedLoading()
    $(@issueSelector).addClass('rate-limit-exceeded').html('Request limit has been exceeded. Please try again from another IP Address')
    $(@buttonSelector).hide()

}

RepoCache = {
  get: (language) ->
    if @_storage(language).length > 0
      repos = @_storage(language)
      repo  = repos.pop()
      @set(language, repos)

      repo

  set: (language, repositories) ->
    allRepositories = { }

    if localStorage.repositories?
      allRepositories = JSON.parse(localStorage.repositories)

    allRepositories[language] = @_filter(repositories)
    localStorage.repositories = JSON.stringify(allRepositories)

  _filter: (repositories) ->
    repositories = _.filter repositories, (repo) ->
      repo.has_issues and repo.open_issues > 0

  _storage: (language) ->
    if localStorage.repositories?
      JSON.parse(localStorage.repositories)[language] || { }
    else
      { }
}

$(document).ready ->
  Projectr.updateIssue()

  $('#language').change ->
    issue    = Projectr.updateIssue()

  $('#new').click ->
    issue    = Projectr.updateIssue()

  $('#do_it').click ->
    window.location = $('#issue a').attr('href')
