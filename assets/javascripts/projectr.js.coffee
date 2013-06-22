#= require vendor/jquery-2.0.2.min
#= require vendor/underscore-min.js
#= require vendor/mustache.js

Projectr = {
  apiBaseUrl: "https://api.github.com"

  updateIssue: (language) ->
    @_updateRepo()

  _updateRepo: (language) ->
    $.ajax(
      url: @_repoUrl(language)
      dataType: 'jsonp'
    ).done (response) =>
      repo = _.find response.data.repositories, (repo) ->
        repo.open_issues > 0

      @_updateIssueForRepo(repo)

   _repoUrl: (language) ->
      "#{@apiBaseUrl}/legacy/repos/search/#{@_randomLetter()}?language=#{language}"

   _randomLetter: ->
     letters = "abcdefghijklmnopqrstuvwxyz"
     letters[Math.floor(Math.random() * (letters.length + 1))]

   _updateIssueForRepo: (repo) ->
     $.ajax(
       url: @_issueURL(repo)
       dataType: 'jsonp'
     ).done (response) =>
       issue = _.find response.data, (issue) ->
         issue.pull_request.html_url == null

       @_displayIssue(issue)

   _displayIssue: (issue) ->
     $('#issue').html(_.template($('#issue_template').html(), { issue: issue }))

   _issueURL: (repo) ->
     window.repo = repo
     "#{@apiBaseUrl}/repos/#{repo.owner}/#{repo.name}/issues"
}


$(document).ready ->
  $('#language').change ->
    language = $(this).val()
    issue    = Projectr.updateIssue(language)
