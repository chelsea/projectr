#= require vendor/jquery-2.0.2.min
#= require vendor/underscore-min.js
#= require vendor/marked.js

Projectr = {
  languageSelector: '#language'
  issueSelector: '#issue'
  apiBaseUrl: "https://api.github.com"

  updateIssue: ->
    @_startLoading()
    @_updateRepo() unless @_language() == ''

  _updateRepo: ->
    $.ajax(
      url: @_repoUrl()
      dataType: 'jsonp'
    ).done (response) =>
      if response.meta['X-RateLimit-Remaining'] is '0'
        @_limitExceeded()
      else
        repo = _.find response.data.repositories, (repo) ->
          repo.has_issues and repo.open_issues > 0

        @_updateIssueForRepo(repo)
  _repoUrl: ->
    "#{@apiBaseUrl}/legacy/repos/search/#{@_randomLetter()}?language=#{@_language()}"

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
    $(@issueSelector).html('Request limit has been exceeded. Please try again from another IP Address')
}


$(document).ready ->
  Projectr.updateIssue()

  $('#language').change ->
    issue    = Projectr.updateIssue()

  $('#new').click ->
    issue    = Projectr.updateIssue()

  $('#do_it').click ->
    window.location = $('#issue a').attr('href')
